%
model_name = gcs;

% noise injection inputs 
ios(1) = linio([model_name,'/Ref_PN'],1,'in');
ios(2) = linio([model_name,'/CP_PN'],1,'in');
ios(3) = linio([model_name,'/LF/R2_noise'],1,'in');
ios(4) = linio([model_name,'/LF/R3_noise'],1,'in');
ios(5) = linio([model_name,'/VCO_PN'],1,'in');

% VCO output 
ios(6) = linio([model_name,'/Inject_3'],1,'out');             % maps to output 1

%% Linearize the model
sys = linearize(model_name,ios);

%% Define Phase Noise for Freq Reference and VCO 
Ref_PN_Freq   =  [10e3 30e3 100e3 1e6 3e6 10e6]; % Hz
Ref_PN_Level  =  [-140 -140 -140 -140 -140 -140]-20; % dBc/Hz
CP_PN_Freq   =  [10e3 30e3 100e3 1e6 3e6 10e6]; % Hz
CP_PN_Level  =  [-224 -229 -234 -239 -240 -241]; % dBc/Hz
VCO_PN_Freq    = [10e3 30e3 100e3 1e6 3e6 10e6]; % offset in Hz
VCO_PN_Level    = [-75 -90 -106 -132 -143 -152];  % dBc/Hz

%% Use PN frequencies to determine frequency range of interest
fmin=min([VCO_PN_Freq,Ref_PN_Freq]);
fmax=max([VCO_PN_Freq,Ref_PN_Freq]);
Npts=500; % number of frequency points
freqv=logspace(log10(fmin),log10(fmax),Npts); % frequency vector
% Interpolate the measured phase noise profiles over freqv
% The spline produces a nicer curve and it goes all the way to fmax
Interp_Type='linear'; % 'linear' or 'spline'
% Interp_Type='linear'; % but you can use linear as well. 
Ref_Phase_Noise_dB = interp1(log10(Ref_PN_Freq),Ref_PN_Level,log10(freqv),Interp_Type)';
CP_Phase_Noise_dB = interp1(log10(CP_PN_Freq),CP_PN_Level,log10(freqv),Interp_Type)';
VCO_Phase_Noise_dB = interp1(log10(VCO_PN_Freq),VCO_PN_Level,log10(freqv),Interp_Type)';

%% Noise Inputs
REF_PN      = 1;
CP_PN       = 2;
R2_NOISE    = 3;
R3_NOISE    = 4;
VCO_PN      = 5;      
OPEN_LOOP   = 6;    
% outputs 
CL_RESP  = 1;    % VCO_out signal in model
OL_RESP  = 2;    % OL_out signal in model

%% Xfer functions
H_REF2VCO     = abs(squeeze(freqresp(sys(CL_RESP,REF_PN),2*pi*freqv)));
H_REF2VCO_dB  = 20*log10(H_REF2VCO);
H_CP2VCO      = abs(squeeze(freqresp(sys(CL_RESP,CP_PN),2*pi*freqv)));  
H_CP2VCO_dB   = 20*log10(H_CP2VCO);
H_VCO2VCO     = abs(squeeze(freqresp(sys(CL_RESP,VCO_PN),2*pi*freqv)));  
H_VCO2VCO_dB  = 20*log10(H_VCO2VCO);
% Resistor Noise Transfer Functions
GR2 = abs(squeeze(freqresp(sys(CL_RESP,R2_NOISE),2*pi*freqv)));
GR3 = abs(squeeze(freqresp(sys(CL_RESP,R3_NOISE),2*pi*freqv)));
GR2_dB = 20*log10(GR2);
GR3_dB = 20*log10(GR3);
%% Plot the individual transfer functions here
figure;
semilogx(freqv,H_REF2VCO_dB,'r',...
    freqv,H_CP2VCO_dB,'g',...
    freqv,H_VCO2VCO_dB,'b',...
    freqv,GR2_dB,'c',...
    freqv,GR3_dB,'m');
