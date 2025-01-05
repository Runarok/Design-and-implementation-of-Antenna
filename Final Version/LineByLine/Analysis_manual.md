# Analysis.m - Line-by-Line Analysis and Manual Calculations

This document provides a detailed line-by-line explanation of the code in `Analysis.m`. For each line, the code is shown, followed by its purpose, manual calculation (if applicable), and any additional information.

---

## **Line-by-Line Explanation**

### **1. Load Parameters and Simulation Results**
**Code**:  
run('Parameters.m');  
load('Implementation_Results.mat');

- **Purpose**:  
  - **`run('Parameters.m')`**: Executes the **Parameters.m** script to load all system parameters and transfer functions into the workspace. This ensures the parameters defined in **Parameters.m**, such as gains, phase noise levels, frequency settings, and transfer functions, are available in the current workspace for the analysis.
  - **`load('Implementation_Results.mat')`**: Loads the simulation results stored in the `.mat` file `Implementation_Results.mat`. This file contains the results of the system simulation, such as the step response (`y`), time vector (`t`), frequency vector (`w`), magnitude response (`mag`), phase response (`phase`), and magnitude in dB (`mag_dB`). These results will be used for the phase noise and jitter analysis.

---

### **2. Noise Source Definitions**
**Code**:  
Ref_PN_Freq = [10e3 30e3 100e3 1e6 3e6 10e6]; % Hz  
Ref_PN_Level = [-140 -140 -140 -140 -140 -140] - 20; % dBc/Hz  
CP_PN_Freq = [10e3 30e3 100e3 1e6 3e6 10e6]; % Hz  
CP_PN_Level = [-224 -229 -234 -239 -240 -241]; % dBc/Hz  
VCO_PN_Freq = VCO_PN_F; % From Parameters.m  
VCO_PN_Level = VCO_PN_L; % From Parameters.m

- **Purpose**:  
  Defines the frequency offsets and corresponding phase noise levels for the reference signal, charge pump, and voltage-controlled oscillator (VCO). The purpose of these definitions is to provide the phase noise data required to compute the overall phase noise and jitter.
- **Explanation**:  
  - **`Ref_PN_Freq`**: Frequency offsets for the reference phase noise, ranging from 10 kHz to 10 MHz.  
  - **`Ref_PN_Level`**: Phase noise levels (in dBc/Hz) corresponding to the reference signal. The noise levels are adjusted by subtracting 20 dB to simulate a specific noise profile.  
  - **`CP_PN_Freq`**: Frequency offsets for the charge pump phase noise. The offsets match those of the reference signal.  
  - **`CP_PN_Level`**: Phase noise levels (in dBc/Hz) corresponding to the charge pump.  
  - **`VCO_PN_Freq`**: Frequency offsets for the VCO phase noise, imported from **Parameters.m**.  
  - **`VCO_PN_Level`**: Phase noise levels for the VCO, also imported from **Parameters.m**.

---

### **3. Frequency Range for Analysis**
**Code**:  
freqv = logspace(log10(min(VCO_PN_Freq)), log10(max(VCO_PN_Freq)), 500);

- **Purpose**:  
  Creates a logarithmic frequency vector (`freqv`) to be used in the phase noise analysis. The frequency vector spans from the minimum to the maximum values of the VCO phase noise frequencies (`VCO_PN_Freq`) and contains 500 points for detailed analysis.
- **Explanation**:  
  - **`logspace(log10(min(VCO_PN_Freq)), log10(max(VCO_PN_Freq)), 500)`**: Generates 500 logarithmically spaced points between the minimum and maximum VCO frequency offsets, which allows for high-resolution phase noise analysis across a wide frequency range.

---

### **4. Interpolate Noise Profiles**
**Code**:  
Ref_Phase_Noise_dB = interp1(log10(Ref_PN_Freq), Ref_PN_Level, log10(freqv), 'linear')';  
CP_Phase_Noise_dB = interp1(log10(CP_PN_Freq), CP_PN_Level, log10(freqv), 'linear')';  
VCO_Phase_Noise_dB = interp1(log10(VCO_PN_Freq), VCO_PN_Level, log10(freqv), 'linear')';

- **Purpose**:  
  Interpolates the phase noise levels at the frequencies defined by `freqv` for each noise source (reference, charge pump, and VCO). This ensures that the phase noise profiles are continuous and smooth across the entire frequency range for analysis.
