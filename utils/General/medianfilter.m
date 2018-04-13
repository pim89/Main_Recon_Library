function res = medianfilter(x,width)

res=zeros(size(x));
for t=1+width:size(x,4)-width
    res(:,:,:,t)=median(x(:,:,:,t-width:t+width),4);
end

% END
end