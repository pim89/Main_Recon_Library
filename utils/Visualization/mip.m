function A = mip(I,ori,w)

I=abs(I);
A=I;

if ori==0
    for n=1+w:size(I,1)-w
        A(n,:,:)=max(I(n-w:n+w,:,:),[],1);
    end
end
  
if ori==1
    for n=1+w:size(I,2)-w
        A(:,n,:)=max(I(:,n-w:n+w,:),[],2);
    end
end
    
if ori==2
    for n=1+w:size(I,3)-w
        A(:,:,n)=max(I(:,:,n-w:n+w),[],3);
    end
end
    
    % end
end