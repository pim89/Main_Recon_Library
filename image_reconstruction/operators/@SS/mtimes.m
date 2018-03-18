function output = mtimes(S,data) 
%%Coil combination using sensitivity maps without uniformity corrections.
idim=c12d(size(data));

if S.adjoint==1
    for p=1:prod(idim(5:end))
        output(:,:,:,:,p)=sum(data(:,:,:,:,p).*conj(S.S),4);
    end
else
    for p=1:prod(idim(5:end))
        output(:,:,:,:,p)=repmat(data(:,:,:,1,p),[1 1 1 size(S.S,4) 1 1 1 1 1 1 1 1]).*S.S;
    end
end

% END
end  
