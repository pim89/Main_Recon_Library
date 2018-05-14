clc;
close all;
clear all;

addpath(pwd);

%%=========================  Read data file ================================================

[data,dimx,dimy,dimz,no_dyn] = load_dat('./data/abdomen3D.dat');

%%========================= Configuration parameters for the motion estimation library =====

id_registration_method = 1;
%% 0: No motion estimation
%% 1: Horn&Schunk algorithm (only the alpha parameter has to be fixed)
%% 2: Cornelius&Kanade algorithm (small improvement of H&S method: both alpha and beta parameters have to be fixed)

% Dynamic image used as the reference position
reference_dynamic      = 1; 

%% Number of iterative raffinement within each resolution level 
%% (0: no raffinement. 1: Allows estimating possible residual motions. 
%% Toward infinity: introduce a bias in the registration process due to partial volume effect. 
%% This value has a direct impact on the computation time. 
%% A value of 0 or 1 are a good compromise in term of performance/accuracy. 
%% A value of 1 provides probably better results for swallow images for which local displacements are importants)   
nb_raffinement_level   = 1;     

%% Weighting factor (between 0 and 1) Close to 0: motion is highly sensitive to grey level intensity variation. Close to 1: the estimated motion is very regular along the space. A value of 0.5 in 2D, and 0.1 in 3D, were found to be a good compromise in term of precision/accuracy.
alpha                  = 0.1;   

%% Relaxation of the grey level intensity conservation (introduced by Cornelius&Kanade) 
%% Close to 0: no relaxation, Toward infinity: high relaxation. 
%% A value of 10.0-20.0 is typically found in the litterature.
beta                   = 20;  

%% Computation of the highest resolution level to perform
%% (accelerationFactor=0 => computation is done on all resolution levels,
%%  accelerationFactor=1 => computation is done on all resolution levels except the highest one)
accelerationFactor = 1;

%%========================= Adjustement of grey level intensities =========================

magnitude = data;

%% Get the reference image for the registration
Iref = magnitude(:, :, :, reference_dynamic);

%% Normalize the reference image
Iref = (Iref - min(Iref(:)))/(max(Iref(:)) - min(Iref(:)));

%% Normalize all other magnitude images by adjusting the mean of the images (less sensitive to local grey level variations compared to a "min-max" method)
for i = 1 : no_dyn  
  aux = magnitude(:, :, :, i);
  magnitude(:, :, :, i) = aux * (mean(Iref(:))/mean(aux(:)));
end

%%========================= Initialisation of the motion estimation library =============

%% Define registration parameters
RTTrackerWrapper(dimx, dimy, dimz, ...
		 id_registration_method, ...
		 nb_raffinement_level, ...
		 accelerationFactor, ...
		 alpha, beta);  

%%========================= Registration loop over the dynamically acquired images ======

for i = 2 : no_dyn  

  %% Get the current image  
  I = magnitude(:, :, :, i);
  
  %% Estimate the motion between the reference and the current images
  RTTrackerWrapper(Iref, I);
  
  % Apply the estimated motion on the current image
  [registered_image] = RTTrackerWrapper(I);
  
  % Get the estimated motion field
  [motion_field] = RTTrackerWrapper();

  %% Display registered images & estimated motion field
  display_result3D(Iref,I,registered_image,motion_field);

end

%%========================= Close the motion estimation library ===========================
RTTrackerWrapper();
