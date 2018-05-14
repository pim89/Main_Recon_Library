function makegif4DMRL(img,filename,fps,clips,varargin)
% Transform a 3D matrix into an image based GIF file
% Note that computer vision toolbox is required for the counter (varargin).
%
% Tom Bruijnen - University Medical Center Utrecht - 201609
close all;

figure

% Normalize
img=img/max(abs(img(:)));

% Reshape to isotropic size
dims=size(img);

% Create axial gif
cimg=abs(squeeze(img(:,:,varargin{1}(1),:,:)));
cfname=strcat(filename,'AX.gif');

for j=1:size(cimg,3);
    imshow(cimg(:,:,j),clips,'InitialMagnification',300);  
    annotation('textbox',[0.05 0.1 1 0],'string',[num2str((j*varargin{3}),'%d'),' s'],...
        'Color','w','FontSize',34,'FontWeight','bold','LineStyle','none');
        
    annotation('textbox',[0.8 0.1 1 0],'string','MRL',...
        'Color','w','FontSize',28,'FontWeight','bold','LineStyle','none');

    set(gcf,'Color','k');
    pause(.2);
    A = getframe();
    im=frame2im(A);
    [A,map]=rgb2ind(im,256);
    if ~exist(cfname,'file')
        imwrite(A,map,cfname,'gif','WriteMode','overwrite','delaytime',1/fps, 'LoopCount', 65535);
    else
        imwrite(A,map,cfname,'gif','WriteMode','append','delaytime',1/fps);    
    end
end

% Create coronal gif
cimg=imresize(rot90(abs(squeeze(img(varargin{1}(2),:,:,:,:))),1),[varargin{2}*dims(3) dims(1)]);figure,imshow(cimg(:,:,1),[])
cfname=strcat(filename,'COR.gif');

for j=1:size(cimg,3);
    imshow(cimg(:,:,j),clips,'InitialMagnification',300);  
    annotation('textbox',[0.05 0.25 1 0],'string',[num2str((j*varargin{3}),'%d'),' s'],...
        'Color','w','FontSize',34,'FontWeight','bold','LineStyle','none');
        
    annotation('textbox',[0.8 0.25 1 0],'string','MRL',...
        'Color','w','FontSize',28,'FontWeight','bold','LineStyle','none');

    set(gcf,'Color','k');
    pause(.2);
    A = getframe();
    im=frame2im(A);
    [A,map]=rgb2ind(im,256);
    if ~exist(cfname,'file')
        imwrite(A,map,cfname,'gif','WriteMode','overwrite','delaytime',1/fps, 'LoopCount', 65535);
    else
        imwrite(A,map,cfname,'gif','WriteMode','append','delaytime',1/fps);    
    end
end

% Create sagittal gif
cimg=imresize(rot90(abs(squeeze(img(:,varargin{1}(3),:,:,:))),1),[varargin{2}*dims(3) dims(1)]);figure,imshow(cimg(:,:,1),[])
cfname=strcat(filename,'SAG.gif');

for j=1:size(cimg,3);
    imshow(cimg(:,:,j),clips,'InitialMagnification',300);  
    annotation('textbox',[0.05 0.25 1 0],'string',[num2str((j*varargin{3}),'%d'),' s'],...
        'Color','w','FontSize',34,'FontWeight','bold','LineStyle','none');
        
    annotation('textbox',[0.8 0.25 1 0],'string','MRL',...
        'Color','w','FontSize',28,'FontWeight','bold','LineStyle','none');

    set(gcf,'Color','k');
    pause(.2);
    A = getframe();
    im=frame2im(A);
    [A,map]=rgb2ind(im,256);
    if ~exist(cfname,'file')
        imwrite(A,map,cfname,'gif','WriteMode','overwrite','delaytime',1/fps, 'LoopCount', 65535);
    else
        imwrite(A,map,cfname,'gif','WriteMode','append','delaytime',1/fps);    
    end
end

% END
end