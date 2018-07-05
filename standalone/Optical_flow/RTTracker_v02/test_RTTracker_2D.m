clc;
close all;
clear all;

addpath(pwd);

%%=========================  Read data file ================================================

[data,dimx,dimy,dimz,no_dyn] = load_dat('./data/abdomen2D.dat');

%%========================= Configuration parameters for the motion estimation library =====

%% Define registration method
%% 0: No motion estimation
%% 1: L2L2 optical flow algorithm
%% 2: L2L1 optical flow algorithm
id_registration_method = 2;

% Dynamic image used as the reference position
reference_dynamic = 20; 

%% Weighting factor (between 0 and 1) Close to 0: motion is highly sensitive to grey level intensity variation. Close to 1: the estimated motion is very regular along the space. See http://bsenneville.free.fr/RealTITracker/ for more informations
alpha = 0.3;   
if (id_registration_method == 2)
  alpha = 0.6;
end

%% Computation of the highest resolution level to perform
%% (accelerationFactor=0 => computation is done on all resolution levels,
%%  accelerationFactor=1 => computation is done on all resolution levels except the highest one)
accelerationFactor = 0;

%% Number of iterative raffinement within each resolution level 
nb_raffinement_level = 1;     

%%========================= Adjustement of grey level intensities =========================

%% Reverse image for display
for i = 1 : no_dyn  
  aux = data(:, :, 1, i);
  data(:, :, 1, i) =  flipud(aux');
end

%% Get the reference image for the registration
Iref = data(:, :, 1, reference_dynamic);

%% Normalize the reference image
Iref = (Iref - min(Iref(:)))/(max(Iref(:)) - min(Iref(:)));


%% Normalize all other images by adjusting the mean of the images (less sensitive to local grey level variations compared to a "min-max" method)
for i = 1 : no_dyn  
  aux = data(:, :, :, i);
  data(:, :, :, i) = aux * (mean(Iref(:))/mean(aux(:)));
end

%%========================= Initialisation of the RealTItracker library =============

%% Define registration parameters
RTTrackerWrapper(dimx, dimy, dimz, ...
		 id_registration_method, ...
		 nb_raffinement_level, ...
		 accelerationFactor, ...
		 alpha);  

%%========================= Registration loop over the dynamically acquired images ======

for i = 1 : no_dyn  

  %% Get the current image  
  I = data(:, :, 1, i);
  
  %% Estimate the motion between the reference and the current images
  RTTrackerWrapper(Iref, I);
  
  % Apply the estimated motion on the current image
  [registered_image] = RTTrackerWrapper(I);
  
  % Get the estimated motion field
  [motion_field] = RTTrackerWrapper();

  %% Display registered images & estimated motion field
  display_result2D(Iref,I,registered_image,motion_field);
  
  pause(0.01);
  
end

%%========================= Close the RealTItracker library ===========================

RTTrackerWrapper();
