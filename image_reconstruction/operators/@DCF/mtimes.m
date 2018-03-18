function output = mtimes(dcf,input)

% Data dimensions for reshape
idim=size(input);

% Examine dimensions of dcf
for j=1:numel(size(input))
    if size(dcf.w,j)==size(input,j)
        idim(j)=1;
    end
end
 
% Multiply k-space data with DCF
W=repmat(dcf.w,idim);
output=input.*W;

% END  
end  
