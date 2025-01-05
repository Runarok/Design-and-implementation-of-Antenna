%% analysis.m: Analyze results from Parameters.m and implementation.m.

% Load parameters and simulation results
run('Parameters.m');
load('Implementation_Results.mat');

% Noise source definitions (example data provided, adapt as needed)
Ref_PN_Freq = [10e3 30e3 100e3 1e6 3e6 10e6]; % Hz
Ref_PN_Level = [-140 -140 -140 -140 -140 -140] - 20; % dBc/Hz
CP_PN_Freq = [10e3 30e3 100e3 1e6 3e6 10e6]; % Hz
CP_PN_Level = [-224 -229 -234 -239 -240 -241]; % dBc/Hz
VCO_PN_Freq = VCO_PN_F; % From Parameters.m
VCO_PN_Level = VCO_PN_L; % From Parameters.m

% Frequency range for analysis
freqv = logspace(log10(min(VCO_PN_Freq)), log10(max(VCO_PN_Freq)), 500);

% Interpolate noise profiles for better analysis
Ref_Phase_Noise_dB = interp1(log10(Ref_PN_Freq), Ref_PN_Level, log10(freqv), 'linear')';
CP_Phase_Noise_dB = interp1(log10(CP_PN_Freq), CP_PN_Level, log10(freqv), 'linear')';
VCO_Phase_Noise_dB = interp1(log10(VCO_PN_Freq), VCO_PN_Level, log10(freqv), 'linear')';

% Compute overall phase noise
H_REF2VCO = abs(squeeze(freqresp(CL_TF, 2*pi*freqv)));
H_REF2VCO_dB = 20*log10(H_REF2VCO);

PN_FROM_REF = 10.^(Ref_Phase_Noise_dB / 10) .* (H_REF2VCO.^2);
PN_TOTAL = PN_FROM_REF; % Add other noise sources if needed.

% Plot results
figure('Name', 'Phase Noise Spectrum', 'NumberTitle', 'off');
semilogx(freqv, 10*log10(PN_TOTAL), 'k', 'LineWidth', 2);
xlabel('Frequency (Hz)');
ylabel('Phase Noise (dBc/Hz)');
title('Overall Phase Noise Spectrum');
grid on;

figure('Name', 'Step Response', 'NumberTitle', 'off');
plot(t, y);
xlabel('Time (s)');
ylabel('Amplitude');
title('Step Response: Closed-Loop Transfer Function');
grid on;

figure('Name', 'Open-Loop Magnitude Response', 'NumberTitle', 'off');
semilogx(w/(2*pi), mag_dB);
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Open-Loop Frequency Response');
grid on;

% Compute RMS jitter
disp('Computing RMS jitter...');
RMS_Jitter = (1 / (2*pi*N*Fref)) * sqrt(2 * trapz(freqv, 10.^(10*log10(PN_TOTAL) / 10)));
disp(['RMS Jitter = ', num2str(RMS_Jitter * 1e12), ' ps']);
