declare id "alembic";
declare name "Alembic Preamp";
declare category "External";

import("stdfaust.lib");

process = pre : fi.iir((b0/a0,b1/a0,b2/a0,b3/a0,b4/a0,b5/a0),(a1/a0,a2/a0,a3/a0,a4/a0,a5/a0)):*(0.05) with {
    LogPot(a, x) = ba.if(a, (exp(a * x) - 1) / (exp(a) - 1), x);
    Inverted(b, x) = ba.if(b, 1 - x, x);
    s = 0.993;
    fs = float(ma.SR);
    pre = _;

	Input = vslider("Input[name:Input]", 0.5, 0, 1, 0.01) : Inverted(0) : LogPot(1) : si.smooth(s);
	Bass = vslider("Bass[name:Bass]", 0.5, 0, 1, 0.01) : Inverted(0) : LogPot(1) : si.smooth(s);
	Middle = vslider("Middle[name:Middle]", 0.5, 0, 1, 0.01) : Inverted(0) : si.smooth(s);       
	Treble = vslider("Treble[name:Treble]", 0.5, 0, 1, 0.01) : Inverted(1) : si.smooth(s);
	Volume = vslider("Volume[name:Volume]", 0.5, 0, 1, 0.01) : Inverted(0) : LogPot(1) : si.smooth(s);
            
    b0 = Volume*(Bass*(Input*Treble*pow(fs,4)*(-5.68615530428513e-21*fs - 3.79077020285676e-20) + Input*pow(fs,2)*(fs*(fs*(5.68615530428513e-21*fs + 9.98505002369502e-19) + 4.85778329480724e-15) + 3.23425287520332e-14)) + Input*Treble*pow(fs,2)*(fs*(-3.55687161587197e-19*fs - 1.44694505189894e-17) - 8.06546851671652e-17) + Input*pow(fs,2)*(fs*(3.55687161587197e-19*fs + 1.44694505189894e-17) + 8.06546851671652e-17) + Middle*(Bass*Input*pow(fs,3)*(fs*(7.96061742599918e-22*fs + 4.56560363232067e-18) + 3.04019770269112e-17) + Input*pow(fs,2)*(fs*(4.97962026222076e-20*fs + 2.85365632064909e-16) + 1.90022438253841e-15)));

    b1 = Volume*(Bass*(Input*Treble*pow(fs,4)*(2.84307765214256e-20*fs + 1.13723106085703e-19) + Input*pow(fs,2)*(fs*(fs*(-2.84307765214256e-20*fs - 2.99551500710851e-18) - 4.85778329480724e-15) + 3.23425287520332e-14)) + Input*Treble*pow(fs,2)*(fs*(1.06706148476159e-18*fs + 1.44694505189894e-17) - 8.06546851671652e-17) + Input*pow(fs,2)*(fs*(-1.06706148476159e-18*fs - 1.44694505189894e-17) + 8.06546851671652e-17) + Middle*(Bass*Input*pow(fs,3)*(fs*(-3.98030871299959e-21*fs - 1.3696810896962e-17) - 3.04019770269112e-17) + Input*pow(fs,2)*(fs*(-1.49388607866623e-19*fs - 2.85365632064909e-16) + 1.90022438253841e-15)));

    b2 = Volume*(Bass*(Input*Treble*pow(fs,4)*(-5.68615530428513e-20*fs - 7.58154040571353e-20) + Input*pow(fs,2)*(fs*(fs*(5.68615530428513e-20*fs + 1.997010004739e-18) - 9.71556658961449e-15) - 6.46850575040665e-14)) + Input*Treble*pow(fs,2)*(fs*(-7.11374323174395e-19*fs + 2.89389010379788e-17) + 1.6130937033433e-16) + Input*pow(fs,2)*(fs*(7.11374323174395e-19*fs - 2.89389010379788e-17) - 1.6130937033433e-16) + Middle*(Bass*Input*pow(fs,3)*(fs*(7.96061742599918e-21*fs + 9.13120726464134e-18) - 6.08039540538225e-17) + Input*pow(fs,2)*(fs*(9.95924052444153e-20*fs - 5.70731264129818e-16) - 3.80044876507682e-15)));

    b3 = Volume*(Bass*(Input*Treble*pow(fs,4)*(5.68615530428513e-20*fs - 7.58154040571353e-20) + Input*pow(fs,2)*(fs*(fs*(-5.68615530428513e-20*fs + 1.997010004739e-18) + 9.71556658961449e-15) - 6.46850575040665e-14)) + Input*Treble*pow(fs,2)*(fs*(-7.11374323174395e-19*fs - 2.89389010379788e-17) + 1.6130937033433e-16) + Input*pow(fs,2)*(fs*(7.11374323174395e-19*fs + 2.89389010379788e-17) - 1.6130937033433e-16) + Middle*(Bass*Input*pow(fs,3)*(fs*(-7.96061742599918e-21*fs + 9.13120726464134e-18) + 6.08039540538225e-17) + Input*pow(fs,2)*(fs*(9.95924052444153e-20*fs + 5.70731264129818e-16) - 3.80044876507682e-15)));

    b4 = Volume*(Bass*(Input*Treble*pow(fs,4)*(-2.84307765214256e-20*fs + 1.13723106085703e-19) + Input*pow(fs,2)*(fs*(fs*(2.84307765214256e-20*fs - 2.99551500710851e-18) + 4.85778329480724e-15) + 3.23425287520332e-14)) + Input*Treble*pow(fs,2)*(fs*(1.06706148476159e-18*fs - 1.44694505189894e-17) - 8.06546851671652e-17) + Input*pow(fs,2)*(fs*(-1.06706148476159e-18*fs + 1.44694505189894e-17) + 8.06546851671652e-17) + Middle*(Bass*Input*pow(fs,3)*(fs*(3.98030871299959e-21*fs - 1.3696810896962e-17) + 3.04019770269112e-17) + Input*pow(fs,2)*(fs*(-1.49388607866623e-19*fs + 2.85365632064909e-16) + 1.90022438253841e-15)));

    b5 = Volume*(Bass*(Input*Treble*pow(fs,4)*(5.68615530428513e-21*fs - 3.79077020285676e-20) + Input*pow(fs,2)*(fs*(fs*(-5.68615530428513e-21*fs + 9.98505002369502e-19) - 4.85778329480724e-15) + 3.23425287520332e-14)) + Input*Treble*pow(fs,2)*(fs*(-3.55687161587197e-19*fs + 1.44694505189894e-17) - 8.06546851671652e-17) + Input*pow(fs,2)*(fs*(3.55687161587197e-19*fs - 1.44694505189894e-17) + 8.06546851671652e-17) + Middle*(Bass*Input*pow(fs,3)*(fs*(-7.96061742599918e-22*fs + 4.56560363232067e-18) - 3.04019770269112e-17) + Input*pow(fs,2)*(fs*(4.97962026222076e-20*fs - 2.85365632064909e-16) + 1.90022438253841e-15)));

    a0 = Bass*(Input*(Input*(fs*(fs*(fs*(fs*(-4.66400408138021e-24*fs - 4.21107717183568e-20) - 4.69643971510767e-18) - 8.52210149990995e-17) - 4.70934759609501e-16) - 7.98191761744856e-16) + fs*(fs*(fs*(fs*(4.66400408138021e-24*fs + 4.21107717183568e-20) + 4.69643971510767e-18) + 8.52210149990995e-17) + 4.70934759609501e-16) + 7.98191761744856e-16) + Treble*(Input*(Input*fs*(fs*(fs*(fs*(-9.32295933998211e-25*fs + 8.13465102081422e-21) + 8.27894207186978e-19) + 1.21893473917967e-17) + 3.98098141170247e-17) + fs*(fs*(fs*(fs*(9.32295933998211e-25*fs - 8.13465102081422e-21) - 8.27894207186978e-19) - 1.21893473917967e-17) - 3.98098141170247e-17)) + Treble*(Input*(Input*pow(fs,2)*(fs*(fs*(1.03616486126347e-24*fs + 1.0400884417695e-22) + 1.52836235209424e-21) + 4.98869851090535e-21) + pow(fs,2)*(fs*(fs*(-1.03616486126347e-24*fs - 1.0400884417695e-22) - 1.52836235209424e-21) - 4.98869851090535e-21)) + pow(fs,2)*(fs*(fs*(-1.10662407182939e-24*fs - 1.11081445580983e-22) - 1.63229099203665e-21) - 5.32793000964692e-21)) + fs*(fs*(fs*(fs*(9.95692057510089e-25*fs - 8.68780729022958e-21) - 8.84191013275692e-19) - 1.30182230144389e-17) - 4.25168814769824e-17)) + fs*(fs*(fs*(fs*(4.98115635891407e-24*fs + 4.49743041952051e-20) + 5.01579761573499e-18) + 9.10160440190383e-17) + 5.02958323262947e-16) + 8.52468801543507e-16) + Input*(Input*(fs*(fs*(fs*(-2.91748340409741e-22*fs - 2.60665717245934e-18) - 1.19810519513002e-16) - 1.35533771234294e-15) - 3.99095880872428e-15) + fs*(fs*(fs*(2.91748340409741e-22*fs + 2.60665717245934e-18) + 1.19810519513002e-16) + 1.35533771234294e-15) + 3.99095880872428e-15) + Middle*(Bass*(Input*(Input*fs*(fs*(fs*(fs*(-4.49377473953314e-25*fs - 3.45203422865533e-21) - 7.39641502461285e-20) - 4.31004728634658e-19) - 7.50300256040165e-19) + fs*(fs*(fs*(fs*(4.49377473953314e-25*fs + 3.45203422865533e-21) + 7.39641502461285e-20) + 4.31004728634658e-19) + 7.50300256040165e-19)) + Treble*(Input*(Input*pow(fs,2)*(fs*(fs*(-1.08708956034044e-25*fs + 6.17731871560931e-22) + 1.08757485215501e-20) + 3.74212252700032e-20) + pow(fs,2)*(fs*(fs*(1.08708956034044e-25*fs - 6.17731871560931e-22) - 1.08757485215501e-20) - 3.74212252700032e-20)) + Treble*(Input*(Input*pow(fs,3)*(fs*(7.76492543100316e-26*fs + 1.36369845222938e-24) + 4.68937660025103e-24) + pow(fs,3)*(fs*(-7.76492543100316e-26*fs - 1.36369845222938e-24) - 4.68937660025103e-24)) + pow(fs,3)*(fs*(-8.29294036031137e-26*fs - 1.45642994698098e-24) - 5.0082542090681e-24)) + pow(fs,2)*(fs*(fs*(1.16101165044359e-25*fs - 6.59737638827074e-22) - 1.16152994210155e-20) - 3.99658685883635e-20)) + fs*(fs*(fs*(fs*(4.79935142182139e-25*fs + 3.68677255620389e-21) + 7.89937124628652e-20) + 4.60313050181815e-19) + 8.01320673450896e-19)) + Input*(Input*(fs*(fs*(fs*(-2.81099951792073e-23*fs - 2.15807364568921e-19) - 4.37590986205892e-18) - 2.25888916645809e-17) - 3.19276704697943e-17) + fs*(fs*(fs*(2.81099951792073e-23*fs + 2.15807364568921e-19) + 4.37590986205892e-18) + 2.25888916645809e-17) + 3.19276704697943e-17) + Treble*(Input*(Input*fs*(fs*(fs*(-6.80009214340617e-24*fs + 3.86721597525567e-20) + 6.80858259239558e-19) + 2.34269282072115e-18) + fs*(fs*(fs*(6.80009214340617e-24*fs - 3.86721597525567e-20) - 6.80858259239558e-19) - 2.34269282072115e-18)) + Treble*(Input*(Input*pow(fs,2)*(fs*(4.85720867386155e-24*fs + 8.53036904160507e-23) + 2.93335472441235e-22) + pow(fs,2)*(fs*(-4.85720867386155e-24*fs - 8.53036904160507e-23) - 2.93335472441235e-22)) + pow(fs,2)*(fs*(-5.18749886368413e-24*fs - 9.11043413643421e-23) - 3.13282284567239e-22)) + fs*(fs*(fs*(7.26249840915779e-24*fs - 4.13018666157306e-20) - 7.27156620867848e-19) - 2.50199593253019e-18)) + fs*(fs*(fs*(3.00214748513934e-23*fs + 2.30482265359608e-19) + 4.67347173267892e-18) + 2.41249362977723e-17) + 3.40987520617403e-17) + Treble*(Input*(Input*(fs*(fs*(fs*(-5.83180860841434e-23*fs + 5.15947717885593e-19) + 2.3901137548476e-17) + 2.70887949322196e-16) + 7.98191761744856e-16) + fs*(fs*(fs*(5.83180860841434e-23*fs - 5.15947717885593e-19) - 2.3901137548476e-17) - 2.70887949322196e-16) - 7.98191761744856e-16) + Treble*(Input*(Input*fs*(fs*(fs*(6.4815418981162e-23*fs + 2.99095367015295e-21) + 3.38701967358278e-20) + 9.9773970218107e-20) + fs*(fs*(fs*(-6.4815418981162e-23*fs - 2.99095367015295e-21) - 3.38701967358278e-20) - 9.9773970218107e-20)) + fs*(fs*(fs*(-6.9222867471881e-23*fs - 3.19433851972335e-21) - 3.61733701138641e-20) - 1.06558600192938e-19)) + fs*(fs*(fs*(6.22837159378651e-23*fs - 5.51032162701814e-19) - 2.55264149017724e-17) - 2.89308329876105e-16) - 8.52468801543507e-16) + fs*(fs*(fs*(3.11587227557603e-22*fs + 2.78390986018658e-18) + 1.27957634839887e-16) + 1.44750067678226e-15) + 4.26234400771753e-15;

    a1 = Bass*(Input*(Input*(fs*(fs*(fs*(fs*(2.33200204069011e-23*fs + 1.26332315155071e-19) + 4.69643971510767e-18) - 8.52210149990995e-17) - 1.4128042788285e-15) - 3.99095880872428e-15) + fs*(fs*(fs*(fs*(-2.33200204069011e-23*fs - 1.26332315155071e-19) - 4.69643971510767e-18) + 8.52210149990995e-17) + 1.4128042788285e-15) + 3.99095880872428e-15) + Treble*(Input*(Input*fs*(fs*(fs*(fs*(4.66147966999105e-24*fs - 2.44039530624426e-20) - 8.27894207186978e-19) + 1.21893473917967e-17) + 1.19429442351074e-16) + fs*(fs*(fs*(fs*(-4.66147966999105e-24*fs + 2.44039530624426e-20) + 8.27894207186978e-19) - 1.21893473917967e-17) - 1.19429442351074e-16)) + Treble*(Input*(Input*pow(fs,2)*(fs*(fs*(-5.18082430631737e-24*fs - 3.12026532530851e-22) - 1.52836235209424e-21) + 4.98869851090535e-21) + pow(fs,2)*(fs*(fs*(5.18082430631737e-24*fs + 3.12026532530851e-22) + 1.52836235209424e-21) - 4.98869851090535e-21)) + pow(fs,2)*(fs*(fs*(5.53312035914695e-24*fs + 3.33244336742949e-22) + 1.63229099203665e-21) - 5.32793000964692e-21)) + fs*(fs*(fs*(fs*(-4.97846028755044e-24*fs + 2.60634218706887e-20) + 8.84191013275692e-19) - 1.30182230144389e-17) - 1.27550644430947e-16)) + fs*(fs*(fs*(fs*(-2.49057817945703e-23*fs - 1.34922912585615e-19) - 5.01579761573499e-18) + 9.10160440190383e-17) + 1.50887496978884e-15) + 4.26234400771753e-15) + Input*(Input*(fs*(fs*(fs*(8.75245021229223e-22*fs + 2.60665717245934e-18) - 1.19810519513002e-16) - 4.06601313702883e-15) - 1.99547940436214e-14) + fs*(fs*(fs*(-8.75245021229223e-22*fs - 2.60665717245934e-18) + 1.19810519513002e-16) + 4.06601313702883e-15) + 1.99547940436214e-14) + Middle*(Bass*(Input*(Input*fs*(fs*(fs*(fs*(2.24688736976657e-24*fs + 1.0356102685966e-20) + 7.39641502461285e-20) - 4.31004728634658e-19) - 2.2509007681205e-18) + fs*(fs*(fs*(fs*(-2.24688736976657e-24*fs - 1.0356102685966e-20) - 7.39641502461285e-20) + 4.31004728634658e-19) + 2.2509007681205e-18)) + Treble*(Input*(Input*pow(fs,2)*(fs*(fs*(5.43544780170221e-25*fs - 1.85319561468279e-21) - 1.08757485215501e-20) + 3.74212252700032e-20) + pow(fs,2)*(fs*(fs*(-5.43544780170221e-25*fs + 1.85319561468279e-21) + 1.08757485215501e-20) - 3.74212252700032e-20)) + Treble*(Input*(Input*pow(fs,3)*(fs*(-3.88246271550158e-25*fs - 4.09109535668814e-24) - 4.68937660025103e-24) + pow(fs,3)*(fs*(3.88246271550158e-25*fs + 4.09109535668814e-24) + 4.68937660025103e-24)) + pow(fs,3)*(fs*(4.14647018015568e-25*fs + 4.36928984094294e-24) + 5.0082542090681e-24)) + pow(fs,2)*(fs*(fs*(-5.80505825221796e-25*fs + 1.97921291648122e-21) + 1.16152994210155e-20) - 3.99658685883635e-20)) + fs*(fs*(fs*(fs*(-2.39967571091069e-24*fs - 1.10603176686117e-20) - 7.89937124628652e-20) + 4.60313050181815e-19) + 2.40396202035269e-18)) + Input*(Input*(fs*(fs*(fs*(8.43299855376218e-23*fs + 2.15807364568921e-19) - 4.37590986205892e-18) - 6.77666749937426e-17) - 1.59638352348971e-16) + fs*(fs*(fs*(-8.43299855376218e-23*fs - 2.15807364568921e-19) + 4.37590986205892e-18) + 6.77666749937426e-17) + 1.59638352348971e-16) + Treble*(Input*(Input*fs*(fs*(fs*(2.04002764302185e-23*fs - 3.86721597525567e-20) + 6.80858259239558e-19) + 7.02807846216346e-18) + fs*(fs*(fs*(-2.04002764302185e-23*fs + 3.86721597525567e-20) - 6.80858259239558e-19) - 7.02807846216346e-18)) + Treble*(Input*(Input*pow(fs,2)*(fs*(-1.45716260215846e-23*fs - 8.53036904160507e-23) + 2.93335472441235e-22) + pow(fs,2)*(fs*(1.45716260215846e-23*fs + 8.53036904160507e-23) - 2.93335472441235e-22)) + pow(fs,2)*(fs*(1.55624965910524e-23*fs + 9.11043413643421e-23) - 3.13282284567239e-22)) + fs*(fs*(fs*(-2.17874952274734e-23*fs + 4.13018666157306e-20) - 7.27156620867848e-19) - 7.50598779759058e-18)) + fs*(fs*(fs*(-9.00644245541801e-23*fs - 2.30482265359608e-19) + 4.67347173267892e-18) + 7.2374808893317e-17) + 1.70493760308701e-16) + Treble*(Input*(Input*(fs*(fs*(fs*(1.7495425825243e-22*fs - 5.15947717885593e-19) + 2.3901137548476e-17) + 8.12663847966588e-16) + 3.99095880872428e-15) + fs*(fs*(fs*(-1.7495425825243e-22*fs + 5.15947717885593e-19) - 2.3901137548476e-17) - 8.12663847966588e-16) - 3.99095880872428e-15) + Treble*(Input*(Input*fs*(fs*(fs*(-1.94446256943486e-22*fs - 2.99095367015295e-21) + 3.38701967358278e-20) + 2.99321910654321e-19) + fs*(fs*(fs*(1.94446256943486e-22*fs + 2.99095367015295e-21) - 3.38701967358278e-20) - 2.99321910654321e-19)) + fs*(fs*(fs*(2.07668602415643e-22*fs + 3.19433851972335e-21) - 3.61733701138641e-20) - 3.19675800578815e-19)) + fs*(fs*(fs*(-1.86851147813595e-22*fs + 5.51032162701814e-19) - 2.55264149017724e-17) - 8.67924989628316e-16) - 4.26234400771753e-15) + fs*(fs*(fs*(-9.3476168267281e-22*fs - 2.78390986018658e-18) + 1.27957634839887e-16) + 4.34250203034679e-15) + 2.13117200385877e-14;

    a2 = Bass*(Input*(Input*(fs*(fs*(fs*(fs*(-4.66400408138021e-23*fs - 8.42215434367137e-20) + 9.39287943021533e-18) + 1.70442029998199e-16) - 9.41869519219001e-16) - 7.98191761744856e-15) + fs*(fs*(fs*(fs*(4.66400408138021e-23*fs + 8.42215434367137e-20) - 9.39287943021533e-18) - 1.70442029998199e-16) + 9.41869519219001e-16) + 7.98191761744856e-15) + Treble*(Input*(Input*fs*(fs*(fs*(fs*(-9.32295933998211e-24*fs + 1.62693020416284e-20) - 1.65578841437396e-18) - 2.43786947835935e-17) + 7.96196282340494e-17) + fs*(fs*(fs*(fs*(9.32295933998211e-24*fs - 1.62693020416284e-20) + 1.65578841437396e-18) + 2.43786947835935e-17) - 7.96196282340494e-17)) + Treble*(Input*(Input*pow(fs,2)*(fs*(fs*(1.03616486126347e-23*fs + 2.08017688353901e-22) - 3.05672470418848e-21) - 9.97739702181071e-21) + pow(fs,2)*(fs*(fs*(-1.03616486126347e-23*fs - 2.08017688353901e-22) + 3.05672470418848e-21) + 9.97739702181071e-21)) + pow(fs,2)*(fs*(fs*(-1.10662407182939e-23*fs - 2.22162891161966e-22) + 3.26458198407329e-21) + 1.06558600192938e-20)) + fs*(fs*(fs*(fs*(9.95692057510089e-24*fs - 1.73756145804592e-20) + 1.76838202655138e-18) + 2.60364460288779e-17) - 8.50337629539648e-17)) + fs*(fs*(fs*(fs*(4.98115635891407e-23*fs + 8.99486083904102e-20) - 1.003159523147e-17) - 1.82032088038077e-16) + 1.00591664652589e-15) + 8.52468801543507e-15) + Input*(Input*(fs*(fs*(fs*(-5.83496680819482e-22*fs + 5.21331434491869e-18) + 2.39621039026005e-16) - 2.71067542468589e-15) - 3.99095880872428e-14) + fs*(fs*(fs*(5.83496680819482e-22*fs - 5.21331434491869e-18) - 2.39621039026005e-16) + 2.71067542468589e-15) + 3.99095880872428e-14) + Middle*(Bass*(Input*(Input*fs*(fs*(fs*(fs*(-4.49377473953314e-24*fs - 6.90406845731066e-21) + 1.47928300492257e-19) + 8.62009457269317e-19) - 1.50060051208033e-18) + fs*(fs*(fs*(fs*(4.49377473953314e-24*fs + 6.90406845731066e-21) - 1.47928300492257e-19) - 8.62009457269317e-19) + 1.50060051208033e-18)) + Treble*(Input*(Input*pow(fs,2)*(fs*(fs*(-1.08708956034044e-24*fs + 1.23546374312186e-21) - 2.17514970431002e-20) - 7.48424505400065e-20) + pow(fs,2)*(fs*(fs*(1.08708956034044e-24*fs - 1.23546374312186e-21) + 2.17514970431002e-20) + 7.48424505400065e-20)) + Treble*(Input*(Input*pow(fs,3)*(fs*(7.76492543100316e-25*fs + 2.72739690445876e-24) - 9.37875320050206e-24) + pow(fs,3)*(fs*(-7.76492543100316e-25*fs - 2.72739690445876e-24) + 9.37875320050206e-24)) + pow(fs,3)*(fs*(-8.29294036031137e-25*fs - 2.91285989396196e-24) + 1.00165084181362e-23)) + pow(fs,2)*(fs*(fs*(1.16101165044359e-24*fs - 1.31947527765415e-21) + 2.3230598842031e-20) + 7.99317371767269e-20)) + fs*(fs*(fs*(fs*(4.79935142182139e-24*fs + 7.37354511240778e-21) - 1.5798742492573e-19) - 9.2062610036363e-19) + 1.60264134690179e-18)) + Input*(Input*(fs*(fs*(fs*(-5.62199903584146e-23*fs + 4.31614729137842e-19) + 8.75181972411783e-18) - 4.51777833291617e-17) - 3.19276704697943e-16) + fs*(fs*(fs*(5.62199903584146e-23*fs - 4.31614729137842e-19) - 8.75181972411783e-18) + 4.51777833291617e-17) + 3.19276704697943e-16) + Treble*(Input*(Input*fs*(fs*(fs*(-1.36001842868123e-23*fs - 7.73443195051134e-20) - 1.36171651847912e-18) + 4.68538564144231e-18) + fs*(fs*(fs*(1.36001842868123e-23*fs + 7.73443195051134e-20) + 1.36171651847912e-18) - 4.68538564144231e-18)) + Treble*(Input*(Input*pow(fs,2)*(fs*(9.7144173477231e-24*fs - 1.70607380832101e-22) - 5.86670944882469e-22) + pow(fs,2)*(fs*(-9.7144173477231e-24*fs + 1.70607380832101e-22) + 5.86670944882469e-22)) + pow(fs,2)*(fs*(-1.03749977273683e-23*fs + 1.82208682728684e-22) + 6.26564569134477e-22)) + fs*(fs*(fs*(1.45249968183156e-23*fs + 8.26037332314611e-20) + 1.4543132417357e-18) - 5.00399186506038e-18)) + fs*(fs*(fs*(6.00429497027867e-23*fs - 4.60964530719215e-19) - 9.34694346535784e-18) + 4.82498725955447e-17) + 3.40987520617403e-16) + Treble*(Input*(Input*(fs*(fs*(fs*(-1.16636172168287e-22*fs - 1.03189543577119e-18) - 4.7802275096952e-17) + 5.41775898644392e-16) + 7.98191761744856e-15) + fs*(fs*(fs*(1.16636172168287e-22*fs + 1.03189543577119e-18) + 4.7802275096952e-17) - 5.41775898644392e-16) - 7.98191761744856e-15) + Treble*(Input*(Input*fs*(fs*(fs*(1.29630837962324e-22*fs - 5.98190734030589e-21) - 6.77403934716556e-20) + 1.99547940436214e-19) + fs*(fs*(fs*(-1.29630837962324e-22*fs + 5.98190734030589e-21) + 6.77403934716556e-20) - 1.99547940436214e-19)) + fs*(fs*(fs*(-1.38445734943762e-22*fs + 6.38867703944669e-21) + 7.23467402277282e-20) - 2.13117200385877e-19)) + fs*(fs*(fs*(1.2456743187573e-22*fs + 1.10206432540363e-18) + 5.10528298035447e-17) - 5.78616659752211e-16) - 8.52468801543507e-15) + fs*(fs*(fs*(6.23174455115207e-22*fs - 5.56781972037316e-18) - 2.55915269679773e-16) + 2.89500135356453e-15) + 4.26234400771753e-14;

    a3 = Bass*(Input*(Input*(fs*(fs*(fs*(fs*(4.66400408138021e-23*fs - 8.42215434367137e-20) - 9.39287943021533e-18) + 1.70442029998199e-16) + 9.41869519219001e-16) - 7.98191761744856e-15) + fs*(fs*(fs*(fs*(-4.66400408138021e-23*fs + 8.42215434367137e-20) + 9.39287943021533e-18) - 1.70442029998199e-16) - 9.41869519219001e-16) + 7.98191761744856e-15) + Treble*(Input*(Input*fs*(fs*(fs*(fs*(9.32295933998211e-24*fs + 1.62693020416284e-20) + 1.65578841437396e-18) - 2.43786947835935e-17) - 7.96196282340494e-17) + fs*(fs*(fs*(fs*(-9.32295933998211e-24*fs - 1.62693020416284e-20) - 1.65578841437396e-18) + 2.43786947835935e-17) + 7.96196282340494e-17)) + Treble*(Input*(Input*pow(fs,2)*(fs*(fs*(-1.03616486126347e-23*fs + 2.08017688353901e-22) + 3.05672470418848e-21) - 9.97739702181071e-21) + pow(fs,2)*(fs*(fs*(1.03616486126347e-23*fs - 2.08017688353901e-22) - 3.05672470418848e-21) + 9.97739702181071e-21)) + pow(fs,2)*(fs*(fs*(1.10662407182939e-23*fs - 2.22162891161966e-22) - 3.26458198407329e-21) + 1.06558600192938e-20)) + fs*(fs*(fs*(fs*(-9.95692057510089e-24*fs - 1.73756145804592e-20) - 1.76838202655138e-18) + 2.60364460288779e-17) + 8.50337629539648e-17)) + fs*(fs*(fs*(fs*(-4.98115635891407e-23*fs + 8.99486083904102e-20) + 1.003159523147e-17) - 1.82032088038077e-16) - 1.00591664652589e-15) + 8.52468801543507e-15) + Input*(Input*(fs*(fs*(fs*(-5.83496680819482e-22*fs - 5.21331434491869e-18) + 2.39621039026005e-16) + 2.71067542468589e-15) - 3.99095880872428e-14) + fs*(fs*(fs*(5.83496680819482e-22*fs + 5.21331434491869e-18) - 2.39621039026005e-16) - 2.71067542468589e-15) + 3.99095880872428e-14) + Middle*(Bass*(Input*(Input*fs*(fs*(fs*(fs*(4.49377473953314e-24*fs - 6.90406845731066e-21) - 1.47928300492257e-19) + 8.62009457269317e-19) + 1.50060051208033e-18) + fs*(fs*(fs*(fs*(-4.49377473953314e-24*fs + 6.90406845731066e-21) + 1.47928300492257e-19) - 8.62009457269317e-19) - 1.50060051208033e-18)) + Treble*(Input*(Input*pow(fs,2)*(fs*(fs*(1.08708956034044e-24*fs + 1.23546374312186e-21) + 2.17514970431002e-20) - 7.48424505400065e-20) + pow(fs,2)*(fs*(fs*(-1.08708956034044e-24*fs - 1.23546374312186e-21) - 2.17514970431002e-20) + 7.48424505400065e-20)) + Treble*(Input*(Input*pow(fs,3)*(fs*(-7.76492543100316e-25*fs + 2.72739690445876e-24) + 9.37875320050206e-24) + pow(fs,3)*(fs*(7.76492543100316e-25*fs - 2.72739690445876e-24) - 9.37875320050206e-24)) + pow(fs,3)*(fs*(8.29294036031137e-25*fs - 2.91285989396196e-24) - 1.00165084181362e-23)) + pow(fs,2)*(fs*(fs*(-1.16101165044359e-24*fs - 1.31947527765415e-21) - 2.3230598842031e-20) + 7.99317371767269e-20)) + fs*(fs*(fs*(fs*(-4.79935142182139e-24*fs + 7.37354511240778e-21) + 1.5798742492573e-19) - 9.2062610036363e-19) - 1.60264134690179e-18)) + Input*(Input*(fs*(fs*(fs*(-5.62199903584146e-23*fs - 4.31614729137842e-19) + 8.75181972411783e-18) + 4.51777833291617e-17) - 3.19276704697943e-16) + fs*(fs*(fs*(5.62199903584146e-23*fs + 4.31614729137842e-19) - 8.75181972411783e-18) - 4.51777833291617e-17) + 3.19276704697943e-16) + Treble*(Input*(Input*fs*(fs*(fs*(-1.36001842868123e-23*fs + 7.73443195051134e-20) - 1.36171651847912e-18) - 4.68538564144231e-18) + fs*(fs*(fs*(1.36001842868123e-23*fs - 7.73443195051134e-20) + 1.36171651847912e-18) + 4.68538564144231e-18)) + Treble*(Input*(Input*pow(fs,2)*(fs*(9.7144173477231e-24*fs + 1.70607380832101e-22) - 5.86670944882469e-22) + pow(fs,2)*(fs*(-9.7144173477231e-24*fs - 1.70607380832101e-22) + 5.86670944882469e-22)) + pow(fs,2)*(fs*(-1.03749977273683e-23*fs - 1.82208682728684e-22) + 6.26564569134477e-22)) + fs*(fs*(fs*(1.45249968183156e-23*fs - 8.26037332314611e-20) + 1.4543132417357e-18) + 5.00399186506038e-18)) + fs*(fs*(fs*(6.00429497027867e-23*fs + 4.60964530719215e-19) - 9.34694346535784e-18) - 4.82498725955447e-17) + 3.40987520617403e-16) + Treble*(Input*(Input*(fs*(fs*(fs*(-1.16636172168287e-22*fs + 1.03189543577119e-18) - 4.7802275096952e-17) - 5.41775898644392e-16) + 7.98191761744856e-15) + fs*(fs*(fs*(1.16636172168287e-22*fs - 1.03189543577119e-18) + 4.7802275096952e-17) + 5.41775898644392e-16) - 7.98191761744856e-15) + Treble*(Input*(Input*fs*(fs*(fs*(1.29630837962324e-22*fs + 5.98190734030589e-21) - 6.77403934716556e-20) - 1.99547940436214e-19) + fs*(fs*(fs*(-1.29630837962324e-22*fs - 5.98190734030589e-21) + 6.77403934716556e-20) + 1.99547940436214e-19)) + fs*(fs*(fs*(-1.38445734943762e-22*fs - 6.38867703944669e-21) + 7.23467402277282e-20) + 2.13117200385877e-19)) + fs*(fs*(fs*(1.2456743187573e-22*fs - 1.10206432540363e-18) + 5.10528298035447e-17) + 5.78616659752211e-16) - 8.52468801543507e-15) + fs*(fs*(fs*(6.23174455115207e-22*fs + 5.56781972037316e-18) - 2.55915269679773e-16) - 2.89500135356453e-15) + 4.26234400771753e-14;

    a4 = Bass*(Input*(Input*(fs*(fs*(fs*(fs*(-2.33200204069011e-23*fs + 1.26332315155071e-19) - 4.69643971510767e-18) - 8.52210149990995e-17) + 1.4128042788285e-15) - 3.99095880872428e-15) + fs*(fs*(fs*(fs*(2.33200204069011e-23*fs - 1.26332315155071e-19) + 4.69643971510767e-18) + 8.52210149990995e-17) - 1.4128042788285e-15) + 3.99095880872428e-15) + Treble*(Input*(Input*fs*(fs*(fs*(fs*(-4.66147966999105e-24*fs - 2.44039530624426e-20) + 8.27894207186978e-19) + 1.21893473917967e-17) - 1.19429442351074e-16) + fs*(fs*(fs*(fs*(4.66147966999105e-24*fs + 2.44039530624426e-20) - 8.27894207186978e-19) - 1.21893473917967e-17) + 1.19429442351074e-16)) + Treble*(Input*(Input*pow(fs,2)*(fs*(fs*(5.18082430631737e-24*fs - 3.12026532530851e-22) + 1.52836235209424e-21) + 4.98869851090535e-21) + pow(fs,2)*(fs*(fs*(-5.18082430631737e-24*fs + 3.12026532530851e-22) - 1.52836235209424e-21) - 4.98869851090535e-21)) + pow(fs,2)*(fs*(fs*(-5.53312035914695e-24*fs + 3.33244336742949e-22) - 1.63229099203665e-21) - 5.32793000964692e-21)) + fs*(fs*(fs*(fs*(4.97846028755044e-24*fs + 2.60634218706887e-20) - 8.84191013275692e-19) - 1.30182230144389e-17) + 1.27550644430947e-16)) + fs*(fs*(fs*(fs*(2.49057817945703e-23*fs - 1.34922912585615e-19) + 5.01579761573499e-18) + 9.10160440190383e-17) - 1.50887496978884e-15) + 4.26234400771753e-15) + Input*(Input*(fs*(fs*(fs*(8.75245021229223e-22*fs - 2.60665717245934e-18) - 1.19810519513002e-16) + 4.06601313702883e-15) - 1.99547940436214e-14) + fs*(fs*(fs*(-8.75245021229223e-22*fs + 2.60665717245934e-18) + 1.19810519513002e-16) - 4.06601313702883e-15) + 1.99547940436214e-14) + Middle*(Bass*(Input*(Input*fs*(fs*(fs*(fs*(-2.24688736976657e-24*fs + 1.0356102685966e-20) - 7.39641502461285e-20) - 4.31004728634658e-19) + 2.2509007681205e-18) + fs*(fs*(fs*(fs*(2.24688736976657e-24*fs - 1.0356102685966e-20) + 7.39641502461285e-20) + 4.31004728634658e-19) - 2.2509007681205e-18)) + Treble*(Input*(Input*pow(fs,2)*(fs*(fs*(-5.43544780170221e-25*fs - 1.85319561468279e-21) + 1.08757485215501e-20) + 3.74212252700032e-20) + pow(fs,2)*(fs*(fs*(5.43544780170221e-25*fs + 1.85319561468279e-21) - 1.08757485215501e-20) - 3.74212252700032e-20)) + Treble*(Input*(Input*pow(fs,3)*(fs*(3.88246271550158e-25*fs - 4.09109535668814e-24) + 4.68937660025103e-24) + pow(fs,3)*(fs*(-3.88246271550158e-25*fs + 4.09109535668814e-24) - 4.68937660025103e-24)) + pow(fs,3)*(fs*(-4.14647018015568e-25*fs + 4.36928984094294e-24) - 5.0082542090681e-24)) + pow(fs,2)*(fs*(fs*(5.80505825221796e-25*fs + 1.97921291648122e-21) - 1.16152994210155e-20) - 3.99658685883635e-20)) + fs*(fs*(fs*(fs*(2.39967571091069e-24*fs - 1.10603176686117e-20) + 7.89937124628652e-20) + 4.60313050181815e-19) - 2.40396202035269e-18)) + Input*(Input*(fs*(fs*(fs*(8.43299855376218e-23*fs - 2.15807364568921e-19) - 4.37590986205892e-18) + 6.77666749937426e-17) - 1.59638352348971e-16) + fs*(fs*(fs*(-8.43299855376218e-23*fs + 2.15807364568921e-19) + 4.37590986205892e-18) - 6.77666749937426e-17) + 1.59638352348971e-16) + Treble*(Input*(Input*fs*(fs*(fs*(2.04002764302185e-23*fs + 3.86721597525567e-20) + 6.80858259239558e-19) - 7.02807846216346e-18) + fs*(fs*(fs*(-2.04002764302185e-23*fs - 3.86721597525567e-20) - 6.80858259239558e-19) + 7.02807846216346e-18)) + Treble*(Input*(Input*pow(fs,2)*(fs*(-1.45716260215846e-23*fs + 8.53036904160507e-23) + 2.93335472441235e-22) + pow(fs,2)*(fs*(1.45716260215846e-23*fs - 8.53036904160507e-23) - 2.93335472441235e-22)) + pow(fs,2)*(fs*(1.55624965910524e-23*fs - 9.11043413643421e-23) - 3.13282284567239e-22)) + fs*(fs*(fs*(-2.17874952274734e-23*fs - 4.13018666157306e-20) - 7.27156620867848e-19) + 7.50598779759058e-18)) + fs*(fs*(fs*(-9.00644245541801e-23*fs + 2.30482265359608e-19) + 4.67347173267892e-18) - 7.2374808893317e-17) + 1.70493760308701e-16) + Treble*(Input*(Input*(fs*(fs*(fs*(1.7495425825243e-22*fs + 5.15947717885593e-19) + 2.3901137548476e-17) - 8.12663847966588e-16) + 3.99095880872428e-15) + fs*(fs*(fs*(-1.7495425825243e-22*fs - 5.15947717885593e-19) - 2.3901137548476e-17) + 8.12663847966588e-16) - 3.99095880872428e-15) + Treble*(Input*(Input*fs*(fs*(fs*(-1.94446256943486e-22*fs + 2.99095367015295e-21) + 3.38701967358278e-20) - 2.99321910654321e-19) + fs*(fs*(fs*(1.94446256943486e-22*fs - 2.99095367015295e-21) - 3.38701967358278e-20) + 2.99321910654321e-19)) + fs*(fs*(fs*(2.07668602415643e-22*fs - 3.19433851972335e-21) - 3.61733701138641e-20) + 3.19675800578815e-19)) + fs*(fs*(fs*(-1.86851147813595e-22*fs - 5.51032162701814e-19) - 2.55264149017724e-17) + 8.67924989628316e-16) - 4.26234400771753e-15) + fs*(fs*(fs*(-9.3476168267281e-22*fs + 2.78390986018658e-18) + 1.27957634839887e-16) - 4.34250203034679e-15) + 2.13117200385877e-14;

    a5 = Bass*(Input*(Input*(fs*(fs*(fs*(fs*(4.66400408138021e-24*fs - 4.21107717183568e-20) + 4.69643971510767e-18) - 8.52210149990995e-17) + 4.70934759609501e-16) - 7.98191761744856e-16) + fs*(fs*(fs*(fs*(-4.66400408138021e-24*fs + 4.21107717183568e-20) - 4.69643971510767e-18) + 8.52210149990995e-17) - 4.70934759609501e-16) + 7.98191761744856e-16) + Treble*(Input*(Input*fs*(fs*(fs*(fs*(9.32295933998211e-25*fs + 8.13465102081422e-21) - 8.27894207186978e-19) + 1.21893473917967e-17) - 3.98098141170247e-17) + fs*(fs*(fs*(fs*(-9.32295933998211e-25*fs - 8.13465102081422e-21) + 8.27894207186978e-19) - 1.21893473917967e-17) + 3.98098141170247e-17)) + Treble*(Input*(Input*pow(fs,2)*(fs*(fs*(-1.03616486126347e-24*fs + 1.0400884417695e-22) - 1.52836235209424e-21) + 4.98869851090535e-21) + pow(fs,2)*(fs*(fs*(1.03616486126347e-24*fs - 1.0400884417695e-22) + 1.52836235209424e-21) - 4.98869851090535e-21)) + pow(fs,2)*(fs*(fs*(1.10662407182939e-24*fs - 1.11081445580983e-22) + 1.63229099203665e-21) - 5.32793000964692e-21)) + fs*(fs*(fs*(fs*(-9.95692057510089e-25*fs - 8.68780729022958e-21) + 8.84191013275692e-19) - 1.30182230144389e-17) + 4.25168814769824e-17)) + fs*(fs*(fs*(fs*(-4.98115635891407e-24*fs + 4.49743041952051e-20) - 5.01579761573499e-18) + 9.10160440190383e-17) - 5.02958323262947e-16) + 8.52468801543507e-16) + Input*(Input*(fs*(fs*(fs*(-2.91748340409741e-22*fs + 2.60665717245934e-18) - 1.19810519513002e-16) + 1.35533771234294e-15) - 3.99095880872428e-15) + fs*(fs*(fs*(2.91748340409741e-22*fs - 2.60665717245934e-18) + 1.19810519513002e-16) - 1.35533771234294e-15) + 3.99095880872428e-15) + Middle*(Bass*(Input*(Input*fs*(fs*(fs*(fs*(4.49377473953314e-25*fs - 3.45203422865533e-21) + 7.39641502461285e-20) - 4.31004728634658e-19) + 7.50300256040165e-19) + fs*(fs*(fs*(fs*(-4.49377473953314e-25*fs + 3.45203422865533e-21) - 7.39641502461285e-20) + 4.31004728634658e-19) - 7.50300256040165e-19)) + Treble*(Input*(Input*pow(fs,2)*(fs*(fs*(1.08708956034044e-25*fs + 6.17731871560931e-22) - 1.08757485215501e-20) + 3.74212252700032e-20) + pow(fs,2)*(fs*(fs*(-1.08708956034044e-25*fs - 6.17731871560931e-22) + 1.08757485215501e-20) - 3.74212252700032e-20)) + Treble*(Input*(Input*pow(fs,3)*(fs*(-7.76492543100316e-26*fs + 1.36369845222938e-24) - 4.68937660025103e-24) + pow(fs,3)*(fs*(7.76492543100316e-26*fs - 1.36369845222938e-24) + 4.68937660025103e-24)) + pow(fs,3)*(fs*(8.29294036031137e-26*fs - 1.45642994698098e-24) + 5.0082542090681e-24)) + pow(fs,2)*(fs*(fs*(-1.16101165044359e-25*fs - 6.59737638827074e-22) + 1.16152994210155e-20) - 3.99658685883635e-20)) + fs*(fs*(fs*(fs*(-4.79935142182139e-25*fs + 3.68677255620389e-21) - 7.89937124628652e-20) + 4.60313050181815e-19) - 8.01320673450896e-19)) + Input*(Input*(fs*(fs*(fs*(-2.81099951792073e-23*fs + 2.15807364568921e-19) - 4.37590986205892e-18) + 2.25888916645809e-17) - 3.19276704697943e-17) + fs*(fs*(fs*(2.81099951792073e-23*fs - 2.15807364568921e-19) + 4.37590986205892e-18) - 2.25888916645809e-17) + 3.19276704697943e-17) + Treble*(Input*(Input*fs*(fs*(fs*(-6.80009214340617e-24*fs - 3.86721597525567e-20) + 6.80858259239558e-19) - 2.34269282072115e-18) + fs*(fs*(fs*(6.80009214340617e-24*fs + 3.86721597525567e-20) - 6.80858259239558e-19) + 2.34269282072115e-18)) + Treble*(Input*(Input*pow(fs,2)*(fs*(4.85720867386155e-24*fs - 8.53036904160507e-23) + 2.93335472441235e-22) + pow(fs,2)*(fs*(-4.85720867386155e-24*fs + 8.53036904160507e-23) - 2.93335472441235e-22)) + pow(fs,2)*(fs*(-5.18749886368413e-24*fs + 9.11043413643421e-23) - 3.13282284567239e-22)) + fs*(fs*(fs*(7.26249840915779e-24*fs + 4.13018666157306e-20) - 7.27156620867848e-19) + 2.50199593253019e-18)) + fs*(fs*(fs*(3.00214748513934e-23*fs - 2.30482265359608e-19) + 4.67347173267892e-18) - 2.41249362977723e-17) + 3.40987520617403e-17) + Treble*(Input*(Input*(fs*(fs*(fs*(-5.83180860841434e-23*fs - 5.15947717885593e-19) + 2.3901137548476e-17) - 2.70887949322196e-16) + 7.98191761744856e-16) + fs*(fs*(fs*(5.83180860841434e-23*fs + 5.15947717885593e-19) - 2.3901137548476e-17) + 2.70887949322196e-16) - 7.98191761744856e-16) + Treble*(Input*(Input*fs*(fs*(fs*(6.4815418981162e-23*fs - 2.99095367015295e-21) + 3.38701967358278e-20) - 9.9773970218107e-20) + fs*(fs*(fs*(-6.4815418981162e-23*fs + 2.99095367015295e-21) - 3.38701967358278e-20) + 9.9773970218107e-20)) + fs*(fs*(fs*(-6.9222867471881e-23*fs + 3.19433851972335e-21) - 3.61733701138641e-20) + 1.06558600192938e-19)) + fs*(fs*(fs*(6.22837159378651e-23*fs + 5.51032162701814e-19) - 2.55264149017724e-17) + 2.89308329876105e-16) - 8.52468801543507e-16) + fs*(fs*(fs*(3.11587227557603e-22*fs - 2.78390986018658e-18) + 1.27957634839887e-16) - 1.44750067678226e-15) + 4.26234400771753e-15;
};
