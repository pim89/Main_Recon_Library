function display_result3D(Iref,I,registered_image,motion_field)

display_motion_number = 20; %% max number of arrows along horizontal and vertical directions
magnitude_threshold_display = 0.05; % Don't display vector field if the magnitude signal is too low

%% Get image dimensions
[dimx dimy dimz] = size(Iref);

% Specific 3D display parameters
display_slice_x = round(dimx/2);
display_slice_y = round(dimy/2);
display_slice_z = round(dimz/2);

%% Select 2D image cross sections for display
Iref_xy = reshape(Iref(:, :, display_slice_z),dimx,dimy);
I_xy = reshape(I(:, :, display_slice_z),dimx,dimy);
registered_image_xy = reshape(registered_image(:, :, display_slice_z),dimx,dimy);
Iref_xz = reshape(Iref(:, display_slice_y, :),dimx,dimz);
I_xz = reshape(I(:, display_slice_y, :),dimx,dimz);
registered_image_xz = reshape(registered_image(:, display_slice_y, :),dimx,dimz);
Iref_yz = reshape(Iref(display_slice_x, :, :),dimy,dimz);
I_yz = reshape(I(display_slice_x, :, :),dimy,dimz);
registered_image_yz = reshape(registered_image(display_slice_x, :, :),dimy,dimz);
    
%% Select 2D motion cross sections for display
motion_field_X = motion_field(:,:,:,1);
motion_field_Y = motion_field(:,:,:,2);
motion_field_Z = motion_field(:,:,:,3);
index = Iref < magnitude_threshold_display;
motion_field_X(index) = 0;
motion_field_Y(index) = 0;
motion_field_Z(index) = 0;
turnMotion_xy_X = flipud(reshape(motion_field_Y(:,:,display_slice_z),dimx,dimy));
turnMotion_xy_Y = -flipud(reshape(motion_field_X(:,:,display_slice_z),dimx,dimy));
turnMotion_xz_X = flipud(reshape(motion_field_Z(:,display_slice_y,:),dimx,dimz));
turnMotion_xz_Y = -flipud(reshape(motion_field_X(:,display_slice_y,:),dimx,dimz));
turnMotion_yz_X = flipud(reshape(motion_field_Z(display_slice_x,:,:),dimy,dimz));
turnMotion_yz_Y = -flipud(reshape(motion_field_Y(display_slice_x,:,:),dimy,dimz));
    
%% Display 3D unregistered and registered images
    
%% Display XY image
figure(1);
clims = [0 1];
subplot(231);
imagesc(Iref_xy,clims); colormap gray; axis off; axis image; title('Reference image');
subplot(232);
imagesc(I_xy,clims); colormap gray; axis off; axis image; title('Image to register');
subplot(233);
imagesc(registered_image_xy,clims); colormap gray; axis off; axis image; title('Registered image');
subplot(234);
motion_field_display_factor = round(max([dimx dimy])/display_motion_number);
quiver((downsample(downsample(turnMotion_xy_X,motion_field_display_factor)',motion_field_display_factor)')/(motion_field_display_factor/2), ...
       (downsample(downsample(turnMotion_xy_Y,motion_field_display_factor)',motion_field_display_factor)')/(motion_field_display_factor/2), ...
       0,'color','b','linewidth',2); title('Motion field'); axis([0 dimy/motion_field_display_factor 0 dimx/motion_field_display_factor]);
axis off; axis image;
clims = [-1./2 1./2];
subplot(235);
imagesc(Iref_xy-I_xy,clims); colormap gray; axis off; axis image; title('Difference before registration');
subplot(236);
imagesc(Iref_xy-registered_image_xy,clims); colormap gray; axis off; axis image; title('Difference after registration');

%% Display XZ image
figure(2);
clims = [0 1];
subplot(231);
imagesc(Iref_xz,clims); colormap gray; axis off; axis image; title('Reference image');
subplot(232);
imagesc(I_xz,clims); colormap gray; axis off; axis image; title('Image to register');
subplot(233);
imagesc(registered_image_xz,clims); colormap gray; axis off; axis image; title('Registered image');
subplot(234);
motion_field_display_factor = round(max([dimx dimz])/display_motion_number);
quiver((downsample(downsample(turnMotion_xz_X,motion_field_display_factor)',motion_field_display_factor)')/(motion_field_display_factor/2), ...
       (downsample(downsample(turnMotion_xz_Y,motion_field_display_factor)',motion_field_display_factor)')/(motion_field_display_factor/2), ...
       0,'color','b','linewidth',2); title('Motion field'); axis([0 dimz/motion_field_display_factor 0 dimx/motion_field_display_factor]);
axis off; axis image;
clims = [-1./2 1./2];
subplot(235);
imagesc(Iref_xz-I_xz,clims); colormap gray; axis off; axis image; title('Difference before registration');
subplot(236);
imagesc(Iref_xz-registered_image_xz,clims); colormap gray; axis off; axis image; title('Difference after registration');

%% Display YZ image
figure(3);
clims = [0 1];
subplot(231);
imagesc(Iref_yz,clims); colormap gray; axis off; axis image; title('Reference image');
subplot(232);
imagesc(I_yz,clims); colormap gray; axis off; axis image; title('Image to register');
subplot(233);
imagesc(registered_image_yz,clims); colormap gray; axis off; axis image; title('Registered image');
subplot(234);
motion_field_display_factor = round(max([dimy dimz])/display_motion_number);
quiver((downsample(downsample(turnMotion_yz_X,motion_field_display_factor)',motion_field_display_factor)')/(motion_field_display_factor/2), ...
       (downsample(downsample(turnMotion_yz_Y,motion_field_display_factor)',motion_field_display_factor)')/(motion_field_display_factor/2), ...
       0,'color','b','linewidth',2); title('Motion field'); axis([0 dimz/motion_field_display_factor 0 dimy/motion_field_display_factor]);
axis off; axis image;
clims = [-1./2 1./2];
subplot(235);
imagesc(Iref_yz-I_yz,clims); colormap gray; axis off; axis image; title('Difference before registration');
subplot(236);
imagesc(Iref_yz-registered_image_yz,clims); colormap gray; axis off; axis image; title('Difference after registration');

%% Display color differences
figure(4);
subplot(121);
imshow(imfuse(Iref_xy, I_xy));
subplot(122);
imshow(imfuse(Iref_xy, registered_image_xy));

figure(5);
subplot(121);
imshow(imfuse(Iref_xz, I_xz));
subplot(122);
imshow(imfuse(Iref_xz, registered_image_xz));

figure(6);
subplot(121);
imshow(imfuse(Iref_yz, I_yz));
subplot(122);
imshow(imfuse(Iref_yz, registered_image_yz));
