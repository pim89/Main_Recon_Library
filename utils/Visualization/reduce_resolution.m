function res = reduce_resolution(I,factor,method)

dim=size(I);
if method==1
    div=factor*2;
    F=fft2c(I);
    F([1:round(dim(1)/div) 3*dim(1)/div:end],:)=0;
    F(:,[1:dim(2)/div 3*dim(2)/div:end])=0;
    res=abs(ifft2c(F));
else
    res=imresize(I,[dim(1)/factor dim(2)/factor]);
    res=imresize(res,[dim(1) dim(2)]);
end
% END
end