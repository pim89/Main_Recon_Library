clc;
close all;
clear all;

addpath(pwd);

%%=========================  Read data file ================================================

[data,dimx,dimy,dimz,no_dyn] = load_dat('./data/abdomen3D.dat');

%%========================= Configuration parameters for the motion estimation library =====

%% Define registration method
%% 0: No motion estimation
%% 1: L2L2 optical flow algorithm
%% 2: L2L1 optical flow algorithm
id_registration_method = 2;

% Dynamic image used as the reference position
reference_dynamic = 1; 

%% Number of iterative raffinement within each resolution level 
%% (0: no raffinement. 1: Allows estimating possible residual motions. 
%% Toward infinity: introduce a bias in the registration process due to partial volume effect. 
%% This value has a direct impact on the computation time. 
%% A value of 0 or 1 are a good compromise in term of performance/accuracy. 
nb_raffinement_level = 1;     

%% Weighting factor (between 0 and 1) Close to 0: motion is highly sensitive to grey level intensity variation. Close to 1: the estimated motion is very regular along the space. A value of 0.3 in 2D, and 0.1 in 3D, were found to be a good compromise in term of precision/accuracy for the L2L2 optical flow algorithm.
alpha = 0.1;   
if (id_registration_method == 2)
  alpha = 0.4;
end

%% Computation of the highest resolution level to perform
%% (accelerationFactor=0 => computation is done on all resolution levels,
%%  accelerationFactor=1 => computation is done on all resolution levels except the highest one)
accelerationFactor = 1;

%%========================= Adjustement of grey level intensities =========================

%% Get the reference image for the registration
Iref = data(:, :, :, reference_dynamic);

%% Normalize the reference image
Iref = (Iref - min(Iref(:)))/(max(Iref(:)) - min(Iref(:)));

%% Normalize all other images by adjusting the mean of the images (less sensitive to local grey level variations compared to a "min-max" method)
for i = 1 : no_dyn  
  aux = data(:, :, :, i);
  data(:, :, :, i) = aux * (mean(Iref(:))/mean(aux(:)));
end

%%========================= Initialisation of the motion estimation library =============

%% Define registration parameters
RTTrackerWrapper(dimx, dimy, dimz, ...
		 id_registration_method, ...
		 nb_raffinement_level, ...
		 accelerationFactor, ...
		 alpha);  

%%========================= Registration loop over the dynamically acquired images ======

for i = 2 : no_dyn  

  %% Get the current image  
  I = data(:, :, :, i);
  
  %% Estimate the motion between the reference and the current images
  disp('Estimating 3D motion...');
  RTTrackerWrapper(Iref, I);
  
  % Apply the estimated motion on the current image
  [registered_image] = RTTrackerWrapper(I);
  
  % Get the estimated motion field
  [motion_field] = RTTrackerWrapper();

  %% Display registered images & estimated motion field
  display_result3D(Iref,I,registered_image,motion_field);

  pause(0.01);
  
end

%%========================= Close the motion estimation library ===========================

RTTrackerWrapper();
