function [kspace_data_resp,traj_resp,dcf_resp] = respiratory_data_transform(kspace_data,traj,dcf,respiratory_bin_idx,n_phases)
%%Transform kspace, trajectory and density function to respiratory phases
%%based on respiration signal and number of phases.

dt=floor(numel(respiratory_bin_idx)/n_phases);

% First swap from dynamics to spokes only
kspace_data=dynamic_to_spokes(kspace_data);
traj=dynamic_to_spokes(traj);
dcf=dynamic_to_spokes(dcf);

% Data dimensions
kdata_dim=c12d(size(kspace_data));
dcf_dim=c12d(size(dcf));
traj_dim=c12d(size(traj));

% Initialize new data matrices
kspace_data_resp=zeros([kdata_dim(1) dt kdata_dim(3) kdata_dim(4) n_phases kdata_dim(6:end)]);
dcf_resp=zeros([dcf_dim(1) dt dcf_dim(3) dcf_dim(4) n_phases dcf_dim(6:end)]);
traj_resp=zeros([traj_dim(1) traj_dim(2) dt traj_dim(4) n_phases traj_dim(6:end)]);

% Transform per dynamic
for t=1:n_phases
    kspace_data_resp(:,:,:,:,t,:,:,:,:,:,:)=kspace_data(:,respiratory_bin_idx(1+dt*(t-1):t*dt),:,:,:,:,:,:,:,:,:);
    dcf_resp(:,:,:,:,t,:,:,:,:,:,:)=dcf(:,respiratory_bin_idx(1+dt*(t-1):t*dt),:,:,:,:,:,:,:,:,:);
    traj_resp(:,:,:,:,t,:,:,:,:,:,:)=traj(:,:,respiratory_bin_idx(1+dt*(t-1):t*dt),:,:,:,:,:,:,:,:);
end

% END
end