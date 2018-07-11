function makegif(img,filename,fps,clips,varargin)
% Transform a 3D matrix into an image based GIF file
% Note that computer vision toolbox is required for the counter (varargin).
%
% Tom Bruijnen - University Medical Center Utrecht - 201609
close all;
% Handle input
if nargin < 5
    counter=0;
else
    counter=1;
end
img=squeeze(img);

figure
for j=1:size(img,3);
    imshow(img(:,:,j),clips,'InitialMagnification',300);
    if counter
        annotation('textbox',[0.02 0.12 1 0],'string',['T: ',num2str(varargin{1}(j),'%d'),' s'],...
            'Color','w','FontSize',40,'FontWeight','bold','LineStyle','none');
        
        if numel(varargin)>1
            annotation('textbox',[0.6 0.12 1 0],'string',['R: ',num2str(varargin{2}(j),'%.1f'),' mm'],...
                'Color','w','FontSize',40,'FontWeight','bold','LineStyle','none');
        end
    end

%     if mod(j,2) == 0
%         annotation('textbox',[0.6 0.12 1 0],'string','ACC-SS',...
%                 'Color','w','FontSize',34,'FontWeight','bold','LineStyle','none');
%     else
%         annotation('textbox',[0.6 0.12 1 0],'string','ACC',...
%                 'Color','w','FontSize',34,'FontWeight','bold','LineStyle','none');
%     end
    
    set(gcf,'Color','k');
    pause(1);
    A = getframe();
    im=frame2im(A);
    [A,map]=rgb2ind(im,256);
    if ~exist(filename,'file')
        imwrite(A,map,filename,'gif','WriteMode','overwrite','delaytime',1/fps, 'LoopCount', 65535);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','delaytime',1/fps);    
    end
end


% END
end