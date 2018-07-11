function  ft = FFT2D()
%
% Tom Bruijnen - University Medical Center Utrecht - 201704 

% FFT sign 1=adjoint operation and -1=forward
ft.adjoint=1; 			

% Define seperate class
ft=class(ft,'FFT2D');

disp('+2D FFT operator initialized.')

%END
end
