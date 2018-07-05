function [u2,v2]=plot_vectorfields(im2,u2,v2,MASK)
%
% function []=plot_vectorfields(im2,u2,v2)
%
% Function to visualize the vector fields, calculated using the 2D OF
% implementation, on top of the corresponding images
% 
% INPUT:        im2 [x,y] - image
%               u2/v2 [x,y] - motionfield in the two directions
% 
% b.stemkens@umcutrecht.nl - 06/2012

s=size(im2);
colormap('gray');
stepsize = 4; 

% % Plot a red border around the GTV
% dMASK=[];
% for j=2:size(MASK,1)-1
%     for k=2:size(MASK,2)-1
%         if (MASK(j-1,k)==0 || MASK(j+1,k)==0 || MASK(j,k-1)==0 || MASK(j,k+1)==0) && MASK(j,k)==1
%             dMASK=[dMASK;[j,k]]; % Get 1st order derivative for outline
%         end
%     end
% end
% ind=sub2ind(size(MASK),dMASK(:,1),dMASK(:,2)); % Linear indices
% red=im2;
% red(ind)=255;
% blue=im2;
% blue(ind)=0;
% green=im2;
% green(ind)=0;
% img=cat(3,red,blue,green); % Complex way to plot color on gray image

% Rest of Bjorn's script
subplot(222)
imshow(im2,[]);hold on
xind = stepsize:stepsize:s(1);
yind = stepsize:stepsize:s(2);
usub=u2(xind,yind);
vsub=v2(xind,yind);
for x=1:length(xind)
    for y=1:length(yind)
        if im2(xind(x),yind(y)) < max(im2(:))*0.001
            usub(xind(x)/stepsize,yind(y)/stepsize) = 0;
            vsub(xind(x)/stepsize,yind(y)/stepsize) = 0;
        end;
    end;
end;
[xsub, ysub]=meshgrid(xind,yind);
quiver(xsub,ysub,usub,vsub,3,'y','LineWidth',2);hold off
title('Registered image')
axis off; axis image;


end