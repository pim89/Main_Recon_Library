function  res = DVF(dvf,dvf_adj)
% Operator to apply deformation vector fields to an image
% You need to provide both the forward and adjoint matrices
% Matrix dimensions need to be [x y 2 1 dyn]
% Only 2D support at the moment
% Tom Bruijnen - University Medical Center Utrecht - 20180626

res.dvf=dvf;
res.dvf_adj=dvf_adj;
res.adjoint=1; % 1 = forward (multicoil --> single coil). -1 = inverse operator
res=class(res,'DVF');

disp('+Deformation vector field operator initialized.')

%END
end