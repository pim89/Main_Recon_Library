function respiration = radial_3D_estimate_motion(kspace_data)
%%Estimate motion signal from 3D radial stack-of-stars k-space data

kdim=size(kspace_data);
respdata=dynamic_to_spokes(kspace_data(kdim(1)/2+1,:,:,:,:,:,:,:,:,:,:,:,:));
respiration=extract_resp_signal(squeeze(respdata));

% END
end