function csm = espirit(img,varargin)
%% Script to do espirit either via bart or matlab

isbart=0;
if ~isempty(varargin)
    isbart=1;
end

% FFT image
kimg=fft2c(img);
if size(img,3)>1
    kimg=fftshift(fft(ifftshift(kimg,3),[],3),3);
end

if isbart
    % m selects number of coil maps
    % t is threshold for background (not really, but effectively)
    csm=bart('ecalib -t 0.0001 -m1',ksp_reconframe_to_bart(kimg));
    csm=ksp_bart_to_reconframe(csm);
else
    if numel(size(squeeze(img)))>3
        disp('>> 3D ESPIRiT is not supported in the matlab implementation.');
        return;
    end
    % Algorithm settings
    coff1=0.02;
    coff2=0.97;
    nlines=30;
    kernelsize=[6,6];
    [nx ny nz nc]=size(img);

    % FFT and select AC
    AC=crop(kimg,nlines);

    % Compute GRAPPA matrix A
    A=calibration_matrix(AC,kernelsize);

    % Do a SVD to get V and the eigenvalues in the diagonal
    [~,EV,V]=svd(A,'econ');
    EV=diag(EV);EV=EV(:);

    % Get rid of null-space
    idx=max(find(EV>=EV(1)*coff1));

    % Reshape V to analyze patches
    V=reshape(V,[kernelsize nc size(V,2)]);
    [M,W]=eigen_patches(V(:,:,:,1:idx),[nx,ny]);

    % Only select largest eigenvalue and normalize
    csm=M(:,:,:,end).*repmat(W(:,:,end)>coff2,[1,1,nc]);
end

disp('+Coil maps estimaed using espirit')
% END
end