/*
 * Copyright (C) 2009, 2010 Hermann Meyer, James Warden, Andreas Degert
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
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 * --------------------------------------------------------------------------
 *
 *  This is the guitarix interface to the jackd audio / midi server
 *
 * --------------------------------------------------------------------------
 */
#include <errno.h>

#include <cstring>
#include <vector>
#include <list>
#include <map>
#include <set>
#include <iostream>
#include <sstream>
#include <fstream>
#include <cmath>
#include <sys/types.h>
#include <signal.h>

#include <array>
#include <zita-convolver.h>
#include <fftw3.h>
#include <zita-resampler.h>

#include <cassert>
#include <sigc++/sigc++.h>
#include <semaphore.h>

using namespace std;

#include <sndfile.h>
#include <jack/jack.h>
#include <jack/statistics.h>
#include <jack/midiport.h>
#include <gtk/gtk.h>

#include "guitarix.h"

#ifdef HAVE_JACK_SESSION
#include <jack/session.h>
#endif

using namespace gx_system;
using namespace gx_engine;
using namespace gx_jconv;
using namespace gx_child_process;

namespace gx_jack
{

//----- pop up a dialog for starting jack
bool gx_jack_init( const string *optvar )
{
	jack_status_t jackstat;
	client_name = "guitarix";

	// init the pointer to the jackbuffer
	for (int i=0; i < nOPorts; i++) output_ports[i] = 0;
	for (int i=0; i < nIPorts; i++) input_ports [i] = 0;

	AVOIDDENORMALS;

#ifdef HAVE_JACK_SESSION
	// try to open jack client
	if (! optvar[JACK_UUID].empty())

	    client = jack_client_open (client_name.c_str(), jack_options_t(JackNoStartServer | JackSessionID), &jackstat, optvar[JACK_UUID].c_str());
	else
#endif
	    client = jack_client_open (client_name.c_str(), JackNoStartServer, &jackstat);

	if (client == 0)
	{
		gx_print_warning("Jack Init", "not yet a jack client");

		// if jackd is running, let's call ourselves again
		if (gx_system_call("pgrep", "jackd", true) == SYSTEM_OK)
		{
			gx_print_warning("Jack Init", "jackd OK, trying to be a client");
			usleep(500000);
			return gx_jack_init( optvar );
		}

		// start a dialog
		if (gx_start_jack_dialog())
		{
			// so let's try to be a jack client again
			client = jack_client_open (client_name.c_str(), JackNoStartServer, &jackstat);

			if (!client)
			{
				gx_print_error("main",
				               string("I really tried to get jack up and running, sorry ... "));
				return false;
			}
		}

		else   // we give up
		{
			gx_print_error("main",
			               string("Ignoring jackd ..."));
			return false;
		}
	}

	// ----------------------------------
	jack_is_down = false;
	is_rt = jack_is_realtime (client);

	// it is maybe not the 1st guitarix instance ?
	if (jackstat & JackNameNotUnique)
		client_name = jack_get_client_name (client);

#ifdef USE_RINGBUFFER
	jack_ringbuffer = jack_ringbuffer_create(2048*sizeof(struct MidiMessage));

	if (jack_ringbuffer == NULL)
	{
		g_critical("Cannot create JACK ringbuffer.");
		gx_clean_exit(NULL, NULL);
	}

	jack_ringbuffer_reset(jack_ringbuffer);
	jack_ringbuffer_mlock(jack_ringbuffer);

#endif

	jack_sr = jack_get_sample_rate (client); // jack sample rate
	ostringstream s;
	s << "The jack sample rate is " << jack_sr << "/sec";
	gx_print_info("Jack init", s.str().c_str());

	jack_bs = jack_get_buffer_size (client); // jack buffer size
	s.str("");
	s << "The jack buffer size is " << jack_bs << "/frames ... ";

	gx_print_info("Jack init", s.str());


	if (gx_gui::fWindow)
		gtk_window_set_title (GTK_WINDOW (gx_gui::fWindow), client_name.c_str());

	return true;
}

struct PortConnData
{
	string name_a, name_b;
	int connect;
	PortConnData(string a, string b, int conn): name_a(a), name_b(b), connect(conn) {}
};

static gboolean gx_jack_portconn_helper(gpointer data)
{
	PortConnData *pc = (PortConnData*)data;
	if (gx_gui::PortMapWindow::instance) {
		gx_gui::PortMapWindow::instance->connection_changed(pc->name_a, pc->name_b, pc->connect);
	}
	delete pc;
	return FALSE;
}

static void gx_jack_portconn_callback(jack_port_id_t a, jack_port_id_t b, int connect, void*)
{
	if (!client) {
		return;
	}
	jack_port_t* port_a = jack_port_by_id(client, a);
	jack_port_t* port_b = jack_port_by_id(client, b);
	if (!port_a || !port_b) {
		return;
	}
	gtk_idle_add(gx_jack_portconn_helper,
	             new PortConnData(jack_port_name(port_a), jack_port_name(port_b),
	                              connect));
}


//----- set client callbacks and activate client
// Note: to be called after gx_engine::gx_engine_init()
void gx_jack_callbacks_and_activate()
{
	//----- set the jack callbacks
	jack_set_xrun_callback(client, gx_jack_xrun_callback, NULL);
	jack_set_sample_rate_callback(client, gx_jack_srate_callback, 0);
	jack_on_shutdown(client, gx_jack_shutdown_callback, NULL);
	jack_set_buffer_size_callback (client, gx_jack_buffersize_callback, 0);
	jack_set_process_callback(client, gx_jack_process, 0);
	jack_set_port_registration_callback(client, gx_jack_portreg_callback, 0);
	jack_set_port_connect_callback(client, gx_jack_portconn_callback, 0);
#ifdef HAVE_JACK_SESSION
	if (jack_set_session_callback)
		jack_set_session_callback (client, gx_jack_session_callback, 0);
#endif

	//----- register the midi input channel
	midi_input_port =
		jack_port_register(client, "midi_in_1", JACK_DEFAULT_MIDI_TYPE, JackPortIsInput, 0);

	//----- register the input channel
	input_ports[0] =
		jack_port_register(client, "in_0", JACK_DEFAULT_AUDIO_TYPE, JackPortIsInput, 0);

	//----- register the midi output channel
	midi_output_ports =
		jack_port_register(client, "midi_out_1", JACK_DEFAULT_MIDI_TYPE, JackPortIsOutput, 0);

	//----- register the audio output channels
	for (int i = 0; i < 2; i++) {
		ostringstream buf;
		buf <<  "out_" << i;
		output_ports[i] =
			jack_port_register(client, buf.str().c_str(),
			                   JACK_DEFAULT_AUDIO_TYPE, JackPortIsOutput, 0);
	}

	//----- ready to go
	if (jack_activate(client))
	{
		gx_print_error("Jack Activation",
		               string("Can't activate JACK client"));
		gx_clean_exit(NULL, NULL);
	}
}

//----- connect ports if we know them
void gx_jack_init_port_connection(const string* optvar)
{
	// set autoconnect capture to user capture port
	if (!optvar[JACK_INP].empty())
	{
		jack_connect(client, optvar[JACK_INP].c_str(),
		             jack_port_name(input_ports[0]));
	} else {
		list<string>& l = jack_connection_lists[kAudioInput];
		for (list<string>::iterator i = l.begin(); i != l.end(); i++) {
			jack_connect(client, i->c_str(), jack_port_name(input_ports[0]));
		}
	}

	// set autoconnect midi to user midi port
	if (midi_input_port && !optvar[JACK_MIDI].empty())
	{
		jack_connect(client, optvar[JACK_MIDI].c_str(),
		             jack_port_name(midi_input_port));
	} else {
		list<string>& l = jack_connection_lists[kMidiInput];
		for (list<string>::iterator i = l.begin(); i != l.end(); i++) {
			jack_connect(client, i->c_str(), jack_port_name(midi_input_port));
		}
	}

	// set autoconnect to user playback ports
	if (optvar[JACK_OUT1].empty() && optvar[JACK_OUT2].empty()) {
		list<string>& l1 = jack_connection_lists[kAudioOutput1];
		for (list<string>::iterator i = l1.begin(); i != l1.end(); i++) {
			jack_connect(client, jack_port_name(output_ports[0]), i->c_str());
		}
		list<string>& l2 = jack_connection_lists[kAudioOutput2];
		for (list<string>::iterator i = l2.begin(); i != l2.end(); i++) {
			jack_connect(client, jack_port_name(output_ports[1]), i->c_str());
		}
	} else {
		int idx = JACK_OUT1;
		for (int i = 0; i < 2; i++) {
			if (!optvar[idx].empty()) {
				jack_connect(client,
				             jack_port_name(output_ports[i]), optvar[idx].c_str());
			}
			idx++;
		}
	}
}

//----- pop up a dialog for starting jack
bool gx_start_jack_dialog()
{
	//--- run dialog and check response
	const guint nchoices    = 3;

	const char* labels[]    =
		{
			"Start Jack", "Ignore Jack", "Exit"
		};

	const gint  responses[] =
		{
			GTK_RESPONSE_YES, GTK_RESPONSE_NO, GTK_RESPONSE_CANCEL
		};

	gint response =
		gx_gui::gx_nchoice_dialog_without_entry (
			" Jack Starter ",
			"\n                        WARNING                        \n\n"
			"   The jack server is not currently running\n"
			"   You can choose to activate it or terminate guitarix   \n\n"
			"       1) activate jack   \n"
			"       2) ignore jack, start guitarix anyway   \n"
			"       3) exit guitarix   \n",
			nchoices,
			labels,
			responses,
			GTK_RESPONSE_YES
			);

	// we are cancelling
	bool retstat = false;

	switch (response)
	{
	case GTK_RESPONSE_NO:
		jack_is_down = true;
		break;

	case GTK_RESPONSE_CANCEL:
		gx_abort(NULL);
		break;

	default:
	case GTK_RESPONSE_YES:
		retstat = gx_start_jack(NULL);
		break;
	}

	// start jack
	return retstat;
}


//----start jack if possible
bool gx_start_jack(void* arg)
{
	// first, let's try via qjackctl
	if (gx_system_call("which", "qjackctl", true) == SYSTEM_OK)
	{
		if (gx_system_call("qjackctl", "--start", true, true) == SYSTEM_OK)
		{
			sleep(5);

			// let's check it is really running
			if (gx_system_call("pgrep", "jackd", true) == SYSTEM_OK)
			{
				return true;
			}
		}
	}

	// qjackctl not found or not started, let's try .jackdrc
	string jackdrc = "$HOME/.jackdrc";
	if (gx_system_call("ls", jackdrc.c_str(), true, false) == SYSTEM_OK)
	{
		// open it
		jackdrc = string(getenv("HOME")) + string("/") + ".jackdrc";
		string cmdline = "";

		ifstream f(jackdrc.c_str());
		if (f.good())
		{
			// should contain only one command line
			getline(f, cmdline);
			f.close();
		}

		// launch jackd
		if (!cmdline.empty())
			if (gx_system_call(cmdline.c_str(), "", true, true) == SYSTEM_OK)
			{
				sleep(2);

				// let's check it is really running
				if (gx_system_call("pgrep", "jackd", true) == SYSTEM_OK)
				{
					return true;
				}
			}

	}

	return false;
}

//---- Jack server connection / disconnection
void gx_jack_connection(GtkCheckMenuItem *menuitem, gpointer arg)
{
	if (gtk_check_menu_item_get_active(GTK_CHECK_MENU_ITEM (menuitem)) == TRUE) {
		if (!client) {
			string optvar[NUM_SHELL_VAR];
			gx_assign_shell_var(shell_var_name[JACK_INP],  optvar[JACK_INP] );
			gx_assign_shell_var(shell_var_name[JACK_MIDI], optvar[JACK_MIDI] );
			gx_assign_shell_var(shell_var_name[JACK_OUT1], optvar[JACK_OUT1]);
			gx_assign_shell_var(shell_var_name[JACK_OUT2], optvar[JACK_OUT2]);
			gx_assign_shell_var(shell_var_name[JACK_UUID], optvar[JACK_UUID]);

			if (gx_jack_init(optvar)) {

				// initialize guitarix engine if necessary
				if (!gx_engine::initialized) {
					gx_engine::gx_engine_init( optvar );
				}
				gx_jack_callbacks_and_activate();
				gx_jack_init_port_connection(optvar);

				// refresh latency check menu
				gx_gui::GxMainInterface* gui = gx_gui::GxMainInterface::instance();
				GtkWidget* wd = gui->getJackLatencyItem(gx_jack::jack_bs);
				if (wd) {
					gtk_check_menu_item_set_active(GTK_CHECK_MENU_ITEM(wd), TRUE);
				}
				if (!gx_engine::pt_initialized) {
				    sleep(5);
                    // -------- pitch tracker (needs jack thread running) -------------
                    gx_engine::pitch_tracker.init();
                }
			}
		}

		if (client) {
			if (gx_gui::gx_jackd_on_image) {
				gtk_widget_show(gx_gui::gx_jackd_on_image);
				gtk_widget_hide(gx_gui::gx_jackd_off_image);
			}
			jack_is_exit = false;
			gx_print_info("Jack Server", "Connected to Jack Server");
		}
	} else {
		gx_jack_cleanup();

		// we bring down jack capture and meterbridge
		Meterbridge::stop();
		JackCapture::stop();

		if (gx_gui::gx_jackd_on_image) {
			gtk_widget_hide(gx_gui::gx_jackd_on_image);
			gtk_widget_show(gx_gui::gx_jackd_off_image);
		}

		// engine buffers no longer ready
		gx_engine::buffers_ready = false;

		gx_print_warning("Jack Server", "Disconnected from Jack Server");
	}
}

//----jack latency change
void gx_set_jack_buffer_size(GtkCheckMenuItem* menuitem, gpointer arg)
{
	// are we a proper jack client ?
	if (!client)
	{
		gx_print_error(
			"Jack Buffer Size setting",
			"we are not a jack client, server may be down"
			);

		return;
	}

	// ----- if check button triggered menually

	// let's avoid triggering the jack server on "inactive"
	if (gtk_check_menu_item_get_active(menuitem) == false)
		return;

	// requested latency
	jack_nframes_t buf_size = (jack_nframes_t)GPOINTER_TO_INT(arg);

	// if the actual buffer size is the same, no need further action
	if (buf_size == jack_get_buffer_size(client))
		return;


	// first time useage warning
	GxJackLatencyChange change_latency = kChangeLatency;

	// if user still wants to be given a choice, let's trigger dialog
	if (fwarn == 0.0)
		change_latency = (GxJackLatencyChange)gx_gui::gx_wait_latency_warn();

	// let's see
	if (change_latency == kChangeLatency)
	{
		int jcio = 0;
		if (conv.is_runnable())
		{
			jcio = 1;
			gx_jconv::GxJConvSettings::checkbutton7 = 0;
			gx_jconv::checkbox7 = 0.0;
			gx_gui::gx_start_stop_jconv(NULL, NULL);
		}

		// let's resize the buffer
		if (jack_set_buffer_size (client, buf_size) != 0)
			gx_print_warning("Setting Jack Buffer Size",
			                 "Could not change latency");

		if (jcio == 1)
		{
			jcio = 0;
			gx_jconv::GxJConvSettings::checkbutton7 = 1;
			gx_jconv::checkbox7 = 1.0;
			gx_gui::gx_start_stop_jconv(NULL, NULL);
		}
	}
	else // restore latency status
	{
		// refresh latency check menu
		gx_gui::GxMainInterface* gui = gx_gui::GxMainInterface::instance();
		GtkWidget* wd = gui->getJackLatencyItem(jack_bs);
		if (wd) gtk_check_menu_item_set_active(GTK_CHECK_MENU_ITEM(wd), TRUE);
	}

	gx_print_info("Jack Buffer Size",
	              string("latency is ") +
	              gx_i2a(jack_get_buffer_size(client)));
}

//-----Function that cleans the jack stuff on shutdown
void gx_jack_cleanup()
{
	if (client && !jack_is_down) {
		jack_is_exit = true;
		// disable input ports
		jack_port_unregister(client, input_ports[0]);
		if (midi_input_port != NULL) {
			jack_port_unregister(client, midi_input_port);
		}
		for (int i = 0; i < 2; i++) {
			jack_port_unregister(client, output_ports[i]);
		}
		if (midi_output_ports != NULL) {
			jack_port_unregister(client, midi_output_ports);
		}
#ifdef USE_RINGBUFFER
		jack_ringbuffer_free(jack_ringbuffer);
#endif

		jack_deactivate(client);
		jack_client_close(client);
		client = NULL;
	}
}

//----jack sample rate change callback
int gx_jack_srate_callback(jack_nframes_t frames, void* arg)
{
	/* Note: just reporting log for now  */

	/*  ostringstream s;
	    s << " jack sample rate changed to " << frames;
	    gx_print_warning("Jack sample rate", s.str()); */

	return 0;
}

//---- jack shutdown callback in case jackd shuts down on us
void gx_jack_shutdown_callback(void *arg)
{
	// global var to let all know that jack is down
	jack_is_down = true;
	// helper funktion to start gx_survive_jack_shutdown thread
	gx_gui::gx_jack_is_down();

}

//---- jack xrun callback
int gx_jack_xrun_callback (void* arg)
{
	xdel = jack_get_xrun_delayed_usecs(client);
	gx_gui::gx_jack_report_xrun();
	return 0;
}

//---- jack buffer size change callback
int gx_jack_buffersize_callback (jack_nframes_t nframes,void* arg)
{
	GxEngineState estate = (GxEngineState)checky;

	// turn off engine
	// Note: simply changing checky is enough to "stop" processing
	// incoming jack buffers. The mydsp::compute method is owned by
	// the jack audio thread. It always runs as long as jack runs
	// independently of the non-RT GUI thread. The value of
	// checky is checked at each jack cycle in mydsp::compute
	// so changing it here affects the behavior of mydsp::compute
	// immediately during the jack_processing of jack cycles.

	if (estate != kEngineOff)
		checky = (float)kEngineOff;

	jack_bs = nframes;


	if (checkfreq)  delete[] checkfreq;
	if (get_frame)  delete[] get_frame;
	if (get_frame1)  delete[] get_frame1;
	if (oversample) delete[] oversample;
	if (result) delete[] result;

	/** disable fft need some fix for work prop **/
	/*
	  fftw_destroy_plan(p);
	  fftw_destroy_plan(p1);
	  fftw_destroy_plan(pf);
	  fftw_free(fftin);
	  fftw_free(fftout);
	  fftw_free(fftin1);
	  fftw_free(fftout1);
	  fftw_free(fftresult);
	*/
	get_frame = new float[jack_bs];
	(void)memset(get_frame, 0, sizeof(float)*jack_bs);

	get_frame1 = new float[jack_bs];
	(void)memset(get_frame1, 0, sizeof(float)*jack_bs);

	checkfreq = new float[jack_bs];
	(void)memset(checkfreq, 0, sizeof(float)*jack_bs);

	oversample = new float[jack_bs*2];
	(void)memset(oversample, 0, sizeof(float)*jack_bs*2);

	result = new float[jack_bs+46];
	(void)memset(result, 0, sizeof(float)*jack_bs+46);
	/*
	  fftin = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * jack_bs);
	  fftout = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * jack_bs);
	  fftin1 = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * jack_bs);
	  fftout1 = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * jack_bs);
	  fftresult = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * jack_bs);

	  p = fftw_plan_dft_1d(jack_bs, fftin, fftout, FFTW_FORWARD, FFTW_ESTIMATE);
	  p1 = fftw_plan_dft_1d(jack_bs, fftout, fftresult, FFTW_BACKWARD, FFTW_ESTIMATE);
	  pf = fftw_plan_dft_1d(jack_bs, fftin1, fftout1, FFTW_FORWARD, FFTW_ESTIMATE);
	*/

	// restore previous state
	checky = (float)estate;
	// return 0 to jack
	return 0;

}

//---- jack midi control input processing
int gx_jack_midi_input_process(jack_nframes_t nframes, void *arg)
{
	if (midi_input_port != NULL)
	{
		midi_input_port_buf =  jack_port_get_buffer(midi_input_port, nframes);
		compute_midi_in(midi_input_port_buf);
	}
	return 0;
}

//---- jack midi processing
#ifndef USE_RINGBUFFER
int gx_jack_midi_process (jack_nframes_t nframes, void *arg)
{
	if (midi_output_ports != NULL)
	{
		AVOIDDENORMALS;

		midi_port_buf =  jack_port_get_buffer(midi_output_ports, nframes);
		jack_midi_clear_buffer(midi_port_buf);

		if ((isMidiOn() == true) || (gx_gui::showwave == 1))
			jcpu_load = jack_cpu_load(client);

		compute_midi(nframes);
	}
	return 0;
}

#else
int gx_jack_midi_process_ringbuffer (jack_nframes_t nframes, void *arg)
{

	/*************************************************************************
      The code for the jack_ringbuffer is take from
      jack-keyboard 2.4, a virtual keyboard for JACK MIDI.
      from Edward Tomasz Napierala <trasz@FreeBSD.org>.
	**************************************************************************/
	int read, t;
	unsigned char* buffer ;

	jack_nframes_t last_frame_time = jack_last_frame_time(client);

	midi_port_buf = jack_port_get_buffer(midi_output_ports, nframes);
	jack_midi_clear_buffer( midi_port_buf);

	if (dsp::playmidi == 1) jcpu_load = jack_cpu_load(client);
	GxEngine::instance()->compute_midi(nframes);

	while (jack_ringbuffer_read_space(jack_ringbuffer))
	{
		read = jack_ringbuffer_peek(jack_ringbuffer, (char *)&ev, sizeof(ev));

		if (read != sizeof(ev))
		{
			// fprintf(stderr, " Short read from the ringbuffer, possible note loss.\n");
			continue;
		}

		t = ev.time + nframes - last_frame_time;
		if ((t >= (int)nframes) || (cpu_load > 75.0))
			break;

		if (t < 0)
			t = 0;

		jack_ringbuffer_read_advance(jack_ringbuffer, sizeof(ev));

		if (jack_midi_max_event_size(midi_port_buf) > sizeof(ev))
			buffer = jack_midi_event_reserve(midi_port_buf, t, ev.len);
		else
			break;

		if (ev.len > 2)
			buffer[2] = ev.data[2];
		if (ev.len > 1)
			buffer[1] = ev.data[1];

		buffer[0] = ev.data[0];
	}

	/********************************************************************
      Thanks Edward for your friendly permision
      Edward Tomasz Napierala <trasz@FreeBSD.org>.
	*********************************************************************/
	return 0;
}
#endif

// ----- main jack process method
int gx_jack_process (jack_nframes_t nframes, void *arg)
{
	measure_start();
	if (!jack_is_exit) {
		AVOIDDENORMALS;

		// retrieve buffers at jack ports
		float *input = (float *)jack_port_get_buffer(input_ports[0], nframes);
		float *output0 = (float *)jack_port_get_buffer(output_ports[0], nframes);
		float *output1 = (float *)jack_port_get_buffer(output_ports[1], nframes);
		// guitarix DSP computing
		compute(nframes, input, output0, output1);

		// ready to go for e.g. level display
		gx_engine::buffers_ready = true;

		// midi input processing
		gx_jack_midi_input_process(nframes, 0);

		// midi processing
#ifdef USE_RINGBUFFER
		gx_jack_midi_process_ringbuffer(nframes, 0);
#else
		gx_jack_midi_process(nframes, 0);
#endif

		// some info display
		if (gx_gui::showwave == 1) {
			time_is =  jack_frame_time (client);
		}
	} else {
		gx_engine::buffers_ready = false;
	}
	measure_stop();
	return 0;
}

struct PortRegData
{
	string name;
	const char *tp;
	int jackflags;
	int reg;
	PortRegData(string nm, const char *t, int flags, int r): name(nm), tp(t), jackflags(flags), reg(r) {}
};

static gboolean gx_jack_portreg_helper(gpointer data)
{
	PortRegData *pm = (PortRegData*)data;
	if (gx_gui::PortMapWindow::instance) {
		gx_gui::PortMapWindow::instance->port_changed(pm->name, pm->tp, pm->jackflags, pm->reg);
	}
	delete pm;
	return FALSE;
}

//----- fetch available jack ports other than guitarix ports
void gx_jack_portreg_callback(jack_port_id_t pid, int reg, void* arg)
{
	if (!client) {
		return;
	}
	jack_port_t* port = jack_port_by_id(client, pid);
	if (!port || jack_port_is_mine(client, port)) {
		return;
	}
	gtk_idle_add(gx_jack_portreg_helper,
	             new PortRegData(jack_port_name(port), jack_port_type(port),
	                             jack_port_flags(port), reg));
}

#ifdef HAVE_JACK_SESSION
static int gx_jack_session_callback_helper(gpointer data) {
    jack_session_event_t *event = (jack_session_event_t *) data;
    string fname( event->session_dir );
    fname += "guitarix.state";
    string cmd( "guitarix -U " );
    cmd += event->client_uuid;
    cmd += " -f ${SESSION_DIR}/guitarix.state";

    saveStateToFile( fname );

    event->command_line = strdup( cmd.c_str() );

    jack_session_reply( client, event );

    jack_session_event_free( event );

    return 0;
}

void gx_jack_session_callback(jack_session_event_t *event, void *arg)
{
    gtk_idle_add(gx_jack_session_callback_helper, (void *)event); 
}
#endif

} /* end of gx_jack namespace */

