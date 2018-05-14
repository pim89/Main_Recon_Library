%% RECONSTRUCT GOLDEN ANGLE STACK-OF-STARS DATA
%% Setup
% SSH to my PC with -X mode (Chouffe)
% You will need this for Reconframe license
clear all;close all;clc;restoredefaultpath

% Go to main recon folder and run setup
% (https://github.com/tombruijnen/Main_Recon_Library/)
cd('/nfs/rtsan02/userdata/home/tbruijne/Documents/Main_Recon_Library/')
setup;

% Select data
datapath1='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/PROSTATE/T1DIXON1/RECONFRAME_DATA/na_07052018_1728590_5_2_wipradt13dffemdixonsmallerfovV4.raw'; % Golden angle stack-of-stars

%% Fully sampled (normal) reconstruction
% Load k-space data including basic corrections
kspace_data=reader_reconframe_lab_raw(datapath1,1); % [kx ky kz coils dynamics phases echoes]

% Select echo 1 if multi echo
if size(kspace_data,7) > 1
    echo=1;
    kspace_data=kspace_data(:,:,:,:,:,:,echo);
end

% Get dimensionality in a vector
kdim=size(kspace_data); 

% Data will be reconstructed as seperate 2D slices, so k-space trajectory will also
% be in 2D
traj=radial_trajectory(kdim(1:2),1); % Radial trajectory [3 kx ky kz dynamics phases echoes] 
dcf=radial_density(traj); % Density compensation function  
kspace_data=ifft(kspace_data,[],3); % Decouple 3D into 2D slices
kspace_data=radial_phase_correction_zero(kspace_data); % Radial phase correction

F2D=FG2D(traj,[kdim(1:2) 1 kdim(4)]); % Define NUFFT operator
lr=8; % 5 times lower resolution
mask=radial_lowres_mask(kdim(1:2),lr);
for z=24:24%1:size(kspace_data,3)
    % Estimate coil maps on lower resolution images

    lowres=F2D'*bsxfun(@times,kspace_data(:,:,z,:,:),dcf.*mask);
    csm=openadapt(lowres);
    %csm=espirit(lowres,'bart');
    S=SS(csm);
    img(:,:,z,:)=S*(F2D'*bsxfun(@times,kspace_data(:,:,z,:,:),dcf)); % Density compensation + NUFFT
    z
end
%figure,imshow3(flip(demax(abs(img(:,:,20:10:98,1))),1),[.05 .55],[2 4])

%% Undersampled reconstruction
R=8; % Undersampling factor
[kspace_data_us,traj_us,dcf_us]=radial_goldenangle_undersample(R,kspace_data,traj,dcf,1);
kdim=size(kspace_data_us);
clear img_us
F2D=FG2D(traj_us,[kdim(1:2) 1 kdim(4)]); % Define NUFFT operator
for z=24:24%1:size(kspace_data,3)
    
    % Estimate coil maps on lower resolution images
    lr=6; % times lower resolution
    mask=radial_lowres_mask(kdim(1:2),lr);
    lowres=F2D'*bsxfun(@times,kspace_data_us(:,:,z,:,:),dcf_us.*mask);
    %csm=espirit(lowres,'bart');
    csm=openadapt(lowres);
    S=SS(csm);
    img_us(:,:,z,:)=S*(F2D'*bsxfun(@times,kspace_data_us(:,:,z,:,:),dcf_us)); % Density compensation + NUFFT
    z
end
%slicer(flip(demax(abs(img_us))))

%% Undersampled with iterative reconstruction
clear img_cs
% Create data struct to use for bart
par.TV=[0.001 0.001 0 0 0]; % lambdas in dimensions 
par.wavelet=0.002;
par.traj=traj_us;
par.Niter=50;
for z=24:24%1:size(kspace_data,3)
    
    % Estimate coil maps on lower resolution images
    lr=6; % 5 times lower resolution
    mask=radial_lowres_mask(kdim(1:2),lr);
    lowres=F2D'*bsxfun(@times,kspace_data_us(:,:,z,:,:),dcf_us.*mask);
    %par.csm=espirit(lowres,'bart');
    par.csm=openadapt(lowres);
    par.kspace_data=kspace_data_us(:,:,z,:,:,:,:,:,:,:);
    img_cs(:,:,z)=configure_compressed_sense(par,'bart');
end

figure,imshow3(cat(3,flip(demax(abs(img(:,:,z))),1),flip(demax(abs(img_us(:,:,z))),1),...
    flip(demax(abs(img_cs(:,:,z))),1)),[],[1 3])