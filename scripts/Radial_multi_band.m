%% Radial multi-band simulations
% Only works for multi-band is 2 at the moment.
%
% T.Bruijnen @ 20180627 

%% 1) Create phantom and test adjoint model 
close all
% Sequence settings
N=256; % Matrix size
nspokes=round(N*pi/2); % Nyquist
dynamics=10; % number of dynamics
goldenangle=1; % Golden angle number [1-7]

% Image space
load('brain.mat');
I=cat(3,phantom(N),demax(imresize(im,[N N])));

% K-space trajectory & density
kdim=c12d([2*N nspokes 2]); %[kx ky kz coils dynamics ...]
traj=radial_trajectory(kdim(1:2),goldenangle);
dcf=radial_density(traj);

% Create operators
op.N=FG2D(traj,kdim); % Fourier transform
op.W=DCF(sqrt(dcf)); % Density operator (sqrt required for cg)
op.PH=PH([pi 0;0 0],kdim); % Add complex phase to data

% Generate radial k-space data for the slices
kspace_data=op.N*I;
nufft=op.N'*(op.W*(op.W*kspace_data));
kspace_data=op.PH*kspace_data;

% Spread data over the dynamics
[kspace_data,traj,dcf]=radial_goldenangle_undersample(dynamics,kspace_data,traj,dcf);
kdim=c12d(size(kspace_data));
kdim(3)=2;
op.PH=PH([pi 0;0 0],kdim); % Add complex phase to data
op.N=FG2D(traj,kdim); % Fourier transform
op.W=DCF(sqrt(dcf)); % Density operator (sqrt required for cg)

% Create the NUFFT separation results
nufft_separate=op.N'*(op.W*(op.W*(op.PH'*kspace_data)));
maxval=max(abs(nufft_separate(:)));
figure,imshow3(abs(nufft_separate(:,:,:,:,dynamics)),[],[1 2])

%% 2) Compressed sense multi-band
%Initialize structure to send to the solverreader_reconframe_lab_raw
op.kdim=kdim;
op.idim=idim_from_trajectory(traj,op.kdim);
op.idim(3)=2;
op.Niter=15;
op.TV=TV_sparse(op.idim,[1 1 0 0 1],maxval*[0.0001 0.0001 0 0 0.05]);
op.S=SS(ones(op.idim(1:3)));
op.beta=.6; % step-size of CG
op.y=op.W*kspace_data;

recon=configure_compressed_sense_multiband(op);
figure,imshow3(abs(recon(:,:,:,:,ceil(dynamics/2))),[],[1 2])
