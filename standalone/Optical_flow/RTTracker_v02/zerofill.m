function M_out = zerofill(M)
% M = input matrix. Assumed thats first two dimensions need to be zero
% filled to a 2^n factor.
power_x=1;
while (power_x < size(M,1))
    power_x=power_x*2;
end

power_y=1;
while (power_y < size(M,2))
    power_y=power_y*2;
end

M_out=zeros(power_x,power_y,size(M,3),size(M,4)); 
M_out(round((power_x-size(M,1))/2):size(M,1)-1+ceil((power_x-size(M,1))/2), ...
    round((power_y-size(M,2))/2):size(M,2)-1+ceil((power_y-size(M,2))/2),:,:)=M(:,:,:,:);

% END
end