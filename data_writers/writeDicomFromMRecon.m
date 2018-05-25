function [output] = writeDicomFromMRecon(MR,imagevolume,varargin)
%% function writeDicomFromMRecon(inpurpars)
%
% Function to formulate a dicomhead from the MRecon struct and write data
% to dicom files
%
% INPUT:        MRecon         = MRecon structure
%               imagevolume    = 3D image volume (2D, single slice, is also
%               allowed)
%               output_path    = Path where the final images should be
%               written (optional)
%               output_name    = Name of the files (optional)
%
% Additional input idea: custom dicom fields?
% MRinfoglobal field name needs to be 'varargin(x)'.... how?
% Check if varargin field name is a valid dicom field????
%
% OUTPUT:       output         = Structure with the derived dicom tags
%
% Requires ReconFrame software package to acces information in the MRecon
% structure.
% Assumes this MR scan is part of a Study (complete exam). The Study UID
% will be taken from there. The reconstructed images of a single Series
% will receive a new SeriesUID 
%
% example:
% [output] = writeDicomFromMRecon(MRecon,imagevolume,output_path,output_name)
%
% Init: T. Schakel 2017
%
% Last edit - 2018/03/14 T. Bruijnen

%% Check input
%number of arguments
defaultname = true;
if nargin < 2
    error('Not enough input arguments. Accepted input: MRecon,imagevolume,output_path(optional),output_name(optional)');
elseif nargin < 3
    disp('No output path and name provided. Data will be written in the current directory with instanceUID filename');
    output_path = pwd;
elseif nargin < 4
    disp('No output name provided. Data will be written with instanceUID filename');
    output_path = varargin{1};
elseif nargin < 5
    output_path = varargin{1};
    if ~exist(output_path)
        mkdir(output_path);
    end
    output_name = varargin{2};
    defaultname = false;
elseif nargin > 4
    error('Too many input arguments. Accepted input: MRecon,imagevolume,output_path(optional),output_name(optional)');
end

%MRecon struct check
if ~isa(MR,'MRecon')
    msg=[inputname(1),' is not an MRecon structure'];
    error(msg);
end

%check imagevolume dimensions 
if ndims(imagevolume) < 2 || ndims(imagevolume) > 4
    msg=['Cannot handle data dimensions. ',inputname(2),' should be a 3D image volume (or 2D single slice)'];
    error(msg);
end

%imagevolume data format
%dicomwrite cannot handle single, so use signed int16
%this will pose an issue with data that has a small range however. 
%can use a scalingfactor, but how to determine? 
imagevolume=abs(imagevolume);
imagevolume=3276.7 * (imagevolume/max(imagevolume(:)));
scalingfactor=10;
imagevolume = int16(imagevolume * scalingfactor);

%dimensions volume
[nX,nY,nZ,nDyns,nCard,nEcho,nLoc,nMix,nEx1,nEx2,nAve] = size(imagevolume);

%% Set the tags
%Machine
MRinfoglobal.Format                 = 'DICOM';
MRinfoglobal.Modality               = MR.Parameter.GetValue('RFR_SERIES_DICOM_MODALITY');
MRinfoglobal.InstitutionName        = MR.Parameter.GetValue('RFR_SERIES_DICOM_INSTITUTION_NAME');
MRinfoglobal.InstitutionalDepartmentName = MR.Parameter.GetValue('RFR_SERIES_DICOM_INSTITUTIONAL_DEPARTMENT_NAME');
MRinfoglobal.Manufacturer           = MR.Parameter.GetValue('RFR_SERIES_DICOM_MANUFACTURER');
MRinfoglobal.ManufacturerModelName  = MR.Parameter.GetValue('RFR_SERIES_DICOM_MANUFACTURERS_MODEL_NAME');
MRinfoglobal.PerformedStationAETitle = MR.Parameter.GetValue('RFR_EXAM_DICOM_PERFORMED_STATION_AE_TITLE');
MRinfoglobal.StationName            = 'YarraServer'; %use the name of the pc on which the reconstruction was performed (localhost)
MRinfoglobal.MagneticFieldStrength  = MR.Parameter.GetValue('HW_main_magnetic_field_mT') / 1000;
MRinfoglobal.SoftwareVersion        = num2str([MR.Parameter.GetValue('RFR_SERIES_DICOM_SOFTWARE_VERSIONS0'),'/',MR.Parameter.GetValue('RFR_SERIES_DICOM_SOFTWARE_VERSIONS1')]);

