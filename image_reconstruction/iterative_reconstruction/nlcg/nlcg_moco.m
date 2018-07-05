function [x,cost] = nlcg_moco(x0,params)
% 
% 20160615 - Non linear conjugate gradient solver, based on Ricardo Ortazos
% code. I made modifications on the setting of lambda, i.e. expressed
% lambda is a ratio between the L1 & L2 gradient. Changed the CG update parameter (bk),
% according to considerations in : Hager, W. W., & Zhang, H. (2006). 
% A Survey of Nonlinear Conjugate Gradient Methods. Stopping criteria are
% now set to equal < 5 % change in L1 && L2 && L1+L2 in cost function. The
% function is compatible with both fessler/greengard gridders.
%
% Given the acquisition model y = E*x, and the sparsifying transform W, 
% the pogram finds the x that minimizes the following objective function:
%
% f(x) = ||E*x - y||^2 + lambda * ||W*x||_1 
%

% starting point
x=x0;
clear x0 % saves memory

% line search parameters
maxlsiter=3;
gradToll=1e-8;
alpha=0.01;  
beta=params.beta;
t0=1 ; 
k=0;
cost=[];
    
% compute g0  = grad(f(x))
g0 = grad(x,params);
dx = -g0;

while(1)
    
    % backtracking line-search
	lsiter=0;
    t=t0;
    f0=objective(x,dx,0,params);
    [f1,l1_tv,l2] = objective(x,dx,t,params);

	while (f1 > f0 - alpha*t*abs(g0(:)'*dx(:)))^2 & (lsiter<maxlsiter)
		lsiter=lsiter + 1;
		t=t*beta;
		[f1,l1_tv,l2]=objective(x,dx,t,params);
    end

	% control the number of line searches by adapting the initial step search
	if lsiter > 2, t0 = t0 * beta;end 
	if lsiter<1, t0 = t0 / beta; end

    % update x
	x=(x+t*dx);

    % Report cost function
    cost(:,k+1)=[f1;l1_tv;l2]; 
    fprintf('Iter=%d | Cost=%6.1e | L1_tv=%6.1e | L2=%6.1e | nrls=%d\n',k,f1,l1_tv,l2,lsiter);       

    % stopping criteria (to be improved)
    k = k + 1;
	if (k > params.Niter) || (norm(dx(:)) < gradToll), break; end
    
    %conjugate gradient calculation
	g1=grad(x,params);
	bk = g1(:)'*g1(:)/(g0(:)'*g0(:)+eps);
    %yk=g1-g0;
    %bk=abs((permute(yk(:)-2*dx(:)*((yk(:)'*yk(:))/(dx(:)'*yk(:))),[2 1 3]))*(g1(:)/(dx(:)'*yk(:)))); % New GC update step
	g0 = g1;
	dx =  - g1 + bk* dx;

end

return;
end

function [res,L1_TV,L2obj] = objective(x,dx,t,params) 

% L2 norm part
w=params.W*(params.N*(params.S'*(x+t*dx)))-params.y;
%w=params.W*(params.N*(params.S'*(params.U'*(x+t*dx))))-params.y;
L2obj=w(:)'*w(:);

 % TV part or tikhonov part
l1smooth=1e-15;
%w=reshape(params.TV*(matrix_to_vec(x+t*dx)),[params.idim(1:3) 1 params.idim(5:end)]);
w=reshape(params.TV*(matrix_to_vec(params.U'*(x+t*dx))),[params.idim(1:3) 1 params.idim(5:end)]);
TVobj=sum((conj(w(:)).*w(:)+l1smooth).^(1/2));

% objective function
res=L2obj+TVobj; % TV lambda is already in the matrix T
L1_TV=TVobj;

end

function g = grad(x,params)

% L2-norm part
%L2Grad=2.*(params.U*(params.S*(params.N'*(params.W*((params.W*(params.N*(params.S'*(params.U'*x))))-params.y)))));
L2Grad=2.*(params.S*(params.N'*(params.W*((params.W*(params.N*(params.S'*x)))-params.y))));

% TV part
l1smooth=1e-15;
w=reshape(params.TV*matrix_to_vec(params.U'*(x)),[params.idim(1:3) 1 params.idim(5:end)]);
%TVGrad=reshape(params.TV'*(matrix_to_vec(w.*(w.*conj(w)+l1smooth).^(-0.5))),[params.idim(1:3) 1 params.idim(5:end)]);
TVGrad=params.U*(reshape(params.TV'*(matrix_to_vec(w.*(w.*conj(w)+l1smooth).^(-0.5))),[params.idim(1:3) 1 params.idim(5:end)]));

% composite gradient
g=L2Grad+TVGrad;

end


