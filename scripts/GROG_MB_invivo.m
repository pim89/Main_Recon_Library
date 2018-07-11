%% Radial multi-band in vivo reconstruction
[~,MR]=reader_reconframe_lab_raw('/local_scratch2/tbruijne/WorkingData/MB/pb_06072018_1438226_14_2_wip_t1ffe_mb2_tomV4.raw');
kdim=size(MR.Data);
MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[kdim(1) kdim(3) kdim(4) kdim(2)*kdim(5)]),[1 4 2 3 5]);
kdim=c12d(size(MR.Data));
kspace_data=MR.Data;

% Trajectory & density
traj=radial_trajectory([kdim(1) kdim(2)],1);
dcf=radial_density(traj);

% Create operators
kdim=c12d(size(kspace_data));kdim(3)=2;
op.PH=PH([pi 0;0 0],kdim); % Add complex phase to data

% GROG operation
R=20;
[kspace_data,traj,dcf]=radial_goldenangle_undersample(R,op.PH'*(kspace_data),traj,dcf);
GROG_data=GROG_kdata(kspace_data,traj);

% 2D FFT
GROG_data=fftshift(fftshift(GROG_data,1),2);
kdim=c12d(size(GROG_data));
mask=logical(abs(GROG_data(:,:,:,1)));
op.N=FFT2D();
op.W=DCF(ones(kdim(1:2),'double'));
fft2d=op.N'*(GROG_data);    

csm1=openadapt(mean(fft2d(:,:,1,:,:),5));
csm2=openadapt(mean(fft2d(:,:,2,:,:),5));

op.S=B1(double(csm2));
maxval=double(max(matrix_to_vec(sum(abs(fft2d(:,:,2,:,:)).^2,4))));

% Compressed sensing 
op.kdim=kdim;
op.idim=c12d(size(fft2d));op.idim(3)=1;
op.Niter=5;
op.TV=TV_sparse(op.idim,[0 0 0 0 1],maxval*[0.00 0.00 0 0 0.01]);
op.beta=.6; % step-size of CG
op.y=op.W*double(GROG_data(:,:,2,:,:));
recon=configure_compressed_sense(op);

MR.Data=recon(:,:,2,:,:);
MR.Parameter.ReconFlags.isimspace=[1,1,1];
MR.GeometryCorrection;
MR.RotateImage;
MR.Data=hum(MR.Data);

save('/local_scratch2/tbruijne/WorkingData/MB/CS.mat','recon','nufft','csm1','csm2')