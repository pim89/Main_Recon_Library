function csm = openadapt_ss(img,varargin)
%%Simple wrapper around the openadapt function that does the permute
%%operations. Real algorithm is in openadapt_algo

dim=size(img);
% Identify square to calculation Rn from
if nargin > 1
    figure,imshow(demax(sum(abs(img(:,:,:,:)),4)),[0 .3]);
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    BW=roipoly();idx=find(BW==1);
    noise_data=reshape(img,[dim(1)^2 dim(4)]);
    noise_data=noise_data(idx,:);
    Rn=noise_covariance_mtx(noise_data);

else
    
    os=1.5;
    c0=round(.7*(os-1)/2*1/os*dim(1));
    noise_data=reshape(cat(3,img([1:c0 end-c0+1:end],:,:,:),...
        permute(img(:,[1:c0 end-c0+1:end],:,:),[2 1 3 4])),[2*c0*dim(1)*2 dim(4)]);
    Rn=noise_covariance_mtx(noise_data);

end

img=permute(img,[4 1 2 3]);
[~,csm]=openadapt_algo(img,0,Rn);
csm=permute(csm,[2 3 4 1]);

% END
end
