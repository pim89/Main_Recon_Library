function [img,seq] = MRRIDDLE_UTE(datapath,outpath,girfpath,dt)
%% MR-RIDDLE reconstruction
% Only works with lab/raw code, no support for data list at the moment.
%
% Requirements:
% 1) Reconframe 
% 2) Fessler's NUFFT toolbox
% 3) Large amount of RAM for the stupid reconframe correction functions
%
% Constraints:
% 1) Should work in all cases
% 2) Should deal with very large data-sets
% 3) Is not performance orientated
% 
% Tuning parameters
% 1) DT of reconstruction (seconds)
%
%
% TODO:
% 1) Add zeropadding for higher reconstruction resolution
%
% Initialized by Tom Bruijnen 20180516
% Last modified: Tom Bruijnen 20180516

%% Check input
if exist(datapath, 'file') ~= 2
    error('-MRRIDDLE ERROR: Specified data file is not accessible/available.')
    return;
end

if nargin < 3
    dt=10;
end

if nargin < 2 
    outpath=[get_data_dir(datapath),'MRRIDDLE_RECON.mat'];
else
    if isempty(outpath)
        outpath=[get_data_dir(datapath),'MRRIDDLE_RECON.mat'];
    end
end

if numel(dt) > 1
    error('-MRRIDDLE ERROR: Defined dt has to be a scalar (non-vector), set to default: dt=10s')
    dt=10;
end

if ~strcmpi(outpath(end-3:end),'.mat')
    outpath=[outpath,'MRRIDDLE_RECON.mat'];
end

%% Algorhitm
% Load in data from reconframe
[~,MR]=reader_reconframe_lab_raw(datapath,1);
if iscell(MR.Data)
    MR.Data=MR.Data{1};    
end

% Load parameters from reconframe
tr=MR.Parameter.Scan.TR*10^-3; % s
scan_time=tr*numel(MR.Parameter.Parameter2Read.kz)*numel(MR.Parameter.Parameter2Read.ky); % s
maxres=round(max(MR.Parameter.Scan.FOV)/min(MR.Parameter.Scan.AcqVoxelSize));
nkz=numel(MR.Parameter.Parameter2Read.kz);
recon_time=dt:dt:scan_time;

% Initial processing steps
[girf_k,girf_phase]=GIRF(MR,girfpath,'verbose');
girf_k={girf_k{1}};
girf_phase={girf_phase{1}};
kdim=c12d(size(MR.Data));
traj=MR.Parameter.Encoding.KyOversampling(1)*ute_trajectory_girf([kdim(1:2) MR.Parameter.Encoding.ZReconRes(1)],1,girf_k);
dcf=iterative_dcf_estimation(traj);
traj=traj(:,:,:,1);dcf=dcf(:,:,1);
MR.Data=radial_phase_correction_girf(MR.Data,1,kdim(1:2),girf_phase);
MR.Data=ifft(MR.Data,MR.Parameter.Encoding.ZReconRes(1),3);
kdim=c12d(size(MR.Data));

% Estimation respiratory motion signal from multichannel data
respiration=radial_3D_estimate_motion(MR.Data,'maf');
respiration=ones(size(respiration));

% Create .mat files for the recons
m=matfile(outpath,'Writable',true);
m.mrriddle_pre_image_corrections=complex(zeros(ceil(max(traj(:))),ceil(max(traj(:))),kdim(3),numel(recon_time)+1,'single'));
m.mrriddle=zeros(MR.Parameter.Encoding.XReconRes(1),MR.Parameter.Encoding.YReconRes(1),MR.Parameter.Encoding.ZReconRes(1),numel(recon_time)+1,'single');
m.mrriddle_csm=complex(zeros(ceil(max(traj(:))),ceil(max(traj(:))),kdim(3),kdim(4),'single'));
disp(['Created instances in: ',outpath,'to for low memory handling.'])

% Some work that can be pre-calculated
kdim=size(MR.Data);
lr=3; % 3 times lower resolution for csm estimation
mask_csm=radial_lowres_mask_ute(traj,lr);
F2D_CSM=FG2D(traj,[kdim(1:2) 1 kdim(4)]);
    
