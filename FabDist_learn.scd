

(
var window, freq, scope, sine1FrequencyKnob, sine2FrequencyKnob, sine1GainKnob, sine2GainKnob, knob3, startButton1, startButton2, sine, sine2, gain, curve, distMenu, oversamplingMenu, inputSignal, filteredSignal, filterCutoff, cutoffMenu, selectedCutoff, distortionType, identityCurveFunction, identityCurveSignal, identityCurve, hardClipCurve, hardClipCurveAsym, softClipCurve, softClipCurveAsym, halfRectCurve, fullRectCurve, signalBuffer, inputBus, distortedSignal, shaper, buffer, hardClipCurveFunction, hardClipCurveFunctionAsym, softClipCurveFunction, softClipCurveFunctionAsym, halfRectCurveFunction, fullRectCurveFunction, hardClipCurveSignal, hardClipCurveSignalAsym, softClipCurveSignal, softClipCurveSignalAsym, halfRectCurveSignal, fullRectCurveSignal, outputBus, inputScope, outputScope, transferFunctionBox, freqValue1, freqValue2, image, alpha, bounds, compositeView, scopePos, freqModeMenu, dbRangeMenu, rand, questionText, submitButtons, nextQuestion, resultText, validDistortionTypes, newDistortionType, val, currentDir;


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
shaper = Synth.after(sine, \shaper, [
	\out, outputBus,
	\in, inputBus,
	\curve, curve,
	\gain, 1

]);


// GUI
currentDir = thisProcess.nowExecutingPath.dirname;
image = Image.new(currentDir +/+ "images/learnbg.png");
alpha = 1.0;
bounds = Rect(0, 0, 1280, 720);

// Create the main window
window = Window("FabDist_Learn Mode", Rect(100,80, 1280, 720))
    .onClose_({ scope.free; freq.kill });
window.view.setBackgroundImage(image, 11, alpha, bounds);
window.front;



// Labels
TextView(window, Rect(97, 320, 46, 23)).string_("FREQ 1").font_(Font("Monaco",10));
TextView(window, Rect(97, 545, 46, 23)).string_("GAIN 1").font_(Font("Monaco",10));
TextView(window, Rect(201, 435, 75, 23)).string_("GLOBAL OUT").font_(Font("Monaco",10));

// Create a start/stop button
startButton1 = Button(window, Rect(58, 93, 163, 70))
.font_(Font("Monaco",30))
.states_([
	["START", Color.black, Color.gray],
	["STOP", Color.white, Color.red]
])
.action = { arg me;
    val = me.value;
    if (val == 1) {
        sine.run;
	} { sine.run(false) }
};



// Create a frequency knob
sine1FrequencyKnob = Knob(window, Rect(57, 179, 135, 135))
.valueAction_(0.5) // Initial value (0.5 is the middle of the range)
.color_([Color.new255(200,0,0), Color.new255(10,150,234), Color.white])
.action_({ arg me;
    freqValue1 = me.value.linexp(0, 1, 100, 17000); // Convert knob value to a frequency range (100Hz to 700Hz)
    sine.set(\freq1, freqValue1);
});

// Create an input gain knob
sine1GainKnob = Knob(window, Rect(57, 405, 135, 135))
.color_([Color.new255(200,0,0), Color.new255(10,150,234), Color.white])
.valueAction_(0.4)
.action_({ arg me; sine.set(\ampin1 , me.value) });


// Create an output gain knob
knob3 = Knob(window, Rect(149.3, 292, 135, 135))
.color_([Color.new255(255, 216, 15), Color.new255(200,0,200), Color.white])
.valueAction_(1)
.action_({ arg me; shaper.set(\gain , me.value) });

// Create an analyzer
scopePos = FreqScopeView(window, Rect(330, 235, 260, 230)).active_(true);
scope = Stethoscope(Server.default, view: scopePos);
freq = FreqScopeView(window, Rect(650, 220, 520, 250)).active_(true);
freq.freqMode = 1;
freq.dbRange = 150;

// FreqScopeView Controls
// Control for freqMode
freqModeMenu = PopUpMenu(window, Rect(700, 465, 150, 30))
.font_(Font("Monaco", 15))
.items_(["Linear Frequency", "Log Frequency"])
.action_({ |me|
    freq.freqMode_(me.value);
});

// Control for dbRange
dbRangeMenu = PopUpMenu(window, Rect(900, 465, 150, 30))
.font_(Font("Monaco", 15))
.items_(["60 dB", "90 dB", "120 dB", "150 dB"])
.action_({ |me|
    freq.dbRange_([60, 90, 120, 150][me.value]);
});

// create random distortion type
~randomDistortionType = { |previousDistortionType|
    newDistortionType = rrand(1, 6);
	while ({newDistortionType == previousDistortionType}) {
        newDistortionType = rrand(1, 6);
    };

    curve = [softClipCurve, softClipCurveAsym, hardClipCurve, hardClipCurveAsym, halfRectCurve, fullRectCurve][newDistortionType - 1];
    shaper.set(\curve, curve);
    newDistortionType;
};


// Text box with current question
questionText = StaticText(window, Rect(450, 145, 700, 40))
.string_("Question: Which distortion type is this?")
.font_(Font("Gadget", 30))
.stringColor_(Color.white);

// buttons for each distortion type
submitButtons = [
    Button(window, Rect(327, 518, 260, 43))
	.states_([["A.  Soft Clip", Color.black]])
	.font_(Font("Gadget", 20))
	.action_({ ~checkAnswer.(1) }),
    Button(window, Rect(614, 518, 260, 43))
	.states_([["B.  Soft Clip Asymmetrical", Color.black]])
	.font_(Font("Gadget", 20))
	.action_({ ~checkAnswer.(2) }),
    Button(window, Rect(901, 518, 260, 43))
	.states_([["C.  Hard Clip", Color.black]])
	.font_(Font("Gadget", 20))
	.action_({ ~checkAnswer.(3) }),
	Button(window, Rect(327, 590, 260, 43))
	.states_([["D.  Hard Clip Asymmetrical", Color.black]])
	.font_(Font("Gadget", 20))
	.action_({ ~checkAnswer.(4) }),
	Button(window, Rect(614, 590, 260, 43))
	.states_([["E.  Half rect", Color.black]])
	.font_(Font("Gadget", 20))
	.action_({ ~checkAnswer.(5) }),
	Button(window, Rect(901, 590, 260, 43))
	.states_([["F.  Full rect", Color.black]])
	.font_(Font("Gadget", 20))
	.action_({ ~checkAnswer.(6) })
];

// checks if the user's answer is correct and updates the score
~score = 0;
~totalQuestions = 0;
~currentDistortionType = 0;

// display the result of the checkAnswer function
resultText = StaticText(window, Rect(380, 660, 511, 40))
.font_(Font("Gadget", 20))
.stringColor_(Color.white);

// map numbers to letters
~numberToLetter = { |number|
	switch (number,
		1, { "A" },
		2, { "B" },
		3, { "C" },
		4, { "D" },
		5, { "E" },
		6, { "F" }
	)
};

~checkAnswer = { |answer|
	~totalQuestions = ~totalQuestions + 1;
    if (answer == ~currentDistortionType) {
        ~score = ~score + 1;
		resultText.string = "Correct ! Your score is now " ++ ~score ++ " on " ++ ~totalQuestions ++ " answered questions";
    } {
        resultText.string = "Incorrect ! The correct answer was " ++ ~numberToLetter.(~currentDistortionType);
    };
    ~nextQuestion.();
};

// move to the next question and update the question text
~nextQuestion = {
	~currentDistortionType = ~randomDistortionType.(~currentDistortionType);
    questionText.string = "Question " ++ (~totalQuestions + 1) ++ ": Which distortion type is this?";
};


// next question
~nextQuestion.();

// Set the onClose action for the window
window.onClose_({ sine.free;});


)
