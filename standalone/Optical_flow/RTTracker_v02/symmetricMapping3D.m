  function [dvf,dvf_adj]=symmetricMapping3D(dvf,dvf_adj,it)
  for t=1:size(dvf,5)
      if nargin<3
          it=10;
      end
      
      u1=dvf(:,:,:,1,t);
      v1=dvf(:,:,:,2,t);
      w1=dvf(:,:,:,3,t);
      u2=dvf_adj(:,:,:,1,t);
      v2=dvf_adj(:,:,:,2,t);
      w2=dvf_adj(:,:,:,3,t);
      
      [u2i,v2i,w2i]=fastInverse3D(u2./2,v2./2,w2./2,it);
      [u1i,v1i,w1i]=fastInverse3D(u1./2,v1./2,w1./2,it);
      
      [u1s,v1s,w1s]=combineDeformation3D(u1./2,v1./2,w1./2,u2i,v2i,w2i,'compositive');
      [u2s,v2s,w2s]=combineDeformation3D(u2./2,v2./2,w2./2,u1i,v1i,w1i,'compositive');
      
      dvf(:,:,:,:,t)=cat(4,u1s,v1s,w1s);
      dvf_adj(:,:,:,:,t)=cat(4,u2s,v2s,w2s);
      t
  end
end

function [u_combined,v_combined,w_combined]=combineDeformation3D(u1st,v1st,w1st,u2nd,v2nd,w2nd,method)
  
  if nargin<7
    method='compositive';
  end
  u2nd(isnan(u2nd))=0;
  u1st(isnan(u1st))=0;
  v2nd(isnan(v2nd))=0;
  v1st(isnan(v1st))=0;
  w2nd(isnan(w2nd))=0;
  w1st(isnan(w1st))=0;
  
  if strcmp(method,'compositive')
    u_combined=imWarp(u2nd,v2nd,w2nd,u1st)+u2nd;
    v_combined=imWarp(u2nd,v2nd,w2nd,v1st)+v2nd;
    w_combined=imWarp(u2nd,v2nd,w2nd,w1st)+w2nd;
  else
    u_combined=u1st+u2nd;
    v_combined=v1st+v2nd;
    w_combined=w1st+w2nd;
  end
  
end

function [u2,v2,w2]=fastInverse3D(u1,v1,w1,it)
  if nargin<4
    it=10;
  end
  [m,n,p]=size(u1);
  [x,y,z]=meshgrid(1:n,1:m,1:p);
  u2=zeros(size(u1));
  v2=zeros(size(v1));
  w2=zeros(size(w1));
  
  for i=1:it
    u2n=-interp3(u1,min(max(x+u2,1),n),min(max(y+v2,1),m),min(max(z+w2,1),p),'linear');
    v2n=-interp3(v1,min(max(x+u2,1),n),min(max(y+v2,1),m),min(max(z+w2,1),p),'linear');
    w2n=-interp3(w1,min(max(x+u2,1),n),min(max(y+v2,1),m),min(max(z+w2,1),p),'linear');
    u2=u2n;
    v2=v2n;
    w2=w2n;
  end
  
end

function [ B ] = imWarp( flowHor, flowVer, flowLon, Bin, method )
  if nargin<5
    method='linear';
  end
				%This function warps B towards A
  [m,n,p,o]=size(Bin);
  
  [x y z] = meshgrid(1:size(Bin,2),1:size(Bin,1),1:size(Bin,3));
  xu=x+flowHor;
  xu(xu<1)=1;
  xu(xu>n)=n;
  xu(isnan(xu))=0;
  
  yv=y+flowVer;
  yv(yv<1)=1;
  yv(yv>m)=m;
  yv(isnan(yv))=0;
  
  zw=z+flowLon;
  zw(zw<1)=1;
  zw(zw>m)=m;
  zw(isnan(zw))=0;
  
  for i=1:size(Bin,4)
    B(:,:,:,i) = interp3(Bin(:,:,:,i), xu,yv,zw, method);   
  end
  B(isnan(B)) = Bin(isnan(B));
end
