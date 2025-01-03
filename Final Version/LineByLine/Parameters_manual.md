# Parameters.m - Line-by-Line Analysis and Manual Calculations

This document provides a detailed line-by-line explanation of the code in `Parameters.m`. For each line, the code is shown, followed by its purpose, manual calculation (if applicable), and any additional information.

---

## **Line-by-Line Explanation**

### **1. Proportional Gain (Kp)**
**Code**:  
Kp = 1/(2*pi);  

- **Purpose**:  
  Defines the proportional gain used in the Phase Frequency Detector (PFD).  

- **Manual Calculation**:  
  Kp = 1 / (2 × 3.1416) ≈ 0.1592 (unitless).  

---

### **2. Frequency-to-Voltage Constant (Kvf)**
**Code**:  
Kvf = 100e6; % Hz/volt  

- **Purpose**:  
  Specifies the frequency-to-voltage constant for the Voltage-Controlled Oscillator (VCO).  

- **Value**:  
  Kvf = 100 × 10^6 = 100,000,000 Hz/volt.  

---

### **3. Angular Frequency-to-Voltage Constant (Kvw)**
**Code**:  
Kvw = 2*pi*Kvf; % (rad/sec)/volt  

- **Purpose**:  
  Converts the frequency-to-voltage constant (**Kvf**) to angular units (rad/sec/volt).  

- **Manual Calculation**:  
  Kvw = 2 × 3.1416 × 100,000,000 ≈ 628,318,530.72 (rad/sec)/volt.  

---

### **4. Charge Pump Current (Kc)**
**Code**:  
Kc = 5e-3;  

- **Purpose**:  
  Specifies the charge pump current in the PLL loop.  

- **Value**:  
  Kc = 5 × 10^-3 = 0.005 Amps.  

---

### **5. Frequency Division Factor (N)**
**Code**:  
N = 70;  

- **Purpose**:  
  Defines the frequency division factor in the feedback loop of the PLL.  

- **Value**:  
  N = 70 (unitless).  

---

### **6. Reference Frequency (Fref)**
**Code**:  
Fref = 30e6;  

- **Purpose**:  
  Specifies the reference frequency for the PLL.  

- **Value**:  
  Fref = 30 × 10^6 = 30,000,000 Hz.  

---

### **7. Hold-Off Time**
**Code**:  
HoldOff = 10e-6;  

- **Purpose**:  
  Defines the hold-off time, which delays the start of the PLL operation.  

- **Value**:  
  HoldOff = 10 × 10^-6 = 10 microseconds.  

---

### **8. VCO Phase Noise Offsets**
**Code**:  
VCO_PN_F = [10e3 30e3 100e3 1e6 3e6 10e6];  

- **Purpose**:  
  Specifies the frequency offsets (in Hz) used for phase noise analysis of the VCO.  

- **Values**:  
  VCO_PN_F = [10,000 Hz, 30,000 Hz, 100,000 Hz, 1,000,000 Hz, 3,000,000 Hz, 10,000,000 Hz].  

---

### **9. VCO Phase Noise Levels**
**Code**:  
VCO_PN_L = [-75 -90 -106 -132 -143 -152];  

- **Purpose**:  
  Specifies the phase noise levels (in dBc/Hz) corresponding to the offsets in **VCO_PN_F**.  

---

### **10. Oversampling Rate (OSR)**
**Code**:  
OSR = 4;  

- **Purpose**:  
  Defines the oversampling rate for spectrum-based phase noise measurement.  

---

### **11. Resolution Bandwidth (RBW2)**
**Code**:  
RBW2 = 100e3;  

- **Purpose**:  
  Specifies the resolution bandwidth for phase noise measurement.  

- **Value**:  
  RBW2 = 100 × 10^3 = 100,000 Hz.  

---

### **12. Frequency Resolution (dF)**
**Code**:  
dF = RBW2/2;  

- **Purpose**:  
  Calculates the frequency resolution (in Hz).  

- **Manual Calculation**:  
  dF = 100,000 / 2 = 50,000 Hz.  

---

### **13. FFT Size (nFFTout)**
**Code**:  
nFFTout = round(OSR*N*Fref/dF);  

- **Purpose**:  
  Determines the FFT size required for spectrum analysis.  

- **Manual Calculation**:  
  nFFTout = round(4 × 70 × 30,000,000 / 50,000)  
  nFFTout = round(168,000,000 / 50,000) = 3360.  

---

### **14. Number of Averages**
**Code**:  
Navg = 2;  

- **Purpose**:  
  Specifies the desired number of averages for phase noise spectrum analysis.  

---

### **15. Overlap Factor**
**Code**:  
OverlapFactor = 0.9;  

- **Purpose**:  
  Defines the overlap factor for FFT processing during phase noise measurement.  

---

### **16. Sample Rate (Fs)**
**Code**:  
Fs = OSR*N*Fref;  

