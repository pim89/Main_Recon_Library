function [kspace_data,traj,dcf] = radial_goldenangle_undersample(R,kspace_data,traj,dcf)
%%Undersample golden angle radial k-space data, trajectory and dcf

% Handle dimensions seperately for kspace_data, traj & dcf
kdim=c12d(size(kspace_data));
kdim(5)=kdim(5)*R;
kdim(2)=floor(kdim(2)/kdim(5));

tdim=c12d(size(traj));
tdim(5)=tdim(5)*R;
tdim(3)=floor(tdim(3)/tdim(5));

ddim=c12d(size(dcf));
ddim(5)=ddim(5)*R;
ddim(2)=floor(ddim(2)/ddim(5));

% Remove residual readouts
kspace_data=kspace_data(:,1:prod(kdim([2 5])),:,:,:,:,:,:,:,:,:,:);

% Align ky and dynamics
kspace_data=permute(kspace_data,[1 3 4 6 7 8 9 10 11 12 2 5]);
traj=permute(traj,[1 2 4 6 7 8 9 10 11 12 3 5]);
dcf=permute(dcf,[1 3 4 6 7 8 9 10 11 12 2 5]);

% Reshuffle
kspace_data=reshape(kspace_data,[kdim(1) kdim(3) kdim(4) kdim(6:12) kdim(2) kdim(5)]);
traj=reshape(traj,[tdim(1) tdim(2) tdim(4) tdim(6:12) tdim(3) tdim(5)]);
dcf=reshape(dcf,[ddim(1) ddim(3) ddim(4) ddim(6:12) ddim(2) ddim(5)]);

% Back to original dimensions
kspace_data=ipermute(kspace_data,[1 3 4 6 7 8 9 10 11 12 2 5]);
traj=ipermute(traj,[1 2 4 6 7 8 9 10 11 12 3 5]);
dcf=ipermute(dcf,[1 3 4 6 7 8 9 10 11 12 2 5]);

% END
end