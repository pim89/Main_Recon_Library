function [MR,sldw_recon,recon_time] = sldw_reconstruction(datapath,R,width)

[~,MR]=reader_reconframe_lab_raw(datapath,1);
tr=MR.Parameter.Scan.TR*10^-3; % s
scan_time=tr*numel(MR.Parameter.Parameter2Read.kz)*numel(MR.Parameter.Parameter2Read.ky); % s
maxres=round(max(MR.Parameter.Scan.FOV)/min(MR.Parameter.Scan.AcqVoxelSize));
nkz=numel(MR.Parameter.Parameter2Read.kz);
recon_time=10:5:scan_time;

% Initial processing steps
MR.Data=ifft(MR.Data,[],3);
MR.Data=radial_phase_correction_zero(MR.Data);
kdim=c12d(size(MR.Data));
traj=radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);

% Estimate csm
lr=5; % 5 times lower resolution
mask=radial_lowres_mask(kdim(1:2),lr);
F2D=FG2D(traj,kdim);
lowres=F2D'*bsxfun(@times,MR.Data,dcf.*mask);
csm=openadapt(lowres);

% Choose spatial resolution for the reconstruction
lr=1;

% Define number of time-points
[MR.Data,traj,dcf]=radial_goldenangle_undersample(R,MR.Data,traj,dcf);

% Reconstruct volumes

for z=1:kdim(3)
    S=SS(csm(:,:,z,:));
    kspace_data=radial_view_sharing(MR.Data(:,:,z,:,:),[],width,[2 5]);
    if z
        sw_kdim=size(kspace_data);
        sw_traj=radial_view_sharing(traj(:,:,:,:,:),[],width,[3 5]);
        sw_dcf=radial_view_sharing(dcf(:,:,:,:,:),[],width,[2 5]);
        F2D=FG2D(sw_traj,sw_kdim);
        mask=radial_lowres_mask(sw_kdim(1:2),lr);
    end
    sldw_recon(:,:,z,:,:)=flip(flip(single(demax(abs(S*(F2D'*bsxfun(@times,...
        bsxfun(@times,kspace_data,sw_dcf),mask))))),1),3);   
    
    disp(['Z = ',num2str(z),' / ',num2str(kdim(3))]);
end

% END
end