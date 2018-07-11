function display_result2D(Iref,I,registered_image,motion_field,varargin)

display_motion_number = 32; %% number of arrows along horizontal and vertical directions
magnitude_threshold_display = 0.1; % Don't display vector field if the magnitude signal is too low

%% Get image dimensions
[dimx dimy] = size(Iref);

%% Don't display vector field if the magnitude signal is too low
index = Iref < magnitude_threshold_display;
motion_field(index) = 0;

%% Display 2D unregistered and registered images
figure(1);
clims = [0 1];
subplot(231);
imagesc(Iref,clims); colormap gray; axis off; axis image; title('Reference image');
subplot(232);
imagesc(I,clims); colormap gray; axis off; axis image; title('Image to register');
subplot(233);
imagesc(registered_image,clims); colormap gray; axis off; axis image; title('Registered image');
  
%% Display 2D motion field vectors
subplot(234);
motion_field_display_factor = round(min([dimx dimy])/display_motion_number);
quiver((downsample(downsample(flipud(imag(motion_field)),motion_field_display_factor)',motion_field_display_factor)')/(motion_field_display_factor/2), ...
       (downsample(downsample(-flipud(real(motion_field)),motion_field_display_factor)',motion_field_display_factor)')/(motion_field_display_factor/2), ...
       0,'color','b','linewidth',2);
title('Motion field'); 
axis([0 dimy/motion_field_display_factor 0 dimx/motion_field_display_factor]);
axis off; axis image;

%% Display difference images
clims = [-1./2 1./2];
subplot(235);
imagesc(Iref-I,clims); colormap gray; axis off; axis image; title('Difference before registration');
subplot(236);
imagesc(Iref-registered_image,clims); colormap gray; axis off; axis image; title('Difference after registration');

%pause(.5);
