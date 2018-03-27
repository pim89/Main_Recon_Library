function  fg = FG2D(k,kdim,varargin)
% Modified for 12D reconframe data
% Based on Miki Lustig his nufft operator
% Changed the input for the nufft_init. Use no overgridding anymore and a
% different interpolation kernel. minmax:tuned instead of minmax:kb. This
% one allowed not overgridding. It is approximately a factor 2 faster.


% Check input
if numel(kdim)<12
    kdim(end+1:12)=1;
    if kdim(3) > 1
        disp('+ K-space dim(3) cannot be larger then 1 for 2D NUFFT.')
        return
    end
end

fg.parfor=0;

% Image space dimensions
fg.idim(1:2)=ceil(max(abs(k(1,:))));
fg.idim(3)=ceil(max(abs(k(3,:))));
if fg.idim(3)==0; fg.idim(3)=1;end
fg.idim=[fg.idim kdim(4:end)];

% K-space dimensions
fg.kdim=kdim;

% Mix the readouts and samples in advance
fg.k=reshape(k,[3 kdim(1)*kdim(2) 1 1 1 kdim(5:12)]);clear k 

% Input for nufft_init
Jd=[4,4];     % Kernel width of convolution
Nd=fg.idim(1:2);
Gd=[Nd*1];    % Overgridding ratio
n_shift=Nd/2;

% Normalize k-space coords
fg.k=fg.k/max(abs(fg.k(:)));

% Create a seperate struct for all the dimensions that need seperate trajectories
for avg=1:kdim(12) % Averages
for ex2=1:kdim(11) % Extra2
for ex1=1:kdim(10) % Extra1
for mix=1:kdim(9)  % Locations
for loc=1:kdim(8)  % Mixes
for ech=1:kdim(7)  % Phases
for ph=1:kdim(6)   % Echos
for dyn=1:kdim(5)  % Dynamics
    om=[fg.k(1,:,:,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg); fg.k(2,:,:,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg)]'*pi;
    fg.st{dyn,ph,ech,loc,mix,ex1,ex2,avg} = nufft_init(om, Nd, Jd, Gd, n_shift,'minmax:tuned');
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
fg=class(fg,'FG2D');

disp('+2D Fessler gridder operator initialized.')
% end
end

