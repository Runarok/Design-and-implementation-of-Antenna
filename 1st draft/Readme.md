# Parameters.m Explanation

The `Parameters.m` script is used for initializing and configuring the parameters of a Phase-Locked Loop (PLL) system. Below is a breakdown of its key components:

## 1. **Gain and Constants Initialization**
The script sets up key parameters for the PLL system, including various system constants:

- `Kp = 1/(2*pi)`: Gain of the phase detector.
- `Kvf = 100e6`: Voltage-to-frequency conversion factor for the VCO in Hz/volt.
- `Kvw = 2*pi*Kvf`: VCO gain in (rad/sec)/volt.
- `Kc = 5e-3`: Charge pump current gain.
- `N = 70`: Divider ratio.
- `Fref = 30e6`: Reference frequency.
- `HoldOff = 10e-6`: Hold-off time for measurements.

## 2. **VCO Phase Noise Settings**
The phase noise of the Voltage-Controlled Oscillator (VCO) is defined at several offset frequencies:

- `VCO_PN_F`: Offset frequencies from 10 kHz to 10 MHz.
- `VCO_PN_L`: Corresponding phase noise levels in dBc/Hz.

## 3. **Phase Noise Measurement Settings**
There are two methods for measuring phase noise: zero-crossing and spectrum-based. Both methods are initialized here:

- **Zero-Crossing Measurement**:
  - `RBW = 7.5e3`: Resolution bandwidth.
  - `Navg = 1`: Number of averages.
  
- **Spectrum-Based Measurement**:
  - `OSR = 4`: Oversampling rate.
  - `RBW2 = 100e3`: Resolution bandwidth.
  - `nFFTout`: FFT size for the PLL output.
  - `Navg = 2`: Number of averages.
  - `OverlapFactor = 0.9`: Overlap factor for FFT processing.
  - `Fs`: Sampling rate.

## 4. **Loop Filter Design**
The loop filter is a crucial part of the PLL. A symbolic transfer function for a third-order passive loop filter is derived:

- `R2, R3`: Resistor values.
- `C1, C2, C3`: Capacitor values.

The transfer function is computed symbolically, and the poles and zeros are determined.

## 5. **PLL Transfer Function and Control System**
The PLL system is described as a control system using transfer functions for various components:

- **Phase Detector and Charge Pump**: Modeled as a transfer function with a delay (`Tpd = 100e-12`).
- **Loop Filter**: The transfer function for the loop filter is derived from the previously computed symbolic result.
- **VCO Model**: The VCO is modeled as an integrator with `Kvw` gain.
- **Divider**: The divider is modeled with a gain of `1/N`.

## 6. **Open-Loop and Closed-Loop Analysis**
The open-loop (`OL_GAIN`) and closed-loop (`CL_TF`) transfer functions are computed, and the stability of the system is analyzed by plotting Bode diagrams:

- Open-loop magnitude and phase responses are plotted.
- Closed-loop step response is simulated.

## 7. **Control System Design**
The script also allows for interactive control system design through the `controlSystemDesigner` tool.

---

This script serves as the initialization and configuration backbone for the PLL system, defining the components, transfer functions, and noise parameters needed for simulation and analysis.
---
---
# Implementation.slx Explanation

![Simulink Model](./image/Simulink%20model.png)


The `implementation.slx` file represents the Simulink model of a Phase-Locked Loop (PLL) system. This model simulates the behavior of the PLL and allows for the analysis of its performance, including phase noise contributions from different components. Below is an overview of its structure and key components:

## 1. **PLL Block Diagram**
The Simulink model includes the essential components of a PLL system:

- **Phase Detector (PD)**: Compares the phase of the input signal with the phase of the output signal from the VCO.
- **Charge Pump (CP)**: Converts the phase difference from the phase detector into a current, which is used to adjust the VCO frequency.
- **Loop Filter (LF)**: Filters the charge pump's output to smooth the control voltage applied to the VCO.
- **Voltage-Controlled Oscillator (VCO)**: Adjusts its output frequency based on the control voltage received from the loop filter.
- **Frequency Divider**: Divides the VCO's output frequency and feeds it back to the phase detector for comparison with the reference signal.

## 2. **Noise Injection Points**
The model includes several noise injection points to analyze the impact of different noise sources on the overall PLL performance. These noise sources are injected at various locations:

- **Reference Phase Noise**: Simulates phase noise originating from the reference input signal.
- **Charge Pump Phase Noise**: Simulates noise from the charge pump.
- **Loop Filter Resistor Noise**: Simulates thermal noise from resistors in the loop filter (`R2_noise` and `R3_noise`).
- **VCO Phase Noise**: Simulates the intrinsic phase noise of the VCO.

These noise sources are injected to study their effects on the output signal.

## 3. **VCO Output**
The output of the PLL system is taken from the VCO. This is where the final frequency-adjusted signal is produced, which is analyzed to measure phase noise and system stability.

