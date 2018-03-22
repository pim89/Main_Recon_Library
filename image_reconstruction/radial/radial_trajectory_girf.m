function traj = radial_trajectory_girf(kdim,goldenangle,girf_k)
% Compute k-space coordinates [-1;1] for radial acquisitions from the GIRF
% modified gradient waveforms. Assumes a stack-of-stars or 2D radial
% trajectory. Assume image dimensons are derivable from kdim

kdim=c12d(kdim);

% Pre-allocate trajectory matrix
traj=zeros(3,kdim(1),kdim(2),prod(kdim([3 5:end])));
    
% Scale girf_k according to kdim
girf_k=cell2mat(girf_k);
girf_k(:,1)=girf_k(:,1)*kdim(1);
girf_k(:,2)=girf_k(:,2)*kdim(1);
girf_k(:,3)=girf_k(:,3)*2;

% Get radial angles for uniform (rev) or golden angle
if goldenangle > 0
    d_ang=(pi/(((1+sqrt(5))/2)+goldenangle-1));
else
    d_ang=pi/(kdim(2));
end
rad_ang=0:d_ang:d_ang*(kdim(2)-1);

% Line reversal for uniform
if goldenangle == 0
    rad_ang(2:2:end)=rad_ang(2:2:end)+pi;
    rad_ang=mod(rad_ang,2*pi);
end

% Deal with stack-of-stars partition direction
if kdim(3) > 1
        if mod(kdim(3),2)==0 % is_odd
            kz=linspace(-kdim(3)/2,kdim(3)/2,kdim(3)+1);kz(end)=[];
        else
            kz=linspace(-kdim(3)/2,kdim(3)/2,kdim(3));
        end
else
    kz=0;
end

% Loop over partitions 
for p=1:prod(kdim(4:end))
    traj(1,:,:,:,p)=repmat(girf_k(:,1),[1 kdim(2) kdim(3)]).*repmat(cos(rad_ang),[kdim(1) 1 kdim(3)]);
    traj(2,:,:,:,p)=repmat(girf_k(:,2),[1 kdim(2) kdim(3)]).*repmat(sin(rad_ang),[kdim(1) 1 kdim(3)]);
    traj(3,:,:,:,p)=repmat(girf_k(:,3),[1 kdim(2) kdim(3)]).*repmat(permute(kz,[1 3 2]),[kdim(1) kdim(2) 1]);
end

% END
end