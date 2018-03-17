function [EigenVecs, EigenVals] = EigenPatches(kernel, imsize)
% 20160616 - Transform calibration matrix A in the coil sensitivity maps.
% Note that the code is not commented yet, have to program it readable and
% more efficient soon.
%
% Function computes the ESPIRiT step II -- eigen-value decomposition of a 
% k-space kernel in image space.  

nc=size(kernel,3); % ncoils
nv=size(kernel,4); % row rank
ksize=[size(kernel,1), size(kernel,2)];

% "rotate kernel to order by maximum variance"
% all kernels per coil contaconated into a vector
k=permute(kernel,[1,2,4,3]);k=reshape(k,prod([ksize,nv]),nc);

% Perform another SVD on this matrix
if size(k,1) < size(k,2)
    [u,s,v]=svd(k);
else
    
    [u,s,v]=svd(k,'econ');
end

k=k*v;
kernel=reshape(k,[ksize,nv,nc]);
kernel=permute(kernel,[1,2,4,3]);

KERNEL=zeros(imsize(1),imsize(2),size(kernel,3),size(kernel,4));
for n=1:size(kernel,4)
    KERNEL(:,:,:,n)=(fft2c(zpad(conj(kernel(end:-1:1,end:-1:1,:,n))*sqrt(imsize(1)*imsize(2)), ...
        [imsize(1),imsize(2),size(kernel,3)])));
end
KERNEL=KERNEL/sqrt(prod(ksize));


EigenVecs=zeros(imsize(1),imsize(2),nc,min(nc,nv));
EigenVals=zeros(imsize(1),imsize(2),min(nc,nv));

for n=1:prod(imsize)
    [x,y]=ind2sub([imsize(1),imsize(2)],n);
    mtx=squeeze(KERNEL(x,y,:,:));

    [C,D,V]=svd(mtx,'econ');
    
    ph=repmat(exp(-i*angle(C(1,:))),[size(C,1),1]);
    C=v*(C.*ph);
    D=real(diag(D));
    EigenVals(x,y,:)=D(end:-1:1);
    EigenVecs(x,y,:,:)=C(:,end:-1:1);
end


