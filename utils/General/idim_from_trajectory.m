function idim = idim_from_trajectory(traj,kdim)
%%Estimate the image dimensions from the k-space trajectory
% Image dimensions are encoded in the k-space trajectory bounds.

idim(1:2)=ceil(max(abs(traj(1,:))));
idim(3)=ceil(2*max(abs(traj(3,:))));
if idim(3)==0; idim(3)=1;end
idim=c12d([idim kdim(4:end)]);

% END
end