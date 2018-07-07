function mask = cartesian_lowres_mask(kdim,lr)
%%Create binary mask to apply zerofilling
% Assume all image dimensions are even

% Checks
if mod(kdim(1:3),2) > 0
    error('+Error:Image dimensions have to be even for now.')
end

% Pre-allocate output
mask=ones(kdim(1:3));

% Calculate cutoff for each dimensions
ct_x=round(kdim(1)/(2*lr));
ct_x=[1:kdim(1)/2-ct_x kdim(1)/2+ct_x+1:kdim(1)];
mask(ct_x,:,:)=0;

ct_y=round(kdim(2)/(2*lr));
ct_y=[1:kdim(2)/2-ct_y kdim(2)/2+ct_y+1:kdim(2)];
mask(:,ct_y,:)=0;

ct_z=round(kdim(3)/(2*lr));
ct_z=[1:kdim(3)/2-ct_z kdim(3)/2+ct_z+1:kdim(3)];
mask(:,:,ct_z)=0;

% END
end