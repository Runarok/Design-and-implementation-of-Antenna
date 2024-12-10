%% including offseting 2*pi factors in Kp and Kvw for completeness
% but typically you would omit these cancelling 2*pi terms.
Kp      = 1/(2*pi);
Kvf     = 100e6; % Hz/volt
Kvw     = 2*pi*Kvf; % (rad/sec)/volt
Kc     = 5e-3;
N       = 70; 
Fref    = 30e6;
HoldOff = 10e-6;
%% VCO Phase Noise Settings: ONLY USED IN TIME-DOMAIN MODEL
VCO_PN_F   = [10e3 30e3 100e3 1e6 3e6 10e6]; % offset in Hz
VCO_PN_L    = [-75 -90 -106 -132 -143 -152];  % dBc/Hz
%% Phase Noise Measurement Settings: using ZC-based measurement
RBW = 7.5e3;
Navg = 1;
HoldOff = 10e-6;
%% Phase Noise Measurement Settings: using spectrum-based measurement
OSR = 4;  % oversampling rate  
RBW2 = 100e3;
dF = RBW2/2; % choosing dF a little smaller than RBW
nFFTout = round(OSR*N*Fref/dF); % FFT size for PLL output        
Navg = 2; % desired number of averages
OverlapFactor = 0.9; % overlap factor for FFT processing
Fs = OSR*N*Fref; % sample rate
%StopTime = (nFFTout + (Navg+1)*nFFTout*(1-OverlapFactor))/Fs + HoldOff;
%% The last remaining block to be specified is the loop filter.
% Here we assume a 3rd order passive loop filter architecture. Derive said its 
% transfer function symbollically
syms V1 V2 s I TF
R2 = sym('R2',{'real','positive'});
R3 = sym('R3',{'real','positive'});
C1 = sym('C1',{'real','positive'});
C2 = sym('C2',{'real','positive'});
C3 = sym('C3',{'real','positive'});
eqn1 = I == V1*C1*s + V1/(R2 + 1/(C2*s)) + (V1 - V2)/R3
eqn2 = (V1-V2)/R3 == V2*C3*s
eqn3 = TF == V2/I;
result = solve([eqn1,eqn2,eqn3],TF,I,V2);
disp('Symbolic Loop Filter Transfer Function');
TF = collect(result.TF,s)
TF_poles = poles(TF);   % a very long expression, 56 terms!
TF_zeros = poles(1/TF); % short and sweet
nzeros = length(TF_zeros)
npoles = length(TF_poles)
%% Option 1: Assume the loop filter circuit components are specified or
% we have a method to compute them. Here is one method that comes with MSB. 
% We'll revisit the loop filter design process later.
LoopBW  = 2e6; % PLL loop BW
PM      = 45; % phase margin in degrees
[C1,C2,C3,R2,R3] = thirdOrderPassiveFilterDesign(LoopBW,PM,Kc,Kvf,N)
R2 = sym(R2);
R3 = sym(R3);
C1 = sym(C1);
C2 = sym(C2);
C3 = sym(C3);
% back substitute circuit values into all-symbolic TF
TF = vpa(subs(TF),4)
[n,d] = numden(TF);
n = sym2poly(n);
d = sym2poly(d);
TF = tf(n,d); % for use with Control System TB or in Simulink
[z,p,k] = tf2zp(n,d);
%% Describe the PLL as a control system in Laplace domain
%% 1. PFD and CP
num=Kp*Kc;
den=1;
tf_pd=tf(num,den);
Tpd     = 100e-12;
set(tf_pd,'ioDelay',Tpd);
%% 2. Loop Filter
s = tf('s');
% rederive components or copy from above
[C1,C2,C3,R2,R3] = thirdOrderPassiveFilterDesign(LoopBW,PM,Kc,Kvf,N);
% s-domain xfer function manually copied from symbolic TF above
tf_lf = (C2*R2*s + 1)/...
    (C1*s + C2*s + C3*s + ...
    C1*C2*R2*s^2 + C1*C3*R3*s^2 + C2*C3*R2*s^2 + C2*C3*R3*s^2 + ...
    C1*C2*C3*R2*R3*s^3);
%% 3. VCO model
num=Kvw;   
den=[1,0];
tf_vco = tf(num,den);
%% 4. Divider
num = 1/N;
den = 1;
tf_div = tf(num,den);
%controlSystemDesigner(G,C,H);
%% Describe Reference to VCO output transfer function
FWD_GAIN = tf_pd*tf_lf*tf_vco;
OL_GAIN = FWD_GAIN*tf_div;
CL_TF = feedback(FWD_GAIN,tf_div);
%controlSystemDesigner(tf_pd*tf_vco,tf_lf,tf_div);
%%
if exist('PLOT_ON')
    if PLOT_ON
%%
        w = linspace(0,2*pi*1000e6,100000);
        [mag,phz,wout] = bode(OL_GAIN,w);
        mag_dB = 20*log10(abs(squeeze(mag)));
        figure(10);subplot(211);semilogx(wout/(2*pi),mag_dB);
        set(gca,'Ylim',[min(mag_dB) max(mag_dB)+10]);
        xlabel('Hz');ylabel('dB');grid on;
        title('OL Magnitude response');
        %phz = phz - phz(1);  % force relative phase to zero at DC
        subplot(212);semilogx(wout/(2*pi),squeeze(phz));
        xlabel('Hz');ylabel('degrees'); grid on;
        title('OL Phase response (including divider)');
%%
        [~,PM,~,PMf] = margin(OL_GAIN);
        disp(['Phase Margin (degrees) = ',num2str(PM)]);
        disp(['@ frequency (Hz) = ',sprintf('%7.4g',PMf/(2*pi))]);
%%
        w = linspace(10,2*pi*1000e6,1000);
        [mag,phz,wout] = bode(CL_TF,w);
        mag_dB = 20*log10(abs(squeeze(2*mag)));
        figure(11);subplot(211);semilogx(wout/(2*pi),mag_dB);
        set(gca,'Ylim',[min(mag_dB) max(mag_dB)+10]);
        xlabel('Hz');ylabel('dB');grid on;
        title('CL Magnitude response');
        phz = phz - phz(1);  % force relative phase to zero at DC
        subplot(212);semilogx(wout/(2*pi),unwrap(squeeze(phz)));
        xlabel('Hz');ylabel('degrees'); grid on;
        title('CL Phase response: REF to VCOout');
%%
        [y,t] = step(CL_TF,10e-6);
        figure(12);plot(t,y);grid
        title('STEP RESPONSE: REF to VCOout ');
        xlabel('seconds')
    end
end
%% Option 2: Derive loop filter components interactively using
% controlSystemDesigner, very flexible but tedious
%sisotool(G,C,H);   %