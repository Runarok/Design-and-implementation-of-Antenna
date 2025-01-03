% Open a new Simulink model
modelName = 'Antenna_Phase_Noise_Reduction';
open_system(new_system(modelName));

% Add Oscillator with Phase Noise Block
oscillator = add_block('simulink/Sources/Sine Wave', [modelName, '/Oscillator']);
set_param(oscillator, 'Amplitude', '1', 'Frequency', '1e6', 'SampleTime', '1e-6');

% Add Phase Noise to Oscillator
noiseBlock = add_block('simulink/Signal Attributes/Noise', [modelName, '/Phase Noise']);
set_param(noiseBlock, 'NoisePower', '1e-3'); % Adjust for phase noise intensity

% Add Phase-Locked Loop (PLL)
pll = add_block('simulink/Signal Processing/Phase-Locked Loop (PLL)', [modelName, '/PLL']);
set_param(pll, 'NaturalFrequency', '1e3', 'DampingFactor', '0.707');

% Connect Oscillator to Phase Noise
add_line(modelName, 'Oscillator/1', 'Phase Noise/1');

% Connect Phase Noise to PLL
add_line(modelName, 'Phase Noise/1', 'PLL/1');

% Configure Output Display
scope = add_block('simulink/Sinks/Scope', [modelName, '/Scope']);
add_line(modelName, 'PLL/1', 'Scope/1');

% Run Simulation and Plot Results
simOut = sim(modelName, 'StopTime', '0.01');

% Plot the Output in MATLAB
simData = simOut.get('ScopeData');
time = simData.time;
signal = simData.signals.values;
plot(time, signal);
title('Phase Noise Reduction in Antenna Oscillator Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;
