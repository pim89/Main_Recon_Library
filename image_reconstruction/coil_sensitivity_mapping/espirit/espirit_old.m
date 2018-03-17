function espirit_old(MR,varargin)
%Function to use the eigenanalysis from Uecker et al. to derive coil
% sensitivity maps from the calibration matrix. Does not work for 3D!!
%
% Tom Bruijnen - University Medical Center Utrecht - 201609

%% Logic
if ~strcmpi(MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps,'espirit') 
    return;end

%% Espirit
% Handle inputs & set default values
coff1=0.02;
coff2=0.97;
nlines=24;
kernelsize=[6, 6];

% handle varargin
if nargin > 1
    coff1=varargin{1};
end
    
if nargin > 2
    coff2=varargin{2};
end

if nargin > 3
    nlines=varargin{3};
end

if nargin > 4
    kernelsize=[varargin{4} varargin{4}];
end
  
% Get image dimensions
[nx ny nz nc]=size(MR.Data{MR.UMCParameters.AdjointReconstruction.CoilMapEchoNumber});

% Select center part 
kimg=fft2c(MR.Data{MR.UMCParameters.AdjointReconstruction.CoilMapEchoNumber});
AC=crop(kimg,nlines);

% Setup parfor to indicate progress
parfor_progress(nz);

% Loop over all z slices, so only works for multislice and not 3D
for z=1:nz
    
    % Compute GRAPPA matrix A
    A=calibration_matrix(AC(:,:,z,:),kernelsize);
    
    % Do a SVD to get V and the eigenvalues in the diagonal
    [~,EV,V]=svd(A,'econ');
    EV=diag(EV);EV=EV(:);
    
    % Get rid of null-space
    idx=max(find(EV>=EV(1)*coff1));
    
    % Reshape V to analyze patches
    V=reshape(V,[kernelsize nc size(V,2)]);
    [M,W]=eigen_patches(V(:,:,:,1:idx),[nx,ny]);
    
    % Only select largest eigenvalue and normalize
    tcsm=M(:,:,:,end).*repmat(W(:,:,end)>coff2,[1,1,nc]);
    tcsm=tcsm/max(abs(tcsm(:)));
    
    % Make non calibration areas noise like
    for p=1:nx*ny*nc;if tcsm(p)==0;tcsm(p)=rand();end;end; 
    
    % Assign to slice
    MR.Parameter.Recon.Sensitivities(:,:,z,:)=tcsm;
    
    % Track progress
    parfor_progress;
end

% Reset parfor script
parfor_progress(0);

% END
end

% Visualization
% A=zeros(160,160,17,17);
% ccimg=squeeze(sum(abs(img),4));
% A(:,:,1,1:end-1)=W;
% A(:,:,2:end,end)=squeeze(abs(img))/max(abs(squeeze(img(:))));
% A(:,:,1,end)=ccimg/max(abs(ccimg(:)));
% A(:,:,2:end,1:end-1)=M;
% figure,imshow3(angle(permute(A,[1 2 3 4])),[],[17 17])
