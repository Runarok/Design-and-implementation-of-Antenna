# MATLAB Code Overview and Explanation

This document provides a detailed breakdown of the MATLAB code used in the project, including each MATLAB file, the functions used, and what each piece of code does with the inputs.

---

## **1. Parameters.m**

### **Functions Used**:

#### **run**
**Syntax**:  
**run('filename.m')**

**Code Used**:  
**run('Parameters.m');**

**What It Does**:  
The **run** function executes the specified script (**Parameters.m**) in the current MATLAB workspace, ensuring that all the parameters required for the simulation are loaded into the environment.

---

#### **tf**
**Syntax**:  
**s = tf('s');**  
**tf(num, den)**

**Code Used**:  
**s = tf('s');**  
**tf_vco = tf(num, den);**

**What It Does**:  
The **tf** function is used to define transfer functions in the system. The **s** represents the Laplace transform variable, and **tf(num, den)** is used to create a transfer function from the numerator (**num**) and denominator (**den**) coefficients.

---

#### **thirdOrderPassiveFilterDesign**
**Syntax**:  
**[C1, C2, C3, R2, R3] = thirdOrderPassiveFilterDesign(LoopBW, PM, Kc, Kvf, N);**

**Code Used**:  
**[C1, C2, C3, R2, R3] = thirdOrderPassiveFilterDesign(LoopBW, PM, Kc, Kvf, N);**

**What It Does**:  
This is a custom function used to design the third-order passive loop filter for the PLL. It returns the values for the filter components that are required to shape the frequency response of the PLL.

---

## **2. Implementation.m**

### **Functions Used**:

#### **run**
**Syntax**:  
**run('filename.m')**

**Code Used**:  
**run('Parameters.m');**

**What It Does**:  
The **run** function is used to load the parameters defined in **Parameters.m** into the current workspace, ensuring the system is correctly configured for the simulation.

---

#### **linspace**
**Syntax**:  
**linspace(start_value, end_value, num_points)**

**Code Used**:  
**t = linspace(0, 10e-6, 1000);**

**What It Does**:  
The **linspace** function generates a linearly spaced vector. In this case, it is used to create a time vector (**t**) that spans from 0 to 10 microseconds, with 1000 data points. This is used for simulating the step response of the system.

---

#### **step**
**Syntax**:  
**[y, t] = step(sys, t)**

**Code Used**:  
**[y, t] = step(CL_TF, t);**

**What It Does**:  
The **step** function computes the step response of the system (**CL_TF**) over the time vector (**t**). It outputs the system's response (**y**) and the time vector (**t**).

---

#### **logspace**
**Syntax**:  
**logspace(start_exp, end_exp, num_points)**

**Code Used**:  
**w = logspace(3, 9, 1000);**

**What It Does**:  
The **logspace** function generates a logarithmically spaced vector. Here, it is used to create a frequency vector (**w**) for simulating the frequency response, spanning from 10^3 Hz to 10^9 Hz (i.e., 1 kHz to 1 GHz), with 1000 data points.

---

#### **bode**
**Syntax**:  
**[mag, phase] = bode(sys, w)**

**Code Used**:  
**[mag, phase] = bode(OL_GAIN, w);**

**What It Does**:  
The **bode** function computes the magnitude (**mag**) and phase (**phase**) of the open-loop gain (**OL_GAIN**) at the specified frequencies (**w**). This is used to analyze the frequency response of the system.

---

#### **squeeze**
**Syntax**:  
**squeeze(value)**

**Code Used**:  
**mag_dB = 20*log10(squeeze(mag));**

**What It Does**:  
The **squeeze** function removes singleton dimensions from an array. This is applied to the output of **bode** to ensure the magnitude (**mag**) is in a suitable format for further calculations.

---

#### **save**
**Syntax**:  
**save('filename.mat', 'var1', 'var2', ...)**

**Code Used**:  
**save('Implementation_Results.mat', 't', 'y', 'w', 'mag', 'phase', 'mag_dB');**

**What It Does**:  
The **save** function stores the specified variables (**t**, **y**, **w**, **mag**, **phase**, **mag_dB**) in a `.mat` file (**Implementation_Results.mat**) for later analysis.

---

## **3. Analysis.m**

