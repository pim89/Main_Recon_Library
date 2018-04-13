function res = demean(x)

res=squeeze(x-mean(abs(x(:))));

end