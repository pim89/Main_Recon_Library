function [kspace_data] = radial_phase_correction_reconframe(kspace_data,goldenangle)
%%Phase correction used in reconframe. Based on finding antiparallel spokes
%and doing cross correlation.

kdim=c12d(size(kspace_data));
cp=kdim(1)/2+1;
cph_pre=mean(matrix_to_vec(var(angle(kspace_data(cp,:,:)),[],2)));

% Get radial ang for uniform (rev) or golden angle
if goldenangle > 0
    d_ang=(pi/(((1+sqrt(5))/2)+goldenangle-1));
else
    d_ang=pi/(kdim(2));
end
rad_ang=mod(0:d_ang:d_ang*(kdim(2)-1),2*pi);

% Line reversal for uniform
if goldenangle == 0
    rad_ang(2:2:end)=rad_ang(2:2:end)+pi;
    rad_ang=mod(rad_ang,2*pi);
end

% Start reconframe algorhitm
signs=zeros(size(rad_ang));
zero2pi=0;
even_profiles=rad_ang > 0 & rad_ang < pi;
odd_profiles=rad_ang > pi & rad_ang < 2*pi;
if length(find(even_profiles)) ~= length(find(odd_profiles)) && mod(length(find(rad_ang == 0)),2)
    if length(find(even_profiles)) > length(find(odd_profiles))
        rad_ang(rad_ang == 0)=2*pi;
        zero2pi=1;
    end
end
even_profiles=rad_ang >= 0 & rad_ang < pi;
odd_profiles=rad_ang > pi & rad_ang <= 2*pi;
signs(even_profiles)=1;
signs(odd_profiles)=-1;
rad_ang=mod(rad_ang,pi);
if zero2pi
    rad_ang(rad_ang == 0)=pi;
end
[sorted_ang, ind_sorted]=sort(rad_ang);
signs=signs(ind_sorted);
ind_even=find(signs==1);
ind_odd=find(signs==-1);
l=min([length(ind_even),length(ind_odd)]);
ind_even=ind_even(1:l);
ind_odd=ind_odd(1:l);
            
% 1D fft
kspace_data=fftshift(ifft(ifftshift(kspace_data,1),[],1),1);
linPhase=sum(kspace_data(1:end-2,ind_sorted(ind_even),:,:,:,:,:,:,:,:).*conj(kspace_data(2:end-1,ind_sorted(ind_even),:,:,:,:,:,:,:,:)));
linPhase2=sum(kspace_data(1:end-2,ind_sorted(ind_odd),:,:,:,:,:,:,:,:).*conj(kspace_data(2:end-1,ind_sorted(ind_odd),:,:,:,:,:,:,:,:)));
linPhase=linPhase./abs(linPhase);
linPhase(isnan(linPhase))=0;
linPhase=angle(linPhase);
linPhase2=linPhase2./abs(linPhase2);
linPhase2(isnan(linPhase2))=0;
linPhase2=angle(linPhase2);
linPhaseavr=(linPhase+linPhase2)/2;          
linPhaseavr=median(linPhaseavr,2);

phase_off=-size(kspace_data,2)*linPhaseavr;
kspace_data(:,ind_sorted(ind_even),:,:,:,:,:,:,:,:)=bsxfun(@times,kspace_data(:,ind_sorted(ind_even),:,:,:,:,:,:,:,:),exp(1i.*bsxfun(@plus,bsxfun(@times,(0:(size(kspace_data,1)-1))',linPhaseavr),phase_off)));
kspace_data(:,ind_sorted(ind_odd),:,:,:,:,:,:,:,:)=bsxfun(@times,kspace_data(:,ind_sorted(ind_odd),:,:,:,:,:,:,:,:),exp(1i.*bsxfun(@plus,bsxfun(@times,(0:(size(kspace_data,1)-1))',linPhaseavr),phase_off)));


absPhase=sum(kspace_data(1:end-1,:,:,:,:,:,:,:),1);
[ma,ind_max]=max(reshape(abs(sum(sum(absPhase(:,:,:,:,:,:,:,:,:,:),2),5)),[],1));
[sl,co]=ind2sub([size(absPhase,3),size(absPhase,4)],ind_max);
absPhase=absPhase(:,:,sl,co,:);
absPhase=absPhase./abs(absPhase);
absPhase(isnan(absPhase))=0;

absPhase=angle(absPhase);
absPhasem=sum(sum(absPhase(:,:,:,:,:,:,:,:,:,:,:,:,:),2),5);
absPhasem=absPhasem./(1*size(absPhase(:,:,:,:,:,:,:,:,:,:,:,:,:),5));
absPhase=bsxfun(@minus,absPhase,absPhasem);
kspace_data(:,:,:,:,:,:,:,:,:,:,:,:,:)=bsxfun(@times,kspace_data(:,:,:,:,:,:,:,:,:,:,:,:,:),exp(1i*(bsxfun(@plus,-absPhase,absPhasem))));

kspace_data=fftshift(fft(ifftshift(kspace_data,1),[],1),1);
cph_post=mean(matrix_to_vec(var(angle(kspace_data(cp,:,:)),[],2)));
disp('+Radial reconframe phase correction.')
disp(['     Mean variance of k0 phase changed from: ',num2str(cph_pre),' -> ',num2str(cph_post)

% END
end