% Loop over slices 
disp('Start looping over Z partitions end time-points.')
cnt=0;
for z=1:size(MR.Data,3)
    
    % Calculate coil maps
    lowres=F2D_CSM'*bsxfun(@times,MR.Data(:,:,z,:,:),dcf.*mask_csm);
    par.csm=single(openadapt(lowres));
    S=B1(par.csm);
    m.mrriddle_csm(1:size(par.csm,1),1:size(par.csm,2),z,1:kdim(4))=par.csm;
    
    % Loop over time-points 
    for t=1:numel(recon_time)
        
        % Select number of readouts to use
        nky=floor(recon_time(t)/(nkz*tr));
        if nky > numel(MR.Parameter.Parameter2Read.ky)
            nky=numel(MR.Parameter.Parameter2Read.ky);
        end
        
        % Process nky with dcf, traj and kspace-data
        par.kspace_data=MR.Data(:,1:nky,z,:,:);
        mr_traj=traj(:,:,1:nky,:,:);
        mr_dcf=dcf(:,1:nky,:,:,:);
        kdim=c12d(size(par.kspace_data));
        
        % Select spatial resolution for reconstruction
        res(t)=makeeven(round(nky*2/pi));
        if res(t) > maxres
            res(t)=maxres;
        end
        lr=maxres/res(t);
        mask=radial_lowres_mask_ute(mr_traj,lr);
        par.kspace_data=bsxfun(@times,par.kspace_data,mask);
        
        % Get soft-weights centered around mid-pos
        recon_matrix_size=round(max(mr_traj(:)));
        soft_weights=mrriddle_respiratory_filter(respiration(1:nky),recon_matrix_size,'midpos');
        
        % Apply motion-weighted reconstruction
        F2D=FG2D(mr_traj,kdim);
        recon_nufft=F2D'*(bsxfun(@times,bsxfun(@times,(par.kspace_data),mr_dcf),soft_weights));
        mrriddle_recon(:,:,t)=single(S*recon_nufft);        
 
        % Display
        cnt=cnt+1;
        disp(['Reconstruction: ',num2str(cnt),'/',num2str(size(MR.Data,3)*numel(recon_time))])
    end  
    
    % Save to disk
    m.mrriddle_pre_image_corrections(1:size(mrriddle_recon,1),1:size(mrriddle_recon,2),z,1:numel(recon_time))=permute(mrriddle_recon,[1 2 4 3]);
       
end

% Geometry correction / Bias filter / Zerofilling on all volumes
ijk=MR.Parameter.Scan.ijk;
fov=MR.Parameter.Scan.curFOV;
for t=numel(recon_time):-1:1
    % Set flags
    MR.Parameter.Scan.curFOV=fov;
    MR.Parameter.Scan.ijk=ijk;
    MR.Parameter.ReconFlags.iszerofilled=[0,0];
    MR.Parameter.ReconFlags.isrotated=1;
    MR.Parameter.ReconFlags.isgeocorrected=0;
    MR.Parameter.ReconFlags.isimspace=[1,1,1];
    MR.Parameter.ReconFlags.iscombined=1;
    MR.Parameter.ReconFlags.isgridded=1;
    MR.Parameter.ReconFlags.isoversampled=[1,1,1];
    
    % Load data from drive
    MR.Data=m.mrriddle_pre_image_corrections(:,:,:,t);
    
    % Apply corrections and put back
    MR.GeometryCorrection;
    MR.RotateImage;
    if t == numel(recon_time)
        [MR.Data,mask]=hum3D(abs(MR.Data));
    else
        MR.Data=hum3D(abs(MR.Data),.15*size(MR.Data,1),mask);
    end
    m.mrriddle(1:size(MR.Data,1),1:size(MR.Data,2),1:size(MR.Data,3),t)=MR.Data;
    
    disp(['Image corrections (geo,hum,zerofill): ',num2str(t),'/',num2str(numel(recon_time))])
end

% Provide output to function & write dicoms
img=m.mrriddle(:,:,:,1:end-1);
folder=[get_data_dir(outpath),'MRRIDDLE_DICOM/'];
if exist(folder) ~= 7
    mkdir(folder);
else
    rmdir(folder,'s');
    mkdir(folder);
end

% Write DICOMS to a maximum of 3000
if size(img,3)*size(img,4) > 3000
    img=img(:,:,:,1:floor(3000/size(img,3)));
end

writeDicomFromMRecon(MR,img,[get_data_dir(outpath),'/MRRIDDLE_DICOM/']);

% Save sequence info to struct
seq=reader_reconframe_summary(MR);
seq.resp=respiration;
seq.recon_times=recon_time;
seq.res=res;
m.seq=seq;

% END
end