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

%% Optional switch to distinguish 2D multislice registration/3D registration (if no parameter is set, a 2D registration is performed for dimz=1 and a 3D registration is performed for dimz>1)
do_2D_registration = 1;

%% Select the slice for which we will display the results
num_display_slice = 2;

%%========================= Simulate multislice data  =========================
dimz = 3;
data_multislice = zeros(dimx,dimy,dimz,no_dyn);
data_multislice(:,:,1,:) = data;
data_multislice(:,:,2,:) = max(data(:))-data;
data_multislice(:,:,3,:) = data;
clear data;

%%========================= Adjustement of grey level intensities =========================

%% Reverse image for display
for i = 1 : no_dyn  
  for z = 1 : dimz
    aux = data_multislice(:, :, z, i);
    data_multislice(:, :, z, i) =  flipud(aux');
  end
end

%% Get the reference image for the registration
Iref = data_multislice(:, :, :, reference_dynamic);

%% Normalize the reference image
for z = 1 : dimz
  aux = Iref(:,:,z);
  Iref(:,:,z) = (aux - min(aux(:)))/(max(aux(:)) - min(aux(:)));
end

%% Normalize all other images by adjusting the mean of the images (less sensitive to local grey level variations compared to a "min-max" method)
for i = 1 : no_dyn
  for z = 1 : dimz
    aux_ref = Iref(:,:,z);
    aux = data_multislice(:, :, z, i);
    data_multislice(:, :, z, i) = aux * (mean(aux_ref(:))/mean(aux(:)));
  end
end

%%========================= Initialisation of the RealTItracker library =============

%% Define registration parameters
RTTrackerWrapper(dimx, dimy, dimz, ...
		 id_registration_method, ...
		 nb_raffinement_level, ...
		 accelerationFactor, ...
		 alpha, ...
		 do_2D_registration);  

%%========================= Registration loop over the dynamically acquired images ======

for i = 1 : no_dyn  

  %% Get the current image  
  I = data_multislice(:, :, :, i);
  
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

  pause(0.01);
  
end

%%========================= Close the RealTItracker library ===========================

RTTrackerWrapper();
