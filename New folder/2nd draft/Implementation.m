% implementation.m: Simulates the antenna system programmatically.

% Load parameters from Parameters.m
run('Parameters.m');

% Define Transfer Functions
% Transfer functions are already defined in Parameters.m:
% - tf_pd: PFD and charge pump.
% - tf_lf: Loop filter.
% - tf_vco: VCO.
% - tf_div: Divider.

% Forward Path and Overall System
FWD_GAIN = tf_pd * tf_lf * tf_vco;  % Forward path gain
OL_GAIN = FWD_GAIN * tf_div;        % Open-loop transfer function
CL_TF = feedback(FWD_GAIN, tf_div); % Closed-loop transfer function

% Simulate System Behavior
% Time domain simulation using step response.
disp('Simulating Step Response...');
t = linspace(0, 10e-6, 1000); % Time vector
[y, t] = step(CL_TF, t);

% Frequency domain analysis.
disp('Simulating Frequency Response...');
w = logspace(3, 9, 1000); % Frequency vector (10 Hz to 1 GHz)
[mag, phase] = bode(OL_GAIN, w);
mag_dB = 20*log10(squeeze(mag));

% Visualize Results
% Plot Step Response
figure('Name', 'Step Response', 'NumberTitle', 'off');
plot(t, y);
xlabel('Time (s)');
ylabel('Amplitude');
title('Step Response: Closed-Loop Transfer Function');
grid on;

% Plot Open-Loop Magnitude Response
figure('Name', 'Open-Loop Magnitude Response', 'NumberTitle', 'off');
semilogx(w/(2*pi), mag_dB);
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Open-Loop Frequency Response');
grid on;

% Plot Phase Response
figure('Name', 'Open-Loop Phase Response', 'NumberTitle', 'off');
semilogx(w/(2*pi), squeeze(phase));
xlabel('Frequency (Hz)');
ylabel('Phase (degrees)');
title('Open-Loop Phase Response');
grid on;

% Save Results
disp('Saving results...');
save('Implementation_Results.mat', 't', 'y', 'w', 'mag', 'phase', 'mag_dB');
disp('Simulation complete!');
