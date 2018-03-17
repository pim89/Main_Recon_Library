function dcf = iterative_dcf_estimation(traj,varargin)
%Iteratively estimate density for arbitrary k-spaces in 3D. This code is
%downloaded from the ismrm-unbound website and written by Nick Zwart.
%
% NOTE : Does not work for 2D at the moment!

% Check input
kdim=size(traj);
if numel(kdim)<4
    disp('Iterative DCF code does not support 2D trajectories at the moment.')
    dcf=[];
    return
end

% Provide number of iter in varargin{1}
if ~isempty(varargin)
    n_iter=varargin{1};
else
    n_iter=5;
end

% Image space dimensions
idim(1:2)=ceil(max(abs(traj(1,:))));
idim(3)=round(2*max(abs(traj(3,:))));

% Scale k-space to [-.5, .5]
traj=.5*traj/max(abs(traj(:)));

% Loop over partitions and compute k-space
for p=1:prod(kdim(5:end)) % Loop over partitions
    dcf(:,:,:,p)=sdc3_MAT(traj(:,:,:,:,p),n_iter,max(idim),0);
end

% END
end