%Patient
MRinfoglobal.PatientName            = MR.Parameter.GetValue('RFR_PATIENT_DICOM_PATIENT_NAME');
MRinfoglobal.PatientID              = MR.Parameter.GetValue('RFR_PATIENT_DICOM_PATIENT_ID');
MRinfoglobal.PatientBirthDate       = MR.Parameter.GetValue('RFR_PATIENT_DICOM_PATIENT_BIRTH_DATE');
MRinfoglobal.PatientSex             = MR.Parameter.GetValue('RFR_PATIENT_DICOM_PATIENT_SEX');
MRinfoglobal.PatientWeight          = MR.Parameter.GetValue('RFR_STUDY_DICOM_PATIENTS_WEIGHT');
MRinfoglobal.PregnancyStatus        = str2double(MR.Parameter.GetValue('RFR_STUDY_DICOM_PREGNANCY_STATUS'));

if strcmp(MR.Parameter.Scan.PatientPosition,'HeadFirst')
    headorfeet = 'HF';
else
    headorfeet = 'FF';
end

if strcmp(MR.Parameter.Scan.PatientOrientation,'Supine')
    proneorsupine = 'S';
elseif strcmp(MR.Parameter.Scan.PatientOrientation,'Prone')
    proneorsupine = 'P';
else
    %exotic orientation (not supported now)
    disp('PatientOrientation is not Supine or Prone! Orientation may be incorrect');
    proneorsupine = 'S';
end

MRinfoglobal.PatientPosition        = [headorfeet,proneorsupine]; %eg 'HFS'

