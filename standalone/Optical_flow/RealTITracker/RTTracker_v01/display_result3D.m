function display_result3D(Iref,I,registered_image,motion_field)

%% Get image dimensions
dimx = size(Iref,1);
dimy = size(Iref,2);
dimz = size(Iref,3);

%% Display unregistered and registered images
display_motion_number = 32;
  
% Specific 3D display parameters
display_slice_x = round(dimx/2);
display_slice_y = round(dimy/2)+40;
display_slice_z = round(dimz/2);

%% Turn images for display
turnIref_xy = reshape(Iref(:, end : - 1 : 1, display_slice_z),dimx,dimy)';
turnI_xy = reshape(I(:, end : - 1 : 1,  display_slice_z),dimx,dimy)';
turnRegistered_image_xy = reshape(registered_image(:, end : - 1 : 1, display_slice_z),dimx,dimy)';
turnIref_xz = reshape(Iref(:, display_slice_y, end : - 1 : 1),dimx,dimz)';
turnI_xz = reshape(I(:, display_slice_y, end : - 1 : 1),dimx,dimz)';
turnRegistered_image_xz = reshape(registered_image(:, display_slice_y, end : - 1 : 1),dimx,dimz)';
turnIref_yz = reshape(Iref(display_slice_x, :, end : - 1 : 1),dimy,dimz)';
turnI_yz = reshape(I(display_slice_x, :, end : - 1 : 1),dimy,dimz)';
turnRegistered_image_yz = reshape(registered_image(display_slice_x, :, end : - 1 : 1),dimy,dimz)';
    
%% Turn motion fields for display
motion_field_X = motion_field(:,:,:,1);
motion_field_Y = motion_field(:,:,:,2);
motion_field_Z = motion_field(:,:,:,3);
magnitude_threshold_display = 0.05; % Don't display vector field if the magnitude signal is too low
index = Iref < magnitude_threshold_display;
motion_field_X(index) = 0;
motion_field_Y(index) = 0;
motion_field_Z(index) = 0;
turnMotion_xy_X = reshape(motion_field_X(:,:,display_slice_z),dimx,dimy);
turnMotion_xy_Y = reshape(motion_field_Y(:,:,display_slice_z),dimx,dimy);
turnMotion_xy_X = turnMotion_xy_X';
turnMotion_xy_Y = turnMotion_xy_Y';
turnMotion_xz_X = reshape(motion_field_X(:,display_slice_y,:),dimx,dimz);
turnMotion_xz_Y = reshape(motion_field_Z(:,display_slice_y,:),dimx,dimz);
turnMotion_xz_X = turnMotion_xz_X';
turnMotion_xz_Y = turnMotion_xz_Y';
turnMotion_yz_X = reshape(motion_field_Y(display_slice_x,:,:),dimy,dimz);
turnMotion_yz_Y = reshape(motion_field_Z(display_slice_x,:,:),dimy,dimz);
turnMotion_yz_X = turnMotion_yz_X';
turnMotion_yz_Y = turnMotion_yz_Y';
    
%% Display 3D unregistered and registered images
    
%% Display XY image
figure(1);
clims = [0 1];
subplot(231);
imagesc(turnIref_xy,clims); colormap gray; axis off; axis image; title('Reference image');
subplot(232);
imagesc(turnI_xy,clims); colormap gray; axis off; axis image; title('Image to register');
subplot(233);
imagesc(turnRegistered_image_xy,clims); colormap gray; axis off; axis image; title('Registered image');
subplot(234);
motion_field_display_factor = round(min([dimx dimy])/display_motion_number);
quiver((downsample(downsample(turnMotion_xy_X,motion_field_display_factor)',motion_field_display_factor)')/(motion_field_display_factor/2), ...
       (downsample(downsample(turnMotion_xy_Y,motion_field_display_factor)',motion_field_display_factor)')/(motion_field_display_factor/2), ...
       0,'color','b','linewidth',2); title('Motion field'); axis([0 dimx/motion_field_display_factor 0 dimy/motion_field_display_factor]);
clims = [-1./2 1./2];
subplot(235);
imagesc(turnIref_xy-turnI_xy,clims); colormap gray; axis off; axis image; title('Difference before registration');
subplot(236);
imagesc(turnIref_xy-turnRegistered_image_xy,clims); colormap gray; axis off; axis image; title('Difference after registration');

%% Display XZ image
figure(2);
clims = [0 1];
subplot(231);
imagesc(turnIref_xz,clims); colormap gray; axis off; axis image; title('Reference image');
subplot(232);
imagesc(turnI_xz,clims); colormap gray; axis off; axis image; title('Image to register');
subplot(233);
imagesc(turnRegistered_image_xz,clims); colormap gray; axis off; axis image; title('Registered image');
subplot(234);
motion_field_display_factor = round(min([dimx dimz])/display_motion_number);
quiver((downsample(downsample(turnMotion_xz_X,motion_field_display_factor)',motion_field_display_factor)')/(motion_field_display_factor/2), ...
       (downsample(downsample(turnMotion_xz_Y,motion_field_display_factor)',motion_field_display_factor)')/(motion_field_display_factor/2), ...
       0,'color','b','linewidth',2); title('Motion field'); axis([0 dimx/motion_field_display_factor 0 dimz/motion_field_display_factor]);
clims = [-1./2 1./2];
subplot(235);
imagesc(turnIref_xz-turnI_xz,clims); colormap gray; axis off; axis image; title('Difference before registration');
subplot(236);
imagesc(turnIref_xz-turnRegistered_image_xz,clims); colormap gray; axis off; axis image; title('Difference after registration');

%% Display YZ image
figure(3);
clims = [0 1];
subplot(231);
imagesc(turnIref_yz,clims); colormap gray; axis off; axis image; title('Reference image');
subplot(232);
imagesc(turnI_yz,clims); colormap gray; axis off; axis image; title('Image to register');
subplot(233);
imagesc(turnRegistered_image_yz,clims); colormap gray; axis off; axis image; title('Registered image');
subplot(234);
motion_field_display_factor = round(min([dimy dimz])/display_motion_number);
quiver((downsample(downsample(turnMotion_yz_X,motion_field_display_factor)',motion_field_display_factor)')/(motion_field_display_factor/2), ...
       (downsample(downsample(turnMotion_yz_Y,motion_field_display_factor)',motion_field_display_factor)')/(motion_field_display_factor/2), ...
       0,'color','b','linewidth',2); title('Motion field'); axis([0 dimy/motion_field_display_factor 0 dimz/motion_field_display_factor]);
clims = [-1./2 1./2];
subplot(235);
imagesc(turnIref_yz-turnI_yz,clims); colormap gray; axis off; axis image; title('Difference before registration');
subplot(236);
imagesc(turnIref_yz-turnRegistered_image_yz,clims); colormap gray; axis off; axis image; title('Difference after registration');