- **Explanation**:  
  - **`interp1`**: The MATLAB function `interp1` is used for 1-dimensional interpolation. It takes the known phase noise levels at the given frequency offsets and interpolates them at the new frequencies (`freqv`).  
  - **`log10(freqv)`**: The frequencies in `freqv` are converted to log scale to match the format of the input frequency offsets (`Ref_PN_Freq`, `CP_PN_Freq`, `VCO_PN_Freq`).  
  - The `'linear'` option ensures linear interpolation between known data points.

---

### **5. Compute Overall Phase Noise**
**Code**:  
H_REF2VCO = abs(squeeze(freqresp(CL_TF, 2*pi*freqv)));  
H_REF2VCO_dB = 20*log10(H_REF2VCO);  

PN_FROM_REF = 10.^(Ref_Phase_Noise_dB / 10) .* (H_REF2VCO.^2);  
PN_TOTAL = PN_FROM_REF; % Add other noise sources if needed.

- **Purpose**:  
  Computes the total phase noise contribution from the reference signal.
- **Explanation**:  
  - **`freqresp(CL_TF, 2*pi*freqv)`**: Computes the frequency response of the closed-loop transfer function (`CL_TF`) at the frequencies defined by `freqv`. The `2*pi*freqv` converts the frequencies to angular form.  
  - **`H_REF2VCO`**: Represents the frequency response magnitude from the reference to the VCO in the system.  
  - **`H_REF2VCO_dB`**: Converts the frequency response to decibels (dB).  
  - **`PN_FROM_REF`**: Computes the phase noise contribution from the reference signal by scaling the phase noise levels (`Ref_Phase_Noise_dB`) according to the transfer function response.  
  - **`PN_TOTAL`**: Currently includes phase noise from the reference signal only. This can be extended to include contributions from other sources like the charge pump and VCO.

---

### **6. Plot Results - Phase Noise Spectrum**
**Code**:  
figure('Name', 'Phase Noise Spectrum', 'NumberTitle', 'off');  
semilogx(freqv, 10*log10(PN_TOTAL), 'k', 'LineWidth', 2);  
xlabel('Frequency (Hz)');  
ylabel('Phase Noise (dBc/Hz)');  
title('Overall Phase Noise Spectrum');  
grid on;

- **Purpose**:  
  Generates a logarithmic plot of the overall phase noise spectrum, visualizing how the phase noise varies with frequency.
- **Explanation**:  
  - **`semilogx`**: Creates a semilogarithmic plot, where the x-axis is logarithmic and the y-axis is linear. This is useful for visualizing phase noise across a wide frequency range.  
  - **`10*log10(PN_TOTAL)`**: Converts the phase noise to decibels (dBc/Hz) for plotting.

---

### **7. Plot Results - Step Response**
**Code**:  
figure('Name', 'Step Response', 'NumberTitle', 'off');  
plot(t, y);  
xlabel('Time (s)');  
ylabel('Amplitude');  
title('Step Response: Closed-Loop Transfer Function');  
grid on;

- **Purpose**:  
  Plots the step response of the closed-loop transfer function (`CL_TF`) to visualize the time-domain behavior of the system.

---

### **8. Plot Results - Open-Loop Magnitude Response**
**Code**:  
figure('Name', 'Open-Loop Magnitude Response', 'NumberTitle', 'off');  
semilogx(w/(2*pi), mag_dB);  
xlabel('Frequency (Hz)');  
ylabel('Magnitude (dB)');  
title('Open-Loop Frequency Response');  
grid on;

- **Purpose**:  
  Plots the open-loop magnitude response in decibels, showing how the system's gain varies with frequency.

---

### **9. Compute RMS Jitter**
**Code**:  
disp('Computing RMS jitter...');  
RMS_Jitter = (1 / (2*pi*N*Fref)) * sqrt(2 * trapz(freqv, 10.^(10*log10(PN_TOTAL) / 10)));  
disp(['RMS Jitter = ', num2str(RMS_Jitter * 1e12), ' ps']);

- **Purpose**:  
  Computes the root mean square (RMS) jitter from the total phase noise.
- **Explanation**:  
  - **`trapz`**: Performs numerical integration using the trapezoidal rule over the frequency vector (`freqv`) to compute the phase noise integral.  
  - **`RMS_Jitter`**: The RMS jitter is computed from the integrated phase noise using the formula for jitter. The result is scaled to picoseconds.

---

This concludes the line-by-line explanation for **Analysis.m**. Let me know if you need further modifications or details!
