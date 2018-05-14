function [MR,mrriddle_recon,recon_time,res] = mrriddle_reconstruction(datapath)

[~,MR]=reader_reconframe_lab_raw(datapath,1);
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
respiration=radial_3D_estimate_motion(MR.Data,'maf');

% Create .mat files for the recons
m=matfile([get_data_dir(datapath),'EXPW/MRIDDLE.mat'],'Writable',true);
m.mrriddle_nufft=zeros(ceil(max(traj(:))),ceil(max(traj(:))),kdim(3),numel(recon_time),'single');
m.mrriddle_cs=zeros(ceil(max(traj(:))),ceil(max(traj(:))),kdim(3),numel(recon_time),'single');

% Loop over multiple resolution and slices
cnt=0;
for z=1:size(MR.Data,3)

    kdim=size(MR.Data);
    lr=3; % 5 times lower resolution
    mask=radial_lowres_mask(kdim(1:2),lr);
    F2D=FG2D(traj,[kdim(1:2) 1 kdim(4)]);
    lowres=F2D'*hannfilter(bsxfun(@times,MR.Data(:,:,z,:,:),dcf.*mask));
    par.csm=espirit(lowres,'bart');
    S=B1(par.csm);
        
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
        mask=radial_lowres_mask(kdim(1:2),lr);
        par.kspace_data=bsxfun(@times,par.kspace_data,mask);
        
        % Get soft-weights
        R=1;
        recon_matrix_size=round(max(mr_traj(:)));
        soft_weights=mrriddle_respiratory_filter(respiration(1:nky),R*recon_matrix_size,'midpos');
        
        % Apply motion-weighted reconstruction
        F2D=FG2D(mr_traj,kdim);
        recon_nufft=F2D'*(bsxfun(@times,bsxfun(@times,hannfilter(par.kspace_data),mr_dcf),soft_weights));
        mrriddle_recon(:,:,t)=flip(flip(single(abs(S*recon_nufft)),1),3);
        
        % CS reconstruction to denoise
        par.TV=[0.00005 0.00005 0 0 0]; % lambdas in dimensions 
        par.wavelet=0.0005;
        par.traj=traj(:,:,1:nky);
        par.iter=100;
        compressed_sense(:,:,t)=flip(flip(abs(configure_compressed_sense(par,'bart')),1),3);

        % Display
        cnt=cnt+1;
        disp(['Reconstruction: ',num2str(cnt),'/',num2str(size(MR.Data,3)*numel(recon_time))])
    end
    
    % Save to disk
    m.mrriddle_nufft(1:size(mrriddle_recon,1),1:size(mrriddle_recon,2),z,1:numel(recon_time))=permute(mrriddle_recon,[1 2 4 3]);
    m.mrriddle_cs(1:size(compressed_sense,1),1:size(compressed_sense,2),z,1:numel(recon_time))=permute(compressed_sense,[1 2 4 3]);

end

% END
end
