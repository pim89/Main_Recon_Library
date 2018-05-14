function fimg = HanningFilter( img )


% Obtain the number of images in MR.Data
data_size=size(img);
nr_images=prod(data_size(3:end));
k=zeros(size(img));

for n=1:nr_images
    k(:,:,n)=fftshift(ifft2(fftshift(img(:,:,n))));
end
%Define filter
hfilter=(hamming(size(img,1))*hamming(size(img,2))');
hfilter=hfilter/max(hfilter(:));
% Filter every single image
for i = 1:nr_images
    k(:,:,i) = k( :,:,i).* hfilter;
end

for n=1:nr_images
    fimg(:,:,n)=fftshift(fft2(fftshift(k(:,:,n))));
end

% END
end