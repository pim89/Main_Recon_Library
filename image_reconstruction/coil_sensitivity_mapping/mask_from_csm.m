function mask = mask_from_csm(csm)

dim_full=size(csm);
% Neighbourhood for smoothing
nn=5;

% Make csm smaller for faster computing
csm=imresize(csm,[100 100]);
dim=size(csm);
if dim(3) == 1
    kern=ones(nn,nn);
else
    z=makeuneven(floor(dim(3)/10));
    if z<1
        z=1;
    end
    kern=ones(nn,nn,z);
end

for c=1:dim(4)
   mask(:,:,:,c)=stdfilt(abs(csm(:,:,:,c)),kern);
end

if dim(3)==1
    mask=imgaussfilt(1-demax(sum(mask,4)),0.1*size(csm,1));
else
    mask=imgaussfilt3(1-demax(sum(mask,4)),0.1*size(csm,1));
end

th=graythresh(mask);
mask(mask<th)=0;
mask(mask>0)=1;

% Select biggest component
CC=bwconncomp(mask);
n_list=1;
n_list_val=1;
for n=1:numel(CC.PixelIdxList)
    cur_val=numel(CC.PixelIdxList{n});
    if cur_val>n_list_val
        n_list_val=cur_val;
        n_list=n;
    end
end

mask=zeros(size(mask));
mask(CC.PixelIdxList{n_list})=1;

if dim(3)==1
    [x,y,z]=ndgrid(-5:5);
    se=strel(sqrt(x.^2 + y.^2 + z.^2) <=1);
    mask=imdilate(mask,se);
else
    [x,y]=ndgrid(-5:5);
    se=strel(sqrt(x.^2 + y.^2) <=1);
    mask=imdilate(mask,se);
end


mask=imresize(mask,dim_full(1:2));
th=.01;
mask(mask<th)=0;
mask(mask>0)=1;

% END
end