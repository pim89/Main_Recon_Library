function [img_filt,mask,bias] = hum3D(img,sigmag,mask)
% Inhomogeneity correction function
% Initially made by Federico D'Agata
% Adjusted by Tom Bruijnen

% Check input
if nargin < 2
    sigmag=.15*size(img,1);
end

if ~isreal(img)
    img=abs(img);
end

% Create mask if none is provided
if nargin < 3
    
    % Background thresholding
    bw_img=demax(img);
    cutoff=.3*graythresh(bw_img);
    bw_img(bw_img<cutoff)=0;
    bw_img(bw_img>cutoff)=1;
    
    % Dilation / erosion
    [x,y,z]=ndgrid(-2:2);
    se=strel(sqrt(x.^2 + y.^2 + z.^2) <=1);

    bw_img=imdilate(bw_img,se);
    bw_img=imdilate(bw_img,se);
    bw_img=imfill(bw_img,'holes');
    bw_img=imerode(bw_img,se);
    bw_img=imerode(bw_img,se);
    bw_img=imerode(bw_img,se);
    bw_img=imdilate(bw_img,se);
    
    % Select biggest component
    CC=bwconncomp(bw_img);
    n_list=1;
    n_list_val=1;
    for n=1:numel(CC.PixelIdxList)
        cur_val=numel(CC.PixelIdxList{n});
        if cur_val>n_list_val
            n_list_val=cur_val;
            n_list=n;
        end
    end
    
    bw_img=ones(size(bw_img));
    bw_img(CC.PixelIdxList{n_list})=0;
    
    % Some dilation operations
    se=strel('disk',8,8);
    mask=imdilate(1-bw_img,se);
    mask=logical(imdilate(mask,se));
end

% HUM part
noise_mask=~mask;
m_w=mean(img(mask));
img(noise_mask)=m_w;
bias=imgaussfilt3(img,sigmag);
img_filt=img./bias;
end
