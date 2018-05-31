function data=ImagParamsold( pat,ext )
%ImagParams print on screen some image parameters for MR
% The input is the path to the folder containing the dicom files
% Developed by m.maspero@umcutrecht.nl, 2015
% In case of comments/improvements just let me know
if nargin<2
    ext='/*.dcm*';
else
end

dicomsMR=dir(fullfile(pat,ext));

if numel(dicomsMR)==0
    error('No Dicom file with .dcm extension')
end
%%
if numel(dicomsMR)>6
    dcmMR=dicominfo([pat,'/',dicomsMR(5).name]);
    dcmMR2=dicominfo([pat,'/',dicomsMR(6).name]);
else
    dcmMR=dicominfo([pat,'/',dicomsMR(1).name]);
    dcmMR2=0;
end
assignin('base','dcmMR',dcmMR)
assignin('base','dcmMR2',dcmMR2)
if ~strcmp(dcmMR.Modality,'MR')
    warning('The selected dicoms are not MR images')
end
%% Image Type string
j=0;t=0;
Eco=zeros(1,2);
Typ=cell(1);
for ii=1:5:numel(dicomsMR);
    j=j+1;
    dcm=dicominfo([pat,'/',dicomsMR(ii).name]);
    if isfield(dcm,'ImageType')
        Typ{j}=dcm.ImageType;
        if isempty(strfind(Typ{j},'ORIGINAL'))
        else
            t=t+1;
            Eco(t)=dcm.EchoTime;
        end
    else
        Typ{j}='none';
        %t=t+1;
        %Eco(t)=0;
    end
end

Ecco=sort(unique(Eco));
if numel(Typ)==1
    T=Typ{1};
else
    T=unique(Typ);
end
if numel(dicomsMR)>6
    A=horzcat(T{:});
else
    A=T;
end
Type=([regexp(A,['\\M\'],'match');regexp(A,['\\IP\'],'match');regexp(A,['\\OP\'],'match');...
    regexp(A,['\\R\'],'match');regexp(A,['\\I\'],'match');regexp(A,['\\P\'],'match');...
    regexp(A,['\\W\'],'match');regexp(A,['\\F\'],'match')]);
% A=cell2struct(horzcat(Type),'Type',1);

if ~isempty(regexp(dcmMR.SeriesDescription,['\w*B1 calibration\w*']))
fprintf(['Acq date: %s @ %s ; PatiendID: %s \n "%s" \n'],...
    dcmMR.StudyDate,dcmMR.StudyTime,dcmMR.PatientID,...
    dcmMR.SeriesDescription)
else
data.FieldStrength = dcmMR.MagneticFieldStrength;
data.PrecessionIsClockwise = 1;
AcqMat=dcmMR.AcquisitionMatrix(dcmMR.AcquisitionMatrix~=0);
if isfield(dcmMR,'Private_2001_1018')
Nr_Slices=dcmMR.Private_2001_1018;
else
   Nr_Slices=dcmMR.MRSeriesNrOfSlices;
end
%%
data.TR = dcmMR.RepetitionTime;
if Ecco(1)==0
    data.TE(1:numel(Ecco)-1) = Ecco(2:end);
    nrEcho=numel(Ecco)-1;
else
    data.TE(1:numel(Ecco)) =Ecco;
    nrEcho=numel(Ecco);
end
if numel(Ecco)==1
    nrEcho=1;
    if Ecco==0
        data.TE=dcmMR.EchoTime;
        %    data.TR=0.;
    end
end
data.Type=Type;
data.VoxelSize=[dcmMR.PixelSpacing(1),dcmMR.PixelSpacing(2),dcmMR.SpacingBetweenSlices];
if isfield(dcmMR,'Private_2005_140f.Item_1.Spoiling')
Spoil=dcmMR.Private_2005_140f.Item_1.Spoiling;
elseif isfield(dcmMR,'PrivatePerFrameSq.Item_1.Spoiling')
Spoil=dcmMR.PrivatePerFrameSq.Item_1.Spoiling;
else
Spoil='Spoiled?';
end


if isfield(dcmMR,'Private_2001_1020')
Sequence=dcmMR.Private_2001_1020;
elseif  isfield(dcmMR,'MRImageScanningSequencePrivate')
Sequence=dcmMR.MRImageScanningSequencePrivate;
else
    Sequence='booo- contrast seq? ';
end
    %%

fprintf(['Acq date: %s @ %s ; PatiendID: %s (%s)\n',...
    '"%s" Imaging parameters @  %.2f T: %s cartesian %s %s %s, %i-echo (%s, %s, Fat-sat: %s) \n',...
    'TE1/TE2/TE... = %s ms; TR = %.2f ms; FA= %i deg; BW = %.1f Hz; WFS = %.2f\n',...
    'Acq Matrix %ix%ix%i, PhaseEnc(%i); Recon Matrix %ix%ix%i; Recon Res = %.1fx%.1fx%.1f mm \n ',...
    'FOV = %.1fx%.1fx%.1f mm \n'...,
    'NSA = %i ; Acq Duration = %.2f s\n',...
    'Image Type:\n %s \n --------------------- \n'],...
    dcmMR.AcquisitionDate,dcmMR.AcquisitionTime,dcmMR.PatientID,dcmMR.PatientSex,...
    dcmMR.ProtocolName,data.FieldStrength,dcmMR.MRAcquisitionType,...
    Spoil,...
    Sequence,...
    dcmMR.ScanningSequence,nrEcho,dcmMR.SequenceVariant,dcmMR.MRSeriesScanningTechniqueDesc,dcmMR.MRFatSaturationTechnique,...
    num2str(horzcat(data.TE)),data.TR,dcmMR.FlipAngle,dcmMR.PixelBandwidth,dcmMR.MRSeriesWaterFatShift,...
    AcqMat(1),AcqMat(2),Nr_Slices,dcmMR.NumberOfPhaseEncodingSteps,dcmMR.Rows,dcmMR.Columns,Nr_Slices,...
    data.VoxelSize,...
    dcmMR.Rows*dcmMR.PixelSpacing(1),dcmMR.Columns*dcmMR.PixelSpacing(2),dcmMR.SpacingBetweenSlices*Nr_Slices,...
    dcmMR.NumberOfAverages,dcmMR.AcquisitionDuration,horzcat(Type{:}));
end
end

