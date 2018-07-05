function res = configure_compressed_sense_gmd(params)
%Configures the structure to send to the nonlinear conjugate gradient
%solver (nlcg_moco).

% Check if struct contains all the required parameters
check_compressed_sense_input(params);

% Scale data
dscale=100/norm(abs(params.y(:)));

% Nonlinear conjugate gradient
x0=sum(params.U'*(params.S*(params.N'*(params.W*params.y))),5);
[res,cost]=nlcg_gmd(x0,params);

% Descale data
res=res*(1/dscale);

% Append resvec if it converges reached prior to N_iter
cost=cost(1,:);
if size(cost,1)<params.Niter;cost(end+1:params.Niter)=0;end

% END
end