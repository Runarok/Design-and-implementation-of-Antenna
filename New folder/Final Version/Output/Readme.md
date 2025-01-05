# How to Execute the Antenna Simulation and Analysis

This document provides step-by-step instructions to run the simulation and analysis using the three provided MATLAB files.

## Steps to Execute

### 1. Download the Files
Download the following files into the same folder on your computer:
- `Parameters.m`: Defines system parameters and transfer functions.
- `implementation.m`: Simulates the system and saves results to a `.mat` file.
- `analysis.m`: Analyzes the saved results and generates plots.

### 2. Change Parameters (Optional)
1. Open `Parameters.m` in MATLAB.
2. Modify the parameters if required. For example:
   - Change the PLL loop bandwidth (`LoopBW`) or phase margin (`PM`) to test different system behaviors.
   - Adjust the VCO phase noise levels (`VCO_PN_L`) to simulate different noise conditions.

### 3. Save Parameters
If you made any changes to `Parameters.m`, save the file before proceeding:
- Go to **File > Save** or press `Ctrl+S` in MATLAB.

### 4. Execute the Implementation Script
1. Ensure all files are in the same folder.
2. Open MATLAB and execute `implementation.m`. This will:
   - Load parameters from `Parameters.m`.
   - Simulate the system (e.g., step response, frequency response).
   - Save the results to a file named `Implementation_Results.mat`.

### 5. Verify the `.mat` File
Check that the file `Implementation_Results.mat` is created in the same folder as the scripts. This file contains all the necessary data for analysis.

### 6. Execute the Analysis Script
1. Open MATLAB and execute `analysis.m`. This will:
   - Load parameters from `Parameters.m` and results from `Implementation_Results.mat`.
   - Perform detailed analysis, including phase noise and jitter computation.
   - Generate plots for system performance.

### 7. Review Outputs
- Check the MATLAB Command Window for RMS jitter values and other performance metrics.
- View the generated plots for phase noise, step response, and frequency response.

### 8. Output Explanation
For detailed examples and explanations of the outputs, refer to [output.md](./output.md) located in the same folder.

