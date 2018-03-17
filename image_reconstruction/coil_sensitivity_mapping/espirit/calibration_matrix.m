function A = calibration_matrix(calib,ksize)
% 20160616 - Generate the calibration matrix (A) from the fully sampled
% k-space x coil data.

% Generate pre_A by transforming the image in rows x coils
[pre_A,dims]=im2row(calib,ksize);

% Generate A by reordering per coil
A=reshape(pre_A,dims(1),prod(dims(2:3)));

% END
end