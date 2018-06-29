classdef MRparameter < handle
    
    
    
    properties ( SetAccess = protected )
        Parameter2Read;
        Chunk;
        Scan;
        Encoding;
        Recon;
        Gridder;
        Cardiac;
        DataFormat;
        ReconFlags;
        EPICorrData;
        Spectro;
    end
    
    properties
        Filename;
        Labels;
        ImageInformation;
        Bruker;
        LabelLookupTable;
    end
    
    properties ( Hidden )
        Parameter2ReadRanges;
        Parameter2Read_Original;
        OriginalLabelLength;
        DataType
        Data;
        DataClass;
        UpdateImageInfo = 0;
        Par40;
    end
    
    properties ( Hidden, SetAccess = private )
        MachineID;
        LicenseFile;
        LicenseInfo;
    end
    
    
    
    properties ( Hidden, SetAccess = private )
        corrected_spectro_dim = false;
    end
    
    
    
    methods
        function PAR = MRparameter( ParameterFilename, Datafile )
            
            
            PAR.Parameter2Read = Parameter2ReadParsUsr;
            PAR.ReconFlags = ReconFlagParsUsr;
            PAR.Encoding = EncodingParsUsr;
            PAR.Cardiac = CardiacParsUsr;
            PAR.Gridder = GridderParsUsr;
            PAR.Recon = ReconParsUsr;
            PAR.Chunk = ChunkParsUsr;
            PAR.Scan = ScanParsUsr;
            PAR.ImageInformation = InfoPars( 1 );
            PAR.EPICorrData = EPICorrDataPars;
            PAR.Spectro = SpectroParsUsr;
            PAR.DataClass = MRdata;
            PAR.ReadParameterFile( ParameterFilename, Datafile );
            
            addlistener( PAR.Cardiac, 'RetroPhases', 'PostSet', @PAR.RetroSetPhase );
            addlistener( PAR.Cardiac, 'PhaseWindow', 'PostSet', @PAR.RetroSetPhaseWindow );
            addlistener( PAR.Cardiac, 'Synchronization', 'PostSet', @PAR.RetroSetSync );
            addlistener( PAR.Cardiac, 'RetroBinning', 'PostSet', @PAR.RetroSetPhase );
            addlistener( PAR.Cardiac, 'RetroEndSystoleMs', 'PostSet', @PAR.RetroSetPhase );
            addlistener( PAR.Cardiac, 'RetroHoleInterpolation', 'PostSet', @PAR.RetroSetPhase );
            addlistener( PAR.Cardiac, 'RetroHoleInterpolation', 'PostSet', @PAR.RetroSetPhaseWindow );
            addlistener( PAR.Encoding, 'KyRange', 'PostSet', @PAR.SetKyKzLabels );
            addlistener( PAR.Encoding, 'KzRange', 'PostSet', @PAR.SetKyKzLabels );
            addlistener( PAR.Encoding, 'Mix', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'Echo', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'KxRange', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'KyRange', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'KzRange', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'XRange', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'YRange', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'ZRange', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'XRes', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'YRes', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'ZRes', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'XReconRes', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'YReconRes', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'ZReconRes', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'KxOversampling', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'KyOversampling', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'KzOversampling', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'FFTShift', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Encoding, 'FFTDims', 'PostSet', @PAR.UpdateWorkEncoding );
            addlistener( PAR.Scan, 'AcqMode', 'PostSet', @PAR.SetKyKzLabels );
            addlistener( PAR.Scan, 'AcqMode', 'PostSet', @PAR.SetGridderPreset );
            addlistener( PAR.Scan, 'PatientPosition', 'PostSet', @PAR.UpdateCoordinateSystem );
            addlistener( PAR.Scan, 'PatientOrientation', 'PostSet', @PAR.UpdateCoordinateSystem );
            addlistener( PAR.Scan, 'Orientation', 'PostSet', @PAR.UpdateCoordinateSystem );
            addlistener( PAR.Scan, 'FoldOverDir', 'PostSet', @PAR.UpdateCoordinateSystem );
            addlistener( PAR.Scan, 'FatShiftDir', 'PostSet', @PAR.UpdateCoordinateSystem );
            addlistener( PAR.Scan, 'Multivenc', 'PostSet', @PAR.UpdateMultivenc );
            addlistener( PAR.Scan, 'kv', 'PostSet', @PAR.Updatekv );
            addlistener( PAR.Scan, 'ScanType', 'PostSet', @PAR.InitSpectro );
            addlistener( PAR.Chunk, 'Def', 'PostSet', @PAR.DefineChunk );
            addlistener( PAR.Chunk, 'CurLoop', 'PostSet', @PAR.DefineChunk );
            addlistener( PAR.Chunk, 'NewChunk', @PAR.NewChunk );
            addlistener( PAR.Chunk, 'ResetChunk', @PAR.ResetChunk );
            addlistener( PAR.Parameter2Read, 'UpdateEncodingPars', @PAR.InitWorkEncoding );
            addlistener( PAR.Parameter2Read, 'UpdateParameter2ReadPars', @PAR.UpdateParameter2Read );
            addlistener( PAR.Parameter2Read, 'UpdateFlowPars', @PAR.UpdateFlow );
            addlistener( PAR.Recon, 'ArrayCompression', 'PostSet', @PAR.SetArrayCompression );
            addlistener( PAR.Recon, 'ACNrVirtualChannels', 'PostSet', @PAR.SetACNrVirtualChannels );
            addlistener( PAR.Recon, 'ACMatrix', 'PostSet', @PAR.SetACMatrix );
            addlistener( PAR.Recon, 'Sensitivities', 'PostSet', @PAR.UpdateACMatrix );
            addlistener( PAR.Recon, 'ExportRECImgTypes', 'PostSet', @PAR.UpdateInfoPars );
            addlistener( PAR.Recon, 'AutoUpdateInfoPars', 'PostSet', @PAR.UpdateInfoPars );
            addlistener( PAR.Recon, 'EPICorrectionMethod', 'PostSet', @PAR.DeleteEPICorrData );
            addlistener( PAR.Recon, 'EPI2DCorr', 'PostSet', @PAR.DeleteEPICorrData );
            addlistener( PAR.Recon, 'ImmediateAveraging', 'PostSet', @PAR.RetroRefillHoles );
            addlistener( PAR.Recon, 'TKE', 'PostSet', @PAR.UpdateTKE );
            addlistener( PAR.ReconFlags, 'isoversampled', 'PostSet', @PAR.UpdateOversampling );
            addlistener( PAR.ReconFlags, 'isunfolded', 'PostSet', @PAR.UpdateSENSE );
            addlistener( PAR.ReconFlags, 'isaveraged', 'PostSet', @PAR.UpdateFidInfos );
            
            PAR.SetTyp;
            PAR.InitEncoding;
            PAR.InitScanPars;
            PAR.InitReconPars;
            PAR.InitCardiac;
            PAR.InitGridder;
            PAR.Chunk.Reset;
            PAR.ReconFlags.Init( PAR.DataFormat );
            PAR.SetKyKzLabels( PAR );
            PAR.Parameter2Read.SetRanges;
            PAR.Parameter2Read.EnableRangeCheck = 1;
            PAR.Parameter2Read_Original = PAR.Parameter2Read.Copy;
            PAR.InitSpectro;
            
        end
        
        function Reset( PAR )
            
            
            PAR.Chunk.Def = 'ALL';
            PAR.Parameter2Read.Assign( PAR.Parameter2Read_Original );
            PAR.Parameter2Read.EnableRangeCheck = 0;
            PAR.SetKyKzLabels( PAR );
            PAR.Parameter2Read.EnableRangeCheck = 1;
            PAR.Gridder.InitWorkingPars;
        end
        
        
        
        
        
        function Value = GetValue( PAR, Name, ArrayIndices, Numeric )
            switch nargin
                case 1
                    error( 'Please specify the name of the parameter as input' );
                case 2
                    ArrayIndices = [  ];
                    Numeric = [  ];
                case 3
                    Numeric = [  ];
            end
            
            Value = PAR.Par40.GetValue( Name, ArrayIndices, Numeric );
        end
        
        function Search( PAR, SearchText, Filter )
            if nargin == 1
                error( 'Please specify a search text as input' );
            end
            if nargin == 2
                Filter = '';
            end
            if isempty( PAR.Par40 )
                return ;
            end
            PAR.Par40.Search( SearchText, Filter );
        end
        
        function CompareParameter( PAR, other )
            if nargin == 1
                error( 'Please give another MRecon object as input' );
            end
            PAR.Par40.CompareParameter( other.Par40 );
        end
        
        
        function IsObj = IsObject( PAR, ObjectName )
            if nargin == 1
                error( 'Please specify an object name as input' );
            end
            IsObj = PAR.Par40.IsObject( ObjectName );
        end
        
        function ObjectNames = GetObjectNames( PAR, ObjectClass )
            if nargin == 1
                error( 'Please specify an object class as input' );
            end
            ObjectNames = PAR.Par40.GetObjectNames( ObjectClass );
        end
        
        function Object = GetObject( PAR, ObjectName )
            if nargin == 1
                error( 'Please specify an object name as input' );
            end
            Object = PAR.Par40.GetObject( ObjectName );
        end
        
        function DisplayObjectNames( PAR, ObjectClass )
            if nargin == 1
                error( 'Please specify an object class as input' );
            end
            PAR.Par40.DisplayObjectNames( ObjectClass );
        end
        
        function DisplayObject( PAR, ObjectName )
            if nargin == 1
                error( 'Please specify an object name as input' );
            end
            PAR.Par40.DisplayObject( ObjectName );
        end
        
        
        function IsPar = IsParameter( PAR, ParameterName )
            if nargin == 1
                error( 'Please specify a parameter name as input' );
            end
            IsPar = PAR.Par40.IsParameter( ParameterName );
        end
        
        function Par = GetParameter( PAR, ParameterName )
            if nargin == 1
                error( 'Please specify a parameter name as input' );
            end
            Par = PAR.Par40.GetParameter( ParameterName );
        end
        
        function Pars = GetParameterInGroup( PAR, GroupName )
            if nargin == 1
                error( 'Please specify a group name as input' );
            end
            Pars = PAR.Par40.GetParameterInGroup( GroupName );
        end
        
        function DisplayParameterInGroup( PAR, GroupName )
            if nargin == 1
                error( 'Please specify a group name as input' );
            end
            PAR.Par40.DisplayParameterInGroup( GroupName );
        end
        
        function Grp = GetGroupOfParameter( PAR, ParameterName )
            if nargin == 1
                error( 'Please specify a parameter name as input' );
            end
            Grp = PAR.Par40.GetGroupOfParameter( ParameterName );
        end
        
        function DisplayGroupOfParameter( PAR, ParameterName )
            if nargin == 1
                error( 'Please specify a parameter name as input' );
            end
            PAR.Par40.DisplayGroupOfParameter( ParameterName );
        end
        
        
        function Grp = GetGroup( PAR, GroupName_or_ID )
            if nargin == 1
                error( 'Please specify a group name or group id as input' );
            end
            Grp = PAR.Par40.GetGroup( GroupName_or_ID );
        end
        
        function DisplayAllGroups( PAR )
            PAR.Par40.DisplayAllGroups(  );
        end
        
        
        function ExtractPDFFile( PAR, filename )
            if nargin == 1
                filename = strrep( PAR.Filename.Data, '.raw', '.gve' );
            end
            PAR.Par40.ExtractPDFFile( filename );
        end
        
        
        function ExtractAttachedFiles( PAR )
            if nargin == 1
                filename = strrep( PAR.Filename.Data, '.raw', '.gve' );
            end
            PAR.Par40.ExtractAttachedFiles(  );
        end
        
        
        function Export2Json( PAR, filename )
            if nargin == 1
                filename = strrep( PAR.Filename.Data, '.raw', '.json' );
            end
            PAR.Par40.Export2Json( filename );
        end
        
        
        
        
        function obj = set.Data( obj, val )
            
            obj.DataClass.Matrix = val;
        end
        
        function value = get.Data( obj )
            
            value = obj.DataClass.Matrix;
        end
        
        function obj = set.ImageInformation( obj, val )
            
            if ~isempty( obj.ImageInformation ) && ~isempty( val )
                send_error = 0;
                if iscell( val )
                    nr_loops = length( val );
                else
                    nr_loops = 1;
                end
                for i = 1:nr_loops
                    if iscell( val )
                        cur_val = val{ i };
                    else
                        cur_val = val;
                    end
                    if ~isempty( cur_val )
                        if ~isobject( cur_val )
                            send_error = 1;
                        else
                            mc = metaclass( cur_val );
                            if ~strcmpi( mc.Name, 'InfoPars' )
                                send_error = 1;
                            end
                        end
                    end
                end
                if send_error
                    error( 'The ImageInformation has to be a InfoPars object' );
                end
            end
            obj.ImageInformation = val;
        end
        
        
        
        
        function new = Copy( this )
            
            mc = eval( [ '?', class( this ) ] );
            new = feval( class( this ), 'Empty' );
            
            
            p = mc.Properties;
            
            for i = 1:length( p )
                try
                    
                    new.( p{ i }.Name ) = this.( p{ i }.Name ).Copy;
                catch
                    try
                        
                        new.( p{ i }.Name ) = this.( p{ i }.Name );
                    end
                end
            end
        end
    end
    methods ( Hidden )
        
        
        
        function ReadParameterFile( PAR, file, datafile )
            slash_ind = strfind( file, filesep ) + 1;
            if isempty( slash_ind )
                slash_ind = strfind( file, '/' ) + 1;
            end
            if isempty( slash_ind )
                slash_ind = 1;
            else
                slash_ind = slash_ind( end  );
            end
            dotind = findstr( file, '.' );
            if ~isempty( dotind )
                dotind = dotind( end  );
            end
            if ~isempty( dotind ) && dotind > slash_ind
                ending = lower( file( dotind( end  ) + 1:end  ) );
            else
                if strcmpi( file( slash_ind:end  ), 'fid' )
                    ending = 'bruker';
                    dotind = [  ];
                else
                    ending = 'raw';
                    dotind = [  ];
                end
            end
            
            
            
            if strcmpi( ending, 'blk' )
                if ( isempty( file ) || isempty( datafile ) )
                    error( 'Please give both the raw and lab file as input' );
                end
                ending = 'raw';
            end
            
            
            if fopen( file ) < 0
                error( [ 'The input file: ', file, ' cannot be found' ] );
            else
                fclose( 'all' );
            end
            switch ending
                case { 'rec', 'par', 'xml' }
                    directory = '';
                    if isempty( datafile )
                        if ~isempty( regexpi( file, '\.par' ) )
                            parfile = file;
                        elseif ~isempty( regexpi( file, '\.xml' ) )
                            parfile = file;
                        else
                            slash_ind = strfind( file, filesep ) + 1;
                            if isempty( slash_ind )
                                slash_ind = strfind( file, '/' ) + 1;
                            end
                            if isempty( slash_ind )
                                slash_ind = 1;
                                directory = '';
                                files = dir;
                            else
                                directory = file( 1:slash_ind( end  ) - 1 );
                                files = dir( directory );
                            end
                            recfile = [ file( slash_ind( end  ):dotind ) ];
                            for i = 1:size( files, 1 )
                                di = findstr( files( i ).name, '.' );
                                if ~isempty( di )
                                    di = di( end  );
                                    cur_ending = lower( files( i ).name( di( end  ) + 1:end  ) );
                                else
                                    cur_ending = '';
                                end
                                if ~isempty( strfind( files( i ).name, recfile ) ) &&  ...
                                        ~strcmpi( files( i ).name, file( slash_ind( end  ):end  ) ) &&  ...
                                        any( strcmpi( cur_ending, { 'par', 'xml' } ) )
                                    parfile = files( i ).name;
                                    ending = cur_ending;
                                end
                            end
                        end
                    else
                        parfile = file;
                    end
                    
                    
                    if fopen( [ directory, parfile ] ) < 0
                        error( [ 'The parameter file: ', file, ' cannot be found' ] );
                    else
                        fclose( 'all' );
                    end
                    
                    
                    if strcmpi( ending, 'par' )
                        PAR.Labels = MRparameter.parread( [ directory, parfile ] );
                    else
                        PAR.Labels = PAR.xmlprideread( [ directory, parfile ] );
                    end
                    PAR.DataFormat = 'Rec';
                    if isempty( datafile )
                        PAR.Filename.Data = [ file( 1:dotind ), 'rec' ];
                    else
                        PAR.Filename.Data = datafile;
                    end
                    
                    if fopen( PAR.Filename.Data ) < 0
                        error( [ 'The data file: ', PAR.Filename.Data, ' cannot be found' ] );
                    else
                        fclose( 'all' );
                    end
                    PAR.Filename.Parameter = parfile;
                    
                    
                    try
                        PAR.Labels.DiffusionBValues = unique( PAR.Labels.ImageInformation.DiffusionBFactor );
                        PAR.Parameter2Read.kz = unique( PAR.Labels.ImageInformation.SliceNumber );
                        PAR.Parameter2Read.echo = unique( PAR.Labels.ImageInformation.EchoNumber );
                        PAR.Parameter2Read.dyn = unique( PAR.Labels.ImageInformation.DynamicScanNumber );
                        PAR.Parameter2Read.card = unique( PAR.Labels.ImageInformation.CardiacPhaseNumber );
                        PAR.Parameter2Read.typ = unique( PAR.Labels.ImageInformation.ImageTypeMr );
                        PAR.Parameter2Read.mix = unique( PAR.Labels.ImageInformation.ScanningSequence );
                        PAR.Parameter2Read.aver = [  ];
                        PAR.Parameter2Read.rtop = [  ];
                        PAR.Parameter2Read.ky = [  ];
                        PAR.Parameter2Read.loca = [  ];
                        PAR.Parameter2Read.chan = [  ];
                        PAR.Parameter2Read.extr1 = [  ];
                        PAR.Parameter2Read.extr2 = [  ];
                    catch
                        PAR.Labels.ImageInformation.Type( strtrim( PAR.Labels.ImageInformation.Type( :, 1 ) ) == 'M' ) = '0';
                        PAR.Labels.ImageInformation.Type( strtrim( PAR.Labels.ImageInformation.Type( :, 1 ) ) == 'R' ) = '1';
                        PAR.Labels.ImageInformation.Type( strtrim( PAR.Labels.ImageInformation.Type( :, 1 ) ) == 'I' ) = '2';
                        PAR.Labels.ImageInformation.Type( strtrim( PAR.Labels.ImageInformation.Type( :, 1 ) ) == 'P' ) = '3';
                        PAR.Labels.ImageInformation.Type( strtrim( PAR.Labels.ImageInformation.Type( :, 1 ) ) == 'D' ) = '0';
                        PAR.Labels.ImageInformation.Type = str2num( PAR.Labels.ImageInformation.Type( :, 1 ) );
                        
                        sequences_cell = num2cell( PAR.Labels.ImageInformation.Sequence, 2 );
                        sequences = unique( PAR.Labels.ImageInformation.Sequence, 'rows' );
                        for i = 1:size( sequences, 1 )
                            PAR.Labels.ImageInformation.Sequence( strcmpi( sequences_cell, sequences( i, : ) ) ) = num2str( i );
                        end
                        PAR.Labels.ImageInformation.Sequence = PAR.Labels.ImageInformation.Sequence( :, 1 );
                        PAR.Labels.ImageInformation.Sequence = str2num( PAR.Labels.ImageInformation.Sequence );
                        
                        PAR.Parameter2Read.kz = unique( PAR.Labels.ImageInformation.Slice );
                        PAR.Parameter2Read.echo = unique( PAR.Labels.ImageInformation.Echo );
                        PAR.Parameter2Read.dyn = unique( PAR.Labels.ImageInformation.Dynamic );
                        PAR.Parameter2Read.card = unique( PAR.Labels.ImageInformation.Phase );
                        PAR.Parameter2Read.typ = unique( PAR.Labels.ImageInformation.Type );
                        PAR.Parameter2Read.mix = unique( PAR.Labels.ImageInformation.Sequence );
                        PAR.Parameter2Read.aver = [  ];
                        PAR.Parameter2Read.rtop = [  ];
                        PAR.Parameter2Read.ky = [  ];
                        PAR.Parameter2Read.loca = [  ];
                        PAR.Parameter2Read.chan = [  ];
                        PAR.Parameter2Read.extr1 = [  ];
                        PAR.Parameter2Read.extr2 = [  ];
                    end
                    
                    PAR.ReconFlags.isreadparameter = 1;
                case 'cpx'
                    PAR.Labels = PAR.read_cpx_header( file, 'no' );
                    PAR.DataFormat = 'Cpx';
                    PAR.Filename.Data = file;
                    PAR.Filename.Parameter = file;
                    
                    
                    if fopen( file ) < 0
                        error( [ 'The parameter file: ', file, ' cannot be found' ] );
                    else
                        fclose( 'all' );
                    end
                    
                    PAR.Parameter2Read.loca = unique( PAR.Labels( :, 1 ) ) + 1;
                    PAR.Parameter2Read.kz = unique( PAR.Labels( :, 2 ) ) + 1;
                    PAR.Parameter2Read.chan = unique( PAR.Labels( :, 3 ) ) + 1;
                    PAR.Parameter2Read.card = unique( PAR.Labels( :, 4 ) ) + 1;
                    PAR.Parameter2Read.echo = unique( PAR.Labels( :, 5 ) ) + 1;
                    PAR.Parameter2Read.dyn = unique( PAR.Labels( :, 6 ) ) + 1;
                    PAR.Parameter2Read.extr1 = unique( PAR.Labels( :, 7 ) ) + 1;
                    PAR.Parameter2Read.extr2 = unique( PAR.Labels( :, 18 ) ) + 1;
                    PAR.Parameter2Read.aver = [  ];
                    PAR.Parameter2Read.rtop = [  ];
                    PAR.Parameter2Read.typ = [  ];
                    PAR.Parameter2Read.mix = [  ];
                    PAR.Parameter2Read.ky = [  ];
                    
                    PAR.ReconFlags.isreadparameter = 1;
                case { 'data', 'list' }
                    t = 'TEHROA';
                    PAR.DataType.SampleSizeBytes = 4;
                    PAR.DataType.DataType{ 1 } = 'single';
                    if isempty( datafile )
                        listfile = [ file( 1:dotind ), 'list' ];
                    else
                        listfile = file;
                    end
                    
                    
                    if fopen( listfile ) < 0
                        error( [ 'The parameter file: ', listfile, ' cannot be found' ] );
                    else
                        fclose( 'all' );
                    end
                    
                    PAR.Labels = PAR.listread( listfile, PAR );
                    
                    PAR.Labels.Index.coded_size = PAR.Labels.Index.size;
                    
                    PAR.Labels.Index.format = uint8( PAR.Labels.Index.size .* 0 + 3 );
                    
                    PAR.Labels.Spectro = false;
                    
                    PAR.DataType.DataTypeNum = uint8( 3 );
                    PAR.DataType.SampleSizeBytes = 4;
                    PAR.DataType.DataType{ 1 } = 'single';
                    
                    
                    if isfield( PAR.Labels.Index, 'y' )
                        PAR.DataFormat = 'ExportedCpx';
                    elseif isfield( PAR.Labels.Index, 'ky' )
                        PAR.DataFormat = 'ExportedRaw';
                    else
                        error( 'Error in ReadParameterFile: Unknown data format' );
                    end
                    
                    if isempty( datafile )
                        PAR.Filename.Data = [ file( 1:dotind ), 'data' ];
                    else
                        PAR.Filename.Data = datafile;
                    end
                    
                    if fopen( PAR.Filename.Data ) < 0
                        error( [ 'The data file: ', PAR.Filename.Data, ' cannot be found' ] );
                    else
                        fclose( 'all' );
                    end
                    PAR.Filename.Parameter = listfile;
                    
                    typ = unique( PAR.Labels.Index.typ( :, 2 ) );
                    for i = 1:length( typ )
                        numtyp( i ) = findstr( typ( i ), t );
                    end
                    PAR.Parameter2Read.typ = sort( numtyp );
                    PAR.Parameter2Read.mix = unique( PAR.Labels.Index.mix );
                    PAR.Parameter2Read.dyn = unique( PAR.Labels.Index.dyn );
                    PAR.Parameter2Read.card = unique( PAR.Labels.Index.card );
                    PAR.Parameter2Read.echo = unique( PAR.Labels.Index.echo );
                    PAR.Parameter2Read.loca = unique( PAR.Labels.Index.loca );
                    PAR.Parameter2Read.chan = unique( PAR.Labels.Index.chan );
                    PAR.Parameter2Read.extr1 = unique( PAR.Labels.Index.extr1 );
                    PAR.Parameter2Read.extr2 = unique( PAR.Labels.Index.extr2 );
                    PAR.Parameter2Read.ky = unique( PAR.Labels.Index.ky );
                    PAR.Parameter2Read.kz = unique( PAR.Labels.Index.kz );
                    if isfield( PAR.Labels.Index, 'aver' )
                        PAR.Parameter2Read.aver = unique( PAR.Labels.Index.aver );
                        PAR.Parameter2Read.rtop = unique( PAR.Labels.Index.rtop );
                    end
                    
                    PAR.ReconFlags.isreadparameter = 1;
                case { 'raw', 'lab' }
                    t = 'TEHROA';
                    PAR.DataFormat = 'Raw';
                    
                    
                    
                    if ( ~isempty( file ) && ~isempty( datafile ) )
                        if ( MRparameter.find_labfile( file, datafile ) ~= 1 )
                            error( 'Please give the labfile as first and the rawfile as second input' );
                        end
                    end
                    
                    if isempty( dotind )
                        if isempty( datafile )
                            slash_ind = strfind( file, filesep ) + 1;
                            if isempty( slash_ind )
                                slash_ind = strfind( file, '/' ) + 1;
                            end
                            if isempty( slash_ind )
                                slash_ind = 1;
                                directory = '';
                                files = dir;
                            else
                                directory = file( 1:slash_ind( end  ) - 1 );
                                files = dir( directory );
                            end
                            one_file = file( slash_ind( end  ):end  );
                            
                            ind_one_file =  - 1;
                            ind_other_file =  - 1;
                            try
                                date_one_file = datenum( str2double( one_file( 4:7 ) ), str2double( one_file( 8:9 ) ), str2double( one_file( 10:11 ) ), str2double( one_file( 12:13 ) ), str2double( one_file( 14:15 ) ), str2double( [ one_file( 16:17 ), '.', one_file( 18:19 ) ] ) );
                                isdate = 1;
                            catch
                                isdate = 0;
                            end
                            for i = 1:size( files, 1 )
                                if strcmp( files( i ).name, one_file )
                                    ind_one_file = i;
                                end
                                if isdate
                                    try
                                        if strfind( files( i ).name, one_file( 1:11 ) ) &  ...
                                                isempty( strfind( files( i ).name, '.' ) ) &  ...
                                                i ~= ind_one_file
                                            
                                            date_this_file = datenum( str2double( files( i ).name( 4:7 ) ), str2double( files( i ).name( 8:9 ) ), str2double( files( i ).name( 10:11 ) ), str2double( files( i ).name( 12:13 ) ), str2double( files( i ).name( 14:15 ) ), str2double( [ files( i ).name( 16:17 ), '.', files( i ).name( 18:19 ) ] ) );
                                            if abs( date_this_file - date_one_file ) < 1e-5
                                                ind_other_file = i;
                                            end
                                        end
                                    catch
                                        if strfind( files( i ).name, one_file( 1:17 ) ) &  ...
                                                isempty( strfind( files( i ).name, '.' ) ) &  ...
                                                i ~= ind_one_file
                                            ind_other_file = i;
                                        end
                                    end
                                else
                                    if strfind( files( i ).name, one_file( 1:17 ) ) &  ...
                                            isempty( strfind( files( i ).name, '.' ) ) &  ...
                                            i ~= ind_one_file
                                        ind_other_file = i;
                                    end
                                end
                            end
                            if ind_one_file > 0 & ind_other_file > 0
                                
                                
                                
                                
                                fid = fopen( [ directory, files( ind_one_file ).name ], 'r' );
                                fread( fid, 2, 'uint8' );
                                header1 = fread( fid, 510, 'uint8' );
                                header1 = sum( abs( header1 ) );
                                fclose( fid );
                                
                                fid = fopen( [ directory, files( ind_other_file ).name ], 'r' );
                                fread( fid, 2, 'uint8' );
                                header2 = fread( fid, 510, 'uint8' );
                                header2 = sum( abs( header2 ) );
                                fclose( fid );
                                
                                if header1 > header2
                                    PAR.Filename.Parameter = [ directory, files( ind_one_file ).name ];
                                    PAR.Filename.Data = [ directory, files( ind_other_file ).name ];
                                else
                                    PAR.Filename.Data = [ directory, files( ind_one_file ).name ];
                                    PAR.Filename.Parameter = [ directory, files( ind_other_file ).name ];
                                end
                            else
                                error( 'data/parameter-file pair not found' );
                            end
                        else
                            PAR.Filename.Data = datafile;
                            PAR.Filename.Parameter = file;
                        end
                        dotind = length( PAR.Filename.Parameter ) + 1;
                        dotind = dotind( end  );
                    else
                        if isempty( datafile )
                            PAR.Filename.Data = [ file( 1:dotind ), 'raw' ];
                            PAR.Filename.Parameter = [ file( 1:dotind ), 'lab' ];
                        else
                            PAR.Filename.Data = datafile;
                            PAR.Filename.Parameter = file;
                        end
                    end
                    
                    
                    if fopen( PAR.Filename.Parameter ) < 0
                        error( [ 'The parameter file: ', PAR.Filename.Parameter, ' cannot be found' ] );
                    else
                        fclose( 'all' );
                    end
                    
                    if fopen( PAR.Filename.Data ) < 0
                        error( [ 'The data file: ', PAR.Filename.Data, ' cannot be found' ] );
                    else
                        fclose( 'all' );
                    end
                    
                    v = labread( PAR.Filename.Parameter );
                    release = [  ];
                    if length( unique( v.channels_active( v.control == 0 ) ) ) > 100
                        disp( 'Release 11' );
                        release = 11;
                        v = labread( PAR.Filename.Parameter, 11 );
                    end
                    
                    v.chan_grp = v.channels_active;
                    
                    
                    if ParameterReader.is_patch( PAR.Filename.Data )
                        PAR.Par40 = ParameterReader( PAR.Filename.Data );
                        [ PAR.Labels, v ] = PAR.parse_recframe_40_parameter( PAR.Par40, v );
                        if ( PAR.Labels.Rel4 )
                            PAR.Labels.CoilNrs = PAR.get_channel_ids( PAR.Par40 );
                        end
                    else
                        [ PAR.Labels, v ] = PAR.get_scan_parameter( PAR.Filename.Data, v );
                        PAR.Labels.Release = release;
                        if isfield( PAR.Labels, 'SampleSets' )
                            v.progress_cnt = v.progress_cnt ./ PAR.Labels.SampleSets;
                        end
                        
                        if ~isfield( PAR.Labels, 'CoilNrs' )
                            PAR.Labels.CoilNrs = [  ];
                        end
                    end
                    
                    PAR.Labels.Index = PAR.lab2list( v, PAR.Labels.CoilNrs );
                    PAR.Labels.OriginalLabelLength = length( PAR.Labels.Index.typ );
                    
                    
                    
                    
                    if isfield( PAR.Labels, 'ScanMode' )
                        if PAR.Labels.Spectro
                            if any( PAR.Labels.Index.dyn ~= 0 )
                                error( 'Problem with switching spectro dynamics dimension, skipping ...' );
                            else
                                PAR.Labels.Index.dyn = PAR.Labels.Index.extr1;
                                
                                
                                PAR.Labels.Index.extr1 = PAR.Labels.Index.na;
                                PAR.corrected_spectro_dim = true;
                            end
                        end
                    end
                    
                    
                    
                    if isfield( PAR.Labels, 'PDAFactors' ) && ~isempty( PAR.Labels.PDAFactors )
                        nr_gain_values = 12;
                        try
                            PAR.Labels.Index.pda_fac( : ) = PAR.Labels.PDAFactors( PAR.Labels.Index.pda_index + PAR.Labels.Index.chan .* nr_gain_values + 1 );
                        catch
                            PAR.Labels.Index.pda_fac( : ) = PAR.Labels.PDAFactors( PAR.Labels.Index.pda_index + 1 );
                        end
                    end
                    
                    PAR.Parameter2Read.typ = unique( PAR.Labels.Index.typ );
                    PAR.Parameter2Read.mix = double( unique( PAR.Labels.Index.mix ) );
                    PAR.Parameter2Read.dyn = double( unique( PAR.Labels.Index.dyn ) );
                    PAR.Parameter2Read.card = double( unique( PAR.Labels.Index.card ) );
                    PAR.Parameter2Read.echo = double( unique( PAR.Labels.Index.echo ) );
                    PAR.Parameter2Read.loca = double( unique( PAR.Labels.Index.loca ) );
                    PAR.Parameter2Read.chan = double( unique( PAR.Labels.Index.chan ) );
                    PAR.Parameter2Read.extr1 = double( unique( PAR.Labels.Index.extr1 ) );
                    PAR.Parameter2Read.extr2 = double( unique( PAR.Labels.Index.extr2 ) );
                    PAR.Parameter2Read.ky = double( unique( PAR.Labels.Index.ky ) );
                    PAR.Parameter2Read.kz = double( unique( PAR.Labels.Index.kz ) );
                    PAR.Parameter2Read.aver = double( unique( PAR.Labels.Index.aver ) );
                    PAR.Parameter2Read.rtop = double( unique( PAR.Labels.Index.rtop ) );
                    
                    formats = unique( PAR.Labels.Index.format );
                    for i = 1:length( formats )
                        PAR.DataType.DataTypeNum( i ) = formats( i );
                        switch formats( i )
                            case 0
                                PAR.DataType.SampleSizeBytes( i ) = 2;
                                PAR.DataType.DataType{ i } = 'int16';
                            case 1
                                PAR.DataType.SampleSizeBytes( i ) = 2;
                                PAR.DataType.DataType{ i } = 'uint16';
                            case 2
                                PAR.DataType.SampleSizeBytes( i ) = 4;
                                PAR.DataType.DataType{ i } = 'int32';
                            case 3
                                PAR.DataType.SampleSizeBytes( i ) = 4;
                                PAR.DataType.DataType{ i } = 'single';
                            case 4
                                PAR.DataType.SampleSizeBytes( i ) = 2;
                                PAR.DataType.DataType{ i } = 'int16';
                            case 5
                                PAR.DataType.SampleSizeBytes( i ) = 8;
                                PAR.DataType.DataType{ i } = 'double';
                            case 6
                                PAR.DataType.SampleSizeBytes( i ) = 4;
                                PAR.DataType.DataType{ i } = 'uint8';
                        end
                    end
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    PAR.Labels.CoilNrsPerStack = [  ];
                    try
                        stacks = unique( PAR.Labels.StackIndex );
                        nr_stacks = length( stacks );
                        for i = 1:nr_stacks
                            loca_nr_per_stack = PAR.Parameter2Read.loca( find( PAR.Labels.StackIndex == stacks( i ) ) );
                            mask = ismember( PAR.Labels.Index.loca, loca_nr_per_stack ) & PAR.Labels.Index.typ == 1;
                            PAR.Labels.CoilNrsPerStack{ i } = unique( PAR.Labels.Index.chan( mask ) );
                        end
                    end
                    
                    
                    PAR.ReconFlags.isreadparameter = 1;
                case 'bruker'
                    slash_ind = strfind( file, filesep ) + 1;
                    if isempty( slash_ind )
                        slash_ind = strfind( file, '/' ) + 1;
                    end
                    if isempty( slash_ind )
                        slash_ind = 1;
                    end
                    
                    PAR.DataFormat = 'Bruker';
                    PAR.Filename.Data = file;
                    PAR.Filename.Parameter{ 1 } = [ file( 1:slash_ind( end  ) - 1 ), 'method' ];
                    PAR.Filename.Parameter{ 2 } = [ file( 1:slash_ind( end  ) - 1 ), 'acqp' ];
                    if slash_ind == 1
                        PAR.Filename.Parameter{ 3 } = '../subject';
                    else
                        PAR.Filename.Parameter{ 3 } = [ file( 1:slash_ind( end  - 1 ) - 1 ), 'subject' ];
                    end
                    
                    if fopen( PAR.Filename.Parameter{ 1 } ) ==  - 1
                        error( 'Error in ReadParameterFile: "method" file not found' );
                    end
                    if fopen( PAR.Filename.Parameter{ 2 } ) ==  - 1
                        error( 'Error in ReadParameterFile: "acqp" file not found' );
                    end
                    
                    B = BrukerPars;
                    if fopen( PAR.Filename.Parameter{ 3 } ) ~=  - 1
                        B.SubjectFile = PAR.Filename.Parameter{ 3 };
                    else
                        B.SubjectFile = [  ];
                    end
                    B.MethodFile = PAR.Filename.Parameter{ 1 };
                    B.AcqpFile = PAR.Filename.Parameter{ 2 };
                    B.CreateLabels;
                    
                    PAR.Labels = B.Labels;
                    PAR.Bruker = B.Parameters;
                    
                    switch PAR.Bruker.WordType
                        case 'GO_32BIT_FLOAT'
                            PAR.DataType.SampleSizeBytes = 4;
                            PAR.DataType.DataType{ 1 } = 'single';
                            PAR.Labels.Index.format( : ) = 3;
                            PAR.DataType.DataTypeNum( 1 ) = 3;
                        case 'GO_16BIT_SGN_INT'
                            PAR.DataType.SampleSizeBytes = 2;
                            PAR.DataType.DataType{ 1 } = 'int16';
                            PAR.Labels.Index.format( : ) = 0;
                            PAR.DataType.DataTypeNum( 1 ) = 0;
                        case 'GO_32BIT_SGN_INT'
                            PAR.DataType.SampleSizeBytes = 4;
                            PAR.DataType.DataType{ 1 } = 'int32';
                            PAR.Labels.Index.format( : ) = 2;
                            PAR.DataType.DataTypeNum( 1 ) = 2;
                        otherwise
                            PAR.DataType.SampleSizeBytes = 4;
                            PAR.DataType.DataType{ 1 } = 'single';
                            PAR.Labels.Index.format( : ) = 3;
                            PAR.DataType.DataTypeNum( 1 ) = 3;
                    end
                    
                    PAR.Parameter2Read.typ = unique( PAR.Labels.Index.typ );
                    PAR.Parameter2Read.mix = double( unique( PAR.Labels.Index.mix ) );
                    PAR.Parameter2Read.dyn = double( unique( PAR.Labels.Index.dyn ) );
                    PAR.Parameter2Read.card = double( unique( PAR.Labels.Index.card ) );
                    PAR.Parameter2Read.echo = double( unique( PAR.Labels.Index.echo ) );
                    PAR.Parameter2Read.loca = double( unique( PAR.Labels.Index.loca ) );
                    PAR.Parameter2Read.chan = double( unique( PAR.Labels.Index.chan ) );
                    PAR.Parameter2Read.extr1 = double( unique( PAR.Labels.Index.extr1 ) );
                    PAR.Parameter2Read.extr2 = double( unique( PAR.Labels.Index.extr2 ) );
                    PAR.Parameter2Read.ky = double( unique( PAR.Labels.Index.ky ) );
                    PAR.Parameter2Read.kz = double( unique( PAR.Labels.Index.kz ) );
                    PAR.Parameter2Read.aver = double( unique( PAR.Labels.Index.aver ) );
                    PAR.Parameter2Read.rtop = double( unique( PAR.Labels.Index.rtop ) );
                    
                    PAR.ReconFlags.isreadparameter = 1;
                    
                    PAR.Labels.Spectro = false;
                    
                otherwise
                    error( 'Datatype not supported' );
            end
            fclose( 'all' );
        end
        
        
        
        
        function InitCardiac( PAR )
            
            
            if isfield( PAR.Labels, 'RNAV' )
                PAR.Cardiac.RNAV = PAR.Labels.RNAV;
            end
            
            if any( strcmp( PAR.DataFormat, { 'Raw', 'ExportedRaw' } ) )
                start_ind = find( PAR.Labels.Index.typ == 1, 1 );
            end
            
            if isfield( PAR.Labels, 'CardSync' )
                
                
                
                
                PAR.Cardiac.Synchronization = PAR.Labels.CardSync;
                
            end
            
            
            if isfield( PAR.Labels, 'HeartPhaseInterval' )
                PAR.Cardiac.HeartPhaseInterval = PAR.Labels.HeartPhaseInterval;
            end
            
            if isfield( PAR.Labels, 'RespComp' )
                PAR.Cardiac.RespComp = PAR.Labels.RespComp;
            end
            
            if isfield( PAR.Labels, 'RespSync' )
                PAR.Cardiac.RespSync = PAR.Labels.RespSync;
            end
            
            if isfield( PAR.Labels, 'Index' )
                if any( strcmpi( PAR.Cardiac.Synchronization, { 'retro', 'retrospective' } ) )
                    
                elseif ( isempty( PAR.Cardiac.Synchronization ) || strcmpi( PAR.Cardiac.Synchronization, 'None' ) ) &&  ...
                        any( strcmp( PAR.DataFormat, { 'Raw', 'ExportedRaw' } ) ) &&  ...
                        isfield( PAR.Labels.Index, 'rtop' ) &&  ...
                        ( ~isempty( find( PAR.Labels.Index.rtop( start_ind:end  ) ~= 0, 1 ) ) &&  ...
                        ~isempty( find( PAR.Labels.Index.rr( start_ind:end  ) ~= 0, 1 ) ) &&  ...
                        isempty( find( PAR.Labels.Index.card( start_ind:end  ) ~= 0, 1 ) ) )
                    
                    
                    PAR.Cardiac.Synchronization = 'Retro';
                elseif isempty( PAR.Cardiac.Synchronization )
                    PAR.Cardiac.Synchronization = 'None';
                end
            end
        end
        function RetroSetSync( PAR, a, b )
            if any( strcmpi( PAR.Cardiac.Synchronization, { 'retro', 'retrospective' } ) )
                if isempty( find( PAR.Labels.Index.rtop ~= 0, 1 ) ) || isempty( find( PAR.Labels.Index.rr ~= 0, 1 ) )
                    warning( 'MATLAB:MRecon', 'This does not seem to be a retrospective triggered scan' );
                end
                
                if PAR.Cardiac.RetroPhases == 1
                    RetroFindNrPhases( PAR );
                end
                
                
                
                if strcmpi( PAR.Cardiac.SynchronizationPreSet, 'PhaseWindow' )
                    RetroFindNrPhases( PAR );
                    PAR.Parameter2Read.rtop = unique( PAR.Labels.Index.rtop );
                end
                
                
                
            elseif any( strcmpi( PAR.Cardiac.SynchronizationPreSet, { 'retro', 'retrospective' } ) ) && any( strcmpi( PAR.Cardiac.Synchronization, { 'Trigger', 'Gate' } ) )
                if ~isempty( PAR.OriginalLabelLength )
                    PAR.Labels.Index = structfun( @( x )x( 1:PAR.OriginalLabelLength ), PAR.Labels.Index, 'UniformOutput', 0 );
                end
                PAR.Cardiac.RetroPhases = 1;
                test_prof = find( PAR.Labels.Index.typ == 1 & PAR.Labels.Index.rr ~= 0, 1 );
                ind = find( PAR.Labels.Index.typ( test_prof + 1:end  ) == 1 &  ...
                    PAR.Labels.Index.ky( test_prof + 1:end  ) == PAR.Labels.Index.ky( test_prof ) &  ...
                    PAR.Labels.Index.kz( test_prof + 1:end  ) == PAR.Labels.Index.kz( test_prof ) &  ...
                    PAR.Labels.Index.extr1( test_prof + 1:end  ) == PAR.Labels.Index.extr1( test_prof ) &  ...
                    PAR.Labels.Index.chan( test_prof + 1:end  ) == PAR.Labels.Index.chan( test_prof ), 1 );
                
                hp = 0;
                for cur_pos = test_prof:ind:length( PAR.Labels.Index.rtop )
                    if ( cur_pos + ind ) > length( PAR.Labels.Index.rtop )
                        PAR.Labels.Index.card( cur_pos:end  ) = hp;
                        break ;
                    else
                        PAR.Labels.Index.card( cur_pos:cur_pos + ind - 1 ) = hp;
                    end
                    if ~ismember( PAR.Labels.Index.ky( cur_pos + ind ),  ...
                            unique( PAR.Labels.Index.ky( cur_pos:cur_pos + ind - 1 ) ) ) ||  ...
                            ~ismember( PAR.Labels.Index.dyn( cur_pos + ind ),  ...
                            unique( PAR.Labels.Index.dyn( cur_pos:cur_pos + ind - 1 ) ) )
                        hp = 0;
                    else
                        hp = hp + 1;
                    end
                end
                PAR.Parameter2Read.card = unique( PAR.Labels.Index.card );
                
                
            elseif any( strcmpi( PAR.Cardiac.Synchronization, { 'retro', 'retrospective' } ) ) && strcmpi( PAR.Cardiac.Synchronization, { 'None' } )
                if ~isempty( PAR.OriginalLabelLength )
                    PAR.Labels.Index = structfun( @( x )x( 1:PAR.OriginalLabelLength ), PAR.Labels.Index, 'UniformOutput', 0 );
                end
                PAR.Labels.Index.card( : ) = 0;
                PAR.Cardiac.RetroPhases = 1;
                
                
            elseif strcmpi( PAR.Cardiac.Synchronization, { 'PhaseWindow' } )
                if all( unique( PAR.Labels.Index.rtop ) == 0 ) || all( unique( PAR.Labels.Index.rr ) == 0 )
                    error( 'The rtop and rr labels have to be set for a PhaseWindow reconstruction. This is not a retrospective triggered scan.' );
                end
                if ~isempty( PAR.Cardiac.PhaseWindow )
                    PAR.RetroSetPhaseWindow( PAR );
                end
            end
        end
        function RetroFindNrPhases( PAR )
            PAR.Cardiac.MeanRRInterval = mean( unique( double( PAR.Labels.Index.rr( PAR.Labels.Index.rr ~= 0 ) ) ) );
            test_prof = find( PAR.Labels.Index.typ == 1 & PAR.Labels.Index.rr ~= 0, 1 );
            ind = find( PAR.Labels.Index.typ( test_prof + 1:end  ) == 1 &  ...
                PAR.Labels.Index.ky( test_prof + 1:end  ) == PAR.Labels.Index.ky( test_prof ) &  ...
                PAR.Labels.Index.kz( test_prof + 1:end  ) == PAR.Labels.Index.kz( test_prof ) &  ...
                PAR.Labels.Index.extr1( test_prof + 1:end  ) == PAR.Labels.Index.extr1( test_prof ) &  ...
                PAR.Labels.Index.chan( test_prof + 1:end  ) == PAR.Labels.Index.chan( test_prof ), 1 );
            
            if ( isempty( ind ) )
                ind = test_prof + 1;
            end
            
            
            hp_length = double( diff( PAR.Labels.Index.rtop( [ test_prof, test_prof + ind ] ) ) );
            PAR.Cardiac.AcqPhases = ceil( PAR.Cardiac.MeanRRInterval / hp_length );
            
            if isfield( PAR.Labels, 'ZReconLength' )
                PAR.Cardiac.RetroPhases = PAR.Labels.ZReconLength / PAR.Labels.NumberOfMixes /  ...
                    length( PAR.Parameter2Read.echo ) / length( PAR.Parameter2Read.extr1 ) / length( PAR.Parameter2Read.aver );
            else
                PAR.Cardiac.RetroPhases = ceil( double( PAR.Cardiac.MeanRRInterval ) / hp_length );
            end
        end
        function RetroSetPhaseWindow( PAR, a, b )
            if strcmpi( PAR.Cardiac.Synchronization, 'PhaseWindow' ) &&  ...
                    ~isempty( PAR.Cardiac.PhaseWindow )
                
                rr_max = single( max( PAR.Labels.Index.rr ) );
                rr_min = 0;
                win_min = PAR.Cardiac.PhaseWindow( 1 );
                win_max = PAR.Cardiac.PhaseWindow( 2 );
                win_dur = win_max - win_min;
                hpl = win_min: - win_dur / 2:rr_min;
                if hpl( end  ) ~= rr_min
                    hpl( end  + 1 ) = rr_min;
                end
                hpr = win_max:win_dur / 2:rr_max;
                if isempty( hpr ) || hpr( end  ) ~= rr_max
                    hpr( end  + 1 ) = rr_max;
                end
                hps = [ hpl( end : - 1:1 ), hpr ];
                hp_target = find( hps == win_min ) - 1;
                for i = 1:length( hps ) - 1
                    mask = PAR.Labels.Index.rtop >= hps( i ) & PAR.Labels.Index.rtop < hps( i + 1 );
                    PAR.Labels.Index.card( mask ) = i - 1;
                end
                skip_phase = setxor( 0:length( hps ) - 2, hp_target );
                
                if ~isempty( PAR.OriginalLabelLength ) && length( PAR.Labels.Index.card ) ~= PAR.OriginalLabelLength
                    labels = structfun( @( x )x( 1:PAR.OriginalLabelLength ), labels, 'UniformOutput', 0 );
                end
                PAR.OriginalLabelLength = length( PAR.Labels.Index.card );
                
                PAR.Labels.Index = MRparameter.retro_fill_holes( PAR.Labels.Index, PAR.Cardiac.RetroHoleInterpolation, PAR.Cardiac.FillHolesPerCoil, PAR.Cardiac.FillHolesWrapAround, PAR.Recon.ImmediateAveraging, skip_phase );
                
                if isfield( PAR.Labels.Index, 'aver' )
                    PAR.Parameter2Read.rtop = unique( PAR.Labels.Index.rtop );
                end
                
                PAR.Parameter2Read.card_range = ( 0:length( hps ) - 2 )';
                PAR.Parameter2Read.card = hp_target;
                
                
            end
        end
        function RetroSetPhase( PAR, a, b )
            if any( strcmpi( PAR.Cardiac.Synchronization, { 'retro', 'retrospective' } ) ) &&  ...
                    ~isempty( PAR.Cardiac.RetroPhases )
                
                
                if ~isempty( PAR.OriginalLabelLength ) && length( PAR.Labels.Index.card ) ~= PAR.OriginalLabelLength
                    PAR.Labels.Index = structfun( @( x )x( 1:PAR.OriginalLabelLength ), PAR.Labels.Index, 'UniformOutput', 0 );
                end
                
                if ~any( strcmpi( PAR.Chunk.Def, 'all' ) ) && ~any( strcmpi( PAR.Chunk.Def, 'card' ) )
                    
                    
                    
                    PAR.Chunk.Reset;
                end
                PAR.Parameter2Read.card = double( ( 0:PAR.Cardiac.RetroPhases - 1 )' );
                PAR.Parameter2Read.card_range = double( ( 0:PAR.Cardiac.RetroPhases - 1 )' );
                PAR.Parameter2Read.rtop = double( unique( PAR.Labels.Index.rtop ) );
                
                if ~isempty( PAR.Chunk.Parameter2Read_BeforeChunk )
                    PAR.Chunk.Parameter2Read_BeforeChunk.card = PAR.Parameter2Read.card;
                end
                if ~isempty( PAR.Parameter2Read_Original )
                    PAR.Parameter2Read_Original.card = PAR.Parameter2Read.card;
                end
                
                PAR.Labels.Index.card = PAR.Labels.Index.card * 0;
                
                
                
                if any( strcmpi( PAR.Cardiac.RetroBinning, { 'Relative', 'relative', 'Rel' } ) )
                    rel_phase_dur = 1 / single( PAR.Cardiac.RetroPhases );
                    rel_phase = single( PAR.Labels.Index.rtop( PAR.Labels.Index.rr > 0 ) ) ./ single( PAR.Labels.Index.rr( PAR.Labels.Index.rr > 0 ) );
                    PAR.Labels.Index.card( PAR.Labels.Index.rr > 0 ) = floor( rel_phase( : ) / rel_phase_dur );
                    PAR.Labels.Index.card( PAR.Labels.Index.card == PAR.Cardiac.RetroPhases ) = PAR.Cardiac.RetroPhases - 1;
                    skip_phase = [  ];
                end
                
                
                
                if any( strcmpi( PAR.Cardiac.RetroBinning, { 'Mixed', 'mixed', 'Mix' } ) )
                    mean_RR_interval = mean( PAR.Labels.Index.rr( PAR.Labels.Index.rr > 0 ) );
                    abs_phase_dur = single( mean_RR_interval ) / single( PAR.Cardiac.RetroPhases );
                    rel_phase_dur = 1 / single( PAR.Cardiac.RetroPhases );
                    
                    end_systole_ms = PAR.Cardiac.RetroEndSystoleMs;
                    profile_mask_systole = PAR.Labels.Index.rr > 0 & PAR.Labels.Index.rtop <= end_systole_ms;
                    PAR.Labels.Index.card( profile_mask_systole ) = floor( single( PAR.Labels.Index.rtop( profile_mask_systole ) ) / abs_phase_dur );
                    
                    profile_mask_diastole = PAR.Labels.Index.rr > 0 & PAR.Labels.Index.rtop > end_systole_ms;
                    rel_phase = single( PAR.Labels.Index.rtop( profile_mask_diastole ) ) ./ single( PAR.Labels.Index.rr( profile_mask_diastole ) );
                    PAR.Labels.Index.card( profile_mask_diastole ) = floor( rel_phase( : ) / rel_phase_dur );
                    skip_phase = [  ];
                end
                
                
                if any( strcmpi( PAR.Cardiac.RetroBinning, { 'Absolute', 'absolute', 'Abs' } ) )
                    max_RR_interval = max( PAR.Labels.Index.rr( PAR.Labels.Index.rr > 0 ) );
                    abs_phase_dur = single( max_RR_interval ) / single( PAR.Cardiac.RetroPhases );
                    
                    PAR.Labels.Index.card( : ) = floor( single( PAR.Labels.Index.rtop( : ) ) / abs_phase_dur );
                    skip_phase = [  ];
                end
                
                if ~isempty( PAR.OriginalLabelLength ) && length( PAR.Labels.Index.card ) ~= PAR.OriginalLabelLength
                    labels = structfun( @( x )x( 1:PAR.OriginalLabelLength ), labels, 'UniformOutput', 0 );
                end
                PAR.OriginalLabelLength = length( PAR.Labels.Index.card );
                
                if ( ~strcmpi( PAR.Cardiac.RetroHoleInterpolation, 'no' ) )
                    PAR.Labels.Index = MRparameter.retro_fill_holes( PAR.Labels.Index, PAR.Cardiac.RetroHoleInterpolation, PAR.Cardiac.FillHolesPerCoil, PAR.Cardiac.FillHolesWrapAround, PAR.Recon.ImmediateAveraging, skip_phase );
                end
                if isfield( PAR.Labels.Index, 'aver' )
                    PAR.Parameter2Read.rtop = unique( PAR.Labels.Index.rtop );
                end
            end
        end
        function RetroRefillHoles( PAR, a, b )
            
            if any( strcmpi( PAR.Cardiac.Synchronization, { 'retro', 'retrospective' } ) ) &&  ...
                    ~isempty( PAR.Cardiac.RetroPhases )
                
                if ~isempty( PAR.OriginalLabelLength )
                    PAR.Labels.Index = structfun( @( x )x( 1:PAR.OriginalLabelLength ), PAR.Labels.Index, 'UniformOutput', 0 );
                end
                skip_phase = [  ];
                
                if ~isempty( PAR.OriginalLabelLength ) && length( PAR.Labels.Index.card ) ~= PAR.OriginalLabelLength
                    labels = structfun( @( x )x( 1:PAR.OriginalLabelLength ), labels, 'UniformOutput', 0 );
                end
                PAR.OriginalLabelLength = length( PAR.Labels.Index.card );
                
                PAR.Labels.Index = MRparameter.retro_fill_holes( PAR.Labels.Index, PAR.Cardiac.RetroHoleInterpolation, PAR.Cardiac.FillHolesPerCoil, PAR.Cardiac.FillHolesWrapAround, PAR.Recon.ImmediateAveraging, skip_phase );
                
                if isfield( PAR.Labels.Index, 'aver' )
                    PAR.Parameter2Read.rtop = unique( PAR.Labels.Index.rtop );
                end
            end
            
        end
        
        
        
        
        function InitEncoding( PAR )
            switch PAR.DataFormat
                case { 'ExportedRaw', 'Raw', 'ExportedCpx', 'Bruker' }
                    PAR.Encoding.Reset;
                    
                    if isfield( PAR.Labels, 'KxRange' )
                        
                        PAR.Encoding.NrMixes = PAR.Labels.NumberOfMixes( 1 );
                        PAR.Encoding.NrEchoes = PAR.Labels.NumberOfEchoes( 1 );
                        
                        mixes = PAR.Parameter2Read.mix;
                        echoes = PAR.Parameter2Read.echo;
                        
                        loop = 1;
                        for m = mixes'
                            for e = echoes'
                                
                                legend_row = PAR.Labels.Mix == m & PAR.Labels.Echo == e;
                                
                                PAR.Encoding.Mix( loop ) = m;
                                PAR.Encoding.Echo( loop ) = e;
                                
                                PAR.Encoding.DataSizeByte( loop ) = max( single( [ 0, PAR.Labels.Index.size(  ...
                                    find( PAR.Labels.Index.typ == 1 & PAR.Labels.Index.echo == e &  ...
                                    PAR.Labels.Index.mix == m, 1 ) ) ] ) );
                                
                                PAR.Encoding.KxRange( loop, : ) = PAR.Labels.KxRange( legend_row, : );
                                if isfield( PAR.Labels, 'KyRange' )
                                    PAR.Encoding.KyRange( loop, : ) = PAR.Labels.KyRange( legend_row, : );
                                end
                                if isfield( PAR.Labels, 'KzRange' )
                                    PAR.Encoding.KzRange( loop, : ) = PAR.Labels.KzRange( legend_row, : );
                                end
                                
                                PAR.Encoding.KxOversampling( loop, : ) = PAR.Labels.KxOversampleFactor( legend_row, : );
                                if isfield( PAR.Labels, 'KyOversampleFactor' )
                                    PAR.Encoding.KyOversampling( loop, : ) = PAR.Labels.KyOversampleFactor( legend_row, : );
                                end
                                if isfield( PAR.Labels, 'KzOversampleFactor' )
                                    PAR.Encoding.KzOversampling( loop, : ) = PAR.Labels.KzOversampleFactor( legend_row, : );
                                end
                                
                                PAR.Encoding.XRange( loop, : ) = PAR.Labels.XRange( legend_row, : );
                                if isfield( PAR.Labels, 'YRange' )
                                    PAR.Encoding.YRange( loop, : ) = PAR.Labels.YRange( legend_row, : );
                                end
                                if isfield( PAR.Labels, 'ZRange' )
                                    PAR.Encoding.ZRange( loop, : ) = PAR.Labels.ZRange( legend_row, : );
                                end
                                
                                PAR.Encoding.XRes( loop, : ) = PAR.Labels.XResolution( m + 1, : );
                                if isfield( PAR.Labels, 'YResolution' )
                                    PAR.Encoding.YRes( loop, : ) = PAR.Labels.YResolution( m + 1, : );
                                end
                                if isfield( PAR.Labels, 'ZResolution' )
                                    PAR.Encoding.ZRes( loop, : ) = PAR.Labels.ZResolution( m + 1, : );
                                end
                                if isfield( PAR.Labels, 'YResolution' )
                                    
                                    if PAR.Labels.Spectro
                                        PAR.Encoding.XReconRes( loop, : ) = PAR.Labels.XResolution( loop );
                                        PAR.Encoding.YReconRes( loop, : ) = PAR.Encoding.YRes( loop );
                                    else
                                        
                                        
                                        PAR.Encoding.XReconRes( loop, : ) = max( [ PAR.Labels.XResolution( m + 1, : ), PAR.Labels.YResolution( m + 1, : ) ] );
                                        PAR.Encoding.YReconRes( loop, : ) = PAR.Encoding.XReconRes( loop, : );
                                    end
                                else
                                    PAR.Encoding.XReconRes( loop, : ) = PAR.Labels.XResolution( m + 1, : );
                                end
                                if isfield( PAR.Labels, 'ZResolution' )
                                    PAR.Encoding.ZReconRes( loop, : ) = PAR.Encoding.ZRes( loop );
                                end
                                
                                loop = loop + 1;
                            end
                        end
                    else
                        PAR.Encoding.NrMixes = length( PAR.Parameter2Read.mix );
                        PAR.Encoding.NrEchoes = length( PAR.Parameter2Read.echo );
                        
                        mixes = PAR.Parameter2Read.mix;
                        echoes = PAR.Parameter2Read.echo;
                        
                        loop = 1;
                        for m = mixes'
                            for e = echoes'
                                mixecho_mask = PAR.Labels.Index.typ == 1 ...
                                    & PAR.Labels.Index.mix == m & PAR.Labels.Index.echo == e;
                                
                                if ~isempty( find( mixecho_mask ) )
                                    curSize = single( PAR.Labels.Index.size( find( mixecho_mask, 1 ) ) );
                                    if isfield( PAR.Labels.Index, 'format' )
                                        format = single( PAR.Labels.Index.format( find( mixecho_mask, 1 ) ) );
                                        samples = curSize / 2 / PAR.DataType.SampleSizeBytes( find( PAR.DataType.DataTypeNum == format ) );
                                    else
                                        samples = curSize / 2 / PAR.DataType.SampleSizeBytes( 1 );
                                    end
                                    
                                    max_ky = max( single( unique( PAR.Labels.Index.ky_label( mixecho_mask ) ) ) );
                                    min_ky = min( [ 0, min( single( unique( PAR.Labels.Index.ky_label( mixecho_mask ) ) ) ) ] );
                                    max_kz = max( single( unique( PAR.Labels.Index.kz_label( mixecho_mask ) ) ) );
                                    min_kz = min( [ 0, min( single( unique( PAR.Labels.Index.kz_label( mixecho_mask ) ) ) ) ] );
                                    
                                    ky_encs = ( max_ky - min_ky ) + 1;
                                    kz_encs = ( max_kz - min_kz ) + 1;
                                    
                                    PAR.Encoding.Mix( loop ) = m;
                                    PAR.Encoding.Echo( loop ) = e;
                                    
                                    PAR.Encoding.DataSizeByte( loop ) = PAR.Labels.Index.size(  ...
                                        find( PAR.Labels.Index.typ == 1 & PAR.Labels.Index.echo == e &  ...
                                        PAR.Labels.Index.mix == m, 1 ) );
                                    
                                    PAR.Encoding.KxRange( loop, : ) = [  - floor( samples / 2 ), ceil( samples ./ 2 ) - 1 ];
                                    if max_ky ~= min_ky
                                        if strcmpi( PAR.DataFormat, 'ExportedCpx' )
                                            PAR.Encoding.KyRange( loop, : ) = [ min_ky, max_ky ];
                                        else
                                            PAR.Encoding.KyRange( loop, : ) = [  - floor( ky_encs / 2 ), ceil( ky_encs ./ 2 ) - 1 ];
                                        end
                                    elseif loop > 1
                                        PAR.Encoding.KyRange( loop, : ) = [ 0, 0 ];
                                    end
                                    if max_kz ~= min_kz
                                        if strcmpi( PAR.DataFormat, 'ExportedCpx' )
                                            PAR.Encoding.KzRange( loop, : ) = [ min_kz, max_kz ];
                                        else
                                            PAR.Encoding.KzRange( loop, : ) = [  - floor( kz_encs / 2 ), ceil( kz_encs ./ 2 ) - 1 ];
                                        end
                                    elseif loop > 1
                                        PAR.Encoding.KzRange( loop, : ) = [ 0, 0 ];
                                    end
                                    
                                    if strcmpi( PAR.DataFormat, 'ExportedCpx' )
                                        PAR.Encoding.KxOversampling( loop, : ) = 1;
                                    else
                                        PAR.Encoding.KxOversampling( loop, : ) = 2;
                                    end
                                    
                                    if max_ky ~= min_ky
                                        PAR.Encoding.KyOversampling( loop, : ) = 1;
                                        
                                        
                                    else
                                        
                                    end
                                    if max_kz ~= min_kz
                                        PAR.Encoding.KzOversampling( loop, : ) = 1;
                                        
                                        
                                    else
                                        
                                    end
                                    
                                    
                                    PAR.Encoding.XRange( loop, : ) = PAR.Encoding.KxRange( loop, : ) ./ PAR.Encoding.KxOversampling( loop, : );
                                    if max_ky ~= min_ky
                                        PAR.Encoding.YRange( loop, : ) = PAR.Encoding.KyRange( loop, : ) ./ PAR.Encoding.KyOversampling( loop, : );
                                        
                                        
                                    else
                                        
                                    end
                                    if max_kz ~= min_kz
                                        PAR.Encoding.ZRange( loop, : ) = PAR.Encoding.KzRange( loop, : ) ./ PAR.Encoding.KzOversampling( loop, : );
                                        
                                        
                                    else
                                        
                                    end
                                    
                                    PAR.Encoding.XRes( loop, : ) = length( PAR.Encoding.XRange( loop, 1 ):PAR.Encoding.XRange( loop, 2 ) );
                                    if max_ky ~= min_ky
                                        PAR.Encoding.YRes( loop, : ) = length( PAR.Encoding.YRange( loop, 1 ):PAR.Encoding.YRange( loop, 2 ) );
                                        
                                        
                                    else
                                        
                                    end
                                    
                                    if max_kz ~= min_kz
                                        PAR.Encoding.ZRes( loop, : ) = length( PAR.Encoding.ZRange( loop, 1 ):PAR.Encoding.ZRange( loop, 2 ) );
                                        
                                        
                                    else
                                        
                                    end
                                    
                                    if ~isempty( PAR.Encoding.YRes )
                                        if loop <= size( PAR.Encoding.YRes, 1 )
                                            PAR.Encoding.XReconRes( loop, : ) = max( [ PAR.Encoding.XRes( loop, : ), PAR.Encoding.YRes( loop, : ) ] );
                                        else
                                            PAR.Encoding.XReconRes( loop, : ) = PAR.Encoding.XRes( loop, : );
                                        end
                                    else
                                        PAR.Encoding.XReconRes( loop, : ) = PAR.Encoding.XRes( loop, : );
                                    end
                                    if max_ky ~= min_ky
                                        PAR.Encoding.YReconRes( loop, : ) = PAR.Encoding.XReconRes( loop, : );
                                        
                                        
                                    else
                                        
                                    end
                                    if max_kz ~= min_kz
                                        PAR.Encoding.ZReconRes( loop, : ) = PAR.Encoding.ZRes( loop );
                                        
                                        
                                    else
                                        
                                    end
                                    
                                    loop = loop + 1;
                                end
                                
                            end
                        end
                    end
                    PAR.Encoding.FFTShift = [ 1, 1, 1 ];
                    PAR.Encoding.FFTDims = [ 1, 1, 1 ];
                    
                    
                    PAR.Encoding.NrFids( 1 ) = sum( ( PAR.Labels.Index.mix == 0 ) & ( PAR.Labels.Index.typ < 2 ) ) /  ...
                        length( unique( PAR.Labels.Index.chan ) ) / length( unique( PAR.Labels.Index.dyn ) ) /  ...
                        length( unique( PAR.Labels.Index.ky ) ) / length( unique( PAR.Labels.Index.kz ) ) / length( unique( PAR.Labels.Index.extr1 ) );
                    if ( length( unique( PAR.Labels.Index.mix ) ) == 2 )
                        PAR.Encoding.NrFids( 2 ) = sum( ( PAR.Labels.Index.mix == 1 ) & ( PAR.Labels.Index.typ < 2 ) ) /  ...
                            length( unique( PAR.Labels.Index.chan ) ) / length( unique( PAR.Labels.Index.dyn ) ) /  ...
                            length( unique( PAR.Labels.Index.ky ) ) / length( unique( PAR.Labels.Index.kz ) ) / length( unique( PAR.Labels.Index.extr1 ) );
                    end
                    
                    PAR.Encoding.NrDyn = zeros( 1, length( unique( PAR.Labels.Index.mix ) ) );
                    PAR.Encoding.NrDyn( 1 ) = length( unique( PAR.Labels.Index.dyn ) );
                    if ( length( unique( PAR.Labels.Index.mix ) ) == 2 )
                        PAR.Encoding.NrDyn( 2 ) = length( unique( PAR.Labels.Index.dyn ) );
                    end
                    
                    PAR.InitWorkEncoding( PAR );
                    
                    
                    
                    if length( PAR.Parameter2Read.echo ) > 1
                        first_range = PAR.Encoding.XRange( 1, : );
                        for i = 1:length( PAR.Encoding.Echo )
                            cur_ind = PAR.Labels.Index.echo == PAR.Encoding.Echo( i ) &  ...
                                PAR.Labels.Index.mix == PAR.Encoding.Mix( i );
                            cur_range = PAR.Encoding.XRange( i, : );
                            if any( first_range ~= cur_range )
                                PAR.Labels.Index.sign( cur_ind ) =  - PAR.Labels.Index.sign( cur_ind );
                            end
                        end
                    end
                    
                case 'Rec'
                    if isfield( PAR.Labels.ImageInformation, 'ReconResolution' )
                        [ PAR.Encoding.XReconRes, a, b ] = unique( PAR.Labels.ImageInformation.ReconResolution( :, 1 ), 'rows' );
                        PAR.Encoding.YReconRes = unique( PAR.Labels.ImageInformation.ReconResolution( :, 2 ), 'rows' );
                        [ u, temp, ind ] = unique( PAR.Labels.ImageInformation.SliceNumber );
                    else
                        [ PAR.Encoding.XReconRes, a, b ] = unique( PAR.Labels.ImageInformation.ResolutionX, 'rows' );
                        PAR.Encoding.YReconRes = unique( PAR.Labels.ImageInformation.ResolutionY, 'rows' );
                        [ u, temp, ind ] = unique( PAR.Labels.ImageInformation.Slice );
                    end
                    for i = 1:length( a )
                        PAR.Encoding.ZReconRes( i, 1 ) = length( find( b( temp ) == i ) );
                    end
                    PAR.InitWorkEncoding( PAR );
            end
        end
        function InitWorkEncoding( PAR, a, b )
            switch PAR.DataFormat
                case { 'ExportedRaw', 'Raw', 'ExportedCpx', 'Bruker' }
                    PAR.Encoding.ResetWorkEncoding;
                    
                    mixes = PAR.Parameter2Read.mix;
                    echoes = PAR.Parameter2Read.echo;
                    mixecho_ind = find( ismember( PAR.Encoding.Mix, mixes ) &  ...
                        ismember( PAR.Encoding.Echo, echoes ) );
                    
                    cur_kx_range = PAR.Encoding.KxRange( mixecho_ind, : );
                    if ~isempty( PAR.Encoding.KyRange )
                        cur_ky_range = PAR.Encoding.KyRange( mixecho_ind, : );
                    else
                        cur_ky_range = [  ];
                    end
                    if ~isempty( PAR.Encoding.KzRange ) && max( mixecho_ind ) <= size( PAR.Encoding.KzRange, 1 )
                        cur_kz_range = PAR.Encoding.KzRange( mixecho_ind, : );
                    else
                        cur_kz_range = [  ];
                    end
                    if ~isempty( PAR.Encoding.DataSizeByte )
                        cur_size = PAR.Encoding.DataSizeByte( mixecho_ind );
                    else
                        cur_size = [  ];
                    end
                    
                    xyz_range_size = [ cur_kx_range, cur_ky_range, cur_kz_range, cur_size' ];
                    [ urows, uind, cell_ind ] = unique( xyz_range_size, 'rows' );
                    
                    
                    
                    
                    
                    if ( PAR.Labels.Spectro && ( PAR.Encoding.NrMixes == 2 ) && ( length( uind ) == 1 ) )
                        urows = [ urows;urows ];
                        uind = [ 1, 2 ];
                        cell_ind = [ 1, 2 ];
                    end
                    
                    
                    for ty = 1:length( PAR.Parameter2Read.typ )
                        typ = PAR.Parameter2Read.typ( ty );
                        if length( PAR.Parameter2Read.typ ) > 1
                            typ_ind = typ;
                        else
                            typ_ind = 1;
                        end
                        
                        for i = 1:length( uind )
                            enc_ind = mixecho_ind( uind( i ) );
                            
                            cur_mix = PAR.Encoding.Mix( mixecho_ind( find( cell_ind == i ) ) );
                            cur_echo = PAR.Encoding.Echo( mixecho_ind( find( cell_ind == i ) ) );
                            cur_size = PAR.Encoding.DataSizeByte( mixecho_ind( find( cell_ind == i ) ) );
                            
                            if typ == 1 || typ == 2 || typ == 3
                                PAR.Encoding.WorkEncoding.Typ{ typ_ind, i } = typ;
                                PAR.Encoding.WorkEncoding.Mix{ typ_ind, i } = cur_mix;
                                PAR.Encoding.WorkEncoding.Echo{ typ_ind, i } = cur_echo;
                                PAR.Encoding.WorkEncoding.DataSizeByte{ typ_ind, i } = cur_size;
                                
                                PAR.Encoding.WorkEncoding.KxRange{ typ_ind, i } = PAR.Encoding.KxRange( enc_ind, : );
                                if ~isempty( PAR.Encoding.KyRange )
                                    PAR.Encoding.WorkEncoding.KyRange{ typ_ind, i } = PAR.Encoding.KyRange( enc_ind, : );
                                else
                                    PAR.Encoding.WorkEncoding.KyRange{ typ_ind, i } = [  ];
                                end
                                if ~isempty( PAR.Encoding.KzRange )
                                    PAR.Encoding.WorkEncoding.KzRange{ typ_ind, i } = PAR.Encoding.KzRange( enc_ind, : );
                                else
                                    PAR.Encoding.WorkEncoding.KzRange{ typ_ind, i } = [  ];
                                end
                                
                                
                                PAR.Encoding.WorkEncoding.KxOversampling{ typ_ind, i } = PAR.Encoding.KxOversampling( enc_ind, : );
                                PAR.Encoding.WorkEncoding.KxOversamplingOrig{ typ_ind, i } = PAR.Encoding.KxOversampling( enc_ind, : );
                                if ~isempty( PAR.Encoding.KyOversampling )
                                    PAR.Encoding.WorkEncoding.KyOversampling{ typ_ind, i } = PAR.Encoding.KyOversampling( enc_ind, : );
                                    PAR.Encoding.WorkEncoding.KyOversamplingOrig{ typ_ind, i } = PAR.Encoding.KyOversampling( enc_ind, : );
                                else
                                    PAR.Encoding.WorkEncoding.KyOversampling{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.KyOversamplingOrig{ typ_ind, i } = [  ];
                                end
                                if ~isempty( PAR.Encoding.KzOversampling )
                                    PAR.Encoding.WorkEncoding.KzOversampling{ typ_ind, i } = PAR.Encoding.KzOversampling( enc_ind, : );
                                    PAR.Encoding.WorkEncoding.KzOversamplingOrig{ typ_ind, i } = PAR.Encoding.KzOversampling( enc_ind, : );
                                else
                                    PAR.Encoding.WorkEncoding.KzOversampling{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.KzOversamplingOrig{ typ_ind, i } = [  ];
                                end
                                
                                
                                if isfield( PAR.Labels, 'FEARFactor' )
                                    PAR.Encoding.WorkEncoding.FEARFactor{ typ_ind, i } = PAR.Labels.FEARFactor;
                                    PAR.Encoding.WorkEncoding.FEARCenterK{ typ_ind, i } = PAR.Encoding.WorkEncoding.KxRange{ typ_ind, i }( 1 );
                                else
                                    PAR.Encoding.WorkEncoding.FEARFactor{ typ_ind, i } = 0;
                                    PAR.Encoding.WorkEncoding.FEARCenterK{ typ_ind, i } = 0;
                                end
                                
                                PAR.Encoding.WorkEncoding.XRes{ typ_ind, i } = PAR.Encoding.XRes( enc_ind, : );
                                if ~isempty( PAR.Encoding.YRes )
                                    PAR.Encoding.WorkEncoding.YRes{ typ_ind, i } = PAR.Encoding.YRes( enc_ind, : );
                                else
                                    PAR.Encoding.WorkEncoding.YRes{ typ_ind, i } = [  ];
                                end
                                if ~isempty( PAR.Encoding.ZRes )
                                    PAR.Encoding.WorkEncoding.ZRes{ typ_ind, i } = PAR.Encoding.ZRes( enc_ind, : );
                                else
                                    PAR.Encoding.WorkEncoding.ZRes{ typ_ind, i } = [  ];
                                end
                                
                                
                                
                                PAR.Encoding.WorkEncoding.XRange{ typ_ind, i } = MRparameter.set_new_range( PAR.Encoding.XRange( enc_ind, : ), PAR.Encoding.KxOversampling( enc_ind, 1 ) );
                                
                                if ~isempty( PAR.Encoding.YRange )
                                    PAR.Encoding.WorkEncoding.YRange{ typ_ind, i } = PAR.Encoding.YRange( enc_ind, : );
                                else
                                    PAR.Encoding.WorkEncoding.YRange{ typ_ind, i } = [  ];
                                end
                                if ~isempty( PAR.Encoding.ZRange )
                                    PAR.Encoding.WorkEncoding.ZRange{ typ_ind, i } = PAR.Encoding.ZRange( enc_ind, : );
                                else
                                    PAR.Encoding.WorkEncoding.ZRange{ typ_ind, i } = [  ];
                                end
                                
                                PAR.Encoding.WorkEncoding.XReconRes{ typ_ind, i } = PAR.Encoding.XReconRes( enc_ind, : );
                                if ~isempty( PAR.Encoding.YReconRes )
                                    PAR.Encoding.WorkEncoding.YReconRes{ typ_ind, i } = PAR.Encoding.YReconRes( enc_ind, : );
                                else
                                    PAR.Encoding.WorkEncoding.YReconRes{ typ_ind, i } = [  ];
                                end
                                if ~isempty( PAR.Encoding.ZReconRes )
                                    PAR.Encoding.WorkEncoding.ZReconRes{ typ_ind, i } = PAR.Encoding.ZReconRes( enc_ind, : );
                                else
                                    PAR.Encoding.WorkEncoding.ZReconRes{ typ_ind, i } = [  ];
                                end
                            else
                                mixecho_mask = ismember( PAR.Labels.Index.typ, typ ) ...
                                    & ismember( PAR.Labels.Index.mix, cur_mix ) ...
                                    & ismember( PAR.Labels.Index.echo, cur_echo );
                                
                                curSize = single( PAR.Labels.Index.size( find( mixecho_mask, 1 ) ) );
                                if isfield( PAR.Labels.Index, 'format' )
                                    if ~isempty( find( mixecho_mask, 1 ) )
                                        cur_ind = find( PAR.DataType.DataTypeNum == PAR.Labels.Index.format( find( mixecho_mask, 1 ) ) );
                                    else
                                        cur_ind = 1;
                                    end
                                else
                                    cur_ind = 1;
                                end
                                if ~isempty( curSize )
                                    
                                    PAR.Encoding.WorkEncoding.Typ{ typ_ind, i } = typ;
                                    PAR.Encoding.WorkEncoding.Mix{ typ_ind, i } = cur_mix;
                                    PAR.Encoding.WorkEncoding.Echo{ typ_ind, i } = cur_echo;
                                    PAR.Encoding.WorkEncoding.DataSizeByte{ typ_ind, i } = curSize;
                                    
                                    samples = curSize / 2 / PAR.DataType.SampleSizeBytes( cur_ind );
                                    
                                    PAR.Encoding.WorkEncoding.KxRange{ typ_ind, i } = [  - floor( samples / 2 ), ceil( samples ./ 2 ) - 1 ];
                                    
                                    PAR.Encoding.WorkEncoding.KyRange{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.KzRange{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.KxOversampling{ typ_ind, i } = 1;
                                    PAR.Encoding.WorkEncoding.KyOversampling{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.KzOversampling{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.KxOversamplingOrig{ typ_ind, i } = 1;
                                    PAR.Encoding.WorkEncoding.KyOversamplingOrig{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.KzOversamplingOrig{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.XRes{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.YRes{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.ZRes{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.XRange{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.YRange{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.ZRange{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.XReconRes{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.YReconRes{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.ZReconRes{ typ_ind, i } = [  ];
                                    PAR.Encoding.WorkEncoding.FEARFactor{ typ_ind, i } = 0;
                                    PAR.Encoding.WorkEncoding.FEARCenterK{ typ_ind, i } = 0;
                                end
                            end
                        end
                    end
                    
                    if ~any( strcmpi( PAR.Chunk.Def, 'ALL' ) ) && ~any( strcmp( PAR.Chunk.Def, 'kz' ) )
                        PAR.Encoding.WorkEncoding.KzRange = cellfun( @( x )[  ], PAR.Encoding.WorkEncoding.KzRange, 'UniformOutput', 0 );
                        PAR.Encoding.WorkEncoding.ZRange = cellfun( @( x )[  ], PAR.Encoding.WorkEncoding.ZRange, 'UniformOutput', 0 );
                        PAR.Encoding.WorkEncoding.ZRes = cellfun( @( x )[  ], PAR.Encoding.WorkEncoding.ZRes, 'UniformOutput', 0 );
                        PAR.Encoding.WorkEncoding.ZReconRes = cellfun( @( x )[  ], PAR.Encoding.WorkEncoding.ZReconRes, 'UniformOutput', 0 );
                        PAR.Encoding.WorkEncoding.KzOversampling = cellfun( @( x )[  ], PAR.Encoding.WorkEncoding.KzOversampling, 'UniformOutput', 0 );
                        PAR.Encoding.WorkEncoding.KzOversampling = cellfun( @( x )[  ], PAR.Encoding.WorkEncoding.KzOversamplingOrig, 'UniformOutput', 0 );
                    end
                case 'Rec'
                    PAR.Encoding.WorkEncoding.XReconRes{ 1 } = PAR.Encoding.XReconRes;
                    PAR.Encoding.WorkEncoding.YReconRes{ 1 } = PAR.Encoding.YReconRes;
                    PAR.Encoding.WorkEncoding.ZReconRes{ 1 } = PAR.Encoding.ZReconRes;
                    
                    PAR.Encoding.WorkEncoding.XRes{ 1 } = PAR.Encoding.XReconRes;
                    PAR.Encoding.WorkEncoding.YRes{ 1 } = PAR.Encoding.YReconRes;
                    PAR.Encoding.WorkEncoding.ZRes{ 1 } = PAR.Encoding.ZReconRes;
            end
            PAR.Encoding.WorkEncoding.MPS = [ 1, 2, 3 ];
            PAR.Encoding.WorkEncoding.FFTShift = PAR.Encoding.FFTShift;
            PAR.Encoding.WorkEncoding.FFTDims = PAR.Encoding.FFTDims;
            
            
            PAR.UpdateFidInfos;
            
        end
        function UpdateWorkEncoding( PAR, a, b )
            if PAR.Parameter2Read.EnableRangeCheck
                switch PAR.DataFormat
                    case { 'ExportedRaw', 'ExportedCpx', 'Raw' }
                        mixes = PAR.Parameter2Read.mix;
                        echoes = PAR.Parameter2Read.echo;
                        mixecho_ind = find( ismember( PAR.Encoding.Mix, mixes ) &  ...
                            ismember( PAR.Encoding.Echo, echoes ) );
                        
                        cur_kx_range = PAR.Encoding.KxRange( mixecho_ind, : );
                        if ~isempty( PAR.Encoding.KyRange )
                            cur_ky_range = PAR.Encoding.KyRange( mixecho_ind, : );
                        else
                            cur_ky_range = [  ];
                        end
                        if ~isempty( PAR.Encoding.KzRange )
                            cur_kz_range = PAR.Encoding.KzRange( mixecho_ind, : );
                        else
                            cur_kz_range = [  ];
                        end
                        if ~isempty( PAR.Encoding.DataSizeByte )
                            cur_size = PAR.Encoding.DataSizeByte( mixecho_ind );
                        else
                            cur_size = [  ];
                        end
                        
                        xyz_range_size = [ cur_kx_range, cur_ky_range, cur_kz_range, cur_size' ];
                        [ urows, uind, cell_ind ] = unique( xyz_range_size, 'rows' );
                        
                        
                        
                        
                        
                        if ( PAR.Labels.Spectro && ( PAR.Encoding.NrMixes == 2 ) && ( length( uind ) == 1 ) )
                            urows = [ urows;urows ];
                            uind = [ 1, 2 ];
                            cell_ind = [ 1, 2 ];
                        end
                        
                        
                        for ty = 1:length( PAR.Parameter2Read.typ )
                            typ = PAR.Parameter2Read.typ( ty );
                            if length( PAR.Parameter2Read.typ ) > 1
                                typ_ind = typ;
                            else
                                typ_ind = 1;
                            end
                            
                            for i = 1:length( uind )
                                enc_ind = mixecho_ind( uind( i ) );
                                
                                cur_mix = PAR.Encoding.Mix( mixecho_ind( find( cell_ind == i ) ) );
                                cur_echo = PAR.Encoding.Echo( mixecho_ind( find( cell_ind == i ) ) );
                                cur_size = PAR.Encoding.DataSizeByte( mixecho_ind( find( cell_ind == i ) ) );
                                
                                if typ == 1 || typ == 2
                                    
                                    switch a.Name
                                        case 'Typ'
                                            PAR.Encoding.WorkEncoding.Typ{ typ_ind, i } = typ;
                                        case 'Mix'
                                            PAR.Encoding.WorkEncoding.Mix{ typ_ind, i } = cur_mix;
                                        case 'Echo'
                                            PAR.Encoding.WorkEncoding.Echo{ typ_ind, i } = cur_echo;
                                        case 'DataSizeByte'
                                            PAR.Encoding.WorkEncoding.DataSizeByte{ typ_ind, i } = cur_size;
                                        case 'KxRange'
                                            PAR.Encoding.WorkEncoding.KxRange{ typ_ind, i } = PAR.Encoding.KxRange( enc_ind, : );
                                        case 'KyRange'
                                            if ~isempty( PAR.Encoding.KyRange )
                                                PAR.Encoding.WorkEncoding.KyRange{ typ_ind, i } = PAR.Encoding.KyRange( enc_ind, : );
                                            else
                                                PAR.Encoding.WorkEncoding.KyRange{ typ_ind, i } = [  ];
                                            end
                                        case 'KzRange'
                                            if ~isempty( PAR.Encoding.KzRange )
                                                PAR.Encoding.WorkEncoding.KzRange{ typ_ind, i } = PAR.Encoding.KzRange( enc_ind, : );
                                            else
                                                PAR.Encoding.WorkEncoding.KzRange{ typ_ind, i } = [  ];
                                            end
                                        case 'KxOversampling'
                                            PAR.Encoding.WorkEncoding.KxOversampling{ typ_ind, i } = PAR.Encoding.KxOversampling( enc_ind, : );
                                            PAR.Encoding.WorkEncoding.KxOversamplingOrig{ typ_ind, i } = PAR.Encoding.KxOversampling( enc_ind, : );
                                        case 'KyOversampling'
                                            if ~isempty( PAR.Encoding.KyOversampling )
                                                PAR.Encoding.WorkEncoding.KyOversampling{ typ_ind, i } = PAR.Encoding.KyOversampling( enc_ind, : );
                                                PAR.Encoding.WorkEncoding.KyOversamplingOrig{ typ_ind, i } = PAR.Encoding.KyOversampling( enc_ind, : );
                                            else
                                                PAR.Encoding.WorkEncoding.KyOversampling{ typ_ind, i } = [  ];
                                                PAR.Encoding.WorkEncoding.KyOversamplingOrig{ typ_ind, i } = [  ];
                                            end
                                        case 'KzOversampling'
                                            if ~isempty( PAR.Encoding.KzOversampling )
                                                PAR.Encoding.WorkEncoding.KzOversampling{ typ_ind, i } = PAR.Encoding.KzOversampling( enc_ind, : );
                                                PAR.Encoding.WorkEncoding.KzOversamplingOrig{ typ_ind, i } = PAR.Encoding.KzOversampling( enc_ind, : );
                                            else
                                                PAR.Encoding.WorkEncoding.KzOversampling{ typ_ind, i } = [  ];
                                                PAR.Encoding.WorkEncoding.KzOversamplingOrig{ typ_ind, i } = [  ];
                                            end
                                        case 'XRes'
                                            PAR.Encoding.WorkEncoding.XRes{ typ_ind, i } = PAR.Encoding.XRes( enc_ind, : );
                                        case 'YRes'
                                            if ~isempty( PAR.Encoding.YRes )
                                                PAR.Encoding.WorkEncoding.YRes{ typ_ind, i } = PAR.Encoding.YRes( enc_ind, : );
                                            else
                                                PAR.Encoding.WorkEncoding.YRes{ typ_ind, i } = [  ];
                                            end
                                        case 'ZRes'
                                            if ~isempty( PAR.Encoding.ZRes )
                                                PAR.Encoding.WorkEncoding.ZRes{ typ_ind, i } = PAR.Encoding.ZRes( enc_ind, : );
                                            else
                                                PAR.Encoding.WorkEncoding.ZRes{ typ_ind, i } = [  ];
                                            end
                                        case 'XRange'
                                            
                                            
                                            
                                            PAR.Encoding.WorkEncoding.XRange{ typ_ind, i } = MRparameter.set_new_range( PAR.Encoding.XRange( enc_ind, : ), PAR.Encoding.KxOversampling( enc_ind, 1 ) );
                                        case 'YRange'
                                            if ~isempty( PAR.Encoding.YRange )
                                                PAR.Encoding.WorkEncoding.YRange{ typ_ind, i } = PAR.Encoding.YRange( enc_ind, : );
                                            else
                                                PAR.Encoding.WorkEncoding.YRange{ typ_ind, i } = [  ];
                                            end
                                        case 'ZRange'
                                            if ~isempty( PAR.Encoding.ZRange )
                                                PAR.Encoding.WorkEncoding.ZRange{ typ_ind, i } = PAR.Encoding.ZRange( enc_ind, : );
                                            else
                                                PAR.Encoding.WorkEncoding.ZRange{ typ_ind, i } = [  ];
                                            end
                                        case 'XReconRes'
                                            PAR.Encoding.WorkEncoding.XReconRes{ typ_ind, i } = PAR.Encoding.XReconRes( enc_ind, : );
                                        case 'YReconRes'
                                            if ~isempty( PAR.Encoding.YReconRes )
                                                PAR.Encoding.WorkEncoding.YReconRes{ typ_ind, i } = PAR.Encoding.YReconRes( enc_ind, : );
                                            else
                                                PAR.Encoding.WorkEncoding.YReconRes{ typ_ind, i } = [  ];
                                            end
                                        case 'ZReconRes'
                                            if ~isempty( PAR.Encoding.ZReconRes )
                                                PAR.Encoding.WorkEncoding.ZReconRes{ typ_ind, i } = PAR.Encoding.ZReconRes( enc_ind, : );
                                            else
                                                PAR.Encoding.WorkEncoding.ZReconRes{ typ_ind, i } = [  ];
                                            end
                                    end
                                    
                                else
                                    mixecho_mask = ismember( PAR.Labels.Index.typ, typ ) ...
                                        & ismember( PAR.Labels.Index.mix, cur_mix ) ...
                                        & ismember( PAR.Labels.Index.echo, cur_echo );
                                    
                                    curSize = single( PAR.Labels.Index.size( find( mixecho_mask, 1 ) ) );
                                    if ~isempty( curSize )
                                        
                                        PAR.Encoding.WorkEncoding.Typ{ typ_ind, i } = typ;
                                        PAR.Encoding.WorkEncoding.Mix{ typ_ind, i } = cur_mix;
                                        PAR.Encoding.WorkEncoding.Echo{ typ_ind, i } = cur_echo;
                                        PAR.Encoding.WorkEncoding.DataSizeByte{ typ_ind, i } = curSize;
                                        
                                        cur_sample_size = PAR.DataType.SampleSizeBytes( find( PAR.DataType.DataTypeNum == PAR.Labels.Index.format( find( PAR.Labels.Index.typ == typ, 1 ) ) ) );
                                        samples = curSize / 2 / cur_sample_size;
                                        
                                        PAR.Encoding.WorkEncoding.KxRange{ typ_ind, i } = [  - floor( samples / 2 ), ceil( samples ./ 2 ) - 1 ];
                                        
                                        PAR.Encoding.WorkEncoding.KyRange{ typ_ind, i } = [  ];
                                        PAR.Encoding.WorkEncoding.KzRange{ typ_ind, i } = [  ];
                                        PAR.Encoding.WorkEncoding.KxOversampling{ typ_ind, i } = [  ];
                                        PAR.Encoding.WorkEncoding.KyOversampling{ typ_ind, i } = [  ];
                                        PAR.Encoding.WorkEncoding.KzOversampling{ typ_ind, i } = [  ];
                                        PAR.Encoding.WorkEncoding.KxOversamplingOrig{ typ_ind, i } = [  ];
                                        PAR.Encoding.WorkEncoding.KyOversamplingOrig{ typ_ind, i } = [  ];
                                        PAR.Encoding.WorkEncoding.KzOversamplingOrig{ typ_ind, i } = [  ];
                                        PAR.Encoding.WorkEncoding.XRes{ typ_ind, i } = [  ];
                                        PAR.Encoding.WorkEncoding.YRes{ typ_ind, i } = [  ];
                                        PAR.Encoding.WorkEncoding.ZRes{ typ_ind, i } = [  ];
                                        PAR.Encoding.WorkEncoding.XRange{ typ_ind, i } = [  ];
                                        PAR.Encoding.WorkEncoding.YRange{ typ_ind, i } = [  ];
                                        PAR.Encoding.WorkEncoding.ZRange{ typ_ind, i } = [  ];
                                        PAR.Encoding.WorkEncoding.XReconRes{ typ_ind, i } = [  ];
                                        PAR.Encoding.WorkEncoding.YReconRes{ typ_ind, i } = [  ];
                                        PAR.Encoding.WorkEncoding.ZReconRes{ typ_ind, i } = [  ];
                                    end
                                end
                            end
                        end
                end
                switch a.Name
                    case 'FFTShift'
                        PAR.Encoding.WorkEncoding.FFTShift = PAR.Encoding.FFTShift;
                    case 'FFTDims'
                        PAR.Encoding.WorkEncoding.FFTDims = PAR.Encoding.FFTDims;
                end
            end
        end
        function SetKyKzLabels( PAR, a, b )
            switch PAR.DataFormat
                case { 'Raw' }
                    PAR.Labels.Index.ky = PAR.Labels.Index.ky_label;
                    PAR.Labels.Index.kz = PAR.Labels.Index.kz_label;
                    
                    if ~any( strcmpi( PAR.Scan.AcqMode, { 'radial', 'spiral' } ) )
                        for i = 1:length( PAR.Encoding.Mix )
                            ind = ( PAR.Labels.Index.typ == 1 | PAR.Labels.Index.typ == 2 | PAR.Labels.Index.typ == 3 | PAR.Labels.Index.typ == 5 ) &  ...
                                PAR.Labels.Index.mix == PAR.Encoding.Mix( i ) &  ...
                                PAR.Labels.Index.echo == PAR.Encoding.Echo( i );
                            
                            if ~isempty( PAR.Encoding.KyRange ) && size( PAR.Encoding.KyRange, 1 ) >= i
                                shift_y = PAR.Encoding.KyRange( i, 1 );
                                PAR.Labels.Index.ky( ind ) = PAR.Labels.Index.ky( ind ) + shift_y;
                            end
                        end
                    end
                    
                    
                    if ~strcmpi( PAR.Scan.KooshBall, 'yes' )
                        for i = 1:length( PAR.Encoding.Mix )
                            ind = ( PAR.Labels.Index.typ == 1 | PAR.Labels.Index.typ == 2 | PAR.Labels.Index.typ == 3 | PAR.Labels.Index.typ == 5 ) &  ...
                                PAR.Labels.Index.mix == PAR.Encoding.Mix( i ) &  ...
                                PAR.Labels.Index.echo == PAR.Encoding.Echo( i );
                            if ~isempty( PAR.Encoding.KzRange ) && size( PAR.Encoding.KzRange, 1 ) >= i
                                shift_z = PAR.Encoding.KzRange( i, 1 );
                                PAR.Labels.Index.kz( ind ) = PAR.Labels.Index.kz( ind ) + shift_z;
                            end
                        end
                    end
                    
                    
                    
                    if isfield( PAR.Labels, 'ScanTechnique' )
                        if ~isempty( regexpi( PAR.Labels.ScanTechnique, 'SE' ) ) &&  ...
                                ~strcmpi( PAR.Labels.ScanTechnique, 'TSE' ) &&  ...
                                length( PAR.Parameter2Read.echo ) > 1
                            max_y = max( single( PAR.Labels.Index.ky ) );
                            min_y = min( single( PAR.Labels.Index.ky ) );
                            max_z = max( single( PAR.Labels.Index.kz ) );
                            min_z = min( single( PAR.Labels.Index.kz ) );
                            odd_echoes = logical( mod( PAR.Labels.Index.echo, 2 ) );
                            PAR.Labels.Index.ky( odd_echoes ) =  - PAR.Labels.Index.ky( odd_echoes );
                            PAR.Labels.Index.kz( odd_echoes ) =  - PAR.Labels.Index.kz( odd_echoes );
                            
                            PAR.Labels.Index.ky( PAR.Labels.Index.ky > max_y ) = max_y;
                            PAR.Labels.Index.ky( PAR.Labels.Index.ky < min_y ) = min_y;
                            PAR.Labels.Index.kz( PAR.Labels.Index.kz > max_z ) = max_z;
                            PAR.Labels.Index.kz( PAR.Labels.Index.kz < min_z ) = min_z;
                        end
                    end
                    
                    PAR.Parameter2Read.ky = double( unique( PAR.Labels.Index.ky ) );
                    PAR.Parameter2Read.kz = double( unique( PAR.Labels.Index.kz ) );
                    if PAR.Parameter2Read.EnableRangeCheck
                        PAR.InitWorkEncoding( PAR );
                    end
            end
        end
        function UpdateFlow( PAR, a, b )
            is_flow = any( PAR.Recon.Venc( 1, : ) ~= 0 );
            if ( is_flow )
                if strcmpi( PAR.Scan.Multivenc, 'Yes' )
                    PAR.Recon.kv = PAR.Recon.kv( PAR.Parameter2Read.extr1 + 1, : );
                    
                    if ( length( PAR.Parameter2Read.extr1 ) == 1 || ~( PAR.Parameter2Read.extr1( 1 ) == 0 ) )
                        PAR.Recon.Venc = zeros( 1, 3 );
                    else
                        PAR.Recon.Venc = abs( 100 * pi ./ ( repmat( PAR.Scan.kv( PAR.Parameter2Read.extr1( 1 ) + 1, : ), [ length( PAR.Parameter2Read.extr1( 2:end  ) ), 1 ] ) - PAR.Scan.kv( PAR.Parameter2Read.extr1( 2:end  ) + 1, : ) ) );
                        PAR.Recon.Venc( isinf( PAR.Recon.Venc ) ) = 0;
                    end
                    if strcmpi( PAR.Recon.TKE, 'Yes' )
                        if ( length( PAR.Parameter2Read.extr1 ) < 2 || max( sum( PAR.Scan.kv( PAR.Parameter2Read.extr1 + 1, : ) ~= 0 ) ) < 2 )
                            
                            
                            PAR.Recon.TKE = 'No';
                            warning( 'Not enough flow segments for TKE recon - setting PAR.Recon.TKE to "No"' )
                        else
                            
                            PAR.Recon.Venc = max( PAR.Recon.Venc, [  ], 1 );
                        end
                    end
                else
                    
                    
                    
                    if ( all( PAR.Scan.Venc ~= 0 ) )
                        if ( length( PAR.Parameter2Read.extr1 ) == 1 || ~( PAR.Parameter2Read.extr1( 1 ) == 0 ) )
                            
                            
                            PAR.Recon.Venc = zeros( 1, 3 );
                        else
                            
                            PAR.Recon.Venc = zeros( 1, 3 );
                            PAR.Recon.Venc( 1, PAR.Parameter2Read.extr1( 2:end  ) ) = PAR.Scan.Venc( 1, PAR.Parameter2Read.extr1( 2:end  ) );
                        end
                    end
                end
            end
        end
        function UpdateTKE( PAR, a, b )
            if strcmpi( PAR.Labels.RefScan, 'No' )
                if strcmpi( PAR.Recon.TKE, 'Yes' )
                    if strcmpi( PAR.Scan.Multivenc, 'Yes' )
                        if ( length( PAR.Parameter2Read.extr1 ) < 2 || max( sum( PAR.Scan.kv( PAR.Parameter2Read.extr1 + 1, : ) ~= 0 ) ) < 2 )
                            
                            
                            PAR.Recon.TKE = 'No';
                            warning( 'Not enough flow segments for TKE recon - setting PAR.Recon.TKE to "No"' )
                        else
                            
                            PAR.Recon.Venc = max( PAR.Recon.Venc, [  ], 1 );
                        end
                    else
                        PAR.Recon.TKE = 'No';
                        warning( 'Not a multi-venc scan - setting PAR.Recon.TKE to "No"' )
                    end
                else
                    if strcmpi( PAR.Scan.Multivenc, 'Yes' )
                        PAR.Recon.Venc = abs( 100 * pi ./ ( repmat( PAR.Scan.kv( PAR.Parameter2Read.extr1( 1 ) + 1, : ), [ length( PAR.Parameter2Read.extr1( 2:end  ) ), 1 ] ) - PAR.Scan.kv( PAR.Parameter2Read.extr1( 2:end  ) + 1, : ) ) );
                        PAR.Recon.Venc( isinf( PAR.Recon.Venc ) ) = 0;
                    end
                end
            end
        end
        
        
        
        
        function CreateReconFlagCopy( PAR, a, b )
            
            
            if ~PAR.ReconFlags.initializing
                PAR.ReconFlags.PreSet = PAR.ReconFlags.Copy;
            end
        end
        function UpdateOversampling( PAR, a, b )
            
            if ~PAR.ReconFlags.initializing
                
                
                if PAR.ReconFlags.isoversampled( 1 ) ~= PAR.ReconFlags.isoversampledPreSet( 1 )
                    
                    if PAR.ReconFlags.isoversampled( 1 ) == 0
                        PAR.Encoding.WorkEncoding.XRange = cellfun( @( x, y )MRparameter.set_new_range( x, 1 / max( [ 1, y ] ) ), PAR.Encoding.WorkEncoding.XRange, PAR.Encoding.WorkEncoding.KxOversampling, 'UniformOutput', 0 );
                        PAR.UpdateCurFOV( [ 1 / max( [ 1, PAR.Encoding.WorkEncoding.KxOversampling{ 1, 1 } ] ), 1, 1 ] );
                        
                        
                        
                        
                        PAR.Encoding.WorkEncoding.KxOversampling = cellfun( @( x )x / x, PAR.Encoding.WorkEncoding.KxOversampling, 'UniformOutput', 0 );
                    else
                        PAR.Encoding.WorkEncoding.XRange = cellfun( @( x, y )MRparameter.set_new_range( x, max( [ 1, y ] ) ), PAR.Encoding.WorkEncoding.XRange, PAR.Encoding.WorkEncoding.KxOversamplingOrig, 'UniformOutput', 0 );
                        PAR.UpdateCurFOV( [ max( [ 1, PAR.Encoding.WorkEncoding.KxOversamplingOrig{ 1, 1 } ] ), 1, 1 ] );
                        
                        
                        
                        PAR.Encoding.WorkEncoding.KxOversampling = cellfun( @( x )x, PAR.Encoding.WorkEncoding.KxOversamplingOrig, 'UniformOutput', 0 );
                    end
                end
                
                
                if PAR.ReconFlags.isoversampled( 2 ) ~= PAR.ReconFlags.isoversampledPreSet( 2 )
                    
                    if PAR.ReconFlags.isoversampled( 2 ) == 0
                        PAR.Encoding.WorkEncoding.YRange = cellfun( @( x, y )MRparameter.set_new_range( x, 1 / max( [ 1, y ] ) ), PAR.Encoding.WorkEncoding.YRange, PAR.Encoding.WorkEncoding.KyOversampling, 'UniformOutput', 0 );
                        PAR.UpdateCurFOV( [ 1, 1 / max( [ 1, PAR.Encoding.WorkEncoding.KyOversampling{ 1, 1 } ] ), 1 ] );
                        PAR.Encoding.WorkEncoding.KyOversampling = cellfun( @( x )x / x, PAR.Encoding.WorkEncoding.KyOversampling, 'UniformOutput', 0 );
                    else
                        PAR.Encoding.WorkEncoding.YRange = cellfun( @( x, y )MRparameter.set_new_range( x, max( [ 1, y ] ) ), PAR.Encoding.WorkEncoding.YRange, PAR.Encoding.WorkEncoding.KyOversamplingOrig, 'UniformOutput', 0 );
                        PAR.UpdateCurFOV( [ 1, max( [ 1, PAR.Encoding.WorkEncoding.KyOversamplingOrig{ 1, 1 } ] ), 1 ] );
                        PAR.Encoding.WorkEncoding.KyOversampling = cellfun( @( x )x, PAR.Encoding.WorkEncoding.KyOversamplingOrig, 'UniformOutput', 0 );
                    end
                end
                
                
                if PAR.ReconFlags.isoversampled( 3 ) ~= PAR.ReconFlags.isoversampledPreSet( 3 )
                    
                    if PAR.ReconFlags.isoversampled( 3 ) == 0
                        PAR.Encoding.WorkEncoding.ZRange = cellfun( @( x, y )MRparameter.set_new_range( x, 1 / max( [ 1, y ] ) ), PAR.Encoding.WorkEncoding.ZRange, PAR.Encoding.WorkEncoding.KzOversampling, 'UniformOutput', 0 );
                        PAR.UpdateCurFOV( [ 1, 1, 1 / max( [ 1, PAR.Encoding.WorkEncoding.KzOversampling{ 1, 1 } ] ) ] );
                        PAR.Encoding.WorkEncoding.KzOversampling = cellfun( @( x )x / x, PAR.Encoding.WorkEncoding.KzOversampling, 'UniformOutput', 0 );
                    else
                        PAR.Encoding.WorkEncoding.ZRange = cellfun( @( x, y )MRparameter.set_new_range( x, max( [ 1, y ] ) ), PAR.Encoding.WorkEncoding.ZRange, PAR.Encoding.WorkEncoding.KzOversamplingOrig, 'UniformOutput', 0 );
                        PAR.UpdateCurFOV( [ 1, 1, max( [ 1, PAR.Encoding.WorkEncoding.KzOversamplingOrig{ 1, 1 } ] ) ] );
                        PAR.Encoding.WorkEncoding.KzOversampling = cellfun( @( x )x, PAR.Encoding.WorkEncoding.KzOversamplingOrig, 'UniformOutput', 0 );
                    end
                end
                
                PAR.ReconFlags.PreSet = [  ];
            end
        end
        function UpdateSENSE( PAR, a, b )
            
            if ~PAR.ReconFlags.initializing
                
                
                if PAR.ReconFlags.isunfolded ~= PAR.ReconFlags.isunfoldedPreSet
                    
                    if PAR.ReconFlags.isunfolded == 1
                        PAR.UpdateCurFOV( PAR.Scan.SENSEFactor );
                    else
                        PAR.UpdateCurFOV( 1 ./ PAR.Scan.SENSEFactor );
                    end
                end
                
                PAR.ReconFlags.PreSet = [  ];
            end
        end
        
        
        
        
        function InitReconPars( PAR )
            switch PAR.DataFormat
                case { 'Raw', 'ExportedRaw', 'ExportedCpx', 'Bruker' }
                    if strcmpi( PAR.Scan.FastImgMode, 'EPI' )
                        PAR.Recon.RingingFilterStrength = [ 0.75, 0.75, 0.75 ];
                        PAR.Recon.EPI2DCorr = 'no';
                    end
                    PAR.Recon.CoilCombination = 'sos';
                    if ~isempty( PAR.Scan.Venc )
                        PAR.Recon.Venc = max( abs( PAR.Scan.Venc ), [  ], 1 );
                        PAR.Recon.kv = PAR.Scan.kv;
                        if any( any( PAR.Scan.Venc ) ~= 0 )
                            PAR.Recon.CoilCombination = 'pc';
                            if strcmpi( PAR.Scan.Multivenc, 'yes' )
                                PAR.Recon.TKE = 'Yes';
                            end
                        end
                    end
                    if strcmpi( PAR.Scan.FastImgMode, 'EPI' ) || strcmpi( PAR.Scan.FastImgMode, 'TFEEPI' )
                        PAR.Recon.ImmediateAveraging = 'no';
                    end
            end
        end
        function SetArrayCompression( PAR, a, b )
            if strcmpi( PAR.Recon.ArrayCompression, 'yes' )
                
                virtual_coils = PAR.CalculateNrVirtualChannels;
                PAR.Recon.ACNrVirtualChannels = virtual_coils;
                
                s = sprintf( '\nWhen Array Compression is switched on the following corrections are performed immediately after data reading and can not be influenced by the user anymore:\n\nRandom Phase Correction\nDc Offset Correction\nPDA Correction\nMeasurement Phase Correction\n' );
                warning( 'MATLAB:MRecon', s );
            else
                PAR.Recon.ACNrVirtualChannels = [  ];
                PAR.Recon.ACMatrix = [  ];
            end
        end
        function SetACMatrix( PAR, a, b )
            if ~isempty( PAR.Recon.ACMatrix )
                if any( [ size( PAR.Recon.ACMatrix, 1 ), size( PAR.Recon.ACMatrix, 2 ), size( PAR.Recon.ACMatrix, 3 ) ] ...
                        ~= [ max( PAR.Recon.ACNrVirtualChannels ), length( PAR.Parameter2Read.chan ), length( PAR.Recon.ACNrVirtualChannels ) ] )
                    if isempty( PAR.Recon.ACNrVirtualChannels )
                        PAR.Recon.ACNrVirtualChannels = ceil( length( PAR.Parameter2Read.chan ) / 4 );
                    end
                    if ~isempty( PAR.Recon.ACMatrix ) || strcmpi( PAR.Recon.ArrayCompression, 'yes' )
                        PAR.ACCalculateMatrix( PAR.Recon.Sensitivities );
                        error( 'The Array Compression matrix has the wrong size. It should be a %d x %d x %d matrix', max( PAR.Recon.ACNrVirtualChannels ), length( PAR.Parameter2Read.chan ), length( PAR.Recon.ACNrVirtualChannels ) );
                    end
                end
            end
        end
        function SetACNrVirtualChannels( PAR, a, b )
            if PAR.Recon.ACNrVirtualChannels > length( PAR.Parameter2Read.chan )
                PAR.Recon.ACNrVirtualChannels = length( PAR.Parameter2Read.chan );
                error( 'Number of virtual channels can not exceed number of physical channels' );
            end
            if PAR.Recon.ACNrVirtualChannels < 1
                PAR.Recon.ACNrVirtualChannels = 1;
                error( 'The minimum number of virtual channels is 1' );
            end
            if strcmpi( PAR.Recon.ArrayCompression, 'yes' )
                virtual_coils = PAR.CalculateNrVirtualChannels;
                PAR.Recon.ACNrVirtualChannels = virtual_coils;
                PAR.ACCalculateMatrix( PAR.Recon.Sensitivities );
            end
        end
        function ACCalculateMatrix( PAR, MRsenseObject )
            
            if nargin == 1
                MRsenseObject = [  ];
            end
            
            
            data_ind = find( PAR.Labels.Index.typ == 1 & PAR.Labels.Index.ky == 0 & PAR.Labels.Index.kz == 0 );
            channel_groups = unique( PAR.Labels.Index.chan_grp( data_ind ) );
            
            Parameter2Read = PAR.Parameter2Read_Original.Copy;
            Parameter2Read.typ = 1;
            Parameter2Read.ky = 0;
            Parameter2Read.kz = 0;
            
            [ center_lines, data_ind ] = MRecon.ReadExportedRaw( PAR.Filename,  ...
                PAR.DataType, PAR.Labels, Parameter2Read,  ...
                Parameter2Read.typ, Parameter2Read.mix, Parameter2Read.echo, [ 0, 1 ], 0,  ...
                0, [  ], [  ] );
            
            mean_noise = MRecon.get_mean_noise( PAR.Filename, PAR.DataType, PAR.Labels );
            
            
            if ( isfield( PAR.Labels, 'FEARFactor' ) && PAR.Labels.FEARFactor > 0 )
                center_k = PAR.Encoding.KxRange( 1, 1 );
                radial_spiral = any( strcmpi( PAR.Scan.AcqMode, { 'radial', 'spiral' } ) ) || strcmpi( PAR.Gridder.Preset, 'radial' );
                
                if ( radial_spiral )
                    center_k = [  ];
                end
                
                center_lines = MRecon.fear_corr( center_lines( :, : ), PAR.Labels, data_ind, PAR.Labels.FEARFactor, center_k );
            else
                center_lines = MRecon.random_phase_corr( center_lines( :, : ), PAR.Labels, data_ind );
            end
            
            
            center_lines = MRecon.dc_offset_corr( center_lines( :, : ), mean_noise, PAR.Labels, PAR.Encoding.WorkEncoding.KxRange{ 1 }, data_ind );
            center_lines = MRecon.pda_corr( center_lines( :, : ), PAR.Labels, data_ind );
            center_lines = MRecon.meas_phase_corr( center_lines( :, : ), PAR.Labels, data_ind );
            
            if isfield( PAR.Labels.Index, 'chan_grp' )
                channel_groups = unique( PAR.Labels.Index.chan_grp( data_ind ) );
            else
                channel_groups = 0;
            end
            
            
            for i = 1:length( channel_groups )
                ucoils = unique( PAR.Labels.Index.chan( data_ind ) );
                nr_coils = length( ucoils );
                if isempty( PAR.Recon.ACNrVirtualChannels )
                    PAR.Recon.ACNrVirtualChannels( i ) = ceil( nr_coils / 4 );
                else
                    if length( PAR.Recon.ACNrVirtualChannels ) ~= length( channel_groups )
                        PAR.Recon.ACNrVirtualChannels( i ) = PAR.Recon.ACNrVirtualChannels( end  );
                    end
                    if PAR.Recon.ACNrVirtualChannels( i ) > nr_coils
                        PAR.Recon.ACNrVirtualChannels( i ) = nr_coils;
                    end
                end
            end
            A = zeros( max( PAR.Recon.ACNrVirtualChannels ), length( PAR.Parameter2Read.chan ), length( channel_groups ) ) + NaN;
            
            for i = 1:length( channel_groups )
                if isfield( PAR.Labels.Index, 'chan_grp' )
                    ind = find( PAR.Labels.Index.chan_grp( data_ind ) == channel_groups( i ) );
                else
                    ind = 1:length( data_ind );
                end
                
                [ ucoils, temp, indc ] = unique( PAR.Labels.Index.chan( data_ind( ind ) ) );
                nr_coils = length( ucoils );
                nr_averages = length( ind ) / nr_coils;
                
                if nr_coils < PAR.Recon.ACNrVirtualChannels( i )
                    return
                end
                
                try
                    cur_center_lines = MRsenseObject.ReformatedCoilData;
                    cur_center_lines = permute( cur_center_lines, [ 4, 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13 ] );
                    cur_center_lines = cur_center_lines( :, : );
                catch
                    cur_center_lines = center_lines( :, ind );
                    cur_center_lines = reshape( cur_center_lines, size( cur_center_lines, 1 ), nr_coils, nr_averages );
                    
                    cur_center_lines = mean( cur_center_lines, 3 );
                    cur_center_lines = MRecon.k2i( cur_center_lines, 1 );
                    cur_center_lines = permute( cur_center_lines, [ 2, 1 ] );
                end
                
                if size( cur_center_lines, 2 ) > 32768
                    step = round( size( cur_center_lines, 2 ) / 32768 );
                else
                    step = 1;
                end
                
                S_hat = zeros( nr_coils, nr_coils );
                for j = 1:step:size( cur_center_lines, 2 )
                    S_hat = S_hat + cur_center_lines( :, j ) * pinv( cur_center_lines( :, j ) );
                end
                [ u, v, w ] = svd( S_hat );
                A( 1:PAR.Recon.ACNrVirtualChannels( i ), 1:nr_coils, i ) = u( :, 1:PAR.Recon.ACNrVirtualChannels( i ) )';
            end
            PAR.Recon.ACMatrix = A;
        end
        function virtual_coils = CalculateNrVirtualChannels( PAR )
            
            center_lines_full = PAR.Labels.Index.typ == 1 &  ...
                PAR.Labels.Index.ky == 0 & PAR.Labels.Index.kz == 0 &  ...
                ismember( PAR.Labels.Index.chan, PAR.Parameter2Read.chan );
            
            if isfield( PAR.Labels.Index, 'chan_grp' )
                channel_groups = unique( PAR.Labels.Index.chan_grp( center_lines_full ) );
            else
                channel_groups = 0;
            end
            virtual_coils = PAR.Recon.ACNrVirtualChannels;
            for i = 1:length( channel_groups )
                if isfield( PAR.Labels.Index, 'chan_grp' )
                    center_lines0 = center_lines_full & PAR.Labels.Index.chan_grp == channel_groups( i );
                else
                    center_lines0 = center_lines_full;
                end
                ucoils = unique( PAR.Labels.Index.chan( center_lines0 ) );
                nr_coils = length( ucoils );
                
                if isempty( PAR.Recon.ACNrVirtualChannels )
                    virtual_coils( i ) = ceil( nr_coils / 4 );
                else
                    if length( PAR.Recon.ACNrVirtualChannels ) ~= length( channel_groups )
                        virtual_coils( i ) = PAR.Recon.ACNrVirtualChannels( end  );
                    end
                    if virtual_coils( i ) > nr_coils
                        virtual_coils( i ) = nr_coils;
                    end
                end
            end
        end
        function DeleteEPICorrData( PAR, a, b )
            PAR.EPICorrData.Reset;
        end
        function UpdateACMatrix( PAR, a, b )
            if strcmpi( PAR.Recon.ArrayCompression, 'yes' )
                PAR.ACCalculateMatrix( PAR.Recon.Sensitivities );
            end
        end
        function S1 = CompressSensitivities( PAR, S )
            
            
            S1 = S.Copy;
            if strcmpi( PAR.Recon.ArrayCompression, 'yes' )
                sens_image = S.Sensitivity;
                coil_ref = S.ReformatedCoilData;
                psi = S.Psi;
                cur_nr_chans = size( S.Sensitivity, 4 );
                for ac_in = 1:size( PAR.Recon.ACMatrix, 3 )
                    row_ind = min( [ size( PAR.Recon.ACMatrix, 1 ), find( isnan( PAR.Recon.ACMatrix( :, 1, ac_in ) ), 1 ) - 1 ] );
                    col_ind = min( [ size( PAR.Recon.ACMatrix, 2 ), find( isnan( PAR.Recon.ACMatrix( 1, :, ac_in ) ), 1 ) - 1 ] );
                    A = PAR.Recon.ACMatrix( 1:row_ind, 1:col_ind, ac_in );
                    
                    if size( A, 2 ) ~= cur_nr_chans
                        continue
                    end
                    sens_image = permute( sens_image, [ 4, 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13 ] );
                    coil_ref = permute( coil_ref, [ 4, 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13 ] );
                    siz = size( sens_image );siz( 1 ) = size( A, 1 );
                    sens_image = A * sens_image( :, : );
                    coil_ref = A * coil_ref( :, : );
                    sens_image = reshape( sens_image, siz );
                    coil_ref = reshape( coil_ref, siz );
                    sens_image = permute( sens_image, [ 2, 3, 4, 1, 5, 6, 7, 8, 9, 10, 11, 12, 13 ] );
                    coil_ref = permute( coil_ref, [ 2, 3, 4, 1, 5, 6, 7, 8, 9, 10, 11, 12, 13 ] );
                    psi = A * psi * A';
                    
                    S1.Sensitivity = sens_image;
                    S1.ReformatedCoilData = coil_ref;
                    S1.Psi = psi;
                end
            end
        end
        
        
        
        
        function InitScanPars( PAR )
            try
                
                PAR.Scan.AcqMode = 'Cartesian';
                
                switch PAR.DataFormat
                    case { 'Raw', 'ExportedRaw', 'ExportedCpx' }
                        stacks = [  ];
                        nr_stacks = [  ];
                        if isfield( PAR.Labels, 'StackIndex' )
                            stacks = unique( PAR.Labels.StackIndex );
                            nr_stacks = length( stacks );
                        end
                        
                        if isfield( PAR.Labels, 'FieldStrength' )
                            PAR.Scan.FieldStrength = PAR.Labels.FieldStrength / 1000;
                        end
                        if isfield( PAR.Labels, 'ScanMode' )
                            PAR.Scan.ScanMode = PAR.Labels.ScanMode;
                        end
                        if isfield( PAR.Labels, 'AcquisitionMode' )
                            PAR.Scan.AcqMode = PAR.Labels.AcquisitionMode;
                        end
                        if isfield( PAR.Labels, 'AcquisitionMode' )
                            PAR.Scan.FastImgMode = PAR.Labels.FastImagingMode;
                        end
                        if isfield( PAR.Labels, 'RepetitionTime' )
                            PAR.Scan.TR = PAR.Labels.RepetitionTime;
                        end
                        if isfield( PAR.Labels, 'FlipAngle' )
                            PAR.Scan.FlipAngle = PAR.Labels.FlipAngle;
                        end
                        
                        if isfield( PAR.Labels, 'UTE' )
                            PAR.Scan.UTE = PAR.Labels.UTE;
                        end
                        if isfield( PAR.Labels, 'KooshBall' )
                            PAR.Scan.KooshBall = PAR.Labels.KooshBall;
                        end
                        
                        PAR.Scan.Stacks = nr_stacks;
                        if ~isempty( stacks )
                            for i = 1:nr_stacks
                                if ~strcmpi( PAR.Scan.ScanMode, '3D' )
                                    PAR.Scan.ImagesPerStack( i, 1 ) = length( find( PAR.Labels.StackIndex == stacks( i ) ) );
                                else
                                    PAR.Scan.ImagesPerStack( i, 1 ) = PAR.Encoding.ZReconRes( 1 );
                                end
                            end
                        end
                        
                        if isfield( PAR.Labels, 'MPSOffcentres' )
                            PAR.Scan.PatientPosition = PAR.Labels.PatientPosition;
                            PAR.Scan.PatientOrientation = PAR.Labels.PatientOrientation;
                            PAR.Scan.Technique = PAR.Labels.ScanTechnique;
                            PAR.Scan.SliceGap = PAR.Labels.SliceGaps;
                            if ~isempty( stacks )
                                for i = 1:nr_stacks
                                    PAR.Scan.MPSOffcentres( i, : ) = mean( PAR.Labels.MPSOffcentres( PAR.Labels.StackIndex == stacks( i ), : ), 1 );
                                    if isfield( PAR.Labels, 'MPSOffcentresMM' )
                                        PAR.Scan.MPSOffcentresMM( i, : ) = mean( PAR.Labels.MPSOffcentresMM( PAR.Labels.StackIndex == stacks( i ), : ), 1 );
                                    end
                                end
                            else
                                PAR.Scan.MPSOffcentres = mean( PAR.Labels.MPSOffcentres );
                                if isfield( PAR.Labels, 'MPSOffcentresMM' )
                                    PAR.Scan.MPSOffcentresMM = mean( PAR.Labels.MPSOffcentresMM );
                                end
                            end
                            
                            if isfield( PAR.Labels, 'TE' )
                                PAR.Scan.TE = PAR.Labels.TE( 1:PAR.Labels.NumberOfEchoes );
                            end
                            PAR.Scan.WaterFatShiftPix = PAR.Labels.WFS;
                            if PAR.Labels.FlowComp
                                PAR.Scan.FlowComp = 'yes';
                            else
                                PAR.Scan.FlowComp = 'no';
                            end
                            
                            if ( isfield( PAR.Labels, 'Multivenc' ) &&  ...
                                    ~isempty( PAR.Labels.Multivenc ) &&  ...
                                    PAR.Labels.Multivenc( 1 ) > 0 &&  ...
                                    ~strcmpi( PAR.Labels.PCAcqType, 'Hadamard' ) )
                                
                                for i = 0:( PAR.Labels.Multivenc( 1 ) - 1 )
                                    PAR.Scan.kv( i + 1, 1 ) = PAR.Labels.Multivenc( 2 + i * 3 );
                                    if ( abs( PAR.Scan.kv( i + 1, 1 ) ) < 1e-3 )PAR.Scan.kv( i + 1, 1 ) = 0;end
                                    PAR.Scan.kv( i + 1, 2 ) = PAR.Labels.Multivenc( 3 + i * 3 );
                                    if ( abs( PAR.Scan.kv( i + 1, 2 ) ) < 1e-3 )PAR.Scan.kv( i + 1, 2 ) = 0;end
                                    PAR.Scan.kv( i + 1, 3 ) = PAR.Labels.Multivenc( 4 + i * 3 );
                                    if ( abs( PAR.Scan.kv( i + 1, 3 ) ) < 1e-3 )PAR.Scan.kv( i + 1, 3 ) = 0;end
                                end
                                
                                PAR.Scan.Venc = 100 * pi ./ ( repmat( PAR.Scan.kv( 1, : ), [ size( PAR.Scan.kv, 1 ) - 1, 1 ] ) - PAR.Scan.kv( 2:end , : ) );
                                PAR.Scan.Venc( find( isinf( PAR.Scan.Venc ) ) ) = 0;
                                if ( any( sum( PAR.Scan.Venc ~= 0, 1 ) > 1 ) )
                                    PAR.Scan.Multivenc = 'Yes';
                                else
                                    PAR.Scan.Multivenc = 'No';
                                end
                            else
                                PAR.Scan.Venc = PAR.Labels.Venc;
                                PAR.Scan.Multivenc = 'No';
                            end
                            PAR.Scan.EPIFactor = PAR.Labels.EPIFactor;
                            if PAR.Labels.SPIR
                                PAR.Scan.SPIR = 'yes';
                            else
                                PAR.Scan.SPIR = 'no';
                            end
                            if PAR.Labels.MTC
                                PAR.Scan.MTC = 'yes';
                            else
                                PAR.Scan.MTC = 'no';
                            end
                            if PAR.Labels.Diffusion
                                PAR.Scan.Diffusion = 'yes';
                            else
                                PAR.Scan.Diffusion = 'no';
                            end
                        end
                        
                        if isfield( PAR.Labels, 'Offcentre' )
                            if ~isempty( stacks )
                                for i = 1:nr_stacks
                                    PAR.Scan.Offcentre( i, : ) = mean( PAR.Labels.Offcentre( PAR.Labels.StackIndex == stacks( i ), : ), 1 );
                                end
                            else
                                PAR.Scan.Offcentre = mean( PAR.Labels.Offcentre, 1 );
                            end
                            PAR.Scan.Offcentre = PAR.Scan.Offcentre( :, [ 1, 3, 2 ] );
                        end
                        if isfield( PAR.Labels, 'Angulation' )
                            if ~isempty( stacks )
                                for i = 1:nr_stacks
                                    PAR.Scan.Angulation( i, : ) = mean( PAR.Labels.Angulation( PAR.Labels.StackIndex == stacks( i ), : ), 1 );
                                end
                            else
                                PAR.Scan.Angulation = mean( PAR.Labels.Angulation, 1 );
                            end
                            PAR.Scan.Angulation = PAR.Scan.Angulation( :, [ 1, 3, 2 ] );
                        end
                        if isfield( PAR.Labels, 'SENSEFactor' )
                            PAR.Scan.SENSEFactor = PAR.Labels.SENSEFactor;
                        end
                        if isfield( PAR.Labels, 'KtFactor' )
                            PAR.Scan.KtFactor = PAR.Labels.KtFactor;
                        end
                        if isfield( PAR.Labels, 'Kt' )
                            PAR.Scan.Kt = PAR.Labels.Kt;
                        end
                        
                        if isfield( PAR.Labels, 'Orientation' )
                            if ~isempty( stacks )
                                for i = 1:nr_stacks
                                    PAR.Scan.Orientation( i, : ) = PAR.Labels.Orientation( find( PAR.Labels.StackIndex == stacks( i ), 1 ), : );
                                end
                                PAR.Scan.Orientation = char( PAR.Scan.Orientation );
                            else
                                PAR.Scan.Orientation = PAR.Labels.Orientation;
                            end
                        end
                        
                        if isfield( PAR.Labels, 'FoldOverDir' )
                            if ~isempty( stacks )
                                for i = 1:nr_stacks
                                    PAR.Scan.FoldOverDir( i, : ) = PAR.Labels.FoldOverDir( find( PAR.Labels.StackIndex == stacks( i ), 1 ), : );
                                end
                                PAR.Scan.FoldOverDir = char( PAR.Scan.FoldOverDir );
                            else
                                PAR.Scan.FoldOverDir = PAR.Labels.FoldOverDir;
                            end
                        end
                        
                        if isfield( PAR.Labels, 'FatShiftDir' )
                            if ~isempty( stacks )
                                for i = 1:nr_stacks
                                    PAR.Scan.FatShiftDir( i, : ) = PAR.Labels.FatShiftDir( find( PAR.Labels.StackIndex == stacks( i ), 1 ), : );
                                end
                                PAR.Scan.FatShiftDir = char( PAR.Scan.FatShiftDir );
                            else
                                PAR.Scan.FatShiftDir = PAR.Labels.FatShiftDir;
                            end
                        end
                        
                        for i = 1:size( PAR.Scan.FoldOverDir, 1 )
                            if isempty( PAR.Scan.PatientPosition )
                                pat_pos = 'HeadFirst';
                            else
                                pat_pos = PAR.Scan.PatientPosition;
                            end
                            if isempty( PAR.Scan.PatientOrientation )
                                pat_ori = 'Supine';
                            else
                                pat_ori = PAR.Scan.PatientOrientation;
                            end
                            
                            if strcmpi( PAR.Scan.KooshBall, 'no' )
                                mode = PAR.Scan.AcqMode;
                            else
                                mode = 'Kooshball';
                            end
                            [ PAR.Scan.MPS( i, : ), PAR.Scan.xyz( i, : ), PAR.Scan.REC( i, : ) ] = MRparameter.get_coordinate_systems( pat_pos, pat_ori, PAR.Scan.Orientation( i, : ), PAR.Scan.FoldOverDir( i, : ), PAR.Scan.FatShiftDir( i, : ), mode );
                            PAR.Scan.ijk( i, : ) = PAR.Scan.MPS( i, : );
                        end
                        PAR.Scan.MPS = char( PAR.Scan.MPS );
                        PAR.Scan.xyz = char( PAR.Scan.xyz );
                        PAR.Scan.ijk = char( PAR.Scan.ijk );
                        PAR.Scan.REC = char( PAR.Scan.REC );
                        
                        if isfield( PAR.Labels, 'FOV' )
                            if ~isempty( stacks )
                                for i = 1:nr_stacks
                                    P = MRparameter.get_coord_transformation( PAR.Scan.MPS( i, : ), 'AP FH RL' );
                                    PAR.Scan.FOV( i, : ) = abs( P * PAR.Labels.FOV( i, : )' )';
                                end
                            else
                                PAR.Scan.FOV = PAR.Labels.FOV;
                            end
                            PAR.InitCurFOV;
                        end
                        
                        if isfield( PAR.Labels, 'VoxelSizes' )
                            PAR.Scan.RecVoxelSize = PAR.Labels.VoxelSizes;
                        end
                        if isfield( PAR.Labels, 'FOV' ) && isfield( PAR.Labels, 'Samples' )
                            if ~strcmpi( PAR.Scan.ScanMode, '3D' )
                                fov = PAR.Labels.FOV;
                                if isfield( PAR.Labels, 'Thicknesses' )
                                    fov( :, 3 ) = PAR.Labels.Thicknesses( 1, 3 );
                                end
                            else
                                fov = PAR.Labels.FOV;
                            end
                            
                            if strcmpi( PAR.Scan.AcqMode, 'Radial' )
                                samples = PAR.Labels.Samples;
                                if length( samples ) > 1
                                    samples( 1:2 ) = PAR.Labels.Samples( 1 );
                                end
                                PAR.Scan.AcqVoxelSize = fov ./ samples;
                            else
                                PAR.Scan.AcqVoxelSize = fov ./ PAR.Labels.Samples;
                            end
                            PAR.Scan.Samples = PAR.Labels.Samples;
                        end
                        
                        if isfield( PAR.Labels, 'TFEfactor' )
                            PAR.Scan.TFEfactor = PAR.Labels.TFEfactor;
                        end
                        
                        if ~isempty( PAR.Scan.MPSOffcentres )
                            for i = 1:size( PAR.Scan.MPSOffcentres, 1 )
                                if isfield( PAR.Labels, 'MPSOffcentresMM' )
                                    from_system = 'MPS';
                                    offs = PAR.Scan.MPSOffcentresMM( i, : );
                                else
                                    from_system = 'MPSpix';
                                    offs = PAR.Scan.MPSOffcentres( i, : );
                                end
                                
                                
                                
                                
                                if ~strcmpi( PAR.Scan.ScanMode, '3D' )
                                    offs( :, 3 ) =  - offs( :, 3 );
                                end
                                
                                isocentreRAF = PAR.Transform( offs, from_system, 'RAF', i, [  ], [  ], [  ], [  ], [  ] );
                                
                                P = MRparameter.get_coord_transformation( 'RL AP FH', 'AP FH RL' );
                                P1 = MRparameter.get_coord_transformation( 'AP FH RL', PAR.Scan.xyz( i, : ) );
                                isocentreRAF = P * isocentreRAF;
                                PAR.Scan.xyzOffcentres( i, : ) = ( P1 * ( PAR.Scan.Offcentre( i, : )' - isocentreRAF ) )';
                                
                            end
                        end
                        
                        
                        
                        
                        
                        if isfield( PAR.Labels, 'Samples' ) && isfield( PAR.Labels, 'Spectro' ) && PAR.Labels.Spectro
                            cur_sample_size = PAR.DataType.SampleSizeBytes( find( PAR.DataType.DataTypeNum == PAR.Labels.Index.format( find( PAR.Labels.Index.typ == 1, 1 ) ) ) );
                            PAR.Labels.Samples( :, 1 ) = PAR.Encoding.DataSizeByte( 1 ) / cur_sample_size / 2;
                            if exist( 'fov', 'var' )
                                PAR.Scan.AcqVoxelSize( 1:2 ) = fov( 1:2 ) ./ PAR.Labels.Samples( 2:3 );
                                PAR.Scan.AcqVoxelSize( 3 ) = fov( 3 );
                            end
                        end
                        
                        if isfield( PAR.Labels, 'PartialFourierFactors' )
                            if PAR.Labels.PartialFourierFactors( 1, 1 ) < 1
                                PAR.Scan.PartialEcho = 'yes';
                            else
                                PAR.Scan.PartialEcho = 'no';
                            end
                            PAR.Scan.HalfScanFactors = PAR.Labels.PartialFourierFactors( 1, 2:3 );
                        end
                        
                        if isfield( PAR.Labels, 'ScanType' )
                            try
                                PAR.Scan.ScanType = PAR.Labels.ScanType;
                                PAR.Scan.AngioMode = PAR.Labels.AngioMode;
                                PAR.Scan.QuantFlow = PAR.Labels.QuantFlow;
                                PAR.Scan.PCAcqType = PAR.Labels.PCAcqType;
                                PAR.Scan.Date = [ PAR.Labels.Date, '  ', PAR.Labels.Time ];
                                PAR.Scan.ScanDuration = PAR.Labels.ScanDuration;
                            end
                        end
                        
                        if isfield( PAR.Labels, 'Spectro' ) && PAR.Labels.Spectro
                            PAR.Scan.ScanType = 'Spectro';
                        end
                        
                        if isfield( PAR.Labels, 'ASLType' )
                            PAR.Scan.ASLType = PAR.Labels.ASLType;
                            PAR.Scan.ASLNolabelTypes = PAR.Labels.ASLNolabelTypes;
                        end
                        
                        
                    case 'Rec'
                        PAR.Scan.Stacks = 1;
                        if ~isnumeric( PAR.Labels.ScanMode )
                            PAR.Scan.ScanMode = strtrim( PAR.Labels.ScanMode );
                            PAR.Scan.FoldOverDir = strtrim( PAR.Labels.PreparationDirection );
                            switch PAR.Scan.FoldOverDir
                                case 'Anterior-Posterior'
                                    PAR.Scan.FoldOverDir = 'AP';
                                case 'Right-Left'
                                    PAR.Scan.FoldOverDir = 'RL';
                                case 'Feet-Head'
                                    PAR.Scan.FoldOverDir = 'FH';
                            end
                        else
                            PAR.Scan.ScanMode = [  ];
                            PAR.Scan.FoldOverDir = [  ];
                        end
                        PAR.Scan.FastImgMode = strtrim( PAR.Labels.Technique );
                        PAR.Scan.AcqMode = [  ];
                        PAR.Scan.UTE = [  ];
                        PAR.Scan.KooshBall = [  ];
                        PAR.Scan.TE = unique( PAR.Labels.ImageInformation.EchoTime );
                        PAR.Scan.FlipAngle = unique( PAR.Labels.ImageInformation.ImageFlipAngle );
                        if ~isempty( PAR.Scan.ScanMode ) && strcmpi( strtrim( PAR.Scan.ScanMode ), '3D' )
                            PAR.Scan.RecVoxelSize = unique( [ PAR.Labels.ImageInformation.PixelSpacing, PAR.Labels.ImageInformation.SliceThickness + PAR.Labels.ImageInformation.SliceGap ], 'rows' );
                        else
                            PAR.Scan.RecVoxelSize = unique( [ PAR.Labels.ImageInformation.PixelSpacing, PAR.Labels.ImageInformation.SliceThickness ], 'rows' );
                        end
                        PAR.Scan.FatShiftDir = [  ];
                        PAR.Scan.SENSEFactor = [  ];
                        try
                            PAR.Scan.Venc = PAR.Labels.PhaseEncodingVelocity;
                        end
                        
                        if isfield( PAR.Labels.ImageInformation, 'Slice' )
                            PAR.Scan.AcqNo = PAR.Labels.AquisitionNumber;
                            PAR.Scan.TFEfactor = double( unique( PAR.Labels.ImageInformation.TURBOFactor ) );
                            PAR.Scan.TR = double( PAR.Labels.RepetitionTimes );
                            PAR.Scan.FOV = double( [ PAR.Labels.FOVAP, PAR.Labels.FOVFH, PAR.Labels.FOVRL ] );
                            PAR.Scan.AcqVoxelSize = [ max( PAR.Scan.FOV ) ./ [ double( PAR.Labels.ScanResolutionX ), double( PAR.Labels.ScanResolutionY ) ], PAR.Labels.ImageInformation.SliceThickness( 1 ) ];
                            PAR.Scan.Samples = [ double( PAR.Labels.ScanResolutionX ), double( PAR.Labels.ScanResolutionY ) ];
                            PAR.Scan.Offcentre = double( unique( [ PAR.Labels.ImageInformation.OffcenterAP,  ...
                                PAR.Labels.ImageInformation.OffcenterFH,  ...
                                PAR.Labels.ImageInformation.OffcenterRL ], 'rows' ) );
                            PAR.Scan.Angulation = double( unique( [ PAR.Labels.ImageInformation.AngulationAP,  ...
                                PAR.Labels.ImageInformation.AngulationFH,  ...
                                PAR.Labels.ImageInformation.AngulationRL ], 'rows' ) );
                            PAR.Scan.Orientation = unique( upper( PAR.Labels.ImageInformation.SliceOrientation( :, 1:3 ) ), 'rows' );
                        else
                            if isfield( PAR.Labels.ImageInformation, 'TurboFactor' )
                                PAR.Scan.TFEfactor = unique( PAR.Labels.ImageInformation.TurboFactor );
                            elseif isfield( PAR.Labels.ImageInformation, 'TURBOFactor' )
                                PAR.Scan.TFEfactor = unique( PAR.Labels.ImageInformation.TURBOFactor );
                            end
                            PAR.Scan.AcqNo = PAR.Labels.AcquisitionNr;
                            PAR.Scan.TR = PAR.Labels.RepetitionTime;
                            PAR.Scan.FOV = PAR.Labels.FOV;
                            PAR.Scan.AcqVoxelSize = [ max( PAR.Scan.FOV ) ./ PAR.Labels.ScanResolution, PAR.Labels.ImageInformation.SliceThickness( 1 ) ];
                            PAR.Scan.Samples = PAR.Labels.ScanResolution;
                            PAR.Scan.Offcentre = PAR.Labels.OffCentreMidslice;
                            PAR.Scan.Angulation = PAR.Labels.AngulationMidslice;
                            temp = unique( PAR.Labels.ImageInformation.SliceOrientation, 'rows' );
                            PAR.Scan.Orientation = 'TRA';
                            for i = 1:size( temp, 1 )
                                switch temp( i )
                                    case 1
                                        PAR.Scan.Orientation( i, : ) = 'TRA';
                                    case 2
                                        PAR.Scan.Orientation( i, : ) = 'SAG';
                                    case 3
                                        PAR.Scan.Orientation( i, : ) = 'COR';
                                end
                            end
                            PAR.Scan.SliceGap = unique( PAR.Labels.ImageInformation.SliceGap );
                        end
                        
                        if isfield( PAR.Labels, 'PatientPosition' )
                            patpos = strtrim( PAR.Labels.PatientPosition );
                            switch patpos( 1:2 )
                                case 'HF'
                                    PAR.Scan.PatientPosition = 'HeadFirst';
                                case 'FF'
                                    PAR.Scan.PatientPosition = 'FeetFirst';
                                otherwise
                                    PAR.Scan.PatientPosition = 'HeadFirst';
                            end
                            
                            switch patpos( 3:end  )
                                case 'S'
                                    PAR.Scan.PatientOrientation = 'Supine';
                                case 'P'
                                    PAR.Scan.PatientOrientation = 'Prone';
                                case 'DR'
                                    PAR.Scan.PatientOrientation = 'Right';
                                case 'DL'
                                    PAR.Scan.PatientOrientation = 'Left';
                                otherwise
                                    PAR.Scan.PatientOrientation = 'Supine';
                            end
                            
                            [ PAR.Scan.MPS, PAR.Scan.xyz, PAR.Scan.REC ] = MRparameter.get_coordinate_systems( PAR.Scan.PatientPosition, PAR.Scan.PatientOrientation, PAR.Scan.Orientation( 1, : ), PAR.Scan.FoldOverDir, '', 'Cartesian' );
                            PAR.Scan.ijk = PAR.Scan.REC;
                            P1 = MRparameter.get_coord_transformation( 'AP FH RL', PAR.Scan.xyz );
                            PAR.Scan.xyzOffcentres = ( P1 * PAR.Scan.Offcentre' )';
                            PAR.InitCurFOV;
                        end
                    case 'Bruker'
                        PAR.Scan.ScanDuration = PAR.Bruker.PVM.ScanTime / 1000;
                        PAR.Scan.ScanMode = PAR.Labels.ScanMode;
                        PAR.Scan.AcqVoxelSize = PAR.Labels.VoxelSizes;
                        PAR.Scan.FOV = PAR.Labels.FOV;
                        PAR.Scan.FlipAngle = PAR.Labels.FlipAngle;
                        PAR.Scan.TE( 1 ) = PAR.Bruker.ACQ.echo_time;
                        if ( isfield( PAR.Bruker.PVM, 'NEchoImages' ) )
                            for i = 2:PAR.Bruker.PVM.NEchoImages
                                PAR.Scan.TE( i ) = PAR.Bruker.ACQ.echo_time + ( i - 1 ) * Parameter.Bruker.EchoTimeIncr;
                            end
                        end
                        PAR.Scan.TR = PAR.Labels.RepetitionTime;
                        PAR.Scan.Technique = PAR.Bruker.ACQ.method;
                        PAR.Scan.ProtocolName = PAR.Bruker.ACQ.protocol_name;
                        PAR.Scan.SliceGap = PAR.Labels.SliceGaps;
                        PAR.Scan.UTE = PAR.Labels.UTE;
                        PAR.Scan.KooshBall = PAR.Labels.KooshBall;
                        
                        PAR.Scan.Angulation = PAR.Labels.Angulation;
                        PAR.Scan.Offcentre = PAR.Labels.Offcentre;
                        PAR.Scan.FoldOverDir = strrep( PAR.Labels.FoldOverDir, '_', '' );
                        switch ( PAR.Scan.FoldOverDir )
                            case 'LR'
                                PAR.Scan.FoldOverDir = 'RL';
                            case 'PA'
                                PAR.Scan.FoldOverDir = 'AP';
                            case 'HF'
                                PAR.Scan.FoldOverDir = 'FH';
                        end
                        
                        PAR.Scan.Stacks = PAR.Bruker.Stacks;
                        
                        patpos = strtrim( PAR.Bruker.ACQ.patient_pos );
                        if ~isempty( strfind( lower( patpos ), 'head' ) )
                            PAR.Scan.PatientPosition = 'HeadFirst';
                        elseif ~isempty( strfind( lower( patpos ), 'feet' ) )
                            PAR.Scan.PatientPosition = 'FeetFirst';
                        else
                            PAR.Scan.PatientPosition = 'HeadFirst';
                        end
                        
                        if ~isempty( strfind( lower( patpos ), 'supine' ) )
                            PAR.Scan.PatientOrientation = 'Supine';
                        elseif ~isempty( strfind( lower( patpos ), 'prone' ) )
                            PAR.Scan.PatientOrientation = 'Prone';
                        elseif ~isempty( strfind( lower( patpos ), 'right' ) )
                            PAR.Scan.PatientOrientation = 'Right';
                        elseif ~isempty( strfind( lower( patpos ), 'left' ) )
                            PAR.Scan.PatientOrientation = 'Left';
                        else
                            PAR.Scan.PatientOrientation = 'Supine';
                        end
                        
                        switch ( PAR.Bruker.PVM.SPackArrSliceOrient )
                            case 'axial'
                                PAR.Scan.Orientation = 'TRA';
                            case 'coronal'
                                PAR.Scan.Orientation = 'COR';
                            case 'sagittal'
                                PAR.Scan.Orientation = 'SAG';
                        end
                        
                        PAR.Recon.Venc = PAR.Scan.Venc;
                        
                        
                        PAR.Scan.TFEfactor = 1;
                        
                        [ PAR.Scan.MPS, PAR.Scan.xyz, PAR.Scan.REC ] = MRparameter.get_coordinate_systems( PAR.Scan.PatientPosition, PAR.Scan.PatientOrientation, PAR.Scan.Orientation( 1, : ), PAR.Scan.FoldOverDir, '', 'Cartesian' );
                        PAR.Scan.ijk = PAR.Scan.REC;
                end
            end
        end
        function SetGridderPreset( PAR, a, b )
            switch PAR.DataFormat
                case { 'Raw', 'ExportedRaw' }
                    switch PAR.Scan.AcqMode
                        case { 'Radial', 'radial' }
                            PAR.Gridder.Preset = 'Radial';
                        case { 'Spiral', 'spiral' }
                            PAR.Gridder.Preset = 'Spiral';
                        otherwise
                            PAR.Gridder.Preset = 'None';
                    end
            end
        end
        function InitCurFOV( PAR, Location )
            if nargin == 1
                Location = 'ReadParameter';
            end
            switch PAR.DataFormat
                case { 'Raw', 'ExportedRaw' }
                    if strcmpi( Location, 'ReadData' )
                        if isfield( PAR.Labels, 'FOV' )
                            PAR.Scan.curFOV = bsxfun( @times, PAR.Labels.FOV, [ max( [ 1, PAR.Encoding.WorkEncoding.KxOversampling{ 1, 1 } ] ), max( [ 1, PAR.Encoding.WorkEncoding.KyOversampling{ 1, 1 } ] ), max( [ 1, PAR.Encoding.WorkEncoding.KzOversampling{ 1, 1 } ] ) ] );
                        end
                    else
                        if isfield( PAR.Labels, 'FOV' )
                            PAR.Scan.curFOV = PAR.Labels.FOV;
                            PAR.Scan.curFOV( :, 2:3 ) = PAR.Scan.curFOV( :, 2:3 ) .* repmat( [ max( [ 1, max( PAR.Encoding.KyOversampling ) ] ), max( [ 1, max( PAR.Encoding.KzOversampling ) ] ) ], [ size( PAR.Scan.curFOV, 1 ), 1 ] );
                            PAR.Scan.curFOV = PAR.Scan.curFOV .* PAR.Scan.SENSEFactor;
                        end
                    end
                case 'Rec'
                    if isfield( PAR.Labels, 'FOV' )
                        P = MRparameter.get_coord_transformation( 'AP FH RL', PAR.Scan.MPS( 1, : ) );
                        PAR.Scan.curFOV = abs( P * PAR.Labels.FOV( 1, : )' )';
                        PAR.Scan.curFOV( 1:2 ) = max( PAR.Scan.curFOV( 1:2 ) );
                    end
            end
        end
        function UpdateCurFOV( PAR, factor, transformation, fov_rows )
            if nargin < 4
                fov_rows = 1:size( PAR.Scan.curFOV, 1 );
            end
            if ~isempty( PAR.Scan.curFOV )
                if nargin == 1 || isempty( factor )
                    factor = 1;
                end
                
                if length( factor ) == 1
                    PAR.Scan.curFOV( fov_rows, : ) = PAR.Scan.curFOV( fov_rows, : ) .* factor;
                else
                    PAR.Scan.curFOV( fov_rows, : ) = bsxfun( @times, PAR.Scan.curFOV( fov_rows, : ), factor );
                end
                
                if nargin >= 3
                    for i = 1:length( fov_rows )
                        PAR.Scan.curFOV( fov_rows( i ), : ) = abs( transformation * PAR.Scan.curFOV( fov_rows( i ), : )' )';
                    end
                end
            end
        end
        function UpdateCoordinateSystem( PAR, a, b )
            if PAR.Parameter2Read.EnableRangeCheck
                try
                    stacks = [  ];
                    nr_stacks = [  ];
                    if isfield( PAR.Labels, 'StackIndex' )
                        stacks = unique( PAR.Labels.StackIndex );
                        nr_stacks = length( stacks );
                    end
                    
                    for i = 1:size( PAR.Scan.FoldOverDir, 1 )
                        if isempty( PAR.Scan.PatientPosition )
                            pat_pos = 'HeadFirst';
                        else
                            pat_pos = PAR.Scan.PatientPosition;
                        end
                        if isempty( PAR.Scan.PatientOrientation )
                            pat_ori = 'Supine';
                        else
                            pat_ori = PAR.Scan.PatientOrientation;
                        end
                        
                        if strcmpi( PAR.Scan.KooshBall, 'no' )
                            mode = PAR.Scan.AcqMode;
                        else
                            mode = 'Kooshball';
                        end
                        [ PAR.Scan.MPS( i, : ), PAR.Scan.xyz( i, : ), PAR.Scan.REC( i, : ) ] = MRparameter.get_coordinate_systems( pat_pos, pat_ori, PAR.Scan.Orientation( i, : ), PAR.Scan.FoldOverDir( i, : ), PAR.Scan.FatShiftDir( i, : ), mode );
                        PAR.Scan.ijk( i, : ) = PAR.Scan.MPS( i, : );
                    end
                    PAR.Scan.MPS = char( PAR.Scan.MPS );
                    PAR.Scan.xyz = char( PAR.Scan.xyz );
                    PAR.Scan.ijk = char( PAR.Scan.ijk );
                    PAR.Scan.REC = char( PAR.Scan.REC );
                    
                    if isfield( PAR.Labels, 'FOV' )
                        if ~isempty( stacks )
                            for i = 1:nr_stacks
                                P = MRparameter.get_coord_transformation( PAR.Scan.MPS( i, : ), 'AP FH RL' );
                                PAR.Scan.FOV( i, : ) = abs( P * PAR.Labels.FOV( i, : )' )';
                            end
                        else
                            PAR.Scan.FOV = PAR.Labels.FOV;
                        end
                    end
                    
                    if ~isempty( PAR.Scan.MPSOffcentres )
                        for i = 1:size( PAR.Scan.MPSOffcentres, 1 )
                            if isfield( PAR.Labels, 'MPSOffcentresMM' )
                                isocentreRAF = PAR.Transform( PAR.Scan.MPSOffcentresMM( i, : ), 'MPS', 'RAF', i, [  ], [  ], [  ], [  ], [  ] );
                            else
                                isocentreRAF = PAR.Transform( PAR.Scan.MPSOffcentres( i, : ), 'MPSpix', 'RAF', i, [  ], [  ], [  ], [  ], [  ] );
                            end
                            P = MRparameter.get_coord_transformation( 'RL AP FH', 'AP FH RL' );
                            P1 = MRparameter.get_coord_transformation( 'AP FH RL', PAR.Scan.xyz( i, : ) );
                            isocentreRAF = P * isocentreRAF;
                            PAR.Scan.xyzOffcentres( i, : ) = ( P1 * ( isocentreRAF + PAR.Scan.Offcentre( i, : )' ) )';
                            
                        end
                    end
                end
            end
        end
        
        function UpdateMultivenc( PAR, a, b )
            if strcmpi( PAR.Scan.Multivenc, 'No' )
                PAR.Scan.kv = zeros( length( PAR.Parameter2Read.extr1 ), 3 );
                if isfield( PAR.Labels, 'Venc' )
                    PAR.Scan.Venc = PAR.Labels.Venc;
                end
                PAR.Recon.TKE = 'No';
            end
        end
        
        function Updatekv( PAR, a, b )
            if strcmpi( PAR.Scan.Multivenc, 'Yes' )
                PAR.Scan.kv( abs( PAR.Scan.kv ) < 1e-3 ) = 0;
                
                PAR.Scan.Venc = 100 * pi ./ ( repmat( PAR.Scan.kv( 1, : ), [ size( PAR.Scan.kv, 1 ) - 1, 1 ] ) - PAR.Scan.kv( 2:end , : ) );
                PAR.Scan.Venc( find( isinf( PAR.Scan.Venc ) ) ) = 0;
            end
        end
        
        
        
        
        function InitGridder( PAR )
            PAR.Gridder.InitWorkingPars;
            
            if ~isempty( PAR.Scan.AcqMode )
                switch lower( PAR.Scan.AcqMode )
                    case 'cartesian'
                        PAR.Gridder.Preset = 'None';
                    case 'radial'
                        PAR.Gridder.Preset = 'Radial';
                        if isfield( PAR.Labels, 'KooshBall' )
                            PAR.Gridder.KooshBall = PAR.Labels.KooshBall;
                        end
                    case 'spiral'
                        PAR.Gridder.Preset = 'Spiral';
                        if isfield( PAR.Labels, 'SpiralLeadingSamples' )
                            PAR.Gridder.SpiralLeadingSamples = PAR.Labels.SpiralLeadingSamples;
                        end
                    case 'propeller'
                        warning( 'MATLAB:MRecon', 'Propeller sampling is currently not supported' );
                    otherwise
                        warning( 'MATLAB:MRecon', 'The current acquisition mode is not supported' );
                end
            end
            
            if any( strcmpi( PAR.Scan.FastImgMode, { 'EPI', 'TFEEPI' } ) ) &&  ...
                    isfield( PAR.Labels, 'NusEncNrs' ) &&  ...
                    ~isempty( PAR.Labels.NusEncNrs )
                PAR.Gridder.Preset = 'Epi';
                PAR.Gridder.KernelWidth = 2;
            end
        end
        
        
        
        
        function CreateInfoPars( PAR, dim )
            if iscell( dim )
                PAR.ImageInformation = [  ];
                for i = 1:size( dim, 1 )
                    for j = 1:size( dim, 2 )
                        if ~isempty( dim{ i, j } )
                            PAR.ImageInformation{ i, j } = InfoPars( dim{ i, j } );
                        end
                    end
                end
            else
                PAR.ImageInformation = InfoPars( dim );
            end
        end
        function ResetImageInformation( PAR )
            PAR.ImageInformation = [  ];
        end
        function UpdateInfoPars( PAR, a, b )
            
            
            
            
            if nargin == 1 || ~ischar( a )
                method = PAR.DataFormat;
            else
                method = a;
            end
            
            try
                switch method
                    case { 'ExportedRaw', 'ExportedCpx', 'Raw', 'Bruker' }
                        if strcmpi( PAR.Recon.AutoUpdateInfoPars, 'yes' ) &&  ...
                                ~isempty( PAR.Scan.ScanMode ) &&  ...
                                ~isempty( PAR.Data );
                            if iscell( PAR.Data )
                                max_ci = size( PAR.Data, 1 );
                                max_cj = size( PAR.Data, 2 );
                            else
                                max_ci = 1;
                                max_cj = 1;
                            end
                            
                            
                            
                            
                            if iscell( PAR.Data ) && length( PAR.Data ) == 1 && ~iscell( PAR.ImageInformation )
                                PAR.ImageInformation = { PAR.ImageInformation };
                                return ;
                            end
                            
                            
                            
                            
                            if ~iscell( PAR.Data ) && iscell( PAR.ImageInformation ) && length( PAR.ImageInformation ) == 1
                                PAR.ImageInformation = PAR.ImageInformation{ 1 };
                                return ;
                            end
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            create_new_info_struct = 0;
                            if isempty( PAR.ImageInformation )
                                create_new_info_struct = 1;
                            else
                                if ~create_new_info_struct
                                    for ci = 1:max_ci
                                        for cj = 1:max_cj
                                            if iscell( PAR.ImageInformation )
                                                if ( any( size( PAR.ImageInformation ) ~= size( PAR.Data ) ) )
                                                    create_new_info_struct = 1;
                                                else
                                                    
                                                    I = PAR.ImageInformation{ ci, cj };
                                                    cur_data_size = size( PAR.Data{ ci, cj } );
                                                    s_data = size( PAR.Data{ ci, cj } );s_data( end  + 1:12 ) = 1;s_data = s_data( 3:end  );
                                                    s_info = size( I );s_info = [ 1, 1, s_info ];s_info( end  + 1:12 ) = 1;s_info = s_info( 3:end  );
                                                    if ~isempty( I )
                                                        if ndims( PAR.Data{ ci, cj } ) - 2 ~= ndims( I ) || any( s_data ~= s_info )
                                                            create_new_info_struct = 1;
                                                        end
                                                    end
                                                end
                                            else
                                                I = PAR.ImageInformation;
                                                cur_data_size = size( PAR.Data );
                                                s_data = size( PAR.Data );s_data( end  + 1:12 ) = 1;s_data = s_data( 3:end  );
                                                s_info = size( I );s_info = [ 1, 1, s_info ];s_info( end  + 1:12 ) = 1;s_info = s_info( 3:end  );
                                                if ~isempty( I )
                                                    if ndims( PAR.Data ) - 2 ~= ndims( I ) || any( s_data ~= s_info )
                                                        create_new_info_struct = 1;
                                                    end
                                                end
                                                
                                            end
                                            
                                        end
                                    end
                                end
                            end
                            if iscell( PAR.ImageInformation )
                                I = PAR.ImageInformation{ 1, 1 };
                            end
                            if create_new_info_struct
                                
                                for ci = 1:max_ci
                                    for cj = 1:max_cj
                                        if iscell( PAR.Data )
                                            dim{ ci, cj } = size( PAR.Data{ ci, cj } );
                                        else
                                            dim{ ci, cj } = size( PAR.Data );
                                        end
                                        if sum( dim{ ci, cj } ) ~= 0
                                            if length( dim{ ci, cj } ) > 2
                                                dim{ ci, cj } = dim{ ci, cj }( 3:end  );
                                            else
                                                dim{ ci, cj } = 1;
                                            end
                                        else
                                            dim{ ci, cj } = [  ];
                                        end
                                        if length( dim{ ci, cj } ) == 1
                                            dim{ ci, cj } = [ dim{ ci, cj }, 1 ];
                                        end
                                    end
                                end
                                dim = MRecon.UnconvertCell( dim );
                                PAR.CreateInfoPars( dim );
                            end
                            if create_new_info_struct || ~isempty( I )
                                
                                if iscell( PAR.Data )
                                    nr_phases = size( PAR.Data{ ci, cj }, 6 );
                                else
                                    nr_phases = size( PAR.Data, 6 );
                                end
                                if nr_phases > 1
                                    if isfield( PAR.Labels, 'Index' )
                                        for i = 1:nr_phases
                                            ind = PAR.Labels.Index.typ == 1 & PAR.Labels.Index.card == ( i - 1 );
                                            trig_delays( i ) = round( mean( PAR.Labels.Index.rtop( ind ) ) );
                                        end
                                    elseif isfield( PAR.Labels, 'ImageInformation' ) && isfield( PAR.Labels.ImageInformation, 'TriggerTime' )
                                        if isfield( PAR.Labels.ImageInformation, 'CardiacPhaseNumber' )
                                            [ a, b, c ] = unique( PAR.Labels.ImageInformation.CardiacPhaseNumber );
                                        else
                                            [ a, b, c ] = unique( PAR.Labels.ImageInformation.Phase );
                                        end
                                        trig_delays = PAR.Labels.ImageInformation.TriggerTime( b );
                                    else
                                        trig_delays = zeros( nr_phases, 1 );
                                    end
                                else
                                    trig_delays = 0;
                                end
                                
                                
                                if iscell( PAR.Data )
                                    nr_dyns = size( PAR.Data{ ci, cj }, 5 );
                                else
                                    nr_dyns = size( PAR.Data, 5 );
                                end
                                if nr_dyns > 1
                                    if isfield( PAR.Labels, 'Index' )
                                        for i = 1:nr_dyns
                                            ind = find( PAR.Labels.Index.typ == 1 & PAR.Labels.Index.dyn == ( i - 1 ), 1 );
                                            if ~isempty( ind )
                                                dyn_times( i ) = double( PAR.Labels.Index.dyn_time( ind ) ) ./ 1000;
                                            end
                                        end
                                    elseif isfield( PAR.Labels, 'ImageInformation' ) && isfield( PAR.Labels.ImageInformation, 'DynScanBeginTime' )
                                        if isfield( PAR.Labels.ImageInformation, 'DynamicScanNumber' )
                                            [ a, b, c ] = unique( PAR.Labels.ImageInformation.DynamicScanNumber );
                                        else
                                            [ a, b, c ] = unique( PAR.Labels.ImageInformation.Dynamic );
                                        end
                                        dyn_times = PAR.Labels.ImageInformation.DynScanBeginTime( b );
                                    else
                                        dyn_times = zeros( nr_dyns, 1 );
                                    end
                                else
                                    dyn_times = 0;
                                end
                                
                                if ~isempty( PAR.Scan.RecVoxelSize ) && length( PAR.Scan.RecVoxelSize( 1, : ) ) > 2
                                    slice_thickness = max( [ 0, PAR.Scan.RecVoxelSize( 1, 3 ) ] );
                                else
                                    slice_thickness = 0;
                                end
                                
                                if isfield( PAR.Labels, 'Angulation' )
                                    angulation = PAR.Labels.Angulation;
                                    angulation = angulation( :, [ 1, 3, 2 ] );
                                elseif isfield( PAR.Labels, 'ImageInformation' ) && isfield( PAR.Labels.ImageInformation, 'ImageAngulation' )
                                    angulation = PAR.Labels.ImageInformation.ImageAngulation;
                                else
                                    angulation = [ 0, 0, 0 ];
                                end
                                if ~isempty( PAR.Scan.Orientation )
                                    orientation = PAR.Scan.Orientation;
                                else
                                    orientation = 'TRA';
                                end
                                
                                if ~isempty( PAR.Scan.TE )
                                    te = PAR.Scan.TE;
                                else
                                    te = 0;
                                end
                            end
                            if isempty( PAR.Scan.AcqVoxelSize )
                                PAR.Scan.AcqVoxelSize = [ 0, 0, 0 ];
                            end
                            
                            for ci = 1:max_ci
                                for cj = 1:max_cj
                                    if iscell( PAR.ImageInformation )
                                        I = PAR.ImageInformation{ ci, cj };
                                    else
                                        I = PAR.ImageInformation;
                                    end
                                    
                                    
                                    if isfield( PAR.Labels, 'Offcentre' )
                                        offcentre = PAR.Labels.Offcentre;
                                        offcentre = offcentre( :, [ 1, 3, 2 ] );
                                        if isfield( PAR.Labels, 'StackIndex' )
                                            stacks = unique( PAR.Labels.StackIndex );
                                            stack_index = PAR.Labels.StackIndex;
                                        else
                                            stacks = 0;
                                            stack_index = zeros( size( offcentre, 1 ), 1 );
                                        end
                                        
                                        if strcmpi( PAR.Scan.ScanMode, '3D' ) && ~isempty( PAR.Scan.Offcentre ) &&  ...
                                                ~isempty( PAR.Scan.Angulation ) && ~isempty( PAR.Scan.FOV )
                                            
                                            if iscell( PAR.Data )
                                                xres = size( PAR.Data{ ci, cj }, 1 );
                                                yres = size( PAR.Data{ ci, cj }, 2 );
                                                zres = size( PAR.Data{ ci, cj }, 3 );
                                            else
                                                xres = size( PAR.Data, 1 );
                                                yres = size( PAR.Data, 2 );
                                                zres = size( PAR.Data, 3 );
                                            end
                                            off_temp = zeros( zres * size( offcentre, 1 ), 3 );
                                            for i = 1:size( offcentre, 1 )
                                                try
                                                    cur_stack = find( stacks == stack_index( i ) );
                                                    ijk = repmat( [ xres / 2 + 0.5;yres / 2 + 0.5;0 ], [ 1, zres ] );
                                                    ijk( 3, : ) = 1:zres;
                                                    off_temp( ( i - 1 ) * zres + 1:( i - 1 ) * zres + zres, : ) = PAR.Transform( ijk, 'ijk', 'RAF', cur_stack, [  ], [  ], [  ], [  ], [  ] )';
                                                catch
                                                end
                                            end
                                            
                                            off_temp = off_temp( :, [ 2, 3, 1 ] );
                                            offcentre = off_temp;
                                        end
                                    elseif isfield( PAR.Labels, 'ImageInformation' ) && isfield( PAR.Labels.ImageInformation, 'ImageOffcentre' )
                                        offcentre = PAR.Labels.ImageInformation.ImageOffcentre;
                                    else
                                        offcentre = [ 0, 0, 0 ];
                                    end
                                    
                                    
                                    if iscell( PAR.Data )
                                        res = [ size( PAR.Data{ 1, 1 }, 1 ), size( PAR.Data{ 1, 1 }, 2 ) ];
                                    else
                                        res = deal( [ size( PAR.Data, 1 ), size( PAR.Data, 2 ) ] );
                                    end
                                    
                                    if isempty( I ) || create_new_info_struct ||  ...
                                            any( I( 1 ).Resolution ~= res ) || max( [ 0, I( 1 ).ACQVoxelSize( 1 ) ] ) ~= max( [ 0, PAR.Scan.AcqVoxelSize( 1 ) ] ) ||  ...
                                            any( I( 1 ).EchoTime ~= max( [ 0, PAR.Scan.TE ] ) ) || I( 1 ).TurboFactor ~= PAR.Scan.TFEfactor ||  ...
                                            I( 1 ).SliceThickness ~= slice_thickness || I( 1 ).SliceGap ~= 0
                                        set_img_pars = 1;
                                    else
                                        set_img_pars = 0;
                                    end
                                    
                                    if isempty( I ) || create_new_info_struct ||  ...
                                            any( I( 1 ).Angulation ~= angulation( 1, : ) ) ||  ...
                                            any( I( 1 ).Offcentre ~= offcentre( 1, : ) ) ||  ...
                                            ~strcmpi( I( 1 ).Orientation, orientation )
                                        set_loca_pars = 1;
                                    else
                                        set_loca_pars = 0;
                                    end
                                    
                                    if ~isempty( I )
                                        s = size( I );
                                        a = ones( s );
                                        a1 = ones( s );
                                        if length( s ) > 1
                                            a3 = ones( [ s( 1 ), 3, s( 2:end  ) ] );
                                            a4 = ones( [ s( 1 ), 4, s( 2:end  ) ] );
                                        else
                                            a3 = ones( [ s( 1 ), 3 ] );
                                            a4 = ones( [ s( 1 ), 4 ] );
                                        end
                                        fn = fieldnames( I );
                                        for i = 1:10
                                            if i <= ndims( I )
                                                dimb = ones( 1, ndims( I ) );
                                                dimb( i ) = size( a, i );
                                                b = ones( dimb );
                                                b( 1:size( a, i ) ) = 1:1:size( a, i );
                                                a = a .* 0 + 1;
                                                a = bsxfun( @times, a, b );
                                            else
                                                a = a .* 0 + 1;
                                            end
                                            c = num2cell( a );
                                            [ I.( fn{ i } ) ] = c{ : };
                                        end
                                        
                                        
                                        if set_img_pars
                                            a3( :, 1, : ) = res( 1 );
                                            a3( :, 2, : ) = res( 2 );
                                            c = num2cell( a3( :, 1:2, : ), 2 );
                                            [ I.Resolution ] = c{ : };
                                            
                                            a = a .* 0 + PAR.Scan.TFEfactor;
                                            c = num2cell( a );
                                            [ I.TurboFactor ] = c{ : };
                                            
                                            a = a .* 0 + slice_thickness;
                                            c = num2cell( a );
                                            [ I.SliceThickness ] = c{ : };
                                            
                                            a = a .* 0;
                                            c = num2cell( a );
                                            [ I.SliceGap ] = c{ : };
                                        end
                                        
                                        
                                        for i = 1:size( I, 7 )
                                            
                                            if ~isempty( PAR.Scan.RecVoxelSize )
                                                if i <= size( PAR.Scan.RecVoxelSize )
                                                    a3( :, 1, :, :, :, :, :, i, : ) = PAR.Scan.RecVoxelSize( i, 1 );
                                                    a3( :, 2, :, :, :, :, :, i, : ) = PAR.Scan.RecVoxelSize( i, 2 );
                                                    a3( :, 3, :, :, :, :, :, i, : ) = PAR.Scan.RecVoxelSize( i, 3 );
                                                else
                                                    a3( :, 1, :, :, :, :, :, i, : ) = PAR.Scan.RecVoxelSize( end , 1 );
                                                    a3( :, 2, :, :, :, :, :, i, : ) = PAR.Scan.RecVoxelSize( end , 2 );
                                                    a3( :, 3, :, :, :, :, :, i, : ) = PAR.Scan.RecVoxelSize( end , 3 );
                                                end
                                            end
                                            c = num2cell( a3, 2 );
                                            [ I.RecVoxelSize ] = c{ : };
                                            
                                            a3 = a3 .* 0;
                                            if ~isempty( PAR.Scan.AcqVoxelSize )
                                                if i <= size( PAR.Scan.AcqVoxelSize )
                                                    a3( :, 1, :, :, :, :, :, i, : ) = PAR.Scan.AcqVoxelSize( i, 1 );
                                                    a3( :, 2, :, :, :, :, :, i, : ) = PAR.Scan.AcqVoxelSize( i, 2 );
                                                    a3( :, 3, :, :, :, :, :, i, : ) = PAR.Scan.AcqVoxelSize( i, 3 );
                                                else
                                                    a3( :, 1, :, :, :, :, :, i, : ) = PAR.Scan.AcqVoxelSize( end , 1 );
                                                    a3( :, 2, :, :, :, :, :, i, : ) = PAR.Scan.AcqVoxelSize( end , 2 );
                                                    a3( :, 3, :, :, :, :, :, i, : ) = PAR.Scan.AcqVoxelSize( end , 3 );
                                                end
                                            end
                                            c = num2cell( a3, 2 );
                                            [ I.ACQVoxelSize ] = c{ : };
                                            
                                            if i <= size( PAR.Scan.FlipAngle )
                                                a( :, :, :, :, :, :, i, : ) = PAR.Scan.FlipAngle( i );
                                            else
                                                a( :, :, :, :, :, :, i, : ) = PAR.Scan.FlipAngle( end  );
                                            end
                                        end
                                        c = num2cell( a );
                                        [ I.FlipAngle ] = c{ : };
                                        
                                        
                                        
                                        if set_loca_pars
                                            a3 = a3 .* 0;
                                            a32 = a3;
                                            a = a .* 0;
                                            a1 = a1 .* 0;
                                            for i = 1:size( I, 6 )
                                                if i <= size( angulation, 1 )
                                                    a3( :, 1, :, :, :, :, i, : ) = angulation( i, 1 );
                                                    a3( :, 2, :, :, :, :, i, : ) = angulation( i, 2 );
                                                    a3( :, 3, :, :, :, :, i, : ) = angulation( i, 3 );
                                                else
                                                    a3( :, 1, :, :, :, :, i, : ) = angulation( end , 1 );
                                                    a3( :, 2, :, :, :, :, i, : ) = angulation( end , 2 );
                                                    a3( :, 3, :, :, :, :, i, : ) = angulation( end , 3 );
                                                end
                                                
                                                
                                                for j = 1:size( I, 1 )
                                                    if i <= size( offcentre, 1 ) && j <= size( offcentre, 1 )
                                                        a32( j, 1, :, :, :, :, i, : ) = offcentre( ( i - 1 ) * size( I, 1 ) + j, 1 );
                                                        a32( j, 2, :, :, :, :, i, : ) = offcentre( ( i - 1 ) * size( I, 1 ) + j, 2 );
                                                        a32( j, 3, :, :, :, :, i, : ) = offcentre( ( i - 1 ) * size( I, 1 ) + j, 3 );
                                                    else
                                                        a32( j, 1, :, :, :, :, i, : ) = offcentre( end , 1 );
                                                        a32( j, 2, :, :, :, :, i, : ) = offcentre( end , 2 );
                                                        a32( j, 3, :, :, :, :, i, : ) = offcentre( end , 3 );
                                                    end
                                                end
                                                if i <= size( orientation )
                                                    switch orientation( i, : )
                                                        case 'TRA'
                                                            a( :, :, :, :, :, i, : ) = 1;
                                                        case 'SAG'
                                                            a( :, :, :, :, :, i, : ) = 2;
                                                        case 'COR'
                                                            a( :, :, :, :, :, i, : ) = 3;
                                                    end
                                                else
                                                    switch orientation( end , : )
                                                        case 'TRA'
                                                            a( :, :, :, :, :, i, : ) = 1;
                                                        case 'SAG'
                                                            a( :, :, :, :, :, i, : ) = 2;
                                                        case 'COR'
                                                            a( :, :, :, :, :, i, : ) = 3;
                                                    end
                                                end
                                                
                                                if ~isempty( PAR.Scan.SliceGap )
                                                    if i <= size( PAR.Scan.SliceGap )
                                                        a1( :, :, :, :, :, i, : ) = max( [ 0, PAR.Scan.SliceGap( i ) ] );
                                                    else
                                                        a1( :, :, :, :, :, i, : ) = max( [ 0, PAR.Scan.SliceGap( end  ) ] );
                                                    end
                                                    
                                                end
                                            end
                                            c = num2cell( a );
                                            [ I.Orientation ] = c{ : };
                                            c = num2cell( a1 );
                                            [ I.SliceGap ] = c{ : };
                                            c = num2cell( a3, 2 );
                                            [ I.Angulation ] = c{ : };
                                            c = num2cell( a32, 2 );
                                            [ I.Offcentre ] = c{ : };
                                            
                                            
                                            
                                            
                                            if set_loca_pars
                                                for i = 1:size( I, 5 )
                                                    if i <= length( te )
                                                        a( :, :, :, :, i, :, : ) = te( i );
                                                    else
                                                        a( :, :, :, :, i, :, : ) = te( end  );
                                                    end
                                                    c = num2cell( a );
                                                    [ I.EchoTime ] = c{ : };
                                                end
                                            end
                                            
                                            
                                            
                                            if nr_phases > 1 && ndims( I ) > 3
                                                dimb = ones( 1, ndims( I ) );
                                                dimb( 4 ) = size( a, 4 );
                                                b = ones( dimb );
                                                if size( a, 4 ) <= length( trig_delays )
                                                    b( 1:size( a, 4 ) ) = trig_delays( 1:size( a, 4 ) );
                                                else
                                                    b( 1:length( trig_delays ) ) = trig_delays;
                                                end
                                                a = a .* 0 + 1;
                                                a = bsxfun( @times, a, b );
                                                c = num2cell( a );
                                            else
                                                a = a .* 0;
                                                c = num2cell( a );
                                            end
                                            [ I.TriggerTime ] = c{ : };
                                            
                                            
                                            
                                            if nr_dyns > 1 && ndims( I ) > 2
                                                dimb = ones( 1, ndims( I ) );
                                                dimb( 3 ) = size( a, 3 );
                                                b = ones( dimb );
                                                if size( a, 3 ) <= length( dyn_times )
                                                    b( 1:size( a, 3 ) ) = dyn_times( 1:size( a, 3 ) );
                                                else
                                                    b( 1:length( dyn_times ) ) = dyn_times;
                                                end
                                                a = a .* 0 + 1;
                                                a = bsxfun( @times, a, b );
                                                c = num2cell( a );
                                            else
                                                a = a .* 0;
                                                c = num2cell( a );
                                            end
                                            [ I.DynamicScanTime ] = c{ : };
                                        end
                                        if iscell( PAR.ImageInformation )
                                            PAR.ImageInformation{ ci, cj } = I;
                                        else
                                            PAR.ImageInformation = I;
                                        end
                                        
                                        if ~isempty( PAR.Scan.ASLType ) && ~strcmpi( PAR.Scan.ASLType, 'No' )
                                            ind = 1:length( I( : ) );
                                            I.Set( 'LabelTypeASL', [ I.Extra1 ]', ind );
                                        end
                                        
                                        if ~isempty( PAR.Scan.Diffusion ) && ~strcmpi( PAR.Scan.Diffusion, 'No' )
                                            try
                                                
                                                if iscell( PAR.Data )
                                                    sum_data = squeeze( sum( sum( abs( PAR.Data{ ci, cj }( :, :, : ) ) ) ) );
                                                else
                                                    sum_data = squeeze( sum( sum( abs( PAR.Data( :, :, : ) ) ) ) );
                                                end
                                                ind_no_data = find( sum_data == 0 );
                                                
                                                
                                                ind = 1:length( I( : ) );
                                                ind0 = find( PAR.Labels.DiffusionBValues( [ I.Extra1 ] ) == 0 );
                                                
                                                
                                                dirs = [ PAR.Labels.DiffusionAP( [ I.Extra2 ] );PAR.Labels.DiffusionFH( [ I.Extra2 ] );PAR.Labels.DiffusionRL( [ I.Extra2 ] ) ]';
                                                
                                                dirs( ind0, : ) = repmat( [ 0, 0, 0 ], [ length( ind0 ), 1 ] );
                                                
                                                b_value_nr = [ I.Extra2 ]' - 1;
                                                b_value_nr( ind0 ) = max( b_value_nr ) + 1;
                                                
                                                no_data = [ I.NoData ]';
                                                no_data( ind_no_data ) = 1;
                                                
                                                I.Set( 'DiffusionBFactor', PAR.Labels.DiffusionBValues( [ I.Extra1 ] )', ind );
                                                I.Set( 'DiffusionAPFHRL', dirs, ind );
                                                I.Set( 'DiffusionBValueNr', b_value_nr, ind );
                                                I.Set( 'NoData', no_data, ind );
                                            end
                                        end
                                        
                                        
                                    end
                                end
                            end
                        end
                    case 'Rec'
                        if strcmpi( PAR.Recon.AutoUpdateInfoPars, 'yes' ) &&  ...
                                ~isempty( PAR.Labels ) && ~isempty( PAR.Data )
                            dim = size( PAR.Data );
                            if length( dim ) > 2
                                dim = dim( 3:end  );
                            else
                                dim = 1;
                            end
                            ind = find( PAR.LabelLookupTable( : ) ~= 0 );
                            ind = PAR.LabelLookupTable( ind );
                            
                            
                            
                            if prod( dim ) ~= length( ind ) || iscell( PAR.Data )
                                PAR.UpdateInfoPars( 'Raw' );
                                return ;
                            end
                            
                            PAR.CreateInfoPars( dim );
                            if isfield( PAR.Labels.ImageInformation, 'SliceNumber' )
                                
                                PAR.ImageInformation.Set( 'Slice', PAR.Labels.ImageInformation.SliceNumber, ind );
                                PAR.ImageInformation.Set( 'Dynamic', PAR.Labels.ImageInformation.DynamicScanNumber, ind );
                                PAR.ImageInformation.Set( 'CardiacPhase ', PAR.Labels.ImageInformation.CardiacPhaseNumber, ind );
                                PAR.ImageInformation.Set( 'Echo ', PAR.Labels.ImageInformation.EchoNumber, ind );
                                PAR.ImageInformation.Set( 'ScanningSequence ', PAR.Labels.ImageInformation.ScanningSequence, ind );
                                PAR.ImageInformation.Set( 'ImageType ', PAR.Labels.ImageInformation.ImageTypeMr, ind );
                                PAR.ImageInformation.Set( 'Resolution ', PAR.Labels.ImageInformation.ReconResolution, ind );
                                PAR.ImageInformation.Set( 'RescaleIntercept ', PAR.Labels.ImageInformation.RescaleIntercept, ind );
                                PAR.ImageInformation.Set( 'RescaleSlope ', PAR.Labels.ImageInformation.RescaleSlope, ind );
                                PAR.ImageInformation.Set( 'ScaleSlope ', PAR.Labels.ImageInformation.ScaleSlope, ind );
                                PAR.ImageInformation.Set( 'WindowCenter ', PAR.Labels.ImageInformation.WindowCenter, ind );
                                PAR.ImageInformation.Set( 'WindowWidth ', PAR.Labels.ImageInformation.WindowWidth, ind );
                                PAR.ImageInformation.Set( 'Angulation ', PAR.Labels.ImageInformation.ImageAngulation, ind );
                                PAR.ImageInformation.Set( 'Offcentre ', PAR.Labels.ImageInformation.ImageOffcentre, ind );
                                PAR.ImageInformation.Set( 'SliceThickness ', PAR.Labels.ImageInformation.SliceThickness, ind );
                                PAR.ImageInformation.Set( 'SliceGap ', PAR.Labels.ImageInformation.SliceGap, ind );
                                PAR.ImageInformation.Set( 'Orientation ', PAR.Labels.ImageInformation.SliceOrientation, ind );
                                PAR.ImageInformation.Set( 'RecVoxelSize ', PAR.Labels.ImageInformation.PixelSpacing, ind );
                                PAR.ImageInformation.Set( 'EchoTime ', PAR.Labels.ImageInformation.EchoTime, ind );
                                PAR.ImageInformation.Set( 'TriggerTime ', PAR.Labels.ImageInformation.TriggerTime, ind );
                                PAR.ImageInformation.Set( 'DynamicScanTime ', PAR.Labels.ImageInformation.DynScanBeginTime, ind );
                                PAR.ImageInformation.Set( 'FlipAngle ', PAR.Labels.ImageInformation.ImageFlipAngle, ind );
                                try
                                    PAR.ImageInformation.Set( 'TurboFactor ', PAR.Labels.ImageInformation.TurboFactor, ind );
                                catch
                                    PAR.ImageInformation.Set( 'TurboFactor ', PAR.Labels.ImageInformation.TURBOFactor, ind );
                                end
                                PAR.ImageInformation.Set( 'DiffusionBFactor ', PAR.Labels.ImageInformation.DiffusionBFactor, ind );
                                PAR.ImageInformation.Set( 'DiffusionBValueNr ', PAR.Labels.ImageInformation.GradientOrientationNumber, ind );
                                PAR.ImageInformation.Set( 'DiffusionAPFHRL ', PAR.Labels.ImageInformation.Diffusion, ind );
                                PAR.ImageInformation.Set( 'ACQVoxelSize ', PAR.Labels.ImageInformation.PixelSpacing, ind );
                                
                            else
                                PAR.ImageInformation.Set( 'Slice', PAR.Labels.ImageInformation.Slice, ind );
                                PAR.ImageInformation.Set( 'Dynamic', PAR.Labels.ImageInformation.Dynamic, ind );
                                PAR.ImageInformation.Set( 'CardiacPhase ', PAR.Labels.ImageInformation.Phase, ind );
                                PAR.ImageInformation.Set( 'Echo ', PAR.Labels.ImageInformation.Echo, ind );
                                PAR.ImageInformation.Set( 'ScanningSequence ', PAR.Labels.ImageInformation.Sequence, ind );
                                PAR.ImageInformation.Set( 'ImageType ', PAR.Labels.ImageInformation.Type, ind );
                                PAR.ImageInformation.Set( 'Resolution ', [ PAR.Labels.ImageInformation.ResolutionX, PAR.Labels.ImageInformation.ResolutionY ], ind );
                                PAR.ImageInformation.Set( 'RescaleIntercept ', PAR.Labels.ImageInformation.RescaleIntercept, ind );
                                PAR.ImageInformation.Set( 'RescaleSlope ', PAR.Labels.ImageInformation.RescaleSlope, ind );
                                PAR.ImageInformation.Set( 'ScaleSlope ', PAR.Labels.ImageInformation.ScaleSlope, ind );
                                PAR.ImageInformation.Set( 'WindowCenter ', PAR.Labels.ImageInformation.WindowCenter, ind );
                                PAR.ImageInformation.Set( 'WindowWidth ', PAR.Labels.ImageInformation.WindowWidth, ind );
                                PAR.ImageInformation.Set( 'Angulation ', [ PAR.Labels.ImageInformation.AngulationAP, PAR.Labels.ImageInformation.AngulationFH, PAR.Labels.ImageInformation.AngulationRL ], ind );
                                PAR.ImageInformation.Set( 'Offcentre ', [ PAR.Labels.ImageInformation.OffcenterAP, PAR.Labels.ImageInformation.OffcenterFH, PAR.Labels.ImageInformation.OffcenterRL ], ind );
                                PAR.ImageInformation.Set( 'SliceThickness ', PAR.Labels.ImageInformation.SliceThickness, ind );
                                PAR.ImageInformation.Set( 'SliceGap ', PAR.Labels.ImageInformation.SliceGap, ind );
                                
                                
                                if ( isnumeric( PAR.Labels.ImageInformation.SliceOrientation ) )
                                    PAR.ImageInformation.Set( 'Orientation ', PAR.Labels.ImageInformation.SliceOrientation, ind );
                                else
                                    orientation_nr = ones( size( PAR.Labels.ImageInformation.SliceOrientation, 1 ), 1 );
                                    for im_nr = 1:size( PAR.Labels.ImageInformation.SliceOrientation, 1 )
                                        if ( strcmpi( PAR.Labels.ImageInformation.SliceOrientation( im_nr, : ), 'Transversal' ) )
                                            orientation_nr( im_nr ) = 1;
                                        end
                                        if ( strcmpi( PAR.Labels.ImageInformation.SliceOrientation( im_nr, : ), 'Sagittal' ) )
                                            orientation_nr( im_nr ) = 2;
                                        end
                                        if ( strcmpi( PAR.Labels.ImageInformation.SliceOrientation( im_nr, : ), 'Coronal' ) )
                                            orientation_nr( im_nr ) = 3;
                                        end
                                    end
                                    PAR.ImageInformation.Set( 'Orientation ', orientation_nr, ind );
                                end
                                
                                PAR.ImageInformation.Set( 'RecVoxelSize ', PAR.Labels.ImageInformation.PixelSpacing, ind );
                                PAR.ImageInformation.Set( 'EchoTime ', PAR.Labels.ImageInformation.EchoTime, ind );
                                PAR.ImageInformation.Set( 'TriggerTime ', PAR.Labels.ImageInformation.TriggerTime, ind );
                                PAR.ImageInformation.Set( 'DynamicScanTime ', PAR.Labels.ImageInformation.DynScanBeginTime, ind );
                                PAR.ImageInformation.Set( 'FlipAngle ', PAR.Labels.ImageInformation.ImageFlipAngle, ind );
                                try
                                    PAR.ImageInformation.Set( 'TurboFactor ', PAR.Labels.ImageInformation.TurboFactor );
                                catch
                                    PAR.ImageInformation.Set( 'TurboFactor ', PAR.Labels.ImageInformation.TURBOFactor );
                                end
                                PAR.ImageInformation.Set( 'DiffusionBFactor ', PAR.Labels.ImageInformation.DiffusionBFactor, ind );
                                PAR.ImageInformation.Set( 'DiffusionBValueNr ', PAR.Labels.ImageInformation.GradOrient, ind );
                                PAR.ImageInformation.Set( 'DiffusionAPFHRL ', [ PAR.Labels.ImageInformation.DiffusionAP, PAR.Labels.ImageInformation.DiffusionFH, PAR.Labels.ImageInformation.DiffusionRL ], ind );
                                PAR.ImageInformation.Set( 'ACQVoxelSize ', PAR.Labels.ImageInformation.PixelSpacing, ind );
                                
                            end
                        end
                end
            catch exeption
                s = sprintf( 'could not update image information. Error in: \nfunction: %s\nline: %d\nerror: %s', exeption.stack( 1 ).name, exeption.stack( 1 ).line, exeption.message );
                warning( 'MATLAB:MRecon', s );
            end
        end
        function UpdateScalingPars( PAR )
            for i = 1:size( PAR.Data, 2 )
                if ~isempty( PAR.Data{ 1, i } )
                    scaling_pars = MRparameter.get_scaling_pars( PAR.Data{ 1, i }, PAR.Recon.ExportRECImgTypes );
                    if iscell( PAR.ImageInformation )
                        I = PAR.ImageInformation{ 1, i };
                    else
                        I = PAR.ImageInformation;
                    end
                    
                    for j = 1:size( PAR.Data{ 1, i }( :, :, : ), 3 )
                        
                        if I( j ).ManualScalingRescaleIntercept == 0 || isempty( I( j ).RescaleIntercept ) ||  ...
                                ( isstruct( I( j ).RescaleIntercept ) && any( structfun( @( x )isempty( x ), I( j ).RescaleIntercept ) ) )
                            I( j ).RescaleIntercept = scaling_pars.ri;
                            I( j ).ManualScalingRescaleIntercept = 0;
                        end
                        if I( j ).ManualScalingRescaleSlope == 0 || isempty( I( j ).RescaleSlope ) ||  ...
                                ( isstruct( I( j ).RescaleSlope ) && any( structfun( @( x )isempty( x ), I( j ).RescaleSlope ) ) )
                            I( j ).RescaleSlope = scaling_pars.rs;
                            I( j ).ManualScalingRescaleSlope = 0;
                        end
                        if I( j ).ManualScalingScaleSlope == 0 || isempty( I( j ).ScaleSlope ) ||  ...
                                ( isstruct( I( j ).ScaleSlope ) && any( structfun( @( x )isempty( x ), I( j ).ScaleSlope ) ) )
                            I( j ).ScaleSlope = scaling_pars.ss;
                            I( j ).ManualScalingScaleSlope = 0;
                        end
                        if I( j ).ManualScalingWindowCenter == 0 || isempty( I( j ).WindowCenter ) ||  ...
                                ( isstruct( I( j ).WindowCenter ) && any( structfun( @( x )isempty( x ), I( j ).WindowCenter ) ) )
                            I( j ).WindowCenter = scaling_pars.wc;
                            I( j ).ManualScalingWindowCenter = 0;
                        end
                        if I( j ).ManualScalingWindowWidth == 0 || isempty( I( j ).WindowWidth ) ||  ...
                                ( isstruct( I( j ).WindowWidth ) && any( structfun( @( x )isempty( x ), I( j ).WindowWidth ) ) )
                            I( j ).WindowWidth = scaling_pars.ww;
                            I( j ).ManualScalingWindowWidth = 0;
                        end
                    end
                end
            end
        end
        
        
        
        
        function DefineChunk( PAR, a, b )
            if iscell( PAR.Chunk.Def )
                [ loops, nr_loops ] = PAR.GetNrChunkLoops( PAR.Chunk.Def );
                PAR.Chunk.SetLoops( loops, nr_loops );
                PAR.Parameter2Read = PAR.GetChunkParameter2Read( loops, PAR.Chunk.CurLoop );
                PAR.InitWorkEncoding( PAR );
            else
                if ~isempty( PAR.Chunk.Parameter2Read_BeforeChunk )
                    PAR.Chunk.Reset;
                    
                end
            end
        end
        function NewChunk( PAR, a, b )
            PAR.Chunk.Parameter2Read_BeforeChunk = PAR.Parameter2Read.Copy;
        end
        function ResetChunk( PAR, a, b )
            PAR.Parameter2Read = PAR.Chunk.Parameter2Read_BeforeChunk.Copy;
            PAR.InitWorkEncoding( PAR );
        end
        function [ loops, nr_loops ] = GetNrChunkLoops( PAR, Chunk )
            if isempty( PAR.Chunk.Parameter2Read_BeforeChunk )
                PAR.Chunk.Parameter2Read_BeforeChunk = PAR.Parameter2Read.Copy;
            end
            loops = struct;
            fn = fieldnames( PAR.Parameter2Read );
            for i = 1:length( fn )
                if ~any( ismember( Chunk, fn{ i } ) ) &&  ...
                        length( PAR.Chunk.Parameter2Read_BeforeChunk.( fn{ i } ) ) ~= 1 &&  ...
                        ~isempty( PAR.Chunk.Parameter2Read_BeforeChunk.( fn{ i } ) ) &&  ...
                        ~strcmp( fn{ i }, 'rtop' )
                    
                    loops.( fn{ i } ) = PAR.Chunk.Parameter2Read_BeforeChunk.( fn{ i } );
                end
            end
            nr_loops = max( [ 1, prod( structfun( @length, loops ) ) ] );
        end
        function par2read = GetChunkParameter2Read( PAR, loops, cur_loop )
            par2read = PAR.Chunk.Parameter2Read_BeforeChunk.Copy;
            loop_lengths = structfun( @length, loops )';
            loop_names = fieldnames( loops );
            if length( loop_names ) > 1
                cur_image_inds = PAR.ind2sub( loop_lengths, cur_loop );
            else
                cur_image_inds = cur_loop;
            end
            for i = 1:length( loop_names )
                if loop_lengths( i ) > 0
                    par2read.( loop_names{ i } ) =  ...
                        loops.( loop_names{ i } )( cur_image_inds( i ) );
                end
            end
        end
        
        
        
        
        function UpdateParameter2Read( PAR, a, b )
            PAR.Parameter2Read.Update( PAR.Labels.Index );
        end
        
        
        
        
        function SetTyp( PAR )
            if any( strcmp( PAR.DataFormat, { 'ExportedRaw', 'ExportedCpx' } ) )
                t = 'TEHROA';
                t_num = t + 1;
                typ = PAR.Labels.Index.typ( :, 2 ) + 1;
                numtyp = zeros( size( typ ) );
                for i = 1:length( t_num )
                    numtyp = numtyp + ( typ == t_num( i ) ) .* i;
                end
                PAR.Labels.Index.typ = numtyp;
            end
        end
        
        
        
        
        function SetEpiCorrData( PAR, epi_corr_data )
            PAR.EPICorrData = epi_corr_data;
        end
        
        
        
        
        function [ xT, A ] = Transform( PAR, x, from, to, input_stacks, angulation, offcentre, matrix_size, fov, slice_gap )
            if nargin < 6
                angulation = [  ];
            end
            if nargin < 7
                offcentre = [  ];
            end
            if nargin < 8
                matrix_size = [  ];
            end
            if nargin < 9
                fov = [  ];
            end
            if nargin < 10
                slice_gap = [  ];
            end
            
            if ndims( x ) > 2
                error( 'Error in Transform: The input coordinate cannot have more than 2 dimensions' );
            end
            if ~isreal( x )
                error( 'Error in Transform: The input coordinate must be real valued' );
            end
            if size( x, 1 ) ~= 3
                x = x';
            end
            if size( x, 1 ) ~= 3
                error( 'Error in Transform: The input coordinate must be a vector/matrix with three rows' );
            end
            
            if nargin < 4
                error( 'Error in Transform: too few input arguments' );
            end
            
            if isfield( PAR.Labels, 'StackIndex' )
                stacks = unique( PAR.Labels.StackIndex );
            else
                stacks = 0;
            end
            nr_stacks = length( stacks );
            if any( input_stacks > nr_stacks )
                error( 'Error in Transform: the stack number exceeds the number of stacks' );
            end
            if any( input_stacks < 1 )
                error( 'Error in Transform: the stack number has to be larger than 0' );
            end
            
            try
                if isempty( PAR.Data )
                    data_is_empty = 1;
                else
                    data_is_empty = 0;
                end
            catch
                data_is_empty = 1;
            end
            
            x = [ x;ones( 1, size( x, 2 ) ) ];
            A = zeros( 4, 4, length( input_stacks ) );
            
            fov_orig = fov;
            matrix_size_orig = matrix_size;
            for cur_stack = 1:length( input_stacks )
                fov = fov_orig;
                matrix_size = matrix_size_orig;
                
                stack = input_stacks( cur_stack );
                
                
                
                
                
                if ~strcmpi( PAR.Scan.ScanMode, '3D' )
                    flip = 0;
                else
                    flip = 1;
                end
                
                from = lower( from );
                switch from
                    case 'rec'
                        from_nr = 1;
                        from_system = PAR.Scan.REC( stack, : );
                    case 'ijk'
                        from_system = PAR.Scan.ijk( stack, : );
                        if ~flip
                            from_system( end  - 1:end  ) = PAR.Scan.REC( stack, end  - 1:end  );
                        end
                        from_nr = 2;
                    case 'mpspix'
                        from_system = PAR.Scan.MPS( stack, : );
                        if ~flip
                            from_system( end  - 1:end  ) = PAR.Scan.REC( stack, end  - 1:end  );
                        end
                        from_nr = 3;
                    case 'mps'
                        from_system = PAR.Scan.MPS( stack, : );
                        if ~flip
                            from_system( end  - 1:end  ) = PAR.Scan.REC( stack, end  - 1:end  );
                        end
                        from_nr = 4;
                    case 'raf'
                        from_system = 'RL AP FH';
                        from_nr = 5;
                    case 'xyz'
                        from_system = PAR.Scan.xyz( stack, : );
                        from_nr = 6;
                    otherwise
                        error( sprintf( 'Error in Transform: Unknown source coordinate system.\nPossible systems are ''ijk'', ''MPS'', ''MPSPIX'', ''RAF'', ''xyz'', ''REC''' ) );
                end
                to = lower( to );
                switch to
                    case 'rec'
                        to_system = PAR.Scan.REC( stack, : );
                        to_nr = 1;
                    case 'ijk'
                        to_system = PAR.Scan.ijk( stack, : );
                        if ~flip
                            to_system( end  - 1:end  ) = PAR.Scan.REC( stack, end  - 1:end  );
                        end
                        to_nr = 2;
                    case 'mpspix'
                        to_system = PAR.Scan.MPS( stack, : );
                        if ~flip
                            to_system( end  - 1:end  ) = PAR.Scan.REC( stack, end  - 1:end  );
                        end
                        to_nr = 3;
                    case 'mps'
                        to_system = PAR.Scan.MPS( stack, : );
                        if ~flip
                            to_system( end  - 1:end  ) = PAR.Scan.REC( stack, end  - 1:end  );
                        end
                        to_nr = 4;
                    case 'raf'
                        to_system = 'RL AP FH';
                        to_nr = 5;
                    case 'xyz'
                        to_system = PAR.Scan.xyz( stack, : );
                        to_nr = 6;
                    otherwise
                        error( sprintf( 'Error in Transform: Unknown target coordinate system.\nPossible systems are ''ijk'', ''MPS'', ''MPSPIX'', ''RAF'', ''xyz'', ''REC''' ) );
                end
                
                
                if ( to_nr == from_nr )
                    A( :, :, cur_stack ) = eye( 4 );
                    continue ;
                end
                
                if from_nr <= 4 && to_nr <= 4
                    angulation = [ 0, 0, 0 ];
                    offcentre = [ 0, 0, 0 ];
                end
                
                take_inv = 0;
                
                if to_nr < from_nr
                    take_inv = 1;
                    temp_nr = to_nr;
                    temp_system = to_system;
                    
                    to_system = from_system;
                    to_nr = from_nr;
                    from_system = temp_system;
                    from_nr = temp_nr;
                end
                
                if from_nr <= 3
                    units = 'pixel';
                else
                    units = 'mm';
                end
                if to_nr <= 3
                    units_to = 'pixel';
                else
                    units_to = 'mm';
                end
                
                if from_nr <= 2
                    shift = 'yes';
                else
                    shift = 'no';
                end
                
                
                
                if isempty( angulation )
                    angulation = PAR.Scan.Angulation( stack, : );
                end
                
                
                
                if isempty( offcentre )
                    if strcmpi( from, 'xyz' ) || strcmpi( to, 'xyz' )
                        offcentre = PAR.Scan.xyzOffcentres( stack, : );
                        P = MRparameter.get_coord_transformation( PAR.Scan.xyz( stack, : ), 'AP FH RL' );
                        offcentre = ( P * offcentre' )';
                    else
                        offcentre = PAR.Scan.Offcentre( stack, : );
                    end
                end
                
                
                
                if isfield( PAR.Labels, 'StackIndex' )
                    loc_ind = find( PAR.Labels.StackIndex == stacks( stack ), 1 );
                else
                    loc_ind = 1;
                end
                if isempty( slice_gap )
                    if ~isempty( PAR.Scan.SliceGap )
                        slice_gap = PAR.Scan.SliceGap( loc_ind );
                    else
                        slice_gap = 0;
                    end
                end
                
                
                
                
                
                
                
                
                if isempty( matrix_size )
                    if strcmpi( PAR.Scan.ScanMode, '3D' )
                        if data_is_empty
                            nr_slices = PAR.Encoding.WorkEncoding.ZRes{ 1, 1 };
                        else
                            if iscell( PAR.Data )
                                nr_slices = size( PAR.Data{ 1, 1 }, 3 );
                            else
                                nr_slices = size( PAR.Data, 3 );
                            end
                        end
                    else
                        try
                            read_locas = PAR.Parameter2Read.loca;
                            locas_per_cur_stack = find( PAR.Labels.StackIndex == stacks( stack ) ) - 1;
                            nr_slices = length( intersect( read_locas, locas_per_cur_stack ) );
                        catch
                            nr_slices = PAR.Encoding.ZReconRes( 1 );
                        end
                        
                    end
                else
                    nr_slices = matrix_size( 3 );
                end
                
                
                if isempty( fov )
                    fov = PAR.Scan.curFOV( stack, : );
                    
                    
                    
                    P = MRparameter.get_coord_transformation( PAR.Scan.ijk( stack, : ), PAR.Scan.MPS( stack, : ) );
                    fov = abs( P * fov' )';
                else
                    
                    P = MRparameter.get_coord_transformation( 'AP FH RL', PAR.Scan.MPS( stack, : ) );
                    fov = abs( P * fov' )';
                end
                
                
                if from_nr == 1
                    fov = PAR.Scan.FOV( stack, : );
                    
                    P = MRparameter.get_coord_transformation( 'AP FH RL', PAR.Scan.MPS( stack, : ) );
                    fov = abs( P * fov' )';
                    fov( 1:2 ) = max( fov( 1:2 ) );
                end
                
                
                
                
                if isempty( matrix_size )
                    if data_is_empty
                        
                        yovs = max( [ 1, max( PAR.Encoding.KyOversampling ) ] );
                        zovs = max( [ 1, max( PAR.Encoding.KzOversampling ) ] );
                        if ~isempty( PAR.Encoding.XRes )
                            xres = PAR.Encoding.XRes( 1 );
                        else
                            xres = 1;
                        end
                        if ~isempty( PAR.Encoding.YRes )
                            yres = PAR.Encoding.YRes( 1 );
                        else
                            yres = 1;
                        end
                        matrix_size = [ xres, yovs * yres, zovs * nr_slices ];
                        image_matrix = matrix_size;
                    else
                        
                        if iscell( PAR.Data )
                            matrix_size = [ size( PAR.Data{ 1, 1 }, 1 ), size( PAR.Data{ 1, 1 }, 2 ), nr_slices ];
                        else
                            matrix_size = [ size( PAR.Data, 1 ), size( PAR.Data, 2 ), nr_slices ];
                        end
                        image_matrix = matrix_size;
                        
                        P = MRparameter.get_coord_transformation( PAR.Scan.ijk( stack, : ), PAR.Scan.MPS( stack, : ) );
                        matrix_size = abs( P * matrix_size' )';
                    end
                else
                    if data_is_empty
                        image_matrix = matrix_size;
                    else
                        image_matrix = matrix_size;
                        P = MRparameter.get_coord_transformation( PAR.Scan.ijk( stack, : ), PAR.Scan.MPS( stack, : ) );
                        matrix_size = abs( P * matrix_size' )';
                    end
                end
                
                
                if from_nr == 1
                    matrix_size = [ PAR.Encoding.XReconRes( 1 ), max( [ 1, PAR.Encoding.YReconRes( 1 ) ] ), nr_slices ];
                    image_matrix = matrix_size;
                end
                
                
                if ( PAR.Labels.Spectro )
                    image_matrix = circshift( image_matrix, [ 0,  - 1 ] );
                    image_matrix( 3 ) = 1;
                    matrix_size = circshift( matrix_size, [ 0,  - 1 ] );
                    matrix_size( 3 ) = 1;
                end
                
                
                
                in_plane_res = fov( 1:2 ) ./ matrix_size( 1:2 );
                
                if matrix_size( 3 ) > 1
                    slice_thickness = ( fov( 3 ) - ( matrix_size( 3 ) - 1 ) * slice_gap ) ./ matrix_size( 3 );
                    z_res = slice_thickness + slice_gap;
                else
                    slice_thickness = fov( 3 );
                    z_res = slice_thickness;
                end
                
                resolutionMPS = [ in_plane_res, z_res ];
                
                
                P = MRparameter.get_coord_transformation( PAR.Scan.MPS( stack, : ), 'AP FH RL' );
                resolution = abs( P * resolutionMPS' )';
                
                if ( strcmpi( units, 'pixel' ) && strcmpi( units_to, 'pixel' ) )
                    resolution = resolution .* 0 + 1;
                end
                
                A( :, :, cur_stack ) = MRparameter.get_transformation_matrix( from_system, to_system, angulation, offcentre, resolution, image_matrix, 'shift', shift, 'Units', units );
                if take_inv
                    A( :, :, cur_stack ) = inv( A( :, :, cur_stack ) );
                end
            end
            xT = A( :, :, 1 ) * x;
            xT = xT( 1:3, : );
        end
        
        
        
        
        
        function InitSpectro( PAR, varargin )
            
            if strcmpi( PAR.Scan.ScanType, 'Spectro' ) && PAR.Parameter2Read.EnableRangeCheck
                
                if ~strcmpi( PAR.DataFormat, 'Raw' )
                    error( 'Spectro data can only be handled in Raw data format' );
                end
                
                PAR.Labels.Spectro = true;
                
                
                if ~PAR.corrected_spectro_dim
                    if any( PAR.Labels.Index.dyn ~= 0 )
                        error( 'Problem with switching spectro dynamics dimension, skipping ...' );
                    else
                        if PAR.ReconFlags.isread
                            error( 'The ScanTyp has to be set before any data is loaded' );
                        end
                        PAR.Labels.Index.dyn = PAR.Labels.Index.extr1;
                        PAR.Labels.Index.extr1 = zeros( size( PAR.Labels.Index.dyn ) );
                        PAR.corrected_spectro_dim = true;
                    end
                end
                
                
                cur_sample_size = PAR.DataType.SampleSizeBytes( find( PAR.DataType.DataTypeNum == PAR.Labels.Index.format( find( PAR.Labels.Index.typ == 1, 1 ) ) ) );
                PAR.Encoding.KxOversampling = PAR.Encoding.DataSizeByte' ./ PAR.Encoding.XRes / ( cur_sample_size * 2 );
                PAR.Encoding.FFTShift = [ 0, 0, 0 ];
                
                
                PAR.Recon.DcOffsetCorrection = 'Yes';
                PAR.Recon.PDACorrection = 'No';
                PAR.Recon.RandomPhaseCorrection = 'Yes';
                PAR.Recon.MeasPhaseCorrection = 'Yes';
                PAR.Recon.PartialFourier = 'No';
                PAR.Recon.Gridding = 'No';
                
                PAR.Recon.RingingFilter = 'Yes';
                PAR.Recon.RingingFilterStrength = [ 0, 1, 1 ];
                PAR.Recon.kSpaceZeroFill = 'No';
                PAR.Recon.EPIPhaseCorrection = 'No';
                PAR.Recon.EPI2DCorr = 'No';
                PAR.Recon.CoilCombination = 'svd';
                PAR.Recon.ImageSpaceZeroFill = 'No';
                PAR.Recon.RotateImage = 'Yes';
                PAR.Recon.GeometryCorrection = 'No';
                PAR.Recon.RemoveMOversampling = 'Yes';
                PAR.Recon.RemovePOversampling = 'No';
                PAR.Recon.ConcomitantFieldCorrection = 'No';
                PAR.Recon.ArrayCompression = 'No';
                PAR.Recon.ImmediateAveraging = 'Yes';
                PAR.Recon.AutoUpdateInfoPars = 'Yes';
                PAR.Recon.SENSE = 'Yes';
                PAR.Recon.StatusMessage = 'Yes';
                PAR.Recon.Logging = 'No';
                PAR.Spectro.Downsample = 'Yes';
                
                
                
                
                PAR.InitWorkEncoding;
                
                
                if ( PAR.Encoding.NrMixes > 1 )
                    PAR.Recon.EddyCurrentCorrection = 'Yes';
                end
            else
                if isstruct( PAR.Labels )
                    PAR.Labels.Spectro = false;
                end
            end
        end
        
        
        
        function UpdateFidInfos( PAR, varargin )
            
            
            
            if isfield( PAR.Labels, 'Spectro' ) && PAR.Labels.Spectro
                PAR.DataClass.Convert2Cell;
                
                if PAR.ReconFlags.isread
                    if PAR.ReconFlags.issorted
                        for cmix = 1:PAR.Encoding.NrMixes
                            PAR.Encoding.WorkEncoding.NrFids{ 1, cmix } = size( PAR.Data{ 1, cmix }, 12 );
                            PAR.Encoding.WorkEncoding.NrDyn{ 1, cmix } = size( PAR.Data{ 1, cmix }, 5 );
                        end
                    else
                        
                        
                        for cmix = 1:PAR.Encoding.NrMixes
                            mix_idx = PAR.LabelLookupTable{ 1, cmix }( PAR.LabelLookupTable{ 1, cmix } ~= 0 );
                            nfid = sum( ( PAR.Labels.Index.chan( mix_idx ) == PAR.Labels.Index.chan( mix_idx( 1 ) ) ) &  ...
                                ( PAR.Labels.Index.dyn( mix_idx ) == PAR.Labels.Index.dyn( mix_idx( 1 ) ) ) &  ...
                                ( PAR.Labels.Index.ky( mix_idx ) == PAR.Labels.Index.ky( mix_idx( 1 ) ) ) &  ...
                                ( PAR.Labels.Index.kz( mix_idx ) == PAR.Labels.Index.kz( mix_idx( 1 ) ) ) );
                            PAR.Encoding.WorkEncoding.NrFids{ 1, cmix } = nfid;
                            
                            ndyn = max( PAR.Labels.Index.dyn( mix_idx ) ) + 1;
                            PAR.Encoding.WorkEncoding.NrDyn{ 1, cmix } = ndyn;
                        end
                    end
                else
                    PAR.Encoding.WorkEncoding.NrFids = num2cell( PAR.Encoding.NrFids );
                    PAR.Encoding.WorkEncoding.NrDyn = num2cell( PAR.Encoding.NrDyn );
                end
                
                
                if isempty( PAR.Spectro.Averaging.FID_BlockSize )
                    PAR.Spectro.Averaging.FID_BlockSize = cell( size( PAR.Encoding.WorkEncoding.Typ ) );
                    PAR.Spectro.Averaging.FID_BlockSize{ 1, 1 } = PAR.Encoding.WorkEncoding.NrFids{ 1, 1 };
                    if ( PAR.Encoding.NrMixes == 2 )
                        PAR.Spectro.Averaging.FID_BlockSize{ 1, 2 } = PAR.Encoding.WorkEncoding.NrFids{ 1, 2 };
                    end
                else
                    if any( size( PAR.Spectro.Averaging.FID_BlockSize ) ~= size( PAR.Encoding.WorkEncoding.Typ ) )
                        
                        new_BlockSize = cell( size( PAR.Encoding.WorkEncoding.Typ ) );
                        new_BlockSize{ 1, 1 } = PAR.Spectro.Averaging.FID_BlockSize{ 1, 1 };
                        if ( PAR.Encoding.NrMixes == 2 )
                            new_BlockSize{ 1, 2 } = PAR.Spectro.Averaging.FID_BlockSize{ 1, 2 };
                        end
                        PAR.Spectro.Averaging.FID_BlockSize = new_BlockSize;
                    end
                end
                if ( isempty( PAR.Spectro.Averaging.FID_BlockSize{ 1, 1 } ) ||  ...
                        ( PAR.Spectro.Averaging.FID_BlockSize{ 1, 1 } > PAR.Encoding.WorkEncoding.NrFids{ 1, 1 } ) )
                    PAR.Spectro.Averaging.FID_BlockSize{ 1, 1 } = PAR.Encoding.WorkEncoding.NrFids{ 1, 1 };
                end
                if ( PAR.Encoding.NrMixes == 2 )
                    if ( isempty( PAR.Spectro.Averaging.FID_BlockSize{ 1, 2 } ) ||  ...
                            ( PAR.Spectro.Averaging.FID_BlockSize{ 1, 2 } > PAR.Encoding.WorkEncoding.NrFids{ 1, 2 } ) )
                        PAR.Spectro.Averaging.FID_BlockSize{ 1, 2 } = PAR.Encoding.WorkEncoding.NrFids{ 1, 2 };
                    end
                end
                if isempty( PAR.Spectro.Averaging.Dyn_BlockSize )
                    PAR.Spectro.Averaging.Dyn_BlockSize = cell( size( PAR.Encoding.WorkEncoding.Typ ) );
                    PAR.Spectro.Averaging.Dyn_BlockSize{ 1, 1 } = PAR.Encoding.WorkEncoding.NrDyn{ 1, 1 };
                    if ( PAR.Encoding.NrMixes == 2 )
                        PAR.Spectro.Averaging.Dyn_BlockSize{ 1, 2 } = PAR.Encoding.WorkEncoding.NrDyn{ 1, 2 };
                    end
                else
                    if any( size( PAR.Spectro.Averaging.Dyn_BlockSize ) ~= size( PAR.Encoding.WorkEncoding.Typ ) )
                        
                        new_BlockSize = cell( size( PAR.Encoding.WorkEncoding.Typ ) );
                        new_BlockSize{ 1, 1 } = PAR.Spectro.Averaging.Dyn_BlockSize{ 1, 1 };
                        if ( PAR.Encoding.NrMixes == 2 )
                            new_BlockSize{ 1, 2 } = PAR.Spectro.Averaging.Dyn_BlockSize{ 1, 2 };
                        end
                        PAR.Spectro.Averaging.Dyn_BlockSize = new_BlockSize;
                    end
                end
                if ( isempty( PAR.Spectro.Averaging.Dyn_BlockSize{ 1, 1 } ) ||  ...
                        ( PAR.Spectro.Averaging.Dyn_BlockSize{ 1, 1 } > PAR.Encoding.WorkEncoding.NrDyn{ 1, 1 } ) )
                    PAR.Spectro.Averaging.Dyn_BlockSize{ 1, 1 } = PAR.Encoding.WorkEncoding.NrDyn{ 1, 1 };
                end
                if ( PAR.Encoding.NrMixes == 2 )
                    if ( isempty( PAR.Spectro.Averaging.Dyn_BlockSize{ 1, 2 } ) ||  ...
                            ( PAR.Spectro.Averaging.Dyn_BlockSize{ 1, 2 } > PAR.Encoding.WorkEncoding.NrDyn{ 1, 2 } ) )
                        PAR.Spectro.Averaging.Dyn_BlockSize{ 1, 2 } = PAR.Encoding.WorkEncoding.NrDyn{ 1, 2 };
                    end
                end
                
                
                if isempty( PAR.Spectro.Averaging.FID_Pattern )
                    PAR.Spectro.Averaging.FID_Pattern = cell( size( PAR.Encoding.WorkEncoding.Typ ) );
                    PAR.Spectro.Averaging.FID_Pattern( 1, 1:PAR.Encoding.NrMixes ) = { 1 };
                else
                    if any( size( PAR.Spectro.Averaging.FID_Pattern ) ~= size( PAR.Encoding.WorkEncoding.Typ ) )
                        
                        new_BlockSize = cell( size( PAR.Encoding.WorkEncoding.Typ ) );
                        new_BlockSize{ 1, 1 } = PAR.Spectro.Averaging.FID_Pattern{ 1, 1 };
                        if ( PAR.Encoding.NrMixes == 2 )
                            new_BlockSize{ 1, 2 } = PAR.Spectro.Averaging.FID_Pattern{ 1, 2 };
                        end
                        PAR.Spectro.Averaging.FID_Pattern = new_BlockSize;
                    end
                end
                if isempty( PAR.Spectro.Averaging.Dyn_Pattern )
                    PAR.Spectro.Averaging.Dyn_Pattern = cell( size( PAR.Encoding.WorkEncoding.Typ ) );
                    PAR.Spectro.Averaging.Dyn_Pattern( 1, 1:PAR.Encoding.NrMixes ) = { 1 };
                else
                    if any( size( PAR.Spectro.Averaging.Dyn_Pattern ) ~= size( PAR.Encoding.WorkEncoding.Typ ) )
                        
                        new_BlockSize = cell( size( PAR.Encoding.WorkEncoding.Typ ) );
                        new_BlockSize{ 1, 1 } = PAR.Spectro.Averaging.Dyn_Pattern{ 1, 1 };
                        if ( PAR.Encoding.NrMixes == 2 )
                            new_BlockSize{ 1, 2 } = PAR.Spectro.Averaging.Dyn_Pattern{ 1, 2 };
                        end
                        PAR.Spectro.Averaging.Dyn_Pattern = new_BlockSize;
                    end
                end
                
                PAR.DataClass.UnconvertCell;
            end
        end
        
        
    end
    
    methods ( Hidden, Static )
        
        function list_struct = lab2list( lab_struct, coil_nrs_input )
            
            control_labels2consider = [ 16, 3, 2, 15,  - 1, 0 ];
            data_types = [ 5, 3, 4, 4, 2, 1 ];
            
            
            
            
            
            if ~isfield( lab_struct, 'raw_format' )
                lab_struct.raw_format = zeros( size( lab_struct.control ), 'int8' );
            end
            
            if ~isfield( lab_struct, 'as_dyn_scan_begin_time' )
                lab_struct.as_dyn_scan_begin_time = zeros( size( lab_struct.control ), 'uint32' );
            end
            
            ind_start = find( lab_struct.control == 28 );
            if ~isempty( ind_start )
                lab_struct = structfun( @( x )x( ind_start:end , : ), lab_struct, 'UniformOutput', 0 );
            end
            
            
            lab_struct.control( lab_struct.control == 0 & lab_struct.invalid == 1 ) =  - 1;
            
            max_nr_coils = 32;
            nr_of_profiles = 0;
            
            
            ind_zero = lab_struct.progress_cnt < 1;
            group_ids = unique( lab_struct.channels_active( find( ind_zero ) ) );
            for i = 1:length( group_ids )
                ind_not_zero = find( ( lab_struct.control == 0 | lab_struct.control == 16 | lab_struct.control == 3 | lab_struct.control ==  - 1 ) ...
                    & lab_struct.data_size > 0 & lab_struct.progress_cnt > 0 & lab_struct.channels_active( :, 1 ) == group_ids( i ), 1 );
                if ~isempty( ind_not_zero )
                    lab_struct.progress_cnt( ind_zero & lab_struct.channels_active( :, 1 ) == group_ids( i ) ) = lab_struct.progress_cnt( ind_not_zero );
                end
            end
            
            
            
            lab_struct.progress_cnt( lab_struct.progress_cnt > 512 ) = 1;
            
            nr_of_profiles = 0;
            for i = control_labels2consider
                ind_control = ( lab_struct.control == i & lab_struct.data_size > 0 );
                
                coils = unique( lab_struct.channels_active( ind_control, : ), 'rows' );
                rel_411 = 0;
                if any( coils( :, 1 ) == 0 )
                    coils = unique( lab_struct.progress_cnt( ind_control & lab_struct.progress_cnt ~= 0 ) );
                    if isempty( coils )
                        coils = lab_struct.progress_cnt( find( lab_struct.progress_cnt ~= 0, 1 ) );
                    end
                    rel_411 = 1;
                end
                for c = 1:size( coils, 1 )
                    if ~rel_411
                        coil_bitmask_str = '';
                        for k = 1:size( coils, 2 )
                            coil_bitmask_str = [ coil_bitmask_str, flipdim( dec2bin( coils( c, k ), max_nr_coils ), 2 ) ];
                        end
                        coil_bitmask = zeros( 1, size( coils, 2 ) * max_nr_coils );
                        cur_nr_coils = 0;
                        for j = 1:length( coil_bitmask_str )
                            coil_bitmask( j ) = str2double( coil_bitmask_str( j ) );
                            cur_nr_coils = cur_nr_coils + ( str2double( coil_bitmask_str( j ) ) == 1 );
                        end
                        
                        label_ind = find( ind_control & all( bsxfun( @eq, lab_struct.channels_active, coils( c, : ) ), 2 ) );
                        nr_of_labels2write = cur_nr_coils * length( label_ind );
                        if isempty( coil_nrs_input )
                            lab_struct.coded_data_size( label_ind ) = lab_struct.data_size( label_ind );
                        end
                    else
                        cur_nr_coils = double( coils( c ) );
                        label_ind = find( ind_control & lab_struct.progress_cnt == coils( c ) );
                        nr_of_labels2write = cur_nr_coils * length( label_ind );
                    end
                    if ~isempty( coil_nrs_input ) && ~isempty( label_ind )
                        chan_grp = lab_struct.chan_grp( label_ind( 1 ) );
                        coil_nrs = coil_nrs_input( coil_nrs_input( :, 2 ) == chan_grp, 1 )';
                        if isempty( coil_nrs )
                            coil_nrs = max( coil_nrs_input( :, 1 ) ) + 1;
                        end
                        cur_nr_coils = length( coil_nrs );
                        nr_of_labels2write = cur_nr_coils * length( label_ind );
                    end
                    nr_of_profiles = nr_of_profiles + nr_of_labels2write;
                end
            end
            
            
            ind_dyn_time = find( lab_struct.control == 13 );
            if ~isempty( ind_dyn_time )
                if ind_dyn_time( end  ) ~= length( lab_struct.control )
                    ind_dyn_time( end  + 1 ) = length( lab_struct.control );
                end
                for i = 1:length( ind_dyn_time ) - 1
                    if ind_dyn_time( i ) - 1 > 0
                        lab_struct.as_dyn_scan_begin_time( ind_dyn_time( i ) - 1:ind_dyn_time( i + 1 ) - 1 ) = lab_struct.as_dyn_scan_begin_time( ind_dyn_time( i ) );
                    end
                end
            else
                lab_struct.as_dyn_scan_begin_time( : ) = 0;
            end
            
            list_struct.typ = zeros( nr_of_profiles, 1, 'uint8' );
            list_struct.mix = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.dyn = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.card = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.echo = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.loca = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.chan = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.extr1 = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.extr2 = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.ky = zeros( nr_of_profiles, 1, 'int32' );
            list_struct.kz = zeros( nr_of_profiles, 1, 'int32' );
            list_struct.na = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.aver = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.sign = zeros( nr_of_profiles, 1, 'int8' );
            list_struct.rf = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.grad = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.enc = zeros( nr_of_profiles, 1, 'int16' );
            list_struct.rtop = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.rr = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.size = zeros( nr_of_profiles, 1, 'uint64' );
            list_struct.offset = zeros( nr_of_profiles, 1, 'uint64' );
            list_struct.random_phase = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.meas_phase = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.pda_index = zeros( nr_of_profiles, 1, 'uint16' );
            list_struct.pda_fac = ones( nr_of_profiles, 1, 'double' );
            list_struct.dyn_time = zeros( nr_of_profiles, 1, 'uint32' );
            list_struct.coded_size = zeros( nr_of_profiles, 1, 'uint32' );
            list_struct.chan_grp = zeros( nr_of_profiles, 1, 'uint32' );
            list_struct.format = zeros( nr_of_profiles, 1, 'uint8' );
            
            order_vec = zeros( nr_of_profiles, 1, 'uint64' );
            
            cur_pos = 1;
            for i = control_labels2consider
                ind_control = ( lab_struct.control == i & lab_struct.data_size > 0 );
                
                coils = unique( lab_struct.channels_active( ind_control, : ), 'rows' );
                rel_411 = 0;
                if any( coils( :, 1 ) == 0 )
                    coils = unique( lab_struct.progress_cnt( ind_control & lab_struct.progress_cnt ~= 0 ) );
                    if isempty( coils )
                        coils = lab_struct.progress_cnt( find( lab_struct.progress_cnt ~= 0, 1 ) );
                    end
                    rel_411 = 1;
                end
                
                if rel_411
                    sumcoils = cumsum( double( coils ) );
                    sumcoils = [ 0;sumcoils ];
                end
                for c = 1:size( coils, 1 )
                    if ~rel_411
                        coil_bitmask_str = '';
                        for k = 1:size( coils, 2 )
                            coil_bitmask_str = [ coil_bitmask_str, flipdim( dec2bin( coils( c, k ), max_nr_coils ), 2 ) ];
                        end
                        coil_bitmask = zeros( 1, size( coils, 2 ) * max_nr_coils );
                        cur_nr_coils = 0;
                        for j = 1:length( coil_bitmask_str )
                            coil_bitmask( j ) = str2double( coil_bitmask_str( j ) );
                            cur_nr_coils = cur_nr_coils + ( str2double( coil_bitmask_str( j ) ) == 1 );
                        end
                        
                        label_ind = find( ind_control & all( bsxfun( @eq, lab_struct.channels_active, coils( c, : ) ), 2 ) );
                        nr_of_labels2write = cur_nr_coils * length( label_ind );
                        if isempty( coil_nrs_input )
                            lab_struct.coded_data_size( label_ind ) = lab_struct.data_size( label_ind );
                        end
                        coil_nrs = find( coil_bitmask ) - 1;
                    else
                        cur_nr_coils = double( coils( c ) );
                        label_ind = find( ind_control & lab_struct.progress_cnt == coils( c ) );
                        nr_of_labels2write = cur_nr_coils * length( label_ind );
                        coil_nrs = sumcoils( c ) + ( 0:coils( c ) - 1 );
                    end
                    if ~isempty( coil_nrs_input ) && ~isempty( label_ind )
                        chan_grp = lab_struct.chan_grp( label_ind( 1 ) );
                        coil_nrs = coil_nrs_input( coil_nrs_input( :, 2 ) == chan_grp, 1 )';
                        if isempty( coil_nrs )
                            coil_nrs = max( coil_nrs_input( :, 1 ) ) + 1;
                        end
                        cur_nr_coils = length( coil_nrs );
                        nr_of_labels2write = cur_nr_coils * length( label_ind );
                    end
                    
                    list_struct.typ( cur_pos:cur_pos + nr_of_labels2write - 1 ) = data_types( control_labels2consider == i );
                    list_struct.mix( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.mix_nr( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.dyn( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.dynamic_scan_nr( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.card( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.cardiac_phase_nr( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.echo( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.echo_nr( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.loca( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.location_nr( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.chan( cur_pos:cur_pos + nr_of_labels2write - 1 ) = repmat( coil_nrs', [ length( label_ind ), 1 ] );
                    list_struct.extr1( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.row_nr( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.extr2( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.extra_attr_nr( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.ky( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.e1_profile_nr( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.kz( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.e2_profile_nr( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.na( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.e3_profile_nr( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.aver( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.measurement_nr( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.sign( cur_pos:cur_pos + nr_of_labels2write - 1 ) =  - 2 * reshape( repmat( lab_struct.measurement_sign( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 ) + 1;
                    list_struct.rf( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.rf_echo_nr( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.grad( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.grad_echo_nr( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.enc( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.enc_time( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.rtop( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.rtop_offset( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.rr( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.rr_interval( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.size( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.data_size( label_ind )' ./ cur_nr_coils, [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    if lab_struct.raw_format( label_ind( 1 ) ) == 6
                        list_struct.offset( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.data_offset( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    else
                        list_struct.offset( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( double( repmat( lab_struct.data_offset( label_ind )', [ cur_nr_coils, 1 ] ) ) ...
                            + double( repmat( lab_struct.data_size( label_ind )' ./ cur_nr_coils, [ cur_nr_coils, 1 ] ) ) ...
                            .* repmat( ( 0:cur_nr_coils - 1 )', [ 1, length( label_ind ) ] ), nr_of_labels2write, 1 );
                    end
                    list_struct.random_phase( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.random_phase( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.meas_phase( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.measurement_phase( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.pda_index( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.gain_setting_index( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.dyn_time( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.as_dyn_scan_begin_time( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    temp_coded = repmat( zeros( 1, length( label_ind ) ), [ cur_nr_coils, 1 ] );
                    temp_coded( end , : ) = lab_struct.coded_data_size( label_ind )';
                    list_struct.coded_size( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( temp_coded, nr_of_labels2write, 1 );
                    list_struct.chan_grp( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.chan_grp( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    list_struct.format( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( lab_struct.raw_format( label_ind )', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    order_vec( cur_pos:cur_pos + nr_of_labels2write - 1 ) = reshape( repmat( label_ind', [ cur_nr_coils, 1 ] ), nr_of_labels2write, 1 );
                    
                    cur_pos = cur_pos + nr_of_labels2write;
                end
            end
            [ sorted_order, ind_sorted ] = sort( order_vec );
            list_struct = structfun( @( x )x( ind_sorted ), list_struct, 'UniformOutput', 0 );
            
            list_struct.ky_label = list_struct.ky;
            list_struct.kz_label = list_struct.kz;
            
            
            
            list_struct.coded_size( list_struct.format ~= 6 ) = list_struct.size( list_struct.format ~= 6 );
            
            
            
            
            if all( list_struct.rtop( list_struct.typ == 1 ) == 0 ) && ~all( list_struct.rr( list_struct.typ == 1 ) == 0 )
                list_struct.rtop( : ) = list_struct.rr( : );
                list_struct.rr( : ) = 0;
            end
            
        end
        function [ v, lab_struct ] = get_scan_parameter( filename, lab_struct )
            
            try
                MAX_PARAMETER = 32;
                
                par_marker_ver_1_0 =  - 99;
                par_marker_ver_2_0 =  - 98;
                version = 2;
                
                v = [  ];
                
                
                
                v.Spectro = false;
                
                v.Rel4 = 0;
                
                junk_data_ind = find( lab_struct.control == 2 );
                parameter_found = 0;
                
                if ~isempty( junk_data_ind )
                    fid = fopen( filename, 'r' );
                    user_def_arrays = 1;
                    
                    cur_parameter_vec_float = 1;
                    cur_parameter_vec_int = 1;
                    parameter_vectors_float = [  ];
                    parameter_vectors_int = [  ];
                    parameter_sets = [  ];
                    
                    for i = 1:length( junk_data_ind )
                        fseek( fid, double( lab_struct.data_offset( junk_data_ind( i ) ) ),  - 1 );
                        p = fread( fid, double( lab_struct.data_size( junk_data_ind( i ) ) ) / 2, 'short' );
                        
                        if ~isempty( p )
                            if ( p( 1 ) ~= par_marker_ver_1_0 ) && ( p( 1 ) ~= par_marker_ver_2_0 )
                                
                                fseek( fid, double( lab_struct.data_offset( junk_data_ind( i ) ) ),  - 1 );
                                p = fread( fid, double( lab_struct.data_size( junk_data_ind( i ) ) ) / 4, 'float' );
                                
                                if ( p( 1 ) ~= par_marker_ver_1_0 ) && ( p( 1 ) ~= par_marker_ver_2_0 )
                                    fseek( fid, double( lab_struct.data_offset( junk_data_ind( i ) ) ),  - 1 );
                                    p = fread( fid, double( lab_struct.data_size( junk_data_ind( i ) ) ) / 4, 'int32' );
                                    if ( p( 1 ) ~= par_marker_ver_1_0 ) && ( p( 1 ) ~= par_marker_ver_2_0 )
                                        p = [  ];
                                    else
                                        
                                        
                                        lab_struct.control( junk_data_ind( i ) ) =  - 2;
                                        
                                        parameter_vectors_int( cur_parameter_vec_int, : ) = p;
                                        cur_parameter_vec_int = cur_parameter_vec_int + 1;
                                        if p( 1 ) == par_marker_ver_1_0
                                            version = 1;
                                        end
                                    end
                                else
                                    
                                    
                                    lab_struct.control( junk_data_ind( i ) ) =  - 2;
                                    
                                    parameter_vectors_float( cur_parameter_vec_float, : ) = p;
                                    cur_parameter_vec_float = cur_parameter_vec_float + 1;
                                    if p( 1 ) == par_marker_ver_1_0
                                        version = 1;
                                    end
                                end
                                
                            else
                                if p( 2 ) ==  - 1
                                    
                                    
                                    p = [ p( 1:2:end  );zeros( length( p( 2:2:end  ) ), 1 ) ];
                                end
                                
                                
                                
                                lab_struct.control( junk_data_ind( i ) ) =  - 2;
                                
                                parameter_vectors_int( cur_parameter_vec_int, : ) = p;
                                cur_parameter_vec_int = cur_parameter_vec_int + 1;
                                if p( 1 ) == par_marker_ver_1_0
                                    version = 1;
                                end
                            end
                        end
                    end
                    
                    cur_set = 1;
                    
                    
                    
                    if version == 2
                        if ~isempty( parameter_vectors_float )
                            parameter_sets_float = unique( parameter_vectors_float( :, 2 ) )';
                            for i = parameter_sets_float
                                start_ind = 3;
                                if parameter_vectors_float( 1 ) == par_marker_ver_2_0
                                    start_ind = 4;
                                end
                                set_ind = find( parameter_vectors_float( :, 2 ) == i );
                                
                                
                                if round( 10 * i ) / 10 == 3.1
                                    ind = 1;
                                    
                                else
                                    ind = i + 1;
                                end
                                cur_row = 1;
                                parameter_sets{ ind } = [  ];
                                finished = 0;
                                
                                
                                
                                
                                
                                
                                while ~finished
                                    
                                    
                                    
                                    
                                    
                                    nr_parameters_without_header = parameter_vectors_float( set_ind( cur_row ), 3 );
                                    nr_rows = 1;
                                    cur_nr_parameters = size( parameter_vectors_float, 2 ) - ( start_ind - 1 );
                                    parameter_vector_complete = 0;
                                    while ~parameter_vector_complete
                                        if ( cur_nr_parameters / nr_parameters_without_header ) < 1
                                            nr_rows = nr_rows + 1;
                                            cur_nr_parameters = cur_nr_parameters + size( parameter_vectors_float, 2 ) - ( start_ind - 1 );
                                        else
                                            parameter_vector_complete = 1;
                                        end
                                    end
                                    
                                    
                                    temp_pars = reshape( parameter_vectors_float( set_ind( cur_row:cur_row + nr_rows - 1 ), start_ind:end  ).', 1, [  ] );
                                    temp_pars = temp_pars( 1:nr_parameters_without_header );
                                    
                                    
                                    
                                    parameter_sets{ ind } = [ parameter_sets{ ind }, temp_pars ];
                                    cur_row = cur_row + nr_rows;
                                    if cur_row > size( set_ind, 1 )
                                        finished = 1;
                                    end
                                end
                                total_length = length( parameter_sets{ ind } );
                                parameter_sets{ ind } = [ parameter_vectors_float( set_ind( 1 ), 1:start_ind - 1 ), parameter_sets{ ind } ];
                                parameter_sets{ ind }( 3 ) = total_length;
                                cur_set = cur_set + 1;
                            end
                        end
                    else
                        for i = 1:size( parameter_vectors_float, 1 )
                            parameter_sets{ parameter_vectors_float( i, 2 ) + 1 } = parameter_vectors_float( i, : );
                        end
                    end
                    
                    
                    
                    if version == 2
                        if ~isempty( parameter_vectors_int )
                            if any( parameter_vectors_int( :, 2 ) < 0 )
                                parameter_vectors_int( :, 2 ) = 0:length( parameter_vectors_int( :, 2 ) ) - 1;
                            end
                            parameter_sets_int = unique( parameter_vectors_int( :, 2 ) )';
                            for i = parameter_sets_int
                                start_ind = 3;
                                if parameter_vectors_int( 1 ) == par_marker_ver_2_0
                                    start_ind = 4;
                                end
                                set_ind = find( parameter_vectors_int( :, 2 ) == i );
                                
                                
                                if round( 10 * i ) / 10 == 3.1
                                    ind = 1;
                                else
                                    ind = i + 1;
                                end
                                
                                parameter_sets{ ind } = [  ];
                                finished = 0;
                                cur_row = 1;
                                
                                
                                
                                
                                
                                while ~finished
                                    
                                    
                                    
                                    
                                    
                                    nr_parameters_without_header = parameter_vectors_int( set_ind( cur_row ), 3 );
                                    nr_rows = 1;
                                    cur_nr_parameters = size( parameter_vectors_int, 2 ) - ( start_ind - 1 );
                                    parameter_vector_complete = 0;
                                    while ~parameter_vector_complete
                                        if ( cur_nr_parameters / nr_parameters_without_header ) < 1
                                            nr_rows = nr_rows + 1;
                                            cur_nr_parameters = cur_nr_parameters + size( parameter_vectors_int, 2 ) - ( start_ind - 1 );
                                        else
                                            parameter_vector_complete = 1;
                                        end
                                    end
                                    
                                    
                                    temp_pars = reshape( parameter_vectors_int( set_ind( cur_row:cur_row + nr_rows - 1 ), start_ind:end  ).', 1, [  ] );
                                    temp_pars = temp_pars( 1:nr_parameters_without_header );
                                    
                                    
                                    
                                    parameter_sets{ ind } = [ parameter_sets{ ind }, temp_pars ];
                                    cur_row = cur_row + nr_rows;
                                    if cur_row > size( set_ind, 1 )
                                        finished = 1;
                                    end
                                end
                                total_length = length( parameter_sets{ ind } );
                                parameter_sets{ ind } = [ parameter_vectors_int( set_ind( 1 ), 1:start_ind - 1 ), parameter_sets{ ind } ];
                                parameter_sets{ ind }( 3 ) = total_length;
                                cur_set = cur_set + 1;
                            end
                        end
                    else
                        for i = 1:size( parameter_vectors_int, 1 )
                            parameter_sets{ parameter_vectors_int( i, 2 ) + 1 } = parameter_vectors_int( i, : );
                        end
                    end
                    
                    
                    
                    
                    if ~isempty( parameter_sets ) && round( 10 * parameter_sets{ 1 }( 2 ) ) / 10 == 3.1
                        parameter_set_start_inds = find( parameter_sets{ 1 } ==  - 98 );
                        set_ids = parameter_sets{ 1 }( parameter_set_start_inds + 1 );
                        parameter_vector_lengths = parameter_sets{ 1 }( parameter_set_start_inds + 2 ) * 3;
                        valid_sets = ( set_ids == round( set_ids ) ) & ( set_ids >= 0 ) & parameter_vector_lengths == floor( parameter_vector_lengths );
                        parameter_set_start_inds = parameter_set_start_inds( valid_sets );
                        set_ids = set_ids( valid_sets );
                        remaining_sets = unique( set_ids );
                        all_parameters = cell( 1, max( remaining_sets ) + 1 );
                        cur_set = 1;
                        for i = 1:length( parameter_set_start_inds )
                            if ismember( set_ids( i ), remaining_sets )
                                cur_parameter_set_length = parameter_sets{ 1 }( parameter_set_start_inds( i ) + 2 ) + 3;
                                if ( i == length( parameter_set_start_inds ) )
                                    new_parameter_sets{ set_ids( i ) + 1 } = parameter_sets{ 1 }( parameter_set_start_inds( i ):end  );
                                else
                                    new_parameter_sets{ set_ids( i ) + 1 } = parameter_sets{ 1 }( parameter_set_start_inds( i ):parameter_set_start_inds( i + 1 ) - 1 );
                                end
                                if cur_parameter_set_length == length( new_parameter_sets{ set_ids( i ) + 1 } )
                                    remaining_sets( remaining_sets == set_ids( i ) ) = [  ];
                                else
                                    new_parameter_sets{ set_ids( i ) + 1 } = parameter_sets{ 1 }( parameter_set_start_inds( i ):parameter_set_start_inds( i ) + cur_parameter_set_length - 1 );
                                end
                                
                                all_parameters{ set_ids( i ) + 1 } = [ all_parameters{ set_ids( i ) + 1 }, new_parameter_sets{ set_ids( i ) + 1 }' ];
                                cur_set = cur_set + 1;
                            end
                        end
                        
                        try
                            if ( ~isempty( remaining_sets ) )
                                for i = 1:length( remaining_sets )
                                    indices = ones( 1, size( all_parameters{ remaining_sets( i ) + 1 }, 2 ) );
                                    vec = all_parameters{ remaining_sets( i ) + 1 };
                                    for j = 1:size( vec, 1 )
                                        if ( all( vec( j, : ) == vec( j, 1 ) ) )
                                            new_parameter_sets{ remaining_sets( i ) + 1 }( j ) = vec( j, 1 );
                                            indices = indices + 1;
                                        else
                                            new_parameter_sets{ remaining_sets( i ) + 1 }( j ) = median( vec( j, : ) );
                                            ind_wrong = find( vec( j, : ) ~= new_parameter_sets{ remaining_sets( i ) + 1 }( j ) );
                                            for k = ind_wrong
                                                if ( j < 1 && vec( j - 1, k ) == new_parameter_sets{ remaining_sets( i ) + 1 }( j ) )
                                                    vec( 2:end , k ) = vec( 1:end  - 1, k );
                                                elseif ( j < size( vec, 1 ) && vec( j + 1, k ) == new_parameter_sets{ remaining_sets( i ) + 1 }( j ) )
                                                    vec( 1:end  - 1, k ) = vec( 2:end , k );
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        parameter_sets = new_parameter_sets;
                    end
                    
                    
                    cur_nav_nr = 1;
                    for i = 1:length( parameter_sets )
                        if ~isempty( parameter_sets{ i } )
                            p = parameter_sets{ i };
                            if ~isempty( p )
                                parameter_set = p( 2 );
                                start_ind = 3;
                                if p( 1 ) == par_marker_ver_2_0
                                    start_ind = 4;
                                end
                                
                                
                                switch ( parameter_set )
                                    
                                    case 0
                                        try
                                            parameter_found = 1;
                                            
                                            enc_pars.nr_mixes = p( start_ind );
                                            enc_pars.nr_echoes = p( start_ind + 1 );
                                            if p( start_ind + 2 ) == 0
                                                p( start_ind + 2 ) = enc_pars.nr_mixes * enc_pars.nr_echoes;
                                            end
                                            nr_elements = p( start_ind + 2 );
                                            
                                            
                                            enc_pars.scan_technique = p( start_ind + 23 );
                                            if any( [ 27, 28, 29, 30, 31, 32, 36, 37, 38, 47 ] == enc_pars.scan_technique )
                                                enc_pars.nr_encs = nr_elements / enc_pars.nr_mixes / enc_pars.nr_echoes;
                                                nr_elements = ( enc_pars.nr_encs + 1 ) * enc_pars.nr_mixes * enc_pars.nr_echoes;
                                            end
                                            
                                            
                                            if nr_elements == 0
                                                nr_elements = enc_pars.nr_mixes * enc_pars.nr_echoes;
                                                enc_pars.nr_encs = 1;
                                            else
                                                enc_pars.nr_encs = nr_elements / enc_pars.nr_mixes / enc_pars.nr_echoes;
                                            end
                                            
                                            for i = 1:6
                                                enc_pars.voxel_size( i ) = p( i + start_ind + 2 );
                                            end
                                            enc_pars.scan_mode = p( start_ind + 8 );
                                            enc_pars.acq_mode = p( start_ind + 9 );
                                            enc_pars.fast_imaging_mode = p( start_ind + 10 );
                                            enc_pars.TR( 1 ) = p( start_ind + 11 );
                                            enc_pars.TR( 2 ) = p( start_ind + 12 );
                                            enc_pars.flip_angle( 1 ) = p( start_ind + 13 );
                                            enc_pars.flip_angle( 2 ) = p( start_ind + 14 );
                                            enc_pars.retro_phases = p( start_ind + 15 );
                                            switch p( start_ind + 16 )
                                                case 1
                                                    enc_pars.rotate = 'RotateLeft';
                                                case 0
                                                    enc_pars.rotate = 'None';
                                                case  - 1
                                                    enc_pars.rotate = 'RotateRight';
                                                case { 2,  - 2 }
                                                    enc_pars.rotate = 'Flip';
                                            end
                                            enc_pars.UTE = p( start_ind + 17 );
                                            enc_pars.coshball = p( start_ind + 18 );
                                            enc_pars.tfe_factor = p( start_ind + 19 );
                                            enc_pars.nr_db_imgs = p( start_ind + 20 );
                                            
                                            enc_pars.patient_position = p( start_ind + 21 );
                                            enc_pars.patient_orientation = p( start_ind + 22 );
                                            
                                            enc_pars.slice_gaps = p( start_ind + 24:start_ind + 26 );
                                            enc_pars.wfs = p( start_ind + 27 );
                                            enc_pars.flow_comp = p( start_ind + 28 );
                                            enc_pars.venc = p( start_ind + 29:start_ind + 31 );
                                            enc_pars.mtc = p( start_ind + 32 );
                                            enc_pars.spir = p( start_ind + 33 );
                                            enc_pars.epi_factor = p( start_ind + 34 );
                                            enc_pars.dynamic_scan = p( start_ind + 35 );
                                            enc_pars.diffusion = p( start_ind + 36 );
                                            enc_pars.diff_echo_time = p( start_ind + 37 );
                                            enc_pars.diff_nr_weigthings = p( start_ind + 38 );
                                            enc_pars.diff_nr_oris = p( start_ind + 39 );
                                            enc_pars.spiral_leading_samples = p( start_ind + 40 );
                                            enc_pars.field_strength = p( start_ind + 41 );
                                            enc_pars.resonance_freq = p( start_ind + 42 );
                                            enc_pars.kt_factor = p( start_ind + 43 );
                                            enc_pars.card_sync = p( start_ind + 44 );
                                            enc_pars.resp_sync = p( start_ind + 45 );
                                            enc_pars.resp_comp = p( start_ind + 46 );
                                            enc_pars.angio_mode = p( start_ind + 47 );
                                            enc_pars.quant_flow = p( start_ind + 48 );
                                            enc_pars.scan_date = p( start_ind + 49 );
                                            enc_pars.scan_time = p( start_ind + 50 );
                                            enc_pars.scan_dur = p( start_ind + 51 );
                                            enc_pars.hp_interval = p( start_ind + 52 );
                                            enc_pars.pc_acq_type = p( start_ind + 53 );
                                            enc_pars.scan_type = p( start_ind + 54 );
                                            enc_pars.kt_type = p( start_ind + 55 );
                                            enc_pars.kt_recon_mode = p( start_ind + 56 );
                                            enc_pars.is_coca_scan = p( start_ind + 57 );
                                            enc_pars.qbc_stack = p( start_ind + 58 );
                                            enc_pars.asl_mode = p( start_ind + 59 );
                                            enc_pars.asl_no_label_types = p( start_ind + 60 );
                                            enc_pars.fear_factor = p( start_ind + 62 );
                                            
                                            enc_pars.sample_sets = p( start_ind + 44 );
                                            
                                        catch
                                        end
                                        
                                        
                                    case 1
                                        enc_pars.min_enc_numbers = p( start_ind:nr_elements + start_ind - 1 );
                                        
                                        
                                    case 2
                                        enc_pars.max_enc_numbers = p( start_ind:nr_elements + start_ind - 1 );
                                        
                                        
                                    case 3
                                        enc_pars.spectrum_origin = p( start_ind:nr_elements + start_ind - 1 );
                                        
                                        
                                    case 4
                                        enc_pars.recon_res = p( start_ind:enc_pars.nr_encs * enc_pars.nr_mixes + start_ind - 1 );
                                        
                                        
                                    case 5
                                        enc_pars.oversampling_factors = p( start_ind:nr_elements + start_ind - 1 );
                                        
                                        
                                    case 6
                                        if version == 2
                                            nr_pars = p( 3 );
                                            enc_pars.ad_hoc_array = p( start_ind:start_ind + nr_pars - 1 );
                                        else
                                            enc_pars.ad_hoc_array = p( start_ind:end  );
                                        end
                                        
                                        
                                    case 7
                                        nr_pars = p( 3 );
                                        enc_pars.pda_ampl_factors = p( start_ind:start_ind + nr_pars - 1 );
                                        enc_pars.pda_ampl_factors = complex( enc_pars.pda_ampl_factors( 1:2:end  ), enc_pars.pda_ampl_factors( 2:2:end  ) );
                                        
                                        
                                    case 8
                                        nr_pars = p( 3 );
                                        nr_composites = p( 4 );
                                        enc_pars.geo = p( start_ind:start_ind + nr_pars - 1 );
                                        enc_pars.geo = reshape( enc_pars.geo, [  ], nr_composites )';
                                        
                                        
                                    case { 9, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30 }
                                        nr_pars = p( 3 );
                                        nr_prep = p( nr_pars + start_ind - 1 );
                                        if nr_prep ~= 0
                                            eval( [ 'enc_pars.nav.Prep', num2str( cur_nav_nr ), '  = p(start_ind+1:min( length(p), start_ind+nr_prep));' ] );
                                        end
                                        eval( [ 'enc_pars.nav.Acq', num2str( cur_nav_nr ), '  = p(start_ind+nr_prep+1:min( length(p), nr_pars+start_ind-2));' ] );
                                        cur_nav_nr = cur_nav_nr + 1;
                                        
                                        
                                    case 10
                                        enc_pars.te = p( start_ind:nr_elements + start_ind - 1 );
                                        
                                        
                                    case 11
                                        nr_pars = p( 3 );
                                        enc_pars.concom = p( start_ind:start_ind + nr_pars - 1 );
                                        
                                        
                                    case 12
                                        nr_pars = p( 4 );
                                        enc_pars.nus_enc_nrs = p( start_ind + 2:start_ind + 2 + nr_pars - 1 );
                                        enc_pars.nus_method = p( start_ind + 1 );
                                        enc_pars.nus_samples = p( start_ind );
                                        
                                        
                                    case 13
                                        nr_pars = p( 3 );
                                        enc_pars.diff = p( start_ind:start_ind + nr_pars - 1 );
                                        
                                        
                                    case 14
                                        nr_pars = p( 3 );
                                        enc_pars.geo_corr = p( start_ind:start_ind + nr_pars - 1 );
                                        
                                        
                                    case 15
                                        nr_pars = p( 3 );
                                        enc_pars.coil_nrs = reshape( p( start_ind:start_ind + nr_pars - 1 ), 2, [  ] )';
                                        if ~isempty( find( all( enc_pars.coil_nrs ==  - 1, 2 ), 1 ) - 1 )
                                            enc_pars.coil_nrs = enc_pars.coil_nrs( 1:find( all( enc_pars.coil_nrs ==  - 1, 2 ), 1 ) - 1, : );
                                        end
                                        
                                        
                                        
                                        
                                        chan_grps = unique( enc_pars.coil_nrs( :, 2 ) );
                                        for k = 1:length( chan_grps )
                                            subset_ind = find( enc_pars.coil_nrs( :, 2 ) == chan_grps( k ) );
                                            subset = enc_pars.coil_nrs( subset_ind, : );
                                            [ subset, ind_sorted ] = sortrows( subset );
                                            duplicates_ind = find( diff( subset( :, 1 ) ) == 0 );
                                            max_coil_nr = max( subset( :, 1 ) );
                                            for j = 1:length( duplicates_ind )
                                                subset( duplicates_ind( j ), 1 ) = max_coil_nr + j;
                                            end
                                            enc_pars.coil_nrs( subset_ind( ind_sorted ), : ) = subset;
                                        end
                                        
                                        stacks = unique( enc_pars.coil_nrs( :, 2 ) );
                                        max_bitmask_length = 0;
                                        for j = 1:length( stacks )
                                            cur_coil_nrs = enc_pars.coil_nrs( enc_pars.coil_nrs( :, 2 ) == stacks( j ), 1 );
                                            bitmask{ j } = MRparameter.coil_nrs2bitmask( cur_coil_nrs );
                                            max_bitmask_length = max( [ max_bitmask_length, length( bitmask{ j } ) ] );
                                        end
                                        lab_struct.channels_active = repmat( lab_struct.channels_active, [ 1, max_bitmask_length ] ) .* 0;
                                        lab_struct.channels_active( :, 1 ) = 1;
                                        
                                        chan_grps_typ1 = unique( lab_struct.chan_grp( lab_struct.control == 0 ) );
                                        for j = 1:length( stacks )
                                            if ( j <= length( chan_grps_typ1 ) )
                                                lab_struct.chan_grp( lab_struct.chan_grp == chan_grps_typ1( j ) ) = stacks( j );
                                            end
                                            stack_mask = lab_struct.chan_grp == stacks( j );
                                            for k = 1:length( bitmask{ j } )
                                                lab_struct.channels_active( stack_mask, k ) = bitmask{ j }( k );
                                            end
                                        end
                                        v.Rel4 = 1;
                                        
                                        
                                    case 16
                                        nr_pars = p( 3 );
                                        enc_pars.multivenc = p( start_ind:start_ind + nr_pars - 1 );
                                        
                                        
                                    otherwise
                                        nr_pars = p( 3 );
                                        enc_pars.user_def{ user_def_arrays } = p( start_ind:start_ind + nr_pars - 1 );
                                        user_def_arrays = user_def_arrays + 1;
                                end
                            end
                        end
                    end
                    fclose( fid );
                    
                    if parameter_found
                        for i = 1:nr_elements
                            if ( enc_pars.max_enc_numbers( i ) < enc_pars.min_enc_numbers( i ) )
                                enc_pars.max_enc_numbers( i ) =  - enc_pars.max_enc_numbers( i );
                                enc_pars.min_enc_numbers( i ) =  - enc_pars.min_enc_numbers( i );
                                enc_pars.spectrum_signs( i ) =  - 1;
                            else
                                enc_pars.spectrum_signs( i ) = 1;
                            end
                        end
                        
                        switch ( enc_pars.scan_mode )
                            case 1
                                v.ScanMode = '2D';
                            case 2
                                v.ScanMode = '3D';
                            case 3
                                v.ScanMode = 'MS';
                            case 4
                                v.ScanMode = 'M2D';
                            case 5
                                v.ScanMode = 'SV';
                            case 6
                                v.ScanMode = '1D';
                        end
                        
                        switch ( enc_pars.acq_mode )
                            case 0
                                v.AcquisitionMode = 'Cartesian';
                            case 1
                                v.AcquisitionMode = 'Radial';
                            case 2
                                v.AcquisitionMode = 'Spiral';
                            case 3
                                v.AcquisitionMode = 'Propeller';
                        end
                        
                        switch ( enc_pars.fast_imaging_mode )
                            case 0
                                v.FastImagingMode = 'None';
                            case 1
                                v.FastImagingMode = 'TSE';
                            case 2
                                v.FastImagingMode = 'TFE';
                            case 3
                                v.FastImagingMode = 'EPI';
                            case 4
                                v.FastImagingMode = 'GRASE';
                            case 5
                                v.FastImagingMode = 'TFEEPI';
                            case 6
                                v.FastImagingMode = 'TSI';
                        end
                        
                        switch ( enc_pars.patient_position )
                            case 0
                                v.PatientPosition = 'HeadFirst';
                            case 1
                                v.PatientPosition = 'FeetFirst';
                        end
                        
                        switch ( enc_pars.patient_orientation )
                            case 0
                                v.PatientOrientation = 'Supine';
                            case 1
                                v.PatientOrientation = 'Prone';
                            case 2
                                v.PatientOrientation = 'Left';
                            case 3
                                v.PatientOrientation = 'Right';
                        end
                        
                        switch ( enc_pars.scan_technique )
                            case 0
                                v.ScanTechnique = 'MSE';
                            case 1
                                v.ScanTechnique = 'MSEEPI';
                            case 2
                                v.ScanTechnique = 'SE';
                            case 3
                                v.ScanTechnique = 'DIFFSE';
                            case 4
                                v.ScanTechnique = 'SEEPI';
                            case 5
                                v.ScanTechnique = 'TSE';
                            case 6
                                v.ScanTechnique = 'GRASE';
                            case 7
                                v.ScanTechnique = 'IR';
                            case 8
                                v.ScanTechnique = 'DIFFIR';
                            case 9
                                v.ScanTechnique = 'DUALIR';
                            case 10
                                v.ScanTechnique = 'IREPI';
                            case 11
                                v.ScanTechnique = 'TIR';
                            case 12
                                v.ScanTechnique = 'TIREPI';
                            case 13
                                v.ScanTechnique = 'MIX';
                            case 14
                                v.ScanTechnique = 'MIXEPI';
                            case 15
                                v.ScanTechnique = 'TMIX';
                            case 16
                                v.ScanTechnique = 'TMIXEPI';
                            case 17
                                v.ScanTechnique = 'FFE';
                            case 18
                                v.ScanTechnique = 'T1FFE';
                            case 19
                                v.ScanTechnique = 'T2FFE';
                            case 20
                                v.ScanTechnique = 'BALANCED_FFE';
                            case 21
                                v.ScanTechnique = 'FFEEPI';
                            case 22
                                v.ScanTechnique = 'TFE';
                            case 23
                                v.ScanTechnique = 'T1TFE';
                            case 24
                                v.ScanTechnique = 'T2TFE';
                            case 25
                                v.ScanTechnique = 'BALANCEDTFE';
                            case 26
                                v.ScanTechnique = 'TFEEPI';
                            case 27
                                v.ScanTechnique = '1DSI';
                            case 28
                                v.ScanTechnique = '1DSIFID';
                            case 29
                                v.ScanTechnique = '1DSIECHO';
                            case 30
                                v.ScanTechnique = '2DSI';
                            case 31
                                v.ScanTechnique = '2DSIFID';
                            case 32
                                v.ScanTechnique = '2DSIECHO';
                            case 33
                                v.ScanTechnique = 'ECHO';
                            case 34
                                v.ScanTechnique = 'COLLECT';
                            case 35
                                v.ScanTechnique = 'BIN';
                            case 36
                                v.ScanTechnique = 'TSI1SL';
                            case 37
                                v.ScanTechnique = 'TSIMS';
                            case 38
                                v.ScanTechnique = '2DSI_MS';
                            case 39
                                v.ScanTechnique = 'VS';
                            case 40
                                v.ScanTechnique = 'FID';
                            case 41
                                v.ScanTechnique = 'DVFID';
                            case 42
                                v.ScanTechnique = 'ADIAB';
                            case 43
                                v.ScanTechnique = 'BLOCK';
                            case 44
                                v.ScanTechnique = 'T1';
                            case 45
                                v.ScanTechnique = 'T2';
                            case 46
                                v.ScanTechnique = 'TS';
                            case 47
                                v.ScanTechnique = '3DSI';
                        end
                        v.Spectro = any( strcmpi( v.ScanTechnique, { '1DSI', '1DSIFID', '1DSIECHO', '2DSI', '2DSIFID', '2DSIECHO', 'TSI1SL', 'TSIMS', '2DSI_MS', 'VS', 'FID', '3DSI' } ) );
                        
                        nr_elements = enc_pars.nr_mixes * enc_pars.nr_echoes;
                        v.ZReconLength = enc_pars.retro_phases;
                        v.FlipAngle = enc_pars.flip_angle( 1:enc_pars.nr_mixes );
                        v.RepetitionTime = enc_pars.TR( 1:enc_pars.nr_mixes );
                        v.SliceGaps = enc_pars.slice_gaps;
                        
                        if ( strcmpi( v.ScanMode, '3D' ) && any( v.SliceGaps > 0 ) )
                            v.SliceGaps( : ) = 0;
                        end
                        
                        if enc_pars.UTE
                            v.UTE = 'yes';
                        else
                            v.UTE = 'no';
                        end
                        if enc_pars.coshball
                            v.KooshBall = 'yes';
                        else
                            v.KooshBall = 'no';
                        end
                        
                        if isfield( enc_pars, 'geo' );
                            ori = { 'SAG';'COR';'TRA' };
                            fold = { 'RL';'AP';'FH' };
                            fat = { 'R';'L';'A';'P';'F';'H' };
                            v.Offcentre = enc_pars.geo( :, 5:7 );
                            v.Angulation = enc_pars.geo( :, 8:10 );
                            v.FOV = unique( enc_pars.geo( :, 14:16 ) ./ enc_pars.geo( :, 11:13 ), 'rows' );
                            v.Orientation = cell2mat( ori( enc_pars.geo( :, 2 ) + 1 ) );
                            v.FoldOverDir = cell2mat( fold( enc_pars.geo( :, 3 ) + 1 ) );
                            v.FatShiftDir = cell2mat( fat( enc_pars.geo( :, 4 ) + 1 ) );
                            v.SENSEFactor = unique( enc_pars.geo( :, 17:19 ), 'rows' );
                            
                            if size( enc_pars.geo, 2 ) > 19
                                v.Samples = unique( enc_pars.geo( :, 20:22 ), 'rows' );
                            end
                            
                            if size( enc_pars.geo, 2 ) > 22
                                v.MPSOffcentres = enc_pars.geo( :, 23:25 );
                                v.NrSegments = enc_pars.geo( :, 26 );
                                v.NrInstances = enc_pars.geo( :, 27 );
                                v.Thicknesses = enc_pars.geo( :, 28:30 );
                                v.MinSliceNr = enc_pars.geo( :, 31 );
                                v.StackIndex = enc_pars.geo( :, 32 );
                                
                                [ u, ind ] = unique( v.StackIndex, 'last' );
                                for i = 1:size( v.StackIndex, 1 )
                                    cur_stack = min( length( v.SliceGaps ), v.StackIndex( i ) + 1 );
                                    slice_gaps( i, 1 ) = v.SliceGaps( cur_stack );
                                end
                                v.SliceGaps = slice_gaps;
                                v.FOV = enc_pars.geo( ind, 14:16 ) ./ enc_pars.geo( ind, 11:13 );
                                v.FOV( :, 3 ) = v.FOV( :, 3 ) .* ( v.MinSliceNr( ind, 1 ) + 1 ) +  ...
                                    ( v.MinSliceNr( ind, 1 ) ) .* v.SliceGaps( ind, 1 );
                                
                                v.SENSEFactor = enc_pars.geo( ind, 17:19 );
                                v.Samples = enc_pars.geo( ind, 20:22 );
                                
                                v.WFS = enc_pars.wfs;
                                v.FlowComp = enc_pars.flow_comp;
                                v.Venc = enc_pars.venc;
                                try
                                    v.MTC = enc_pars.mtc;
                                    v.SPIR = enc_pars.spir;
                                    v.EPIFactor = enc_pars.epi_factor;
                                    v.DynamicScan = enc_pars.dynamic_scan;
                                    v.Diffusion = enc_pars.diffusion;
                                    v.DiffusionEchoTime = enc_pars.diff_echo_time;
                                    v.DiffusionValues = enc_pars.diff_nr_weigthings;
                                    v.GradientOris = enc_pars.diff_nr_oris;
                                    v.SpiralLeadingSamples = enc_pars.spiral_leading_samples;
                                    v.FieldStrength = enc_pars.field_strength;
                                    v.ResonanceFreq = enc_pars.resonance_freq;
                                    v.SampleSets = max( [ enc_pars.sample_sets, 1 ] );
                                end
                                
                                if isfield( enc_pars, 'geo_corr' )
                                    if length( enc_pars.geo_corr ) >= 354
                                        v.GeoCorrPars = single( enc_pars.geo_corr( 1:354 ) );
                                    end
                                end
                                
                                if enc_pars.scan_date ~= 0
                                    switch enc_pars.card_sync
                                        case 0
                                            v.CardSync = 'No';
                                        case 1
                                            v.CardSync = 'Trigger';
                                        case 2
                                            v.CardSync = 'Gate';
                                        case 3
                                            v.CardSync = 'Retro';
                                    end
                                    
                                    switch enc_pars.resp_sync
                                        case 0
                                            v.RespSync = 'No';
                                        case 1
                                            v.RespSync = 'Trigger';
                                        case 2
                                            v.RespSync = 'Breathold';
                                        case 3
                                            v.RespSync = 'Pear';
                                        case 4
                                            v.RespSync = 'Gate';
                                    end
                                    
                                    switch enc_pars.resp_comp
                                        case 0
                                            v.RespComp = 'No';
                                        case 1
                                            v.RespComp = 'Gate';
                                        case 2
                                            v.RespComp = 'Track';
                                        case 3
                                            v.RespComp = 'GateAndTrack';
                                        case 4
                                            v.RespComp = 'Trigger';
                                        case 5
                                            v.RespComp = 'TriggerAndTrack';
                                    end
                                    
                                    switch enc_pars.angio_mode
                                        case 0
                                            v.AngioMode = 'No';
                                        case 1
                                            v.AngioMode = 'Inflow';
                                        case 2
                                            v.AngioMode = 'PC';
                                        case 3
                                            v.AngioMode = 'CE';
                                    end
                                    
                                    switch enc_pars.quant_flow
                                        case 0
                                            v.QuantFlow = 'No';
                                        case 1
                                            v.QuantFlow = 'Yes';
                                    end
                                    
                                    date_str = num2str( enc_pars.scan_date );
                                    year = num2str( 1900 + str2double( date_str( 1:3 ) ) );
                                    month = date_str( 4:5 );
                                    day = date_str( 6:7 );
                                    time_str = num2str( enc_pars.scan_time );
                                    if length( time_str ) == 5
                                        time_str = [ '0', time_str ];
                                    end
                                    if length( time_str ) == 4
                                        time_str = [ '00', time_str ];
                                    end
                                    if length( time_str ) == 3
                                        time_str = [ '000', time_str ];
                                    end
                                    if length( time_str ) == 2
                                        time_str = [ '0000', time_str ];
                                    end
                                    if length( time_str ) == 1
                                        time_str = [ '00000', time_str ];
                                    end
                                    hour = time_str( 1:2 );
                                    minute = time_str( 3:4 );
                                    sec = time_str( 5:6 );
                                    v.Date = [ day, '.', month, '.', year ];
                                    v.Time = [ hour, ':', minute, ':', sec ];
                                    v.ScanDuration = enc_pars.scan_dur;
                                    v.HeartPhaseInterval = enc_pars.hp_interval;
                                    switch enc_pars.pc_acq_type
                                        case 0
                                            v.PCAcqType = 'MPS';
                                        case 1
                                            if length( unique( lab_struct.row_nr ) ) < 4
                                                v.PCAcqType = 'MPS';
                                            else
                                                v.PCAcqType = 'Hadamard';
                                            end
                                    end
                                    switch enc_pars.scan_type
                                        case 0
                                            v.ScanType = 'Imaging';
                                        case 1
                                            v.ScanType = 'Spectro';
                                            v.Spectro = 1;
                                    end
                                end
                                
                                ind = find( v.StackIndex == 0 );
                                v.AverageOffcentre = mean( v.Offcentre( ind, : ), 1 );
                            end
                            
                            if isfield( v, 'Samples' ) && v.Spectro
                                v.Samples = circshift( v.Samples, [ 0, 1 ] );
                            end
                            
                            if size( enc_pars.geo, 2 ) > 32
                                v.MPSOffcentres = round( enc_pars.geo( :, 23:25 ) ./ enc_pars.geo( :, 33:35 ) );
                                v.MPSOffcentresMM = enc_pars.geo( :, 23:25 );
                                v.KtFactor = enc_pars.kt_factor;
                                if isfield( enc_pars, 'kt_type' )
                                    if v.KtFactor > 1 && enc_pars.kt_type == 0
                                        v.Kt = 'Heart Phases';
                                    else
                                        switch enc_pars.kt_type
                                            case 0
                                                v.Kt = 'No';
                                            case 1
                                                v.Kt = 'Heart Phases';
                                            case 2
                                                v.Kt = 'Dynamic Scans';
                                        end
                                        switch enc_pars.kt_recon_mode
                                            case 0
                                                v.KtReconMode = 'No';
                                            case 1
                                                v.KtReconMode = 'Sense';
                                            case 2
                                                v.KtReconMode = 'Blast';
                                            case 3
                                                v.KtReconMode = 'SlidingWindow';
                                            case 4
                                                v.KtReconMode = 'PCA';
                                        end
                                    end
                                    
                                    switch enc_pars.is_coca_scan
                                        case 0
                                            v.RefScan = 'No';
                                        case 1
                                            v.RefScan = 'Classic';
                                            v.QbcStack = enc_pars.qbc_stack;
                                        case 2
                                            v.RefScan = 'Fast';
                                            v.QbcStack = enc_pars.qbc_stack;
                                        case 3
                                            v.RefScan = 'CoilSurvey';
                                            v.QbcStack = enc_pars.qbc_stack;
                                    end
                                end
                                
                                if isfield( enc_pars, 'asl_mode' )
                                    switch enc_pars.asl_mode
                                        case 0
                                            v.ASLType = 'No';
                                        case 1
                                            v.ASLType = 'FAIR';
                                        case 2
                                            v.ASLType = 'TILT';
                                        case 3
                                            v.ASLType = 'CASL';
                                        case 4
                                            v.ASLType = 'STAR';
                                        case 5
                                            v.ASLType = 'pCASL';
                                        case 6
                                            v.ASLType = 'TIMESLIP';
                                    end
                                    
                                    v.ASLNolabelTypes = enc_pars.asl_no_label_types;
                                end
                                
                                if isfield( enc_pars, 'fear_factor' )
                                    v.FEARFactor = enc_pars.fear_factor;
                                end
                                
                            end
                            if size( enc_pars.geo, 2 ) > 35
                                v.PartialFourierFactors = enc_pars.geo( :, 36:38 );
                            end
                            
                        end
                        
                        if isfield( enc_pars, 'te' );
                            v.TE = enc_pars.te;
                        end
                        
                        if isfield( enc_pars, 'nav' );
                            v.RNAV = enc_pars.nav;
                        end
                        
                        if isfield( enc_pars, 'tfe_factor' );
                            v.TFEfactor = enc_pars.tfe_factor;
                        end
                        
                        if isfield( enc_pars, 'voxel_size' ) && isfield( v, 'FOV' );
                            v.VoxelSizes = enc_pars.voxel_size( 1:3 * enc_pars.nr_mixes );
                            
                            
                            
                            if enc_pars.nr_mixes > 1
                                v.VoxelSizes = reshape( v.VoxelSizes, 2, [  ] );
                                if isfield( v, 'Samples' )
                                    v.VoxelSizes( end  ) = v.FOV( end  ) ./ v.Samples( end  );
                                end
                            end
                        end
                        if isfield( enc_pars, 'ad_hoc_array' );
                            v.AdHocArray = enc_pars.ad_hoc_array;
                        end
                        if isfield( enc_pars, 'pda_ampl_factors' );
                            v.PDAFactors = enc_pars.pda_ampl_factors;
                        end
                        
                        if isfield( enc_pars, 'concom' );
                            v.ConcomFactors = enc_pars.concom;
                        end
                        
                        if isfield( enc_pars, 'nus_enc_nrs' );
                            v.NusEncNrs = enc_pars.nus_enc_nrs;
                            v.NusMethod = enc_pars.nus_method;
                            v.NusSamples = enc_pars.nus_samples;
                        end
                        
                        if isfield( enc_pars, 'diff' );
                            v.DiffusionAP = enc_pars.diff( 1:128 );
                            v.DiffusionFH = enc_pars.diff( 129:256 );
                            v.DiffusionRL = enc_pars.diff( 257:384 );
                            v.DiffusionBValues = enc_pars.diff( 385:end  );
                        end
                        
                        if isfield( enc_pars, 'user_def' );
                            v.UserData = enc_pars.user_def;
                        end
                        
                        v.NumberOfMixes = enc_pars.nr_mixes;
                        v.NumberOfEncodingDimensions = repmat( enc_pars.nr_encs, [ enc_pars.nr_mixes, 1 ] );
                        v.NumberOfEchoes = repmat( enc_pars.nr_echoes, [ enc_pars.nr_mixes, 1 ] );
                        
                        v.KxRange = [ enc_pars.min_enc_numbers( 1:nr_elements )', enc_pars.max_enc_numbers( 1:nr_elements )' ];
                        if enc_pars.nr_encs > 1
                            v.KyRange = [ enc_pars.min_enc_numbers( nr_elements + 1:2 * nr_elements )', enc_pars.max_enc_numbers( nr_elements + 1:2 * nr_elements )' ];
                        end
                        if enc_pars.nr_encs > 2
                            v.KzRange = [ enc_pars.min_enc_numbers( 2 * nr_elements + 1:3 * nr_elements )', enc_pars.max_enc_numbers( 2 * nr_elements + 1:3 * nr_elements )' ];
                        end
                        
                        v.KxOversampleFactor = enc_pars.oversampling_factors( 1:nr_elements )';
                        if enc_pars.nr_encs > 1
                            
                            
                            if ( v.Rel4 ) && ~strcmpi( v.AcquisitionMode, 'Radial' )
                                ovs = enc_pars.oversampling_factors( nr_elements + 1:2 * nr_elements );
                                n = length( ovs );
                                for i = 1:n
                                    if ~ismember( ovs, enc_pars.geo( :, 12 ) )
                                        ovs( i ) = enc_pars.geo( 1, 12 );
                                    end
                                end
                                enc_pars.oversampling_factors( nr_elements + 1:2 * nr_elements ) = ovs;
                            end
                            v.KyOversampleFactor = enc_pars.oversampling_factors( nr_elements + 1:2 * nr_elements )';
                        end
                        if enc_pars.nr_encs > 2
                            v.KzOversampleFactor = enc_pars.oversampling_factors( 2 * nr_elements + 1:3 * nr_elements )';
                        end
                        if enc_pars.nr_encs > 3
                            v.KtOversampleFactor = enc_pars.oversampling_factors( 3 * nr_elements + 1:4 * nr_elements )';
                        end
                        
                        v.XResolution = enc_pars.recon_res( 1:enc_pars.nr_mixes )';
                        if enc_pars.nr_encs > 1
                            v.YResolution = enc_pars.recon_res( enc_pars.nr_mixes + 1:2 * enc_pars.nr_mixes )';
                        end
                        if enc_pars.nr_encs > 2
                            v.ZResolution = enc_pars.recon_res( 2 * enc_pars.nr_mixes + 1:3 * enc_pars.nr_mixes )';
                        end
                        if enc_pars.nr_encs > 3
                            v.TResolution = enc_pars.recon_res( 3 * enc_pars.nr_mixes + 1:4 * enc_pars.nr_mixes )';
                        end
                        
                        recon_res_x = repmat( enc_pars.recon_res( 1:enc_pars.nr_mixes ), [ 1, nr_elements / enc_pars.nr_mixes ] );
                        if isfield( v, 'SENSEFactor' )
                            recon_res_x = ceil( floor( recon_res_x / v.SENSEFactor( 1, 1 ) ) / 2 ) * 2;
                        end
                        v.XRange = [ floor( (  - recon_res_x ./ 2 + enc_pars.spectrum_origin( 1:nr_elements ) ) .* enc_pars.spectrum_signs( 1:nr_elements ) )',  ...
                            ( ( ceil( recon_res_x ./ 2 ) + enc_pars.spectrum_origin( 1:nr_elements ) - 1 ) .* enc_pars.spectrum_signs( 1:nr_elements ) )' ];
                        
                        if isfield( v, 'FastImagingMode' ) &&  ...
                                isfield( v, 'MPSOffcentres' ) &&  ...
                                any( strcmpi( v.FastImagingMode, { 'EPI', 'TFEPI' } ) )
                            v.XRange = v.XRange + v.MPSOffcentres( 1, 1 );
                        end
                        
                        if isfield( v, 'AcquisitionMode' ) &&  ...
                                isfield( v, 'MPSOffcentres' ) &&  ...
                                any( strcmpi( v.AcquisitionMode, { 'Spiral' } ) )
                            v.XRange = v.XRange + v.MPSOffcentres( 1, 1 );
                        end
                        
                        if enc_pars.nr_encs > 1
                            
                            
                            recon_res_y = enc_pars.oversampling_factors( nr_elements + 1:2 * nr_elements ) .* repmat( enc_pars.recon_res( enc_pars.nr_mixes + 1:2 * enc_pars.nr_mixes ), [ 1, enc_pars.nr_echoes ] );
                            if isfield( v, 'SENSEFactor' )
                                recon_res_y = ceil( floor( recon_res_y / v.SENSEFactor( 1, 2 ) ) / 2 ) * 2;
                            end
                            v.YRange = [ floor( (  - recon_res_y ./ 2 + enc_pars.spectrum_origin( nr_elements + 1:2 * nr_elements ) ) .* enc_pars.spectrum_signs( nr_elements + 1:2 * nr_elements ) )',  ...
                                ( ( ceil( recon_res_y ./ 2 ) + enc_pars.spectrum_origin( nr_elements + 1:2 * nr_elements ) - 1 ) .* enc_pars.spectrum_signs( nr_elements + 1:2 * nr_elements ) )' ];
                            
                            if isfield( v, 'FastImagingMode' ) &&  ...
                                    isfield( v, 'MPSOffcentres' ) &&  ...
                                    any( strcmpi( v.FastImagingMode, { 'EPI', 'TFEPI' } ) )
                                v.YRange = v.YRange - v.MPSOffcentres( 1, 2 );
                            end
                            
                            if isfield( v, 'AcquisitionMode' ) &&  ...
                                    isfield( v, 'MPSOffcentres' ) &&  ...
                                    any( strcmpi( v.AcquisitionMode, { 'Spiral' } ) )
                                v.YRange = v.YRange - v.MPSOffcentres( 1, 2 );
                            end
                            
                        end
                        if enc_pars.nr_encs > 2
                            
                            
                            recon_res_z = enc_pars.oversampling_factors( 2 * nr_elements + 1:3 * nr_elements ) .* repmat( enc_pars.recon_res( 2 * enc_pars.nr_mixes + 1:3 * enc_pars.nr_mixes ), [ 1, enc_pars.nr_echoes ] );
                            if isfield( v, 'SENSEFactor' )
                                recon_res_z = ceil( floor( recon_res_z / v.SENSEFactor( 1, 3 ) ) / 2 ) * 2;
                            end
                            v.ZRange = [ floor( (  - recon_res_z ./ 2 + enc_pars.spectrum_origin( 2 * nr_elements + 1:3 * nr_elements ) ) .* enc_pars.spectrum_signs( 2 * nr_elements + 1:3 * nr_elements ) )',  ...
                                ( ( ceil( recon_res_z ./ 2 ) + enc_pars.spectrum_origin( 2 * nr_elements + 1:3 * nr_elements ) - 1 ) .* enc_pars.spectrum_signs( 2 * nr_elements + 1:3 * nr_elements ) )' ];
                            
                            
                            
                            
                            
                            
                            
                            if isfield( v, 'AcquisitionMode' ) &&  ...
                                    isfield( v, 'MPSOffcentres' ) &&  ...
                                    any( strcmpi( v.AcquisitionMode, { 'Spiral' } ) )
                                
                            end
                        end
                        
                        if isfield( enc_pars, 'coil_nrs' )
                            v.CoilNrs = enc_pars.coil_nrs;
                        else
                            v.CoilNrs = [  ];
                        end
                        
                        mix = repmat( ( 0:enc_pars.nr_mixes - 1 )', [ nr_elements / enc_pars.nr_mixes, 1 ] );
                        mix = mix( : );
                        v.Mix = mix;
                        echo = repmat( ( 0:enc_pars.nr_echoes - 1 ), [ nr_elements / enc_pars.nr_echoes, 1 ] );
                        echo = echo( : );
                        v.Echo = echo;
                        
                        if isfield( enc_pars, 'multivenc' )
                            v.Multivenc = enc_pars.multivenc;
                            
                            
                            
                            
                        else
                            v.Multivenc = [  ];
                        end
                        
                        v = orderfields( v );
                    end
                end
            catch exeption
                s = sprintf( 'Could not read the ReconFrame parameter .Error in: \nfunction: %s\nline: %d\nerror: %s', exeption.stack( 1 ).name, exeption.stack( 1 ).line, exeption.message );
                
            end
        end
        function [ v, lab_struct ] = parse_recframe_40_parameter( par, lab_struct )
            ori = { 'SAG';'COR';'TRA' };
            
            LCA = par.GetObject( 'LCA`ima' );
            LCA_voi = par.GetObject( 'LCA`voi' );
            ENC = par.GetObject( 'ENC`ima' );
            STACK = par.GetObject( 'STACK`ima' );
            
            nr_mixes = par.GetValue( 'UGN1_ACQ_mixes' );
            nr_echoes = par.GetValue( 'UGN1_ACQ_echoes' );
            nr_stacks = STACK.GetValue( 'comp_elements', 1 );
            nr_locations = LCA.GetValue( 'comp_elements', 1 );
            nr_elements = ENC.GetValue( 'nr_encodings', 1 ) * nr_mixes * nr_echoes;
            if nr_elements == 0
                nr_elements = nr_mixes * nr_echoes;
                nr_encs = 1;
            else
                nr_encs = nr_elements / nr_mixes / nr_echoes;
            end
            
            v.Spectro = strcmpi( par.GetValue( 'UGN1_ACQ_scan_type' ), 'Spectroscopy' );
            
            
            v.MinSliceNr = LCA.GetValue( 'min_slice_nr' );
            v.StackIndex = LCA.GetValue( 'stack_index' );
            slice_gaps_per_stack = par.GetValue( 'UGN0_GEO_stack_slice_gaps', 1:nr_stacks );
            for i = 1:length( v.StackIndex )
                cur_stack = min( length( slice_gaps_per_stack ), v.StackIndex( i ) + 1 );
                v.SliceGaps( i, 1 ) = slice_gaps_per_stack( cur_stack );
            end
            
            [ u, ind ] = unique( v.StackIndex, 'last' );
            v.FOV_AP_FH_RL = [ par.GetValue( 'PS_stack_ap_fovs', 1:nr_stacks )', par.GetValue( 'PS_stack_fh_fovs', 1:nr_stacks )', par.GetValue( 'PS_stack_rl_fovs', 1:nr_stacks )' ];
            
            if v.Spectro
                v.FOV = LCA_voi.GetValue( 'thicknesses', ind ) ./ LCA.GetValue( 'oversample_factors', ind );
            else
                v.FOV = LCA.GetValue( 'sampled_fovs', ind ) ./ LCA.GetValue( 'oversample_factors', ind );
            end
            v.FOV( :, 3 ) = v.FOV( :, 3 ) .* ( v.MinSliceNr( ind, 1 ) + 1 ) +  ...
                ( v.MinSliceNr( ind, 1 ) ) .* v.SliceGaps( ind, 1 );
            
            
            v.Offcentre = LCA.GetValue( 'pat_offcentres' );
            ind = find( v.StackIndex == 0 );
            v.AverageOffcentre = mean( v.Offcentre( ind, : ), 1 );
            v.Angulation = LCA.GetValue( 'pat_angulations' );
            
            
            v.Orientation = cell2mat( ori( LCA.GetValue( 'orientation', [  ], [  ], true ) + 1 ) );
            if LCA.nr_composites > 1
                v.FoldOverDir = cell2mat( LCA.GetValue( 'prep_dir' ) );
                v.FatShiftDir = cell2mat( LCA.GetValue( 'fat_shift_dir' ) );
            else
                v.FoldOverDir = LCA.GetValue( 'prep_dir' );
                v.FatShiftDir = LCA.GetValue( 'fat_shift_dir' );
            end
            
            v.SENSEFactor = repmat( ENC.GetValue( 'sense_factors', 1 ), [ nr_stacks, 1 ] );
            v.Samples = repmat( ENC.GetValue( 'scan_resolutions', 1 ), [ nr_stacks, 1 ] );
            if v.Spectro
                v.Samples = circshift( v.Samples, [ 0, 1 ] );
            end
            
            if v.Spectro
                v.MPSOffcentres = round( bsxfun( @rdivide, LCA.GetValue( 'mps_offcentres' ), LCA_voi.GetValue( 'thicknesses', 1 ) ) );
            else
                v.MPSOffcentres = round( bsxfun( @rdivide, LCA.GetValue( 'mps_offcentres' ), ENC.GetValue( 'voxel_sizes', 1 ) ) );
            end
            
            
            v.MPSOffcentresMM = LCA.GetValue( 'mps_offcentres' );
            v.NrSegments = LCA.GetValue( 'nr_segments' );
            v.NrInstances = LCA.GetValue( 'nr_instances' );
            
            if v.Spectro
                v.Thicknesses = LCA_voi.GetValue( 'thicknesses' );
            else
                v.Thicknesses = LCA.GetValue( 'thicknesses' );
            end
            
            
            v.ScanMode = par.GetValue( 'UGN1_ACQ_scan_mode' );
            v.AcquisitionMode = par.GetValue( 'RC_k_space_traj_type' );
            v.FastImagingMode = MRparameter.format_value( par.GetValue( 'UGN1_ACQ_fast_imaging_mode' ) );
            if ~strcmp( v.FastImagingMode, 'None' )
                v.FastImagingMode = upper( v.FastImagingMode );
            end
            
            
            
            if ( strcmpi( v.ScanMode, '3D' ) && any( v.SliceGaps > 0 ) )
                v.SliceGaps( : ) = 0;
            end
            
            v.PatientPosition = MRparameter.format_value( par.GetValue( 'UGN1_GEO_patient_position' ) );
            v.PatientOrientation = MRparameter.format_value( par.GetValue( 'UGN1_GEO_patient_orientation' ) );
            if strcmpi( v.PatientOrientation, 'RDecub' )
                v.PatientOrientation = 'Right';
            end
            if strcmpi( v.PatientOrientation, 'LDecub' )
                v.PatientOrientation = 'Left';
            end
            
            
            v.ScanTechnique = par.GetValue( 'UGN12_DEF_scan_technique' );
            v.ZReconLength = par.GetValue( 'RC_max_zrecon_length' );
            v.FlipAngle = par.GetValue( 'RC_flip_angles', 1:nr_mixes );
            v.RepetitionTime = par.GetValue( 'RC_rep_times', 1:nr_mixes );
            
            v.UTE = par.GetValue( 'UGN1_ACQ_radial_fid_sampling' );
            v.KooshBall = par.GetValue( 'UGN1_ACQ_radial_3d_koosh' );
            
            v.WFS = par.GetValue( 'UGN5_FFE_act_water_fat_shift' );
            v.FlowComp = par.GetValue( 'UGN1_ACQ_flow_compensation', [  ], true );
            v.Venc = par.GetValue( 'UGN1_PC_velocities_cmPs' );
            
            v.MTC = par.GetValue( 'UGN1_MTC_enable', [  ], true );
            v.SPIR = par.GetValue( 'UGN1_SPIR_enable', [  ], true );
            v.EPIFactor = par.GetValue( 'UGN1_ACQ_epi_factor' );
            v.DynamicScan = par.GetValue( 'EX_DYN_study', [  ], true );
            v.Diffusion = par.GetValue( 'UGN1_DIFF_enable', [  ], true );
            v.DiffusionEchoTime = par.GetValue( 'UGN5_DIFF_echo_time' );
            v.DiffusionValues = par.GetValue( 'UGN1_DIFF_nr_weightings' );
            try
                v.GradientOris = par.GetValue( 'UGN5_DIFF_measured_nr_oris' );
            catch
                v.GradientOris = par.GetValue( 'UGN1_DIFF_nr_directions' );
            end
            v.SpiralLeadingSamples = par.GetValue( 'RC_nr_leading_spiral_samples' );
            v.FieldStrength = par.GetValue( 'HW_main_magnetic_field_mT' );
            v.ResonanceFreq = par.GetValue( 'HW_resonance_freq' );
            
            
            v.GeoCorrPars = single( [ par.GetValue( 'RC_geom_corr_gx_ref_radius' ),  ...
                par.GetValue( 'RC_geom_corr_gy_field_s_coeffs', 1:14 * 12 ),  ...
                par.GetValue( 'RC_geom_corr_gx_field_c_coeffs', 1:14 * 12 ),  ...
                par.GetValue( 'RC_geom_corr_gz_field_coeffs', 1:12:16 * 12 ), 0 ] );
            if length( v.GeoCorrPars ) >= 354
                v.GeoCorrPars = v.GeoCorrPars( 1:354 );
            end
            v.CardSync = MRparameter.format_value( par.GetValue( 'UGN1_CARD_synchronisation' ) );
            v.RespSync = MRparameter.format_value( par.GetValue( 'UGN1_RESP_synch' ) );
            v.RespComp = MRparameter.format_value( par.GetValue( 'EX_RNAV_resp_comp' ) );
            v.AngioMode = MRparameter.format_value( par.GetValue( 'UGN1_PC_angio_mode' ) );
            v.QuantFlow = MRparameter.format_value( par.GetValue( 'UGN1_PC_quant_flow' ) );
            v.ScanDuration = par.GetValue( 'AC_total_scan_time' );
            v.HeartPhaseInterval = par.GetValue( 'IF_act_heart_phase_interval' );
            v.PCAcqType = MRparameter.format_value( par.GetValue( 'CSC_pc_acq_type' ) );
            if strcmpi( v.PCAcqType, 'Hadamard' ) && par.GetValue( 'MP_pc_scan_segs' ) < 4
                v.PCAcqType = 'MPS';
            end
            
            v.ScanType = MRparameter.format_value( par.GetValue( 'EX_ACQ_scan_type' ) );
            if strcmpi( v.ScanType, 'Spectroscopy' )
                v.ScanType = 'Spectro';
            end
            
            v.KtFactor = par.GetValue( 'UGN1_ACQ_kt_factor' );
            v.Kt = MRparameter.format_value( par.GetValue( 'UGN1_ACQ_kt' ) );
            try
                v.KtReconMode = strrep( MRparameter.format_value( par.GetValue( 'EX_PROC_kt_recon_mode' ) ), 'KT', '' );
            catch
                v.KtReconMode = 'Sense';
            end
            
            if ( par.IsParameter( 'UGN1_ACQ_enable_pre_scan' ) )
                v.RefScan = MRparameter.format_value( par.GetValue( 'UGN1_ACQ_enable_pre_scan' ) );
            else
                v.RefScan = MRparameter.format_value( par.GetValue( 'RC_is_coca_scan' ) );
            end
            if strcmpi( v.RefScan, 'Yes' )
                v.RefScan = 'Classic';
            end
            
            try
                v.QbcStack = 1;
                par.GetValue( 'UGN1_ACQ_enable_pre_scan' );
                try
                    v.QbcStack = find( cellfun( @( x )~isempty( strfind( par.GetValue( [ 'FE`', x, ':coil_id' ] ), 'BODY_' ) ), STACK.GetValue( 'aq_fe_object' ) ) ) - 1;
                end
                
                v.Rel4 = 1;
            catch
                
                if ~strcmpi( v.RefScan, 'no' )
                    try
                        v.QbcStack = find( cellfun( @( x )strcmpi( x, 'Q-Body' ), STACK.GetValue( 'coil_id' ) ) ) - 1;
                    end
                end
                v.Rel4 = 0;
            end
            
            
            
            
            v.ASLType = MRparameter.format_value( par.GetValue( 'UGN1_FLL_mode' ) );
            if ~strcmpi( v.ASLType, 'No' )
                v.ASLNolabelTypes = par.GetValue( 'UGN1_FLL_nr_cycles' );
            else
                v.ASLNolabelTypes = 0;
            end
            try
                v.FEARFactor = par.GetValue( 'RC_relative_fear_bandwidth' );
            catch
                v.FEARFactor = 0;
            end
            v.PartialFourierFactors = ENC.GetValue( 'partial_matrix_factors' );
            v.TE = par.GetValue( 'RC_echo_times', 1:nr_echoes );
            v.TFEfactor = par.GetValue( 'UGN7_TFE_factor' );
            
            if v.Spectro
                v.VoxelSizes = LCA_voi.GetValue( 'thicknesses', 1 );
            else
                v.VoxelSizes = par.GetValue( 'RC_voxel_sizes', 1:3 * nr_mixes );
            end
            
            pda_raw = par.GetValue( 'RC_pda_ampl_factors' );
            v.PDAFactors = complex( pda_raw( 1:2:end  ), pda_raw( 2:2:end  ) );
            v.ConcomFactors = par.GetValue( 'RC_pc_concom_corr_coefs', 1:384 );
            v.NusMethod = par.GetValue( 'RC_nus_method', [  ], true );
            v.NusSamples = par.GetValue( 'RC_nus_samples' );
            if v.NusSamples ~= 0
                v.NusEncNrs = par.GetValue( 'RC_nus_enc_nrs', 1:v.NusSamples );
            else
                v.NusEncNrs = [  ];
            end
            v.DiffusionAP = par.GetValue( 'RC_diffusion_ap_directions' );
            v.DiffusionFH = par.GetValue( 'RC_diffusion_fh_directions' );
            v.DiffusionRL = par.GetValue( 'RC_diffusion_rl_directions' );
            v.DiffusionBValues = par.GetValue( 'RC_diffusion_b_factors' );
            v.NumberOfMixes = nr_mixes;
            v.NumberOfEncodingDimensions = repmat( nr_encs, [ nr_mixes, 1 ] );
            v.NumberOfEchoes = repmat( nr_echoes, [ nr_mixes, 1 ] );
            
            min_enc_nrs = par.GetValue( 'RC_min_encoding_numbers', 1:nr_elements );
            max_enc_nrs = par.GetValue( 'RC_max_encoding_numbers', 1:nr_elements );
            oversampling_factors = par.GetValue( 'RC_oversample_factors', 1:nr_elements );
            recon_res = par.GetValue( 'RC_recon_resolutions', 1:( nr_encs * nr_mixes ) );
            spectrum_origin = par.GetValue( 'RC_spectrum_origins', 1:nr_elements );
            spectrum_signs = par.GetValue( 'RC_spectrum_signs', 1:nr_elements );
            
            nr_elements = nr_mixes * nr_echoes;
            v.KxRange = [ min_enc_nrs( 1:nr_elements )', max_enc_nrs( 1:nr_elements )' ];
            if nr_encs > 1
                v.KyRange = [ min_enc_nrs( nr_elements + 1:2 * nr_elements )', max_enc_nrs( nr_elements + 1:2 * nr_elements )' ];
            end
            if nr_encs > 2
                v.KzRange = [ min_enc_nrs( 2 * nr_elements + 1:3 * nr_elements )', max_enc_nrs( 2 * nr_elements + 1:3 * nr_elements )' ];
            end
            
            v.KxOversampleFactor = oversampling_factors( 1:nr_elements )';
            if nr_encs > 1
                
                
                if ( v.Rel4 ) && ~strcmpi( v.AcquisitionMode, 'Radial' ) && ~strcmpi( v.AcquisitionMode, 'Spiral' )
                    ovs = oversampling_factors( nr_elements + 1:2 * nr_elements );
                    n = length( ovs );
                    for i = 1:n
                        if ~ismember( ovs, LCA.GetValue( 'oversample_factors', ':', 2 ) )
                            ovs( i ) = LCA.GetValue( 'oversample_factors', 1, 2 );
                        end
                    end
                    oversampling_factors( nr_elements + 1:2 * nr_elements ) = ovs;
                end
                v.KyOversampleFactor = oversampling_factors( nr_elements + 1:2 * nr_elements )';
            end
            if nr_encs > 2
                v.KzOversampleFactor = oversampling_factors( 2 * nr_elements + 1:3 * nr_elements )';
            end
            if nr_encs > 3
                v.KtOversampleFactor = oversampling_factors( 3 * nr_elements + 1:4 * nr_elements )';
            end
            if nr_encs > 2
                v.KzOversampleFactor = oversampling_factors( 2 * nr_elements + 1:3 * nr_elements )';
            end
            if nr_encs > 3
                v.KtOversampleFactor = oversampling_factors( 3 * nr_elements + 1:4 * nr_elements )';
            end
            
            v.XResolution = recon_res( 1:nr_mixes )';
            if nr_encs > 1
                v.YResolution = recon_res( nr_mixes + 1:2 * nr_mixes )';
            end
            if nr_encs > 2
                v.ZResolution = recon_res( 2 * nr_mixes + 1:3 * nr_mixes )';
            end
            if nr_encs > 3
                v.TResolution = recon_res( 3 * nr_mixes + 1:4 * nr_mixes )';
            end
            
            recon_res_x = repmat( recon_res( 1:nr_mixes ), [ 1, nr_elements / nr_mixes ] );
            if isfield( v, 'SENSEFactor' )
                recon_res_x = ceil( floor( recon_res_x / v.SENSEFactor( 1, 1 ) ) / 2 ) * 2;
            end
            v.XRange = [ floor( (  - recon_res_x ./ 2 + spectrum_origin( 1:nr_elements ) ) .* spectrum_signs( 1:nr_elements ) )',  ...
                ( ( ceil( recon_res_x ./ 2 ) + spectrum_origin( 1:nr_elements ) - 1 ) .* spectrum_signs( 1:nr_elements ) )' ];
            
            if isfield( v, 'FastImagingMode' ) &&  ...
                    isfield( v, 'MPSOffcentres' ) &&  ...
                    any( strcmpi( v.FastImagingMode, { 'EPI', 'TFEPI' } ) )
                v.XRange = v.XRange + v.MPSOffcentres( 1, 1 );
            end
            
            if isfield( v, 'AcquisitionMode' ) &&  ...
                    isfield( v, 'MPSOffcentres' ) &&  ...
                    any( strcmpi( v.AcquisitionMode, { 'Spiral' } ) )
                v.XRange = v.XRange + v.MPSOffcentres( 1, 1 );
            end
            
            if nr_encs > 1
                
                
                recon_res_y = oversampling_factors( nr_elements + 1:2 * nr_elements ) .* repmat( recon_res( nr_mixes + 1:2 * nr_mixes ), [ 1, nr_echoes ] );
                if isfield( v, 'SENSEFactor' )
                    recon_res_y = ceil( floor( recon_res_y / v.SENSEFactor( 1, 2 ) ) / 2 ) * 2;
                end
                v.YRange = [ floor( (  - recon_res_y ./ 2 + spectrum_origin( nr_elements + 1:2 * nr_elements ) ) .* spectrum_signs( nr_elements + 1:2 * nr_elements ) )',  ...
                    ( ( ceil( recon_res_y ./ 2 ) + spectrum_origin( nr_elements + 1:2 * nr_elements ) - 1 ) .* spectrum_signs( nr_elements + 1:2 * nr_elements ) )' ];
                
                if isfield( v, 'FastImagingMode' ) &&  ...
                        isfield( v, 'MPSOffcentres' ) &&  ...
                        any( strcmpi( v.FastImagingMode, { 'EPI', 'TFEPI' } ) )
                    if ( strcmpi( v.ScanMode, '3D' ) )
                        if ( par.GetValue( 'UGN1_ACQ_epi_3D_mode', 1, 1 ) == 0 )
                            v.YRange = v.YRange - v.MPSOffcentres( 1, 2 );
                        end
                    else
                        v.YRange = v.YRange - v.MPSOffcentres( 1, 2 );
                    end
                end
                
                if isfield( v, 'AcquisitionMode' ) &&  ...
                        isfield( v, 'MPSOffcentres' ) &&  ...
                        any( strcmpi( v.AcquisitionMode, { 'Spiral' } ) )
                    v.YRange = v.YRange - v.MPSOffcentres( 1, 2 );
                end
                
            end
            if nr_encs > 2
                
                
                recon_res_z = oversampling_factors( 2 * nr_elements + 1:3 * nr_elements ) .* repmat( recon_res( 2 * nr_mixes + 1:3 * nr_mixes ), [ 1, nr_echoes ] );
                if isfield( v, 'SENSEFactor' )
                    recon_res_z = ceil( floor( recon_res_z / v.SENSEFactor( 1, 3 ) ) / 2 ) * 2;
                end
                v.ZRange = [ floor( (  - recon_res_z ./ 2 + spectrum_origin( 2 * nr_elements + 1:3 * nr_elements ) ) .* spectrum_signs( 2 * nr_elements + 1:3 * nr_elements ) )',  ...
                    ( ( ceil( recon_res_z ./ 2 ) + spectrum_origin( 2 * nr_elements + 1:3 * nr_elements ) - 1 ) .* spectrum_signs( 2 * nr_elements + 1:3 * nr_elements ) )' ];
                
                if isfield( v, 'FastImagingMode' ) &&  ...
                        isfield( v, 'MPSOffcentres' ) &&  ...
                        any( strcmpi( v.FastImagingMode, { 'EPI', 'TFEPI' } ) )
                    if ( strcmpi( v.ScanMode, '3D' ) )
                        if ( par.GetValue( 'UGN1_ACQ_epi_3D_mode', 1, 1 ) == 1 )
                            v.ZRange = v.ZRange + v.MPSOffcentres( 1, 3 );
                        end
                    end
                end
                
                if isfield( v, 'AcquisitionMode' ) &&  ...
                        isfield( v, 'MPSOffcentres' ) &&  ...
                        any( strcmpi( v.AcquisitionMode, { 'Spiral' } ) )
                end
            end
            
            v.CoilNrs = [  ];
            
            mix = repmat( ( 0:nr_mixes - 1 )', [ nr_elements / nr_mixes, 1 ] );
            mix = mix( : );
            v.Mix = mix;
            echo = repmat( ( 0:nr_echoes - 1 ), [ nr_elements / nr_echoes, 1 ] );
            echo = echo( : );
            v.Echo = echo;
            
            
            
            nr_preps = par.GetValue( 'PR_RNAV_statistics', 1 );
            total_nr_navs = par.GetValue( 'PR_RNAV_statistics', 2 ) - 1;
            total_accepted = par.GetValue( 'PR_RNAV_statistics', 3 );
            total_rejected = par.GetValue( 'PR_RNAV_statistics', 4 ) - 1;
            gating_efficiency = total_accepted / total_nr_navs;
            nr_beams_phase1 = par.GetValue( 'PR_RNAV_statistics', 6 );
            nr_beams_phase2 = par.GetValue( 'PR_RNAV_statistics', 7 );
            length_beam1 = par.GetValue( 'PR_RNAV_statistics', 9 );
            length_beam2 = par.GetValue( 'PR_RNAV_statistics', 10 );
            length_beam3 = par.GetValue( 'PR_RNAV_statistics', 11 );
            nr_values_per_shot = nr_beams_phase1 + nr_beams_phase2;
            total_prep_values = ( nr_preps + 1 ) * nr_values_per_shot;
            array_end = min( [ length( par.GetValue( 'PR_RNAV_pos_array' ) ), total_prep_values + total_nr_navs * nr_values_per_shot ] );
            
            if total_nr_navs > 0
                v.RNAV.NrPreps = nr_preps;
                v.RNAV.TotalNrNavs = total_nr_navs;
                v.RNAV.TotalAccepted = total_accepted;
                v.RNAV.TotalRejected = total_rejected;
                v.RNAV.GatingEfficiency = gating_efficiency * 100;
                
                if nr_beams_phase1 > 0
                    v.RNAV.Beam1.PrepLead = par.GetValue( 'PR_RNAV_pos_array', nr_values_per_shot + 1:nr_values_per_shot:total_prep_values ) ./ 10;
                    v.RNAV.Beam1.AcqLead = par.GetValue( 'PR_RNAV_pos_array', total_prep_values + 1:nr_values_per_shot:array_end ) ./ 10;
                    if nr_beams_phase2 > 0
                        v.RNAV.Beam1.PrepTrail = par.GetValue( 'PR_RNAV_pos_array', nr_values_per_shot + 1 + nr_beams_phase1:nr_values_per_shot:total_prep_values ) ./ 10;
                        v.RNAV.Beam1.AcqTrail = par.GetValue( 'PR_RNAV_pos_array', total_prep_values + 1 + nr_beams_phase1:nr_values_per_shot:array_end ) ./ 10;
                    end
                end
                if nr_beams_phase1 > 1
                    v.RNAV.Beam2.PrepLead = par.GetValue( 'PR_RNAV_pos_array', nr_values_per_shot + 2:nr_values_per_shot:total_prep_values ) ./ 10;
                    v.RNAV.Beam2.AcqLead = par.GetValue( 'PR_RNAV_pos_array', total_prep_values + 2:nr_values_per_shot:array_end ) ./ 10;
                    if nr_beams_phase2 > 1
                        v.RNAV.Beam2.PrepTrail = par.GetValue( 'PR_RNAV_pos_array', nr_values_per_shot + 2 + nr_beams_phase1:nr_values_per_shot:total_prep_values ) ./ 10;
                        v.RNAV.Beam2.AcqTrail = par.GetValue( 'PR_RNAV_pos_array', total_prep_values + 2 + nr_beams_phase1:nr_values_per_shot:array_end ) ./ 10;
                    end
                end
                if nr_beams_phase1 > 2
                    v.RNAV.Beam3.PrepLead = par.GetValue( 'PR_RNAV_pos_array', nr_values_per_shot + 3:nr_values_per_shot:total_prep_values ) ./ 10;
                    v.RNAV.Beam3.AcqLead = par.GetValue( 'PR_RNAV_pos_array', total_prep_values + 3:nr_values_per_shot:array_end ) ./ 10;
                    if nr_beams_phase2 > 2
                        v.RNAV.Beam3.PrepTrail = par.GetValue( 'PR_RNAV_pos_array', nr_values_per_shot + 3 + nr_beams_phase1:nr_values_per_shot:total_prep_values ) ./ 10;
                        v.RNAV.Beam3.AcqTrail = par.GetValue( 'PR_RNAV_pos_array', total_prep_values + 3 + nr_beams_phase1:nr_values_per_shot:array_end ) ./ 10;
                    end
                end
            end
            
            
            
            
            
            
            
            
            
            
            v = orderfields( v );
            
        end
        function formated_val = format_value( val )
            val = lower( val );
            formated_val = regexprep( val, '(\<[a-z])', '${upper($1)}' );
            formated_val( isspace( formated_val ) ) = [  ];
            formated_val = strrep( formated_val, '-', '' );
            
            
            if strcmpi( formated_val, 'True' )
                formated_val = 'Yes';
            end
            if strcmpi( formated_val, 'False' )
                formated_val = 'No';
            end
        end
        function channel_ids = get_channel_ids( P )
            STACK = P.GetObject( 'STACK`ima' );
            nr_stacks = STACK.GetValue( 'comp_elements', 1 );
            
            connected_coils = P.GetValue( 'EX_GEO_connected_coils' );
            
            
            
            connected_channel_ids = zeros( 10000, 2 );
            loop = 1;
            for i = 1:length( connected_coils )
                if isempty( connected_coils{ i } )
                    continue ;
                end
                try
                    
                    
                    
                    try
                        cur_coil = P.GetObject( [ 'COIL`', connected_coils{ i } ] );
                    catch
                        coil_objects = P.GetObjectNames( 'COIL' );
                        for j = 1:length( coil_objects )
                            coil_name = P.GetValue( [ 'COIL`', coil_objects{ j }, ':internal_name' ] );
                            if ( strcmpi( coil_name, connected_coils{ i } ) )
                                cur_coil = P.GetObject( [ 'COIL`', coil_objects{ j } ] );
                                break ;
                            end
                        end
                    end
                    nr_channels = cur_coil.GetValue( 'no_synco_channels' );
                    coil_id = cur_coil.GetValue( 'coil_id_nr', [  ], [  ], true );
                    for cur_channel = 1:nr_channels
                        cur_channel_id = coil_id * 100000 + cur_channel;
                        connected_channel_ids( loop, 1 ) = loop - 1;
                        connected_channel_ids( loop, 2 ) = cur_channel_id;
                        loop = loop + 1;
                    end
                catch
                    error( 'Could not get the channel ids' );
                end
            end
            connected_channel_ids = connected_channel_ids( 1:loop - 1, : );
            
            
            
            active_channel_ids = [  ];
            channel_groups = [  ];
            for i = 1:nr_stacks
                fe_id = STACK.GetValue( 'aq_fe_object', i );
                try
                    cur_fe_obj = P.GetObject( [ 'FE`', fe_id ] );
                    nr_rcv_coils = cur_fe_obj.GetValue( 'nr_rcv_coils', 1, 1 );
                    
                    for j = 1:nr_rcv_coils
                        cur_channel_group = cur_fe_obj.GetValue( 'recon_group_id', j );
                        coil_id = cur_fe_obj.GetValue( 'coil_id', j, 1, true );
                        active_channels = cur_fe_obj.GetValue( 'active_channels', j, [  ], true );
                        active_channels = find( active_channels );
                        cur_active_ids = ( coil_id * 100000 + active_channels )';
                        active_channel_ids = [ active_channel_ids;cur_active_ids ];
                        channel_groups = [ channel_groups;zeros( size( cur_active_ids ) ) + cur_channel_group ];
                    end
                catch
                    error( 'Could not get the channel ids' );
                end
            end
            
            channel_ids = [  ];
            for i = 1:length( active_channel_ids )
                cur_channel_id = find( connected_channel_ids( :, 2 ) == active_channel_ids( i ), 1 );
                if ~isempty( cur_channel_id )
                    channel_ids = [ channel_ids;[ connected_channel_ids( cur_channel_id ), channel_groups( i ) ] ];
                    connected_channel_ids( cur_channel_id, : ) = [  ];
                end
            end
            
            
            
            
            
            
            
            unique_groups = unique( channel_ids( :, 2 ) );
            nr_channels_per_group = P.GetValue( 'RC_nr_measured_channels_per_group' );
            for i = 1:length( unique_groups )
                rc_nr_channels = nr_channels_per_group( unique_groups( i ) + 1 );
                my_nr_channels = length( find( channel_groups == unique_groups( i ) ) );
                if rc_nr_channels ~= my_nr_channels
                    error( 'Number of channel in group is different than it is supposed to. Something went wrong' );
                end
            end
            
            
            channel_ids = unique( channel_ids, 'rows' );
            channel_ids = sortrows( channel_ids, 2 );
        end
        function bitmask = coil_nrs2bitmask( coil_nrs )
            coil_nrs = coil_nrs + 1;
            max_connected_coil_nr = max( coil_nrs );
            vector_length = 32 * ceil( max_connected_coil_nr / 32 );
            if vector_length == 0
                vector_length = 32;
            end
            bitmask_num = zeros( 1, vector_length );
            bitmask_num( coil_nrs ) = 1;
            bitmask_str = num2str( bitmask_num );
            bitmask_str( isspace( bitmask_str ) ) = [  ];
            bitmask_str = reshape( bitmask_str', 32, [  ] )';
            bitmask_str = bitmask_str( :, end : - 1:1 );
            for i = 1:size( bitmask_str, 1 )
                bitmask( i ) = bin2dec( bitmask_str( i, : ) );
            end
        end
        
        
        function values = listread( filename, PAR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            fid = fopen( filename );
            if fid ==  - 1
                error( [ 'The .list file ', filename, ' does not exist' ] )
                return
            end
            values = PAR.LIST_read_upper_part( fid, PAR );
            values = PAR.LIST_read_lower_part( fid, values, PAR );
            
            if ~isfield( values.Index, 'ky' ) && isfield( values.Index, 'y' )
                values.Index.ky = values.Index.y;
                values.Index.kz = values.Index.z;
            end
            values.Index.ky_label = values.Index.ky;
            values.Index.kz_label = values.Index.kz;
            
            fclose( fid );
        end
        function values = LIST_read_upper_part( fid, PAR )
            
            values = [  ];
            parameters = PAR.LIST_read_parameters( fid );
            
            if ~isempty( parameters );
                struct_names = PAR.LIST_format_parameters( parameters, 1 );
                no_parameters = size( parameters, 1 );
                values = struct;
                values.Mix = [  ];
                values.Echo = [  ];
                for i = 1:no_parameters
                    values_temp = [  ];
                    values_legend_temp = [  ];
                    fseek( fid, 0,  - 1 );
                    while ~feof( fid )
                        s = fgetl( fid );
                        if strmatch( '# === START OF DATA VECTOR INDEX =', s )
                            break
                        end
                        s_index = findstr( parameters{ i }, s );
                        if ~isempty( s_index )
                            s_index = findstr( ':', s );
                            s_index = s_index( 1 ) + 1;
                            
                            s_dot = findstr( '.', s );
                            s_dot = s_dot( 1 ) + 1;
                            
                            s_legend = sscanf( s( s_dot:end  ), '%d%d%d' )';
                            if ~isempty( s_legend )
                                values_legend_temp = [ values_legend_temp;s_legend ];
                            end
                            
                            
                            
                            if any( ~ismember( values_legend_temp( :, 1 ), values.Mix ) )
                                ind = find( ~ismember( values_legend_temp( :, 1 ), values.Mix ) );
                                values.Mix( end  + 1 ) = values_legend_temp( ind, 1 );
                            end
                            if any( ~ismember( values_legend_temp( :, 2 ), values.Echo ) )
                                ind = find( ~ismember( values_legend_temp( :, 2 ), values.Echo ) );
                                values.Echo( end  + 1 ) = values_legend_temp( ind, 2 );
                            end
                            
                            s_test = s( s_index:length( s ) );
                            s_test = strrep( s_test, '-', ' ' );
                            s_test = strrep( s_test, '.', ' ' );
                            s_test = s_test( ~isspace( s_test ) );
                            if isnan( str2double( s_test ) )
                                values_temp = strtrim( s( s_index:length( s ) ) );
                            else
                                values_temp = [ values_temp;str2num( s( s_index:length( s ) ) ) ];
                            end
                            values.( struct_names{ i } ) = values_temp;
                            s_index = s_index + 1;
                        end
                    end
                end
            end
        end
        function values = LIST_read_lower_part( fid, values, PAR )
            
            image_information_legend = PAR.LIST_image_information_legend( fid );
            if ~isempty( image_information_legend )
                image_information_legend = PAR.LIST_format_parameters( image_information_legend, 0 );
                read_string = '%3s';
                for i = 1:size( image_information_legend, 1 ) - 1
                    read_string = [ read_string, ' %d' ];
                end
                fseek( fid, 0,  - 1 );
                loop = 1;
                while ~feof( fid )
                    s = fgetl( fid );
                    s_index = strmatch( '# === START OF DATA VECTOR INDEX ===', s );
                    if ~isempty( s_index )
                        fgetl( fid );
                        fgetl( fid );
                        fgetl( fid );
                        fgetl( fid );
                        
                        
                        file_pos_catch = ftell( fid );
                        try
                            data = fscanf( fid, '%c', inf );
                            eof = strfind( data, '#' );
                            if isempty( eof )
                                eof = length( data( : ) );
                            end
                            data = data( 1:eof - 1 );
                            data = sscanf( data, read_string, [ size( image_information_legend, 1 ) + 2, inf ] );
                        catch
                            fseek( fid, file_pos_catch,  - 1 );
                            data = fscanf( fid, read_string, [ size( image_information_legend, 1 ) + 2, inf ] );
                        end
                        h1 = char( data( 1:3, 1:end  ) );
                        h = data( 4:end , 1:end  );
                        break
                    end
                end
                Index = struct;
                Index = setfield( Index, 'typ', h1' );
                
                k = 1;
                for i = 1:length( image_information_legend )
                    if ~strcmp( image_information_legend{ i }, 'typ' )
                        Index = setfield( Index, image_information_legend{ i }, h( k, : )' );
                        k = k + 1;
                    end
                end
                values = setfield( values, 'Index', Index );
            end
        end
        function parameters = LIST_read_parameters( fid )
            
            
            fseek( fid, 0,  - 1 );
            loop = 1;
            found_end = 0;
            parameters = [  ];
            start_str = '# === GENERAL INFORMATION';
            end_str = '# === START OF DATA VECTOR INDEX =';
            while ~feof( fid )
                s = fgetl( fid );
                s_start = strmatch( start_str, s );
                s_end = strmatch( end_str, s );
                if ~isempty( s_end )
                    found_end = 1;
                end
                if ~isempty( s_start )
                    while ~feof( fid )
                        s = fgetl( fid );
                        if strmatch( end_str, s )
                            found_end = 1;
                            break
                        end
                        if strcmp( s( 1 ), '#' )
                            continue
                        end
                        ind_end = findstr( s, ':' );
                        i = 2;numbers = 0;
                        while numbers < 3 && i <= ind_end
                            test = str2double( s( i ) );
                            if ~isnan( test ) && isreal( test )
                                numbers = numbers + 1;
                            end
                            i = i + 1;
                        end
                        ind_start = i;
                        s1 = s( ind_start + 1:ind_end - 1 );
                        if ~isempty( s1 )
                            parameters{ loop } = strtrim( s1 );
                        else
                            parameters{ loop } = strtrim( s( 2:ind_end - 1 ) );
                        end
                        loop = loop + 1;
                    end
                end
                if found_end
                    break
                end
            end
            parameters = parameters';
        end
        function struct_names = LIST_format_parameters( parameters, uppercase )
            
            
            for i = 1:length( parameters )
                s = parameters{ i };
                ind1 = strfind( s, '(' );
                ind2 = strfind( s, '[' );
                ind3 = strfind( s, '<' );
                ind = [ ind1, ind2, ind3 ];
                if ~isempty( ind )
                    ind = min( ind );
                    s = s( 1:ind - 1 );
                end
                s = strrep( s, '.', ' ' );
                s = strrep( s, '/', ' ' );
                s = strrep( s, '_', ' ' );
                s = strrep( s, '-', ' ' );
                s = deblank( s );
                ind = strfind( s, ' ' );
                if uppercase
                    s( ind + 1 ) = upper( s( ind + 1 ) );
                    s( 1 ) = upper( s( 1 ) );
                end
                s( ind ) = [  ];
                struct_names{ i } = s;
            end
            struct_names = struct_names';
        end
        function image_information_legend = LIST_image_information_legend( fid )
            
            
            
            fseek( fid, 0,  - 1 );
            loop = 1;
            image_information_legend = [  ];
            ind = [  ];
            while ~feof( fid )
                s = fgetl( fid );
                s_index = strmatch( '# === START OF DATA VECTOR INDEX ===', s );
                if ~isempty( s_index )
                    fgetl( fid );
                    s = fgetl( fid );
                    s = s( 2:end  );
                    ind = isspace( s );
                    while ~isempty( find( ind ) )
                        while ind( 1 ) == 1
                            ind( 1 ) = [  ];
                            s( 1 ) = [  ];
                        end
                        ind_end = find( ind, 1 );
                        if ~isempty( ind_end )
                            image_information_legend{ loop } = s( 1:ind_end - 1 );
                            s( 1:ind_end - 1 ) = [  ];
                            ind( 1:ind_end - 1 ) = [  ];
                            loop = loop + 1;
                        end
                    end
                    break
                end
            end
            if ~isempty( ind )
                image_information_legend{ loop } = s( 1:end  );
            end
            image_information_legend = image_information_legend';
        end
        
        
        function header = read_cpx_header( file, output )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if nargin == 1
                output = 'yes';
            end
            
            
            fid = fopen( file );
            fseek( fid, 0, 'eof' );
            filesize = ftell( fid );
            fseek( fid, 0, 'bof' );
            
            
            h1 = fread( fid, 15, 'long' );
            factor = fread( fid, 2, 'float' );
            h2 = fread( fid, 111, 'long' );
            
            res_x = h1( 11 );
            res_y = h1( 12 );
            compression = h1( 14 );
            if ~h2( 26 )
                offset = h1( 10 );
            else
                offset = h2( 26 );
            end
            
            matrix_data_blocks = h1( 13 );
            
            
            image_exist = 1;i = 0;
            while image_exist
                
                header_offset = ( matrix_data_blocks * 512 + offset ) * i;
                fseek( fid, header_offset, 'bof' );
                h1 = fread( fid, 15, 'long' );
                image_exist = h1( 9 );
                i = i + 1;
            end
            images = i - 1;
            
            
            
            
            
            
            
            header = zeros( images, 19 );
            
            
            for i = 0:images - 1
                header_offset = ( matrix_data_blocks * 512 + offset ) * i;
                fseek( fid, header_offset, 'bof' );
                h1 = fread( fid, 15, 'long' );
                factor = fread( fid, 2, 'float' );
                h2 = fread( fid, 111, 'long' );
                header( i + 1, 1 ) = h1( 2 );
                header( i + 1, 2 ) = h1( 3 );
                header( i + 1, 3 ) = h2( 2 );
                header( i + 1, 4 ) = h1( 6 );
                header( i + 1, 5 ) = h1( 5 );
                header( i + 1, 6 ) = h1( 7 );
                header( i + 1, 7 ) = h1( 8 );
                if ~h2( 26 )
                    header( i + 1, 8 ) = h1( 10 );
                else
                    header( i + 1, 8 ) = h2( 26 );
                end
                header( i + 1, 9 ) = h1( 11 );
                header( i + 1, 10 ) = h1( 12 );
                header( i + 1, 11 ) = h1( 14 );
                header( i + 1, 12 ) = h2( 111 );
                header( i + 1, 13 ) = factor( 1 );
                header( i + 1, 14 ) = factor( 2 );
                header( i + 1, 15 ) = h1( 1 );
                header( i + 1, 16 ) = h1( 4 );
                header( i + 1, 17 ) = h1( 15 );
                header( i + 1, 18 ) = h2( 1 );
                header( i + 1, 19 ) = h2( 3 );
                
                if h1( 9 ) == 0
                    'Header Problem!! Too many images calculated'
                    break
                end
            end
            
            
            
            last_header_offset = ( matrix_data_blocks * 512 + offset ) * images;
            fseek( fid, last_header_offset, 'bof' );
            h1 = fread( fid, 15, 'long' );
            factor = fread( fid, 2, 'float' );
            h2 = fread( fid, 10, 'long' );
            if h1( 9 ) ~= 0
                'Header Problem'
                return
            end
            
            
            if strcmp( output, 'yes' )
                s1 = sprintf( '\nResolution in x-direction: %d \nResolution in y-direction: %d \nNumber of stacks: %d \nNumber of slices: %d \nNumber of coils: %d \nNumber of heart phases: %d \nNumber of echos: %d \nNumber of dynamics: %d \nNumber of segments: %d \nNumber of segments2: %d', header( 1, 9 ), header( 1, 10 ), max( header( :, 1 ) ) + 1, max( header( :, 2 ) ) + 1, max( header( :, 3 ) ) + 1, max( header( :, 4 ) ) + 1, max( header( :, 5 ) ) + 1, max( header( :, 6 ) ) + 1, max( header( :, 7 ) ) + 1, max( header( :, 18 ) ) + 1 );
                disp( s1 );
            end
        end
        
        
        function values = parread( filename )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            fid = fopen( filename );
            if fid ==  - 1
                filename = [ filename( 1:end  - 3 ), 'par' ];
                fid = fopen( filename );
                if fid ==  - 1
                    error( [ 'The .par file ', filename, ' does not exist' ] )
                    return
                end
            end
            values = MRparameter.REC_read_upper_part( fid );
            values = MRparameter.REC_read_lower_part( fid, values );
            fclose( fid );
        end
        function values = parread_from_string( parfile_string )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            values = [  ];
            parfile_splitted = textscan( parfile_string, '%s', 'delimiter', sprintf( '\n' ) );
            if ( isempty( parfile_splitted ) )
                return ;
            end
            values = MRparameter.REC_read_upper_part( parfile_splitted{ 1 } );
            values = MRparameter.REC_read_lower_part( parfile_splitted{ 1 }, values );
        end
        function values = REC_read_upper_part( fid )
            
            
            is_file = isnumeric( fid );
            
            
            parameters = MRparameter.REC_read_parameters( fid );
            struct_names = MRparameter.REC_format_parameters( parameters );
            no_parameters = size( parameters, 1 );
            values = struct;
            for i = 1:no_parameters
                values_temp = [  ];
                
                if ( is_file )
                    fseek( fid, 0,  - 1 );
                    while ~feof( fid )
                        
                        s = fgetl( fid );
                        s_index = findstr( parameters{ i }, s );
                        if ~isempty( s_index )
                            s_index = findstr( ':', s );
                            
                            s_index = s_index( 1 ) + 1;
                            
                            if isempty( str2num( s( s_index:length( s ) ) ) )
                                values_temp = s( s_index:length( s ) );
                            else
                                values_temp = str2num( s( s_index:length( s ) ) );
                            end
                            values = setfield( values, struct_names{ i }, values_temp );
                            s_index = s_index + 1;
                        end
                    end
                else
                    loop = 1;
                    while loop <= size( fid, 1 )
                        s = fid{ loop };
                        loop = loop + 1;
                        s_index = findstr( parameters{ i }, s );
                        if ~isempty( s_index )
                            s_index = findstr( ':', s );
                            
                            s_index = s_index( 1 ) + 1;
                            
                            if isempty( str2num( s( s_index:length( s ) ) ) )
                                values_temp = s( s_index:length( s ) );
                            else
                                values_temp = str2num( s( s_index:length( s ) ) );
                            end
                            values = setfield( values, struct_names{ i }, values_temp );
                            s_index = s_index + 1;
                        end
                    end
                end
            end
        end
        function values = REC_read_lower_part( fid, values )
            
            
            
            
            is_file = isnumeric( fid );
            
            [ image_information_legend, image_information_length ] = MRparameter.REC_read_image_information_parameters( fid );
            if ~isempty( image_information_legend )
                image_information_legend = MRparameter.REC_format_parameters( image_information_legend );
                
                if ( is_file )
                    fseek( fid, 0,  - 1 );
                    loop = 1;
                    while ~feof( fid )
                        s = fgetl( fid );
                        s_index = strmatch( '# === IMAGE INFORMATION ==', s );
                        if ~isempty( s_index )
                            fgetl( fid );
                            fgetl( fid );
                            while ~feof( fid )
                                s = fgetl( fid );
                                if length( str2num( s ) ) ~= 0
                                    if exist( 'h' ) & length( str2num( s ) ) ~= size( h, 2 )
                                        s = str2num( s );
                                        s = [ s( 1:3 ), round( s( 4 ) / 10 ), rem( s( 4 ), 10 ), s( 5:end  ) ];
                                    else
                                        s = str2num( s );
                                    end
                                    h( loop, : ) = s;
                                end
                                loop = loop + 1;
                            end
                        end
                    end
                else
                    par_ind = 1;
                    loop = 1;
                    while loop <= size( fid, 1 )
                        s = fid{ loop };
                        loop = loop + 1;
                        s_index = strmatch( '# === IMAGE INFORMATION ==', s );
                        if ~isempty( s_index )
                            loop = loop + 1;
                            loop = loop + 1;
                            while loop <= size( fid, 1 )
                                s = fid{ loop };
                                loop = loop + 1;
                                if length( str2num( s ) ) ~= 0
                                    if exist( 'h' ) & length( str2num( s ) ) ~= size( h, 2 )
                                        s = str2num( s );
                                        s = [ s( 1:3 ), round( s( 4 ) / 10 ), rem( s( 4 ), 10 ), s( 5:end  ) ];
                                    else
                                        s = str2num( s );
                                    end
                                    h( par_ind, : ) = s;
                                end
                                par_ind = par_ind + 1;
                            end
                        end
                    end
                end
                if ~isempty( s_index )
                    ImageInformation = struct;
                    k = 1;
                    for i = 1:length( image_information_legend )
                        ImageInformation = setfield( ImageInformation, image_information_legend{ i }, h( :, k:k + image_information_length( i ) - 1 ) );
                        k = k + image_information_length( i );
                    end
                    values = setfield( values, 'ImageInformation', ImageInformation );
                end
            end
        end
        function parameters = REC_read_parameters( fid )
            
            
            
            
            
            is_file = isnumeric( fid );
            
            if ( is_file )
                loop = 1;
                while ~feof( fid )
                    s = fgetl( fid );
                    s_index = strmatch( '# === GENERAL INFORMATION', s );
                    if ~isempty( s_index )
                        fgetl( fid );
                        while ~feof( fid )
                            s = fgetl( fid );
                            if isempty( s ) | ~strcmp( s( 1 ), '.' )
                                break
                            end
                            ind = findstr( s, ':' );
                            s = s( 2:ind - 1 );
                            parameters{ loop } = strtrim( s );
                            loop = loop + 1;
                        end
                    end
                end
            else
                par_ind = 1;
                loop = 1;
                while loop <= size( fid, 1 )
                    s = fid{ loop };
                    loop = loop + 1;
                    s_index = strmatch( '# === GENERAL INFORMATION', s );
                    if ~isempty( s_index )
                        loop = loop + 1;
                        while loop <= size( fid, 1 )
                            s = fid{ loop };
                            loop = loop + 1;
                            if isempty( s ) | ~strcmp( s( 1 ), '.' )
                                break
                            end
                            ind = findstr( s, ':' );
                            s = s( 2:ind - 1 );
                            parameters{ par_ind } = strtrim( s );
                            par_ind = par_ind + 1;
                        end
                    end
                end
            end
            
            parameters = parameters';
        end
        function struct_names = REC_format_parameters( parameters )
            
            
            for i = 1:length( parameters )
                s = parameters{ i };
                ind1 = strfind( s, '(' );
                ind2 = strfind( s, '[' );
                ind3 = strfind( s, '<' );
                ind = [ ind1, ind2, ind3 ];
                if ~isempty( ind )
                    ind = min( ind );
                    s = s( 1:ind - 1 );
                end
                s = strrep( s, '.', ' ' );
                s = strrep( s, '/', ' ' );
                s = strrep( s, '_', ' ' );
                s = strrep( s, '-', ' ' );
                s = deblank( s );
                ind = strfind( s, ' ' );
                s( ind + 1 ) = upper( s( ind + 1 ) );
                s( 1 ) = upper( s( 1 ) );
                s( ind ) = [  ];
                struct_names{ i } = s;
            end
            struct_names = struct_names';
        end
        function [ image_information_legend, image_information_length ] = REC_read_image_information_parameters( fid )
            
            
            
            
            
            is_file = isnumeric( fid );
            
            if ( is_file )
                fseek( fid, 0,  - 1 );
                loop = 1;
                image_information_legend = [  ];
                image_information_length = [  ];
                while ~feof( fid )
                    s = fgetl( fid );
                    s_index = strmatch( '# === IMAGE INFORMATION DEFINITION', s );
                    if ~isempty( s_index )
                        fgetl( fid );
                        fgetl( fid );
                        while ~feof( fid )
                            s = fgetl( fid );
                            if length( s ) < 5
                                break
                            end
                            ind = max( findstr( s, '(' ) );
                            l = str2double( s( ind + 1 ) );
                            s = s( 2:ind - 1 );
                            image_information_legend{ loop } = strtrim( s );
                            if isnan( l ) | imag( l ) ~= 0
                                image_information_length( loop ) = 1;
                            else
                                image_information_length( loop ) = l;
                            end
                            loop = loop + 1;
                        end
                    end
                end
            else
                par_ind = 1;
                loop = 1;
                image_information_legend = [  ];
                image_information_length = [  ];
                while loop <= size( fid, 1 )
                    s = fid{ loop };
                    loop = loop + 1;
                    s_index = strmatch( '# === IMAGE INFORMATION DEFINITION', s );
                    if ~isempty( s_index )
                        loop = loop + 1;
                        loop = loop + 1;
                        while loop <= size( fid, 1 )
                            s = fid{ loop };
                            loop = loop + 1;
                            if length( s ) < 5
                                break
                            end
                            ind = max( findstr( s, '(' ) );
                            l = str2double( s( ind + 1 ) );
                            s = s( 2:ind - 1 );
                            image_information_legend{ par_ind } = strtrim( s );
                            if isnan( l ) | imag( l ) ~= 0
                                image_information_length( par_ind ) = 1;
                            else
                                image_information_length( par_ind ) = l;
                            end
                            par_ind = par_ind + 1;
                        end
                    end
                end
            end
            if ~isempty( image_information_legend )
                image_information_legend = image_information_legend';
            end
        end
        
        
        function v = convert_parameter2output_struct( par )
            
            nr_images = 0;
            for i = 1:size( par.Data, 2 )
                if ~isempty( par.Data{ 1, i } )
                    nr_images = nr_images + size( par.Data{ 1, i }( :, :, : ), 3 );
                end
            end
            nr_images2 = 0;
            if ( strcmp( par.Recon.TKE, 'Yes' ) && ( size( par.Data, 2 ) == 2 ) )
                nr_images2 = size( par.Data{ 1, 2 }( :, :, : ), 3 );
            end
            I = InfoPars( nr_images );
            cur_img = 1;
            
            max_dyn = 0;
            dynamics = zeros( 1, nr_images );
            for i = 1:size( par.Data, 2 )
                if ~isempty( par.Data{ 1, i } )
                    if iscell( par.ImageInformation )
                        I( cur_img:cur_img + size( par.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = par.ImageInformation{ 1, i }( : );
                    else
                        I( cur_img:cur_img + size( par.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = par.ImageInformation( : );
                    end
                    dynamics( cur_img:cur_img + size( par.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = [ I( cur_img:cur_img + size( par.Data{ 1, i }( :, :, : ), 3 ) - 1 ).Dynamic ] + max_dyn;
                    max_dyn = max( dynamics );
                    cur_img = cur_img + size( par.Data{ 1, i }( :, :, : ), 3 );
                end
            end
            
            if ( strcmpi( par.Recon.TKE, 'Yes' ) )
                dynamics( : ) = 1;
            end
            
            
            nslice = length( unique( [ I.Slice ] ) );
            ncoil = length( unique( [ I.Coil ] ) );
            ndyn = length( unique( dynamics ) );
            nphase = length( unique( [ I.CardiacPhase ] ) );
            necho = length( unique( [ I.Echo ] ) );
            nloca = length( unique( [ I.Location ] ) );
            nmix = length( unique( [ I.Mix ] ) );
            nextr1 = length( unique( [ I.Extra1 ] ) );
            nextr2 = length( unique( [ I.Extra2 ] ) );
            naver = length( unique( [ I.Average ] ) );
            
            bvalues = unique( [ I.DiffusionBValueNr ] );
            
            is_flow = false;
            if strcmpi( par.Scan.Multivenc, 'yes' )
                is_flow = true;
            elseif ~isempty( par.Recon.Venc )
                is_flow = any( par.Recon.Venc( 1, : ) ~= 0 ) && length( unique( [ I.Extra1 ] ) ) > 1;
            end
            is_asl = ~isempty( par.Scan.ASLType ) && ~strcmpi( par.Scan.ASLType, 'No' );
            
            NY = { 'N', 'Y' };
            if ~isfield( par.Labels, 'MPSOffcentres' )
                technique = par.Scan.FastImgMode;
                par.Labels.DiffusionValues = 1;
                par.Labels.GradientOris = 1;
                patpos = 'HFS';
                wfs = 0;
                flow_comp = 'N';
                venc = [ 0, 0, 0 ];
                mtc = 'N';
                spir = 'N';
                epi_factor = 1;
                dyn_scan = 'N';
                diff = 'N';
                par.Labels.DiffusionEchoTime = 0;
            else
                technique = par.Scan.Technique;
                wfs = par.Scan.WaterFatShiftPix;
                venc = par.Scan.Venc;
                epi_factor = par.Scan.EPIFactor;
                patpos = [ par.Labels.PatientPosition( regexp( par.Labels.PatientPosition, '[A-Z]' ) ), par.Labels.PatientOrientation( regexp( par.Labels.PatientOrientation, '[A-Z]' ) ) ];
                flow_comp = NY{ par.Labels.FlowComp + 1 };
                mtc = NY{ par.Labels.MTC + 1 };
                spir = NY{ par.Labels.SPIR + 1 };
                dyn_scan = NY{ ( par.Labels.DynamicScan > 0 ) + 1 };
                diff = NY{ ( par.Labels.Diffusion > 0 ) + 1 };
            end
            
            if ~isempty( par.Scan.FoldOverDir )
                for i = 1:length( I( : ) )
                    try
                        cur_prep_dir = par.Labels.FoldOverDir( min( [ size( par.Labels.FoldOverDir, 1 ), I( i ).Location ] ), : );
                    catch
                        cur_prep_dir = strtrim( par.Scan.FoldOverDir( 1, : ) );
                    end
                    switch I( i ).Orientation
                        case 1
                            if strcmpi( cur_prep_dir, 'AP' )
                                permutation( i, : ) = [ 2, 3, 1 ];
                            else
                                permutation( i, : ) = [ 1, 3, 2 ];
                            end
                        case 2
                            if strcmpi( cur_prep_dir, 'AP' )
                                permutation( i, : ) = [ 2, 1, 3 ];
                            else
                                permutation( i, : ) = [ 1, 2, 3 ];
                            end
                        case 3
                            if strcmpi( cur_prep_dir, 'RL' )
                                permutation( i, : ) = [ 3, 1, 2 ];
                            else
                                permutation( i, : ) = [ 3, 2, 1 ];
                            end
                        otherwise
                            permutation( i, : ) = [ 1, 2, 3 ];
                    end
                end
            else
                permutation = [ 1, 2, 3 ];
            end
            
            
            if ~isempty( venc )
                venc = venc( :, circshift( permutation( 1, : ), [ 0, 1 ] ) );
            end
            
            
            perm_temp = permutation;
            for j = 1:size( permutation, 1 )
                for i = 1:3
                    perm_temp( j, i ) = find( permutation( j, : ) == i );
                end
            end
            permutation = perm_temp;
            
            if ~isempty( par.Scan.FOV )
                rFOV = par.Scan.FOV( permutation( 1 ) ) / par.Scan.FOV( permutation( 2 ) );
            else
                rFOV = 1;
            end
            if ~isfield( par.Labels, 'Samples' )
                par.Labels.Samples = [ 0, 0, 0 ];
            end
            if isempty( par.Scan.FOV )
                fov = [ 0, 0, 0 ];
            else
                fov = par.Scan.FOV;
            end
            if isempty( par.Scan.Angulation )
                angulation = [ 0, 0, 0 ];
            else
                angulation = par.Scan.Angulation( 1, : );
            end
            
            if isempty( par.Scan.Offcentre )
                av_offcentre = [ 0, 0, 0 ];
            else
                av_offcentre = par.Scan.Offcentre( 1, : );
            end
            
            if isempty( par.Scan.AcqNo )
                acq_no = 1;
            else
                acq_no = par.Scan.AcqNo;
            end
            rec_no = 1;
            
            v.PatientName = 'ReconFrame';
            v.ExaminationName = 'ReconFrame';
            if ( isempty( par.Scan.ProtocolName ) )
                protocol_name = 'ReconFrame';
            else
                protocol_name = par.Scan.ProtocolName;
                protocol_name = strrep( protocol_name, 'WIP', '' );
                protocol_name = [ 'GT', protocol_name ];
            end
            v.ProtocolName = protocol_name;
            v.ExaminationDate = '2000.01.01';
            v.ExaminationTime = '00:00:00';
            v.SeriesDataType = 'PIXEL';
            v.AquisitionNumber = acq_no;
            v.ReconstructionNumber = rec_no;
            v.ScanDuration = 1;
            v.MaxNoPhases = nphase;
            v.MaxNoEchoes = necho;
            v.MaxNoSlices = nslice * nloca;
            v.MaxNoDynamics = ndyn;
            v.MaxNoMixes = ncoil * nmix * nextr1 * nextr2 * naver;
            
            if ( strcmpi( par.Recon.TKE, 'Yes' ) )
                v.MaxNoMixes = ncoil * nmix * nextr1 * nextr2 * naver + 1;
            end
            v.MaxNoBValues = par.Labels.DiffusionValues + 1;
            if strcmpi( diff, 'Y' )
                v.MaxNoGradientOrients = par.Labels.GradientOris + 1;
            else
                v.MaxNoGradientOrients = par.Labels.GradientOris;
            end
            v.NoLabelTypes = 0;
            v.PatientPosition = patpos;
            v.PreparationDirection = par.Scan.FoldOverDir( 1, : );
            v.Technique = technique;
            if ( all( par.Labels.Samples ) == 0 )
                try
                    v.ScanResolutionX = par.Labels.ScanResolution( 1 );
                    v.ScanResolutionY = par.Labels.ScanResolution( 2 );
                catch
                    try
                        v.ScanResolutionX = par.Labels.ScanResolutionX;
                        v.ScanResolutionY = par.Labels.ScanResolutionY;
                    catch
                        try
                            v.ScanResolutionX = size( par.Data, 1 );
                            v.ScanResolutionY = size( par.Data, 2 );
                        end
                    end
                end
            else
                v.ScanResolutionX = par.Labels.Samples( 1, 1 );
                v.ScanResolutionY = round( par.Labels.Samples( 1, 2 ) * rFOV );
            end
            v.ScanMode = par.Scan.ScanMode;
            v.RepetitionTimes = par.Scan.TR;
            v.FOVAP = fov( 1, 1 );
            v.FOVFH = fov( 1, 2 );
            v.FOVRL = fov( 1, 3 );
            v.WaterFatShift = wfs;
            v.AngulationAP = angulation( 1, 1 );
            v.AngulationFH = angulation( 1, 2 );
            v.AngulationRL = angulation( 1, 3 );
            v.OffCenterAP = av_offcentre( 1, 1 );
            v.OffCenterFH = av_offcentre( 1, 2 );
            v.OffCenterRL = av_offcentre( 1, 3 );
            v.FlowCompensation = flow_comp;
            v.Presaturation = 'N';
            v.PhaseEncodingVelocity = venc;
            v.MTC = mtc;
            v.SPIR = spir;
            v.EPIfactor = epi_factor;
            v.DynamicScan = dyn_scan;
            v.Diffusion = diff;
            v.DiffusionEchoTime = par.Labels.DiffusionEchoTime;
            v.DiffusionValues = par.Labels.DiffusionValues;
            if strcmpi( diff, 'Y' )
                v.GradientOris = par.Labels.GradientOris + 1;
            else
                v.GradientOris = 1;
            end
            
            v.ASLNolabelTypes = par.Scan.ASLNolabelTypes;
            
            fn = fieldnames( v );
            for i = 1:length( fn )
                if isempty( v.( fn{ i } ) )
                    v.( fn{ i } ) = 0;
                end
            end
            nr_loops = length( par.Recon.ExportRECImgTypes );
            
            lI = length( I( : ) ) - nr_images2;
            for type_loop = 1:nr_loops
                for i = 1:lI
                    
                    switch par.Recon.ExportRECImgTypes{ type_loop }
                        case 'M'
                            try
                                ri = I( i ).RescaleIntercept.M;
                                rs = I( i ).RescaleSlope.M;
                                ss = I( i ).ScaleSlope.M;
                                wc = I( i ).WindowCenter.M;
                                ww = I( i ).WindowWidth.M;
                            catch
                                ri = I( i ).RescaleIntercept( 1 );
                                rs = I( i ).RescaleSlope( 1 );
                                ss = I( i ).ScaleSlope( 1 );
                                wc = I( i ).WindowCenter( 1 );
                                ww = I( i ).WindowWidth( 1 );
                            end
                        case 'R'
                            try
                                ri = I( i ).RescaleIntercept.R;
                                rs = I( i ).RescaleSlope.R;
                                ss = I( i ).ScaleSlope.R;
                                wc = I( i ).WindowCenter.R;
                                ww = I( i ).WindowWidth.R;
                            catch
                                ri = I( i ).RescaleIntercept( 2 );
                                rs = I( i ).RescaleSlope( 2 );
                                ss = I( i ).ScaleSlope( 2 );
                                wc = I( i ).WindowCenter( 2 );
                                ww = I( i ).WindowWidth( 2 );
                            end
                        case 'I'
                            try
                                ri = I( i ).RescaleIntercept.I;
                                rs = I( i ).RescaleSlope.I;
                                ss = I( i ).ScaleSlope.I;
                                wc = I( i ).WindowCenter.I;
                                ww = I( i ).WindowWidth.I;
                            catch
                                ri = I( i ).RescaleIntercept( 3 );
                                rs = I( i ).RescaleSlope( 3 );
                                ss = I( i ).ScaleSlope( 3 );
                                wc = I( i ).WindowCenter( 3 );
                                ww = I( i ).WindowWidth( 3 );
                            end
                        case 'P'
                            try
                                ri = I( i ).RescaleIntercept.P;
                                rs = I( i ).RescaleSlope.P;
                                ss = I( i ).ScaleSlope.P;
                                wc = I( i ).WindowCenter.P;
                                ww = I( i ).WindowWidth.P;
                            catch
                                ri = I( i ).RescaleIntercept( 4 );
                                rs = I( i ).RescaleSlope( 4 );
                                ss = I( i ).ScaleSlope( 4 );
                                wc = I( i ).WindowCenter( 4 );
                                ww = I( i ).WindowWidth( 4 );
                            end
                    end
                    
                    v.ImageInformation.Slice( ( type_loop - 1 ) * lI + i, 1 ) = sub2ind( [ nslice, nloca ], I( i ).Slice, I( i ).Location );
                    
                    if is_asl
                        v.ImageInformation.Echo( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Extra1 - 1;
                    else
                        v.ImageInformation.Echo( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Echo;
                    end
                    
                    if is_flow || is_asl
                        v.ImageInformation.Dynamic( ( type_loop - 1 ) * lI + i, 1 ) = sub2ind( [ ndyn, ncoil, nmix, 1, nextr2, naver ], dynamics( i ), I( i ).Coil, I( i ).Mix, 1, I( i ).Extra2, I( i ).Average );
                    else
                        v.ImageInformation.Dynamic( ( type_loop - 1 ) * lI + i, 1 ) = sub2ind( [ ndyn, ncoil, nmix, nextr1, nextr2, naver ], dynamics( i ), I( i ).Coil, I( i ).Mix, I( i ).Extra1, I( i ).Extra2, I( i ).Average );
                    end
                    v.ImageInformation.Phase( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).CardiacPhase;
                    cur_bvalue = 1;
                    if isfield( par.Labels, 'DiffusionBValues' )
                        if ~isempty( I( i ).DiffusionBFactor )
                            cur_bvalue = find( par.Labels.DiffusionBValues == I( i ).DiffusionBFactor, 1 );
                        end
                    else
                        try
                            if ~isempty( I( i ).DiffusionBFactor )
                                cur_bvalue = I( i ).DiffusionBFactor;
                            end
                        end
                    end
                    
                    v.ImageInformation.BValue( ( type_loop - 1 ) * lI + i, 1 ) = cur_bvalue;
                    v.ImageInformation.GradOrient( ( type_loop - 1 ) * lI + i, 1 ) = max( [ 0, I( i ).DiffusionBValueNr ] );
                    v.ImageInformation.LabelType( ( type_loop - 1 ) * lI + i, 1 ) = '-';
                    v.ImageInformation.Type( ( type_loop - 1 ) * lI + i, 1 ) = par.Recon.ExportRECImgTypes{ type_loop };
                    v.ImageInformation.Sequence( ( type_loop - 1 ) * lI + i, : ) = 'FFE';
                    v.ImageInformation.Index( ( type_loop - 1 ) * lI + i, 1 ) = ( type_loop - 1 ) * lI + i - 1;
                    v.ImageInformation.PixelSize( ( type_loop - 1 ) * lI + i, 1 ) = 16;
                    v.ImageInformation.ScanPercentage( ( type_loop - 1 ) * lI + i, 1 ) = min( [ 100, 100 * I( i ).ACQVoxelSize( 1 ) / I( i ).ACQVoxelSize( 2 ) ] );
                    v.ImageInformation.ResolutionX( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Resolution( 2 );
                    v.ImageInformation.ResolutionY( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Resolution( 1 );
                    v.ImageInformation.RescaleIntercept( ( type_loop - 1 ) * lI + i, 1 ) = ri;
                    v.ImageInformation.RescaleSlope( ( type_loop - 1 ) * lI + i, 1 ) = rs;
                    v.ImageInformation.ScaleSlope( ( type_loop - 1 ) * lI + i, 1 ) = ss;
                    v.ImageInformation.WindowCenter( ( type_loop - 1 ) * lI + i, 1 ) = wc;
                    v.ImageInformation.WindowWidth( ( type_loop - 1 ) * lI + i, 1 ) = ww;
                    v.ImageInformation.SliceThickness( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).SliceThickness;
                    v.ImageInformation.SliceGap( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).SliceGap;
                    v.ImageInformation.DisplayOrientation( ( type_loop - 1 ) * lI + i, : ) = 'NONE';
                    v.ImageInformation.fMRIStatusIndication( ( type_loop - 1 ) * lI + i, 1 ) = 0;
                    v.ImageInformation.ImageTypeEdEs( ( type_loop - 1 ) * lI + i, 1 ) = 'U';
                    v.ImageInformation.PixelSpacing( ( type_loop - 1 ) * lI + i, : ) = I( i ).RecVoxelSize( 1:2 );
                    v.ImageInformation.EchoTime( ( type_loop - 1 ) * lI + i, 1 ) = max( [ 0, I( i ).EchoTime ] );
                    v.ImageInformation.DynScanBeginTime( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).DynamicScanTime;
                    v.ImageInformation.TriggerTime( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).TriggerTime;
                    v.ImageInformation.DiffusionBFactor( ( type_loop - 1 ) * lI + i, 1 ) = max( [ 0, I( i ).DiffusionBFactor ] );
                    v.ImageInformation.NoAverages( ( type_loop - 1 ) * lI + i, 1 ) = naver;
                    v.ImageInformation.ImageFlipAngle( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).FlipAngle;
                    v.ImageInformation.CardiacFrequency( ( type_loop - 1 ) * lI + i, 1 ) = 0;
                    v.ImageInformation.MinRRInterval( ( type_loop - 1 ) * lI + i, 1 ) = 0;
                    v.ImageInformation.MaxRRInterval( ( type_loop - 1 ) * lI + i, 1 ) = 0;
                    v.ImageInformation.TURBOFactor( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).TurboFactor;
                    v.ImageInformation.InversionDelay( ( type_loop - 1 ) * lI + i, 1 ) = 0;
                    if strcmpi( diff, 'Y' )
                        v.ImageInformation.ContrastType( ( type_loop - 1 ) * lI + i, : ) = 'DIFFUSION';
                    else
                        v.ImageInformation.ContrastType( ( type_loop - 1 ) * lI + i, : ) = 'T1';
                    end
                    v.ImageInformation.DiffusionAnisotropyType( ( type_loop - 1 ) * lI + i, 1 ) = '-';
                    if isempty( I( i ).DiffusionAPFHRL )
                        diffapfhrl = [ 0, 0, 0 ];
                    else
                        diffapfhrl = I( i ).DiffusionAPFHRL;
                    end
                    v.ImageInformation.DiffusionAP( ( type_loop - 1 ) * lI + i, 1 ) = diffapfhrl( 1 );
                    v.ImageInformation.DiffusionFH( ( type_loop - 1 ) * lI + i, 1 ) = diffapfhrl( 2 );
                    v.ImageInformation.DiffusionRL( ( type_loop - 1 ) * lI + i, 1 ) = diffapfhrl( 3 );
                    v.ImageInformation.AngulationAP( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Angulation( 1 );
                    v.ImageInformation.AngulationFH( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Angulation( 2 );
                    v.ImageInformation.AngulationRL( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Angulation( 3 );
                    v.ImageInformation.OffcenterAP( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Offcentre( 1 );
                    v.ImageInformation.OffcenterFH( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Offcentre( 2 );
                    v.ImageInformation.OffcenterRL( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Offcentre( 3 );
                    switch I( i ).Orientation
                        case 1
                            ori = 'Transversal';
                        case 2
                            ori = 'Sagital    ';
                        case 3
                            ori = 'Coronal    ';
                    end
                    v.ImageInformation.SliceOrientation( ( type_loop - 1 ) * lI + i, : ) = ori;
                    
                    v.Extr1( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Extra1;
                    
                    if strcmpi( par.Scan.ASLType, 'no' )
                        label_type = 0;
                    else
                        if isempty( I( i ).LabelTypeASL )
                            label_type = 1;
                        else
                            label_type = I( i ).LabelTypeASL;
                        end
                    end
                    v.ImageInformation.LabelTypeASL( ( type_loop - 1 ) * lI + i, 1 ) = label_type;
                    
                    v.ImageInformation.NoData( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).NoData;
                end
            end
            if ( nr_images2 > 0 )
                for i = lI + 1:lI + nr_images2
                    
                    try
                        ri = I( i ).RescaleIntercept.M;
                        rs = I( i ).RescaleSlope.M;
                        ss = I( i ).ScaleSlope.M;
                        wc = I( i ).WindowCenter.M;
                        ww = I( i ).WindowWidth.M;
                    catch
                        ri = I( i ).RescaleIntercept( 1 );
                        rs = I( i ).RescaleSlope( 1 );
                        ss = I( i ).ScaleSlope( 1 );
                        wc = I( i ).WindowCenter( 1 );
                        ww = I( i ).WindowWidth( 1 );
                    end
                    
                    v.ImageInformation.Slice( ( type_loop - 1 ) * lI + i, 1 ) = sub2ind( [ nslice, nloca ], I( i ).Slice, I( i ).Location );
                    
                    if is_asl
                        v.ImageInformation.Echo( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Extra1 - 1;
                    else
                        v.ImageInformation.Echo( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Echo;
                    end
                    
                    if is_flow || is_asl
                        v.ImageInformation.Dynamic( ( type_loop - 1 ) * lI + i, 1 ) = sub2ind( [ ndyn, ncoil, nmix, 1, nextr2, naver ], dynamics( i ), I( i ).Coil, I( i ).Mix, 1, I( i ).Extra2, I( i ).Average );
                    else
                        v.ImageInformation.Dynamic( ( type_loop - 1 ) * lI + i, 1 ) = sub2ind( [ ndyn, ncoil, nmix, nextr1, nextr2, naver ], dynamics( i ), I( i ).Coil, I( i ).Mix, I( i ).Extra1, I( i ).Extra2, I( i ).Average );
                    end
                    v.ImageInformation.Phase( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).CardiacPhase;
                    cur_bvalue = 1;
                    if isfield( par.Labels, 'DiffusionBValues' )
                        if ~isempty( I( i ).DiffusionBFactor )
                            cur_bvalue = find( par.Labels.DiffusionBValues == I( i ).DiffusionBFactor, 1 );
                        end
                    else
                        try
                            cur_bvalue = I( i ).DiffusionBFactor;
                        end
                    end
                    
                    v.ImageInformation.BValue( ( type_loop - 1 ) * lI + i, 1 ) = cur_bvalue;
                    v.ImageInformation.GradOrient( ( type_loop - 1 ) * lI + i, 1 ) = max( [ 0, I( i ).DiffusionBValueNr ] );
                    v.ImageInformation.LabelType( ( type_loop - 1 ) * lI + i, 1 ) = '-';
                    v.ImageInformation.Type( ( type_loop - 1 ) * lI + i, 1 ) = par.Recon.ExportRECImgTypes{ 1 };
                    v.ImageInformation.Sequence( ( type_loop - 1 ) * lI + i, : ) = 'FFE';
                    v.ImageInformation.Index( ( type_loop - 1 ) * lI + i, 1 ) = ( type_loop - 1 ) * lI + i - 1;
                    v.ImageInformation.PixelSize( ( type_loop - 1 ) * lI + i, 1 ) = 16;
                    v.ImageInformation.ScanPercentage( ( type_loop - 1 ) * lI + i, 1 ) = min( [ 100, 100 * I( i ).ACQVoxelSize( 1 ) / I( i ).ACQVoxelSize( 2 ) ] );
                    v.ImageInformation.ResolutionX( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Resolution( 1 );
                    v.ImageInformation.ResolutionY( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Resolution( 2 );
                    v.ImageInformation.RescaleIntercept( ( type_loop - 1 ) * lI + i, 1 ) = ri;
                    v.ImageInformation.RescaleSlope( ( type_loop - 1 ) * lI + i, 1 ) = rs;
                    v.ImageInformation.ScaleSlope( ( type_loop - 1 ) * lI + i, 1 ) = ss;
                    v.ImageInformation.WindowCenter( ( type_loop - 1 ) * lI + i, 1 ) = wc;
                    v.ImageInformation.WindowWidth( ( type_loop - 1 ) * lI + i, 1 ) = ww;
                    v.ImageInformation.SliceThickness( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).SliceThickness;
                    v.ImageInformation.SliceGap( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).SliceGap;
                    v.ImageInformation.DisplayOrientation( ( type_loop - 1 ) * lI + i, : ) = 'NONE';
                    v.ImageInformation.fMRIStatusIndication( ( type_loop - 1 ) * lI + i, 1 ) = 0;
                    v.ImageInformation.ImageTypeEdEs( ( type_loop - 1 ) * lI + i, 1 ) = 'U';
                    v.ImageInformation.PixelSpacing( ( type_loop - 1 ) * lI + i, : ) = I( i ).RecVoxelSize( 1:2 );
                    v.ImageInformation.EchoTime( ( type_loop - 1 ) * lI + i, 1 ) = min( [ 0, I( i ).EchoTime ] );
                    v.ImageInformation.DynScanBeginTime( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).DynamicScanTime;
                    v.ImageInformation.TriggerTime( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).TriggerTime;
                    v.ImageInformation.DiffusionBFactor( ( type_loop - 1 ) * lI + i, 1 ) = max( [ 0, I( i ).DiffusionBFactor ] );
                    v.ImageInformation.NoAverages( ( type_loop - 1 ) * lI + i, 1 ) = naver;
                    v.ImageInformation.ImageFlipAngle( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).FlipAngle;
                    v.ImageInformation.CardiacFrequency( ( type_loop - 1 ) * lI + i, 1 ) = 0;
                    v.ImageInformation.MinRRInterval( ( type_loop - 1 ) * lI + i, 1 ) = 0;
                    v.ImageInformation.MaxRRInterval( ( type_loop - 1 ) * lI + i, 1 ) = 0;
                    v.ImageInformation.TURBOFactor( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).TurboFactor;
                    v.ImageInformation.InversionDelay( ( type_loop - 1 ) * lI + i, 1 ) = 0;
                    if strcmpi( diff, 'Y' )
                        v.ImageInformation.ContrastType( ( type_loop - 1 ) * lI + i, : ) = 'DIFFUSION';
                    else
                        v.ImageInformation.ContrastType( ( type_loop - 1 ) * lI + i, : ) = 'T1';
                    end
                    v.ImageInformation.DiffusionAnisotropyType( ( type_loop - 1 ) * lI + i, 1 ) = '-';
                    if isempty( I( i ).DiffusionAPFHRL )
                        diffapfhrl = [ 0, 0, 0 ];
                    else
                        diffapfhrl = I( i ).DiffusionAPFHRL;
                    end
                    v.ImageInformation.DiffusionAP( ( type_loop - 1 ) * lI + i, 1 ) = diffapfhrl( 1 );
                    v.ImageInformation.DiffusionFH( ( type_loop - 1 ) * lI + i, 1 ) = diffapfhrl( 2 );
                    v.ImageInformation.DiffusionRL( ( type_loop - 1 ) * lI + i, 1 ) = diffapfhrl( 3 );
                    v.ImageInformation.AngulationAP( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Angulation( 1 );
                    v.ImageInformation.AngulationFH( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Angulation( 2 );
                    v.ImageInformation.AngulationRL( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Angulation( 3 );
                    v.ImageInformation.OffcenterAP( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Offcentre( 1 );
                    v.ImageInformation.OffcenterFH( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Offcentre( 2 );
                    v.ImageInformation.OffcenterRL( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Offcentre( 3 );
                    switch I( i ).Orientation
                        case 1
                            ori = 'Transversal';
                        case 2
                            ori = 'Sagital    ';
                        case 3
                            ori = 'Coronal    ';
                    end
                    v.ImageInformation.SliceOrientation( ( type_loop - 1 ) * lI + i, : ) = ori;
                    
                    v.Extr1( ( type_loop - 1 ) * lI + i, 1 ) = I( i ).Extra1;
                    
                    if isempty( I( i ).LabelTypeASL )
                        label_type = 1;
                    else
                        label_type = I( i ).LabelTypeASL;
                    end
                    v.ImageInformation.LabelTypeASL( ( type_loop - 1 ) * lI + i, 1 ) = label_type;
                end
            end
            
            fn = fieldnames( v.ImageInformation );
            for i = 1:length( fn )
                for j = 1:length( v.ImageInformation.( fn{ i } ) )
                    if isempty( v.ImageInformation.( fn{ i } )( j ) )
                        v.ImageInformation.( fn{ i } )( j ) = 0;
                    end
                end
            end
        end
        function values = xmlprideread( filename )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            global PRIDE
            PRIDE.XML_TEMPLATE = 'PRIDE_Series_Template.XML';
            
            PRIDE.XML_HEADER = 'PRIDE_V5';
            PRIDE.XML_SERIES_HEADER = 'Series_Info';
            PRIDE.XML_IMAGE_ARR_HEADER = 'Image_Array';
            PRIDE.XML_IMAGE_HEADER = 'Image_Info';
            PRIDE.XML_IMAGE_KEY_HEADER = 'Key';
            PRIDE.XML_ATTRIB_HEADER = 'Attribute';
            
            
            try
                xml_tree = xmlread( filename );
            catch
                error( [ 'Error reading .xml file ', filename ] )
            end
            values = MRparameter.XML_read_upper_part( xml_tree );
            values = MRparameter.XML_read_lower_part( xml_tree, values );
        end
        function values = XML_read_upper_part( tree )
            
            
            global PRIDE
            PRIDEseriesInfoNode = tree.getElementsByTagName( PRIDE.XML_SERIES_HEADER );
            PRIDEseriesAttribList = PRIDEseriesInfoNode.item( 0 ).getElementsByTagName( PRIDE.XML_ATTRIB_HEADER );
            numAttributes = PRIDEseriesAttribList.getLength;
            values = [  ];
            for attribNum = 0:numAttributes - 1
                elim = PRIDEseriesAttribList.item( attribNum );
                values = MRparameter.XML_getAttribFromElim( elim, values );
            end
        end
        function values = XML_read_lower_part( tree, values )
            
            
            global PRIDE
            PRIDEimageInfoNode = tree.getElementsByTagName( PRIDE.XML_IMAGE_HEADER );
            PRIDEimageAttribList = PRIDEimageInfoNode.item( 0 ).getElementsByTagName( PRIDE.XML_ATTRIB_HEADER );
            numImages = PRIDEimageInfoNode.getLength;
            numAttributes = PRIDEimageAttribList.getLength;
            attributes = [  ];
            for attribNum = 0:numAttributes - 1
                elim = PRIDEimageAttribList.item( attribNum );
                attributes = MRparameter.XML_getAttribFromElim( elim, attributes );
            end
            fn = fieldnames( attributes );
            for imageNum = 1:numImages - 1
                PRIDEimageAttribList = PRIDEimageInfoNode.item( imageNum ).getElementsByTagName( PRIDE.XML_ATTRIB_HEADER );
                numAttributes = PRIDEimageAttribList.getLength;
                attributes_image = [  ];
                for attribNum = 0:numAttributes - 1
                    elim = PRIDEimageAttribList.item( attribNum );
                    attributes_image = MRparameter.XML_getAttribFromElim( elim, attributes_image );
                end
                for i = 1:length( fn )
                    
                    newlength = length( attributes_image.( fn{ i } )( 1, : ) );
                    if ( length( attributes.( fn{ i } )( 1, : ) ) < newlength )
                        blanks = repmat( char( 32 ), [ size( attributes.( fn{ i } ), 1 ), newlength - size( attributes.( fn{ i } ), 2 ) ] );
                        attributes.( fn{ i } ) = [ attributes.( fn{ i } ), blanks ];
                    elseif ( length( attributes.( fn{ i } )( 1, : ) ) > newlength )
                        blanks = repmat( char( 32 ), [ size( attributes_image.( fn{ i } ), 1 ), newlength - size( attributes_image.( fn{ i } ), 2 ) ] );
                        attributes_image.( fn{ i } ) = [ attributes_image.( fn{ i } ), blanks ];
                    end
                    
                    attributes.( fn{ i } ) = [ attributes.( fn{ i } );attributes_image.( fn{ i } ) ];
                end
                
            end
            values.( 'ImageInformation' ) = attributes;
        end
        function attribsStruct = XML_getAttribFromElim( elim, attribsStruct )
            
            
            attribsList = elim.getAttributes(  );
            
            elimName = char( MRparameter.XML_getAttrValue( attribsList.getNamedItem( 'Name' ) ) );
            elimName( isspace( char( elimName ) ) ) = '';
            
            elimNodeType = MRparameter.XML_getAttrValue( attribsList.getNamedItem( 'Type' ) );
            
            if isempty( attribsList.getNamedItem( 'ArraySize' ) )
                elimNodeArrL = 1;
            else
                elimNodeArrL = MRparameter.XML_getAttrValue( attribsList.getNamedItem( 'ArraySize' ) );
            end
            
            if isempty( attribsList.getNamedItem( 'EnumType' ) )
                elimNodeEnum = '';
            else
                elimNodeEnum = MRparameter.XML_getAttrValue( attribsList.getNamedItem( 'EnumType' ) );
            end
            
            elimNodeValue = MRparameter.XML_getAttrValue( elim );
            elimValue = [  ];
            elimValue = MRparameter.XML_convertStringToType( elimNodeValue, elimNodeType, elimNodeEnum );
            attribsStruct.( elimName ) = elimValue;
        end
        function value = XML_getAttrValue( attribNode )
            
            
            valueAttribNode = attribNode.getFirstChild;
            if ( valueAttribNode.getNodeType == 3 )
                value = valueAttribNode.getData;
            end
        end
        function value = XML_convertStringToType( elimNodeValue, elimNodeType, elimNodeEnum )
            
            
            switch char( elimNodeType )
                case { 'String', 'Date', 'Time', 'Boolean', 'Enumeration' }
                    value = char( elimNodeValue );
                case 'Int16'
                    value = int16( str2num( elimNodeValue ) );
                case 'Int32'
                    value = int32( str2num( elimNodeValue ) );
                case 'Float'
                    value = single( str2num( elimNodeValue ) );
                case 'Double'
                    value = double( str2num( elimNodeValue ) );
                case 'UInt16'
                    value = uint16( str2num( elimNodeValue ) );
                case 'UInt32'
                    value = uint32( str2num( elimNodeValue ) );
                otherwise
                    value = char( elimNodeValue );
            end
        end
        
        
        function A = get_transformation_matrix( from_system, to_system, Angulation, Offcentre, Resolution, ImageMatrix, varargin )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            pixel = 1;
            shift = 1;
            
            for i = 1:2:length( varargin )
                switch varargin{ i }
                    case { 'Units', 'units' }
                        if i + 1 <= length( varargin )
                            switch varargin{ i + 1 }
                                case { 'pixel', 'Pixel' }
                                    pixel = 1;
                                case { 'mm', 'MM' }
                                    pixel = 0;
                                otherwise
                                    error( 'Error in Transform: Unknown unit' );
                            end
                        else
                            error( 'Error in Transform: Please specify a unit' );
                        end
                    case { 'Shift', 'shift' }
                        if i + 1 < length( varargin )
                            switch varargin{ i + 1 }
                                case { 'yes', 'Yes' }
                                    shift = 1;
                                case { 'no', 'No' }
                                    shift = 0;
                                otherwise
                                    error( 'Error in Transform: the shift has to be yes or no' );
                            end
                        else
                            error( 'Error in Transform: Please specify a shift' );
                        end
                end
            end
            
            angrl = Angulation( 3 );
            angap = Angulation( 1 );
            angfh = Angulation( 2 );
            
            
            
            rad = ( pi / 180 );
            R_RL = [ 1, 0, 0;0, cos( angrl * rad ),  - sin( angrl * rad );0, sin( angrl * rad ), cos( angrl * rad ) ];
            R_AP = [ cos( angap * rad ), 0, sin( angap * rad );0, 1, 0; - sin( angap * rad ), 0, cos( angap * rad ) ];
            R_FH = [ cos( angfh * rad ),  - sin( angfh * rad ), 0;sin( angfh * rad ), cos( angfh * rad ), 0;0, 0, 1 ];
            OMatrix = R_RL * R_AP * R_FH;
            
            
            
            Offcenter_RAF = [ Offcentre( 3 ),  ...
                Offcentre( 1 ),  ...
                Offcentre( 2 ) ];
            
            
            
            A_RAF = [ OMatrix, Offcenter_RAF' ];
            A_RAF = [ A_RAF;0, 0, 0, 1 ];
            
            
            
            ShiftMat = eye( 4 );
            if shift
                ShiftMat( :, 4 ) = [  - ( ImageMatrix( 1 ) / 2 + 0.5 ); - ( ImageMatrix( 2 ) / 2 + 0.5 ); - ( ImageMatrix( 3 ) / 2 + 0.5 );1 ];
                
                
            end
            
            
            
            PermRAF = eye( 4 );
            PermRAF( 1:3, 1:3 ) = MRparameter.get_coord_transformation( from_system, 'RL AP FH' );
            
            
            Pix2MM = eye( 4 );
            if pixel
                Pix2MM( 1, 1 ) = Resolution( 3 );
                Pix2MM( 2, 2 ) = Resolution( 1 );
                Pix2MM( 3, 3 ) = Resolution( 2 );
            end
            
            
            
            PermOUT = eye( 4 );
            PermOUT( 1:3, 1:3 ) = MRparameter.get_coord_transformation( 'RL AP FH', to_system );
            
            A = PermOUT * A_RAF * Pix2MM * PermRAF * ShiftMat;
        end
        function n = coord2num( coord )
            if size( coord, 1 ) == 1
                coord = MRparameter.unformat_coord_str( coord );
            end
            
            n = double( coord );
            if size( n, 2 ) == 2
                n = [ zeros( size( n, 1 ), 1 ) + 32, n ];
            end
            n( :, 3 ) = 1;
            
            n( n == 32 ) = 1;
            n( n == 45 ) =  - 1;
            n( n == 82 ) = 1;
            n( n == 76 ) =  - 1;
            n( n == 65 ) = 2;
            n( n == 80 ) =  - 2;
            n( n == 70 ) = 3;
            n( n == 72 ) =  - 3;
            
            n = prod( n, 2 );
        end
        function c = num2coord( num )
            c = zeros( size( num, 1 ), 3 );
            s = sign( num );
            c( :, 1 ) = 32;
            if s( abs( num ) == 1 ) == 1
                c( abs( num ) == 1, 2 ) = 82;
                c( abs( num ) == 1, 3 ) = 76;
            else
                c( abs( num ) == 1, 3 ) = 82;
                c( abs( num ) == 1, 2 ) = 76;
            end
            if s( abs( num ) == 2 ) == 1
                c( abs( num ) == 2, 2 ) = 65;
                c( abs( num ) == 2, 3 ) = 80;
            else
                c( abs( num ) == 2, 3 ) = 65;
                c( abs( num ) == 2, 2 ) = 80;
            end
            if s( abs( num ) == 3 ) == 1
                c( abs( num ) == 3, 2 ) = 70;
                c( abs( num ) == 3, 3 ) = 72;
            else
                c( abs( num ) == 3, 3 ) = 70;
                c( abs( num ) == 3, 2 ) = 72;
            end
            c = char( c );
        end
        function P = get_coord_transformation( c_from, c_to )
            if size( c_from, 1 ) == 1
                c_from = MRparameter.unformat_coord_str( c_from );
            end
            if size( c_to, 1 ) == 1
                c_to = MRparameter.unformat_coord_str( c_to );
            end
            
            if ischar( c_from )
                c_from = MRparameter.coord2num( c_from );
            end
            if ischar( c_to )
                c_to = MRparameter.coord2num( c_to );
            end
            s_from = sign( c_from );
            s_to = sign( c_to );
            
            P = zeros( length( c_to ), length( c_from ) );
            
            [ im, permutation ] = ismember( abs( c_to ), abs( c_from ) );
            for i = 1:length( permutation )
                P( i, permutation( i ) ) = s_from( permutation( i ) ) * s_to( i );
            end
        end
        function c = format_coord_str( c )
            c = MRparameter.num2coord( MRparameter.coord2num( c ) );
            c = c';
            c = strtrim( c( : )' );
        end
        function c = unformat_coord_str( c )
            c = [ ' ', c ];
            c = reshape( c, 3, [  ] )';
        end
        function [ MPS, xyz, REC ] = get_coordinate_systems( PatientPosition, PatientOrientation, Orientation, FoldOverDir, FatShiftDir, AcqMode )
            switch PatientPosition
                case 'HeadFirst'
                    switch PatientOrientation
                        case 'Supine';
                            xyz = [ 'PA';'RL';'FH' ];
                        case 'Prone';
                            xyz = [ 'AP';'LR';'FH' ];
                        case 'Left';
                            xyz = [ 'LR';'PA';'FH' ];
                        case 'Right';
                            xyz = [ 'RL';'AP';'FH' ];
                        otherwise
                            xyz = [  ];
                    end
                    
                case 'FeetFirst'
                    switch PatientOrientation
                        case 'Supine';
                            xyz = [ 'PA';'LR';'HF' ];
                        case 'Prone';
                            xyz = [ 'AP';'RL';'HF' ];
                        case 'Left';
                            xyz = [ 'LR';'AP';'HF' ];
                        case 'Right';
                            xyz = [ 'RL';'PA';'HF' ];
                        otherwise
                            xyz = [  ];
                    end
                    
            end
            
            switch Orientation
                case 'TRA'
                    switch AcqMode
                        case 'Cartesian'
                            switch FoldOverDir
                                case 'AP'
                                    switch FatShiftDir
                                        case 'L'
                                            MPS = [ 'RL';'AP';'HF' ];
                                        case 'R'
                                            MPS = [ 'LR';'PA';'HF' ];
                                        case 'A'
                                            MPS = [ 'LR';'PA';'HF' ];
                                        case 'P'
                                            MPS = [ 'RL';'AP';'HF' ];
                                        case 'F'
                                            MPS = [ 'LR';'PA';'HF' ];
                                        case 'H'
                                            MPS = [ 'RL';'PA';'HF' ];
                                        otherwise
                                            MPS = [ 'RL';'AP';'HF' ];
                                    end
                                case 'RL'
                                    switch FatShiftDir
                                        case 'A'
                                            MPS = [ 'PA';'RL';'HF' ];
                                        case 'P'
                                            MPS = [ 'AP';'LR';'HF' ];
                                        case 'R'
                                            MPS = [ 'AP';'LR';'HF' ];
                                        case 'L'
                                            MPS = [ 'PA';'RL';'HF' ];
                                        case 'F'
                                            MPS = [ 'PA';'RL';'HF' ];
                                        case 'H'
                                            MPS = [ 'AP';'RL';'HF' ];
                                        otherwise
                                            MPS = [ 'PA';'RL';'HF' ];
                                    end
                                otherwise
                                    MPS = [  ];
                                    xyz = [  ];
                            end
                        case 'Radial'
                            MPS = [ 'PA';'RL';'HF' ];
                        case 'Spiral'
                            MPS = [ 'RL';'AP';'HF' ];
                        case 'Kooshball'
                            MPS = [ 'AP';'RL';'HF' ];
                        otherwise
                            MPS = [  ];
                            xyz = [  ];
                    end
                    REC = [ 'AP';'RL';'FH' ];
                case 'SAG'
                    switch AcqMode
                        case 'Cartesian'
                            switch FoldOverDir
                                case 'AP'
                                    switch FatShiftDir
                                        case 'F'
                                            MPS = [ 'HF';'PA';'RL' ];
                                        case 'H'
                                            MPS = [ 'FH';'AP';'RL' ];
                                        case 'A'
                                            MPS = [ 'HF';'PA';'RL' ];
                                        case 'P'
                                            MPS = [ 'FH';'AP';'RL' ];
                                        otherwise
                                            MPS = [ 'HF';'PA';'RL' ];
                                    end
                                case 'FH'
                                    switch FatShiftDir
                                        case 'A'
                                            MPS = [ 'PA';'FH';'RL' ];
                                        case 'P'
                                            MPS = [ 'AP';'HF';'RL' ];
                                        case 'F'
                                            MPS = [ 'AP';'HF';'RL' ];
                                        case 'H'
                                            MPS = [ 'PA';'FH';'RL' ];
                                        otherwise
                                            MPS = [ 'PA';'FH';'RL' ];
                                    end
                                otherwise
                                    MPS = [  ];
                                    xyz = [  ];
                            end
                        case 'Radial'
                            MPS = [ 'FH';'AP';'RL' ];
                        case 'Spiral'
                            MPS = [ 'AP';'HF';'RL' ];
                        case 'Kooshball'
                            MPS = [ 'HF';'AP';'RL' ];
                        otherwise
                            MPS = [  ];
                            xyz = [  ];
                    end
                    REC = [ 'HF';'AP';'LR' ];
                case 'COR'
                    switch AcqMode
                        case 'Cartesian'
                            switch FoldOverDir
                                case 'FH'
                                    switch FatShiftDir
                                        case 'L'
                                            MPS = [ 'RL';'HF';'PA' ];
                                        case 'R'
                                            MPS = [ 'LR';'FH';'PA' ];
                                        case 'F'
                                            MPS = [ 'RL';'HF';'PA' ];
                                        case 'H'
                                            MPS = [ 'LR';'FH';'PA' ];
                                        case 'A'
                                            MPS = [ 'LR';'FH';'PA' ];
                                        case 'P'
                                            MPS = [ 'RL';'FH';'PA' ];
                                        otherwise
                                            MPS = [ 'RL';'HF';'PA' ];
                                    end
                                case 'RL'
                                    switch FatShiftDir
                                        case 'F'
                                            MPS = [ 'HF';'LR';'PA' ];
                                        case 'H'
                                            MPS = [ 'FH';'RL';'PA' ];
                                        case 'R'
                                            MPS = [ 'HF';'LR';'PA' ];
                                        case 'L'
                                            MPS = [ 'FH';'RL';'PA' ];
                                        case 'A'
                                            MPS = [ 'FH';'RL';'PA' ];
                                        case 'P'
                                            MPS = [ 'HF';'RL';'PA' ];
                                        otherwise
                                            MPS = [ 'HF';'LR';'PA' ];
                                    end
                                otherwise
                                    MPS = [  ];
                                    xyz = [  ];
                            end
                        case 'Radial'
                            
                            MPS = [ 'FH';'RL';'PA' ];
                        case 'Spiral'
                            MPS = [ 'RL';'HF';'PA' ];
                        case 'Kooshball'
                            MPS = [ 'HF';'RL';'PA' ];
                        otherwise
                            MPS = [  ];
                            xyz = [  ];
                    end
                    REC = [ 'HF';'RL';'AP' ];
                otherwise
                    MPS = [  ];
                    xyz = [  ];
                    REC = [  ];
            end
            
            MPS = MRparameter.format_coord_str( MPS );
            xyz = MRparameter.format_coord_str( xyz );
            REC = MRparameter.format_coord_str( REC );
        end
        
        
        function labels = retro_fill_holes( labels, interpolation_method, PER_COIL, WRAP_AROUND, immediage_averaging, skip_phase )
            
            
            if PER_COIL
                mask = labels.typ == 1;
            else
                first_profile = find( labels.typ == 1, 1 );
                mask = labels.typ == 1 & labels.chan == labels.chan( first_profile );
            end
            
            nr_mix = length( unique( labels.mix( mask ) ) );
            nr_dyn = length( unique( labels.dyn( mask ) ) );
            nr_card = length( min( unique( labels.card( mask ) ) ):max( unique( labels.card( mask ) ) ) );
            nr_loca = length( unique( labels.loca( mask ) ) );
            nr_echo = length( unique( labels.echo( mask ) ) );
            nr_extr1 = length( unique( labels.extr1( mask ) ) );
            nr_extr2 = length( unique( labels.extr2( mask ) ) );
            nr_ky = length( unique( labels.ky( mask ) ) );
            nr_kz = length( unique( labels.kz( mask ) ) );
            nr_aver = length( unique( labels.aver( mask ) ) );
            
            nr_coils = length( unique( labels.chan( labels.typ == 1 ) ) );
            
            if PER_COIL
                filled_array = zeros( nr_card + 2, nr_ky, nr_kz, nr_coils, nr_dyn,  ...
                    nr_echo, nr_loca, nr_mix, nr_extr1, nr_extr2, nr_aver, 'single' );
            else
                filled_array = zeros( nr_card + 2, nr_ky, nr_kz, 1, nr_dyn,  ...
                    nr_echo, nr_loca, nr_mix, nr_extr1, nr_extr2, nr_aver, 'single' );
            end
            
            [ tf, mix ] = ismember( labels.mix( mask ), unique( labels.mix( mask ) ) );
            [ tf, dyn ] = ismember( labels.dyn( mask ), unique( labels.dyn( mask ) ) );
            [ tf, card ] = ismember( labels.card( mask ), min( unique( labels.card( mask ) ) ):max( unique( labels.card( mask ) ) ) );
            card = card + 1;
            [ tf, loca ] = ismember( labels.loca( mask ), unique( labels.loca( mask ) ) );
            [ tf, echo ] = ismember( labels.echo( mask ), unique( labels.echo( mask ) ) );
            [ tf, extr1 ] = ismember( labels.extr1( mask ), unique( labels.extr1( mask ) ) );
            [ tf, extr2 ] = ismember( labels.extr2( mask ), unique( labels.extr2( mask ) ) );
            [ tf, ky ] = ismember( labels.ky( mask ), unique( labels.ky( mask ) ) );
            [ tf, kz ] = ismember( labels.kz( mask ), unique( labels.kz( mask ) ) );
            [ tf, aver ] = ismember( labels.aver( mask ), unique( labels.aver( mask ) ) );
            
            if PER_COIL
                [ tf, chan ] = ismember( labels.chan( mask ), unique( labels.chan( mask ) ) );
            else
                chan = ones( size( ky ) );
            end
            
            
            ind = sub2ind( size( filled_array ), card, ky, kz, chan, dyn, echo, loca, mix, extr1, extr2, aver );
            filled_array( ind ) = find( mask );
            
            
            
            filled_array( 1, : ) = filled_array( end  - 1, : );
            filled_array( end , : ) = filled_array( 2, : );
            
            
            
            filled_array( :, sum( filled_array ) == 0 ) =  - 1;
            
            
            
            filled_array( 1, filled_array( 1, : ) == 0 ) =  - 1;
            filled_array( end , filled_array( end , : ) == 0 ) =  - 1;
            
            
            
            if ~WRAP_AROUND
                filled_array( 1, : ) =  - 1;
                filled_array( end , : ) =  - 1;
            end
            
            
            rtop = zeros( size( filled_array ) );
            rtop( ind ) = labels.rtop( mask );
            
            
            rtop( 1, : ) = rtop( end  - 1, : );
            rtop( end , : ) = rtop( 2, : );
            
            
            rr = zeros( size( filled_array ) );
            rr( ind ) = labels.rr( mask );
            
            
            rr( 1, : ) = rr( end  - 1, : );
            rr( end , : ) = rr( 2, : );
            
            
            
            rtop( 1, : ) = rtop( 1, : ) - rr( 1, : );
            rtop( end , : ) = rtop( end , : ) + rr( end , : );
            
            
            hp = zeros( size( filled_array ) );
            hp( ind ) = labels.card( mask );
            
            hp( 1, : ) = hp( end  - 1, : );
            hp( end , : ) = hp( 2, : );
            
            for i = 1:size( hp, 1 )
                hp( i, : ) = max( hp( i, : ) );
            end
            
            
            ky = zeros( size( filled_array ) );
            ky( ind ) = labels.ky( mask );
            
            ky( 1, : ) = ky( end  - 1, : );
            ky( end , : ) = ky( 2, : );
            
            for i = 1:size( ky, 2 )
                [ ma, ind ] = max( abs( ky( :, i ) ) );
                ky( :, i ) = ky( ind, i );
            end
            s = size( ky );
            ky = repmat( ky( :, :, 1 ), [ 1, 1, size( ky( :, :, : ), 3 ) ] );
            ky = reshape( ky, s );
            
            
            
            if strcmpi( immediage_averaging, 'yes' )
                holes = find( bsxfun( @plus, max( filled_array, [  ], 11 ), filled_array ) == 0 );
            else
                holes = find( filled_array == 0 );
            end
            
            
            FillerInfo_ind = zeros( length( holes ), 1 ) - 1;
            FillerInfo_card = zeros( length( holes ), 1 ) - 1;
            FillerInfo_rtop = zeros( length( holes ), 1 ) - 1;
            
            i = 1;
            cur_filler = 1;
            filler_ind = NaN;
            finished = false;
            
            
            switch interpolation_method
                case { 'Nearest', 'nearest' }
                    nr_neighbour_profiles = 1;
                case { 'Average', 'average' }
                    nr_neighbour_profiles = 2;
                case { 'Linear', 'linear' }
                    nr_neighbour_profiles = 2;
                case { 'Cubic', 'cubic' }
                    nr_neighbour_profiles = 4;
            end
            
            max_ind = length( filled_array( : ) );
            neighbours_pos = zeros( length( holes ), ceil( nr_neighbour_profiles / 2 ) ) - 1;
            neighbours_neg = zeros( length( holes ), ceil( nr_neighbour_profiles / 2 ) ) - 1;
            cur_neighbours_ind_pos = holes + 1;
            cur_neighbours_ind_neg = holes - 1;
            cur_neighbour_pos = ones( length( holes ), 1 );
            cur_neighbour_neg = ones( length( holes ), 1 );
            while ~finished && i < nr_card + 2
                
                
                if WRAP_AROUND
                    cur_neighbours_ind_pos( cur_neighbours_ind_pos > max_ind ) = cur_neighbours_ind_pos( cur_neighbours_ind_pos > max_ind ) - nr_card - 1;
                    cur_neighbours_ind_neg( cur_neighbours_ind_neg < 1 ) = cur_neighbours_ind_neg( cur_neighbours_ind_neg < 1 ) + nr_card + 1;
                else
                    cur_neighbours_ind_pos( cur_neighbours_ind_pos > max_ind & cur_neighbours_ind_pos > 0 ) =  - cur_neighbours_ind_pos( cur_neighbours_ind_pos > max_ind & cur_neighbours_ind_pos > 0 );
                    cur_neighbours_ind_neg( cur_neighbours_ind_neg < 1 & cur_neighbours_ind_neg > 0 ) =  - cur_neighbours_ind_neg( cur_neighbours_ind_neg < 1 & cur_neighbours_ind_neg > 0 );
                end
                
                
                
                if WRAP_AROUND
                    cur_neighbours_ind_pos( ky( cur_neighbours_ind_pos ) ~= ky( holes ) ) = cur_neighbours_ind_pos( ky( cur_neighbours_ind_pos ) ~= ky( holes ) ) - nr_card - 1;
                    cur_neighbours_ind_neg( ky( cur_neighbours_ind_neg ) ~= ky( holes ) ) = cur_neighbours_ind_neg( ky( cur_neighbours_ind_neg ) ~= ky( holes ) ) + nr_card + 1;
                else
                    cur_neighbours_ind_pos( ky( cur_neighbours_ind_pos ) ~= ky( holes ) & cur_neighbours_ind_pos > 0 ) =  - cur_neighbours_ind_pos( ky( cur_neighbours_ind_pos ) ~= ky( holes ) & cur_neighbours_ind_pos > 0 );
                    cur_neighbours_ind_neg( ky( cur_neighbours_ind_neg ) ~= ky( holes ) & cur_neighbours_ind_neg > 0 ) =  - cur_neighbours_ind_neg( ky( cur_neighbours_ind_neg ) ~= ky( holes ) & cur_neighbours_ind_neg > 0 );
                end
                
                
                
                cur_neighbours_ind_pos( filled_array( cur_neighbours_ind_pos ) < 1 | cur_neighbour_pos > size( neighbours_pos, 2 ) & cur_neighbours_ind_pos > 0 ) =  - cur_neighbours_ind_pos( filled_array( cur_neighbours_ind_pos ) < 1 | cur_neighbour_pos > size( neighbours_pos, 2 ) & cur_neighbours_ind_pos > 0 );
                cur_neighbours_ind_neg( filled_array( cur_neighbours_ind_neg ) < 1 | cur_neighbour_neg > size( neighbours_neg, 2 ) & cur_neighbours_ind_neg > 0 ) =  - cur_neighbours_ind_neg( filled_array( cur_neighbours_ind_neg ) < 1 | cur_neighbour_neg > size( neighbours_neg, 2 ) & cur_neighbours_ind_neg > 0 );
                
                
                valid_pos = cur_neighbours_ind_pos > 0;
                ind = sub2ind( size( neighbours_pos ), find( valid_pos ), cur_neighbour_pos( valid_pos ) );
                
                neighbours_pos( ind ) = cur_neighbours_ind_pos( valid_pos );
                
                cur_neighbour_pos( valid_pos ) = cur_neighbour_pos( valid_pos ) + 1;
                
                
                valid_neg = cur_neighbours_ind_neg > 0;
                ind = sub2ind( size( neighbours_neg ), find( valid_neg ), cur_neighbour_neg( valid_neg ) );
                
                neighbours_neg( ind ) = cur_neighbours_ind_neg( valid_neg );
                
                cur_neighbour_neg( valid_neg ) = cur_neighbour_neg( valid_neg ) + 1;
                
                i = i + 1;
                finished = isempty( [ find( cur_neighbour_neg( : ) < size( neighbours_neg, 2 ) + 1 );find( cur_neighbour_pos( : ) < size( neighbours_pos, 2 ) + 1 ) ] );
                
                cur_neighbours_ind_pos = abs( cur_neighbours_ind_pos );
                cur_neighbours_ind_neg = abs( cur_neighbours_ind_neg );
                
                cur_neighbours_ind_pos = cur_neighbours_ind_pos + 1;
                cur_neighbours_ind_neg = cur_neighbours_ind_neg - 1;
            end
            
            
            
            if nr_neighbour_profiles == 1
                hp_holes = hp( holes );
                hp_neg = hp( neighbours_neg );
                hp_pos = hp( neighbours_pos );
                
                d_hp_neg = hp_holes - hp_neg;
                d_hp_neg( d_hp_neg < 0 ) = hp_holes( d_hp_neg < 0 ) - ( hp_neg( d_hp_neg < 0 ) - nr_card );
                
                d_hp_pos = hp_pos - hp_holes;
                d_hp_pos( d_hp_pos < 0 ) = ( hp_pos( d_hp_pos < 0 ) + nr_card ) - hp_holes( d_hp_pos < 0 );
                
                neighbours = zeros( size( neighbours_neg, 1 ), 1 );
                
                neg_smaller = d_hp_neg < d_hp_pos;
                neighbours( neg_smaller ) = neighbours_neg( neg_smaller );
                
                pos_smaller = d_hp_neg >= d_hp_pos;
                neighbours( pos_smaller ) = neighbours_pos( pos_smaller );
                
            else
                
                
                
                neighbours = cat( 1, neighbours_neg, neighbours_pos );
            end
            
            
            
            
            hp_holes = repmat( hp( holes ), [ nr_neighbour_profiles, 1 ] );
            
            
            hp_holes = hp_holes( neighbours > 0 );
            neighbours = neighbours( neighbours > 0 );
            
            
            filler_ind = filled_array( neighbours );
            
            
            
            if ~isempty( skip_phase )
                mask = ismember( hp( holes ), skip_phase );
                neighbours( mask ) = [  ];
                hp_holes( mask ) = [  ];
            end
            
            
            rtop_holes = rtop( neighbours );
            
            if ~PER_COIL
                filler_ind = repmat( filler_ind', [ nr_coils, 1 ] );
                filler_ind = bsxfun( @plus, filler_ind, ( 0:nr_coils - 1 )' );
                filler_ind = filler_ind( : );
                
                hp_holes = repmat( hp_holes', [ nr_coils, 1 ] );
                hp_holes = hp_holes( : );
                
                rtop_holes = repmat( rtop_holes', [ nr_coils, 1 ] );
                rtop_holes = rtop_holes( : );
            end
            
            
            if ~isempty( filler_ind )
                FillerInfo_ind( cur_filler:cur_filler + length( filler_ind ) - 1 ) = filler_ind;
                FillerInfo_card( cur_filler:cur_filler + length( filler_ind ) - 1 ) = hp_holes;
                FillerInfo_rtop( cur_filler:cur_filler + length( filler_ind ) - 1 ) = rtop_holes;
                cur_filler = cur_filler + length( filler_ind );
            end
            
            FillerInfo_card( FillerInfo_ind < 0 ) = [  ];
            FillerInfo_rtop( FillerInfo_ind < 0 ) = [  ];
            FillerInfo_ind( FillerInfo_ind < 0 ) = [  ];
            FillerInfo_card( FillerInfo_ind > length( labels.typ ) ) = [  ];
            FillerInfo_rtop( FillerInfo_ind > length( labels.typ ) ) = [  ];
            FillerInfo_ind( FillerInfo_ind > length( labels.typ ) ) = [  ];
            if ~isempty( FillerInfo_ind )
                labels = structfun( @( x )[ x( :, 1 );x( FillerInfo_ind, 1 ) ], labels, 'UniformOutput', 0 );
                labels.card( end  - length( FillerInfo_ind ) + 1:end  ) = FillerInfo_card;
                labels.rtop( end  - length( FillerInfo_ind ) + 1:end  ) = FillerInfo_rtop;
            end
        end
        
        
        function MachineID = get_machineID
            
            mac = MRparameter.getmac(  );
            diskid = MRparameter.getDiskID(  );
            
            mac = strrep( mac, '-', '' );
            mac = strrep( mac, ':', '' );
            diskid = strrep( diskid, '-', '' );
            
            while length( diskid ) < 8
                diskid = [ '0', diskid ];
            end
            
            id = [ mac, diskid ];
            id = reshape( id', 2, [  ] )';
            
            id_bin = reshape( dec2bin( hex2dec( id ), 8 )', 5, [  ] )';
            MachineID = MRparameter.dec2bit32( bin2dec( id_bin ) );
            
            MachineID = reshape( MachineID, 1, [  ] );
            MachineID = [ MachineID( 1:4 ), '-', MachineID( 5:8 ), '-', MachineID( 9:12 ), '-', MachineID( 13:16 ) ];
            
            if ispc
                MachineID = [ 'W-', MachineID ];
            elseif ismac
                MachineID = [ 'A-', MachineID ];
            elseif isunix
                MachineID = [ 'L-', MachineID ];
            else
                MachineID = [ 'U-', MachineID ];
            end
        end
        function CheckAgain = ShowLicenseDialog( LicenseInfo )
            
            if nargin == 0
                [ LicenseFile, LicensePath, status ] = MRparameter.GetLicenseFile;
                MachineID = MRparameter.get_machineID;
                Version = 30;
                if status ~=  - 5
                    [ status, LicenseInfo ] = MRparameter.checkID( MachineID, LicenseFile, Version );
                else
                    LicenseInfo.LicenseFile = [  ];
                    LicenseInfo.Status = status;
                    LicenseInfo.ThisMachineID = MachineID;
                end
                version_file = which( 'Version.txt' );
                loopv = 1;
                fidv = fopen( version_file );
                if fidv ==  - 1
                    LicenseInfo( 1 ).ThisVersion = '3.0';
                else
                    while ~feof( fidv )
                        s{ loopv } = fgetl( fidv );
                        loopv = loopv + 1;
                    end
                    fclose( fidv );
                    s1 = strrep( s{ 1 }, 'MRecon: Version ', '' );
                    LicenseInfo( 1 ).ThisVersion = s1;
                end
            end
            fp = get( 0, 'DefaultFigurePosition' );
            
            figname = 'License Dialog';
            okstring = 'Store License';
            cancelstring = 'Cancel';
            min_x = 10;
            listbox_x = fp( 3 ) / 4;
            listbox_y = fp( 4 ) / 3;
            listbox_width = fp( 3 ) / 2;
            listbox_height = fp( 4 ) / 2.3;
            button_height = 30;
            button_width = 80;
            button_gap = 8;
            button_x = fp( 3 ) - 2 * button_width - button_gap - min_x;
            button_y = 10;
            panel_y = button_y + button_height + 5;
            image_width = 120;
            image_height = fp( 4 ) - panel_y - 2 * min_x;
            main_x = image_width + 2 * min_x;
            edit_x = main_x;
            edit_y = panel_y + min_x;
            edit_width = fp( 3 ) - main_x - 3 * min_x;
            edit_height = 22;
            text_height = 20;
            hyperlink_x = 0;
            hyperlink_y = 10;
            hyperlink_width = 70;
            hyperlink_height = 20;
            emaillink_x = main_x + 250;
            emaillink_y = edit_y + 2 * edit_height + 4;
            emaillink_width = 150;
            emaillink_height = 20;
            
            edt_string = { [ 'License(s) found: ', LicenseInfo( 1 ).LicenseFile ], '' };
            if ~isfield( LicenseInfo( 1 ), 'Status' ) || LicenseInfo( 1 ).Status ==  - 5
                edt_string{ 3 } = 'No licenses found';
            else
                edt_loop = 3;
                for i = 1:length( LicenseInfo )
                    edt_string{ edt_loop } = LicenseInfo( i ).LicenseKey;
                    edt_loop = edt_loop + 1;
                    switch LicenseInfo( i ).Status
                        case 1
                            edt_string{ edt_loop } = [ '<Html><FONT color="blue">', LicenseInfo( i ).Name, ' -> License valid until ', datestr( LicenseInfo( i ).Date, 'dd.mm.yyyy' ), '</font>' ];
                        case  - 1
                            edt_string{ edt_loop } = [ '<Html><FONT color="red">', LicenseInfo( i ).Name, ' -> License invalid on this computer</font>' ];
                        case  - 2
                            edt_string{ edt_loop } = [ '<Html><FONT color="red">', LicenseInfo( i ).Name, ' -> License expired on ', datestr( LicenseInfo( i ).Date, 'dd.mm.yyyy' ), '</font>' ];
                        case  - 3
                            edt_string{ edt_loop } = [ '<Html><FONT color="red">', LicenseInfo( i ).Name, ' -> License belongs to another version</font>' ];
                        case  - 4
                            edt_string{ edt_loop } = [ '<Html><FONT color="red">', LicenseInfo( i ).Name, ' -> License belongs to another GyroTools product</font>' ];
                        otherwise
                    end
                    edt_loop = edt_loop + 1;
                end
            end
            
            pms_path1 = 'G:\Site\';
            if exist( pms_path1, 'dir' ) > 0
                StoreInfo.System = 'Scanner';
            else
                StoreInfo.System = 'PC';
            end
            
            if ~isfield( LicenseInfo( 1 ), 'Status' ) || LicenseInfo( 1 ).Status ==  - 5
                StoreInfo.Action = 'new';
                
                if strcmpi( StoreInfo.System, 'Scanner' )
                    StoreInfo.Path = 'G:\Site\AvailablePatches\License\license.lic';
                else
                    StoreInfo.System = 'PC';
                    base_path = which( 'MRecon.m' );
                    if ~isempty( base_path )
                        StoreInfo.Path = strrep( base_path, 'MRecon.m', 'license/license.lic' );
                    else
                        base_path = which( 'MRecon.p' );
                        if ~isempty( base_path )
                            StoreInfo.Path = strrep( base_path, 'MRecon.p', 'license/license.lic' );
                        else
                            StoreInfo.Path = [  ];
                        end
                    end
                end
            else
                if strcmpi( StoreInfo.System, 'Scanner' )
                    StoreInfo.Path = 'G:\Site\AvailablePatches\License\license.lic';
                    StoreInfo.Action = 'new';
                else
                    StoreInfo.Action = 'append';
                    StoreInfo.Path = LicenseInfo( 1 ).LicenseFile;
                end
            end
            StoreInfo.MachineID = LicenseInfo( 1 ).ThisMachineID;
            
            
            fig_props = {  ...
                'name', figname ...
                , 'color', get( 0, 'DefaultUicontrolBackgroundColor' ) ...
                , 'resize', 'off' ...
                , 'numbertitle', 'off' ...
                , 'menubar', 'none' ...
                , 'windowstyle', 'modal' ...
                , 'visible', 'off' ...
                , 'createfcn', '' ...
                , 'position', fp ...
                , 'UserData', 0 ...
                , 'closerequestfcn', @MRparameter.OnCloseRequest ...
                };
            
            fig = figure( fig_props{ : } );
            
            FigColor = get( 0, 'DefaultUicontrolBackgroundcolor' );
            TextInfo.Units = 'pixels';
            TextInfo.FontSize = get( 0, 'FactoryUIControlFontSize' );
            TextInfo.FontWeight = get( fig, 'DefaultTextFontWeight' );
            TextInfo.HorizontalAlignment = 'left';
            TextInfo.HandleVisibility = 'callback';
            StInfo = TextInfo;
            StInfo.Style = 'text';
            StInfo.BackgroundColor = FigColor;
            StInfo.Units = 'Pixel';
            EdInfo = StInfo;
            EdInfo.FontWeight = get( fig, 'DefaultUicontrolFontWeight' );
            EdInfo.Style = 'edit';
            EdInfo.BackgroundColor = 'white';
            
            ImageAxes = axes(  ...
                'Parent', fig,  ...
                'Units', 'pixel',  ...
                'Position', [ min_x, panel_y + min_x, image_width, image_height ],  ...
                'Tag', 'ImageAxes',  ...
                'Xtick', [  ], 'YTick', [  ],  ...
                'Box', 'off' ...
                );
            
            try
                img = imread( 'license_dialog_img.png' );
            catch
                img = uint8( zeros( 355, 120, 3 ) + 255 );
            end
            imagesc( img, 'Parent', ImageAxes );
            axis( ImageAxes, 'off' );
            
            
            WelcomeString = uicontrol( StInfo,  ...
                'Position', [ main_x, fp( 4 ) - 4 * min_x, fp( 3 ) - main_x - min_x, text_height ],  ...
                'String', [ 'Welcome to MRecon version ', LicenseInfo( 1 ).ThisVersion ],  ...
                'Tag', 'WelcomeText' ...
                );
            MachineIDString = uicontrol( StInfo,  ...
                'Position', [ main_x, fp( 4 ) - 7 * min_x, 55, text_height ],  ...
                'String', 'MachineID:',  ...
                'Tag', 'MacineIDText' ...
                );
            
            MachineIDEdit = uicontrol( EdInfo,  ...
                'Position', [ main_x + 60, fp( 4 ) - 7 * min_x, 250, edit_height ],  ...
                'String', LicenseInfo( 1 ).ThisMachineID,  ...
                'Tag', 'Edit',  ...
                'UserData', LicenseInfo( 1 ).ThisMachineID,  ...
                'HorizontalAlignment', 'center' );
            set( MachineIDEdit, 'callback', @MRparameter.OnEditMachineID );
            
            MachineIDBrowseRadio = uicontrol( StInfo,  ...
                'Style', 'radiobutton',  ...
                'Position', [ main_x, edit_y + 2 * edit_height + 2, 150, text_height ],  ...
                'String', 'Browse for a license file:',  ...
                'callback', @MRparameter.OnBrowseRadio ...
                );
            
            StoreLicense = uicontrol( 'style', 'pushbutton',  ...
                'string', okstring,  ...
                'position', [ fp( 3 ) - button_width - min_x, button_y, button_width, button_height ],  ...
                'callback', @MRparameter.OnStoreLicense );
            
            browse_btn = uicontrol( 'style', 'pushbutton',  ...
                'string', 'Browse...',  ...
                'Enable', 'off',  ...
                'position', [ main_x + 150, edit_y + 2 * edit_height, button_width, 25 ],  ...
                'UserData', StoreLicense,  ...
                'Callback', @MRparameter.OnBrowse ...
                );
            
            MachineIDEditRadio = uicontrol( StInfo,  ...
                'Style', 'radiobutton',  ...
                'Position', [ main_x, edit_y + edit_height + 2, fp( 3 ) - main_x - min_x, text_height ],  ...
                'String', 'Enter a license key:',  ...
                'Value', 1,  ...
                'callback', @MRparameter.OnMachineIDRadio ...
                );
            
            license_key_edit = uicontrol( EdInfo,  ...
                'Position', [ main_x + 2 * min_x, edit_y, edit_width, edit_height ],  ...
                'Tag', 'Edit',  ...
                'HorizontalAlignment', 'center' ...
                );
            
            listbox = uicontrol( 'style', 'listbox',  ...
                'position', [ listbox_x, listbox_y, fp( 3 ) - main_x - min_x, listbox_height ],  ...
                'string', edt_string,  ...
                'backgroundcolor', 'w',  ...
                'max', 0,  ...
                'tag', 'listbox',  ...
                'value', 1,  ...
                'HitTest', 'off',  ...
                'SelectionHighlight', 'off' );
            
            hsp = uipanel( 'Parent', fig, 'Units', 'pixel',  ...
                'BorderType', 'beveledin',  ...
                'Position', [ min_x, panel_y, fp( 3 ) - 2 * min_x, 2 ] );
            
            cancel_btn = uicontrol( 'style', 'pushbutton',  ...
                'string', cancelstring,  ...
                'position', [ button_x, button_y, button_width, button_height ],  ...
                'callback', @MRparameter.doCancel );
            
            
            labelStr = '<html><center><a href="">GyroTools';
            cbStr = 'web(''http://www.gyrotools.com/'');';
            import javax.swing.JButton;
            hyperlink = JButton( labelStr );
            hyperlink.setCursor( java.awt.Cursor( java.awt.Cursor.HAND_CURSOR ) );
            hyperlink.setContentAreaFilled( 0 );
            [ hcomponent, hcontainer ] = javacomponent( hyperlink, [  ], fig );
            set( hcontainer, 'units', 'pixel',  ...
                'position', [ hyperlink_x, hyperlink_y, hyperlink_width, hyperlink_height ] );
            set( hyperlink, 'ActionPerformedCallback', cbStr );
            
            
            labelStr = '<html><center><a href="">Request License';
            cbStr = 'web(''mailto:martin.buehrer@gyrotools.com'');';
            import javax.swing.JButton;
            emaillink = JButton( labelStr );
            emaillink.setCursor( java.awt.Cursor( java.awt.Cursor.HAND_CURSOR ) );
            emaillink.setContentAreaFilled( 0 );
            [ hcomponent, hcontainer ] = javacomponent( emaillink, [  ], fig );
            set( hcontainer, 'units', 'pixel',  ...
                'position', [ emaillink_x, emaillink_y, emaillink_width, emaillink_height ] );
            set( emaillink, 'ActionPerformedCallback', cbStr );
            
            set( MachineIDBrowseRadio, 'Userdata', [ MachineIDEditRadio, browse_btn, license_key_edit ] );
            set( MachineIDEditRadio, 'Userdata', [ MachineIDBrowseRadio, browse_btn, license_key_edit ] );
            StoreInfo.LicenseKeyEditHandle = license_key_edit;
            
            set( StoreLicense, 'UserData', StoreInfo );
            
            set( fig, 'position', MRparameter.getnicedialoglocation( fp, get( fig, 'Units' ) ) );
            set( fig, 'visible', 'on' );drawnow;
            
            uiwait( fig );
            CheckAgain = get( fig, 'UserData' );
            delete( fig );
        end
        function [ RAF, A_RAF, A_MPS2RAF ] = mps2RAF( ijk, Angulation, Offcentre, MatrixSize, SliceOrientation, FOV, SliceGap )
            
            
            
            
            
            
            
            
            
            
            
            
            
            ijk = [ ijk;ones( size( ijk( 1, : ) ) ) ];
            
            angrl = Angulation( 3 );
            angap = Angulation( 1 );
            angfh = Angulation( 2 );
            
            
            
            rad = ( pi / 180 );
            R_RL = [ 1, 0, 0;0, cos( angrl * rad ),  - sin( angrl * rad );0, sin( angrl * rad ), cos( angrl * rad ) ];
            R_AP = [ cos( angap * rad ), 0, sin( angap * rad );0, 1, 0; - sin( angap * rad ), 0, cos( angap * rad ) ];
            R_FH = [ cos( angfh * rad ),  - sin( angfh * rad ), 0;sin( angfh * rad ), cos( angfh * rad ), 0;0, 0, 1 ];
            OMatrix = R_RL * R_AP * R_FH;
            
            
            
            Offcenter_RAF = [ Offcentre( 3 ),  ...
                Offcentre( 1 ),  ...
                Offcentre( 2 ) ];
            
            
            
            A_RAF = [ OMatrix, Offcenter_RAF' ];
            A_RAF = [ A_RAF;0, 0, 0, 1 ];
            
            
            
            ShiftMat = eye( 4 );
            ShiftMat( :, 4 ) = [  - ( MatrixSize( 1 ) / 2 + 0.5 ); - ( MatrixSize( 2 ) / 2 + 0.5 ); - ( MatrixSize( 3 ) / 2 + 0.5 );1 ];
            
            
            
            
            
            
            
            PermAxis1 = eye( 4 );
            PermAxis1( 1, 1 ) = 0;
            PermAxis1( 2, 1 ) =  - 1;
            PermAxis1( 1, 2 ) = 1;
            PermAxis1( 2, 2 ) = 0;
            
            
            
            
            switch SliceOrientation
                case 1
                    PermAxis2 = zeros( 4 );
                    PermAxis2( 1, 1 ) = 1;
                    PermAxis2( 2, 2 ) =  - 1;
                    PermAxis2( 3, 3 ) = 1;
                    PermAxis2( 4, 4 ) = 1;
                    
                    in_plane_res = max( FOV( [ 1, 3 ] ) ) ./ max( MatrixSize( 1:2 ) );
                    
                    
                    SliceThickness = ( FOV( 2 ) - ( MatrixSize( 3 ) - 1 ) * SliceGap ) ./ MatrixSize( 3 );
                    z_res = SliceThickness + SliceGap;
                    
                    ResolutionRAF = [ in_plane_res, in_plane_res, z_res ];
                case 2
                    PermAxis2 = zeros( 4 );
                    PermAxis2( 1, 3 ) =  - 1;
                    PermAxis2( 2, 1 ) = 1;
                    PermAxis2( 3, 2 ) = 1;
                    PermAxis2( 4, 4 ) = 1;
                    
                    in_plane_res = max( FOV( [ 1, 2 ] ) ) ./ max( MatrixSize( 1:2 ) );
                    
                    
                    SliceThickness = ( FOV( 3 ) - ( MatrixSize( 3 ) - 1 ) * SliceGap ) ./ MatrixSize( 3 );
                    z_res = SliceThickness + SliceGap;
                    
                    ResolutionRAF = [ z_res, in_plane_res, in_plane_res ];
                    
                case 3
                    PermAxis2 = zeros( 4 );
                    PermAxis2( 1, 1 ) = 1;
                    PermAxis2( 2, 3 ) = 1;
                    PermAxis2( 3, 2 ) = 1;
                    PermAxis2( 4, 4 ) = 1;
                    
                    in_plane_res = max( FOV( [ 2, 3 ] ) ) ./ max( MatrixSize( 1:2 ) );
                    
                    
                    SliceThickness = ( FOV( 1 ) - ( MatrixSize( 3 ) - 1 ) * SliceGap ) ./ MatrixSize( 3 );
                    z_res = SliceThickness + SliceGap;
                    
                    ResolutionRAF = [ in_plane_res, z_res, in_plane_res ];
                    
            end
            
            Pix2MM = eye( 4 );
            Pix2MM( 1, 1 ) = ResolutionRAF( 1 );
            Pix2MM( 2, 2 ) = ResolutionRAF( 2 );
            Pix2MM( 3, 3 ) = ResolutionRAF( 3 );
            
            A_MPS2RAF = A_RAF * Pix2MM * PermAxis2;
            A_RAF = A_RAF * Pix2MM * PermAxis2 * PermAxis1 * ShiftMat;
            
            RAF = A_RAF * ijk;
            RAF = RAF( 1:3, : )';
        end
        function scaling_pars = get_scaling_pars( d, types )
            
            
            max_data_abs = 1;
            min_data_abs = 1;
            max_data_real = 1;
            min_data_real = 1;
            max_data_imag = 1;
            min_data_imag = 1;
            max_data_phase = 1;
            min_data_phase = 1;
            
            for i = 1:length( types )
                switch types{ i }
                    case 'M'
                        d1 = abs( d( : ) );
                        max_data_abs = max( d1 );
                        min_data_abs = min( d1 );
                    case 'R'
                        d1 = real( d( : ) );
                        max_data_real = max( d1 );
                        min_data_real = min( d1 );
                    case 'I'
                        d1 = imag( d( : ) );
                        max_data_imag = max( d1 );
                        min_data_imag = min( d1 );
                    case 'P'
                        d1 = floor( 1000 .* angle( d( : ) ) );
                        max_data_phase = 3142;
                        min_data_phase =  - 3142;
                end
            end
            
            range_data_abs = max_data_abs - min_data_abs;
            range_data_real = max_data_real - min_data_real;
            range_data_imag = max_data_imag - min_data_imag;
            range_data_phase = max_data_phase - min_data_phase;
            
            scaling_pars.ri.M = min_data_abs;
            scaling_pars.ri.R = min_data_real;
            scaling_pars.ri.I = min_data_imag;
            scaling_pars.ri.P = min_data_phase;
            
            scaling_pars.rs.M = ( max_data_abs - min_data_abs ) ./ 4095;
            scaling_pars.rs.R = ( max_data_real - min_data_real ) ./ 4095;
            scaling_pars.rs.I = ( max_data_imag - min_data_imag ) ./ 4095;
            scaling_pars.rs.P = ( max_data_phase - min_data_phase ) ./ 4095;
            
            scaling_pars.ss.M = 4095 ./ max_data_abs;
            scaling_pars.ss.R = 4095 ./ max_data_real;
            scaling_pars.ss.I = 4095 ./ max_data_imag;
            scaling_pars.ss.P = 4095 ./ max_data_phase;
            
            scaling_pars.wc.M = round( min_data_abs + range_data_abs / 2 );
            scaling_pars.wc.R = round( min_data_real + range_data_real / 2 );
            scaling_pars.wc.I = round( min_data_imag + range_data_imag / 2 );
            scaling_pars.wc.P = round( min_data_phase + range_data_phase / 2 );
            
            scaling_pars.ww.M = round( 0.95 * range_data_abs );
            scaling_pars.ww.R = round( 0.95 * range_data_real );
            scaling_pars.ww.I = round( 0.95 * range_data_imag );
            scaling_pars.ww.P = round( 0.95 * range_data_phase );
        end
        function new_range = set_new_range( range, n )
            
            
            new_range = range;
            if ~isempty( range )
                a = range( 1 );
                b = range( 2 );
                as = floor( ( ( n + 1 ) * a - ( n - 1 ) * b - n + 1 ) / 2 );
                bs = ceil( a + b - as );
                new_range = [ as, bs ];
            end
        end
        function labfile_nr = find_labfile( file1, file2 )
            fid = fopen( file1, 'r' );
            fread( fid, 2, 'uint8' );
            header1 = fread( fid, 510, 'uint8' );
            header1 = sum( abs( header1 ) );
            fclose( fid );
            
            fid = fopen( file2, 'r' );
            fread( fid, 2, 'uint8' );
            header2 = fread( fid, 510, 'uint8' );
            header2 = sum( abs( header2 ) );
            fclose( fid );
            
            if header1 > header2
                labfile_nr = 1;
            else
                labfile_nr = 2;
            end
        end
    end
    
    methods ( Hidden, Sealed, Static, Access = private )
        
        function [ LicenseFile, MachineID, LicenseInfo, test_output ] = CheckLicense(  )
            test_output = 0.1457896324;
            CheckAgain = 0;
            
            [ LicenseFile, LicensePath, status ] = MRparameter.GetLicenseFile;
            MachineID = MRparameter.get_machineID;
            Version = 30;
            if status ~=  - 5
                [ status, LicenseInfo ] = MRparameter.checkID( MachineID, LicenseFile, Version );
            else
                LicenseInfo.LicenseFile = [  ];
                LicenseInfo.Status = status;
                LicenseInfo.ThisMachineID = MachineID;
            end
            version_file = which( 'Version.txt' );
            loopv = 1;
            fidv = fopen( version_file );
            if fidv ==  - 1
                LicenseInfo( 1 ).ThisVersion = '3.0';
            else
                while ~feof( fidv )
                    s{ loopv } = fgetl( fidv );
                    loopv = loopv + 1;
                end
                fclose( fidv );
                s1 = strrep( s{ 1 }, 'MRecon: Version ', '' );
                LicenseInfo( 1 ).ThisVersion = s1;
            end
            
            if status < 0
                switch status
                    case  - 1
                        s = sprintf( 'License Error1: License invalid - contact GyroTools  \n\nYour MachineID is: %s\nLicense File: %s', MachineID, LicenseFile );
                        CheckAgain = MRparameter.ShowLicenseDialog( LicenseInfo );
                        if CheckAgain
                            MRparameter.CheckLicense(  );
                        else
                            
                            
                            error( s );
                        end
                    case  - 2
                        s = sprintf( 'License Error2: License expired - contact GyroTools  \n\nYour MachineID is: %s\nLicense File: %s', MachineID, LicenseFile );
                        CheckAgain = MRparameter.ShowLicenseDialog( LicenseInfo );
                        if CheckAgain
                            MRparameter.CheckLicense(  );
                        else
                            
                            
                            error( s );
                        end
                    case  - 3
                        s = sprintf( 'License Error3: The license belongs to a previous version of ReconFrame - contact GyroTools  \n\nYour MachineID is: %s\nLicense File: %s', MachineID, LicenseFile );
                        CheckAgain = MRparameter.ShowLicenseDialog( LicenseInfo );
                        if CheckAgain
                            MRparameter.CheckLicense(  );
                        else
                            
                            
                            error( s );
                        end
                    case  - 4
                        s = sprintf( 'License Error4: The license belongs to a different product of GyroTools - contact GyroTools  \n\nYour MachineID is: %s\nLicense File: %s', MachineID, LicenseFile );
                        CheckAgain = MRparameter.ShowLicenseDialog( LicenseInfo );
                        if CheckAgain
                            MRparameter.CheckLicense(  );
                        else
                            
                            
                            error( s );
                        end
                    case  - 5
                        s = sprintf( 'License Error5: License file not found - contact GyroTools  \n\nYour MachineID is: %s', MachineID );
                        CheckAgain = MRparameter.ShowLicenseDialog( LicenseInfo );
                        if CheckAgain
                            MRparameter.CheckLicense(  );
                        else
                            
                            
                            error( s' );
                        end
                    otherwise
                        s = sprintf( 'License Error6: License could not be checked - contact GyroTools  \n\nYour MachineID is: %s\nLicense File: %s', MachineID, LicenseFile );
                        CheckAgain = MRparameter.ShowLicenseDialog( LicenseInfo );
                        if CheckAgain
                            MRparameter.CheckLicense(  );
                        else
                            
                            
                            error( s );
                            
                        end
                end
            end
        end
        function [ file, path, status ] = GetLicenseFile
            status =  - 1;
            base_path = which( 'MRecon.m' );
            if ~isempty( base_path )
                base_path = strrep( base_path, 'MRecon.m', '' );
                path = [ base_path, 'license', base_path( end  ) ];
            else
                base_path = which( 'MRecon.p' );
                if ~isempty( base_path )
                    base_path = strrep( base_path, 'MRecon.p', '' );
                    path = [ base_path, 'license', base_path( end  ) ];
                else
                    path = '';
                end
            end
            file = [ path, 'license.lic' ];
            if fopen( file ) < 0
                path = '';
                file = [ path, 'license.lic' ];
                if fopen( file ) < 0
                    file = which( 'license.lic' );
                    if fopen( file ) < 0
                        file = 'G:\patch\pride\license.lic';
                        if fopen( file ) < 0
                            file = 'G:\patch\pride\ScannerRecon\license.lic';
                            if fopen( file ) < 0
                                file = 'G:\patch\pride\reconframe\license.lic';
                                if fopen( file ) < 0
                                    file = 'G:\Site\AvailablePatches\license\license.lic';
                                    if fopen( file ) < 0
                                        file = 'G:\patch\license.lic';
                                        if fopen( file ) < 0
                                            file = 'G:\patch\gtLicense.txt';
                                            if fopen( file ) < 0
                                                fclose( 'all' );
                                                status =  - 5;
                                                MachineID = MRparameter.get_machineID;
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        function [ status, LicenseInfo, MachineID ] = checkID( MachineID, license_file, version )
            status =  - 1;
            
            fid = fopen( license_file, 'r' );
            if fid ==  - 1
                status =  - 5;
                LicenseInfo.LicenseFile = [  ];
                LicenseInfo.Status = status;
                return
            end
            LicenseInfo.LicenseFile = license_file;
            LicenseInfo.ThisMachineID = MachineID;
            last_line = '';
            loop = 1;
            
            Product = sum( char( 'ReconFrame' ) + 1 - 1 );
            MachineID = strrep( MachineID, '-', '' );
            while ~feof( fid )
                line = fgetl( fid );
                skip = ~( ~isempty( line ) && line( 1 ) ~= ';' );
                if ~skip
                    name = regexpi( last_line, ';[\w\s\W]*:', 'match' );
                    if ~isempty( name )
                        name = name{ 1 };
                        name = name( 2:end  - 1 );
                        name = strtrim( name );
                    else
                        name = '';
                    end
                    
                    [ Test_MachineID, Test_Version, Test_Date, Test_FeatureName ] = MRparameter.decrypt( line );
                    if ~isempty( Test_MachineID )
                        if strcmpi( Test_MachineID( 1 ), 'X' )
                            Test_MachineID( 1 ) = 'L';
                        end
                        if strcmpi( Test_MachineID( 1 ), 'N' )
                            machine_valid = 1;
                        else
                            machine_valid = strcmpi( Test_MachineID, MachineID );
                        end
                        date_valid = Test_Date > datenum( date );
                        version_valid = Test_Version == version;
                        product_valid = Test_FeatureName == Product;
                        
                        license_valid = machine_valid & date_valid & version_valid & product_valid;
                        if license_valid
                            status = 1;
                            
                        end
                        if status ~= 1
                            if machine_valid & ~date_valid
                                status =  - 2;
                            elseif machine_valid & ~version_valid
                                status =  - 3;
                            elseif machine_valid & ~product_valid
                                status =  - 4;
                            else
                                status = min( [ status,  - 1 ] );
                            end
                        end
                        
                        LicenseInfo( loop ).FeatureName = 'ReconFrame';
                        LicenseInfo( loop ).LicenseKey = strtrim( line );
                        LicenseInfo( loop ).Name = name;
                        LicenseInfo( loop ).MachineID = Test_MachineID;
                        LicenseInfo( loop ).Date = Test_Date;
                        LicenseInfo( loop ).FeatureName = Test_FeatureName;
                        LicenseInfo( loop ).Version = Test_Version;
                        
                        if license_valid
                            LicenseInfo( loop ).Status = 1;
                        elseif machine_valid & ~date_valid
                            LicenseInfo( loop ).Status =  - 2;
                        elseif machine_valid & ~version_valid
                            LicenseInfo( loop ).Status =  - 3;
                        elseif machine_valid & ~product_valid
                            LicenseInfo( loop ).Status =  - 4;
                        else
                            LicenseInfo( loop ).Status =  - 1;
                        end
                        
                    else
                        if status ~= 1
                            status = min( [ status,  - 1 ] );
                        end
                        
                        LicenseInfo( loop ).FeatureName = 'ReconFrame';
                        LicenseInfo( loop ).LicenseKey = strtrim( line );
                        LicenseInfo( loop ).Name = name;
                        LicenseInfo( loop ).MachineID = Test_MachineID;
                        LicenseInfo( loop ).Date = Test_Date;
                        LicenseInfo( loop ).FeatureName = Test_FeatureName;
                        LicenseInfo( loop ).Version = Test_Version;
                        LicenseInfo( loop ).Status = status;
                    end
                    loop = loop + 1;
                else
                    last_line = line;
                end
            end
            fclose( fid );
        end
        function mac = getmac
            if ispc
                [ fail, mac_str ] = system( 'getmac' );
                if fail || ~ischar( mac_str )
                    
                    
                    error( 'Could not determine mac-address' );
                    
                end
                pat = '\w{2}-\w{2}-\w{2}-\w{2}-\w{2}-\w{2}';
                macs = regexpi( mac_str, pat, 'match' );
                if ~isempty( macs )
                    if iscell( macs )
                        
                        
                        mac = macs{ 1 };
                        mac = strrep( mac, ' ', '' );
                        mac = deblank( mac );
                    else
                        mac = macs;
                        mac = strrep( mac, ' ', '' );
                        mac = deblank( mac );
                    end
                else
                    error( 'Could not determine mac-address' );
                end
            elseif ismac
                [ fail, mac_str ] = system( 'netstat -I en0' );
                if fail || ~ischar( mac_str )
                    error( 'Could not determine mac-address' );
                end
                pat = '\w{2}:\w{2}:\w{2}:\w{2}:\w{2}:\w{2}';
                macs = regexpi( mac_str, pat, 'match' );
                if ~isempty( macs )
                    if iscell( macs )
                        
                        
                        mac = macs{ 1 };
                    else
                        mac = macs;
                    end
                else
                    error( 'Could not determine mac-address' );
                end
            elseif isunix
                [ fail, mac_str ] = system( '/sbin/ifconfig' );
                if fail || ~ischar( mac_str )
                    error( 'Could not determine mac-address' );
                end
                pat = '\w{2}:\w{2}:\w{2}:\w{2}:\w{2}:\w{2}';
                macs = regexpi( mac_str, pat, 'match' );
                if ~isempty( macs )
                    if iscell( macs )
                        [ temp, ind_min ] = min( cellfun( @( x )length( x ), strfind( macs, '00' ) ) );
                        mac = macs{ ind_min };
                    else
                        mac = macs;
                    end
                else
                    error( 'Could not determine mac-address' );
                end
                
            else
                error( 'Unknown operating system' );
            end
            
        end
        function DiskID = getDiskID(  )
            
            if ispc
                DiskID = volnr;
                if DiskID ==  - 1
                    DiskID = 'F0F0F0F9';
                else
                    DiskID = dec2hex( DiskID );
                end
            else
                DiskID = 'F0F0F0F9';
            end
        end
        function [ MachineID, Version, Date, FeatureName ] = decrypt( encoded_id )
            charset = 'ABCDEFGHIJKMNPQRSTUVWXYZ23456789';
            nr_chars = length( charset );
            
            seeds1 = 10000 .* [ 0.527439092065878, 0.668820351208011, 0.863642753038389, 0.243750316204387, 0.711564447130805, 0.263662927441142, 0.382821503273594, 0.0810055192937169, 0.459762769499683, 0.232866981175201, 0.795352611595463, 0.491343084951557, 0.00322878081501870, 0.266119158019367, 0.664688831504755, 0.425191100419122, 0.186824744188611, 0.963475577981898, 0.134039141765814, 0.795855658033796, 0.946044574000894, 0.171155233015844, 0.606001297294163, 0.0638036229944805, 0.347491668233411, 0.292467998942578, 0.509658227911991, 0.825836516835651, 0.834338456780807, 0.726443115028759, 0.329434288353396, 0.802084355522918, 0.631763273678610, 0.0453407163942888, 0.0414204388118444, 0.153315110669152, 0.767065016444337, 0.0617313799735771, 0.519303215909425, 0.929149789702683, 0.220515532987432, 0.204562919775286, 0.0889926632349345, 0.699690989544471, 0.706461273928388, 0.494630914411801, 0.261778519145110, 0.711571271862635, 0.378366195307284, 0.200644529518040, 0.232607609700695, 0.436096239572436, 0.469498493927297, 0.861187436087610, 0.977238324460219, 0.444519202897567, 0.0342430994074061, 0.523771740274398, 0.0316387917993771, 0.753173772130708, 0.591588200811105, 0.822891032240768, 0.329578870595237, 0.232078094143457, 0.536528269078829, 0.430618407870931, 0.403581086734115, 0.987324740266113, 0.966909652560442, 0.850530583341853, 0.867514226523933, 0.311605187743718, 0.148390408674437, 0.997598591259494, 0.639523298311757, 0.468074725693127, 0.931914724377876, 0.690772618954430, 0.815406767099820, 0.541534646666392, 0.572806522051248, 0.159216115325324, 0.945250272725360, 0.821333695119868, 0.155413879619638, 0.0410747672622440, 0.343613376535295, 0.110019428706737, 0.0965382741282407, 0.518773273340787, 0.0224050385981822, 0.561483719647622, 0.856876117576322, 0.516908105237832, 0.674524732248171, 0.737174895003985, 0.698460331977559, 0.0227995468409730, 0.191983756232999, 0.670991008016742, 0.345871737387903, 0.0662902784842487, 0.140710484767664, 0.921117490120753, 0.221656459486883, 0.380114596048423, 0.586015785851523, 0.167312806550093, 0.0263396874192821, 0.691126455874707, 0.762343886197705, 0.713695324824050, 0.0773243178042231, 0.589809335577213, 0.925503046217143, 0.929697771523938, 0.430446002832822, 0.505969611232155, 0.831255978826087, 0.919236130043509, 0.601637641248125, 0.723836457228212, 0.519336634557385, 0.490817005974621, 0.161419415455973, 0.976115568529868, 0.574360281496477, 0.273251111280756, 0.531427295660333, 0.698558163223117, 0.667049290922959, 0.0974325421719963, 0.548736284742475, 0.610737666772091, 0.667965438527970, 0.495125339597056, 0.571582607725441, 0.588888041483652, 0.441313215736911, 0.151216890267663, 0.502274728614034, 0.731363816061692, 0.0316565488612543, 0.0516167111003849, 0.522063464169420, 0.320642295442821, 0.0350595074869038, 0.245142332392345, 0.107180518148085, 0.382968514870372, 0.551829426340679, 0.597168507798188, 0.611110564140189, 0.935251504152665, 0.772030293835341, 0.513148490578471, 0.486681152361762, 0.650127744139232, 0.696995748065876, 0.407537743173324, 0.486849514062912, 0.479782855361599, 0.710450062393421, 0.534198646216746, 0.276646964846480, 0.605538174791978, 0.280103728771258, 0.703369458533530, 0.530489573036549, 0.938254025270349, 0.235402718761658, 0.413494227180953, 0.597476230281161, 0.783002335477156, 0.920252364557354, 0.681491115447828, 0.821177331647453, 0.527412998735631, 0.230269749756097, 0.143684150718005, 0.899521117517502, 0.251422116649999, 0.651514536538867, 0.00481560873091948, 0.935935940563649, 0.275353053247255, 0.858765926611966, 0.278928567319609, 0.952430940676681, 0.506819952980997, 0.122949751616898, 0.416475425202621, 0.702471380449120, 0.436491208354240, 0.107738809710247, 0.766174800119444, 0.0998656074981511, 0.441265221424990, 0.344576489806444, 0.297064176898945, 0.757621140572066, 0.338509594713575, 0.330758351055327, 0.0556061868814780, 0.573182917001277, 0.485286040457564, 0.202481970285290, 0.114474584867467, 0.974347867525345, 0.864609498467580, 0.491840744620115, 0.367394830271320, 0.804912370073103, 0.162203818635179, 0.159579801447494, 0.0577229280293560, 0.149251389386715, 0.468101422520402, 0.380608300390005, 0.883704654818263, 0.424133530549767, 0.412247949937474, 0.651294599124833, 0.308327491073090, 0.0601424654294469, 0.814416472713657, 0.897656898432252, 0.919491950850697, 0.901217947668032, 0.770046456609874, 0.170796242156437, 0.572441923232955, 0.0314037762728537, 0.803267817852678, 0.522214649953979, 0.861621776531274, 0.277198161127604, 0.869494071635182, 0.586861972504697, 0.389171886439050, 0.811895381106015, 0.525670248794216, 0.939871484385744, 0.420038071190956, 0.579862506398867, 0.749145045759690, 0.880784083102264, 0.338084699743467, 0.189548588446131, 0.743126014127920, 0.718919447957966, 0.879161829538253, 0.0728690494191223, 0.710113587188587, 0.879059878587285, 0.359379416498998 ];
            seeds2 = 10000 .* [ 0.745522213049942, 0.991834730371756, 0.766313358101208, 0.428609607009501, 0.641665008683533, 0.463800944138226, 0.102468131157788, 0.181880368935820, 0.863360704324842, 0.503357587616592, 0.930975072053715, 0.898036006790603, 0.291166129657610, 0.629141155457656, 0.975399776816089, 0.544048948001139, 0.830669055148339, 0.0548098781401338, 0.189621901227917, 0.975293937593370, 0.765209131764811, 0.869877571179475, 0.0323388134279935, 0.518437284286338, 0.375437000475562, 0.969666992765696, 0.193147413056878, 0.228571246950222, 0.596947492378274, 0.896504401646789, 0.549478477588612, 0.0847728317998223, 0.776984059613656, 0.771089926721104, 0.708398401601426, 0.0519357151593714, 0.883564683554491, 0.0716365003360605, 0.994661148169386, 0.269917282867207, 0.499773149145661, 0.687317691132109, 0.748434857348183, 0.944647450905595, 0.689707370330443, 0.911773143760754, 0.171227186997993, 0.815331875260608, 0.282827505042231, 0.481877244767676, 0.910852810326430, 0.703183156299956, 0.399307933356291, 0.168435919176990, 0.902493607673093, 0.210064161666699, 0.548365132207221, 0.372777006762464, 0.263152656733595, 0.806701721533528, 0.235833814011809, 0.658912096479401, 0.335605529293234, 0.522130831387886, 0.452883136203924, 0.606870179347168, 0.667104287849322, 0.0217658835564581, 0.819204933391514, 0.377315511171387, 0.541796257506030, 0.969699903842853, 0.746283886836043, 0.793286053367558, 0.758698948546638, 0.453228223348608, 0.406749820060446, 0.244225755913288, 0.702279634635094, 0.213819312031297, 0.661177310003516, 0.407049229092453, 0.276393356861730, 0.343148775092861, 0.301462985715579, 0.688400921732374, 0.954291556009227, 0.778181847081604, 0.902303900524184, 0.0216561099615209, 0.974240123282299, 0.0537520055909418, 0.409957966958153, 0.163550665678247, 0.796038054300490, 0.0115786283330892, 0.602006394230764, 0.921467836444018, 0.109927114616114, 0.545015353031929, 0.0730384076354273, 0.556517128626126, 0.383380819290588, 0.481429816913526, 0.390932865622888, 0.408672523875103, 0.559108768850150, 0.941078064470123, 0.699029549350510, 0.589635934023948, 0.0111431405000124, 0.282762383708154, 0.387382982944782, 0.745794352956952, 0.565690147488234, 0.554308834743830, 0.268585539547999, 0.117163183222135, 0.161620414425442, 0.354305248406858, 0.808309974059607, 0.265734019813004, 0.191670997157540, 0.414449226769828, 0.648154320497138, 0.529664595392376, 0.0728547596711920, 0.469945793724594, 0.378955129244810, 0.0988572175143553, 0.493254763769570, 0.132814675165720, 0.216245510250444, 0.438290779217282, 0.353126304854232, 0.993805685077703, 0.892149100961233, 0.349939855444217, 0.439150450955681, 0.801629212126895, 0.982168216715645, 0.301218339847968, 0.576637824800163, 0.551921416331046, 0.143244275889939, 0.506544882201843, 0.499835166381595, 0.729641375471671, 0.0825975523714896, 0.217062707625824, 0.172927067229956, 0.385218933869721, 0.374621548398687, 0.264363936737349, 0.164684744628465, 0.856502970613774, 0.245427105690086, 0.893365333272780, 0.791156315613145, 0.964196510130631, 0.250745765515950, 0.284081026578360, 0.549813702492888, 0.718897797967725, 0.515290443559778, 0.486484909191022, 0.351868773508756, 0.858476361659577, 0.412210412515425, 0.0204031467532754, 0.915687482299138, 0.959515001605970, 0.568631991543170, 0.997881866059211, 0.400522857159620, 0.587660281726932, 0.806354984550902, 0.408225347012386, 0.0434072371774387, 0.545435241211874, 0.130099047967279, 0.574699186056247, 0.969220047336640, 0.681335586906101, 0.207209130845596, 0.563862121926556, 0.830683219633383, 0.292872378273342, 0.306061640058673, 0.977984466114074, 0.984921979245228, 0.583705174542826, 0.332868541280212, 0.521573296525317, 0.0823947010014181, 0.807739730834840, 0.681656141151514, 0.594764333495295, 0.204153055420217, 0.200402447581479, 0.163936501910880, 0.280787616167584, 0.197464928588581, 0.793054788277044, 0.871826572284022, 0.789200377552398, 0.0907455231485635, 0.160007557906214, 0.247025729737722, 0.761439701896831, 0.517069780042893, 0.391793180905186, 0.867991473464291, 0.332694514343838, 0.596702576892778, 0.780209836913370, 0.986729003017176, 0.954353709683918, 0.822798657614178, 0.777038521495200, 0.686430769826486, 0.841948473752452, 0.627998357465490, 0.768393922489320, 0.396655277999423, 0.585257336304177, 0.420051264306554, 0.801599200256914, 0.477758717945665, 0.690772512783656, 0.813622354908670, 0.550918950024489, 0.294793061583672, 0.586986036778887, 0.474320142750777, 0.898639212315268, 0.429241382716802, 0.259919321285523, 0.464032845787719, 3.91541980389292e-05, 0.658064606440284, 0.0918404418471458, 0.562306124978841, 0.679042519386412, 0.667623327424574, 0.745264024820767, 0.652465162636929, 0.981988438862371, 0.279691959861523, 0.782769392609023, 0.00518157985302693, 0.0868125898236467, 0.0591971660308527, 0.926769480540776, 0.214659448813023, 0.781356200474015 ];
            
            encoded_id = encoded_id( find( isspace( encoded_id ) ) + 3:end  );
            
            MachineID = [  ];
            Version = [  ];
            Date = [  ];
            FeatureName = [  ];
            
            if length( encoded_id ) == 31
                encoded_bin = MRparameter.bit322bin( encoded_id );
                encoded_bin = encoded_bin( 5:end  );
                seed_ind1 = bin2dec( encoded_bin( 1:8 ) ) + 1;
                seed_ind2 = bin2dec( encoded_bin( 9:16 ) ) + 1;
                
                encoded_bin = encoded_bin( 17:end  );
                
                string_length = length( encoded_bin ) / 5;
                
                rand( 'seed', seeds1( seed_ind1 ) + seeds2( seed_ind2 ) );
                shifts = round( 1 + ( nr_chars - 1 ) .* rand( 1, string_length ) );
                perm = randperm( length( encoded_bin ) );
                
                [ temp, perm ] = ismember( 1:length( perm ), perm );
                encoded_bin = encoded_bin( perm );
                encoded_bit32 = reshape( MRparameter.bin2bit32( encoded_bin ), 1, [  ] );
                
                number2decode = MRparameter.char2dec( encoded_bit32, charset );
                decoded_nr = MRparameter.decode_nr( number2decode, shifts, nr_chars );
                bit32_decoded = MRparameter.dec2char( decoded_nr, charset );
                
                bin_decoded = MRparameter.bit322bin( bit32_decoded );
                
                bin_MachineID = bin_decoded( 1:85 );
                bin_version = bin_decoded( 86:93 );
                bin_date = bin_decoded( 94:117 );
                bin_FeatureName = bin_decoded( 118:133 );
                
                MachineID = reshape( MRparameter.bin2bit32( bin_MachineID ), 1, [  ] );
                Version = bin2dec( bin_version );
                Date = bin2dec( bin_date );
                FeatureName = bin2dec( bin_FeatureName );
            end
        end
        function dec = char2dec( string, charset )
            string = upper( string );
            dec = zeros( 1, length( string ) );
            for i = 1:length( string )
                dec( i ) = strfind( charset, string( i ) );
            end
        end
        function string = dec2char( dec, charset )
            for i = 1:length( dec )
                string( i ) = charset( dec( i ) );
            end
        end
        function bit32 = dec2bit32( dec )
            
            bit32_alphabet = 'ABCDEFGHIJKMNPQRSTUVWXYZ23456789';
            base32_alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUV';
            
            base32 = dec2base( dec, 32 );
            
            for i = 1:size( base32, 1 )
                for j = 1:size( base32, 2 )
                    ind = strfind( base32_alphabet, base32( i, j ) );
                    bit32( i, j ) = bit32_alphabet( ind );
                end
            end
        end
        function dec = bit322dec( bit32 )
            
            bit32_alphabet = 'ABCDEFGHIJKMNPQRSTUVWXYZ23456789';
            base32_alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUV';
            
            for i = 1:size( bit32, 1 )
                for j = 1:size( bit32, 2 )
                    strrep( bit32( i, j ), 'L', 'X' );
                    ind = strfind( bit32_alphabet, bit32( i, j ) );
                    base32( i, j ) = base32_alphabet( ind );
                end
            end
            
            dec = base2dec( base32, 32 );
        end
        function bit32 = bin2bit32( bin )
            bin = reshape( bin', 5, [  ] )';
            bit32 = MRparameter.dec2bit32( bin2dec( bin ) );
        end
        function bin = bit322bin( bit32 )
            dec = MRparameter.bit322dec( bit32' );
            bin = dec2bin( dec );
            bin = reshape( bin', 1, [  ] );
        end
        function dec_nr = decode_nr( encoded_numbers, shifts, nr_chars )
            dec_nr = zeros( size( encoded_numbers ) );
            for i = 1:length( encoded_numbers )
                shifted_charset = circshift( 1:nr_chars, [ 0,  - shifts( i ) ] );
                dec_nr( i ) = shifted_charset( encoded_numbers( i ) );
            end
        end
        
        
        function doCancel( cancel_btn, evd, listbox )
            MRparameter.OnCloseRequest( gcbf, [  ], [  ] );
        end
        function OnEditMachineID( hObject, evd, listbox )
            machine_id = get( hObject, 'UserData' );
            set( hObject, 'String', machine_id );
        end
        function OnBrowseRadio( hObject, evd, listbox )
            handles = get( hObject, 'UserData' );
            set( handles( 1 ), 'Value', 0 );
            set( handles( 2 ), 'Enable', 'on' );
            set( handles( 3 ), 'Enable', 'off' );
        end
        function OnMachineIDRadio( hObject, evd, listbox )
            handles = get( hObject, 'UserData' );
            set( handles( 1 ), 'Value', 0 );
            set( handles( 2 ), 'Enable', 'off' );
            set( handles( 3 ), 'Enable', 'on' );
        end
        function OnStoreLicense( hObject, evd, listbox )
            set( gcbf, 'UserData', 1 );
            StoreInfo = get( hObject, 'UserData' );
            
            if strcmpi( StoreInfo.System, 'Scanner' )
                if ~exist( 'G:\Site\AvailablePatches', 'dir' )
                    mkdir( 'G:\Site\', 'AvailablePatches' );
                end
                if ~exist( 'G:\Site\AvailablePatches\license', 'dir' )
                    mkdir( 'G:\Site\AvailablePatches', 'license' );
                end
            end
            switch StoreInfo.Action
                case 'new'
                    key = get( StoreInfo.LicenseKeyEditHandle, 'String' );
                    
                    fid = fopen( StoreInfo.Path, 'w' );
                    fprintf( fid, ';=====================================================\r\n' );
                    fprintf( fid, ';\r\n' );
                    fprintf( fid, '; 	GyroTools License\r\n' );
                    fprintf( fid, ';	Generated by license dialog\r\n' );
                    fprintf( fid, ';\r\n' );
                    fprintf( fid, ';===================================================== \r\n' );
                    fprintf( fid, '\r\n' );
                    fprintf( fid, ';----------------------------------------------------- \r\n' );
                    fprintf( fid, [ '; License Dialog: ', StoreInfo.MachineID, ' \r\n' ] );
                    fprintf( fid, [ key, '\r\n' ] );
                    fclose( fid );
                case 'append'
                    key = get( StoreInfo.LicenseKeyEditHandle, 'String' );
                    fid = fopen( StoreInfo.Path, 'a' );
                    fprintf( fid, '\r\n' );
                    fprintf( fid, ';----------------------------------------------------- \r\n' );
                    fprintf( fid, [ '; License Dialog: ', StoreInfo.MachineID, ' \r\n' ] );
                    fprintf( fid, [ key, '\r\n' ] );
                    fclose( fid );
                case 'copy'
                    copyfile( StoreInfo.SourceFile, StoreInfo.Path );
            end
            MRparameter.OnCloseRequest( gcbf, [  ], [  ] );
        end
        function OnBrowse( hObject, evd, listbox )
            directory = cd;
            [ filename, pathname, filterindex ] = uigetfile(  ...
                { 'license.lic; gtLicense.txt', 'License files ' },  ...
                'Pick a license file', directory );
            if filename ~= 0
                h = get( hObject, 'UserData' );
                StoreInfo = get( h, 'UserData' );
                StoreInfo.Action = 'copy';
                StoreInfo.SourceFile = [ pathname, filename ];
                set( h, 'UserData', StoreInfo );
                MRparameter.OnStoreLicense( h, [  ], [  ] );
            end
        end
        function OnCloseRequest( hObject, evd, listbox )
            if isequal( get( hObject, 'waitstatus' ), 'waiting' )
                
                uiresume( hObject );
            else
                
                delete( hObject );
            end
        end
        function figure_size = getnicedialoglocation( figure_size, figure_units )
            
            
            
            
            
            
            
            
            
            
            
            
            
            parentHandle = gcbf;
            propName = 'Position';
            if isempty( parentHandle )
                parentHandle = 0;
                propName = 'ScreenSize';
            end
            
            old_u = get( parentHandle, 'Units' );
            set( parentHandle, 'Units', figure_units );
            container_size = get( parentHandle, propName );
            set( parentHandle, 'Units', old_u );
            
            figure_size( 1 ) = container_size( 1 ) + 1 / 2 * ( container_size( 3 ) - figure_size( 3 ) );
            figure_size( 2 ) = container_size( 2 ) + 2 / 3 * ( container_size( 4 ) - figure_size( 4 ) );
        end
        
        
        function sub = ind2sub( siz, ndx )
            siz = double( siz );
            n = length( siz );
            k = [ 1, cumprod( siz( 1:end  - 1 ) ) ];
            for i = n: - 1:1,
                vi = rem( ndx - 1, k( i ) ) + 1;
                vj = ( ndx - vi ) / k( i ) + 1;
                sub( i ) = vj;
                ndx = vi;
            end
        end
    end
end

