Server.killAll;
s.boot;

(
var window, freq, scope, sine1FrequencyKnob, sine2FrequencyKnob, sine1GainKnob, sine2GainKnob, knob3, startButton1, startButton2, sine, sine2, gain, curve, distMenu, oversamplingMenu, inputSignal, filteredSignal, filterCutoff, cutoffMenu, selectedCutoff, distortionType, identityCurveFunction, identityCurveSignal, identityCurve, hardClipCurve, hardClipCurveAsym, softClipCurve, softClipCurveAsym, halfRectCurve, fullRectCurve, signalBuffer, inputBus, distortedSignal, shaper, buffer, hardClipCurveFunction, hardClipCurveFunctionAsym, softClipCurveFunction, softClipCurveFunctionAsym, halfRectCurveFunction, fullRectCurveFunction, hardClipCurveSignal, hardClipCurveSignalAsym, softClipCurveSignal, softClipCurveSignalAsym, halfRectCurveSignal, fullRectCurveSignal, outputBus, inputScope, outputScope, transferFunctionBox, freqValue1, freqValue2, image, alpha, bounds, compositeView, scopePos, freqModeMenu, dbRangeMenu, transferFunc, data, x, plotContainer, transferFuncPlot, val;


//BUSSES
inputBus = Bus.audio(s, 2);

//CURVES
identityCurveFunction = {arg x; x};
softClipCurveFunction = {arg x; tanh(x * 2)};
softClipCurveFunctionAsym = {arg x; if (x>=0, {tanh(x * 2)}, {tanh(x * 4)}) };
hardClipCurveFunction = {arg x; x.sign * min(2 * x.abs, 1)};
hardClipCurveFunctionAsym = {arg x; if (x>=0, {min(2 * x.abs, 1)}, {-1.0 * min(2.5 * x.abs, 1)})};
halfRectCurveFunction = {arg x; max(x, 0)};
fullRectCurveFunction = {arg x; x.abs};

identityCurveSignal = Signal.newClear(513);
softClipCurveSignal = Signal.newClear(513);
softClipCurveSignalAsym = Signal.newClear(513);
hardClipCurveSignal = Signal.newClear(513);
hardClipCurveSignalAsym = Signal.newClear(513);
halfRectCurveSignal = Signal.newClear(513);
fullRectCurveSignal = Signal.newClear(513);

identityCurveSignal.waveFill(identityCurveFunction, -1.0, 1.0);
softClipCurveSignal.waveFill(softClipCurveFunction, -1.0, 1.0);
softClipCurveSignalAsym.waveFill(softClipCurveFunctionAsym, -1.0, 1.0);
hardClipCurveSignal.waveFill(hardClipCurveFunction, -1.0, 1.0);
hardClipCurveSignalAsym.waveFill(hardClipCurveFunctionAsym, -1.0, 1.0);
halfRectCurveSignal.waveFill(halfRectCurveFunction, -1.0, 1.0);
fullRectCurveSignal.waveFill(fullRectCurveFunction, -1.0, 1.0);

identityCurve = Buffer.loadCollection(s, identityCurveSignal.asWavetableNoWrap);
softClipCurve = Buffer.loadCollection(s, softClipCurveSignal.asWavetableNoWrap);
softClipCurveAsym = Buffer.loadCollection(s, softClipCurveSignalAsym.asWavetableNoWrap);
hardClipCurve = Buffer.loadCollection(s, hardClipCurveSignal.asWavetableNoWrap);
hardClipCurveAsym = Buffer.loadCollection(s, hardClipCurveSignalAsym.asWavetableNoWrap);
halfRectCurve = Buffer.loadCollection(s, halfRectCurveSignal.asWavetableNoWrap);
fullRectCurve = Buffer.loadCollection(s, fullRectCurveSignal.asWavetableNoWrap);

//Transfer functions
~transferFunctions = [
    "f(x) = x",
    "f(x) = tanh(2x)",
	"f(x) = if (x>=0, {tanh(x * 2)}, {tanh(x * 4)})",
    "f(x) = sign(x) * min(2|x|, 1)",
	"f(x) = if (x>=0, {min(2 * x.abs, 1)}, {-1.0 * min(2.5 * x.abs, 1)})",
    "f(x) = max(x, 0)",
    "f(x) = |x|"
];


//SYNTH
SynthDef.new("sine", {|freq1 = 440, ampin1 = 0.4, ampout1 = 0.001, bus = 0|
    Out.ar(bus, SinOsc.ar([freq1, freq1], 0, 1) * ampin1*2)
}).add;

SynthDef.new(\shaper, {|out = 0, in, curve, filterCutoff = 18000, gain = 1|

    inputSignal = In.ar(in, 2);
    distortedSignal = Shaper.ar(curve, inputSignal);
    filteredSignal = LPF.ar(distortedSignal, filterCutoff);

    Out.ar(out, filteredSignal * gain);
}).add;

sine = Synth.newPaused(\sine, [\bus, inputBus]);
sine2 = Synth.newPaused(\sine, [\bus, inputBus]);
shaper = Synth.after(sine, \shaper, [
	\out, outputBus,
	\in, inputBus,
	\curve, curve,
	\gain, 1

]);


// GUI
image = Image.new(thisProcess.nowExecutingPath.dirname +/+ "images/teachbg.png");
alpha = 1.0;
bounds = Rect(0, 0, 1280, 720);

// Create the main window
window = Window("FabDist_Teach Mode", Rect(100,80, 1280, 720))
    .onClose_({ scope.free; freq.kill });
window.view.setBackgroundImage(image, 11, alpha, bounds);
window.front;

b = Button(window, Rect(422, 678, 437, 30))
.states_([["TAKE ME TO THE QUIZ", Color.black, Color.red]])
.font_(Font("Monaco",20, true))
.action = {
	thisProcess.interpreter.executeFile("FabDist_learn.scd");
	sine.run(false);
	sine2.run(false);
};


// Labels
TextView(window, Rect(310, 280, 46, 23)).string_("FREQ 1").font_(Font("Monaco",10));
TextView(window, Rect(450, 280, 46, 23)).string_("GAIN 1").font_(Font("Monaco",10));
TextView(window, Rect(790, 280, 46, 23)).string_("GAIN 2").font_(Font("Monaco",10));
TextView(window, Rect(925, 280, 46, 23)).string_("FREQ 2").font_(Font("Monaco",10));
TextView(window, Rect(588, 335, 99, 30)).string_("GLOBAL OUT").font_(Font("Monaco",15));

// Create a start/stop button
startButton1 = Button(window, Rect(89, 107, 150, 64))
.font_(Font("Monaco",30, true))
.states_([
	[ "START", Color.black, Color.gray],
	["STOP", Color.white, Color.red]
])
.action = { arg me;
    val = me.value;
    if (val == 1) {
        sine.run;
	} { sine.run(false) }
};



// Create a frequency knob
sine1FrequencyKnob = Knob(window, Rect(267, 137, 135, 135))
.valueAction_(0.01) // Initial value (0.5 is the middle of the range)
.color_([Color.new255(200,0,0), Color.new255(10,150,234), Color.white])
.action_({ arg me;
    freqValue1 = me.value.linexp(0, 1, 100, 17000); // Convert knob value to a frequency range (100Hz to 700Hz)
    sine.set(\freq1, freqValue1);
});

// Create an input gain knob
sine1GainKnob = Knob(window, Rect(404, 137, 135, 135))
.valueAction_(0.4)
.action_({ arg me; sine.set(\ampin1 , me.value) })
.color_([Color.new255(200,0,0), Color.new255(10,150,234), Color.white]);


startButton2 = Button(window, Rect(1042, 107, 150, 64))
.font_(Font("Monaco",30, true))
.states_([
	[ "START", Color.black, Color.gray],
	["STOP", Color.white, Color.red]
])
.action = { arg me;
    val = me.value;
    if (val == 1) {
        sine2.run;
	} { sine2.run(false) }
};

sine2FrequencyKnob = Knob(window, Rect(877, 137, 135, 135))
.valueAction_(0.5) // Initial value (0.5 is the middle of the range)
.color_([Color.new255(200,0,0), Color.new255(10,150,234), Color.white])
.action_({ arg me;
    freqValue2 = me.value.linexp(0, 1, 100, 17000); // Convert knob value to a frequency range (100Hz to 17000Hz)
    sine2.set(\freq1, freqValue2);
});

sine2GainKnob = Knob.new(window, Rect(740, 137, 135, 135))
.valueAction_(0.2)
	.color_([Color.new255(200,0,0), Color.new255(10,150,234), Color.white])
.action_({ arg me; sine2.set(\ampin1 , me.value) });

// Create an output gain knob
knob3 = Knob(window, Rect(540, 137, 200, 200))
.valueAction_(1)
.color_([Color.new255(255, 216, 15), Color.new255(200,0,200), Color.white])
.action_({ arg me; shaper.set(\gain , me.value) });

// Add a CompositeView to contain the Plotter
plotContainer = CompositeView(window, Rect(66, 390, 380, 263)).background_(Color.gray);

// Create a Plotter
transferFuncPlot = Plotter.new("Transfer Function Plot", parent: plotContainer);

// Create a distortion type menu
distMenu = PopUpMenu(window, Rect(65, 325, 150, 30));
distMenu.font_(Font("Monaco",15));
distMenu.items = ["No Distortion", "Soft Clip", "Soft Clip Asym",  "Hard Clip", "Hard Clip Asym", "Half Rect", "Full Rect"];
distMenu.valueAction = 0;
distMenu.action = { arg distMenu;
    switch (distMenu.value,
        0, { curve = identityCurve; },
        1, { curve = softClipCurve; },
		2, { curve = softClipCurveAsym; },
        3, { curve = hardClipCurve; },
		4, { curve = hardClipCurveAsym; },
        5, { curve = halfRectCurve; },
        6, { curve = fullRectCurve; }
    );
    shaper.set(\curve, curve);

	// Update the transfer function in the text box
    transferFunctionBox.string_(~transferFunctions[distMenu.value]);

	// Plot the transfer function
    switch (distMenu.value,
        0, { transferFunc = identityCurveFunction; },
        1, { transferFunc = softClipCurveFunction; },
        2, { transferFunc = softClipCurveFunctionAsym; },
        3, { transferFunc = hardClipCurveFunction; },
        4, { transferFunc = hardClipCurveFunctionAsym; },
        5, { transferFunc = halfRectCurveFunction; },
        6, { transferFunc = fullRectCurveFunction; }
    );

        data = Array.fill(1000, { |i|
        x = i / 999.0 * 2.0 - 1.0;
        transferFunc.value(x);
    });
	// Update the plotter value
	transferFuncPlot.value = data;
	transferFuncPlot.update;
	transferFuncPlot.setProperties(
		\fontColor, Color.red,
		\plotColor, Color.white,
		\backgroundColor, Color.black,
		\gridColorX, Color.white,
		\labelX, "Transfer Function Plot"
	);
	transferFuncPlot.refresh;
};

//Textbox to view the transfer function
//StaticText(window, Rect(265, 325, 150, 30)).string_("Transfer Function:");
transferFunctionBox = TextView(window, Rect(265, 320, 200, 40))
.font_(Font("Monaco",12))
.background_(Color.white)
.string_("f(x) = x"); // Set the initial transfer function (identityCurve)

// Create a filter cutoff control menu
cutoffMenu = PopUpMenu(window, Rect(1020, 325, 150, 30))
.font_(Font("Monaco",15))
.items_(["18000 Hz", "16000 Hz", "12000 Hz", "8000 Hz", "4000 Hz", "2000 Hz"])
.action_({ arg me;
        var selectedCutoff = me.value;
        shaper.set(\filterCutoff, [18000, 16000, 12000, 8000, 4000, 2000][selectedCutoff]);
});


// Create an analyzer
scopePos = FreqScopeView(window, Rect(500, 400, 260, 230)).active_(true);
scope = Stethoscope(Server.default, view: scopePos);
freq = FreqScopeView(window, Rect(835, 390, 382, 230)).active_(true);
freq.freqMode = 0;
freq.dbRange = 120;

// FreqScopeView Controls
// Control for freqMode
freqModeMenu = PopUpMenu(window, Rect(850, 620, 150, 30))
.font_(Font("Monaco", 15))
.items_(["Linear Frequency", "Log Frequency"])
.action_({ |me|
    freq.freqMode_(me.value);
});

// Control for dbRange
dbRangeMenu = PopUpMenu(window, Rect(1000, 620, 150, 30))
.font_(Font("Monaco", 15, true))
.items_(["60 dB", "90 dB", "120 dB", "150 dB"])
.action_({ |me|
    freq.dbRange_([60, 90, 120, 150][me.value]);
});


// Set the onClose action for the window
window.onClose_({ sine.free; s.freeAll;});

)
