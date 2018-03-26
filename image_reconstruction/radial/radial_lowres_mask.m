function mask = radial_lowres_mask(kdim,lr)

mask=ones(kdim,'single');
% Calculate mask threshold
thresh=round(kdim(1)/2*(lr-1)/lr);
mask([1:thresh end-thresh+1:end],:,:,:,:,:,:,:,:,:,:,:)=0;

disp('+Mask created for zerofilling of radial data.')
% END
end