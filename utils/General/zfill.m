function res = zfill(X,a,b)
res=X;
res(end+1:a,:)=0;
res(:,end+1:b)=0;
% END
end