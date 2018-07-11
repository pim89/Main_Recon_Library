function  bg = BG2D(k,kdim,varargin)
% Modified for 12D reconframe data
% NUFFT using the BART toolbox

% Check input
if numel(kdim)<12
    kdim(end+1:12)=1;
end

% Image space dimensions
if isempty(varargin)
    bg.idim(1:2)=ceil(max(abs(matrix_to_vec(k([1 2],:)))));
    bg.idim(3)=ceil(max(abs(k(3,:))));
    if bg.idim(3)==0; bg.idim(3)=1;end
    bg.idim=[bg.idim kdim(4:end)];
else
    bg.idim=c12d(varargin{1});
end

% K-space dimensions
bg.kdim=kdim;

% Mix the readouts and samples in advance
bg.k=reshape(k,[3 kdim(1)*kdim(2) 1 1 1 kdim(5:12)]);clear k 

% Normalize k-space coords
bg.k=bg.k/max(abs(bg.k(:)));

% Generate BART calls
bg.nufft=['nufft -d ',num2str(bg.idim(1:2))];
bg.nufft_adj=['nufft -a -d ',num2str(bg.idim(1:2))];

disp('+2D BART NUFFT operator initialized.')
% end
end

