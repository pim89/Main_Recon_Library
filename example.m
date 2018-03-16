%% Example of multiple functions
clear all;close all;clc

%%% Readers
% Get k-space data from lab/raw
kdata=reader_reconframe_lab_raw('/local_scratch/tbruijne/WorkingData/4DGA/Scan2/bs_06122016_1607476_2_2_wip4dga1pfnoexperiment1senseV4.raw');

% Get images from par/rec
images=reader_reconframe_par_rec('/local_scratch/tbruijne/WorkingData/4DLung/Scan2/ha_27112017_1534304_8_1_wip_t_t1_4d_tfeV4.rec');

% Extract PPE parameters (from reconframe object)
[kdata,MR]=reader_reconframe_lab_raw('/local_scratch/tbruijne/WorkingData/4DGA/Scan2/bs_06122016_1607476_2_2_wip4dga1pfnoexperiment1senseV4.raw');
ppe_pars=reader_reconframe_ppe_pars(MR);

% Write data to dicom
MR.Perform;
writeDicomFromMRecon(MR,MR.Data,'../Modular_Recon_Library/');

