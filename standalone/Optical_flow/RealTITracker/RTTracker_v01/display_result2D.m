function [u2,v2]=display_result2D(Iref,I,registered_image,motion_field,MASK,dyn)

%% Get image dimensions
dimx = size(Iref,1);
dimy = size(Iref,2);

%% Display unregistered and registered images
display_motion_number = 32;
  
%% Turn images for display
turnIref = Iref;
turnI = I/max(abs(I(:)));
turnRegistered_image = registered_image;

%% Turn motion fields for display
magnitude_threshold_display = 0.1; % Don't display vector field if the magnitude signal is too low
index = Iref < magnitude_threshold_display;
motion_field(index) = 0;
motion_field=rot90(motion_field,3);
turnMotionY = real(motion_field);
turnMotionX = imag(motion_field);
turnMotionX = turnMotionX';
turnMotionY = turnMotionY';

%% Result display
f1=figure(1);
set(f1,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
%scrsz = get(0,'ScreenSize');
%set(f1,'position',scrsz);
clims = [0 1];

 imagesc(turnRegistered_image,clims); colormap gray; axis off; axis image; title('Registered image');
% Superimpose motion fields, need this rotation.
%[u2,v2]=plot_vectorfields(turnRegistered_image,rot90(imag(motion_field)),rot90(real(motion_field)),MASK);

clims=[0 1];

%% Display 2D unregistered and registered images
motion_field=rot90(motion_field);
% subplot(231);
% imshow(turnIref,[]); title('Reference image');
% axis([40 215 66 189  ])
% subplot(232);
subplot(221);
imshow(turnI,[]); title('Image to register');
axis([40 215 66 189  ])
set(gca,'LineWidth',3,'FontWeight','bold','fontsize',24);

% subplot(233);
% imshow(turnRegistered_image,[]); title('Registered image');
% axis([40 215 66 189  ])

%% Display 2D motion field vectors
%subplot(234);
subplot(222)
imshow(turnRegistered_image,[]);title('Registered image');
% Superimpose motion fields, need this rotation.
[u2,v2]=plot_vectorfields(turnRegistered_image,imag(motion_field),real(motion_field),MASK);
clims = [-1./2 1./2];
axis([40 215 66 189  ])
   set(gca,'LineWidth',3,'FontWeight','bold','fontsize',24);

% subplot(235);
% imshow(turnIref-turnI,clims); title('Difference before registration');
% axis([40 215 66 189  ])
% subplot(236);
% imshow(turnIref-turnRegistered_image,clims);title('Difference after registration');
% axis([40 215 66 189  ])
   filename = 'Analyse.gif';

   set(gcf,'Color','w');
   %pause(0.1)

   frame = getframe(gcf);
   im = frame2im(frame);
   [imind,cm] = rgb2ind(im,256);
   if dyn == 1;
       imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
   else
       imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.2);
   end

