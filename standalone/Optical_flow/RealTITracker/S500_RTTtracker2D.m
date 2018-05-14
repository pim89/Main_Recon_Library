function [SI,AP]=S500_RTTtracker2D(data,dimx,dimy,no_dyn,ref,MASK)
% Version 20151019 || t.bruijnen@student.tue.nl
%% =========================  Read data file ================================================
% % 
% [data,dimx,dimy,dimz,no_dyn] = load_dat('./data/abdomen2D.dat');

%%========================= Configuration parameters for the motion estimation library =====
dimz=1;
data=reshape(data,dimx,dimy,dimz,no_dyn); % Reshape
id_registration_method = 1;

% Select outline GTV
dMASK=outlines(MASK);

% Create coordinate maps
xmap=repmat(1:dimx,[256,1]).*dMASK;
ymap=repmat((1:dimy)',[1,256]).*dMASK;
refSI=mean(nonzeros(ymap));
refAP=mean(nonzeros(xmap));

%% 0: No motion estimation
%% 1: Horn&Schunk algorithm (only the alpha parameter has to be fixed)
%% 2: Cornelius&Kanade algorithm (small improvement of H&S method: both alpha and beta parameters have to be fixed)

% Dynamic image used as the reference position
reference_dynamic      = ref; 

%% Weighting factor (between 0 and 1) Close to 0: motion is highly sensitive to grey level intensity variation. Close to 1: the estimated motion is very regular along the space. See http://bsenneville.free.fr/RealTITracker/ for more informations
alpha                  = 0.12;   

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

for dyn = 1:no_dyn  
    
  %% Get the current image  
  I = magnitude(:, :, :, dyn);
  
  %% Estimate the motion between the reference and the current images
  RTTrackerWrapper(Iref, I);
  
  % Apply the estimated motion on the current image
  [registered_image] = RTTrackerWrapper(I);
  
  % Get the estimated motion field
  motmatrix = RTTrackerWrapper();
  
  % Multiply with binary outline mask
  motmatrix = motmatrix.*dMASK;

  SI(dyn)=refSI-mean(mean(nonzeros(real(motmatrix)+ymap)));
  AP(dyn)=refAP-mean(mean(nonzeros(imag(motmatrix)+xmap)));
  

  %% Display registered images & estimated motion field
   %[u2,v2]=display_result2D(Iref,I,registered_image,pf,MASK);
   %pause(0.1)
%    filename = 'Analyse.gif';
%    frame = getframe(1);
%    im = frame2im(frame);
%    [imind,cm] = rgb2ind(im,256);
%    if dyn == 1;
%        imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
%    else
%        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0);
%    end
   %figure(2);
   %imagesc(abs(motion_field))
%   colorbar
%   
end

%% ========================= Close the RealTItracker library ===========================

RTTrackerWrapper();
% END
end