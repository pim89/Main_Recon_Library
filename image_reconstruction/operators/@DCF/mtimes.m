function output = mtimes(dcf,input)

% Data dimensions for reshape
idim=size(input);

% Multiply k-space data with DCF
W=repmat(dcf.w,idim);
output=input.*W;

% END  
end  
