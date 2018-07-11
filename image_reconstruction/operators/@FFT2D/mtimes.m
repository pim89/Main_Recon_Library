function res = mtimes(ft,data) 
% Tom Bruijnen - University Medical Center Utrecht - 201704 
    

if ft.adjoint==-1 % FFT^(-1)
    % k-space to image domain || type 1   
    res=fftshift(fftshift(ifft2(fftshift(fftshift(data,1),2)),1),2);

else         % Cartesian image domain to Cartesian k-space || type 2
    res=fftshift(fftshift(fft2(fftshift(fftshift(data,1),2)),1),2);

end

% END  
end  