- **Purpose**:  
  Calculates the sample rate of the system.  

- **Manual Calculation**:  
  Fs = 4 × 70 × 30,000,000 = 8.4 × 10^9 Hz = 8.4 GHz.  

---

### **17. Loop Bandwidth**
**Code**:  
LoopBW = 2e6;  

- **Purpose**:  
  Specifies the loop bandwidth of the PLL (in Hz).  

---

### **18. Phase Margin (PM)**
**Code**:  
PM = 45;  

- **Purpose**:  
  Defines the phase margin (in degrees) of the PLL.  

---

### **19. Loop Filter Design**
**Code**:  
[C1, C2, C3, R2, R3] = thirdOrderPassiveFilterDesign(LoopBW, PM, Kc, Kvf, N);  

- **Purpose**:  
  Calls the custom function `thirdOrderPassiveFilterDesign` to calculate the loop filter components.  

- **Outputs**:  
  - C1, C2, C3: Capacitor values.  
  - R2, R3: Resistor values.  

---

### **20. S-Domain Variable**
**Code**:  
s = tf('s');  

- **Purpose**:  
  Creates the Laplace transform variable `s`, used for defining transfer functions in the frequency domain.  

---

### **21. Loop Filter Transfer Function**
**Code**:  
tf_lf = (C2*R2*s + 1)/...  
        (C1*s + C2*s + C3*s + ...  
         C1*C2*R2*s^2 + C1*C3*R3*s^2 + C2*C3*R2*s^2 + C2*C3*R3*s^2 + ...  
         C1*C2*C3*R2*R3*s^3);  

- **Purpose**:  
  Defines the transfer function of the 3rd-order passive loop filter.  

---

### **22. PFD and CP Transfer Function**
**Code**:  
num = Kp*Kc;  
den = 1;  
tf_pd = tf(num, den);  

- **Purpose**:  
  Defines the transfer function of the Phase Frequency Detector (PFD) and Charge Pump (CP).  

- **Manual Calculation**:  
  num = 0.1592 × 0.005 = 0.000796.  
  Transfer function: tf_pd = 0.000796.  

---

### **23. VCO Transfer Function**
**Code**:  
num = Kvw;  
den = [1, 0];  
tf_vco = tf(num, den);  

- **Purpose**:  
  Defines the transfer function of the Voltage-Controlled Oscillator (VCO).  

---

### **24. Divider Transfer Function**
**Code**:  
num = 1/N;  
den = 1;  
tf_div = tf(num, den);  

- **Purpose**:  
  Defines the transfer function of the frequency divider in the PLL feedback loop.  

- **Manual Calculation**:  
  num = 1 / 70 = 0.01429.  
  Transfer function: tf_div = 0.01429.  

---

### **25. Overall Transfer Functions**
**Code**:  
FWD_GAIN = tf_pd * tf_lf * tf_vco;  
OL_GAIN = FWD_GAIN * tf_div;  
CL_TF = feedback(FWD_GAIN, tf_div);  

- **Purpose**:  
  - **`FWD_GAIN`**: Calculates the forward gain of the system by combining the transfer functions of the PFD/CP, loop filter, and VCO.  
  - **`OL_GAIN`**: Computes the open-loop transfer function, which includes the forward gain and divider.  
  - **`CL_TF`**: Defines the closed-loop transfer function by applying feedback to the forward gain and divider.  

- **Explanation**:  
  - `FWD_GAIN = tf_pd * tf_lf * tf_vco`: The product of PFD/CP transfer function, loop filter, and VCO transfer functions represents the forward gain of the system.  
  - `OL_GAIN = FWD_GAIN * tf_div`: The open-loop gain adds the effect of the divider.  
  - `CL_TF = feedback(FWD_GAIN, tf_div)`: Applies negative feedback to the forward gain to form the closed-loop transfer function.
 
- **Manual Calculation**:  
  - The transfer function of the system is calculated step-by-step by multiplying the individual transfer functions:
    - `tf_pd` is the transfer function of the Phase Frequency Detector and Charge Pump.
    - `tf_lf` is the transfer function of the loop filter, defined by the third-order passive filter.
    - `tf_vco` is the transfer function of the Voltage-Controlled Oscillator (VCO).
    - `tf_div` represents the divider in the feedback loop.
    
  - **`FWD_GAIN`**: The forward gain is calculated by multiplying the transfer functions:  
    `FWD_GAIN = tf_pd * tf_lf * tf_vco`.

  - **`OL_GAIN`**: The open-loop gain is calculated by multiplying the forward gain by the divider transfer function:  
    `OL_GAIN = FWD_GAIN * tf_div`.

  - **`CL_TF`**: The closed-loop transfer function is calculated by applying feedback to the open-loop gain:  
    `CL_TF = feedback(FWD_GAIN, tf_div)`.
