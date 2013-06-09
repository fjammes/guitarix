/*
 * Copyright (C) 2009, 2010 Hermann Meyer, James Warden, Andreas Degert
 * Copyright (C) 2011 Pete Shorthose
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 * ---------------------------------------------------------------------------
 * ----------------------------------------------------------------------------
 *
 *    This is gx_head main.
 *
 * ----------------------------------------------------------------------------
 */

#include "guitarix.h"       // NOLINT

#include <gtkmm/main.h>     // NOLINT
#include <gxwmm/init.h>     // NOLINT
#include <string>           // NOLINT
#include "jsonrpc.h"

/****************************************************************
 ** class PosixSignals
 **
 ** Block unix signals and catch them in a special thread.
 ** Blocking is inherited by all threads created after an
 ** instance of PosixSignals
 */

class PosixSignals {
private:
    sigset_t waitset;
    Glib::Thread *thread;
    pthread_t pthr;
    bool gui;
    volatile bool exit;
    void signal_helper_thread();
    void quit_slot();
    void gx_ladi_handler();
    void create_thread();
    bool gtk_level();
    static void relay_sigchld(int);
public:
    PosixSignals(bool gui);
    ~PosixSignals();
};

PosixSignals::PosixSignals(bool gui_)
    : waitset(),
      thread(),
      pthr(),
      gui(gui_),
      exit(false) {
    sigemptyset(&waitset);
    /* ----- block signal USR1 ---------
    ** inherited by all threads which are created later
    ** signals are processed synchronously by signal_helper_thread
    */
    sigaddset(&waitset, SIGUSR1);
    sigaddset(&waitset, SIGCHLD);
    sigaddset(&waitset, SIGINT);
    sigaddset(&waitset, SIGQUIT);
    sigaddset(&waitset, SIGTERM);
    sigaddset(&waitset, SIGHUP);
    sigaddset(&waitset, SIGKILL);

    // ----- leave alone these signals: generated by programming errors
    // SIGABRT
    // SIGSEGV

    sigprocmask(SIG_BLOCK, &waitset, NULL);
    create_thread();
    signal(SIGCHLD, relay_sigchld);
}

PosixSignals::~PosixSignals() {
    if (thread) {
	exit = true;
	pthread_kill(pthr, SIGINT);
	thread->join();
    }
    sigprocmask(SIG_UNBLOCK, &waitset, NULL);
}

void PosixSignals::create_thread() {
    try {
	thread = Glib::Thread::create(
	    sigc::mem_fun(*this, &PosixSignals::signal_helper_thread), true);
    } catch (Glib::ThreadError& e) {
	throw gx_system::GxFatalError(
	    boost::format(_("Thread create failed (signal): %1%")) % e.what());
    }
}

void PosixSignals::quit_slot() {
    gx_system::GxExit::get_instance().exit_program();
}

void PosixSignals::gx_ladi_handler() {
    gx_system::gx_print_warning(
	_("signal_handler"), _("signal USR1 received, save settings"));
    if (gx_preset::GxSettings::instance) {
    bool cur_state = gx_preset::GxSettings::instance->get_auto_save_state();
    gx_preset::GxSettings::instance->disable_autosave(false);
	gx_preset::GxSettings::instance->auto_save_state();
    gx_preset::GxSettings::instance->disable_autosave(cur_state);
    }
}

void PosixSignals::relay_sigchld(int) {
    kill(getpid(), SIGCHLD);
}

bool PosixSignals::gtk_level() {
    if (! gui) {
	return 1;
    } else {
	return Gtk::Main::level();
    }
}

