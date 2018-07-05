function MR = reconframe_read_sort_correct(MR,type,coil_comp)
%% Simple reconframe reader
MR.Parameter.Parameter2Read.typ=type;

% Coil compression
if coil_comp > 0
    MR.Parameter.Recon.ArrayCompression='yes';
    MR.Parameter.Recon.ACNrVirtualChannels=coil_comp;
end
MR.Parameter.Parameter2Read.ky=(0:500)';

% Read data and corrections
MR.ReadData;
disp('+Read raw data.')
MR.RandomPhaseCorrection;
MR.RemoveOversampling;
MR.PDACorrection;
MR.DcOffsetCorrection;
MR.MeasPhaseCorrection;
disp('+Basic corrections finished.')
MR.SortData;
%MR.RingingFilter;
disp('+Data sorting is finished.')

% END
end