## 4. **Linearization of the Model**
The model is designed to be linearized for phase noise analysis. Using MATLAB's `linearize` function, the system's transfer functions can be computed, which allows for the analysis of the system's response to various noise sources. The linearized system can then be used in further MATLAB scripts (e.g., `analysis.m`) for frequency domain analysis.

## 5. **Closed-Loop Feedback**
The model implements closed-loop feedback between the phase detector and the frequency divider. This feedback ensures that the PLL locks to the correct frequency and phase, stabilizing the output.

## 6. **Analysis and Simulation**
The `implementation.slx` model is used in conjunction with MATLAB scripts (e.g., `Parameters.m` and `analysis.m`) to simulate the PLL's behavior and analyze performance metrics such as phase noise, stability, and jitter.

- **Open-Loop and Closed-Loop Responses**: By linearizing the model, open-loop and closed-loop frequency responses can be computed to assess system stability and performance.
- **Phase Noise Contributions**: The model allows for detailed analysis of how different components (e.g., reference, charge pump, VCO) contribute to the total phase noise at the VCO output.

---

This Simulink model is essential for simulating and analyzing the PLL system's performance, enabling detailed phase noise and stability analysis.
---
---
# Analysis.m Explanation

The `analysis.m` script is designed to analyze the phase noise and overall performance of a Phase-Locked Loop (PLL) system by linearizing its Simulink model (`implementation.slx`). This script performs phase noise computations and visualizes the contributions from various noise sources. Below is an outline of its functionality:

## 1. **Model Linearization and Noise Injection**
The script begins by linearizing the PLL Simulink model (`implementation.slx`) to analyze its response to noise injections at different points:
- **Phase Noise Inputs**: Noise is injected into the model at multiple points:
  - `Ref_PN`: Reference phase noise.
  - `CP_PN`: Charge pump phase noise.
  - `R2_noise`: Resistor noise from `R2` in the loop filter.
  - `R3_noise`: Resistor noise from `R3` in the loop filter.
  - `VCO_PN`: VCO phase noise.

The output is taken from the VCO (`Inject_3`), and the system is linearized using the `linearize` function.

## 2. **Phase Noise Definition**
The script defines the phase noise profiles for the reference, charge pump, and VCO across multiple frequencies:
- **Reference Phase Noise** (`Ref_PN_Freq`, `Ref_PN_Level`): Constant phase noise levels across specified frequencies.
- **Charge Pump Phase Noise** (`CP_PN_Freq`, `CP_PN_Level`): Noise levels at different frequency offsets.
- **VCO Phase Noise** (`VCO_PN_Freq`, `VCO_PN_Level`): Noise levels at different frequency offsets for the VCO.

## 3. **Frequency Range and Interpolation**
The frequency range of interest is determined based on the minimum and maximum phase noise frequencies. The phase noise profiles are interpolated across this frequency range using linear or spline interpolation for smooth curves.

## 4. **Transfer Function Calculations**
The script calculates the transfer functions from each noise source to the VCO output:
- **`H_REF2VCO`**: Transfer function from the reference to the VCO output.
- **`H_CP2VCO`**: Transfer function from the charge pump to the VCO output.
- **`H_VCO2VCO`**: Transfer function from the VCO to the VCO output.
- **`GR2`, `GR3`**: Transfer functions for noise from resistors `R2` and `R3` in the loop filter to the output.

These transfer functions are then plotted, showing the noise propagation from each source to the VCO output.

## 5. **Overall Phase Noise Calculation**
The total phase noise at the VCO output is computed by summing the contributions from all noise sources:
- Each noise source's power is converted from dB to linear units.
- The power is then scaled by the square of the respective transfer function, and the total noise is computed by summing these contributions.
- The resistor noise contribution is computed using Boltzmann's constant (`Kb`) and the temperature (`T`).

The overall phase noise is converted back to dB and plotted for visualization.

## 6. **Plotting Results**
The script generates several plots:
- **Transfer Functions**: Displays the individual transfer functions from each noise source to the VCO output.
- **Total Phase Noise**: Plots the overall phase noise at the VCO output, showing the contributions from reference, charge pump, VCO, and resistor noise sources.
- **Phase Noise Breakdown**: Plots the individual phase noise contributions from each noise source (reference, charge pump, VCO, loop filter).

## 7. **RMS Jitter Calculation**
The RMS jitter is computed using the overall phase noise profile:
- The jitter is calculated by integrating the total phase noise power over the frequency range.
- The RMS jitter is displayed on the phase noise plot title for easy reference.

## 8. **Phase Noise Prediction**
The script computes predicted phase noise levels at specific VCO frequencies (`VCO_PN_Freq`) and saves this prediction data for future comparison with measured results. The phase noise is saved in the file `Predicted_Phase_Noise.mat`.

---

This script is essential for performing detailed phase noise analysis of the PLL system, visualizing how different noise sources impact the output, and calculating important metrics such as RMS jitter.
---
---