title('PLL Noise XFER functions from stated block to VCO Out');
xlabel('Hz'); ylabel('dB');grid on;
legend('REF to OUT','CP to OUT','VCO to VCO','R2 to OUT','R3 to OUT');

%% Compute overall phase noise
% convert dB units to linear power units because we must ADD the individual
% contributations to form the overall phase noise
PREF_PN = 10.^((Ref_Phase_Noise_dB/10));  % power in REF phase noise
PCP_PN = 10.^((CP_Phase_Noise_dB/10));  % power in CP phase noise      
PVCO_PN = 10.^((VCO_Phase_Noise_dB/10));  % power in VCO phase noise      
%  multiply by various xfer^2 terms and sum, multiply by 2 for single-sided PSD   
PN_FROM_REF = 2*PREF_PN.*((H_REF2VCO).^2);
PN_FROM_REF_dB = 10*log10(PN_FROM_REF);
PN_FROM_CP = 2*PCP_PN.*((H_CP2VCO).^2);
PN_FROM_CP_dB = 10*log10(PN_FROM_CP);
PN_FROM_VCO = 2*PVCO_PN.*((H_VCO2VCO).^2);
PN_FROM_VCO_dB = 10*log10(PN_FROM_VCO);
Kb     = 1.38e-23; % Boltzmans constant in (Joules/Kelvin)
T      = 298; % default room temp around 300;      % Temperature in Kelvin
% SSB noise factor = 2*Kb*T or 4*Kb*T? 
PN_FROM_LF   = 4*Kb*T*(R2*(GR2.^2) + R3*(GR3.^2)); 
PN_FROM_LF_dB = 10*log10(PN_FROM_LF);
PN_TOTAL = PN_FROM_REF + PN_FROM_CP + PN_FROM_VCO + PN_FROM_LF;
% back to dB
PN_TOTAL_dB = 10*log10(PN_TOTAL);

%% Visualize
figure('position',[40 40 800 600],'NumberTitle','off','Name','Phase Noise')
semilogx(freqv,PN_TOTAL_dB,'color',[0 0 0],'LineWidth',2);
ylabel('dBc/Hz'); xlabel('Hz'), title('PLL Phase Noise Analysis')
hold on
semilogx(freqv,PN_FROM_REF_dB,'r','LineWidth',1,'LineStyle','--');
semilogx(freqv,PN_FROM_CP_dB,'g','LineWidth',1,'LineStyle','--');
semilogx(freqv,PN_FROM_VCO_dB,'b','LineWidth',1,'LineStyle','--');
semilogx(freqv,PN_FROM_LF_dB,'c','LineWidth',1,'LineStyle','--');
legend('Total PN Level',...
       'PN from REF',...
       'PN from CP',...
       'PN from VCO',...
       'PN from LF');
grid on;
hold off

% Compute RMS jitter see http://www.maxim-ic.com/app-notes/index.mvp/id/3359
% equation 13
RMS_Jitter=(1/(2*pi*N*Fref))*sqrt(2*trapz(freqv,10.^(PN_TOTAL_dB/10)));
%ht6=text(tleft,0.6,sprintf('RMS Jitter      = %5.2f ps ',RMS_Jitter_1*1e12));
%set(ht6,'FontSize',12,'FontWeight','Bold'); 
title(['Phase Noise Plots, RMS Jitter (ps) = ',num2str(RMS_Jitter*1e12)]);


%% PN Target for use with MSB PN Measurement block
Fc = N*Fref;
m = .999;
for k = 1:length(VCO_PN_Freq);
    idx(k) = min(find(freqv >=  m*VCO_PN_Freq(k)));
    % rounding predictions to nearest dB, can optionally maintain more
    % precision. % T (target) contains predicted phase noise levels at the 
    % specified frequencies
    T(k) = round(PN_TOTAL_dB(idx(k))); 
end 

% save phase noise prediction for future comparison. 
save('Predicted_Phase_Noise','PN_TOTAL_dB','T','freqv','Ref_PN_Level','Ref_PN_Freq','VCO_PN_Level','VCO_PN_Freq');
% DONE
