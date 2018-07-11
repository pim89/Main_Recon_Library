function mask = mask_from_csm(csm)

dim_full=size(csm);
% Neighbourhood for smoothing
nn=5;

% Make csm smaller for faster computing
csm=imresize(csm,[100 100]);
dim=size(csm);
kern=ones(nn,nn);

for c=1:dim(4)
    for z=1:dim(3)
        mask(:,:,z,c)=stdfilt(angle(csm(:,:,z,c)),kern);
    end
end

mask=median(mask,4);

th=graythresh(mask);
mask(mask<th)=0;
mask(mask>0)=1;
mask=1-mask;

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
    [x,y,z]=ndgrid(-3:3);
    se=strel(sqrt(x.^2 + y.^2 + z.^2) <=5);
    mask=imdilate(mask,se);
    mask=imdilate(mask,se);
else
    [x,y]=ndgrid(-3:3);
    se=strel(sqrt(x.^2 + y.^2) <=5);
    mask=imdilate(mask,se);
    mask=imdilate(mask,se);
    mask=imdilate(mask,se);
end


mask=imresize(mask,dim_full(1:2));
th=graythresh(mask);
mask(mask<th)=0;
mask(mask>0)=1;

% END
end