function MR = reconframe_read_sort_correct(MR,type,noisenavigator)
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
if noisenavigator;noiseNav(MR,1);end
MR.SortData;
MR.RingingFilter;

% END
end