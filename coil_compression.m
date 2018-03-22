function kspace_data = coil_compression(kspace_data,nCh,varargin)
%%Coil compression using the BART toolbox

if ~isempty(varargin)
    ccmethod=varargin{1};
else
    ccmethod='-S';
end
kspace_data=ksp_reconframe_to_bart(kspace_data);
kspace_data=bart(['cc -p ',num2str(nCh),' ',ccmethod],kspace_data);
kspace_data=ksp_bart_to_reconframe(kspace_data);
% END
end