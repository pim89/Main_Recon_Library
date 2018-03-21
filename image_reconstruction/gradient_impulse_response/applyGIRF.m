function [cwf,b0_ec,ph_ec] = applyGIRF(t,nom,girf)
%Apply girfs on nominal waveform and return corrected waveform and B0
% modulations.
% Everything is in seconds and T/m/s
%    
% Version: 20171110 
% Author: Tom Bruijnen
% Contact: t.bruijnen@umcutrecht.nl

% Zeropad nominal waveform and time vector with 5 ms on both sides
dt=abs(t(2)-t(1));
%t_zp=-2E-03:dt:10E-03+t(end)-dt;
t_zp=0:dt:10E-03+t(end)-dt;
zp=round(5E-03/dt);
nom_zp=zeros(numel(t_zp),3);
nom_zp(zp+1:zp+numel(t),:)=nom;

% Fourier transform the zeropadded waveform
F_nom=ifftshift(fft(fftshift(nom_zp,1),[],1),1);

% Generate frequency vector of nominal waveform
df = 1/dt/numel(t_zp);
f_nom = df*(0:numel(t_zp)-1);
f_nom = f_nom-df*ceil((numel(t_zp)-1)/2); 

% Resample the GIRFs to the nominal waveform frequencies
for ax=1:3
    g0(:,ax)=interp1(girf.freq0,girf.girf0(:,ax),f_nom);g0(isnan(g0))=0;
    g1(:,ax)=interp1(girf.freq1,girf.girf1(:,ax),f_nom);g1(isnan(g1))=0;
end

% Apply GIRFs
F_b0=F_nom.*g0;
F_cwf=F_nom.*g1;

% Translate zeroth order to B0 modulations and to phase errors
b0_ec_zp=real(fftshift(ifft(fftshift(F_b0,1),[],1),1));
ph_ec_zp=360*(t_zp(2)-t_zp(1))*cumsum(b0_ec_zp);

% Apply first order to gradient waveform
cwf_zp=real(fftshift(ifft(fftshift(F_cwf,1),[],1),1));

% Remove zero paddings
for ax=1:3
    cwf(:,ax)=interp1(t_zp,cwf_zp(:,ax),t+5E-03);
    b0_ec(:,ax)=interp1(t_zp,b0_ec_zp(:,ax),t+5E-03);
    ph_ec(:,ax)=interp1(t_zp,ph_ec_zp(:,ax),t+5E-03);
end

% END
end