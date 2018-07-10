function kdata_GROG = GROG_kdata(kdata,traj)
% [kSpace,phase_mod,para] = prepare_kSpace(kSpace_all,theta_all,para)

t1 = tic;
kdim=size(kdata);

%ifNUFFT             = para.ifNUFFT;
%kCenter             = para.kSpace_center;
%interp_method       = para.interp_method;

%%%%% pre-interpolation
disp('Pre-interpolate into Cartesian space per 2D slice...')

for z=1:kdim(3)
    G=GROG.init(kdata(:,:,z,:),squeeze(traj(1,:,:,:,:)),squeeze(traj(2,:,:,:,:)));
    kdata_GROG(:,:,z,:)=GROG.interp(kdata(:,:,z,:),G);
end

% END
end

  