// --- wait for USR1 signal to arrive and invoke ladi handler via mainloop
void PosixSignals::signal_helper_thread() {
    pthr = pthread_self();
    const char *signame;
    guint source_id_usr1 = 0;
    pthread_sigmask(SIG_BLOCK, &waitset, NULL);
    bool seen = false;
    while (true) {
	int sig;
        int ret = sigwait(&waitset, &sig);
	if (exit) {
	    break;
	}
        if (ret != 0) {
            assert(errno == EINTR);
	    continue;
	}
	switch (sig) {
	case SIGUSR1:
	    if (gtk_level() < 1) {
		gx_system::gx_print_info(_("system startup"),
					 _("signal usr1 skipped"));
		break;
	    }
	    // do not add a new call if another one is already pending
	    if (source_id_usr1 == 0 ||
		g_main_context_find_source_by_id(NULL, source_id_usr1) == NULL) {
		const Glib::RefPtr<Glib::IdleSource> idle_source = Glib::IdleSource::create();
		idle_source->connect(
		    sigc::bind_return<bool>(
			sigc::mem_fun(*this, &PosixSignals::gx_ladi_handler),false));
		idle_source->attach();
		source_id_usr1 = idle_source->get_id();
	    }
	    break;
	case SIGCHLD:
	    Glib::signal_idle().connect_once(
		sigc::ptr_fun(gx_child_process::gx_sigchld_handler));
	    break;
	case SIGINT:
	case SIGQUIT:
	case SIGTERM:
	case SIGHUP:
	    switch (sig) {
	    case SIGINT:
		signame = _("ctrl-c");
		break;
	    case SIGQUIT:
		signame = "SIGQUIT";
		break;
	    case SIGTERM:
		signame = "SIGTERM";
		break;
	    case SIGHUP:
		signame = "SIGHUP";
		break;
	    }
	    if (!seen && gtk_level() == 1) {
		printf("\nquit (%s)\n", signame);
		Glib::signal_idle().connect_once(sigc::mem_fun(*this, &PosixSignals::quit_slot));
	    } else {
		gx_system::GxExit::get_instance().exit_program(
		    (boost::format("\nQUIT (%1%)\n") % signame).str());
	    }
	    seen = true;
	    break;
	default:
	    assert(false);
        }
    }
}


/****************************************************************
 ** class ErrorPopup
 ** show UI popup for kError messages
 */

class ErrorPopup {
private:
    Glib::ustring msg;
    bool active;
    Gtk::MessageDialog *dialog;
    void show_msg();
    void on_response(int);
public:
    ErrorPopup();
    ~ErrorPopup();
    void on_message(const Glib::ustring& msg, gx_system::GxMsgType tp, bool plugged);
};

ErrorPopup::ErrorPopup()
    : msg(),
      active(false),
      dialog(0) {
}

ErrorPopup::~ErrorPopup() {
    delete dialog;
}

void ErrorPopup::on_message(const Glib::ustring& msg_, gx_system::GxMsgType tp, bool plugged) {
    if (plugged) {
	return;
    }
    if (tp == gx_system::kError) {
	if (active) {
	    msg += "\n" + msg_;
	    if (msg.size() > 1000) {
		msg.substr(msg.size()-1000);
	    }
	    if (dialog) {
		dialog->set_message(msg);
	    }
	} else {
	    msg = msg_;
	    active = true;
	    show_msg();
	}
    }
}

void ErrorPopup::on_response(int) {
    delete dialog;
    dialog = 0;
    active = false;
}

void ErrorPopup::show_msg() {
    dialog = new Gtk::MessageDialog(msg, false, Gtk::MESSAGE_ERROR, Gtk::BUTTONS_CLOSE);
    dialog->set_keep_above(true);
    //Gtk::VBox *ma = dialog->get_message_area(); // not in Gtkmm 0.20
    //FIXME: no comment :-)
    Gtk::VBox *ma = dynamic_cast<Gtk::VBox*>(
	*(++dynamic_cast<Gtk::HBox*>(
	      *dialog->get_vbox()->get_children().begin())->get_children().begin()));
    // add an alignment parent to the label widget inside the message area
    // should better define our own dialog instead of hacking MessageDialog...
    Gtk::Alignment *align = new Gtk::Alignment();
    align->show();
    dynamic_cast<Gtk::Label*>(*ma->get_children().begin())->reparent(*align);
    ma->pack_start(*manage(align));
    align->set_padding(50,20,0,10);
    Gtk::VBox *vbox = dynamic_cast<Gtk::VBox *>(dialog->get_child());
    vbox->set_redraw_on_allocate(true);
    vbox->signal_expose_event().connect(
	sigc::group(&gx_cairo::error_box_expose,GTK_WIDGET(vbox->gobj()),sigc::_1,(void*)0),false);
    dialog->set_title(_("GUITARIX ERROR"));
    dialog->signal_response().connect(
	sigc::mem_fun(*this, &ErrorPopup::on_response));
    dialog->show();
}

/****************************************************************
 ** class GxSplashBox
 ** show splash screen at start up
 */

class GxSplashBox: public Gtk::Window {
 public:
    explicit GxSplashBox();
    ~GxSplashBox();
};
GxSplashBox::~GxSplashBox() {}

GxSplashBox::GxSplashBox()
    : Gtk::Window(Gtk::WINDOW_POPUP) {
    set_redraw_on_allocate(true);
    set_app_paintable();
    signal_expose_event().connect(
        sigc::group(&gx_cairo::splash_expose, GTK_WIDGET(gobj()),
		    sigc::_1, (void*)0), false);
    set_decorated(false);
    set_type_hint(Gdk::WINDOW_TYPE_HINT_SPLASHSCREEN);
    set_position(Gtk::WIN_POS_CENTER );
    set_default_size(280,80);
    show_all();
    while(Gtk::Main::events_pending())
        Gtk::Main::iteration(false); 
}

