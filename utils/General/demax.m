function res = demax(x)

res=squeeze(x/abs(max(x(:))));

end