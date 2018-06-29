function res = configure_compressed_sense_multiband(params,varargin)
%Configures the structure to send to the nonlinear conjugate gradient
%solver (nlcg).

% Check if struct contains all the required parameters
check_compressed_sense_input(params);

% Scale data
dscale=100/norm(abs(params.y(:)));

% Nonlinear conjugate gradient
res=params.S*(params.N'*(params.W*(params.PH'*params.y)));
for n=1:3
    [res,cost]=nlcg_multiband(res,params);
end

% Descale data
res=res*(1/dscale);

% Append resvec if it converges reached prior to N_iter
cost=cost(1,:);
if size(cost,1)<params.Niter;cost(end+1:params.Niter)=0;end

% END
end