# Simulink Model for Phase Noise Reduction Using a PLL

This guide explains how to build a Simulink model that simulates phase noise in a high-frequency oscillator and reduces it using a Phase-Locked Loop (PLL).

## Steps

### Step 1: Open Simulink and Create a New Model

1. Open MATLAB and type `simulink` in the Command Window to launch Simulink.
2. Create a new blank model by selecting **Blank Model**.

---

### Step 2: Add Components to Simulate Phase Noise and Implement PLL

In this model, you’ll need the following main blocks:

- **Oscillator Block (Sine Wave Block)** - Simulates the signal from the local oscillator.
- **Phase Noise Block** - Adds phase noise to the signal.
- **Phase-Locked Loop (PLL)** - Reduces the phase noise.
- **Scope Block** - Displays the results of phase noise reduction.

---

### Step 3: Configure the Blocks

#### 1. Configure the Oscillator Block (Sine Wave)

1. In the Simulink Library Browser, go to **Sources** and find the **Sine Wave** block.
2. Drag and drop the Sine Wave block into your model.
3. Double-click the **Sine Wave** block and configure the parameters:
   - **Amplitude**: Set to `1` (or adjust based on your requirements).
   - **Frequency (rad/s)**: Set to a high frequency, for example, `1e6` (1 MHz).
   - **Sample time**: Set to `1e-6` (for high-frequency simulation).

#### 2. Add and Configure Phase Noise

To simulate phase noise, we’ll add random noise to the oscillator signal.

1. In the Library Browser, go to **Simulink > Signal Attributes** and drag the **Random Number** block into your model.
2. Set the **Random Number** block:
   - **Mean**: Set to `0`.
   - **Variance**: Set to a small value, like `1e-3`, which simulates phase noise. Adjust this value to represent different levels of phase noise.
3. Add a **Gain** block from **Simulink > Math Operations** and connect it after the **Random Number** block. Set the Gain block to adjust the phase noise effect (e.g., `0.1`).
4. Add the noise output to the **Sine Wave** block to simulate the noisy oscillator signal. Use a **Sum** block to add them together.

#### 3. Implement a Phase-Locked Loop (PLL)

1. In the Simulink Library Browser, go to **DSP System Toolbox > Signal Operations** and find the **Phase-Locked Loop (PLL)** block (or a similar PLL implementation based on your Simulink version).
2. Drag the PLL block into the model.
3. Configure the **PLL** block:
   - **Natural Frequency**: Set this to a lower value than the oscillator frequency (e.g., `1e3` or 1 kHz) for phase noise reduction.
   - **Damping Factor**: Set to `0.707` for critical damping, which helps the PLL lock onto the signal without overshoot.
4. Connect the noisy oscillator output to the **PLL** block input.

#### 4. Add Scope for Visualization

1. From the Library Browser, drag a **Scope** block from **Simulink > Sinks** into the model.
2. Connect the **PLL output** to the **Scope input** to visualize the phase noise reduction result.

---

### Step 4: Set Up and Run the Simulation

1. Set the **Simulation Stop Time** in the Simulink model (e.g., `0.01` for a short simulation).
2. Run the simulation by clicking on the **Run** button in Simulink.
3. Open the **Scope** block to view the results. You should see a cleaner signal at the PLL output compared to the input, indicating that the PLL has reduced phase noise.

---

### Step 5: Analyzing Results

Observe the following in the Scope:
- The input signal with phase noise.
- The output signal from the PLL, which should show reduced phase noise.

The phase noise reduction can be observed as the PLL output signal becomes more stable over time, filtering out the noise from the original oscillator signal.

---

This Simulink model provides a simple demonstration of using a PLL to reduce phase noise in a high-frequency oscillator. Let me know if you need additional details on any specific part of the setup!
