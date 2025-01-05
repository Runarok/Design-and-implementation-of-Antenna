
%% analysis.m: Perform phase noise analysis for the antenna system.

% Load parameters from Parameters.m.
run('Parameters.m');

% Define the Simulink model name.
model_name = 'implementation';

% Noise injection inputs.
ios(1) = linio([model_name, '/Ref_PN'], 1, 'in');
ios(2) = linio([model_name, '/CP_PN'], 1, 'in');
ios(3) = linio([model_name, '/LF/R2_noise'], 1, 'in');
ios(4) = linio([model_name, '/LF/R3_noise'], 1, 'in');
ios(5) = linio([model_name, '/VCO_PN'], 1, 'in');

% VCO output.
ios(6) = linio([model_name, '/Inject_3'], 1, 'out'); % Maps to output 1.

% Linearize the model.
sys = linearize(model_name, ios);

% Perform phase noise computations.
% (The rest of the script remains unchanged.)
