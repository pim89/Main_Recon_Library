function res = configure_compressed_sense(params,varargin)
%Configures the structure to send to the nonlinear conjugate gradient
%solver (nlcg).

isbart=0;
if ~isempty(varargin)
    isbart=1;
end

if isbart
    params=check_compressed_sense_input(params,'bart');
    pics_call=compose_pics_call(params); 
    
    % Non-cartesian case
    if ~isfield(par,'mask')
        res=bart(pics_call,ktraj_reconframe_to_bart(.5*params.traj),...  % .5 required vs normal nufft
            ksp_reconframe_to_bart(params.kspace_data),...
            params.csm);
    else % Cartesian case
        res=bart(pics_call,params.mask,...  
            ksp_reconframe_to_bart(params.kspace_data),...
            params.csm);
    end
    res=isp_bart_to_reconframe(res);
else    
    % Check if struct contains all the required parameters
    check_compressed_sense_input(params);
    
    % Scale data
    dscale=100/norm(abs(params.y(:)));
    
    % Nonlinear conjugate gradient
    x0=params.S*(params.N'*(params.W*params.y));
    [res,cost]=nlcg(x0,params);
    
    % Descale data
    res=res*(1/dscale);
    
    % Append resvec if it converges reached prior to N_iter
    cost=cost(1,:);
    if size(cost,1)<params.Niter;cost(end+1:params.Niter)=0;end
end
% END
end