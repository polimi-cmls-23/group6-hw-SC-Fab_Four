# FabDist - A SuperCollider Toolbox to teach and learn distortion

This project aims to create an audio distortion box for teaching and learning purpose using the SuperCollider programming language.
The synthesizer is designed to produce one or two sine waves and apply various distortion techniques to the generated sound.
The project also features a graphical user interface (GUI) for controlling various parameters such as input gain, output gain, distortion type, filter cutoff and frequency.
The teaching GUI permits to explore the various types of distortion along with time/frequency graphs and transfer function definition.
The learning GUI is organized as a score quiz where the user has to recognize the distortion type from time/frequency representation.

## Features of teach script

- Two sine wave oscillators with frequency and gain control
- Distortion types:
    - No Distortion
    - Soft Clip
    - Soft Clip Asymmetrical
    - Hard Clip
    - Hard Clip Asymmetrical
    - Half Rectification
    - Full Rectification
- Output gain control
- Low-pass filter with selectable cutoff frequencies
- Frequency spectrum analyzer
- Waveform display
- Transfer function display

## Features of teach script

- Interactive quiz interface to learn and identify different types of audio distortion
- Real-time audio processing using SuperCollider
- Controls for adjusting frequency, input gain, and output gain
- Score tracking based on correct answers

## How to Use

1. Install [SuperCollider](https://supercollider.github.io/download) if you haven't already.
2. Clone or download this repository to your local machine.
3. Open the main file `FabDist-teach.scd` or `FabDist-learn.scd` in the SuperCollider IDE.
4. To run the application, select the entire code and press `Ctrl+Enter` (Windows/Linux) or `Cmd+Enter` (macOS).
5. The GUI will appear, allowing you to control the parameters of the distortion synthesizer.
6. Start and stop the sine wave oscillators using the "Start" and "Stop" buttons.
7. Adjust the frequency and gain of each oscillator using the corresponding knobs.
8. Choose a distortion type from the drop-down menu.
9. Adjust the output gain using the "Output Gain" knob.
10. Select a low-pass filter cutoff frequency from the "Filter Cutoff" drop-down menu.
11. Observe the frequency spectrum analyzer and waveform for real-time visualization of the audio signal.

## License

This project is open-source and available under the [MIT License](LICENSE).