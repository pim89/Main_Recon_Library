function kspace_data = radial_phase_correction_zero(kspace_data)
%% Simple radial phase correction method

kdim=size(kspace_data);
cp=kdim(1)/2+1;

phase_corr_mtx=zeros(kdim,'single');
for p=1:prod(kdim(3:end))
    cph=angle(kspace_data(cp,:,p));
    phase_corr_mtx(:,:,p)=single(exp(-1j*repmat(cph,[kdim(1) 1])));
end

% Apply phase correction by matrix multiplication
cph_pre=mean(matrix_to_vec(var(angle(kspace_data(cp,:,:)),[],2)));
kspace_data=kspace_data.*phase_corr_mtx;
cph_post=mean(matrix_to_vec(var(angle(kspace_data(cp,:,:)),[],2)));

disp(['>> Mean variance of k0 phase changed from: ',num2str(cph_pre),' -> ',num2str(cph_post)])

% END
end