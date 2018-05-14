function res = dice(X1,X2)

Seg1 = X1(:);
Seg2 = X2(:);
VoxelsNumber1=sum(Seg1); 
VoxelsNumber2=sum(Seg2);
CommonArea=sum(Seg1 & Seg2); 
res=(2*CommonArea)/(VoxelsNumber1+VoxelsNumber2);

% END
end
