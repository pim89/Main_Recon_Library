function  fg = FG3D(k,kdim,varargin)
% Modified for 12D reconframe data
% (c) Michael Lustig 2007


% Check input
if numel(kdim)<12
    kdim(end+1:12)=1;
end

fg.parfor=0;

% Image space dimensions
fg.idim(1:2)=ceil(max(abs(matrix_to_vec(k([1 2],:)))));
fg.idim(3)=round(2*max(abs(k(3,:))));
fg.idim=[fg.idim kdim(4:end)];

% K-space dimensions
fg.kdim=kdim;

% Mix the readouts and samples in advance
fg.k=reshape(k,[3 kdim(1)*kdim(2)*kdim(3) 1 kdim(5:12)]);clear k

% Input for nufft_init
Jd=[3,3,3];     % Kernel width of convolution
Nd=fg.idim(1:3);
Gd=[Nd*2];    % Overgridding ratio
n_shift=Nd/2;
n_shift(3)=+Nd(3); % If third dimension is uneven

% Normalize k-space coords
kxy_max=max(abs(matrix_to_vec(fg.k(1:2,:))));
kz_max=max(abs(matrix_to_vec(fg.k(3,:))));
fg.k(1:2,:,:,:,:,:,:,:,:,:,:,:,:)=fg.k(1:2,:,:,:,:,:,:,:,:,:,:,:,:)/kxy_max;
fg.k(3,:,:,:,:,:,:,:,:,:,:,:,:)=fg.k(3,:,:,:,:,:,:,:,:,:,:,:,:)/kz_max;

% Create a seperate struct for all the dimensions that need seperate trajectories
for avg=1:kdim(12) % Averages
for ex2=1:kdim(11) % Extra2
for ex1=1:kdim(10) % Extra1
for mix=1:kdim(9)  % Locations
for loc=1:kdim(8)  % Mixes
for ech=1:kdim(7)  % Phases
for ph=1:kdim(6)   % Echos
for dyn=1:kdim(5)  % Dynamics
    om=[fg.k(1,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg);fg.k(2,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg);fg.k(3,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg)]'*pi;
    fg.st{dyn,ph,ech,loc,mix,ex1,ex2,avg} = nufft_init(om, Nd, Jd, Gd, n_shift,'table', 2^12,'minmax:kb');
end % Dynamics
end % Echos
end % Phases
end % Mixes
end % Locations
end % Extra1
end % Extra2
end % Averages

fg.phase=1;
fg.w=1;
fg.adjoint=0;
fg.mode=2;   % 2= complex image
fg=class(fg,'FG3D');

disp('+3D Fessler gridder operator initialized.')

% end
end