### **Functions Used**:

#### **run**
**Syntax**:  
**run('filename.m')**

**Code Used**:  
**run('Parameters.m');**

**What It Does**:  
The **run** function loads the parameters from **Parameters.m** to set up the system for analysis.

---

#### **load**
**Syntax**:  
**load('filename.mat')**

**Code Used**:  
**load('Implementation_Results.mat');**

**What It Does**:  
The **load** function loads the simulation results from **Implementation_Results.mat**, which were saved earlier in **Implementation.m**.

---

#### **interp1**
**Syntax**:  
**interp1(x, y, xi, method)**

**Code Used**:  
**Ref_Phase_Noise_dB = interp1(log10(Ref_PN_Freq), Ref_PN_Level, log10(freqv), 'linear')';**

**What It Does**:  
The **interp1** function performs linear interpolation of phase noise levels over the frequency range (**freqv**). It uses logarithmic values for interpolation, ensuring a smooth noise profile.

---

#### **freqresp**
**Syntax**:  
**freqresp(sys, w)**

**Code Used**:  
**H_REF2VCO = abs(squeeze(freqresp(CL_TF, 2*pi*freqv)));**

**What It Does**:  
The **freqresp** function computes the frequency response of the closed-loop transfer function (**CL_TF**) over the specified frequency range (**freqv**). The **abs** function ensures the result is non-negative.

---

#### **trapz**
**Syntax**:  
**trapz(x, y)**

**Code Used**:  
**RMS_Jitter = (1 / (2*pi*N*Fref)) * sqrt(2 * trapz(freqv, 10.^(10*log10(PN_TOTAL) / 10)));**

**What It Does**:  
The **trapz** function calculates the integral of the phase noise spectrum (**PN_TOTAL**) to compute the RMS jitter. It uses the trapezoidal rule for numerical integration.

---

#### **sqrt**
**Syntax**:  
**sqrt(value)**

**Code Used**:  
**RMS_Jitter = sqrt(2 * trapz(freqv, 10.^(10*log10(PN_TOTAL) / 10)));**

**What It Does**:  
The **sqrt** function computes the square root of the integrated phase noise spectrum, resulting in the RMS jitter value.

---

#### **disp**
**Syntax**:  
**disp(message)**

**Code Used**:  
**disp('Computing RMS jitter...');**

**What It Does**:  
The **disp** function prints the specified message in the MATLAB Command Window, allowing the user to track the progress of the analysis.

---

#### **figure**
**Syntax**:  
**figure('Name', 'Figure Name', 'NumberTitle', 'off')**

**Code Used**:  
**figure('Name', 'Phase Noise Spectrum', 'NumberTitle', 'off');**

**What It Does**:  
The **figure** function creates a new figure window for plotting. This is used to generate separate plots for each set of results.

---

#### **semilogx**
**Syntax**:  
**semilogx(x, y)**

**Code Used**:  
**semilogx(freqv, 10*log10(PN_TOTAL), 'k', 'LineWidth', 2);**

**What It Does**:  
The **semilogx** function plots data with a logarithmic x-axis. It is used here to display the phase noise spectrum, where the x-axis represents frequency.

---

#### **plot**
**Syntax**:  
**plot(x, y)**

**Code Used**:  
**plot(t, y);**

**What It Does**:  
The **plot** function creates a 2D plot with linear axes. It is used to visualize the step response over time.

---

#### **xlabel**, **ylabel**, **title**
**Syntax**:  
**xlabel('X-axis label');**  
**ylabel('Y-axis label');**  
**title('Plot title');**

**Code Used**:  
**xlabel('Frequency (Hz)');**  
**ylabel('Phase Noise (dBc/Hz)');**  
**title('Overall Phase Noise Spectrum');**

**What It Does**:  
These functions add labels to the x-axis, y-axis, and title to the plot, providing context for the visualized data.

---

#### **grid**
**Syntax**:  
**grid on**

**Code Used**:  
**grid on;**

**What It Does**:  
The **grid** function adds grid lines to the plot, improving the readability of the data.

---

This document outlines the MATLAB functions used in **Parameters.m**, **Implementation.m**, and **Analysis.m**. Each function plays a key role in the simulation, analysis, and visualization process.
