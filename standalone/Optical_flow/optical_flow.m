function [dvf, f_img] = optical_flow(data,alpha,ref,varargin)
% Perform image registration on a 2D+time matrix with spatial regularization parameter alpha
id_registration_method = 1;
dimx=size(data,1);
dimy=size(data,2);
dimz=size(data,3);
no_dyn=size(data,4);

% Check input
if nargin < 4
    MASK=ones(dimx,dimy,dimz);
end

if ref > no_dyn
    dvf=[];
    disp('Reference is large then number of dynamics')
    return;
end

if alpha < 0 || alpha > 1
    dvf=[];
    disp('Alpha should be within [0 1]')
    return;
end

if numel(size(data)) > 4
    dvf=[];
    disp('Only accepts 4D matrices [X Y Z TIME].')
    return;
end

%% 0: No motion estimation
%% 1: Horn&Schunk algorithm (only the alpha parameter has to be fixed)
%% 2: Cornelius&Kanade algorithm (small improvement of H&S method: both alpha and beta parameters have to be fixed)

% Dynamic image used as the reference position
reference_dynamic      = ref; 

%% Weighting factor (between 0 and 1) Close to 0: motion is highly sensitive to grey level intensity variation. Close to 1: the estimated motion is very regular along the space. See http://bsenneville.free.fr/RealTITracker/ for more informations
alpha                  = alpha;   

%% Relaxation of the grey level intensity conservation (introduced by Cornelius&Kanade) 
%% Close to 0: no relaxation, Toward infinity: high relaxation. 
%% A value of 10.0-20.0 is typically found in the literature.
beta                   = 10.0;  

%% Computation of the highest resolution level to perform
%% (accelerationFactor=0 => computation is done on all resolution levels,
%%  accelerationFactor=1 => computation is done on all resolution levels except the highest one)
accelerationFactor     = 0;

%% Number of iterative raffinement within each resolution level 
nb_raffinement_level   = 1;     

%%========================= Adjustement of grey level intensities =========================

magnitude = abs(data);

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
		 alpha);  

%%========================= Registration loop over the dynamically acquired images ======

for dyn = 1:no_dyn  
    
  %% Get the current image  
  I = magnitude(:, :, :, dyn);
  
  %% Estimate the motion between the reference and the current images
  RTTrackerWrapper(Iref, I);
  
  % Apply the estimated motion on the current image
  registered_image(:,:,:,dyn) = RTTrackerWrapper(I);
  
  % Get the estimated motion field
  dvf(:,:,:,:,dyn)= RTTrackerWrapper();

  %% Display registered images & estimated motion field
  %display_result2D(Iref,I,registered_image(:,:,:,dyn),dvf(:,:,:,:,dyn),MASK);
 
  
end

%% ========================= Close the RealTItracker library ===========================

RTTrackerWrapper();

% END
end