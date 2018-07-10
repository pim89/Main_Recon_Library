%% Setup paths appropriately
% Works differently for windows if you run BART via cygwin.

if ispc
% windows
    addpath(genpath('C:\cygwin64\bin\'))
    addpath(genpath('C:\cygwin64\home\tombruijnen\BART\'))
    addpath(genpath('C:\Users\tombruijnen\Documents\Programming\MATLAB\RECON_MAIN\Main_Recon_Library\'));
    addpath(genpath('C:\Users\tombruijnen\Documents\Programming\MATLAB\MRecon-3.0.541')); 
    addpath(fullfile('C:\cygwin64\home\tombruijnen\BART\','matlab'));
    setenv('TOOLBOX_PATH','C:\cygwin64\home\tombruijnen\BART\');
    fin_mode=0; % FINUFFT does not work for windows
    ute=0;
else
    % Linux
%     addpath(genpath('../Main_Recon_Library'))
%     addpath(fullfile('../Main_Recon_Library/standalone/bart-0.4.02/','matlab'));
%     setenv('TOOLBOX_PATH','../Main_Recon_Library/standalone/bart-0.4.02');
    
    addpath(genpath('../Main_Recon_Library'))
    addpath(genpath('/local_scratch2/tbruijne/BART/bart-0.4.02'))
    addpath(fullfile('/local_scratch2/tbruijne/BART/bart-0.4.02','matlab'));
    setenv('TOOLBOX_PATH','/local_scratch2/tbruijne/BART/bart-0.4.02');
    fin_mode=1;
    ute=1;
end