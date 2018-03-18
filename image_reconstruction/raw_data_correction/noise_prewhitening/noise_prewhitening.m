function kspace_data = noise_prewhitening(kspace_data,noise_data)
%%NOISE PREWHITENING

noise_covariance=noise_covariance_mtx(squeeze(noise_data));
noise_decorrelation=noise_decorrelation_mtx(noise_covariance);
kspace_data=permute(apply_noise_decorrelation_mtx(permute(kspace_data,...
    [1:3 5:12 4]),noise_decorrelation),[1:3 12 4:11]);

% END
end