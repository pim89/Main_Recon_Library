function output = mtimes(PH,data) 
%%Add complex phase to the data

if PH.adjoint==1
    output=sum(bsxfun(@times,data,PH.phase_pattern),3);
else % Complex conjugate
    output=bsxfun(@times,repmat(data,[1 1 2 1 1]),conj(PH.phase_pattern));
end

% END
end  
