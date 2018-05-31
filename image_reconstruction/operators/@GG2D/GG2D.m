function  gg = GG2D(k,kdim)
% Greengard Gaussian gridding for 12D data structures
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

% Parfor options
gg.parfor=0;
	
% Image space dimensions
gg.idim(1:2)=ceil(max(abs(matrix_to_vec(k([1 2],:)))));
gg.idim(3)=ceil(max(abs(k(3,:))));
if gg.idim(3)==0; gg.idim(3)=1;end
gg.idim=[gg.idim kdim(4:end)];

% FFT sign 1=adjoint operation and -1=forward
gg.adjoint=1; 			

% Scale k-space between [-pi pi]
gg.k=pi*k/max(abs(k(:)));

% Precision for the gridding
gg.precision=1e-01; % range: 1e-1 - 1e-15

% Number of k-space points per gridding operation
gg.nj=numel(k(1,:,:,1));

% K-space dimensions
gg.kdim=kdim;

% Mix the readouts and samples in advance, kpos has to be doubles!!
gg.k=-1*double(reshape(gg.k,[3 gg.kdim(1)*gg.kdim(2) 1 1 gg.kdim(5:end)]));

% Define seperate class
gg=class(gg,'GG2D');

disp('+2D Greengard gridder operator initialized.')

%END
end
