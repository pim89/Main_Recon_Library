function MR = reconframe_read_sort_correct(MR,type)
%% Simple reconframe reader
MR.Parameter.Parameter2Read.typ=type;
MR.ReadData;
MR.RandomPhaseCorrection;
MR.RemoveOversampling;
MR.PDACorrection;
MR.DcOffsetCorrection;
MR.MeasPhaseCorrection;
MR.SortData;

% END
end