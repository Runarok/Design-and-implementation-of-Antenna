# **PLL Simulation Documentation**

This documentation provides a detailed overview of the variables, functions, and processes used across the `Parameters.m`, `implementation.m`, and `analysis.m` files. It serves as a guide for newcomers to understand the system simulation and analysis.

---

## **1. Parameters.m**
Defines system-level parameters and transfer functions for a Phase-Locked Loop (PLL) simulation.

### **Variables**
- **`Kp`**: Phase detector gain, \( \frac{1}{2\pi} \) (volts/rad).
- **`Kvf`**: VCO frequency sensitivity, \( 100 \times 10^6 \) Hz/volt.
- **`Kvw`**: VCO angular frequency sensitivity, \( 2\pi \times K_{vf} \) rad/sec/volt.
- **`Kc`**: Charge pump gain, \( 5 \times 10^{-3} \).
- **`N`**: Divider value, 70.
- **`Fref`**: Reference frequency, 30 MHz.
- **`HoldOff`**: Hold-off time, \( 10 \times 10^{-6} \) sec.
- **`VCO_PN_F`**: Offset frequencies for VCO phase noise, in Hz.
- **`VCO_PN_L`**: VCO phase noise levels at offset frequencies, in dBc/Hz.
- **`OSR`**: Oversampling rate, 4.
- **`RBW2`**: Resolution bandwidth, 100 kHz.
- **`dF`**: Frequency resolution for FFT, \( \frac{RBW2}{2} \).
- **`nFFTout`**: FFT size, derived based on oversampling and \( Fref \).
- **`Navg`**: Number of FFT averages, 2.
- **`OverlapFactor`**: Overlap factor for FFT, 0.9.
- **`Fs`**: Sampling rate, \( OSR \times N \times Fref \).

### **Functions**
- **`thirdOrderPassiveFilterDesign`**: Designs a 3rd-order passive loop filter using:
  - `LoopBW`: Loop bandwidth, 2 MHz.
  - `PM`: Phase margin, 45°.
  - **Output**: Component values \( C1, C2, C3, R2, R3 \).

### **Transfer Functions**
- **`tf_lf`**: Loop filter transfer function (3rd-order).
- **`tf_pd`**: PFD and charge pump transfer function.
- **`tf_vco`**: VCO model.
- **`tf_div`**: Divider model.
- **`FWD_GAIN`**: Forward path gain of PLL.
- **`OL_GAIN`**: Open-loop transfer function.
- **`CL_TF`**: Closed-loop transfer function (with feedback).

---

## **2. Implementation.m**
Executes simulations for the PLL system.

### **Processes**
1. **Step Response Simulation**:
   - Simulates the step response of the closed-loop transfer function (`CL_TF`).
   - **Time Vector**: \( t = 0 \) to \( 10 \times 10^{-6} \) s, with 1000 points.
   - **Outputs**:
     - `t`: Time vector.
     - `y`: Step response output.

2. **Open-Loop Frequency Response**:
   - Simulates magnitude and phase response of the open-loop transfer function (`OL_GAIN`).
   - **Frequency Range**: 10 Hz to 1 GHz (log scale).
   - **Outputs**:
     - `w`: Frequency vector.
     - `mag`: Magnitude response.
     - `phase`: Phase response.
     - `mag_dB`: Magnitude in dB.

3. **Save Results**:
   - Saves simulation outputs to `Implementation_Results.mat`.

---

## **3. Analysis.m**
Analyzes the simulation results and phase noise behavior.

### **Processes**
1. **Load Results**:
   - Loads parameters and simulation results from `Parameters.m` and `Implementation_Results.mat`.

2. **Phase Noise Interpolation**:
   - Interpolates phase noise profiles for better resolution across the frequency range (`freqv`).

3. **Overall Phase Noise Calculation**:
   - Combines noise contributions (e.g., reference, charge pump, VCO).
   - Uses closed-loop transfer function (`CL_TF`) to compute transfer function from reference to VCO.

4. **Plot Results**:
   - **Phase Noise Spectrum**:
     - Plots total phase noise vs. frequency.
   - **Step Response**:
     - Visualizes the time-domain step response.
   - **Open-Loop Magnitude Response**:
     - Plots magnitude response of `OL_GAIN`.
       
5. **RMS Jitter Calculation**:
   - Computes RMS jitter as the product of:
     1. The reciprocal of \(2 \pi\), the divider value \(N\), and the reference frequency \(F_ref\).
     2. The square root of twice the integral of the phase noise \(PN(f)\) across the frequency range of interest.
   - **Output**: Jitter in picoseconds.

### **Outputs**
- `RMS_Jitter`: RMS jitter in seconds (converted to picoseconds for display).

---

## **General Notes**
- **Dependencies**:
  - All files depend on `Parameters.m` for system setup.
  - `implementation.m` generates simulation results required by `analysis.m`.
- **Key Results**:
  - Transfer functions, step response, frequency response, phase noise spectrum, and RMS jitter are key metrics for PLL performance evaluation.

---

## **Getting Started**
1. Run `Parameters.m` to initialize parameters.
2. Execute `implementation.m` to generate simulation data.
3. Run `analysis.m` to analyze results and compute metrics.

