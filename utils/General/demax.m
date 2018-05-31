function res = demax(x)

res=squeeze(x/max(abs(x(:))));

end