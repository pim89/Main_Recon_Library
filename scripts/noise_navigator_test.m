%% Compare noise-navigator with projection based soft-gated reconstruction
clear all;close all;clc
datapath1='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/ABDOMEN/BSPIR1/ut_14092017_1537185_7_2_wipt4dbffedceclearV4.raw'; 

[~,MR]=reader_reconframe_lab_raw(datapath1,1,1);
tr=MR.Parameter.Scan.TR*10^-3; % s
scan_time=tr*numel(MR.Parameter.Parameter2Read.kz)*numel(MR.Parameter.Parameter2Read.ky); % s
maxres=round(max(MR.Parameter.Scan.FOV)/min(MR.Parameter.Scan.AcqVoxelSize));
nkz=numel(MR.Parameter.Parameter2Read.kz);
recon_time=10:5:scan_time;

% Initial processing steps
MR.Data=ifft(MR.Data,MR.Parameter.Encoding.ZReconRes,3);
MR.Data=radial_phase_correction_zero(MR.Data);
kdim=c12d(size(MR.Data));
traj=1.25*radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);

% Estimation respiratory motion signal from multichannel data
norm=@(bla)((bla - min(bla)) / ( max(bla) - min(bla) ));
respiration=norm(radial_3D_estimate_motion(MR.Data,'maf'));
MR.Parameter.Bruker=norm(MR.Parameter.Bruker);

% Visualize signals
t=linspace(0,180,numel(respiration));
norm=@(bla)((bla - min(bla)) / ( max(bla) - min(bla) ));
close all
figure,plot(t,norm(respiration),'b','LineWidth',2);hold on;
plot(t,norm(MR.Parameter.Bruker),'k','LineWidth',2)
xlabel('Time [s]');ylabel('Navigator signal [au]');legend('Projection nav','Noise nav')
set(gca,'FontSize',18,'FontWeight','bold','LineWidth',2);axis([0 180 -.5 1.5])
set(gcf,'Position',[10 500 1800 500],'Color','w')

%% SOFT-GATED RECONSTRUCTION
cnt=0;
for z=1:size(MR.Data,3)

    kdim=size(MR.Data);
    lr=3; % 5 times lower resolution
    mask=radial_lowres_mask(kdim(1:2),lr);
    F2D=FG2D(traj,[kdim(1:2) 1 kdim(4)]);
    lowres=F2D'*hannfilter(bsxfun(@times,MR.Data(:,:,z,:,:),dcf.*mask));
    par.csm=espirit(lowres,'bart');
    S=B1(par.csm);
                
    % Process nky with dcf, traj and kspace-data
    par.kspace_data=MR.Data(:,:,z,:,:);
    mr_traj=traj(:,:,:,:,:);
    mr_dcf=dcf(:,:,:,:,:);
    kdim=c12d(size(par.kspace_data));        

    % Get soft-weights
    R=1;
    recon_matrix_size=round(max(mr_traj(:)));
    soft_weights_PROJ=mrriddle_respiratory_filter(respiration(:),R*recon_matrix_size,'midpos');
    soft_weights_NOISE=mrriddle_respiratory_filter(MR.Parameter.Bruker(:),R*recon_matrix_size,'midpos');

    % Apply motion-weighted reconstruction
    F2D=FG2D(mr_traj,kdim);
    recon_nufft_PROJ=F2D'*(bsxfun(@times,bsxfun(@times,hannfilter(par.kspace_data),mr_dcf),soft_weights_PROJ));
    recon_nufft_NOISE=F2D'*(bsxfun(@times,bsxfun(@times,hannfilter(par.kspace_data),mr_dcf),soft_weights_NOISE));
    mrriddle_recon_PROJ(:,:,z)=flip(flip(single(abs(S*recon_nufft_PROJ)),1),3);
    mrriddle_recon_NOISE(:,:,z)=flip(flip(single(abs(S*recon_nufft_NOISE)),1),3);

    figure,imshow3(cat(3,mrriddle_recon_PROJ(:,:,z),mrriddle_recon_NOISE(:,:,z)),[],[2 1])
    % Display
    cnt=cnt+1;
    disp(['Reconstruction: ',num2str(cnt),'/',num2str(size(MR.Data,3)*numel(recon_time))])

 
end