/****************************************************************
 ** main()
 */
#if 0
#ifndef NDEBUG
int debug_display_glade(gx_engine::GxEngine& engine, gx_system::CmdlineOptions& options,
                        gx_engine::ParamMap& pmap, const string& fname) {
    pmap.set_init_values();
    if (!options.get_rcset().empty()) {
	std::string rcfile = options.get_style_filepath("gx_head_"+options.get_rcset()+".rc");
	gtk_rc_parse(rcfile.c_str());
	gtk_rc_reset_styles(gtk_settings_get_default());
    }
    Gtk::Window *w = 0;
    gx_ui::GxUI ui;
    Glib::RefPtr<gx_gui::GxBuilder> bld = gx_gui::GxBuilder::create_from_file(fname, &machine);
    w = bld->get_first_window();
    gx_ui::GxUI::updateAllGuis(true);
    if (w) {
	Gtk::Main::run(*w);
	delete w;
    }
    return 0;
}
#endif
#endif

//FIXME: join with MainWindow::do_program_change
void do_program_change(int pgm, gx_engine::GxMachineBase& machine) {
    Glib::ustring bank = machine.get_current_bank();
    bool in_preset = !bank.empty();
    gx_system::PresetFile *f;
    if (in_preset) {
	f = machine.get_bank_file(bank);
	in_preset = pgm < f->size();
    }
    if (in_preset) {
	machine.load_preset(f, f->get_name(pgm));
	if (machine.get_state() == gx_engine::kEngineBypass) {
	    machine.set_state(gx_engine::kEngineOn);
	}
    } else if (machine.get_state() == gx_engine::kEngineOn) {
	machine.set_state(gx_engine::kEngineBypass);
    }
}

bool update_all_gui(gx_engine::GxMachineBase& machine) {
    // the general Gui update handler
    gx_ui::GxUI::updateAllGuis();
    machine.check_module_lists();
    return true;
}

static void mainHeadless(int argc, char *argv[]) {
    Glib::init();
    Gio::init();

    gx_system::CmdlineOptions options;
    options.parse(argc, argv);
    PosixSignals posixsig(false); // catch unix signals in special thread
    options.process(argc, argv);
    // ---------------- Check for working user directory  -------------
    bool need_new_preset;
    if (gx_preset::GxSettings::check_settings_dir(options, &need_new_preset)) {
	cerr << 
	    _("old config directory found (.gx_head)."
	      " state file and standard presets file have been copied to"
	      " the new directory (.config/guitarix).\n"
	      " Additional old preset files can be imported into the"
	      " new bank scheme by mouse drag and drop with a file"
	      " manager");
	return;
    }

    gx_engine::GxMachine machine(options);

    gx_jack::GxJack::rt_watchdog_set_limit(options.get_idle_thread_timeout());
    machine.loadstate();
    //if (!in_session) {
    //	gx_settings.disable_autosave(options.get_opt_auto_save());
    //}
    machine.signal_midi_new_program().connect(
	sigc::bind(sigc::ptr_fun(do_program_change),sigc::ref(machine)));

    if (! machine.get_jack()->gx_jack_connection(true, true, 0)) {
	cerr << "can't connect to jack\n";
	return;
    }
    if (need_new_preset) {
	machine.create_default_scratch_preset();
    }
    // ----------------------- Run Glib main loop ----------------------
    Glib::signal_timeout().connect(sigc::bind(sigc::ptr_fun(update_all_gui), sigc::ref(machine)), 40);
    cout << "Ctrl-C to quit\n";
    Glib::RefPtr<Glib::MainLoop> loop = Glib::MainLoop::create();
    machine.get_jack()->shutdown.connect(sigc::mem_fun(loop.operator->(),&Glib::MainLoop::quit));
    int port = options.get_rpcport();
    if (port == RPCPORT_DEFAULT) {
	port = 7000;
    }
    if (port != RPCPORT_NONE) {
	machine.start_socket(sigc::mem_fun(loop.operator->(),&Glib::MainLoop::quit), port);
	loop->run();
    } else {
	loop->run();
    }
}