% Orientation (or is this a dynamic parameter?
[direcMatRL,direcMatAP,direcMatFH] = get_direct_matrix(MR);
offcentre = MR.Parameter.Scan.Offcentre;
numbStacks = MR.Parameter.Scan.Stacks;
direc_cosine = [direcMatRL(1); direcMatAP(1); direcMatFH(1); direcMatRL(2); direcMatAP(2); direcMatFH(2)];
MRinfoglobal.ImageOrientationPatient = direc_cosine;

% MRinfoglobal.ImageOrientationPatient = [1;0;0;0;1;0]; % this the default setting -> how to derive this from the data?
%MRinfoglobal.ImageOrientationPatient = [1;0;0;0;0.99446749687194;-0.1050447598099];

%Study
MRinfoglobal.StudyInstanceUID       = MR.Parameter.GetValue('RFR_STUDY_DICOM_STUDY_INSTANCE_UID');
MRinfoglobal.StudyID                = MR.Parameter.GetValue('RFR_EXAM_DICOM_PERFORMED_PROCEDURE_STEP_ID');
MRinfoglobal.ProtocolName           = MR.Parameter.GetValue('RFR_SERIES_DICOM_PROTOCOL_NAME'); 

%Series (scan)
MRinfoglobal.SeriesDescription      = MR.Parameter.GetValue('RFR_SERIES_DICOM_SERIES_DESCRIPTION'); 
MRinfoglobal.SeriesInstanceUID      = dicomuid; %generate new UID for series
tmp = MR.Parameter.GetValue('RFR_SERIES_PIIM_MR_SERIES_ACQUISITION_NUMBER');
if ischar(tmp)
   tmp = uint16(str2num(tmp));
else
   tmp = uint16(tmp);
end;
MRinfoglobal.AcquisitionNumber      = tmp; % uint16(str2num(MR.Parameter.GetValue('RFR_SERIES_PIIM_MR_SERIES_ACQUISITION_NUMBER')));
MRinfoglobal.AcquisitionDuration    = MR.Parameter.GetValue('AC_total_scan_time');
newSeriesNumber                     = MR.Parameter.GetValue('RFR_SERIES_DICOM_SERIES_NUMBER');   %What to do with the series number?? Function input? Always increment the default number?
if ischar(newSeriesNumber)
   newSeriesNumber = uint16(str2num(newSeriesNumber));
else
   newSeriesNumber = uint16(newSeriesNumber);
end;
MRinfoglobal.SeriesNumber           = newSeriesNumber;
MRinfoglobal.FrameOfReferenceUID    = MR.Parameter.GetValue('RFR_SERIES_DICOM_FRAME_OF_REFERENCE_UID');
MRinfoglobal.SeriesTime             = MR.Parameter.GetValue('RFR_SERIES_DICOM_SERIES_TIME');

MRinfoglobal.NumberOfSlicesMR       = str2double(MR.Parameter.GetValue('RFR_SERIES_PIIM_MR_SERIES_NR_OF_SLICES')); 
MRinfoglobal.SliceThickness         = MR.Parameter.GetValue('EX_GEO_slice_thickness'); %or EX_GEO_voxel_size_s? 3D vs MS
MRinfoglobal.SpacingBetweenSlices   = MRinfoglobal.SliceThickness + MR.Parameter.GetValue('EX_GEO_cur_stack_slice_gap'); %which slice gap parameter to take? Defined per stack...
MRinfoglobal.PixelSpacing           = [MR.Parameter.Scan.RecVoxelSize(1); MR.Parameter.Scan.RecVoxelSize(2)]; %2 entries, will typically be the same value. 

% These have the wrong 
% MRinfoglobal.EchoTime               = str2double(MR.Parameter.GetValue)
% MRinfoglobal.RepetitionTime         = str2double(MR.Parameter.GetValue('RFR_SERIES_PIIM_MR_SERIES_REPETITION_TIME'));
% MRinfoglobal.ImagingFrequency       = str2double(MR.Parameter.GetValue('RFR_SERIES_PIIM_MR_SERIES_IMAGING_FREQUENCY'));
MRinfoglobal.ImagedNucles           = num2str(MR.Parameter.GetValue('VW_imaged_nucleus'));
% MRinfoglobal.EchoTrainLength        = str2double(MR.Parameter.GetValue('RFR_SERIES_PIIM_MR_SERIES_ECHO_TRAIN_LENGTH'));
% MRinfoglobal.FlipAngle              = str2double(MR.Parameter.GetValue('RFR_SERIES_PIIM_MR_SERIES_FLIP_ANGLE'));

% MRinfoglobal.SAR                    = str2double(MR.Parameter.GetValue('AC_act_SAR'));
% MRinfoglobal.dBdt                   = str2double(MR.Parameter.GetValue('AC_dbdt_level'));

MRinfoglobal.WindowWidth = 0.5 * max(imagevolume(:)); % just a guess
MRinfoglobal.WindowCenter = 0.25 * max(imagevolume(:)); % just a guess

MRinfoglobal.InstanceCreationDate = datestr((date),'yyyymmdd');
MRinfoglobal.InstanceCreationTime = datestr((clock),'HHMMSS');

MRinfoglobal.MRAcquisitionType = MR.Parameter.Scan.ScanMode;

% Dynamic information
MRinfoglobal.NumberOfTemporalPositions = nDyns;

%% Set slice specific tags
%loop over slices
%make an MRinfo cell for reference
if strcmp(MRinfoglobal.MRAcquisitionType,'3D')
    for dyn = 1:nDyns
        for slice=1:nZ
            MRinfo{dyn,slice} = MRinfoglobal;
            MRinfo{dyn,slice}.SOPInstanceUID = dicomuid; % new UID for slice
            if defaultname
                sliceFileName = fullfile(output_path,['mr_',MRinfo{dyn,slice}.SOPInstanceUID,'.dcm']);
            else
                sliceFileName = fullfile(output_path,[output_name,num2str(slice,'%04u'),'.dcm']); % %04u -> add leading zeros, 4 digits total.
            end
            MRinfo{dyn,slice}.Filename = sliceFileName;
            MRinfo{dyn,slice}.InstanceNumber = ((slice-1)*nDyns)+dyn;
            MRinfo{dyn,slice}.ImagePositionPatient = MR.Transform([1;1;slice],'ijk','RAF'); %coordinates of the top left pixel in the current slice (in the patient coordinate frame)
            MRinfo{dyn,slice}.TemporalPositionIdentifier = dyn;
            %MRinfo{slice}.SliceLocation = Zoffset + slice * MRinfoglobal.SpacingBetweenSlices;
            dicomwrite(squeeze(imagevolume(:,:,slice,dyn)),sliceFileName,MRinfo{dyn,slice});
        end
    end;
elseif strcmp(MRinfoglobal.MRAcquisitionType,'2D')
    for dyn=1:nDyns
        MRinfo{dyn} = MRinfoglobal;
        MRinfo{dyn}.SOPInstanceUID = dicomuid; % new UID for dynamic time point
        if defaultname
            sliceFileName = fullfile(output_path,['mr_',MRinfo{dyn}.SOPInstanceUID,'.dcm']);
        else
            sliceFileName = fullfile(output_path,[output_name,num2str(dyn,'%04u'),'.dcm']); % %04u -> add leading zeros, 4 digits total.
        end
        MRinfo{dyn}.Filename = sliceFileName;
        MRinfo{dyn}.InstanceNumber = dyn;
        MRinfo{dyn}.ImagePositionPatient=MR.Transform([1;1;1],'ijk','RAF');
        MRinfo{dyn}.NumberOfTemporalPositions = nDyns;
        dicomwrite(squeeze(imagevolume(:,:,1,dyn)),sliceFileName,MRinfo{dyn});
    end;
else % M2D/MS
    for stacks = 1:numbStacks
        for slice = 1:nZ
            [direcMatRL,direcMatAP,direcMatFH] = get_direct_matrix(MR,stacks);
            direc_cosine = [direcMatRL(1); direcMatAP(1); direcMatFH(1); direcMatRL(2); direcMatAP(2); direcMatFH(2)];
            MRinfoglobal.ImageOrientationPatient = direc_cosine;
            MRinfo{slice} = MRinfoglobal;
            MRinfo{slice}.SOPInstanceUID = dicomuid; % new UID for slice
            if defaultname
                sliceFileName = fullfile(output_path,['mr_',MRinfo{slice}.SOPInstanceUID,'.dcm']);
            else
                sliceFileName = fullfile(output_path,[output_name,num2str(slice,'%04u'),'.dcm']); % %04u -> add leading zeros, 4 digits total.
            end
            MRinfo{slice}.Filename = sliceFileName;
            MRinfo{slice}.InstanceNumber = slice;
            MRinfo{slice}.ImagePositionPatient=MR.Transform([1;1;slice],'ijk','RAF'); %coordinates of the top left pixel in the current slice (in the patient coordinate frame)
            %MRinfo{slice}.SliceLocation = Zoffset + slice * MRinfoglobal.SpacingBetweenSlices;
            dicomwrite(squeeze(imagevolume(:,:,slice)),sliceFileName,MRinfo{slice});
        end  
    end;
end;

output=MRinfo;

%% Helper functions
    function [direcMatRL,direcMatAP,direcMatFH] = get_direct_matrix(MR,stacknumb)
        if nargin < 2
            stacknumb = 1;
        end;
        angulation = MR.Parameter.Scan.Angulation(stacknumb,1:end);
        orientation = MR.Parameter.Scan.Orientation(stacknumb,1:end);
        switch orientation;
            case 'TRA' %1
                matrixX = zeros(3,1);
                matrixY = zeros(3,1);
                matrixZ = zeros(3,1);
                matrixX(1) = 1;
                matrixY(2) = 1;
                matrixZ(3) = 1;
            case 'SAG' %2
                matrixX = zeros(3,1);
                matrixY = zeros(3,1);
                matrixZ = zeros(3,1);
                matrixX(3) = -1;
                matrixY(1) = 1;
                matrixZ(2) = -1;
            case 'COR' %3
                matrixX = zeros(3,1);
                matrixY = zeros(3,1);
                matrixZ = zeros(3,1);
                matrixX(1) = 1;
                matrixY(3) = 1;
                matrixZ(2) = -1;
            otherwise
                matrixX = zeros(3,1);
                matrixY = zeros(3,1);
                matrixZ = zeros(3,1);
                matrixX(1) = 1;
                matrixY(2) = 1;
                matrixZ(3) = 1;
        end;
        sx = -sin(angulation(1)*pi/180);
        sy = -sin(angulation(2)*pi/180);
        sz = -sin(angulation(3)*pi/180);
        cx = cos(angulation(1)*pi/180);
        cy = cos(angulation(1)*pi/180);
        cz = cos(angulation(1)*pi/180);

        rotMatX = zeros(3,1);
        rotMatY = zeros(3,1);
        rotMatZ = zeros(3,1);

        rotMatX(1) = cy*cz;
        rotMatY(1) = -sz*cx + sx*sy*cz;
        rotMatZ(1) = sx*sz + sy*cx*cz;

        rotMatX(2) = sz*cy;
        rotMatY(2) = cx*cz+sx*sy*sz;
        rotMatZ(2) = -sx*cz+sy*sz*cx;

        rotMatX(3) = -sy;
        rotMatY(3) = sx*cy;
        rotMatZ(3) = cx*cy;

        direcMatRL = zeros(3,1);
        direcMatAP = zeros(3,1);
        direcMatFH = zeros(3,1);

        direcMatRL(1)=rotMatX(1) * matrixX(1) + rotMatX(2) * matrixY(1) + rotMatX(3) * matrixZ(1);
        direcMatRL(2)=rotMatX(1) * matrixX(2) + rotMatX(2) * matrixY(2) + rotMatX(3) * matrixZ(2);
        direcMatRL(3)=rotMatX(1) * matrixX(3) + rotMatX(2) * matrixY(3) + rotMatX(3) * matrixZ(3);

        direcMatAP(1)=rotMatY(1) * matrixX(1) + rotMatY(2) * matrixY(1) + rotMatY(3) * matrixZ(1);
        direcMatAP(2)=rotMatY(1) * matrixX(2) + rotMatY(2) * matrixY(2) + rotMatY(3) * matrixZ(2);
        direcMatAP(3)=rotMatY(1) * matrixX(3) + rotMatY(2) * matrixY(3) + rotMatY(3) * matrixZ(3);

        direcMatFH(1)=rotMatZ(1) * matrixX(1) + rotMatZ(2) * matrixY(1) + rotMatZ(3) * matrixZ(1);
        direcMatFH(2)=rotMatZ(1) * matrixX(2) + rotMatZ(2) * matrixY(2) + rotMatZ(3) * matrixZ(2);
        direcMatFH(3)=rotMatZ(1) * matrixX(3) + rotMatZ(2) * matrixY(3) + rotMatZ(3) * matrixZ(3);

    end

end
