%% Check if all the libraries are correctly installed and paths are set
% Check if current working directory is appropriate (needs to be
% ../Modular_Recon_Library/
curdir=pwd;
suc6=1;

if ~strcmpi(curdir(end-17:end),'Main_Recon_Library')
    disp('Warning: Current directory is not set appropriately, should be /../Main_Recon_Library/');suc6=0;
end

% Check if bart toolbox is added to the path
try
    bart;
catch
    suc6=0;
    if isempty(which('bart'))
        disp('+ BART toolbox is not added to the path');
    else
        disp('+ BART toolbox is not installed');
    end
end

% Check if Greengard NUFFT toolbox works
try
    nufft2d1(1,1,1,1,1,1E-15,1,1);
    nufft3d1(1,1,1,1,1,1,1E-15,1,1,1);
catch
    suc6=0;
    if isempty(which('nufft2d1')) || isempty(which('nufft3d1'))
        disp('+ Greengard NUFFT toolbox not added to path');
    else
        disp('+ Greengard NUFFT toolbox not compiled');
    end
end

% Check if Fessler NUFFT toolbox works
try
    back_grid(1+1j,1,1,1,1,1,1,1,1);
catch
    suc6=0;
    if isempty(which('nufft2d1')) || isempty(which('nufft3d1'))
        disp('+ Fessler NUFFT toolbox not added to path');
    else
        disp('+ Fessler NUFFT toolbox not compiled');
    end
end

% Check if Reconframe is added to the path
try
    fftshiftc(single(1),(1));
catch
    suc6=0;
    if isempty(which('MRecon'))
        disp('+ Reconframe is not added to the path');
    else
         disp('+ Reconframe is not installed/compiled');
    end
end

% Check if iterative DCF code is added to the path
try
    a=sdc3_MAT(.5*rand(3,2,2,2),1,2,0);
catch
    suc6=0;
    if isempty(which('sdc3_MAT'))
        disp('+ Iterative DCF code is not added to the path');
    else
        disp('+ Iterative DCF code is not installed');
    end
end

% Succesfull integration
if suc6
    disp('+ All toolboxes are succesfully installed and included to path')
end

