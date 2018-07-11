function output = mtimes(DVF,data) 
%%Vector field image deformation operator
% Only 2D is supported at the moment
%
% T.Bruijnen @ 20180626

% Dimensions
idim=c12d(size(data));

% Adjoint or not
if DVF.adjoint==1
    for dyn=1:idim(5)
        output(:,:,:,:,dyn)=imwarp(data(:,:,:,:,dyn),DVF.dvf_adj(:,:,:,:,dyn),'cubic');
    end
else
    for dyn=1:idim(5)
        output(:,:,:,:,dyn)=imwarp(data(:,:,:,:,dyn),DVF.dvf(:,:,:,:,dyn),'cubic');
    end
end

% END
end  
