function [girf_k,girf_ph,time,nom] = GIRF(MR,pathgirf,varargin)
%Process gradient waveform with zeroth and first order impulse response
% functions. Note that the module is not perfect yet regarding orientations
% such as readout direction etc. It needs the reconframe object as input
% and girf.mat should be included in your path.
%    
% Output: 
%     - girf_k is the UNSCALED k-space trajectory
%     - ph_ec is the phase error on each adc point in RADIANS
%
%
% Version: 20171110 
% Author: Tom Bruijnen
% Contact: t.bruijnen@umcutrecht.nl

% Get waveform 
[time,nom,adc]=reconframe_2_waveform(MR);

% Load girfs
load(pathgirf)

% Apply girfs
[cwf,b0_ec,ph_ec]=applyGIRF(time,nom,girf);

% Resample the phase error to the adc points
for ech=1:numel(adc);girf_ph{ech}=interp1(time,ph_ec,adc{ech});end

% Transform waveform to k-space trajectory per axis
for ech=1:numel(adc);girf_k{ech}=interp1(time,cumsum(cwf),adc{ech});end

% Transform waveform to k-space trajectory per axis for nominal case
for ech=1:numel(adc);nom_k{ech}=interp1(time,cumsum(nom),adc{ech});end

% GIRF introduces a 1 sample delay somewhere - still have to solve this
for ech=1:numel(adc);girf_k{ech}(1:end-1,:)=girf_k{ech}(2:end,:);end
for ech=1:numel(adc);girf_ph{ech}(1:end-1,:)=girf_ph{ech}(2:end,:);end

% Scale to k-space between -.5 and .5
for ech=1:numel(adc);
    for ax=1:3;
        tmp=girf_k{ech}(:,ax);
        girf_k{ech}(:,ax)=.5*tmp/max(abs(tmp(:)));
        tmp=nom_k{ech}(:,ax);
        nom_k{ech}(:,ax)=.5*tmp/max(abs(tmp(:)));
    end
end

disp('+Gradient impulse response loaded and processed.')
% Visualization
if nargin > 2
    %adc{1}=(0.357:0.001:0.82)*10^-3;
    figure,subplot(221);plot(10^3*time,10^3*nom(:,1),'g','LineWidth',2);hold on;
    plot(10^3*time,10^3*nom(:,2),'k','LineWidth',2);plot(10^3*time,10^3*nom(:,3),'b','LineWidth',2);
    scatter(10^3*adc{1},zeros(size(adc{1})),25,'r');plot(10^3*time,10^3*cwf(:,1),'g--','LineWidth',2);legend('X','Y','Z','ADC');
    plot(10^3*time,10^3*cwf(:,2),'k--','LineWidth',2);plot(10^3*time,10^3*cwf(:,3),'b--','LineWidth',2);
    xlabel('Time [ms]');ylabel('G_{str} [mT/m]');title('Gradient waveforms');grid on;box on;
    axis([time(1)*1E+03 time(end)*1E+03 -25 25]);set(gca,'LineWidth',2,'FontSize',14,'FontWeight','bold');    
  
    subplot(222);plot(abs(nom_k{1}(:,1)),'g','LineWidth',2);hold on;plot(abs(nom_k{1}(:,2)),'k','LineWidth',2);
    plot(abs(nom_k{1}(:,3)),'b','LineWidth',2);plot(abs(girf_k{1}(:,1)),'g--','LineWidth',2);axis([0 numel(adc{1}) 0 .5])
    plot(abs(girf_k{1}(:,2)),'k--','LineWidth',2);plot(abs(girf_k{1}(:,3)),'b--','LineWidth',2);grid on;box on;
    xlabel('Sample #');ylabel('K');legend('M','P','S');title('K-space');set(gca,'LineWidth',2,'FontSize',14,'FontWeight','bold');    
    
    subplot(223);plot(10^3*time,180/pi*ph_ec(:,1),'g','LineWidth',2);hold on;
    plot(10^3*time,180/pi*ph_ec(:,2),'k','LineWidth',2);plot(10^3*time,180/pi*ph_ec(:,3),'b','LineWidth',2);
    xlabel('Time [ms]');ylabel('Phase error [deg]');title('B0 eddy currents');grid on;box on;
    axis([time(1)*1E+03 time(end)*1E+03 -100 100]);set(gca,'LineWidth',2,'FontSize',14,'FontWeight','bold');    
          
    subplot(224);plot(10^3*time,180/pi*b0_ec(:,1),'g','LineWidth',2);hold on;
    plot(10^3*time,180/pi*b0_ec(:,2),'k','LineWidth',2);plot(10^3*time,180/pi*b0_ec(:,3),'b','LineWidth',2);
    xlabel('Time [ms]');ylabel('dB0 [Hz]');title('B0 eddy currents');grid on;box on;legend('X','Y','Z','ADC');
    axis([time(1)*1E+03 time(end)*1E+03 -1000 1000]);set(gca,'LineWidth',2,'FontSize',14,'FontWeight','bold');    
    
    set(gcf,'Color','w')
    drawnow;
end
% END
end
