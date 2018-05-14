function kspace_data = hannfilter(kspace_data)

kdim=size(kspace_data);

% Determine support for one readout
start1=0;
end1=0;
for n=1:kdim(1)
    if kspace_data(n,1,1,1,1)~=0
        start1=n;
        break;
    end
end

for n=kdim(1):-1:1
    if kspace_data(n,1,1,1,1)~=0
        end1=n;
        break;
    end
end

% Create hamming window
f=zeros(kdim);
dim=numel(start1:end1)*2;
ops=hamming(dim);
ops=ops(dim/2-floor(dim/4):dim/2+floor(dim/4)-1);
f(start1:end1,:,:,:,:)=repmat(ops,[1 kdim(2:end)]);

% Apply filter
kspace_data=f.*kspace_data;

% END
end