static void mainGtk(int argc, char *argv[]) {
    Glib::init();
    Gxw::init();

    gx_system::CmdlineOptions options;
    PosixSignals posixsig(true); // catch unix signals in special thread
    Gtk::Main main(argc, argv, options);
    options.process(argc, argv);
    GxSplashBox * Splash = NULL;
#ifdef NDEBUG
    Splash =  new GxSplashBox();
#endif
    gx_system::GxExit::get_instance().signal_msg().connect(
	sigc::ptr_fun(gx_gui::show_error_msg));  // show fatal errors in UI
    ErrorPopup popup;
    gx_system::Logger::get_logger().signal_message().connect(
	sigc::mem_fun(popup, &ErrorPopup::on_message));
    // ---------------- Check for working user directory  -------------
    bool need_new_preset;
    if (gx_preset::GxSettings::check_settings_dir(options, &need_new_preset)) {
	Gtk::MessageDialog dialog(
	    _("old config directory found (.gx_head)."
	      " state file and standard presets file have been copied to"
	      " the new directory (.config/guitarix).\n"
	      " Additional old preset files can be imported into the"
	      " new bank scheme by mouse drag and drop with a file"
	      " manager"), false, Gtk::MESSAGE_INFO, Gtk::BUTTONS_CLOSE, true);
	dialog.set_title("Guitarix");
	dialog.run();
    }

    gx_engine::GxMachine machine(options);
#if 0
#ifndef NDEBUG
    if (argc > 1) {
	delete Splash;
	debug_display_glade(engine, options, gx_engine::parameter_map, argv[1]);
	return;
    }
#endif
#endif
    // ----------------------- init GTK interface----------------------
    MainWindow gui(machine, options, Splash);
    if (need_new_preset) {
	gui.create_default_scratch_preset();
    }
    // ----------------------- run GTK main loop ----------------------
    delete Splash;
    gui.run();
}

static void mainFront(int argc, char *argv[]) {
    Glib::init();
    Gxw::init();

    gx_system::CmdlineOptions options;
    PosixSignals posixsig(true); // catch unix signals in special thread
    Gtk::Main main(argc, argv, options);
    options.process(argc, argv);
    GxSplashBox * Splash = NULL;
#ifdef NDEBUG
    Splash =  new GxSplashBox();
#endif
    gx_system::GxExit::get_instance().signal_msg().connect(
	sigc::ptr_fun(gx_gui::show_error_msg));  // show fatal errors in UI
    ErrorPopup popup;
    gx_system::Logger::get_logger().signal_message().connect(
	sigc::mem_fun(popup, &ErrorPopup::on_message));
    // ---------------- Check for working user directory  -------------
    bool need_new_preset;
    if (gx_preset::GxSettings::check_settings_dir(options, &need_new_preset)) {
	Gtk::MessageDialog dialog(
	    _("old config directory found (.gx_head)."
	      " state file and standard presets file have been copied to"
	      " the new directory (.config/guitarix).\n"
	      " Additional old preset files can be imported into the"
	      " new bank scheme by mouse drag and drop with a file"
	      " manager"), false, Gtk::MESSAGE_INFO, Gtk::BUTTONS_CLOSE, true);
	dialog.set_title("Guitarix");
	dialog.run();
    }

    gx_engine::GxMachineRemote machine(options);

    // ----------------------- init GTK interface----------------------
    MainWindow gui(machine, options, Splash);
    if (need_new_preset) {
	gui.create_default_scratch_preset();
    }
    // ----------------------- run GTK main loop ----------------------
    delete Splash;
    gui.run();
}

static bool is_headless(int argc, char *argv[]) {
    for (int i = 0; i < argc; ++i) {
	if (strcmp(argv[i], "-N") == 0 || strcmp(argv[i], "--nogui") == 0) {
	    return true;
	}
    }
    return false;
}

static bool is_frontend(int argc, char *argv[]) {
    return false;
}

int main(int argc, char *argv[]) {
#ifdef DISABLE_NLS
// break
#elif IS_MACOSX
// break
#elif ENABLE_NLS
    bindtextdomain(GETTEXT_PACKAGE, LOCALEDIR);
    bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
    textdomain(GETTEXT_PACKAGE);
#endif

    try {
	// ----------------------- init basic subsystems ----------------------
#ifndef G_DISABLE_DEPRECATED
	if (!g_thread_supported ()) {
	    Glib::thread_init();
	}
#endif
	if (is_headless(argc, argv)) {
	    mainHeadless(argc, argv);
	} else if (is_frontend(argc, argv)) {
	    mainFront(argc, argv);
	} else {
	    mainGtk(argc, argv);
	}
	gx_child_process::childprocs.killall();
    } catch (const Glib::OptionError &e) {
	cerr << e.what() << endl;
	cerr << _("use \"guitarix -h\" to get a help text") << endl;
	return 1;
    } catch (const gx_system::GxFatalError &e) {
	cerr << e.what() << endl;
	return 1;
    } catch (const Glib::Exception &e) {
	cerr << "unknown Glib Exception: " << e.what() << endl;
	return 1;
    }
    return 0;
}
