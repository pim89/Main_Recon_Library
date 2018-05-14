clc;
close all;
clear all;

addpath(pwd);

%%=========================  Read data file ================================================

[data,dimx,dimy,dimz,no_dyn] = load_dat('./data/abdomen2D.dat');

%%========================= Configuration parameters for the motion estimation library =====

id_registration_method = 1;
%% 0: No motion estimation
%% 1: Horn&Schunk algorithm (only the alpha parameter has to be fixed)
%% 2: Cornelius&Kanade algorithm (small improvement of H&S method: both alpha and beta parameters have to be fixed)

% Dynamic image used as the reference position
reference_dynamic      = 20; 

%% Weighting factor (between 0 and 1) Close to 0: motion is highly sensitive to grey level intensity variation. Close to 1: the estimated motion is very regular along the space. See http://bsenneville.free.fr/RealTITracker/ for more informations
alpha                  = 0.3;   

%% Relaxation of the grey level intensity conservation (introduced by Cornelius&Kanade) 
%% Close to 0: no relaxation, Toward infinity: high relaxation. 
%% A value of 10.0-20.0 is typically found in the litterature.
beta                   = 5.0;  

%% Computation of the highest resolution level to perform
%% (accelerationFactor=0 => computation is done on all resolution levels,
%%  accelerationFactor=1 => computation is done on all resolution levels except the highest one)
accelerationFactor     = 0;

%% Number of iterative raffinement within each resolution level 
nb_raffinement_level   = 1;     

%% Optional switch to distinguish 2D multislice registration/3D registration (if no parameter is set, a 2D registration is performed for dimz=1 and a 3D registration is performed for dimz>1)
do_2D_registration = 1;

%% Select the slice for which we will display the results
num_display_slice = 3;

%%========================= Simulate multislice data  =========================
dimz = 3;
data_multislice = zeros(dimx,dimy,dimz,no_dyn);
data_multislice(:,:,1,:) = data;
data_multislice(:,:,2,:) = data;
data_multislice(:,:,3,:) = data;

%%========================= Adjustement of grey level intensities =========================

magnitude = data_multislice;

%% Get the reference image for the registration
Iref = magnitude(:, :, :, reference_dynamic);

%% Normalize the reference image
Iref = (Iref - min(Iref(:)))/(max(Iref(:)) - min(Iref(:)));

%% Normalize all other magnitude images by adjusting the mean of the images (less sensitive to local grey level variations compared to a "min-max" method)
for i = 1 : no_dyn  
  aux = magnitude(:, :, :, i);
  magnitude(:, :, :, i) = aux * (mean(Iref(:))/mean(aux(:)));
end

%%========================= Initialisation of the RealTItracker library =============

%% Define registration parameters
RTTrackerWrapper(dimx, dimy, dimz, ...
		 id_registration_method, ...
		 nb_raffinement_level, ...
		 accelerationFactor, ...
		 alpha, beta, ...
		 do_2D_registration);  

%%========================= Registration loop over the dynamically acquired images ======

for i = 1 : no_dyn  

  %% Get the current image  
  I = magnitude(:, :, :, i);
  
  %% Estimate the motion between the reference and the current images
  RTTrackerWrapper(Iref, I);
  
  % Apply the estimated motion on the current image
  [registered_image] = RTTrackerWrapper(I);
  
  % Get the estimated motion field
  [motion_field] = RTTrackerWrapper();

  %% Display registered images & estimated motion field
  display_result2D(Iref(:,:,num_display_slice), ...
		   I(:,:,num_display_slice), ...
		   registered_image(:,:,num_display_slice), ...
		   motion_field(:,:,num_display_slice));

end

%%========================= Close the RealTItracker library ===========================

RTTrackerWrapper();
