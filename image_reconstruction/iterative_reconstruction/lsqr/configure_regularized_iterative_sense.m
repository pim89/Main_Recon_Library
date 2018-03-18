function [res,lsvec] = configure_regularized_iterative_sense(params)
%Function passes the Operators struct to the matlab LSQR routine. The
% forward and adjoint operations of the model are described in the file
% regularize_iterative_sense.m. If no total variation penalty is applied,
% Tikhonov regularization will be applied

% LSQR settings
ops=optimset('Display','off');

% Scale data
dscale=100/norm(abs(params.y(:)));

% Function handle for (regularized) lsqr
func=@(x,tr) regularized_iterative_sense(x,params,tr);
s=matrix_to_vec(params.y);
s=double([s ;zeros(prod(params.idim([1 2 3 5 6 7 8 9 10 11 12])),1)]);

% LSQR
[tmp,~,~,~,~,lsvec]=lsqr(func,s,1E-15,params.Niter);
res=reshape(1/dscale*tmp,[params.idim(1:3) 1 params.idim(5:12)]);

% Append resvec if it converges reached prior to N_iter
if size(lsvec,1)<params.Niter;lsvec(end+1:params.Niter)=0;end

% END
end