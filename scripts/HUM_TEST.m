%% Effect of HUM on SOS | ESP | WALSH
clear all;close all;clc

exportfig=0;

%% T1 abdominal data
datapath='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/ABDOMEN/T1SPIR3/ut_26092017_1515142_9_2_wipt4dt1tfespirclearV4.raw'; % T1SPIR3
[~,MR]=reader_reconframe_lab_raw(datapath,1);
MR.Data=ifft(MR.Data,MR.Parameter.Encoding.ZReconRes,3);
MR.Data=radial_phase_correction_zero(MR.Data);
kdim=c12d(size(MR.Data));
traj=1.25*radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);

% Initialize Fessler 2D nufft operator
F2D=FG2D(traj,kdim);

% Do the Fessler gridding
z=16;
recon=single(flip(flip(F2D'*(bsxfun(@times,MR.Data,dcf)),1),3));

% Tune-able stuff for HUM
sigmag=35;

% HUM - I need a smarter masking algorithm
recon_sos=squeeze(sos(recon,4));
[recon_sos_hum,mask_sos,bias_sos]=hum3D(recon_sos);

tic
csm_espirit=espirit(recon,'bart');
toc
recon_espirit=sum(recon.*conj(csm_espirit),4);
[recon_espirit_hum,mask_espirit,bias_espirit]=hum3D(abs(recon_espirit));

csm_walsh=openadapt(recon);
recon_walsh=sum(recon.*conj(csm_walsh),4);
[recon_walsh_hum,mask_walsh,bias_walsh]=hum(abs(recon_walsh));

cfac=2.3;
figure,imshow3(cfac*cat(3,demax(recon_sos),demax(recon_sos_hum.*mask_sos),demax(bias_sos),...
    demax(abs(recon_espirit)),demax(recon_espirit_hum.*mask_espirit),demax(bias_espirit),...
    demax(abs(recon_walsh)),demax(recon_walsh_hum.*mask_walsh),demax(bias_walsh)),[0.05 1],[3 3])
title('SOS | SOS + HUM | BIAS','FontSize',24);set(gcf,'Position',[10 10 1200 1000])

if exportfig
export_fig /nfs/bsc01/researchData/USER/tbruijne/Projects_Software/CoilCombination/MRL_RADIALT1.jpg -r600
end

%% T1 abdominal data 2
datapath='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/ABDOMEN/T1SPIR1/ut_28092017_1137425_5_2_wipt4dt1tfespirclearV4.raw'; 
[~,MR]=reader_reconframe_lab_raw(datapath,1);
[noise,~]=reader_reconframe_lab_raw(datapath,5);
MR.Data=ifft(MR.Data,MR.Parameter.Encoding.ZReconRes,3);
MR.Data=radial_phase_correction_zero(MR.Data);
kdim=c12d(size(MR.Data));
traj=1.25*radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);

% Initialize Fessler 2D nufft operator
F2D=FG2D(traj,[kdim(1:2) 1 kdim(4)]);

% Do the Fessler gridding
z=16;
recon=single(flip(flip(F2D'*(bsxfun(@times,MR.Data(:,:,z,:,:),dcf)),1),3));

% Tune-able stuff for HUM
sigmag=25;

% HUM - I need a smarter masking algorithm
recon_sos=squeeze(sos(recon,4));
[recon_sos_hum,mask_sos,bias_sos]=hum(recon_sos);

tic
csm_espirit=espirit(recon,'bart');
toc
recon_espirit=sum(recon.*conj(csm_espirit),4);
[recon_espirit_hum,mask_espirit,bias_espirit]=hum(abs(recon_espirit));

csm_walsh=openadapt(recon);
recon_walsh=sum(recon.*conj(csm_walsh),4);
[recon_walsh_hum,mask_walsh,bias_walsh]=hum(abs(recon_walsh));

cfac=1;
figure,imshow3(cfac*cat(3,demax(recon_sos),demax(recon_sos_hum.*mask_sos),demax(bias_sos),...
    demax(abs(recon_espirit)),demax(recon_espirit_hum.*mask_espirit),demax(bias_espirit),...
    demax(abs(recon_walsh)),demax(recon_walsh_hum.*mask_walsh),demax(bias_walsh)),[0 1],[3 3])
title('SOS | SOS + HUM | BIAS','FontSize',24);set(gcf,'Position',[10 10 1200 1000])

%% B abdominal data 2
datapath='/nfs/bsc01/researchData/USER/tbruijne/MR_Data/Internal_data/Radial3D_data/MR21/20161220_4DGA_volunteer/Scan2/pb_20122016_1632484_22_2_wiptbffega11000pf072clearV4.raw'; 
[~,MR]=reader_reconframe_lab_raw(datapath,1);
[noise,~]=reader_reconframe_lab_raw(datapath,5);
MR.Data=ifft(MR.Data,MR.Parameter.Encoding.ZReconRes,3);
MR.Data=radial_phase_correction_zero(MR.Data);
kdim=c12d(size(MR.Data));
traj=1.25*radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);

% Initialize Fessler 2D nufft operator
F2D=FG2D(traj,[kdim(1:2) 1 kdim(4)]);

% Do the Fessler gridding
z=16;
recon=single(flip(flip(F2D'*(bsxfun(@times,MR.Data(:,:,z,:,:),dcf)),1),3));

% Tune-able stuff for HUM
sigmag=22;

% HUM - I need a smarter masking algorithm
recon_sos=squeeze(sos(recon,4));
[recon_sos_hum,mask_sos,bias_sos]=hum(recon_sos);

tic
csm_espirit=espirit(recon,'bart');
toc
recon_espirit=sum(recon.*conj(csm_espirit),4);
[recon_espirit_hum,mask_espirit,bias_espirit]=hum(abs(recon_espirit));

csm_walsh=openadapt(recon);
recon_walsh=sum(recon.*conj(csm_walsh),4);
[recon_walsh_hum,mask_walsh,bias_walsh]=hum(abs(recon_walsh));

cfac=1.6;
figure,imshow3(cfac*cat(3,demax(recon_sos),demax(recon_sos_hum.*mask_sos),demax(bias_sos),...
    demax(abs(recon_espirit)),demax(recon_espirit_hum.*mask_espirit),demax(bias_espirit),...
    demax(abs(recon_walsh)),demax(recon_walsh_hum.*mask_walsh),demax(bias_walsh)),[0 1],[3 3])
title('SOS | SOS + HUM | BIAS','FontSize',24);set(gcf,'Position',[10 10 1200 1000])

if exportfig
export_fig /nfs/bsc01/researchData/USER/tbruijne/Projects_Software/CoilCombination/MRL_RADIALB2.jpg -r600
end

%% B abdominal data 3
datapath='/nfs/bsc01/researchData/USER/tbruijne/MR_Data/Internal_data/Radial3D_data/MR21/20161220_4DGA_volunteer/Scan1/pb_20122016_1613188_14_2_wiptbffega11000clearV4.raw'; 
[~,MR]=reader_reconframe_lab_raw(datapath,1);
[noise,~]=reader_reconframe_lab_raw(datapath,5);
MR.Data=ifft(MR.Data,MR.Parameter.Encoding.ZReconRes,3);
MR.Data=radial_phase_correction_zero(MR.Data);
kdim=c12d(size(MR.Data));
traj=1.25*radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);

% Initialize Fessler 2D nufft operator
F2D=FG2D(traj,[kdim(1:2) 1 kdim(4)]);

% Do the Fessler gridding
z=8;
recon=single(flip(flip(F2D'*(bsxfun(@times,MR.Data(:,:,z,:,:),dcf)),1),3));

% Tune-able stuff for HUM
sigmag=22;

% HUM - I need a smarter masking algorithm
recon_sos=squeeze(sos(recon,4));
[recon_sos_hum,mask_sos,bias_sos]=hum(recon_sos);

csm_espirit=espirit(recon,'bart');
recon_espirit=sum(recon.*conj(csm_espirit),4);
[recon_espirit_hum,mask_espirit,bias_espirit]=hum(abs(recon_espirit));

csm_walsh=openadapt(recon);
recon_walsh=sum(recon.*conj(csm_walsh),4);
[recon_walsh_hum,mask_walsh,bias_walsh]=hum(abs(recon_walsh));

cfac=1.9;
figure,imshow3(cfac*cat(3,demax(recon_sos),demax(recon_sos_hum.*mask_sos),demax(bias_sos),...
    demax(abs(recon_espirit)),demax(recon_espirit_hum.*mask_espirit),demax(bias_espirit),...
    demax(abs(recon_walsh)),demax(recon_walsh_hum.*mask_walsh),demax(bias_walsh)),[0 1],[3 3])
title('SOS | SOS + HUM | BIAS','FontSize',24);set(gcf,'Position',[10 10 1200 1000])

if exportfig
export_fig /nfs/bsc01/researchData/USER/tbruijne/Projects_Software/CoilCombination/MRL_RADIALB3.jpg -r600
end
%% B abdominal data
datapath='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/ABDOMEN/BSPIR1/ut_14092017_1537185_7_2_wipt4dbffedceclearV4.raw';
[~,MR]=reader_reconframe_lab_raw(datapath,1);
MR.Data=ifft(MR.Data,MR.Parameter.Encoding.ZReconRes,3);
MR.Data=radial_phase_correction_zero(MR.Data);
kdim=c12d(size(MR.Data));
traj=1.25*radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);

% Initialize Fessler 2D nufft operator
%F2D=FG2D(traj,[kdim(1:2) 1 kdim(4)]);
F2D=FG2D(traj,kdim);


% Do the Fessler gridding
z=16;
%recon=single(flip(flip(F2D'*(bsxfun(@times,MR.Data(:,:,z,:,:),dcf)),1),3));
recon=single(flip(flip(F2D'*(bsxfun(@times,MR.Data,dcf)),1),3));


% Tune-able stuff for HUM
sigmag=35;

% HUM - I need a smarter masking algorithm
recon_sos=squeeze(sos(recon,4));
[recon_sos_hum,mask_sos,bias_sos]=hum3D(recon_sos);

tic
csm_espirit=espirit(recon,'bart');
toc
recon_espirit=sum(recon.*conj(csm_espirit),4);
[recon_espirit_hum,mask_espirit,bias_espirit]=hum3D(abs(recon_espirit));

csm_walsh=openadapt(recon);
recon_walsh=sum(recon.*conj(csm_walsh),4);
[recon_walsh_hum,mask_walsh,bias_walsh]=hum3D(abs(recon_walsh));

cfac=1.2;
figure,imshow3(cfac*cat(3,demax(recon_sos),demax(recon_sos_hum.*mask_sos),demax(bias_sos),...
    demax(abs(recon_espirit)),demax(recon_espirit_hum.*mask_espirit),demax(bias_espirit),...
    demax(abs(recon_walsh)),demax(recon_walsh_hum.*mask_walsh),demax(bias_walsh)),[0 1],[3 3])
title('SOS | SOS + HUM | BIAS','FontSize',24);set(gcf,'Position',[10 10 1200 1000])

if exportfig
export_fig /nfs/bsc01/researchData/USER/tbruijne/Projects_Software/CoilCombination/MRL_RADIALB.jpg -r600
end

%% B abdominal data no spir
datapath='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/ABDOMEN/BNOSPIR1/ut_28092017_1122351_3_2_wipt4dbffeclearV4.raw';
[~,MR]=reader_reconframe_lab_raw(datapath,1);
MR.Data=ifft(MR.Data,MR.Parameter.Encoding.ZReconRes,3);
MR.Data=radial_phase_correction_zero(MR.Data);
kdim=c12d(size(MR.Data));
traj=1.25*radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);

% Initialize Fessler 2D nufft operator
F2D=FG2D(traj,[kdim(1:2) 1 kdim(4)]);

% Do the Fessler gridding
z=25;
recon=single(flip(flip(F2D'*(bsxfun(@times,MR.Data(:,:,z,:,:),dcf)),1),3));

% Tune-able stuff for HUM
sigmag=35;

% HUM - I need a smarter masking algorithm
recon_sos=squeeze(sos(recon,4));
[recon_sos_hum,mask_sos,bias_sos]=hum(recon_sos);

tic
csm_espirit=espirit(recon,'bart');
toc
recon_espirit=sum(recon.*conj(csm_espirit),4);
[recon_espirit_hum,mask_espirit,bias_espirit]=hum(abs(recon_espirit));

csm_walsh=openadapt(recon);
recon_walsh=sum(recon.*conj(csm_walsh),4);
[recon_walsh_hum,mask_walsh,bias_walsh]=hum(abs(recon_walsh));

cfac=1.2;
figure,imshow3(cfac*cat(3,demax(recon_sos),demax(recon_sos_hum.*mask_sos),demax(bias_sos),...
    demax(abs(recon_espirit)),demax(recon_espirit_hum.*mask_espirit),demax(bias_espirit),...
    demax(abs(recon_walsh)),demax(recon_walsh_hum.*mask_walsh),demax(bias_walsh)),[0 1],[3 3])
title('SOS | SOS + HUM | BIAS','FontSize',24);set(gcf,'Position',[10 10 1200 1000])

if exportfig
export_fig /nfs/bsc01/researchData/USER/tbruijne/Projects_Software/CoilCombination/MRL_RADIALBNOSPIR.jpg -r600
end

%% T1 pelvis data
datapath='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/PROSTATE/T1TFE1/rn_02052018_1754081_10_2_wip_radial_t1tfeV4.raw';
[~,MR]=reader_reconframe_lab_raw(datapath,1);
MR.Data=ifft(MR.Data,MR.Parameter.Encoding.ZReconRes,3);
MR.Data=radial_phase_correction_zero(MR.Data);
kdim=c12d(size(MR.Data));
traj=1.25*radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);

% Initialize Fessler 2D nufft operator
F2D=FG2D(traj,[kdim(1:2) 1 kdim(4)]);

% Do the Fessler gridding
z=25;
recon=single(flip(flip(F2D'*(bsxfun(@times,MR.Data(:,:,z,:,:),dcf)),1),3));

% Tune-able stuff for HUM
sigmag=40;

% HUM - I need a smarter masking algorithm
recon_sos=squeeze(sos(recon,4));
[recon_sos_hum,mask_sos,bias_sos]=hum(recon_sos);

csm_espirit=espirit(recon,'bart');
recon_espirit=sum(recon.*conj(csm_espirit),4);
[recon_espirit_hum,mask_espirit,bias_espirit]=hum(abs(recon_espirit));

csm_walsh=openadapt(recon);
recon_walsh=sum(recon.*conj(csm_walsh),4);
[recon_walsh_hum,mask_walsh,bias_walsh]=hum(abs(recon_walsh));

cfac=1.5;
figure,imshow3(cfac*cat(3,demax(recon_sos),demax(recon_sos_hum.*mask_sos),demax(bias_sos),...
    demax(abs(recon_espirit)),demax(recon_espirit_hum.*mask_espirit),demax(bias_espirit),...
    demax(abs(recon_walsh)),demax(recon_walsh_hum.*mask_walsh),demax(bias_walsh)),[0 1],[3 3])
title('SOS | SOS + HUM | BIAS','FontSize',24);set(gcf,'Position',[10 10 1200 1000])

if exportfig
export_fig /nfs/bsc01/researchData/USER/tbruijne/Projects_Software/CoilCombination/MRL_RADIALT1_PELVIS.jpg -r600
end