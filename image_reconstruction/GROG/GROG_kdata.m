function kdata_GROG = GROG_kdata(kdata,traj)
% [kSpace,phase_mod,para] = prepare_kSpace(kSpace_all,theta_all,para)

t1 = tic;
kdim=size(kdata);

%ifNUFFT             = para.ifNUFFT;
%kCenter             = para.kSpace_center;
%interp_method       = para.interp_method;

%%%%% pre-interpolation
disp('+Pre-interpolate into Cartesian space per 2D slice...')

for dyn=1:kdim(5)
for z=1:kdim(3)
    G=GROG_init(kdata(:,:,z,:,dyn),squeeze(traj(1,:,:,:,dyn)),squeeze(traj(2,:,:,:,dyn)));
    kdata_GROG(:,:,z,:,dyn)=GROG_interp(kdata(:,:,z,:,dyn),G);
end
end

% END
end

  