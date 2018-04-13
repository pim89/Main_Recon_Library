clear all;close all;clc
datapath1='../Data/SOS_GA/bs_06122016_1607476_2_2_wip4dga1pfnoexperiment1senseV4.raw'; % Golden angle stack-of-stars

kspace_data=reader_reconframe_lab_raw(datapath1,1,1);
kdim=size(kspace_data);
traj=radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);
kspace_data=ifft(kspace_data,[],3);
kspace_data=radial_phase_correction_zero(kspace_data);
F2D=FG2D(traj,kdim);
img=F2D'*bsxfun(@times,kspace_data,dcf);
img=sum(abs(img),4);

% 
kspace_data=reader_reconframe_lab_raw(datapath1,1,1);
kdim=size(kspace_data);
traj=radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);
kspace_data=ifft(kspace_data,[],3);
kspace_data=radial_phase_correction_zero(kspace_data);

R=8;
[kspace_data,traj,dcf]=radial_goldenangle_undersample(R,kspace_data,traj,dcf);
kdim=size(kspace_data);

F2D=FG2D(traj,kdim);
img=F2D'*bsxfun(@times,kspace_data,dcf);
img=sum(abs(img),4);
figure,imshow3(abs(img(:,:,5:28,1)),[],[4 6])
