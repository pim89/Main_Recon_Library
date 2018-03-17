function res = dynamic_to_spokes(data)
%Merge dimension 2 and 5 or 3 and 5 for traj

dim=size(data);dim(end+1:12)=1;
if dim(1)==3
    data=permute(data,[1 2 4 6:12 3 5]);
    data=reshape(data,[dim([1 2 4 6:12]) prod(dim([3 5])) 1]);
    res=permute(data,[1 2 11 3 12 4:10]);
else
    data=permute(data,[1 3 4 6:12 2 5]);
    data=reshape(data,[dim([1 3 4 6:12]) prod(dim([2 5])) 1]);
    res=permute(data,[1 11 2 3 12 4:10]);
end
% END
end