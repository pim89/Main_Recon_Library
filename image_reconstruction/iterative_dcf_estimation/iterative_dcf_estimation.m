function dcf = iterative_dcf_estimation(traj,varargin)
%Iteratively estimate density for arbitrary k-spaces in 3D. This code is
%downloaded from the ismrm-unbound website and written by Nick Zwart.

% Provide number of iter in varargin{1}
if ~isempty(varargin)
    n_iter=varargin{1};
else
    n_iter=5;
end

% Kspace dimensions
kdim=size(traj);

% Image space dimensions
idim(1:2)=ceil(max(abs(traj(1,:))));
idim(3)=round(2*max(abs(traj(3,:))));

% If k-space is 2D, zerofill in 3th dimension

for p=1:prod(kdim(5:end)) % Loop over partitions
    dcf(:,:,:,p)=sdc3_MAT(traj(:,:,:,p),n_iter,max(idim));
end

% END
end