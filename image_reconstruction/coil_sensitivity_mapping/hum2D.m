function [img_filt,mask,bias] = hum2D(img,mask)
% Inhomogeneity correction function
% Initially made by Federico D'Agata
% Adjusted by Tom Bruijnen

% Check input
if ~isreal(img)
    img=abs(img);
end

% Create mask if none is provided
if nargin < 3
    mask=ones(size(img));               
end

% HUM part
img_small=imresize(img,[64 64]);
dim=size(img_small);
[X,Y] = meshgrid(1:dim(1), 1:dim(2));
x1d = reshape(X, numel(X), 1);
y1d = reshape(Y, numel(Y), 1);

%z1d = double(reshape(z, numel(z), 1));
x = [x1d y1d];

%--------------------------------------------------------
% Get a 4th order polynomial model.
% CHANGE THE ORDER HERE IF YOU WANT TO.
%--------------------------------------------------------
polynomialOrder = 6;
p = polyfitn(x, img_small(:), polynomialOrder);

% Evaluate on a grid and plot:
zg = polyvaln(p, x);
bias = demax(imresize(reshape(zg, dim(1:2)),[size(img,1) size(img,2)]));
bias(bias < .4 )=.4; % Limit correction factor to ~2.5
%bias(bias==0)=mean(nonzeros(bias(:)));

img_filt=mask.*(img./bias);

end
