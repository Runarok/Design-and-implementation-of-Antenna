
%% Parameters.m: Define system parameters and transfer functions for antenna simulation.

% Including offsetting 2*pi factors in Kp and Kvw for completeness.
Kp = 1/(2*pi);
Kvf = 100e6; % Hz/volt
Kvw = 2*pi*Kvf; % (rad/sec)/volt
Kc = 5e-3;
N = 70; 
Fref = 30e6;
HoldOff = 10e-6;

% VCO Phase Noise Settings: ONLY USED IN TIME-DOMAIN MODEL.
VCO_PN_F = [10e3 30e3 100e3 1e6 3e6 10e6]; % offset in Hz.
VCO_PN_L = [-75 -90 -106 -132 -143 -152];  % dBc/Hz.

% Phase Noise Measurement Settings (Spectrum-based Measurement).
OSR = 4;  % Oversampling rate.
RBW2 = 100e3;
dF = RBW2/2; % Choosing dF a little smaller than RBW.
nFFTout = round(OSR*N*Fref/dF); % FFT size for PLL output.
Navg = 2; % Desired number of averages.
OverlapFactor = 0.9; % Overlap factor for FFT processing.
Fs = OSR*N*Fref; % Sample rate.

% The remaining block to specify is the loop filter.
% Assume a 3rd-order passive loop filter. Derive its transfer function.
LoopBW = 2e6; % PLL loop BW.
PM = 45; % Phase margin in degrees.
[C1, C2, C3, R2, R3] = thirdOrderPassiveFilterDesign(LoopBW, PM, Kc, Kvf, N);

% S-domain loop filter transfer function.
s = tf('s');
tf_lf = (C2*R2*s + 1)/...
        (C1*s + C2*s + C3*s + ...
         C1*C2*R2*s^2 + C1*C3*R3*s^2 + C2*C3*R2*s^2 + C2*C3*R3*s^2 + ...
         C1*C2*C3*R2*R3*s^3);

% PFD and CP transfer function.
num = Kp*Kc;
den = 1;
tf_pd = tf(num, den);

% VCO model.
num = Kvw;
den = [1, 0];
tf_vco = tf(num, den);

% Divider model.
num = 1/N;
den = 1;
tf_div = tf(num, den);

% Overall Transfer Functions.
FWD_GAIN = tf_pd * tf_lf * tf_vco;
OL_GAIN = FWD_GAIN * tf_div;
CL_TF = feedback(FWD_GAIN, tf_div);

disp('Parameters loaded successfully.');
