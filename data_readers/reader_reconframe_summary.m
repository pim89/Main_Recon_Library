function seq = reader_reconframe_summary(MR)
% Summarize important sequence parameters into a struct

seq.mode=MR.Parameter.Scan.ScanMode;
seq.trajectory=MR.Parameter.Scan.AcqMode;
seq.contrast=MR.Parameter.Scan.Technique;
seq.echoes=MR.Parameter.Encoding.Echo+1;
seq.tr=MR.Parameter.Scan.TR*10^-3;
seq.te=MR.Parameter.Scan.TE*10^-3;
seq.fa=MR.Parameter.Scan.FlipAngle;
seq.channels=numel(MR.Parameter.Parameter2Read.chan);
seq.acqres=MR.Parameter.Scan.AcqVoxelSize;
seq.recres=MR.Parameter.Scan.RecVoxelSize;
seq.fov=MR.Parameter.Scan.curFOV;
seq.kspace=MR.Parameter.Scan.Samples;
seq.bandwidth=MR.Parameter.GetValue('RFR_SERIES_DICOM_PIXEL_BANDWIDTH');
% END
end