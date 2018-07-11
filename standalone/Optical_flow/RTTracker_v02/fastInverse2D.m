function dvf = fastInverse2D(u1,v1,it)

%% Chen, M., Lu, W., Chen, Q., Ruchala, K.J., Olivera, G.H., 2007. A simple fixed-point approach to invert a deformation field. Medical Physics 35, 81.

  if nargin<3
    it=10;
  end
for t=1:size(u1,5)
%   u1=motion_field1(:,:,:,1);
%   v1=motion_field1(:,:,:,2);
%   w1=motion_field1(:,:,:,3);
  [m,n]=size(u1(:,:,:,:,t));
  [x,y]=meshgrid(1:m,1:n);
  u2=zeros(m,n);
  v2=zeros(m,n);
  
  for i=1:it
    u2n=-interp2(u1(:,:,:,:,t),min(max(x+u2,1),m),min(max(y+v2,1),n),'linear');
    v2n=-interp2(v1(:,:,:,:,t),min(max(x+u2,1),m),min(max(y+v2,1),n),'linear'); 
    dvf(:,:,:,:,t)=v2n+1j*u2n;

  end
%   motion_field2=zeros(size(motion_field1));
%   motion_field2(:,:,:,1) = u2;
%   motion_field2(:,:,:,2) = v2;
%   motion_field2(:,:,:,3) = w2;
end
end
