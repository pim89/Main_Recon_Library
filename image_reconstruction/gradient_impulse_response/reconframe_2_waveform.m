function [time,nom,adc] = reconframe_2_waveform( MR )
%Reconstruct the nominal gradient waveform from the MPF objects extracted
%using the MR.Search function in Reconframe.
%
% So far works for: EPI, Radial, Cartesian and UTE 
% Only tested with data from realease: R5.17 and R5.30
%
% Version: 20171110 
% Author: Tom Bruijnen
% Contact: t.bruijnen@umcutrecht.nl

% Predefine the time step size
GR.dt=1E-07; % seconds

% Get names of gradient waveforms depending on acquisition mode
if strcmpi(MR.Parameter.Scan.AcqMode,'Radial');gradients={'mc0';'m0';'m1';'m2';'m3';'md';'blip';'r';'py';'pyr';'pz';'pzr';};end%'d';'r0';'s_ex'};end % d,s_ex and r0 are removed
if strcmpi(MR.Parameter.Scan.AcqMode,'Cartesian');gradients={'mc0';'m0';'m1';'m2';'m3';'md';'blip';'r';'py';'pyr';'pz';'pzr'};end % d,s_ex and r0 are removed
if strcmpi(MR.Parameter.Scan.FastImgMode,'EPI');gradients={'mc0';'m0';'blip';'py';};end % d,s_ex and r0 are removed

% Get all atributes 
for j=1:numel(gradients);GR.([gradients{j}])=extract_gradient_info(MR,gradients{j});end
    
% Get time points per gradient from attributes
for j=1:numel(gradients);GR.([gradients{j}]).t=[GR.([gradients{j}]).offset GR.([gradients{j}]).slope1 GR.([gradients{j}]).lenc GR.([gradients{j}]).slope2 ];end 

% Replace 0s with the 0.0001 * dwell time, otherwise I get problems with the interpolation step (not monotoneously increasing)
for j=1:numel(gradients);GR.([gradients{j}]).t(GR.([gradients{j}]).t==0)=0.0001*GR.dt;end

% Get gradient amplitudes corresponding to the timepoints
for j=1:numel(gradients);GR.([gradients{j}]).A=[0 GR.([gradients{j}]).str GR.([gradients{j}]).str 0];end

% if EPI repeat timepoints and amps points N times
if strcmpi(MR.Parameter.Scan.Technique,'FEEPI')
    GR.m0.t=[GR.m0.t(1) repmat(GR.m0.t(2:4),[1 MR.Parameter.Scan.Samples(2)])];
    GR.m0.A=[0 repmat(GR.m0.A(2:4),[1 MR.Parameter.Scan.Samples(2)])];
    
    % Swap polarities of readout gradient
    for tps=2:3:numel(GR.m0.A)
        GR.m0.A(tps:tps+2)=GR.m0.A(tps:tps+2)*(-1)^((tps-2)/3);
    end
    
    GR.blip.t=[GR.blip.t(1) repmat([GR.blip.t(2:4) GR.m0.dur-GR.blip.dur],[1 MR.Parameter.Scan.Samples(2)-1])];
    GR.blip.A=[GR.blip.A(1) repmat([GR.blip.A(2:4) 0],[1 MR.Parameter.Scan.Samples(2)-1])];
end

% Calculate cummulative time to get timelines
for j=1:numel(gradients);GR.([gradients{j}]).t=cumsum(GR.([gradients{j}]).t);end

% Extract sequence timing parameters
sq={'base','xbase','ME','fin'};
for j=1:numel(sq);SQ.([sq{j}])=extract_sequence_info(MR,sq{j});end

% Interpolate gradient amplitudes to a nominal timeline per sequence object
t=-1000*GR.dt:GR.dt:MR.Parameter.Scan.TR*10^(-3);
%t=-.002:GR.dt:MR.Parameter.Scan.TR*10^(-3);

% SQ`base
cnt=1;for j=1:numel(gradients);if strcmpi(GR.([gradients{j}]).sq,'base');base(:,cnt,GR.([gradients{j}]).ori+1)=interp1(GR.([gradients{j}]).t,GR.([gradients{j}]).A,t,'linear');cnt=cnt+1;end;end
if exist('base');base(isnan(base))=0;if size(base,3)<3; base(:,:,end+1:3)=0;end;base=sum(base,2);tSQ(:,1,:)=base;end % Remove interpolation NaNs

% SQ`ME - different for multiple echos
cnt=1;for j=1:numel(gradients);if strcmpi(GR.([gradients{j}]).sq,'ME');ME(:,cnt,GR.([gradients{j}]).ori+1)=interp1(GR.([gradients{j}]).t+SQ.base.dur2+SQ.ME.ref,GR.([gradients{j}]).A,t,'linear');...
for l=1:SQ.ME.nechos-1;ME(:,cnt,GR.([gradients{j}]).ori+1,l+1)=interp1(GR.([gradients{j}]).t+l*SQ.ME.dur,-1*GR.([gradients{j}]).A,t,'linear')';end;cnt=cnt+1;end;end
if exist('ME');ME(isnan(ME))=0;if size(ME,3)<3; ME(:,:,end+1:3,:)=0;end;ME=sum(sum(ME,4),2);tSQ(:,2,:)=ME;end % Remove interpolation NaNs

% SQ`xbase
cnt=1;for j=1:numel(gradients);if strcmpi(GR.([gradients{j}]).sq,'xbase');xbase(:,cnt,GR.([gradients{j}]).ori+1)=interp1(GR.([gradients{j}]).t,GR.([gradients{j}]).A,t,'linear');cnt=cnt+1;end;end
if exist('xbase');xbase(isnan(xbase))=0;if size(xbase,3)<3; xbase(:,:,end+1:3)=0;end;xbase=sum(xbase,2);tSQ(:,3,:)=xbase;end % Remove interpolation NaNs

% SQ`fin
cnt=1;for j=1:numel(gradients);if strcmpi(GR.([gradients{j}]).sq,'fin');fin(:,cnt,GR.([gradients{j}]).ori+1)=interp1(GR.([gradients{j}]).t+SQ.base.dur2+SQ.ME.nechos*SQ.ME.dur+SQ.fin.ref,GR.([gradients{j}]).A,t,'linear');cnt=cnt+1;end;end
if exist('fin');fin(isnan(fin))=0;if size(fin,3)<3; fin(:,:,end+1:3)=0;end;fin=sum(fin,2);tSQ(:,4,:)=fin;end % Remove interpolation NaNs

% Remove empty cells from sq
sq(~cellfun('isempty',sq));

% Sum all gradient waveforms
tSQ=squeeze(sum(tSQ,2));

% Synchronize ADC points with gradient waveform per echo!!
necho=numel(MR.Parameter.Parameter2Read.echo);adc={};
for n=1:necho
    ADC{n}=extract_adc_info(MR,n);
    for j=1:ADC{n}.nr_acq;
        offset=(j-1)*ADC{n}.epi_dt+(j-1)*SQ.ME.dur;
        adc{n}(j,:)=offset+ADC{n}.offset:ADC{n}.dt:ADC{n}.offset+ADC{n}.dur-0.00000000001+offset;
    end
    adc{n}=adc{n}(:);
end

% IF radial sampling P-axis equals M-axis 
if strcmpi(MR.Parameter.Scan.AcqMode,'Radial')
    tSQ(:,2)=tSQ(:,1);
end

% Assign to output
time=(t+1001*GR.dt)';
nom=tSQ;
adc=cellfun(@(x) (x+1001*GR.dt)',adc(:)','UniformOutput',false);

% END
end