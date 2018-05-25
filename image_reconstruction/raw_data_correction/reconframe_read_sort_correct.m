function MR = reconframe_read_sort_correct(MR,type)
%% Simple reconframe reader
MR.Parameter.Parameter2Read.typ=type;
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