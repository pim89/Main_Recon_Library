%% Demonstration script
% Note: for windows replace all "/" with "/" and vice versa.
clear all;close all;clc
datapath1='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/PROSTATE/T1TFE/rn_02052018_1754081_10_2_wip_radial_t1tfeV4.raw'; % Golden angle stack-of-stars

recon=mrriddle_reconstruction(datapath1);

load('/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/PROSTATE/T1TFE/EXPW/MRIDDLE.mat', 'mrriddle_nufft')
writeDicomFromMRecon(MR,flip(mrriddle_nufft(:,:,11:end-21,:),3),'/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/PROSTATE/T1TFE/EXPW/DICOM_NUFFT/');
clear mrriddle_nuft

load('/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/PROSTATE/T1TFE/EXPW/MRIDDLE.mat', 'mrriddle_cs')
writeDicomFromMRecon(MR,flip(mrriddle_cs(:,:,11:end-21,:),3),'/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/PROSTATE/T1TFE/EXPW/DICOM_CS/');
