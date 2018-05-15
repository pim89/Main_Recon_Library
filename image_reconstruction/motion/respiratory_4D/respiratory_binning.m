function resp_bin_idx = respiratory_binning(respiration,n_phases,varargin)
%%Respiratory phase binning
% Function gets indices to transform the dimensions of the kspace-data,
% trajectory and density functions. Varargin arguments can be 'phase' or
% 'amplitude'.

% Check input
if isempty(varargin)
    par.sort_data='phase';
else
    par.sort_data=varargin{1};
end

% Create struct to feed to Bjorns binning code
par.respiration=respiration;
par.resp_phases=n_phases;

% Perform the binning
resp_bin_idx=sort_data_4D(par);

disp(['+Data binned in ',num2str(n_phases),' respiratory phase.'])
% END
end