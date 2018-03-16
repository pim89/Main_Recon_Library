function kdata = radial_phase_correction_zero(kdata)
%% Simple radial phase correction method

kdim=size(kdata);
% Phase correction matrix
phase_corr_matrix=repmat(single(exp(-1j*angle(kdata(end/2+1,:,:,:,:,:,:,:,:,:,:,:)))),...
    [kdim(1) 1 1 1 1 1 1 1 1 1 1]);

% Apply correction
kdata=kdata.*phase_corr_matrix;

% END
end