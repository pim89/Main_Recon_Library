function dvf = fastInverse(u1,v1,w1,it)

%% Chen, M., Lu, W., Chen, Q., Ruchala, K.J., Olivera, G.H., 2007. A simple fixed-point approach to invert a deformation field. Medical Physics 35, 81.

  if nargin<2
    it=10;
  end

%   u1=motion_field1(:,:,:,1);
%   v1=motion_field1(:,:,:,2);
%   w1=motion_field1(:,:,:,3);
  [m,n,o]=size(u1);
  [x,y,z]=meshgrid(1:m,1:n,1:o);
  u2=zeros(size(u1));
  v2=zeros(size(v1));
  w2=zeros(size(w1));
  
  for i=1:it
    u2n=-interp3(u1,min(max(x+u2,1),m),min(max(y+v2,1),n),min(max(z+w2,1),o),'linear');
    v2n=-interp3(v1,min(max(x+u2,1),m),min(max(y+v2,1),n),min(max(z+w2,1),o),'linear');
    w2n=-interp3(w1,min(max(x+u2,1),m),min(max(y+v2,1),n),min(max(z+w2,1),o),'linear');
    u2=u2n;
    v2=v2n;
    w2=w2n;
  end
  
  dvf=cat(4,u2,v2,w2);
%   motion_field2=zeros(size(motion_field1));
%   motion_field2(:,:,:,1) = u2;
%   motion_field2(:,:,:,2) = v2;
%   motion_field2(:,:,:,3) = w2;
end
