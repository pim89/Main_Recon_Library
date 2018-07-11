function pics_call = compose_pics_call(par)
%% Function to compose the pics call

pics_call='pics -S -d5 -l1  -m ';

% Wavelet regularization
if isfield(par,'wavelet')
    pics_call=strcat(pics_call,[' -r',num2str(par.wavelet)]);
end

% Total variation regularization
if isfield(par,'TV')
    % Create bitmask depending on the dimensions
    tv_idx=find(dim_reconframe_to_bart(par.TV)>0);
    bm=@(x)(sum(2.^x));
   
    pics_call=strcat(pics_call,[' -l1 -RT:',num2str(bm(tv_idx-1)),':0:',...
        num2str(max(par.TV))]);
end

% Locally low rank regularization
if isfield(par,'LR')
    % Create bitmask depending on the dimensions
    tv_idx=find(dim_reconframe_to_bart(par.LR)>0);
    bm=@(x)(sum(2.^x));
   
    pics_call=strcat(pics_call,[' -RL:','7',':0:',...
        num2str(max(par.LR))]);
end

% Change number of iterations
if isfield(par,'Niter')
    pics_call=strcat(pics_call,[' -i',num2str(par.Niter)]);
end

% Add trajectory 
if isfield(par,'traj')
    pics_call=strcat(pics_call,' -t');
end

% Add mask for cartesian only! 
% if isfield(par,'mask')
%     pics_call=strcat(pics_call,' -p');
% end

% END
end