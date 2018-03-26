function  gg = GG3D(k,kdim,varargin)
% Greengard Gaussian gridding for 12D data structures in 3D
% Input:
% 	k:   double 11D struct containg k-space coordinates [-.5 .5] with dimensions [nkx nky nkz nc ndyn nechos nphases nmixes nlocs nex1 nex2 navgs]
%   idim:  double 11D struct with Image space dimensions
%   kdim:  double 11D struct with K-space dimensions
%   varagin: Number of CPU's to use for parallel computing
% 
% Output: gg : structure to pass as the nufft operator
%
% Tom Bruijnen - University Medical Center Utrecht - 201704 

% Check input
if numel(kdim)<12
    kdim(end+1:12)=1;
end
gg.parfor=0;		

% FFT sign 1=adjoint operation and -1=forward
gg.adjoint=1; 			

% Image space dimensions
gg.idim(1:2)=ceil(max(abs(k(1,:))));
gg.idim(3)=round(2*max(abs(k(3,:))));
gg.idim=[gg.idim kdim(4:end)];

% K-space dimensions
gg.kdim=kdim;

% Mix the readouts and samples in advance
gg.k=reshape(k,[3 kdim(1)*kdim(2)*kdim(3) 1 kdim(5:12)]);clear k

% Normalize k-space coords
kxy_max=max(abs(matrix_to_vec(gg.k(1:2,:))));
kz_max=max(abs(matrix_to_vec(gg.k(3,:))));
gg.k(1:2,:,:,:,:,:,:,:,:,:,:,:,:)=pi*gg.k(1:2,:,:,:,:,:,:,:,:,:,:,:,:)/kxy_max;
gg.k(3,:,:,:,:,:,:,:,:,:,:,:,:)=pi*gg.k(3,:,:,:,:,:,:,:,:,:,:,:,:)/kz_max;

% Precision for the gridding
gg.precision=1e-01; % range: 1e-1 - 1e-15

% Number of k-space points per gridding operation
gg.nj=numel(gg.k(1,:,:,:,1));

% Define seperate class
gg=class(gg,'GG3D');

disp('+3D Greengard gridder operator initialized.')

%END
end
