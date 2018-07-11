function  res = PH(phase_pattern,kdim)
% Operator to add or subtract phase patterns to the k-space data.
% Phase pattern should have slices in colums and phase in alternating
% manner in radians. E.g. [0 0;0 pi] = Slice1: [0,0], Slice2: [0,pi]
%
% Tom Bruijnen - University Medical Center Utrecht - 20180627

res.phase_pattern=repmat(permute(exp(1j*phase_pattern),[3 1 2]),[1 ceil(kdim(2)/2) 1]);
res.phase_pattern=res.phase_pattern(:,1:kdim(2),:,:,:); % Odd even thingy - poor implementaiton
res.adjoint=1; % 1 = forward. -1 = complex conjugate
res=class(res,'PH');

disp('+Phase pattern operator initialized.')

%END
end