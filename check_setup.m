%% Check if all the libraries are correctly installed and paths are set
% Check if current working directory is appropriate (needs to be
% ../Modular_Recon_Library/
curdir=pwd;
suc6=1;

if ~strcmpi(curdir(end-20:end),'Modular_Recon_Library')
    disp('Warning: Current directory is not set appropriately, should be /Modular_Recon_Library/');suc6=0;
end

% Check if bart toolbox is added to the path
if isempty(which('bart'))
    disp('Warning: BART toolbox is not installed or not added to the path');suc6=0;
end

% Check if Greengard NUFFT toolbox works
if isempty(which('nufft2d1')) || isempty(which('nufft3d1'))
    disp('Warning: Greengard NUFFT toolbox not fully installed or not added to path');suc6=0;
end

% Check if Fessler NUFFT toolbox works
if isempty(which('nufft_init')) 
    disp('Warning: Fessler NUFFT toolbox not fully installed or not added to path');suc6=0;
end

% Check if Reconframe is added to the path
if isempty(which('MRecon'))
    disp('Warning: Reconframe is not added to the path');suc6=0;
end

% Succesfull integration
if suc6
    disp('All toolboxes are succesfully installed and included to path')
end

