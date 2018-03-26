function  fi = FI2D(k,kdim)
% Flat iron NUFFT for 12D data structures
% Input:
% 	k:   double 11D struct containg k-space coordinates [-.5 .5] with dimensions [nkx nky nkz nc ndyn nechos nphases nmixes nlocs nex1 nex2 navgs]
%   kdim:  double 11D struct with K-space dimensions
%   varagin: Number of CPU's to use for parallel computing
% 
% Output: fi : structure to pass as the nufft operator
%
% Tom Bruijnen - University Medical Center Utrecht - 201704 

% Check input
if numel(kdim)<12
    kdim(end+1:12)=1;
end

% Parfor options
fi.parfor=0;
	
% Image space dimensions
fi.idim(1:2)=ceil(max(abs(k(1,:))));
fi.idim(3)=ceil(max(abs(k(3,:))));
if fi.idim(3)==0; fi.idim(3)=1;end
fi.idim=[fi.idim kdim(4:end)];

% FFT sign 1=adjoint operation and -1=forward
fi.adjoint=1; 			

% Scale k-space between [-pi pi]^2
fi.k=pi*k/max(abs(k(:)));

% Precision for the gridding
fi.precision=1e-01; % range: 1e-1 - 1e-15

% Number of k-space points per gridding operation
fi.nj=numel(k(1,:,:,1));

% K-space dimensions
fi.kdim=kdim;

% Mix the readouts and samples in advance, kpos has to be doubles!!
fi.k=-1*double(reshape(fi.k,[3 fi.kdim(1)*fi.kdim(2) 1 1 fi.kdim(5:end)]));

% Define seperate class
fi=class(fi,'FI2D');

disp('+2D FlatIron gridder operator initialized.')

%END
end
