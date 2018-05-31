function mask = radial_lowres_mask_ute(traj,lr)

% Dimensions
kdim=size(traj);
mask=ones(kdim(2:3),'single');

% Find cut-off point on spoke
cal=squeeze(sqrt(sum(traj(1,:,1).^2+traj(2,:,1).^2+traj(3,:,1).^2,1)));
maxval=max(cal);
idx=1;
cutoff=1;
while cal(idx) < maxval / lr || idx == numel(cal)
    cutoff=idx;
    idx=idx+1;
end

mask(cutoff:end,:,:,:,:,:,:,:,:,:,:,:)=0;

disp('+Mask created for zerofilling of UTE data.')
% END
end