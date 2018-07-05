function res = configure_compressed_sense_moco(params)
%Configures the structure to send to the nonlinear conjugate gradient
%solver (nlcg_moco).

% Check if struct contains all the required parameters
check_compressed_sense_input(params);

% Scale data
dscale=100/norm(abs(params.y(:)));

% Nonlinear conjugate gradient
x0=params.S*(params.N'*(params.W*params.y));
[res,cost]=nlcg_moco(x0,params);

% Descale data
res=res*(1/dscale);

% Append resvec if it converges reached prior to N_iter
cost=cost(1,:);
if size(cost,1)<params.Niter;cost(end+1:params.Niter)=0;end

% END
end