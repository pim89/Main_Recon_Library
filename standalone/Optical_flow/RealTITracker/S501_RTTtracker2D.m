function [CC,AP]=S501_RTTtracker2D(data,dimx,dimy,no_dyn,ref)
% Version 20151019 || t.bruijnen@student.tue.nl
%% =========================  Read data file ================================================
% % 
% [data,dimx,dimy,dimz,no_dyn] = load_dat('./data/abdomen2D.dat');

%%========================= Configuration parameters for the motion estimation library =====
dimz=1;
data=reshape(data,dimx,dimy,dimz,no_dyn); % Reshape
id_registration_method = 1;


%% 0: No motion estimation
%% 1: Horn&Schunk algorithm (only the alpha parameter has to be fixed)
%% 2: Cornelius&Kanade algorithm (small improvement of H&S method: both alpha and beta parameters have to be fixed)

% Dynamic image used as the reference position
reference_dynamic      = ref; 

%% Weighting factor (between 0 and 1) Close to 0: motion is highly sensitive to grey level intensity variation. Close to 1: the estimated motion is very regular along the space. See http://bsenneville.free.fr/RealTITracker/ for more informations
alpha                  = 0.12;   

%% Relaxation of the grey level intensity conservation (introduced by Cornelius&Kanade) 
%% Close to 0: no relaxation, Toward infinity: high relaxation. 
%% A value of 10.0-20.0 is typically found in the litterature.
beta                   = 10.0;  

%% Computation of the highest resolution level to perform
%% (accelerationFactor=0 => computation is done on all resolution levels,
%%  accelerationFactor=1 => computation is done on all resolution levels except the highest one)
accelerationFactor     = 0;

%% Number of iterative raffinement within each resolution level 
nb_raffinement_level   = 1;     

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

%%========================= Initialisation of the RealTItracker library =============

%% Define registration parameters
RTTrackerWrapper(dimx, dimy, dimz, ...
		 id_registration_method, ...
		 nb_raffinement_level, ...
		 accelerationFactor, ...
		 alpha, beta);  

%%========================= Registration loop over the dynamically acquired images ======
% Preallocate matrices
CC=zeros(no_dyn-1,1);
AP=zeros(no_dyn-1,1);

% Select outline GTV
dMASK=outlines(MASK);

for i = 1 : no_dyn-1  

  %% Get the current image  
  I = magnitude(:, :, :, i);
  
  %% Estimate the motion between the reference and the current images
  RTTrackerWrapper(Iref, I);
  
  % Apply the estimated motion on the current image
  [registered_image] = RTTrackerWrapper(I);
  
  % Get the estimated motion field
  [motion_field] = RTTrackerWrapper();%.*dMASK;

  % Seperate AP/CC and select 95th percentile
%   [cc,ap] = orderdata(motion_field,97.5);
%   CC(i)=sum(cc)/length(cc); % Calculate mean
%   CC(isnan(CC))=0; % Get rid off NaN
%   AP(i)=sum(ap)/length(ap); % Maybe put at end of function
%   AP(isnan(AP))=0;

  %% Display registered images & estimated motion field
  [u2,v2]=display_result2D(Iref,I,registered_image,motion_field,MASK);
  pause(0.1)
  figure(2);
  imagesc(abs(motion_field))
  colorbar
%   
end

%% ========================= Close the RealTItracker library ===========================

RTTrackerWrapper();
% END
end