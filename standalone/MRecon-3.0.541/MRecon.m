classdef MRecon < handle
    
    
    
    
    
    
    properties
        
        
        
        Parameter;
        
        
        
        Data;
    end
    properties ( Hidden )
        LabelLookupTable;
        MeanNoise;
        DataClass;
        PFLowRes;
    end
    
    
    
    properties ( Hidden, Constant )
        dim = struct( 'kx', 1,  ...
            'ky', 2,  ...
            'kz', 3,  ...
            'coil', 4,  ...
            'dyn', 5,  ...
            'hp', 6,  ...
            'echo', 7,  ...
            'loc', 8,  ...
            'mix', 9,  ...
            'extr1', 10,  ...
            'extr2', 11,  ...
            'meas', 12 );
    end
    
    
    methods
        
        
        
        function MR = MRecon( Filename, Datafile, varargin )
            MRecon.add_path;
            
            uigetfile_title = [  ];
            try
                for i = 1:length( varargin )
                    if any( strcmpi( varargin{ i }, { 'FileDialog', 'File_Dialog', 'uigetfile' } ) )
                        if length( varargin ) > i && ~isempty( varargin{ i + 1 } ) && ischar( varargin{ i + 1 } )
                            uigetfile_title = varargin{ i + 1 };
                        end
                    end
                end
            end
            
            if nargin == 0 || isempty( Filename )
                Filename = MRecon.DisplayFileList( '', uigetfile_title );
                if isempty( Filename )
                    return ;
                end
                Datafile = '';
            end
%             if strcmpi( Filename, 'version' )
%                 MR.DisplayVersion;
%             elseif strcmpi( Filename, 'MachineID' )
%                 MachineID = MRparameter.get_machineID;
%                 MachineID = 'L-ZDFD-XCYY-Y92R-B6H3';
%                 disp( MachineID );
%             elseif strcmpi( Filename, 'License' )
%                 MRparameter.ShowLicenseDialog(  );
%             elseif strcmpi( Filename, 'Empty' )
%                 MR.Parameter = MRparameter( 'Empty' );
%                 MR.DataClass = MRdata;
%             elseif strcmpi( Filename, 'Help' )
%                 doc MReconDoc;
%             elseif strcmpi( Filename, 'Agora' )
%                 dataset_id = Datafile;
%                 if ~isnumeric( dataset_id )
%                     error( 'The second input argument must be a dataset id' );
%                 end
%                 A = MRAgora;
%                 Datafiles = A.DownloadFiles( dataset_id, 'Dataset' );
%                 if ( any( [ Datafiles.type ] == 100 ) && any( [ Datafiles.type ] == 101 ) )
%                     Datafile = MRAgora.get_filename( Datafiles( find( [ Datafiles.type ] == 100 ) ).rel_filename );
%                     Filename = MRAgora.get_filename( Datafiles( find( [ Datafiles.type ] == 101 ) ).rel_filename );
%                 elseif ( any( [ Datafiles.type ] == 102 ) && any( [ Datafiles.type ] == 103 ) )
%                     Datafile = MRAgora.get_filename( Datafiles( find( [ Datafiles.type ] == 102 ) ).rel_filename );
%                     Filename = MRAgora.get_filename( Datafiles( find( [ Datafiles.type ] == 103 ) ).rel_filename );
%                 else
%                     error( 'Datatype not supported' );
%                 end

                if nargin == 1
                    if isdir( Filename )
                        Filename = MRecon.DisplayFileList( Filename );
                        if isempty( Filename )
                            return ;
                        end
                    end
                    Datafile = '';
                end
                
                MR.Parameter = MRparameter( Filename, Datafile );
                
                
                MR.DataClass = MR.Parameter.DataClass;
            end
        
        
        
        
        function Perform( MR )
            switch MR.Parameter.DataFormat
                case { 'ExportedRaw', 'Raw', 'Bruker' }
                    
                    
                    MR.Parameter.Parameter2Read.typ = 1;
                    MR.Parameter.Parameter2Read.Update;
                    
                    
                    
                    
                    if strcmpi( MR.Parameter.Recon.AutoChunkHandling, 'yes' )
                        [ MemoryNeeded, MemoryAvailable, MaxDataSize ] = MR.GetMemoryInformation;
                        if MemoryNeeded > MemoryAvailable
                            if strcmpi( MR.Parameter.Recon.ImmediateAveraging, 'yes' ) || strcmpi( MR.Parameter.Recon.Average, 'yes' )
                                MR.Parameter.Chunk.Def = { 'kx', 'ky', 'kz', 'chan', 'aver' };
                            else
                                MR.Parameter.Chunk.Def = { 'kx', 'ky', 'kz', 'chan' };
                            end
                        end
                    end
                    
                    
                    
                    AutoUpdateStatus = MR.Parameter.Recon.AutoUpdateInfoPars;
                    MR.Parameter.Recon.AutoUpdateInfoPars = 'no';
                    
                    
                    counter = Counter( 'Performing Recon --> Chunk %d/%d\n' );
                    
                    
                    for cur_loop = 1:MR.Parameter.Chunk.NrLoops
                        
                        
                        if strcmpi( MR.Parameter.Recon.StatusMessage, 'yes' )
                            counter.Update( { cur_loop, MR.Parameter.Chunk.NrLoops } );
                        end
                        
                        
                        
                        MR.Parameter.Chunk.CurLoop = cur_loop;
                        
                        
                        
                        
                        
                        
                        if MR.Parameter.Labels.Spectro
                            MR.ReadData;
                            MR.RandomPhaseCorrection;
                            MR.PDACorrection;
                            MR.DcOffsetCorrection;
                            MR.SortData;
                            MR.Average;
                            MR.RemoveOversampling;
                            MR.RingingFilter;
                            MR.ZeroFill;
                            MR.SENSEUnfold;
                            MR.EddyCurrentCorrection;
                            MR.CombineCoils;
                            MR.GeometryCorrection;
                            MR.K2I;
                            
                        else
                            
                            MR.ReadData;
                            MR.RandomPhaseCorrection;
                            MR.RemoveOversampling;
                            MR.PDACorrection;
                            MR.DcOffsetCorrection;
                            MR.MeasPhaseCorrection;
                            MR.SortData;
                            MR.GridData;
                            MR.RingingFilter;
                            MR.ZeroFill;
                            MR.K2IM;
                            MR.EPIPhaseCorrection;
                            MR.K2IP;
                            MR.GridderNormalization;
                            MR.SENSEUnfold;
                            MR.PartialFourier;
                            MR.ConcomitantFieldCorrection;
                            MR.DivideFlowSegments;
                            MR.CombineCoils;
                            MR.Average;
                            MR.GeometryCorrection;
                            MR.RemoveOversampling;
                            MR.FlowPhaseCorrection;
                            MR.ReconTKE;
                            MR.ZeroFill;
                            MR.RotateImage;
                        end
                        
                        
                        
                        
                        if MR.Parameter.Chunk.NrLoops > 1
                            [ exported_datafile, exported_listfile ] = MR.WriteExportedRaw( [ MR.Parameter.Filename.Data, '_temp.data' ], MR.Parameter.Parameter2Read );
                        end
                        
                        
                        
                        
                    end
                    
                    
                    
                    if MR.Parameter.Chunk.NrLoops > 1
                        r_temp = MRecon( exported_datafile );
                        r_temp.ReadData;
                        r_temp.Parameter.Recon.ImmediateAveraging = 'no';
                        r_temp.SortData;
                        MR.Data = r_temp.Data;
                        fclose all;
                        delete( exported_datafile );
                        delete( exported_listfile );
                        clear r_temp;
                    end
                    if strcmpi( MR.Parameter.Recon.StatusMessage, 'yes' )
                        fprintf( '\n' );
                    end
                    MR.Parameter.Recon.AutoUpdateInfoPars = AutoUpdateStatus;
                    MR.Parameter.Reset;
                case 'ExportedCpx'
                    MR.ReadData;
                    MR.SortData;
                    MR.CombineCoils;
                case 'Cpx'
                    MR.ReadData;
                    MR.CombineCoils;
                case 'Rec'
                    MR.ReadData;
                    MR.RaleREC;
                    MR.CreateComplexREC;
                otherwise
                    error( 'Error in Perform: Unknown data format' );
            end
        end
        
        
        
        
        function ReadData( MR )
            MR.Parameter.ReconFlags.Init( MR.Parameter.DataFormat );
            MR.Parameter.InitWorkEncoding( MR.Parameter );
            MR.Parameter.Gridder.InitWorkingPars;
            try
                MR.Parameter.InitCurFOV( 'ReadData' );
            end
            MR.Parameter.ResetImageInformation;
            
            switch MR.Parameter.DataFormat
                case 'Rec'
                    [ MR.Data, MR.Parameter.LabelLookupTable ] = MR.readrec( MR.Parameter.Filename.Data, MR.Parameter.Parameter2Read, MR.Parameter.Labels );
                    MR.Parameter.UpdateImageInfo = 1;
                    MR.Parameter.UpdateInfoPars;
                case 'Cpx'
                    MR.Data = MR.read_cpx( MR.Parameter.Filename.Data, 0, 0, 0, MR.Parameter.Parameter2Read, [  ], MR );
                case { 'ExportedRaw', 'Raw', 'ExportedCpx', 'Bruker' }
                    MR.Parameter.Scan.ijk = MR.Parameter.Scan.MPS;
                    
                    radial_spiral = any( strcmpi( MR.Parameter.Scan.AcqMode, { 'radial', 'spiral' } ) ) || strcmpi( MR.Parameter.Gridder.Preset, 'radial' );
                    [ MR.Data, MR.Parameter.LabelLookupTable ] =  ...
                        cellfun( @( x1, x2, x3, x4, x5, x6 )MR.ReadExportedRaw( MR.Parameter.Filename,  ...
                        MR.Parameter.DataType, MR.Parameter.Labels,  ...
                        MR.Parameter.Parameter2Read, x1, x2, x3, x4,  ...
                        radial_spiral, strcmpi( MR.Parameter.Recon.ArrayCompression, 'yes' ),  ...
                        MR.Parameter.Recon.ACNrVirtualChannels, MR.Parameter.Recon.ACMatrix ),  ...
                        MR.Parameter.Encoding.WorkEncoding.Typ,  ...
                        MR.Parameter.Encoding.WorkEncoding.Mix,  ...
                        MR.Parameter.Encoding.WorkEncoding.Echo,  ...
                        MR.Parameter.Encoding.WorkEncoding.KxRange,  ...
                        'UniformOutput', false );
            end
            
            MR.Data = MR.UnconvertCell( MR.Data );
            MR.Parameter.LabelLookupTable = MR.UnconvertCell( MR.Parameter.LabelLookupTable );
            MR.Parameter.ReconFlags.isread = 1;
        end
        
        
        
        
        function [ datafile, listfile ] = WriteExportedRaw( MR, Filename, Parameter2Write )
            if ~MR.Parameter.ReconFlags.issorted
                error( 'Please sort the data first' );
            end
            [ datafile, listfile ] = MR.write_eported_raw( MR, Filename, MR.Data, Parameter2Write );
        end
        function WriteRec( MR, Filename )
            
            if isempty( MR.Data )
                error( 'Error in WriteRec: The data matrix is empty. Please reconstruct the data first' );
            end
            
            
            MR.DataClass.Convert2Cell;
            
            
            if isempty( MR.Parameter.ImageInformation )
                for ci = 1:size( MR.Data, 1 )
                    for cj = 1:size( MR.Data, 2 )
                        dim{ ci, cj } = size( MR.Data{ ci, cj } );
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
                MR.Parameter.CreateInfoPars( dim );
                
            end
            
            if any( any( MR.Parameter.Scan.Venc ) ~= 0 )
                MR.Parameter.Recon.ExportRECImgTypes = { 'M', 'P' };
            end
            
            
            data_type = 'uint16';
            
            
            if nargin == 1 || isempty( Filename )
                Filename = 'recon.rec';
            end
            
            
            
            MR.Parameter.UpdateImageInfo = 0;
            
            
            
            
            if size( MR.Data, 1 ) > 1
                warning( 'MATLAB:MRecon', 'Only standard data is written to the .rec file' );
            end
            if size( MR.Data, 2 ) > 1
                if any( cellfun( @( x )size( x, 1 ) ~= size( x, 2 ), MR.Data( 1, : ) ) )
                    warning( 'MATLAB:MRecon', 'There are different sized images in the data. The sizes are made equal before writing' );
                end
            end
            
            
            
            nr_images = 0;
            for i = 1:size( MR.Data, 2 )
                if ~isempty( MR.Data{ 1, i } )
                    nr_images = nr_images + size( MR.Data{ 1, i }( :, :, : ), 3 );
                end
            end
            
            nr_images2 = 0;
            if ( strcmpi( MR.Parameter.Scan.Multivenc, 'Yes' ) && ( size( MR.Data, 2 ) == 2 ) )
                nr_images2 = size( MR.Data{ 1, 2 }( :, :, : ), 3 );
            end
            
            MR.Parameter.UpdatalingPars;
            
            
            
            data = zeros( size( MR.Data{ 1, 1 }, 1 ), size( MR.Data{ 1, 1 }, 2 ), nr_images );
            I = InfoPars( size( data, 3 ) );
            cur_img = 1;
            
            
            
            
            
            for i = 1:size( MR.Data, 2 )
                if ~isempty( MR.Data{ 1, i } )
                    ox = 1;
                    oy = 1;
                    oz = 1;
                    if ~isempty( MR.Parameter.Encoding.WorkEncoding.XReconRes{ 1, 1 } ) &&  ...
                            size( MR.Data{ 1, i }, 1 ) ~= size( data, 1 )
                        ox = size( MR.Data{ 1, i }, 1 ) / size( data, 1 );
                    end
                    if ~isempty( MR.Parameter.Encoding.WorkEncoding.YReconRes{ 1, 1 } ) &&  ...
                            size( MR.Data{ 1, i }, 2 ) ~= size( data, 2 )
                        oy = size( MR.Data{ 1, i }, 2 ) / size( data, 2 );
                    end
                    
                    if any( [ ox, oy, oz ] ~= [ 1, 1, 1 ] )
                        temp = zeros( size( data, 1 ), size( data, 2 ), size( MR.Data{ 1, i }, 3 ) );
                        for j = 1:size( MR.Data{ 1, i }, 3 )
                            temp( :, :, j ) = complex( imresize( real( MR.Data{ 1, i }( :, :, j ) ), [ size( data, 1 ), size( data, 2 ) ] ),  ...
                                imresize( imag( MR.Data{ 1, i }( :, :, j ) ), [ size( data, 1 ), size( data, 2 ) ] ) );
                        end
                        data( :, :, cur_img:cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = temp( :, :, : );
                    else
                        data( :, :, cur_img:cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = MR.Data{ 1, i }( :, :, : );
                    end
                    
                    
                    if iscell( MR.Parameter.ImageInformation )
                        I( cur_img:cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = MR.Parameter.ImageInformation{ 1, i }( : );
                    else
                        I( cur_img:cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = MR.Parameter.ImageInformation( : );
                    end
                    cur_img = cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 );
                end
            end
            
            if isempty( MR.Parameter.Scan.Multivenc ) || strcmpi( MR.Parameter.Scan.Multivenc, 'no' )
                if ( ~isempty( MR.Parameter.Recon.Venc ) && sum( MR.Parameter.Recon.Venc ~= 0 ) > 1 )
                    nr_files = size( MR.Data{ 1 }, 10 );
                    for ffile = 1:nr_files
                        if ~isempty( strfind( Filename, '.rec' ) )
                            fid{ ffile } = fopen( [ strrep( Filename, '.rec', '' ), sprintf( '_%d.rec', ffile ) ], 'w' );
                        elseif ~isempty( strfind( Filename, '.REC' ) )
                            fid{ ffile } = fopen( [ strrep( Filename, '.REC', '' ), sprintf( '_%d.REC', ffile ) ], 'w' );
                        else
                            fid{ ffile } = fopen( [ Filename, sprintf( '_%d.REC', ffile ) ], 'w' );
                        end
                    end
                else
                    fid{ 1 } = fopen( Filename, 'w' );
                end
            else
                venc_dir = sum( MR.Parameter.Recon.Venc > 0, 1 );
                if sum( venc_dir ) > 0
                    for nr = 1:sum( venc_dir )
                        if ~isempty( strfind( Filename, '.rec' ) )
                            fid{ nr } = fopen( [ strrep( Filename, '.rec', '' ), sprintf( '%d.rec', nr ) ], 'w' );
                        elseif ~isempty( strfind( Filename, '.REC' ) )
                            fid{ nr } = fopen( [ strrep( Filename, '.REC', '' ), sprintf( '%d.rec', nr ) ], 'w' );
                        else
                            fid{ nr } = fopen( [ Filename, sprintf( '%d.rec', nr ) ], 'w' );
                        end
                    end
                    if nr_images2 > 0
                        if ~isempty( strfind( Filename, '.rec' ) )
                            fid{ nr + 1 } = fopen( [ strrep( Filename, '.rec', '' ), 'TKE.rec' ], 'w' );
                        elseif ~isempty( strfind( Filename, '.REC' ) )
                            fid{ nr + 1 } = fopen( [ strrep( Filename, '.REC', '' ), 'TKE.rec' ], 'w' );
                        else
                            fid{ nr + 1 } = fopen( [ Filename, 'TKE.rec' ], 'w' );
                        end
                    end
                else
                    if ~isempty( strfind( Filename, '.rec' ) )
                        fid{ 1 } = fopen( [ strrep( Filename, '.rec', '' ), sprintf( '%d.rec', 1 ) ], 'w' );
                    elseif ~isempty( strfind( Filename, '.REC' ) )
                        fid{ 1 } = fopen( [ strrep( Filename, '.REC', '' ), sprintf( '%d.rec', 1 ) ], 'w' );
                    else
                        fid{ 1 } = fopen( [ Filename, sprintf( '%d.rec', 1 ) ], 'w' );
                    end
                end
            end
            
            
            nr_loops = length( MR.Parameter.Recon.ExportRECImgTypes );
            
            for phase_loop = 1:nr_loops
                xres = size( data, 1 );
                yres = size( data, 2 );
                for k = 1:( size( data, 3 ) - nr_images2 )
                    if I( k ).NoData
                        continue ;
                    end
                    
                    
                    
                    
                    
                    switch MR.Parameter.Recon.ExportRECImgTypes{ phase_loop }
                        case 'M'
                            try
                                data2write = round( ( abs( data( :, :, k ) ) - I( k ).RaleIntercept.M ) ./ I( k ).RaleSlope.M );
                            catch
                                data2write = round( ( abs( data( :, :, k ) ) - I( k ).RaleIntercept( 1 ) ) ./ I( k ).RaleSlope( 1 ) );
                            end
                        case 'P'
                            try
                                data2write = round( ( floor( 1000 .* angle( data( :, :, k ) ) ) - I( k ).RaleIntercept.P ) ./ I( k ).RaleSlope.P );
                            catch
                                data2write = round( ( floor( 1000 .* angle( data( :, :, k ) ) ) - I( k ).RaleIntercept( 2 ) ) ./ I( k ).RaleSlope( 2 ) );
                            end
                        case 'R'
                            try
                                data2write = round( ( real( data( :, :, k ) ) - I( k ).RaleIntercept.R ) ./ I( k ).RaleSlope.R );
                            catch
                                data2write = round( ( real( data( :, :, k ) ) - I( k ).RaleIntercept( 3 ) ) ./ I( k ).RaleSlope( 3 ) );
                            end
                        case 'I'
                            try
                                data2write = round( ( imag( data( :, :, k ) ) - I( k ).RaleIntercept.I ) ./ I( k ).RaleSlope.I );
                            catch
                                data2write = round( ( imag( data( :, :, k ) ) - I( k ).RaleIntercept( 4 ) ) ./ I( k ).RaleSlope.( 4 ) );
                            end
                    end
                    
                    if iscell( fid )
                        cur_fid = min( [ length( fid ), I( k ).Extra1 ] );
                        fwrite( fid{ cur_fid }, reshape( data2write, xres * yres, 1 ), data_type );
                    else
                        fwrite( fid, reshape( data2write, xres * yres, 1 ), data_type );
                    end
                end
            end
            if ( nr_images2 > 0 )
                xres = size( data, 1 );
                yres = size( data, 2 );
                for k = ( size( data, 3 ) - nr_images2 + 1 ):size( data, 3 )
                    
                    
                    
                    
                    try
                        data2write = round( ( abs( data( :, :, k ) ) - I( k ).RaleIntercept.M ) ./ I( k ).RaleSlope.M );
                    catch
                        data2write = round( ( abs( data( :, :, k ) ) - I( k ).RaleIntercept( 1 ) ) ./ I( k ).RaleSlope( 1 ) );
                    end
                    
                    fwrite( fid{ cur_fid + 1 }, reshape( data2write, xres * yres, 1 ), data_type );
                end
            end
            
            
            fclose( 'all' );
            
            
            MR.Data = MR.UnconvertCell( MR.Data );
            MR.Parameter.UpdateImageInfo = 1;
            
        end
        function WritePar( MR, Filename )
            if isempty( MR.Parameter.ImageInformation )
                error( 'Parameter.ImageInformation struct is empty. Please set Parameter.Recon.AutoUpdateInfoPars to yes' );
            end
            
            if any( any( MR.Parameter.Scan.Venc ) ~= 0 )
                MR.Parameter.Recon.ExportRECImgTypes = { 'M', 'P' };
            end
            
            auto_update_status = MR.Parameter.Recon.AutoUpdateInfoPars;
            MR.Parameter.Recon.AutoUpdateInfoPars = 'no';
            
            MR.DataClass.Convert2Cell;
            MR.Parameter.UpdatalingPars;
            
            NY = 'NY';
            
            nr_images = 0;
            for i = 1:size( MR.Data, 2 )
                if ~isempty( MR.Data{ 1, i } )
                    nr_images = nr_images + size( MR.Data{ 1, i }( :, :, : ), 3 );
                end
            end
            
            nr_images2 = 0;
            if ( strcmpi( MR.Parameter.Recon.TKE, 'Yes' ) && ( size( MR.Data, 2 ) == 2 ) )
                nr_images2 = size( MR.Data{ 1, 2 }( :, :, : ), 3 );
            end
            I = InfoPars( nr_images );
            cur_img = 1;
            for i = 1:size( MR.Data, 2 )
                if ~isempty( MR.Data{ 1, i } )
                    
                    if iscell( MR.Parameter.ImageInformation )
                        I( cur_img:cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = MR.Parameter.ImageInformation{ 1, i }( : );
                    else
                        I( cur_img:cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = MR.Parameter.ImageInformation( : );
                    end
                    cur_img = cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 );
                end
            end
            
            if nargin == 1 || isempty( Filename )
                Filename = 'recon.par';
            end
            
            if isempty( MR.Parameter.Scan.Multivenc ) || ( strcmpi( MR.Parameter.Scan.Multivenc, 'no' ) )
                if ( ~isempty( MR.Parameter.Recon.Venc ) && sum( MR.Parameter.Recon.Venc ~= 0 ) > 1 )
                    nr_files = size( MR.Data{ 1 }, 10 );
                    for ffile = 1:nr_files
                        if ~isempty( strfind( Filename, '.par' ) )
                            fid{ ffile } = fopen( [ strrep( Filename, '.par', '' ), sprintf( '_%d.par', ffile ) ], 'w' );
                        elseif ~isempty( strfind( Filename, '.PAR' ) )
                            fid{ ffile } = fopen( [ strrep( Filename, '.PAR', '' ), sprintf( '_%d.PAR', ffile ) ], 'w' );
                        else
                            fid{ ffile } = fopen( [ Filename, sprintf( '_%d.M.PAR', ffile ) ], 'w' );
                        end
                    end
                else
                    fid{ 1 } = fopen( Filename, 'w' );
                end
            else
                venc_dir = sum( MR.Parameter.Recon.Venc > 0, 1 );
                if sum( venc_dir ) > 0
                    for nr = 1:sum( venc_dir )
                        if ~isempty( strfind( Filename, '.par' ) )
                            fid{ nr } = fopen( [ strrep( Filename, '.par', '' ), sprintf( '%d.par', nr ) ], 'w' );
                        elseif ~isempty( strfind( Filename, '.PAR' ) )
                            fid{ nr } = fopen( [ strrep( Filename, '.PAR', '' ), sprintf( '%d.par', nr ) ], 'w' );
                        else
                            fid{ nr } = fopen( [ Filename, sprintf( '%d.par', nr ) ], 'w' );
                        end
                    end
                    if nr_images2 > 0
                        if ~isempty( strfind( Filename, '.par' ) )
                            fid{ nr + 1 } = fopen( [ strrep( Filename, '.par', '' ), 'TKE.par' ], 'w' );
                        elseif ~isempty( strfind( Filename, '.PAR' ) )
                            fid{ nr + 1 } = fopen( [ strrep( Filename, '.PAR', '' ), 'TKE.par' ], 'w' );
                        else
                            fid{ nr + 1 } = fopen( [ Filename, 'TKE.par' ], 'w' );
                        end
                    end
                else
                    if ~isempty( strfind( Filename, '.par' ) )
                        fid{ 1 } = fopen( [ strrep( Filename, '.par', '' ), sprintf( '%d.par', 1 ) ], 'w' );
                    elseif ~isempty( strfind( Filename, '.PAR' ) )
                        fid{ 1 } = fopen( [ strrep( Filename, '.PAR', '' ), sprintf( '%d.par', 1 ) ], 'w' );
                    else
                        fid{ 1 } = fopen( [ Filename, sprintf( '%d.par', 1 ) ], 'w' );
                    end
                end
            end
            
            v = MRparameter.convert_parameter2output_struct( MR.Parameter );
            
            slashind = [ strfind( Filename, '\' ), strfind( Filename, '/' ) ];
            dotind = strfind( Filename, '.' );
            if isempty( slashind )
                slashind = 1;
            end
            if isempty( dotind )
                dotind = length( Filename );
            end
            dataset_name = Filename( slashind( end  ) + 1:dotind( end  ) - 1 );
            
            venc_ind = abs( MRparameter.coord2num( MRparameter.unformat_coord_str( MR.Parameter.Scan.ijk( 1, : ) ) ) );
            for i = 1:length( fid )
                
                if isempty( MR.Parameter.Recon.Venc )
                    MR.Parameter.Recon.Venc = MR.Parameter.Scan.Venc;
                end
                if size( MR.Parameter.Recon.Venc, 2 ) < 3
                    MR.Parameter.Recon.Venc( :, end  + 1:3 ) = 0;
                end
                
                if strcmpi( MR.Parameter.Scan.Multivenc, 'no' )
                    if ~isempty( MR.Parameter.Recon.Venc )
                        venc = v.PhaseEncodingVelocity .* 0;
                        if sum( MR.Parameter.Recon.Venc ~= 0 ) > 1
                            try
                                venc( venc_ind( i ) ) = MR.Parameter.Recon.Venc( i );
                            catch
                                venc = [ 0, 0, 0 ];
                            end
                        else
                            venc = MR.Parameter.Recon.Venc;
                        end
                    else
                        venc = [ 0, 0, 0 ];
                    end
                else
                    venc = MR.Parameter.Recon.Venc( i, : );
                end
                
                
                fprintf( fid{ i }, '# === DATA DRIPTION FILE ======================================================\r\n' );
                fprintf( fid{ i }, '#\r\n' );
                fprintf( fid{ i }, '# CAUTION - Investigational device.\r\n' );
                fprintf( fid{ i }, '# Limited by Federal Law to investigational use.\r\n' );
                fprintf( fid{ i }, '#\r\n' );
                fprintf( fid{ i }, '# Dataset name: %s\r\n', dataset_name );
                fprintf( fid{ i }, '# Exported by MRecon (c)Gyrotools GmbH, Zuerich Switzerland (http://www.gyrotools.ch/)\r\n' );
                fprintf( fid{ i }, '# CLINICAL TRYOUT             Research image export tool     V4.1\r\n' );
                fprintf( fid{ i }, '#\r\n' );
                fprintf( fid{ i }, '# === GENERAL INFORMATION ========================================================\r\n' );
                fprintf( fid{ i }, '#\r\n' );
                
                fprintf( fid{ i }, '.    Patient name                       :   %s\r\n', v.PatientName );
                fprintf( fid{ i }, '.    Examination name                   :   %s\r\n', v.ExaminationName );
                fprintf( fid{ i }, '.    Protocol name                      :   %s\r\n', v.ProtocolName );
                fprintf( fid{ i }, '.    Examination date/time              :   %s / %s\r\n', v.ExaminationDate, v.ExaminationTime );
                fprintf( fid{ i }, '.    Series_data_type                   :   %d\r\n', 0 );
                fprintf( fid{ i }, '.    Acquisition nr                     :   %d\r\n', v.AquisitionNumber );
                fprintf( fid{ i }, '.    Reconstruction nr                  :   %d\r\n', v.ReconstructionNumber );
                fprintf( fid{ i }, '.    Scan Duration [sec]                :   %0.2f\r\n', 0 );
                fprintf( fid{ i }, '.    Max. number of cardiac phases      :   %d\r\n', v.MaxNoPhases );
                fprintf( fid{ i }, '.    Max. number of echoes              :   %d\r\n', v.MaxNoEchoes );
                fprintf( fid{ i }, '.    Max. number of slices/locations    :   %d\r\n', v.MaxNoSlices );
                fprintf( fid{ i }, '.    Max. number of dynamics            :   %d\r\n', v.MaxNoDynamics );
                fprintf( fid{ i }, '.    Max. number of mixes               :   %d\r\n', v.MaxNoMixes );
                fprintf( fid{ i }, '.    Patient Position                   :   %s\r\n', v.PatientPosition );
                fprintf( fid{ i }, '.    Preparation direction              :   %s\r\n', v.PreparationDirection( 1, : ) );
                fprintf( fid{ i }, '.    Technique                          :   %s\r\n', v.Technique );
                fprintf( fid{ i }, '.    Scan resolution  (x, y)            :   %-3d  %3d\r\n', v.ScanResolutionX, v.ScanResolutionY );
                fprintf( fid{ i }, '.    Scan mode                          :   %s\r\n', v.ScanMode );
                fprintf( fid{ i }, '.    Repetition time [msec]             :   %0.2f\r\n', v.RepetitionTimes( 1 ) );
                fprintf( fid{ i }, '.    FOV (ap,fh,rl) [mm]                :   %-5.2f %5.2f %5.2f\r\n', v.FOVAP, v.FOVFH, v.FOVRL );
                fprintf( fid{ i }, '.    Water Fat shift [pixels]           :   %0.2f\r\n', v.WaterFatShift );
                fprintf( fid{ i }, '.    Angulation midslice(ap,fh,rl)[degr]:   %-6.2f %-6.2f %-6.2f\r\n', v.AngulationAP, v.AngulationFH, v.AngulationRL );
                fprintf( fid{ i }, '.    Off Centre midslice(ap,fh,rl) [mm] :   %-6.2f %-6.2f %-6.2f\r\n', v.OffCenterAP, v.OffCenterFH, v.OffCenterRL );
                fprintf( fid{ i }, '.    Flow compensation <0=no 1=yes> ?   :   %d\r\n', findstr( NY, v.FlowCompensation ) - 1 );
                fprintf( fid{ i }, '.    Presaturation     <0=no 1=yes> ?   :   %d\r\n', findstr( NY, v.Presaturation ) - 1 );
                fprintf( fid{ i }, '.    Phase encoding velocity [cm/sec]   :   %-5.2f %5.2f %5.2f\r\n', venc( 1 ), venc( 2 ), venc( 3 ) );
                fprintf( fid{ i }, '.    MTC               <0=no 1=yes> ?   :   %d\r\n', findstr( NY, v.MTC ) - 1 );
                fprintf( fid{ i }, '.    SPIR              <0=no 1=yes> ?   :   %d\r\n', findstr( NY, v.SPIR ) - 1 );
                fprintf( fid{ i }, '.    EPI factor        <0,1=no EPI>     :   %d\r\n', v.EPIfactor );
                fprintf( fid{ i }, '.    Dynamic scan      <0=no 1=yes> ?   :   %d\r\n', findstr( NY, v.DynamicScan ) - 1 );
                fprintf( fid{ i }, '.    Diffusion         <0=no 1=yes> ?   :   %d\r\n', findstr( NY, v.Diffusion ) - 1 );
                fprintf( fid{ i }, '.    Diffusion echo time [msec]         :   %0.2f\r\n', v.DiffusionEchoTime );
                fprintf( fid{ i }, '.    Max. number of diffusion values    :   %d\r\n', v.DiffusionValues );
                fprintf( fid{ i }, '.    Max. number of gradient orients    :   %d\r\n', v.GradientOris );
                fprintf( fid{ i }, '.    Number of label types   <0=no ASL> :   %d\r\n', v.ASLNolabelTypes );
                fprintf( fid{ i }, '#\r\n' );
                
                fprintf( fid{ i }, '# === PIXEL VALUES =============================================================\r\n' );
                fprintf( fid{ i }, '#  PV = pixel value in REC file, FP = floating point value, DV = displayed value on console\r\n' );
                fprintf( fid{ i }, '#  RS = rale slope,           RI = rale intercept,    SS = scale slope\r\n' );
                fprintf( fid{ i }, '#  DV = PV * RS + RI             FP = PV /  SS\r\n' );
                fprintf( fid{ i }, '#\r\n' );
                fprintf( fid{ i }, '# === IMAGE INFORMATION DEFINITION =============================================\r\n' );
                fprintf( fid{ i }, '#  The rest of this file contains ONE line per image, this line contains the following information:\r\n' );
                fprintf( fid{ i }, '#  \r\n' );
                fprintf( fid{ i }, '#  slice number                             (integer)\r\n' );
                fprintf( fid{ i }, '#  echo number                              (integer)\r\n' );
                fprintf( fid{ i }, '#  dynamic scan number                      (integer)\r\n' );
                fprintf( fid{ i }, '#  cardiac phase number                     (integer)\r\n' );
                fprintf( fid{ i }, '#  image_type_mr                            (integer)\r\n' );
                fprintf( fid{ i }, '#  scanning sequence                        (integer)\r\n' );
                fprintf( fid{ i }, '#  index in REC file (in images)            (integer)\r\n' );
                fprintf( fid{ i }, '#  image pixel size (in bits)               (integer)\r\n' );
                fprintf( fid{ i }, '#  scan percentage                          (integer)\r\n' );
                fprintf( fid{ i }, '#  recon resolution (x,y)                   (2*integer)\r\n' );
                fprintf( fid{ i }, '#  rale intercept                        (float)\r\n' );
                fprintf( fid{ i }, '#  rale slope                            (float)\r\n' );
                fprintf( fid{ i }, '#  scale slope                              (float)\r\n' );
                fprintf( fid{ i }, '#  window center                            (integer)\r\n' );
                fprintf( fid{ i }, '#  window width                             (integer)\r\n' );
                fprintf( fid{ i }, '#  image angulation (ap,fh,rl in degrees )  (3*float)\r\n' );
                fprintf( fid{ i }, '#  image offcentre (ap,fh,rl in mm )        (3*float)\r\n' );
                fprintf( fid{ i }, '#  slice thickness                          (float)\r\n' );
                fprintf( fid{ i }, '#  slice gap                                (float)\r\n' );
                fprintf( fid{ i }, '#  image_display_orientation                (integer)\r\n' );
                fprintf( fid{ i }, '#  slice orientation ( TRA/SAG/COR )        (integer)\r\n' );
                fprintf( fid{ i }, '#  fmri_status_indication                   (integer)\r\n' );
                fprintf( fid{ i }, '#  image_type_ed_es  (end diast/end syst)   (integer)\r\n' );
                fprintf( fid{ i }, '#  pixel spacing (x,y) (in mm)              (2*float)\r\n' );
                fprintf( fid{ i }, '#  echo_time                                (float)\r\n' );
                fprintf( fid{ i }, '#  dyn_scan_begin_time                      (float)\r\n' );
                fprintf( fid{ i }, '#  trigger_time                             (float)\r\n' );
                fprintf( fid{ i }, '#  diffusion_b_factor                       (float)\r\n' );
                fprintf( fid{ i }, '#  number of averages                       (float)\r\n' );
                fprintf( fid{ i }, '#  image_flip_angle (in degrees)            (float)\r\n' );
                fprintf( fid{ i }, '#  cardiac frequency                        (integer)\r\n' );
                fprintf( fid{ i }, '#  min. RR. interval                        (integer)\r\n' );
                fprintf( fid{ i }, '#  max. RR. interval                        (integer)\r\n' );
                fprintf( fid{ i }, '#  turbo factor                             (integer)\r\n' );
                fprintf( fid{ i }, '#  inversion delay                          (float)\r\n' );
                fprintf( fid{ i }, '#  diffusion b value number    (imagekey!)  (integer)\r\n' );
                fprintf( fid{ i }, '#  gradient orientation number (imagekey!)  (integer)\r\n' );
                fprintf( fid{ i }, '#  contrast type                            (string)\r\n' );
                fprintf( fid{ i }, '#  diffusion anisotropy type                (string)\r\n' );
                fprintf( fid{ i }, '#  diffusion (ap, fh, rl)                   (3*float)\r\n' );
                fprintf( fid{ i }, '#  label type (ASL)            (imagekey!)  (integer)\r\n' );
                fprintf( fid{ i }, '#\r\n' );
                fprintf( fid{ i }, '# === IMAGE INFORMATION ==========================================================\r\n' );
                fprintf( fid{ i }, '#sl ec dyn ph ty  idx pix %% rec size (re)scale     window       angulation      offcentre         thick  gap   info   spacing   echo  dtime ttime    diff avg  flip  freq RR_int  turbo  delay b grad cont anis diffusion\r\n\r\n' );
                
                format_str = '%-4d %-3d %-3d %-3d %-3d %-3d %-5d %-2d %-4d %-4d %-4d %8f %8f %8f %6d %6d %6.2f %6.2f %6.2f %7.3f %7.3f %7.3f %5.2f %5.2f %d %d %d %d %5.3f %5.3f %5.3f %9.3f %5.1f %5d %5d %4.1f %5d %5d %5d %3d %4.2f %3d %3d %6d %6d %8f %8f %8f %3d\r\n';
                datatyp = 'uint16';
            end
            
            total_nr_images = length( v.ImageInformation.Slice );
            
            index = zeros( length( fid ), 1 );
            for i = 1:total_nr_images - nr_images2
                
                if v.ImageInformation.NoData( i )
                    continue ;
                end
                
                
                if length( fid ) > 1
                    cur_fid = v.Extr1( i );
                else
                    cur_fid = 1;
                end
                
                switch v.ImageInformation.Type( i, : )
                    case 'M'
                        type = 0;
                    case 'R'
                        type = 1;
                    case 'I'
                        type = 2;
                    case 'P'
                        type = 3;
                end
                
                ri = v.ImageInformation.RaleIntercept( i );
                rs = v.ImageInformation.RaleSlope( i );
                ss = v.ImageInformation.ScaleSlope( i );
                wc = v.ImageInformation.WindowCenter( i );
                ww = v.ImageInformation.WindowWidth( i );
                
                switch v.ImageInformation.Sequence( i, : )
                    case 'FFE'
                        seq = 0;
                    case 'SE'
                        seq = 1;
                end
                switch strtrim( v.ImageInformation.SliceOrientation( i, : ) )
                    case 'Transversal'
                        ori = 1;
                    case 'Coronal'
                        ori = 3;
                    case 'Sagital'
                        ori = 2;
                end
                
                fprintf( fid{ cur_fid }, format_str,  ...
                    v.ImageInformation.Slice( i ),  ...
                    v.ImageInformation.Echo( i ),  ...
                    v.ImageInformation.Dynamic( i ),  ...
                    v.ImageInformation.Phase( i ),  ...
                    type,  ...
                    seq,  ...
                    index( cur_fid ),  ...
                    16,  ...
                    v.ImageInformation.ScanPercentage( i ),  ...
                    v.ImageInformation.ResolutionX( i ),  ...
                    v.ImageInformation.ResolutionY( i ),  ...
                    ri,  ...
                    rs,  ...
                    ss,  ...
                    wc,  ...
                    ww,  ...
                    v.ImageInformation.AngulationAP( i ),  ...
                    v.ImageInformation.AngulationFH( i ),  ...
                    v.ImageInformation.AngulationRL( i ),  ...
                    v.ImageInformation.OffcenterAP( i ),  ...
                    v.ImageInformation.OffcenterFH( i ),  ...
                    v.ImageInformation.OffcenterRL( i ),  ...
                    v.ImageInformation.SliceThickness( i ),  ...
                    v.ImageInformation.SliceGap( i ),  ...
                    0,  ...
                    ori,  ...
                    v.ImageInformation.fMRIStatusIndication( i ),  ...
                    0,  ...
                    v.ImageInformation.PixelSpacing( i, 1 ),  ...
                    v.ImageInformation.PixelSpacing( i, 1 ),  ...
                    v.ImageInformation.EchoTime( i ),  ...
                    v.ImageInformation.DynScanBeginTime( i ),  ...
                    v.ImageInformation.TriggerTime( i ),  ...
                    v.ImageInformation.DiffusionBFactor( i ),  ...
                    v.ImageInformation.NoAverages( i ),  ...
                    v.ImageInformation.ImageFlipAngle( i ),  ...
                    v.ImageInformation.CardiacFrequency( i ),  ...
                    v.ImageInformation.MinRRInterval( i ),  ...
                    v.ImageInformation.MaxRRInterval( i ),  ...
                    v.ImageInformation.TURBOFactor( i ),  ...
                    v.ImageInformation.InversionDelay( i ),  ...
                    v.ImageInformation.BValue( i ),  ...
                    v.ImageInformation.GradOrient( i ),  ...
                    0,  ...
                    0,  ...
                    v.ImageInformation.DiffusionAP( i ),  ...
                    v.ImageInformation.DiffusionFH( i ),  ...
                    v.ImageInformation.DiffusionRL( i ),  ...
                    v.ImageInformation.LabelTypeASL( i ) );
                
                index( cur_fid ) = index( cur_fid ) + 1;
            end
            
            if ( ( nr_images2 > 2 ) && strcmpi( MR.Parameter.Recon.TKE, 'Yes' ) )
                cur_fid = cur_fid + 1;
                for i = total_nr_images - nr_images2 + 1:total_nr_images
                    
                    
                    type = 0;
                    
                    ri = v.ImageInformation.RaleIntercept( i );
                    rs = v.ImageInformation.RaleSlope( i );
                    ss = v.ImageInformation.ScaleSlope( i );
                    wc = v.ImageInformation.WindowCenter( i );
                    ww = v.ImageInformation.WindowWidth( i );
                    
                    switch v.ImageInformation.Sequence( i, : )
                        case 'FFE'
                            seq = 0;
                        case 'SE'
                            seq = 1;
                    end
                    switch strtrim( v.ImageInformation.SliceOrientation( i, : ) )
                        case 'Transversal'
                            ori = 1;
                        case 'Coronal'
                            ori = 3;
                        case 'Sagital'
                            ori = 2;
                    end
                    
                    fprintf( fid{ cur_fid }, format_str,  ...
                        v.ImageInformation.Slice( i ),  ...
                        v.ImageInformation.Echo( i ),  ...
                        v.ImageInformation.Dynamic( i ),  ...
                        v.ImageInformation.Phase( i ),  ...
                        type,  ...
                        seq,  ...
                        index( cur_fid ),  ...
                        16,  ...
                        v.ImageInformation.ScanPercentage( i ),  ...
                        v.ImageInformation.ResolutionX( i ),  ...
                        v.ImageInformation.ResolutionY( i ),  ...
                        ri,  ...
                        rs,  ...
                        ss,  ...
                        wc,  ...
                        ww,  ...
                        v.ImageInformation.AngulationAP( i ),  ...
                        v.ImageInformation.AngulationFH( i ),  ...
                        v.ImageInformation.AngulationRL( i ),  ...
                        v.ImageInformation.OffcenterAP( i ),  ...
                        v.ImageInformation.OffcenterFH( i ),  ...
                        v.ImageInformation.OffcenterRL( i ),  ...
                        v.ImageInformation.SliceThickness( i ),  ...
                        v.ImageInformation.SliceGap( i ),  ...
                        0,  ...
                        ori,  ...
                        v.ImageInformation.fMRIStatusIndication( i ),  ...
                        0,  ...
                        v.ImageInformation.PixelSpacing( i, 1 ),  ...
                        v.ImageInformation.PixelSpacing( i, 1 ),  ...
                        v.ImageInformation.EchoTime( i ),  ...
                        v.ImageInformation.DynScanBeginTime( i ),  ...
                        v.ImageInformation.TriggerTime( i ),  ...
                        v.ImageInformation.DiffusionBFactor( i ),  ...
                        v.ImageInformation.NoAverages( i ),  ...
                        v.ImageInformation.ImageFlipAngle( i ),  ...
                        v.ImageInformation.CardiacFrequency( i ),  ...
                        v.ImageInformation.MinRRInterval( i ),  ...
                        v.ImageInformation.MaxRRInterval( i ),  ...
                        v.ImageInformation.TURBOFactor( i ),  ...
                        v.ImageInformation.InversionDelay( i ),  ...
                        v.ImageInformation.BValue( i ),  ...
                        v.ImageInformation.GradOrient( i ),  ...
                        0,  ...
                        0,  ...
                        v.ImageInformation.DiffusionAP( i ),  ...
                        v.ImageInformation.DiffusionFH( i ),  ...
                        v.ImageInformation.DiffusionRL( i ),  ...
                        v.ImageInformation.LabelTypeASL( i ) );
                    
                    index( cur_fid ) = index( cur_fid ) + 1;
                end
            end
            
            for i = 1:length( fid )
                fprintf( fid{ i }, '\r\n' );
                fprintf( fid{ i }, '# === END OF DATA DRIPTION FILE ===============================================\r\n' );
            end
            
            MR.Data = MR.UnconvertCell( MR.Data );
            MR.Parameter.Recon.AutoUpdateInfoPars = auto_update_status;
            fclose all;
            
        end
        function WriteXMLPar( MR, Filename )
            auto_update_status = MR.Parameter.Recon.AutoUpdateInfoPars;
            MR.Parameter.Recon.AutoUpdateInfoPars = 'no';
            
            if nargin == 1 || isempty( Filename )
                Filename = 'recon.xml';
            end
            
            MR.DataClass.Convert2Cell;
            MR.Parameter.UpdatalingPars;
            
            nr_images = 0;
            for i = 1:size( MR.Data, 2 )
                if ~isempty( MR.Data{ 1, i } )
                    nr_images = nr_images + size( MR.Data{ 1, i }( :, :, : ), 3 );
                end
            end
            I = InfoPars( nr_images );
            cur_img = 1;
            for i = 1:size( MR.Data, 2 )
                if ~isempty( MR.Data{ 1, i } )
                    
                    if iscell( MR.Parameter.ImageInformation )
                        I( cur_img:cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = MR.Parameter.ImageInformation{ 1, i }( : );
                    else
                        I( cur_img:cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = MR.Parameter.ImageInformation( : );
                    end
                    cur_img = cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 );
                end
            end
            
            v = MRparameter.convert_parameter2output_struct( MR.Parameter );
            if all( MR.Parameter.Scan.Venc ~= 0 ) && length( unique( [ I.Extra1 ] ) ) == 3
                if ~isempty( strfind( Filename, '.xml' ) )
                    fid{ 1 } = fopen( [ strrep( Filename, '.xml', '' ), 'M.xml' ], 'w' );
                    fid{ 2 } = fopen( [ strrep( Filename, '.xml', '' ), 'P.xml' ], 'w' );
                    fid{ 3 } = fopen( [ strrep( Filename, '.xml', '' ), 'S.xml' ], 'w' );
                elseif ~isempty( strfind( Filename, '.XML' ) )
                    fid{ 1 } = fopen( [ strrep( Filename, '.XML', '' ), 'M.XML' ], 'w' );
                    fid{ 2 } = fopen( [ strrep( Filename, '.XML', '' ), 'P.XML' ], 'w' );
                    fid{ 3 } = fopen( [ strrep( Filename, '.XML', '' ), 'S.XML' ], 'w' );
                else
                    fid{ 1 } = fopen( [ Filename, 'M.XML' ], 'w' );
                    fid{ 2 } = fopen( [ Filename, 'P.XML' ], 'w' );
                    fid{ 3 } = fopen( [ Filename, 'S.XML' ], 'w' );
                end
            else
                fid = fopen( Filename, 'w' );
            end
            
            fprintf( fid, '<PRIDE_V5>\r\n' );
            fprintf( fid, '<Series_Info>\r\n' );
            
            fprintf( fid, '<Attribute Name="Patient Name" Tag="0x00100010" Level="Patient" Type="String">%s</Attribute>\r\n', strtrim( v.PatientName ) );
            fprintf( fid, '<Attribute Name="Examination Name" Tag="0x00400254" Level="Examination" Type="String">%s</Attribute>\r\n', strtrim( v.ExaminationName ) );
            fprintf( fid, '<Attribute Name="Protocol Name" Tag="0x00181030" Level="MRSeries" Type="String">%s</Attribute>\r\n', strtrim( v.ProtocolName ) );
            fprintf( fid, '<Attribute Name="Examination Date" Tag="0x00400244" Level="Examination" Type="Date">%s</Attribute>\r\n', strtrim( v.ExaminationDate ) );
            fprintf( fid, '<Attribute Name="Examination Time" Tag="0x00400245" Level="Examination" Type="Time">%s</Attribute>\r\n', strtrim( v.ExaminationTime ) );
            fprintf( fid, '<Attribute Name="Series Data Type" Tag="0x20051035" Level="MRSeries" Type="String">%s</Attribute>\r\n', strtrim( v.SeriesDataType ) );
            fprintf( fid, '<Attribute Name="Aquisition Number" Tag="0x2001107B" Level="MRSeries" Type="Int32">%d</Attribute>\r\n', v.AquisitionNumber );
            fprintf( fid, '<Attribute Name="Reconstruction Number" Tag="0x2001101D" Level="MRSeries" Type="Int32">%d</Attribute>\r\n', v.ReconstructionNumber );
            fprintf( fid, '<Attribute Name="Scan Duration" Tag="0x2001101D" Level="MRSeries" Type="Float">%f</Attribute>\r\n', v.ScanDuration );
            fprintf( fid, '<Attribute Name="Max No Phases" Tag="0x20011017" Level="MRSeries" Type="Int32">%d</Attribute>\r\n', v.MaxNoPhases );
            fprintf( fid, '<Attribute Name="Max No Echoes" Tag="0x20011014" Level="MRSeries" Type="Int32">%d</Attribute>\r\n', v.MaxNoEchoes );
            fprintf( fid, '<Attribute Name="Max No Slices" Tag="0x20011018" Level="MRSeries" Type="Int32">%d</Attribute>\r\n', v.MaxNoSlices );
            fprintf( fid, '<Attribute Name="Max No Dynamics" Tag="0x20011081" Level="MRSeries" Type="Int32">%d</Attribute>\r\n', v.MaxNoDynamics );
            fprintf( fid, '<Attribute Name="Max No Mixes" Tag="0x20051021" Level="MRSeries" Type="Int16">%d</Attribute>\r\n', v.MaxNoMixes );
            fprintf( fid, '<Attribute Name="Max No B Values" Tag="0x20051414" Level="MRSeries" Type="Int32">%d</Attribute>\r\n', v.MaxNoBValues );
            fprintf( fid, '<Attribute Name="Max No Gradient Orients" Tag="0x20051415" Level="MRSeries" Type="Int32">%d</Attribute>\r\n', v.MaxNoGradientOrients );
            fprintf( fid, '<Attribute Name="No Label Types" Tag="0x20051428" Level="MRSeries" Type="Int32">%d</Attribute>\r\n', v.NoLabelTypes );
            fprintf( fid, '<Attribute Name="Patient Position" Tag="0x00185100" Level="MRSeries" Type="String">%s</Attribute>\r\n', strtrim( v.PatientPosition ) );
            fprintf( fid, '<Attribute Name="Preparation Direction" Tag="0x2005107B" Level="MRStack" Type="String">%s</Attribute>\r\n', strtrim( v.PreparationDirection ) );
            fprintf( fid, '<Attribute Name="Technique" Tag="0x20011020" Level="MRSeries" Type="String">%s</Attribute>\r\n', strtrim( v.Technique ) );
            fprintf( fid, '<Attribute Name="Scan Resolution X" Tag="0x2005101D" Level="MRSeries" Type="Int16">%d</Attribute>\r\n', v.ScanResolutionX );
            fprintf( fid, '<Attribute Name="Scan Resolution Y" Tag="0x00180089" Level="MRImage" Type="Int32">%d</Attribute>\r\n', v.ScanResolutionY );
            fprintf( fid, '<Attribute Name="Scan Mode" Tag="0x2005106F" Level="MRSeries" Type="String">%s</Attribute>\r\n', strtrim( v.ScanMode ) );
            if length( v.RepetitionTimes ) > 1
                temp1 = sprintf( '%2.4E', v.RepetitionTimes( 1 ) );
                temp2 = sprintf( '%2.4E', v.RepetitionTimes( 2 ) );
                temp1( end  - 2 ) = [  ];
                temp2( end  - 2 ) = [  ];
                fprintf( fid, '<Attribute Name="Repetition Times" Tag="0x20051030" Level="MRSeries" Type="Float" ArraySize="2">%s %s</Attribute>\r\n', temp1, temp2 );
            else
                temp1 = sprintf( '%2.4E', v.RepetitionTimes( 1 ) );
                temp1( end  - 2 ) = [  ];
                fprintf( fid, '<Attribute Name="Repetition Times" Tag="0x20051030" Level="MRSeries" Type="Float" ArraySize="2">%s</Attribute>\r\n', temp1 );
            end
            temp1 = sprintf( '%2.4E', v.FOVAP );
            temp1( end  - 2 ) = [  ];
            fprintf( fid, '<Attribute Name="FOV AP" Tag="0x20051074" Level="MRStack" Type="Float">%s</Attribute>\r\n', temp1 );
            temp1 = sprintf( '%2.4E', v.FOVFH );
            temp1( end  - 2 ) = [  ];
            fprintf( fid, '<Attribute Name="FOV FH" Tag="0x20051075" Level="MRStack" Type="Float">%s</Attribute>\r\n', temp1 );
            temp1 = sprintf( '%2.4E', v.FOVRL );
            temp1( end  - 2 ) = [  ];
            fprintf( fid, '<Attribute Name="FOV RL" Tag="0x20051076" Level="MRStack" Type="Float">%s</Attribute>\r\n', temp1 );
            temp1 = sprintf( '%2.4E', v.WaterFatShift );
            temp1( end  - 2 ) = [  ];
            fprintf( fid, '<Attribute Name="Water Fat Shift" Tag="0x20011022" Level="MRSeries" Type="Float">%s</Attribute>\r\n', temp1 );
            temp1 = sprintf( '%2.4E', v.AngulationAP );
            temp1( end  - 2 ) = [  ];
            fprintf( fid, '<Attribute Name="Angulation AP" Tag="0x20051071" Level="MRStack" Type="Float">%s</Attribute>\r\n', temp1 );
            temp1 = sprintf( '%2.4E', v.AngulationFH );
            temp1( end  - 2 ) = [  ];
            fprintf( fid, '<Attribute Name="Angulation FH" Tag="0x20051072" Level="MRStack" Type="Float">%s</Attribute>\r\n', temp1 );
            temp1 = sprintf( '%2.4E', v.AngulationRL );
            temp1( end  - 2 ) = [  ];
            fprintf( fid, '<Attribute Name="Angulation RL" Tag="0x20051073" Level="MRStack" Type="Float">%s</Attribute>\r\n', temp1 );
            temp1 = sprintf( '%2.4E', v.OffCenterAP );
            temp1( end  - 2 ) = [  ];
            fprintf( fid, '<Attribute Name="Off Center AP" Tag="0x20051078" Level="MRStack" Type="Float">%s</Attribute>\r\n', temp1 );
            temp1 = sprintf( '%2.4E', v.OffCenterFH );
            temp1( end  - 2 ) = [  ];
            fprintf( fid, '<Attribute Name="Off Center FH" Tag="0x20051079" Level="MRStack" Type="Float">%s</Attribute>\r\n', temp1 );
            temp1 = sprintf( '%2.4E', v.OffCenterRL );
            temp1( end  - 2 ) = [  ];
            fprintf( fid, '<Attribute Name="Off Center RL" Tag="0x2005107A" Level="MRStack" Type="Float">%s</Attribute>\r\n', temp1 );
            fprintf( fid, '<Attribute Name="Flow Compensation" Tag="0x20051016" Level="MRSeries" Type="Boolean">%s</Attribute>\r\n', strtrim( v.FlowCompensation ) );
            fprintf( fid, '<Attribute Name="Presaturation" Tag="0x2005102F" Level="MRSeries" Type="Boolean">%s</Attribute>\r\n', strtrim( v.Presaturation ) );
            temp1 = sprintf( '%2.4E', v.PhaseEncodingVelocity( 1 ) );
            temp2 = sprintf( '%2.4E', v.PhaseEncodingVelocity( 2 ) );
            temp3 = sprintf( '%2.4E', v.PhaseEncodingVelocity( 3 ) );
            temp1( end  - 2 ) = [  ];
            temp2( end  - 2 ) = [  ];
            temp3( end  - 2 ) = [  ];
            fprintf( fid, '<Attribute Name="Phase Encoding Velocity" Tag="0x2001101A" Level="MRSeries" Type="Float" ArraySize="3">%s %s %s</Attribute>\r\n', temp1, temp2, temp3 );
            fprintf( fid, '<Attribute Name="MTC" Tag="0x2005101C" Level="MRSeries" Type="Boolean">%s</Attribute>\r\n', strtrim( v.MTC ) );
            fprintf( fid, '<Attribute Name="SPIR" Tag="0x20011021" Level="MRSeries" Type="Boolean">%s</Attribute>\r\n', strtrim( v.SPIR ) );
            fprintf( fid, '<Attribute Name="EPI factor" Tag="0x20011013" Level="MRSeries" Type="Int32">%d</Attribute>\r\n', v.EPIfactor );
            fprintf( fid, '<Attribute Name="Dynamic Scan" Tag="0x20011012" Level="MRSeries" Type="Boolean">%s</Attribute>\r\n', strtrim( v.DynamicScan ) );
            fprintf( fid, '<Attribute Name="Diffusion" Tag="0x20051014" Level="MRSeries" Type="Boolean">%s</Attribute>\r\n', strtrim( v.Diffusion ) );
            temp1 = sprintf( '%2.4E', v.DiffusionEchoTime );
            temp1( end  - 2 ) = [  ];
            fprintf( fid, '<Attribute Name="Diffusion Echo Time" Tag="0x20011011" Level="MRSeries" Type="Float">%s</Attribute>\r\n', temp1 );
            fprintf( fid, '</Series_Info>\r\n' );
            
            fprintf( fid, '<Image_Array>' );
            
            for i = 1:length( v.ImageInformation.Slice )
                if v.ImageInformation.NoData( i )
                    continue ;
                end
                
                fprintf( fid, '<Image_Info>' );
                fprintf( fid, '<Key>' );
                fprintf( fid, '<Attribute Name="Slice" Tag="0x2001100A" Type="Int32">%d</Attribute>\r\n', v.ImageInformation.Slice( i ) );
                fprintf( fid, '<Attribute Name="Echo" Tag="0x00180086" Type="Int32">%d</Attribute>\r\n', v.ImageInformation.Echo( i ) );
                fprintf( fid, '<Attribute Name="Dynamic" Tag="0x00200100" Type="Int32">%d</Attribute>\r\n', v.ImageInformation.Dynamic( i ) );
                fprintf( fid, '<Attribute Name="Phase" Tag="0x20011008" Type="Int32">%d</Attribute>\r\n', v.ImageInformation.Phase( i ) );
                fprintf( fid, '<Attribute Name="BValue" Tag="0x20051412" Type="Int32">%d</Attribute>\r\n', v.ImageInformation.BValue( i ) );
                fprintf( fid, '<Attribute Name="Grad Orient" Tag="0x20051413" Type="Int32">%d</Attribute>\r\n', v.ImageInformation.GradOrient( i ) );
                fprintf( fid, '<Attribute Name="Label Type" Tag="0x20051429" Type="Enumeration" EnumType="Label_Type">%s</Attribute>\r\n', strtrim( v.ImageInformation.LabelType( i, : ) ) );
                fprintf( fid, '<Attribute Name="Type" Tag="0x20051011" Type="Enumeration" EnumType="Image_Type">%s</Attribute>\r\n', strtrim( v.ImageInformation.Type( i, : ) ) );
                fprintf( fid, '<Attribute Name="Sequence" Tag="0x2005106E" Type="Enumeration" EnumType="Image_Sequence">%s</Attribute>\r\n', strtrim( v.ImageInformation.Sequence( i, : ) ) );
                fprintf( fid, '<Attribute Name="Index" Type="Int32" Calc="Index">%d</Attribute>\r\n', v.ImageInformation.Index( i ) );
                fprintf( fid, '</Key>\r\n' );
                fprintf( fid, '<Attribute Name="Pixel Size" Tag="0x00280100" Type="UInt16">%d</Attribute>\r\n', v.ImageInformation.PixelSize( i ) );
                fprintf( fid, '<Attribute Name="Scan Percentage" Tag="0x00180093" Type="Double">%2.6E</Attribute>\r\n', v.ImageInformation.ScanPercentage( i ) );
                fprintf( fid, '<Attribute Name="Resolution X" Tag="0x00280011" Type="UInt16">%d</Attribute>\r\n', v.ImageInformation.ResolutionX( i ) );
                fprintf( fid, '<Attribute Name="Resolution Y" Tag="0x00280010" Type="UInt16">%d</Attribute>\r\n', v.ImageInformation.ResolutionY( i ) );
                
                ri = v.ImageInformation.RaleIntercept( i );
                rs = v.ImageInformation.RaleSlope( i );
                ss = v.ImageInformation.ScaleSlope( i );
                wc = v.ImageInformation.WindowCenter( i );
                ww = v.ImageInformation.WindowWidth( i );
                
                fprintf( fid, '<Attribute Name="Rale Intercept" Tag="0x00281052" Type="Double">%2.6E</Attribute>\r\n', ri );
                fprintf( fid, '<Attribute Name="Rale Slope" Tag="0x00281053" Type="Double">%2.6E</Attribute>\r\n', rs );
                temp1 = sprintf( '%2.4E', ss );
                temp1( end  - 2 ) = [  ];
                fprintf( fid, '<Attribute Name="Scale Slope" Tag="0x2005100E" Type="Float">%s</Attribute>\r\n', temp1 );
                fprintf( fid, '<Attribute Name="Window Center" Tag="0x00281050" Type="Double">%2.6E</Attribute>\r\n', wc );
                fprintf( fid, '<Attribute Name="Window Width" Tag="0x00281051" Type="Double">%2.6E</Attribute>\r\n', ww );
                fprintf( fid, '<Attribute Name="Slice Thickness" Tag="0x00180050" Type="Double">%2.6E</Attribute>\r\n', v.ImageInformation.SliceThickness( i ) );
                fprintf( fid, '<Attribute Name="Slice Gap" Tag="0x00180088" Type="Double">%2.6E</Attribute>\r\n', v.ImageInformation.SliceGap( i ) );
                fprintf( fid, '<Attribute Name="Display Orientation" Tag="0x20051004" Type="Enumeration" EnumType="Display_Orientation">%s</Attribute>\r\n', strtrim( v.ImageInformation.DisplayOrientation( i, : ) ) );
                fprintf( fid, '<Attribute Name="fMRI Status Indication" Tag="0x20051063" Type="Int16">%d</Attribute>\r\n', v.ImageInformation.fMRIStatusIndication( i ) );
                fprintf( fid, '<Attribute Name="Image Type Ed Es" Tag="0x20011007" Type="Enumeration" EnumType="Type_ed_es">%s</Attribute>\r\n', strtrim( v.ImageInformation.ImageTypeEdEs( i, : ) ) );
                fprintf( fid, '<Attribute Name="Pixel Spacing" Tag="0x00280030" Type="Double" ArraySize="2">%4.6E %4.6E</Attribute>\r\n', v.ImageInformation.PixelSpacing( i, 1 ), v.ImageInformation.PixelSpacing( i, 2 ) );
                fprintf( fid, '<Attribute Name="Echo Time" Tag="0x00180081" Type="Double">%4.6E</Attribute>\r\n', v.ImageInformation.EchoTime( i ) );
                temp1 = sprintf( '%2.4E', v.ImageInformation.DynScanBeginTime( i ) );
                temp1( end  - 2 ) = [  ];
                fprintf( fid, '<Attribute Name="Dyn Scan Begin Time" Tag="0x200510A0" Type="Float">%s</Attribute>\r\n', temp1 );
                fprintf( fid, '<Attribute Name="Trigger Time" Tag="0x00181060" Type="Double">%4.6E</Attribute>\r\n', v.ImageInformation.TriggerTime( i ) );
                temp1 = sprintf( '%2.4E', v.ImageInformation.DiffusionBFactor( i ) );
                temp1( end  - 2 ) = [  ];
                fprintf( fid, '<Attribute Name="Diffusion B Factor" Tag="0x20011003" Type="Float">%s</Attribute>\r\n', temp1 );
                fprintf( fid, '<Attribute Name="No Averages" Tag="0x00180083" Type="Double">%4.6E</Attribute>\r\n', v.ImageInformation.NoAverages( i ) );
                fprintf( fid, '<Attribute Name="Image Flip Angle" Tag="0x00181314" Type="Double">%4.6E</Attribute>\r\n', v.ImageInformation.ImageFlipAngle( i ) );
                fprintf( fid, '<Attribute Name="Cardiac Frequency" Tag="0x00181088" Type="Int32">%d</Attribute>\r\n', v.ImageInformation.CardiacFrequency( i ) );
                fprintf( fid, '<Attribute Name="Min RR Interval" Tag="0x00181081" Type="Int32">%d</Attribute>\r\n', v.ImageInformation.MinRRInterval( i ) );
                fprintf( fid, '<Attribute Name="Max RR Interval" Tag="0x00181082" Type="Int32">%d</Attribute>\r\n', v.ImageInformation.MaxRRInterval( i ) );
                fprintf( fid, '<Attribute Name="TURBO Factor" Tag="0x00180091" Type="Int32">%d</Attribute>\r\n', v.ImageInformation.TURBOFactor( i ) );
                fprintf( fid, '<Attribute Name="Inversion Delay" Tag="0x00180082" Type="Double">%4.6E</Attribute>\r\n', v.ImageInformation.InversionDelay( i ) );
                fprintf( fid, '<Attribute Name="Contrast Type" Tag="0x00089209" Type="String">%s</Attribute>\r\n', strtrim( v.ImageInformation.ContrastType( i, : ) ) );
                fprintf( fid, '<Attribute Name="Diffusion Anisotropy Type" Tag="0x00189147" Type="String">%s</Attribute>\r\n', strtrim( v.ImageInformation.DiffusionAnisotropyType( i, : ) ) );
                temp1 = sprintf( '%2.4E', v.ImageInformation.DiffusionAP( i ) );
                temp1( end  - 2 ) = [  ];
                fprintf( fid, '<Attribute Name="Diffusion AP" Tag="0x200510B1" Type="Float">%s</Attribute>\r\n', temp1 );
                temp1 = sprintf( '%2.4E', v.ImageInformation.DiffusionFH( i ) );
                temp1( end  - 2 ) = [  ];
                fprintf( fid, '<Attribute Name="Diffusion FH" Tag="0x200510B2" Type="Float">%s</Attribute>\r\n', temp1 );
                temp1 = sprintf( '%2.4E', v.ImageInformation.DiffusionRL( i ) );
                temp1( end  - 2 ) = [  ];
                fprintf( fid, '<Attribute Name="Diffusion RL" Tag="0x200510B0" Type="Float">%s</Attribute>\r\n', temp1 );
                fprintf( fid, '<Attribute Name="Angulation AP" Type="Double" Calc="AngulationAP">%4.6E</Attribute>\r\n', v.ImageInformation.AngulationAP( i ) );
                fprintf( fid, '<Attribute Name="Angulation FH" Type="Double" Calc="AngulationFH">%4.6E</Attribute>\r\n', v.ImageInformation.AngulationFH( i ) );
                fprintf( fid, '<Attribute Name="Angulation RL" Type="Double" Calc="AngulationRL">%4.6E</Attribute>\r\n', v.ImageInformation.AngulationRL( i ) );
                fprintf( fid, '<Attribute Name="Offcenter AP" Type="Double" Calc="OffcenterAP">%4.6E</Attribute>\r\n', v.ImageInformation.OffcenterAP( i ) );
                fprintf( fid, '<Attribute Name="Offcenter FH" Type="Double" Calc="OffcenterFH">%4.6E</Attribute>\r\n', v.ImageInformation.OffcenterFH( i ) );
                fprintf( fid, '<Attribute Name="Offcenter RL" Type="Double" Calc="OffcenterRL">%4.6E</Attribute>\r\n', v.ImageInformation.OffcenterRL( i ) );
                fprintf( fid, '<Attribute Name="Slice Orientation" Type="Enumeration" Calc="SliceOrient" EnumType="Slice_Orientation">%s</Attribute>\r\n', strtrim( v.ImageInformation.SliceOrientation( i, : ) ) );
                fprintf( fid, '</Image_Info>\r\n' );
                
            end
            
            fprintf( fid, '</Image_Array>\r\n' );
            fprintf( fid, '</PRIDE_V5>\r\n' );
            
            MR.Data = MR.UnconvertCell( MR.Data );
            MR.Parameter.Recon.AutoUpdateInfoPars = auto_update_status;
            
            fclose( fid );
        end
        function WriteCpx( MR, Filename )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if nargin == 1
                Filename = 'recon.cpx';
            end
            
            MR.Parameter.UpdateImageInfo = 0;
            MR.DataClass.Convert2Cell;
            MR.Parameter.UpdateImageInfo = 1;
            
            switch class( MR.Data{ 1 } )
                case ( 'double' )
                    compression = 1;
                case ( 'single' )
                    compression = 1;
                otherwise
                    MR.Data = single( MR.Data );
                    compression = 1;
            end
            
            fid = fopen( Filename, 'w' );
            
            h1 = zeros( 15, 1 );
            h2 = zeros( 15, 1 );
            skip = zeros( 384, 1 );
            
            for m = 1:size( MR.Data, 2 )
                siz = ones( 1, 12 );
                siz( 1:ndims( MR.Data{ 1, m } ) ) = size( MR.Data{ 1, m } );
                
                res_x = siz( 1 );
                res_y = siz( 2 );
                data_slice = zeros( ceil( res_x * res_y * 8 / 512 ) * 512 / 8 * 2, 1 );
                
                siz = siz( 3:end  );
                total_nr_images = size( MR.Data{ 1, m }( :, :, : ), 3 );
                
                for i = 1:total_nr_images
                    sub = MR.ind2sub( siz, i );
                    
                    
                    if size( MR.Data, 2 ) == 1
                        real_mix = sub( 7 );
                    else
                        real_mix = m;
                    end
                    
                    slice = sub( 1 );
                    chan = sub( 2 );
                    dyn = sub( 3 );
                    card = sub( 4 );
                    echo = sub( 5 );
                    loca = siz( 6 ) * ( real_mix - 1 ) + sub( 6 );
                    extr1 = sub( 8 );
                    extr2 = siz( 9 ) * ( sub( 10 ) - 1 ) + sub( 9 );
                    
                    h1( 2 ) = loca;
                    h1( 3 ) = slice;
                    h2( 2 ) = chan;
                    h1( 6 ) = card;
                    h1( 5 ) = echo;
                    h1( 7 ) = dyn;
                    h1( 8 ) = extr1;
                    h2( 1 ) = extr2;
                    
                    h1( 11 ) = res_x;
                    h1( 12 ) = res_y;
                    h1( 14 ) = compression;
                    h1( 9 ) = 1;
                    h1( 13 ) = ceil( res_x * res_y * 8 / 512 );
                    h1( 10 ) = ftell( fid ) + 512;
                    
                    fwrite( fid, h1, 'long' );
                    fwrite( fid, 0, 'float' );
                    fwrite( fid, 0, 'float' );
                    fwrite( fid, h2, 'long' );
                    fwrite( fid, skip, 'char' );
                    
                    data_slice1 = MR.Data{ 1, m }( :, :, i );
                    data_slice1 = reshape( data_slice1, res_x * res_y, 1 );
                    data_slice( 1:2:2 * length( data_slice1 ) ) = real( data_slice1 );
                    data_slice( 2:2:2 * length( data_slice1 ) ) = imag( data_slice1 );
                    fwrite( fid, data_slice, 'float' );
                    
                end
            end
            
            
            h1( 9 ) = 0;
            fwrite( fid, h1, 'long' );
            fwrite( fid, 0, 'float' );
            fwrite( fid, 0, 'float' );
            fwrite( fid, h2, 'long' );
            fwrite( fid, skip, 'char' );
            
            fclose( fid );
        end
        function ExportLabels( MR, Filename )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if ~MR.Parameter.ReconFlags.isreadparameter
                error( 'Please read the parameter file first' );
            end
            
            if nargin == 1
                Filename = 'labels.list';
            end
            MR.export_labels( MR, Filename );
        end
        function WriteDICOM( MR, OutputDirectory )
            
            if isempty( MR.Data )
                error( 'Error in WriteDICOM: The data matrix is empty. Please reconstruct the data first' );
            end
            
            if isempty( MR.Parameter.Par40 )
                warning( 'The dataset was measured with the old ReconFrame patch. Some DICOM tags will be missing' );
            else
                if ( ~MR.Parameter.IsParameter( 'RFR_EXAM_OBJECT_OID' ) )
                    warning( 'DICOM export on release 3 data is not fully supported. Some DICOM tags will be missing' );
                end
            end
            
            if nargin == 1
                OutputDirectory = cd;
            end
            
            slashind = [ strfind( MR.Parameter.Filename.Data, '\' ), strfind( MR.Parameter.Filename.Data, '/' ) ];
            dotind = strfind( MR.Parameter.Filename.Data, '.' );
            if isempty( slashind )
                slashind = 1;
            end
            if isempty( dotind )
                dotind = length( MR.Parameter.Filename.Data );
            end
            dataset_name = MR.Parameter.Filename.Data( slashind( end  ) + 1:dotind( end  ) - 1 );
            
            par = MR.WritePar2String;
            rec = MR.GetRecImages;
            for i = 1:length( par )
                Parfile{ i } = MR.Parameter.parread_from_string( par{ i } );
            end
            D = DICOMExporter;
            
            if ( ~isdir( [ OutputDirectory, filesep, dataset_name ] ) )
                try
                    mkdir( OutputDirectory, dataset_name );
                catch
                    error( [ 'cannot create the directory: ', OutDir, filesep, 'DICOM' ] );
                end
            end
            
            OutputDirectory = [ OutputDirectory, filesep, dataset_name ];
            if ( isempty( MR.Parameter.Par40 ) )
                D.Export( OutputDirectory, rec, Parfile );
            else
                D.Export( OutputDirectory, rec, Parfile, MR.Parameter.Par40 );
            end
        end
        
        
        
        
        function SortData( MR )
            if ~MR.Parameter.ReconFlags.isread
                error( 'Please read the data first' );
            end
            if MR.Parameter.ReconFlags.issorted
                error( 'The data is already sorted' );
            end
            
            AverageIdenticalProfs = any( strcmpi( MR.Parameter.Cardiac.Synchronization, { 'retro', 'retrospective' } ) );
            ImmediateAveraging = strcmpi( MR.Parameter.Recon.ImmediateAveraging, 'yes' ) && strcmpi( MR.Parameter.Recon.Average, 'yes' );
            
            if ~isempty( MR.Data )
                MR.Parameter.UpdateImageInfo = 0;
                MR.Data = MR.Convert2Cell( MR.Data );
                
                MR.Parameter.LabelLookupTable = MR.Convert2Cell( MR.Parameter.LabelLookupTable );
                
                NoZeroPad( 1 ) = any( strcmpi( MR.Parameter.Scan.AcqMode, { 'Radial', 'Spiral' } ) );
                
                
                NoZeroPad( 2 ) = ( strcmpi( MR.Parameter.Scan.AcqMode, 'Radial' ) && strcmpi( MR.Parameter.Scan.KooshBall, 'yes' ) );
                
                
                
                if MR.Parameter.Labels.Spectro && any( strcmpi( MR.Parameter.Scan.AcqMode, { 'Radial', 'Spiral' } ) )
                    NoZeroPad( : ) = 1;
                end
                
                
                if isfield( MR.Parameter.Labels, 'Samples' )
                    samples = MR.Parameter.Labels.Samples( 1, : );
                    ovs = cellfun( @( x, y, z )[ max( [ x, 1 ] ), max( [ y, 1 ] ), max( [ z, 1 ] ) ], MR.Parameter.Encoding.WorkEncoding.KxOversampling, MR.Parameter.Encoding.WorkEncoding.KyOversampling, MR.Parameter.Encoding.WorkEncoding.KzOversampling, 'UniformOutput', 0 );
                    samples = cellfun( @( x )round( x .* samples ), ovs, 'UniformOutput', 0 );
                else
                    samples = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.KxOversampling, 'UniformOutput', 0 );
                end
                FixedKyRange = ~isfield( MR.Parameter.Labels, 'KxRange' );
                
                [ MR.Parameter.Encoding.WorkEncoding, MR.Parameter.LabelLookupTable ] = MRecon.check_cell_sizes( MR.Parameter.Encoding.WorkEncoding, MR.Parameter.LabelLookupTable, MR.Data );
                
                
                
                ky_outside_range = ~NoZeroPad( 1 ) && ( any( any( cellfun( @( x, y )max( [ min( MR.Parameter.Labels.Index.ky( x ) ) < min( y ), 0 ] ) > 0, MR.Parameter.LabelLookupTable, MR.Parameter.Encoding.WorkEncoding.KyRange ) ) ) ||  ...
                    any( any( cellfun( @( x, y )max( [ max( MR.Parameter.Labels.Index.ky( x ) ) > max( y ), 0 ] ) > 0, MR.Parameter.LabelLookupTable, MR.Parameter.Encoding.WorkEncoding.KyRange ) ) ) );
                if ( ky_outside_range )
                    error( 'The ky-labels (Parameter.Labels.Index.ky) are outside the ky-range (r.Parameter.Encoding.KyRange). Please adapt your parameters' );
                end
                kz_outside_range = ~NoZeroPad( 2 ) && ( any( any( cellfun( @( x, y )max( [ min( MR.Parameter.Labels.Index.kz( x ) ) < min( y ), 0 ] ) > 0, MR.Parameter.LabelLookupTable, MR.Parameter.Encoding.WorkEncoding.KzRange ) ) ) ||  ...
                    any( any( cellfun( @( x, y )max( [ max( MR.Parameter.Labels.Index.kz( x ) ) > max( y ), 0 ] ) > 0, MR.Parameter.LabelLookupTable, MR.Parameter.Encoding.WorkEncoding.KzRange ) ) ) );
                if ( kz_outside_range )
                    error( 'The kz-labels (Parameter.Labels.Index.kz) are outside the kz-range (r.Parameter.Encoding.KzRange). Please adapt your parameter' );
                end
                
                if ( ismac )
                    [ MR.Data, MR.Parameter.LabelLookupTable ] = cellfun( @( x, y, z, u, v, w )MR.SortExportedRaw( x, MR.Parameter.Labels, y, z, u, v, w, NoZeroPad, AverageIdenticalProfs, ImmediateAveraging ),  ...
                        MR.Data, MR.Parameter.LabelLookupTable,  ...
                        MR.Parameter.Encoding.WorkEncoding.KyRange, MR.Parameter.Encoding.WorkEncoding.KzRange,  ...
                        MR.Parameter.Encoding.WorkEncoding.KyOversampling, MR.Parameter.Encoding.WorkEncoding.KzOversampling, 'UniformOutput', false );
                else
                    if any( strcmpi( MR.Parameter.Cardiac.Synchronization, { 'retro', 'retrospective' } ) )
                        switch MR.Parameter.Cardiac.RetroHoleInterpolation
                            case { 'Nearest', 'nearest' }
                                AverageIdenticalProfs = 0;
                            case { 'Average', 'average' }
                                AverageIdenticalProfs = 1;
                            case { 'Linear', 'linear', 'Cubic', 'cubic' }
                                AverageIdenticalProfs = 2;
                            otherwise
                                AverageIdenticalProfs = 0;
                        end
                    else
                        AverageIdenticalProfs = 1;
                    end
                    [ MR.Data, MR.Parameter.LabelLookupTable ] = cellfun( @( x, y, z, u, v, w, s )sort_data( x, y, MR.Parameter.Labels.Index, z, u, v, w, s, NoZeroPad, AverageIdenticalProfs, ImmediateAveraging, FixedKyRange ),  ...
                        MR.Data, MR.Parameter.LabelLookupTable,  ...
                        MR.Parameter.Encoding.WorkEncoding.KyRange, MR.Parameter.Encoding.WorkEncoding.KzRange,  ...
                        MR.Parameter.Encoding.WorkEncoding.KyOversampling, MR.Parameter.Encoding.WorkEncoding.KzOversampling, samples, 'UniformOutput', false );
                end
                MR.Parameter.UpdateImageInfo = 1;
                MR.Data = MR.UnconvertCell( MR.Data );
                MR.Parameter.LabelLookupTable = MR.UnconvertCell( MR.Parameter.LabelLookupTable );
                
            end
            MR.Parameter.ReconFlags.issorted = 1;
            
            if ImmediateAveraging
                MR.Parameter.ReconFlags.isaveraged = 1;
            end
            
            
        end
        
        
        
        function RandomPhaseCorrection( MR )
            if strcmpi( MR.Parameter.Recon.RandomPhaseCorrection, 'yes' ) &&  ...
                    strcmpi( MR.Parameter.Recon.ArrayCompression, 'no' ) &&  ...
                    strcmpi( MR.Parameter.DataFormat, 'raw' )
                
                if ~MR.Parameter.ReconFlags.isread
                    error( 'Error in Random Phase Correction: Please read the data first' );
                end
                if MR.Parameter.ReconFlags.ispartialfourier
                    error( 'Error in Random Phase Correction: The random phase correction has to be applied before the partial fourier reconstruction' );
                end
                if MR.Parameter.ReconFlags.israndphasecorr
                    error( 'Error in Random Phase Correction: The data is already random-phase corrected' );
                end
                if any( MR.Parameter.ReconFlags.isimspace )
                    error( 'Error in Random Phase Correction: The random phase correction has to be applied in k-space' );
                end
                
                if ~isempty( MR.Data )
                    
                    MR.Parameter.UpdateImageInfo = 0;
                    MR.DataClass.Convert2Cell;
                    
                    MR.Parameter.LabelLookupTable = MR.Convert2Cell( MR.Parameter.LabelLookupTable );
                    
                    
                    
                    if ( isfield( MR.Parameter.Labels, 'FEARFactor' ) && MR.Parameter.Labels.FEARFactor > 0 )
                        if ~MR.Parameter.ReconFlags.isoversampled( 1 )
                            error( 'Error in Random Phase Correction: The RandomPhaseCorrection must be performed before RemoveOversampling for release 5 data and higher' );
                        end
                        
                        center_k = MR.Parameter.Encoding.WorkEncoding.FEARCenterK;
                        radial_spiral = any( strcmpi( MR.Parameter.Scan.AcqMode, { 'radial', 'spiral' } ) ) || strcmpi( MR.Parameter.Gridder.Preset, 'radial' );
                        if ( radial_spiral )
                            center_k = cellfun( @( x )[  ], center_k, 'UniformOutput', 0 );
                        end
                        
                        MR.Data = cellfun( @( x, y, z, u )MR.fear_corr( x, MR.Parameter.Labels, y, z, u ),  ...
                            MR.Data, MR.Parameter.LabelLookupTable, MR.Parameter.Encoding.WorkEncoding.FEARFactor, center_k, 'UniformOutput', false );
                    else
                        MR.Data = cellfun( @( x, y )MR.random_phase_corr( x, MR.Parameter.Labels, y ),  ...
                            MR.Data, MR.Parameter.LabelLookupTable, 'UniformOutput', false );
                    end
                    
                    [ MR.Parameter.Encoding.WorkEncoding, MR.Parameter.LabelLookupTable ] = MRecon.check_cell_sizes( MR.Parameter.Encoding.WorkEncoding, MR.Parameter.LabelLookupTable, MR.Data );
                    
                    
                    
                    
                    MR.Parameter.UpdateImageInfo = 1;
                    MR.Data = MR.UnconvertCell( MR.Data );
                    
                    MR.Parameter.LabelLookupTable = MR.UnconvertCell( MR.Parameter.LabelLookupTable );
                end
                MR.Parameter.ReconFlags.israndphasecorr = 1;
                
            end
        end
        function MeasPhaseCorrection( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if strcmpi( MR.Parameter.Recon.MeasPhaseCorrection, 'yes' ) &&  ...
                    strcmpi( MR.Parameter.Recon.ArrayCompression, 'no' ) &&  ...
                    strcmpi( MR.Parameter.DataFormat, 'raw' )
                
                if ~MR.Parameter.ReconFlags.isread
                    error( 'Error in Measurement Phase Correction: Please read the data first' );
                end
                if any( MR.Parameter.ReconFlags.isimspace )
                    error( 'Error in Measurement Phase Correction: The random phase correction has to be applied in k-space' );
                end
                if MR.Parameter.ReconFlags.ismeasphasecorr
                    error( 'Error in Measurement Phase Correction: The data is already measurement-phase corrected' );
                end
                if MR.Parameter.ReconFlags.issorted && strcmpi( MR.Parameter.Recon.ImmediateAveraging, 'yes' )
                    error( 'Error in Measurement Phase Correction: Please apply the measurement before averaging the data. Either perform it before SortData or switch immediate averaging off in Parameter.Recon.ImmediateAveraging' );
                end
                
                if ( MR.Parameter.Labels.Spectro == 1 )
                    warning( 'Running the measurement phase correction on spectro data is not recommended. The spectra quality might suffer considerably' );
                end
                
                if ~isempty( MR.Data )
                    MR.Parameter.UpdateImageInfo = 0;
                    MR.DataClass.Convert2Cell;
                    
                    MR.Parameter.LabelLookupTable = MR.Convert2Cell( MR.Parameter.LabelLookupTable );
                    
                    [ MR.Parameter.Encoding.WorkEncoding, MR.Parameter.LabelLookupTable ] = MRecon.check_cell_sizes( MR.Parameter.Encoding.WorkEncoding, MR.Parameter.LabelLookupTable, MR.Data );
                    
                    MR.Data = cellfun( @( x, y )MR.meas_phase_corr( x, MR.Parameter.Labels, y ),  ...
                        MR.Data, MR.Parameter.LabelLookupTable, 'UniformOutput', false );
                    
                    
                    
                    
                    
                    MR.Parameter.UpdateImageInfo = 1;
                    MR.Data = MR.UnconvertCell( MR.Data );
                    
                    MR.Parameter.LabelLookupTable = MR.UnconvertCell( MR.Parameter.LabelLookupTable );
                    
                end
                MR.Parameter.ReconFlags.ismeasphasecorr = 1;
            end
        end
        function DcOffsetCorrection( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if strcmpi( MR.Parameter.Recon.DcOffsetCorrection, 'yes' ) &&  ...
                    strcmpi( MR.Parameter.Recon.ArrayCompression, 'no' ) &&  ...
                    strcmpi( MR.Parameter.DataFormat, 'raw' )
                
                if ~MR.Parameter.ReconFlags.isread
                    error( 'Error in DC Offset Correction: Please read the data first' );
                end
                if MR.Parameter.ReconFlags.ispartialfourier
                    error( 'Error in DC Offset Correction: The DC Offset correction has to be applied before the partial fourier reconstruction' );
                end
                if MR.Parameter.ReconFlags.isdcoffsetcorr
                    error( 'Error in DC Offset Correction: The data is already DC Offset corrected' );
                end
                if any( MR.Parameter.ReconFlags.isimspace )
                    error( 'Error in DC OffsetA Correction: The DC Offset correction has to be applied in k-space' );
                end
                
                if ~isempty( MR.Data )
                    if isempty( MR.MeanNoise )
                        MR.MeanNoise = MR.get_mean_noise( MR.Parameter.Filename,  ...
                            MR.Parameter.DataType, MR.Parameter.Labels );
                    end
                    
                    MR.Parameter.UpdateImageInfo = 0;
                    MR.DataClass.Convert2Cell;
                    
                    MR.Parameter.LabelLookupTable = MR.Convert2Cell( MR.Parameter.LabelLookupTable );
                    
                    [ MR.Parameter.Encoding.WorkEncoding, MR.Parameter.LabelLookupTable ] = MRecon.check_cell_sizes( MR.Parameter.Encoding.WorkEncoding, MR.Parameter.LabelLookupTable, MR.Data );
                    
                    MR.Data = cellfun( @( x, y, z )MR.dc_offset_corr( x, MR.MeanNoise, MR.Parameter.Labels, y, z, MR.Parameter.ReconFlags.ispdacorr ),  ...
                        MR.Data, MR.Parameter.Encoding.WorkEncoding.KxRange, MR.Parameter.LabelLookupTable, 'UniformOutput', false );
                    
                    
                    
                    
                    MR.Parameter.UpdateImageInfo = 1;
                    MR.Data = MR.UnconvertCell( MR.Data );
                    
                    MR.Parameter.LabelLookupTable = MR.UnconvertCell( MR.Parameter.LabelLookupTable );
                    
                end
                MR.Parameter.ReconFlags.isdcoffsetcorr = 1;
            end
        end
        function PDACorrection( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if strcmpi( MR.Parameter.Recon.PDACorrection, 'yes' ) &&  ...
                    strcmpi( MR.Parameter.Recon.ArrayCompression, 'no' ) &&  ...
                    strcmpi( MR.Parameter.DataFormat, 'raw' ) &&  ...
                    isfield( MR.Parameter.Labels, 'PDAFactors' ) &&  ...
                    ~all( MR.Parameter.Labels.PDAFactors == 0 )
                
                if ~MR.Parameter.ReconFlags.isread
                    error( 'Error in PDA Correction: Please read the data first' );
                end
                if MR.Parameter.ReconFlags.ispartialfourier
                    error( 'Error in PDA Correction: The PDA correction has to be applied before the partial fourier reconstruction' );
                end
                if MR.Parameter.ReconFlags.ispdacorr
                    error( 'Error in PDA Correction: The data is already PDA corrected' );
                end
                if any( MR.Parameter.ReconFlags.isimspace )
                    error( 'Error in PDA Correction: The PDA correction has to be applied in k-space' );
                end
                
                if ~isempty( MR.Data )
                    MR.Parameter.UpdateImageInfo = 0;
                    MR.DataClass.Convert2Cell;
                    
                    MR.Parameter.LabelLookupTable = MR.Convert2Cell( MR.Parameter.LabelLookupTable );
                    
                    [ MR.Parameter.Encoding.WorkEncoding, MR.Parameter.LabelLookupTable ] = MRecon.check_cell_sizes( MR.Parameter.Encoding.WorkEncoding, MR.Parameter.LabelLookupTable, MR.Data );
                    
                    MR.Data = cellfun( @( x, y )MR.pda_corr( x, MR.Parameter.Labels, y ),  ...
                        MR.Data, MR.Parameter.LabelLookupTable, 'UniformOutput', false );
                    
                    
                    
                    
                    MR.Parameter.UpdateImageInfo = 1;
                    MR.Data = MR.UnconvertCell( MR.Data );
                    
                    MR.Parameter.LabelLookupTable = MR.UnconvertCell( MR.Parameter.LabelLookupTable );
                    
                end
                MR.Parameter.ReconFlags.ispdacorr = 1;
            end
        end
        function EPIPhaseCorrection( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if strcmpi( MR.Parameter.Recon.EPIPhaseCorrection, 'yes' )
                
                if ~isempty( MR.Data )
                    if ~MR.Parameter.ReconFlags.issorted
                        error( 'Please sort the data first' );
                    end
                    if ~MR.Parameter.ReconFlags.isimspace( 1 )
                        error( 'Please fourier transform the data along the measurement direction first' );
                    end
                    
                    if any( strcmpi( MR.Parameter.DataFormat, { 'Raw', 'Bruker' } ) ) &&  ...
                            any( strcmpi( MR.Parameter.Scan.FastImgMode, { 'EPI', 'TFEEPI', 'TFEPI' } ) )
                        if MR.Parameter.ReconFlags.isdepicorr
                            error( 'The data is already EPI-phase corrected' );
                        end
                        
                        
                        
                        
                        
                        recalculate_EPI_corr = ~( MR.Parameter.EPICorrData.coil_changed ||  ...
                            MR.Parameter.EPICorrData.loca_changed ||  ...
                            MR.Parameter.EPICorrData.offset_changed ||  ...
                            MR.Parameter.EPICorrData.slope_changed ||  ...
                            MR.Parameter.EPICorrData.corr_factors_changed );
                        
                        if recalculate_EPI_corr
                            if isempty( MR.MeanNoise )
                                MR.MeanNoise = MR.get_mean_noise( MR.Parameter.Filename, MR.Parameter.DataType, MR.Parameter.Labels );
                            end
                            
                            
                            
                            isocenterMPS = MR.Transform( [ 0, 0, 0 ], 'xyz', 'ijk', 1 );
                            
                            ACMatrix = [  ];
                            if strcmpi( MR.Parameter.Recon.ArrayCompression, 'yes' )
                                ACMatrix = MR.Parameter.Recon.ACMatrix;
                            end
                            
                            epi_corr_data = MR.get_epi_corr_data( MR.Parameter.Filename, MR.Parameter.DataType,  ...
                                MR.Parameter.Labels, MR.Parameter.Gridder.WorkingPars, MR.Parameter.Encoding,  ...
                                MR.Parameter.LabelLookupTable, MR.Data,  ...
                                MR.Parameter.ReconFlags.isgridded, MR.Parameter.ReconFlags.iszerofilled( 1 ),  ...
                                ~MR.Parameter.ReconFlags.isoversampled( 1 ), strcmpi( MR.Parameter.Recon.EPI2DCorr, 'yes' ),  ...
                                strcmpi( MR.Parameter.Recon.EPICorrectionMethod, 'Linear' ), isocenterMPS, ACMatrix,  ...
                                strcmpi( MR.Parameter.Recon.EPICorrPerLocation, 'yes' ) );
                            
                            MR.Parameter.SetEpiCorrData( epi_corr_data );
                        else
                            warning( 'The EPI correction parameters are not recalculated because they were manually set. If you want them to be recalculated call: r.Parameter.EpiCorrData.Reset' );
                        end
                        
                        MR.Parameter.UpdateImageInfo = 0;
                        MR.DataClass.Convert2Cell;
                        
                        if isempty( MR.Parameter.LabelLookupTable )
                            MR.Parameter.LabelLookupTable = cellfun( @( x )[  ], MR.Data, 'UniformOutput', 0 );
                        else
                            MR.Parameter.LabelLookupTable = MR.Convert2Cell( MR.Parameter.LabelLookupTable );
                        end
                        
                        if ~isempty( MR.Parameter.EPICorrData )
                            MR.Data = cellfun( @( x, y )MR.epi_corr( x, MR.Parameter.EPICorrData,  ...
                                MR.Parameter.Labels, y, strcmpi( MR.Parameter.Recon.EPICorrectionMethod, 'Linear' ),  ...
                                strcmpi( MR.Parameter.Recon.EPICorrPerLocation, 'yes' ) ),  ...
                                MR.Data, MR.Parameter.LabelLookupTable, 'UniformOutput', false );
                        end
                        
                        if recalculate_EPI_corr
                            MR.Parameter.EPICorrData.ResetFlags;
                        end
                        
                        MR.Parameter.UpdateImageInfo = 1;
                        MR.Data = MR.UnconvertCell( MR.Data );
                        
                        MR.Parameter.LabelLookupTable = MR.UnconvertCell( MR.Parameter.LabelLookupTable );
                        
                    elseif strcmpi( MR.Parameter.DataFormat, 'ExportedRaw' )
                        if any( strcmpi( MR.Parameter.Scan.FastImgMode, { 'EPI', 'TFEEPI' } ) )
                            
                            phx_profiles = ( MR.Parameter.Labels.Index.typ == 3 );
                            
                            sign = double( MR.Parameter.Labels.Index.sign( phx_profiles ) );
                            sign( sign ==  - 1 ) = 0;
                            signs = unique( sign );
                            MR.Parameter.Labels.Index.ky( phx_profiles ) = sign;
                            
                            
                            
                            [ corr_data, corr_data_ind ] = MRecon.ReadExportedRaw( MR, MR.Parameter.Parameter2Read_Original, 3, 0, 0, MR.Parameter.Encoding.KxRange( 1, : ) );
                            [ corr_data, corr_data_ind ] = MRecon.SortExportedRaw( corr_data, MR.Parameter.Labels, corr_data_ind, [ min( signs ), max( signs ) ], [ 0, 0 ], 1, 1, 1, 1, 1 );
                            corr_data = corr_data( end : - 1:1, :, :, :, : );
                            coils = MR.Parameter.Parameter2Read.chan;
                            data = MR.Data;
                            data_ind = MR.Parameter.LabelLookupTable;
                            for c = 1:size( MR.Data, 4 )
                                for si = [  - 1, 1 ]
                                    sign_ind = zeros( size( data_ind ) );
                                    sign_ind( data_ind ~= 0 ) = double( MR.Parameter.Labels.Index.sign( data_ind( data_ind ~= 0 ) ) ) == si &  ...
                                        double( MR.Parameter.Labels.Index.chan( data_ind( data_ind ~= 0 ) ) ) == coils( c );
                                    data( :, find( sign_ind ) ) = bsxfun( @times, data( :, find( sign_ind ) ), corr_data( :, ( si == 1 ) + 1, 1, c ) );
                                    
                                end
                            end
                            MR.Data = data;
                        end
                    end
                    
                end
                MR.Parameter.ReconFlags.isdepicorr = 1;
            end
        end
        function RingingFilter( MR )
            if strcmpi( MR.Parameter.Recon.RingingFilter, 'yes' )
                
                
                if ~MR.Parameter.ReconFlags.isread
                    error( 'Please read the data first' );
                end
                if ~MR.Parameter.ReconFlags.issorted
                    error( 'Please sort the data first' );
                end
                if any( MR.Parameter.ReconFlags.isimspace )
                    error( 'The ringing filter can only be applied in k-space' );
                end
                
                if ~isempty( MR.Data )
                    
                    
                    
                    
                    MR.Parameter.UpdateImageInfo = 0;
                    MR.DataClass.Convert2Cell;
                    
                    
                    
                    
                    
                    if strcmpi( MR.Parameter.Gridder.Preset, 'radial' )
                        for ci = 1:size( MR.Data, 1 )
                            for cj = 1:size( MR.Data, 2 )
                                if isempty( MR.Data{ ci, cj } )
                                    sampled_size{ ci, cj } = [  ];
                                    continue ;
                                end
                                sampled_size{ ci, cj } = [ min( [ size( MR.Data{ ci, cj }, 1 ), length( MR.Parameter.Encoding.WorkEncoding.KxRange{ ci, cj }( 1 ):MR.Parameter.Encoding.WorkEncoding.KxRange{ ci, cj }( 2 ) ) ] ),  ...
                                    min( [ size( MR.Data{ ci, cj }, 2 ), length( MR.Parameter.Encoding.WorkEncoding.KxRange{ ci, cj }( 1 ):MR.Parameter.Encoding.WorkEncoding.KxRange{ ci, cj }( 2 ) ) ] ) ];
                                if ~isempty( MR.Parameter.Encoding.WorkEncoding.KzRange{ ci, cj } )
                                    sampled_size{ ci, cj } = [ sampled_size{ ci, cj },  ...
                                        length( MR.Parameter.Encoding.WorkEncoding.KzRange{ ci, cj }( 1 ):MR.Parameter.Encoding.WorkEncoding.KzRange{ ci, cj }( 2 ) ) ];
                                else
                                    sampled_size{ ci, cj } = [ sampled_size{ ci, cj }, 1 ];
                                end
                            end
                        end
                        
                    else
                        sampled_size = cell( size( MR.Data ) );
                    end
                    
                    MR.Data = cellfun( @( x, y )MR.hamming_filter( x, MR.Parameter.Recon.RingingFilterStrength, y ), MR.Data, sampled_size, 'UniformOutput', 0 );
                    
                    
                    MR.Parameter.UpdateImageInfo = 1;
                    MR.Data = MR.UnconvertCell( MR.Data );
                end
                
            end
        end
        function ConcomitantFieldCorrection( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if strcmpi( MR.Parameter.Recon.ConcomitantFieldCorrection, 'yes' )
                if isfield( MR.Parameter.Labels, 'ConcomFactors' ) &&  ...
                        any( MR.Parameter.Labels.ConcomFactors ~= 0 )
                    
                    if any( ~MR.Parameter.ReconFlags.isimspace )
                        error( 'Error in ConcomitantFieldCorrection: The ConcomitantFieldCorrection has to be performed in image space' );
                    end
                    if MR.Parameter.ReconFlags.isconcomcorrected
                        error( 'Error in GeometryCorrection: The data is already concomitant field corrected' );
                    end
                    
                    MR.DataClass.Convert2Cell;
                    
                    A = MR.Transform( 'ijk', 'xyz' );
                    stacks_read = MR.Parameter.Parameter2Read.loca;
                    if isfield( MR.Parameter.Labels, 'StackIndex' )
                        stacks = MR.Parameter.Labels.StackIndex( stacks_read + 1 );
                    end
                    
                    MR.Data( 1, : ) = cellfun( @( x )MRecon.concom_corr( x, A, MR.Parameter.Labels.ConcomFactors, stacks, MR.Parameter.Parameter2Read.extr1, single( MR.Parameter.Labels.GeoCorrPars ) ),  ...
                        MR.Data( 1, : ), 'UniformOutput', 0 );
                    
                    MR.Data = MR.UnconvertCell( MR.Data );
                    MR.Parameter.ReconFlags.isconcomcorrected = 1;
                end
            end
        end
        function GeometryCorrection( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if ~isempty( MR.Data ) && strcmpi( MR.Parameter.Recon.GeometryCorrection, 'yes' )
                if ~isfield( MR.Parameter.Labels, 'GeoCorrPars' )
                    warning( 'MATLAB:MRecon', 'Cannot execute the geometry correction. Not enough parameter. Please update the scanner patch' );
                    return ;
                end
                if any( ~MR.Parameter.ReconFlags.isimspace )
                    error( 'Error in GeometryCorrection: The data must be in image-space' );
                end
                if MR.Parameter.ReconFlags.isgeocorrected
                    error( 'Error in GeometryCorrection: The data is already geometry corrected' );
                end
                
                if ~isempty( MR.Parameter.Scan.ijk ) && ~isempty( MR.Parameter.Scan.xyz )
                    if isfield( MR.Parameter.Labels, 'StackIndex' )
                        try
                            stack_nr = MR.Parameter.Labels.StackIndex( MR.Parameter.Parameter2Read.loca + 1 );
                        catch
                            stack_nr = [  ];
                        end
                    else
                        stack_nr = [  ];
                    end
                    
                    MR.Parameter.UpdateImageInfo = 0;
                    MR.DataClass.Convert2Cell;
                    
                    MR.Data = cellfun( @( x )MR.geometry_correction( x, MR.Parameter, stack_nr ),  ...
                        MR.Data, 'UniformOutput', 0 );
                    
                    MR.Parameter.UpdateImageInfo = 1;
                    MR.Data = MR.UnconvertCell( MR.Data );
                    MR.Parameter.ReconFlags.isgeocorrected = 1;
                end
            end
        end
        function FlowPhaseCorrection( MR )
            if ~isempty( MR.Data ) && strcmpi( MR.Parameter.Recon.FlowPhaseCorrection, 'yes' )
                if any( ~MR.Parameter.ReconFlags.isimspace )
                    error( 'Error in FlowPhaseCorrection: The FlowPhaseCorrection has to be performed in image space' );
                end
                
                if ~isempty( MR.Parameter.Scan.Venc ) &&  ...
                        any( any( MR.Parameter.Scan.Venc ) ~= 0 ) &&  ...
                        strcmpi( MR.Parameter.Recon.CoilCombination, 'pc' )
                    
                    MR.DataClass.Convert2Cell;
                    MR.Data( 1, : ) = cellfun( @( x )MRecon.fit_flow_phase( x ), MR.Data( 1, : ), 'UniformOutput', 0 );
                    MR.Data = MR.UnconvertCell( MR.Data );
                end
            end
        end
        
        
        
        
        function GridData( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if strcmpi( MR.Parameter.Recon.Gridding, 'yes' )
                if ~MR.Parameter.ReconFlags.issorted && ~strcmpi( MR.Parameter.Gridder.Preset, 'Epi' )
                    error( 'Error in Gridder: Please sort the data first' );
                end
                if MR.Parameter.ReconFlags.isgridded
                    error( 'Error in Gridder: The data is already gridded' );
                end
                if any( MR.Parameter.ReconFlags.isimspace )
                    error( 'Error in Gridder: Please grid the data in k-space' );
                end
                
                if any( strcmpi( MR.Parameter.Gridder.Preset, { 'Radial', 'Spiral', 'Epi', 'Cartesian' } ) ) || ~isempty( MR.Parameter.Gridder.Kpos )
                    if ~isempty( MR.Data )
                        MR.DataClass.Convert2Cell;
                        MR.Parameter.LabelLookupTable = MR.Convert2Cell( MR.Parameter.LabelLookupTable );
                        [ MR.Parameter.Encoding.WorkEncoding, MR.Parameter.LabelLookupTable ] = MRecon.check_cell_sizes( MR.Parameter.Encoding.WorkEncoding, MR.Parameter.LabelLookupTable, MR.Data );
                        
                        MR.Parameter.UpdateImageInfo = 0;
                        
                        MR.Parameter.Gridder.InitWorkingPars( size( MR.Data, 2 ) );
                        
                        for cell_index = 1:size( MR.Data, 2 )
                            MR.Parameter.Gridder.AssignWorkingPars( cell_index );
                            
                            if ~strcmpi( MR.Parameter.Gridder.WorkingPars{ cell_index }.Preset, 'none' )
                                grid_ovs = [  ];
                                
                                if isempty( MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos )
                                    if isfield( MR.Parameter.Labels, 'NusEncNrs' )
                                        nus_enc_nrs = MR.Parameter.Labels.NusEncNrs;
                                        if size( nus_enc_nrs, 1 ) < size( nus_enc_nrs, 2 )
                                            nus_enc_nrs = nus_enc_nrs;
                                        end
                                    else
                                        nus_enc_nrs = [  ];
                                    end
                                    [ MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos, grid_ovs, MR.Parameter.Gridder.WorkingPars{ cell_index }.RadialAngles ] =  ...
                                        MR.calculate_trajectory( MR.Data{ 1, cell_index }, MR.Parameter.Encoding.WorkEncoding.KxOversampling{ cell_index }, MR.Parameter.Encoding.WorkEncoding.KxRange{ 1, cell_index }, MR.Parameter.Gridder.WorkingPars{ cell_index }, nus_enc_nrs, MR.Parameter.Scan.SENSEFactor );
                                else
                                    if ndims( MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos ) < 4 || ( size( MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos, 4 ) ~= 3 )
                                        error( 'Error in Gridder: Parameter.Gridder.Kpos has to be a 4-dimensional matrix of size no_samples x no_profiles x no_slices x 3' );
                                    end
                                end
                                
                                if isempty( MR.Parameter.Gridder.WorkingPars{ cell_index }.GridOvsFactor )
                                    MR.Parameter.Gridder.WorkingPars{ cell_index }.GridOvsFactor = grid_ovs;
                                end
                                
                                if isempty( MR.Parameter.Gridder.WorkingPars{ cell_index }.Weights )
                                    MR.Parameter.Gridder.WorkingPars{ cell_index }.Weights = MR.calculate_weights( MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos, MR.Parameter.Gridder.WorkingPars{ cell_index } );
                                end
                                
                            end
                            
                            if ~isempty( MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos )
                                
                                if isempty( MR.Parameter.Gridder.WorkingPars{ cell_index }.OutputMatrixSize )
                                    MR.Parameter.Gridder.WorkingPars{ cell_index }.OutputMatrixSize = [ MR.Parameter.Encoding.WorkEncoding.XRes{ 1, cell_index } * MR.Parameter.Encoding.WorkEncoding.KxOversampling{ 1, cell_index },  ...
                                        MR.Parameter.Encoding.WorkEncoding.YRes{ 1, cell_index } * MR.Parameter.Encoding.WorkEncoding.KyOversampling{ 1, cell_index },  ...
                                        MR.Parameter.Encoding.WorkEncoding.ZRes{ 1, cell_index } * MR.Parameter.Encoding.WorkEncoding.KzOversampling{ 1, cell_index } ];
                                    
                                    
                                    if strcmpi( MR.Parameter.Gridder.WorkingPars{ cell_index }.Preset, 'Epi' ) && isfield( MR.Parameter.Labels, 'Samples' )
                                        MR.Parameter.Gridder.WorkingPars{ cell_index }.OutputMatrixSize = [ round( MR.Parameter.Labels.Samples( 1 ) * MR.Parameter.Encoding.WorkEncoding.KxOversampling{ 1, cell_index } ),  ...
                                            round( MR.Parameter.Labels.Samples( 2 ) * MR.Parameter.Encoding.WorkEncoding.KyOversampling{ 1, cell_index } ),  ...
                                            round( MR.Parameter.Labels.Samples( 3 ) * MR.Parameter.Encoding.WorkEncoding.KzOversampling{ 1, cell_index } ) ];
                                    end
                                end
                                
                                if isempty( MR.Parameter.Gridder.WorkingPars{ cell_index }.GridOvsFactor )
                                    MR.Parameter.Gridder.WorkingPars{ cell_index }.GridOvsFactor = 1;
                                end
                                
                                if isempty( MR.Parameter.Gridder.WorkingPars{ cell_index }.Weights )
                                    MR.Parameter.Gridder.WorkingPars{ cell_index }.Weights = ones( size( MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos, 1 ), size( MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos, 2 ), size( MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos, 3 ) );
                                end
                                
                                if ( size( MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos, 1 ) ~= size( MR.Parameter.Gridder.WorkingPars{ cell_index }.Weights, 1 ) ) ||  ...
                                        ( size( MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos, 2 ) ~= size( MR.Parameter.Gridder.WorkingPars{ cell_index }.Weights, 2 ) ) ||  ...
                                        ( size( MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos, 3 ) ~= size( MR.Parameter.Gridder.WorkingPars{ cell_index }.Weights, 3 ) )
                                    error( 'Error in Gridder: Parameter.Gridder.Weights has to be a matrix of size: %d x %d x %d', size( MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos, 1 ), size( MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos, 2 ), size( MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos, 3 ) );
                                end
                                if strcmpi( MR.Parameter.Gridder.WorkingPars{ cell_index }.Preset, 'radial' ) && ~isempty( MR.Parameter.Gridder.WorkingPars{ cell_index }.RadialAngles ) && ( size( MR.Parameter.Gridder.WorkingPars{ cell_index }.RadialAngles, 1 ) ~= size( MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos, 2 ) )
                                    error( 'Error in Gridder: The number of rows in Parameter.Gridder.RadialAngles has to be %d', size( MR.Parameter.Gridder.WorkingPars{ cell_index }.Kpos, 2 ) );
                                end
                                
                            end
                            
                            
                            if size( MR.Data( 1, : ), 2 ) ~= length( MR.Parameter.Gridder.WorkingPars )
                                error( 'Error in Gridder: Parameter.Gridder.%s has to be a cell array of size %d x %d', fn{ i }, size( MR.Data( 1, : ), 1 ), size( MR.Data( 1, : ), 2 ) );
                            end
                        end
                        
                        
                        MR.Data( 1, : ) = cellfun( @( x, y )MR.grid_data( x, y ),  ...
                            MR.Data( 1, : ), MR.Parameter.Gridder.WorkingPars, 'UniformOutput', false );
                        
                        
                        if ~strcmpi( MR.Parameter.Gridder.Preset, 'Epi' )
                            MR.Parameter.LabelLookupTable = cellfun( @( x )[  ], MR.Parameter.LabelLookupTable, 'UniformOutput', 0 );
                        end
                        
                        MR.Parameter.ReconFlags.isgridded = 1;
                        
                        
                        MR.Parameter.UpdateImageInfo = 1;
                        MR.Data = MR.UnconvertCell( MR.Data );
                    end
                end
            end
        end
        function GridderCalculateTrajectory( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if ~MR.Parameter.ReconFlags.isread
                error( 'Error in CalculateTrajectory: Please read the data first' );
            end
            if ~MR.Parameter.ReconFlags.issorted
                error( 'Error in CalculateTrajectory: Please sort the data first' );
            end
            
            if ~strcmpi( MR.Parameter.Gridder.Preset, 'none' )
                MR.DataClass.Convert2Cell;
                grid_ovs = [  ];
                
                if isfield( MR.Parameter.Labels, 'NusEncNrs' )
                    nus_enc_nrs = MR.Parameter.Labels.NusEncNrs;
                    if size( nus_enc_nrs, 1 ) < size( nus_enc_nrs, 2 )
                        nus_enc_nrs = nus_enc_nrs;
                    end
                else
                    nus_enc_nrs = [  ];
                end
                
                if isempty( MR.Parameter.Gridder.Kpos )
                    [ MR.Parameter.Gridder.Kpos, grid_ovs, MR.Parameter.Gridder.RadialAngles ] = cellfun( @( x, y, z, v )MR.calculate_trajectory( x, y, z, MR.Parameter.Gridder, nus_enc_nrs, MR.Parameter.Scan.SENSEFactor ),  ...
                        MR.Data( 1, : ), MR.Parameter.Encoding.WorkEncoding.KxOversampling( 1, : ),  ...
                        MR.Parameter.Encoding.WorkEncoding.KxRange( 1, : ), 'UniformOutput', false );
                else
                    MR.Parameter.Gridder.Kpos = MRecon.Convert2Cell( MR.Parameter.Gridder.Kpos );
                end
                
                if isempty( MR.Parameter.Gridder.GridOvsFactor )
                    MR.Parameter.Gridder.GridOvsFactor = grid_ovs;
                else
                    MR.Parameter.Gridder.GridOvsFactor = MRecon.Convert2Cell( MR.Parameter.Gridder.GridOvsFactor );
                end
                
                if isempty( MR.Parameter.Gridder.Weights )
                    MR.Parameter.Gridder.Weights = cellfun( @( x, y, z, v )MR.calculate_weights( x, MR.Parameter.Gridder ),  ...
                        MR.Parameter.Gridder.Kpos, 'UniformOutput', false );
                else
                    MR.Parameter.Gridder.Weights = MRecon.Convert2Cell( MR.Parameter.Gridder.Weights );
                end
                
                if isempty( MR.Parameter.Gridder.OutputMatrixSize )
                    MR.Parameter.Gridder.OutputMatrixSize = cellfun( @( x, ox, y, oy, z, oz )[ x * ox, y * oy, z * oz ],  ...
                        MR.Parameter.Encoding.WorkEncoding.XRes( 1, : ), MR.Parameter.Encoding.WorkEncoding.KxOversampling( 1, : ),  ...
                        MR.Parameter.Encoding.WorkEncoding.YRes( 1, : ), MR.Parameter.Encoding.WorkEncoding.KyOversampling( 1, : ),  ...
                        MR.Parameter.Encoding.WorkEncoding.ZRes( 1, : ), MR.Parameter.Encoding.WorkEncoding.KzOversampling( 1, : ),  ...
                        'UniformOutput', false );
                    
                    if strcmpi( MR.Parameter.Gridder.Preset, 'Epi' ) && isfield( MR.Parameter.Labels, 'Samples' )
                        MR.Parameter.Gridder.OutputMatrixSize = cellfun( @( ox, oy, oz )[ round( MR.Parameter.Labels.Samples( 1 ) * ox ), round( MR.Parameter.Labels.Samples( 2 ) * oy ), round( MR.Parameter.Labels.Samples( 3 ) * oz ) ],  ...
                            MR.Parameter.Encoding.WorkEncoding.KxOversampling( 1, : ),  ...
                            MR.Parameter.Encoding.WorkEncoding.KyOversampling( 1, : ),  ...
                            MR.Parameter.Encoding.WorkEncoding.KzOversampling( 1, : ),  ...
                            'UniformOutput', false );
                    end
                else
                    MR.Parameter.Gridder.OutputMatrixSize = MRecon.Convert2Cell( MR.Parameter.Gridder.OutputMatrixSize );
                end
                
                for cell_index = 1:size( MR.Data, 2 )
                    MR.Parameter.Gridder.AssignWorkingPars( cell_index );
                end
                
                MR.Parameter.Gridder.Kpos = MR.UnconvertCell( MR.Parameter.Gridder.Kpos );
                MR.Parameter.Gridder.RadialAngles = MR.UnconvertCell( MR.Parameter.Gridder.RadialAngles );
                MR.Parameter.Gridder.Weights = MR.UnconvertCell( MR.Parameter.Gridder.Weights );
                MR.Parameter.Gridder.GridOvsFactor = MR.UnconvertCell( MR.Parameter.Gridder.GridOvsFactor );
                MR.Parameter.Gridder.OutputMatrixSize = MR.UnconvertCell( MR.Parameter.Gridder.OutputMatrixSize );
                
                MR.Data = MR.UnconvertCell( MR.Data );
                
            end
        end
        function GridderNormalization( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if strcmpi( MR.Parameter.Recon.Gridding, 'yes' ) && MR.Parameter.ReconFlags.isgridded
                if ~strcmpi( MR.Parameter.Gridder.Preset, 'none' )
                    if ~all( MR.Parameter.ReconFlags.isimspace )
                        error( 'The data can only be normalized in image-space' );
                    end
                    if ~MR.Parameter.ReconFlags.isgridded
                        error( 'Please grid the data first' );
                    end
                    
                    if ~isempty( MR.Data )
                        if strcmpi( MR.Parameter.Gridder.Normalize, 'yes' )
                            MR.Parameter.UpdateImageInfo = 0;
                            MR.DataClass.Convert2Cell;
                            
                            
                            
                            
                            for i = 1:length( MR.Parameter.Gridder.WorkingPars )
                                is_3d{ i } = size( MR.Parameter.Gridder.WorkingPars{ i }.Kpos, 3 ) > 1;
                            end
                            
                            MR.Data( 1, : ) = cellfun( @( x, y, ox, oy, oz, xr, yr, zr )MR.gridder_normalization( x, MR.Parameter.Gridder.KernelWidth, y, ox, oy, oz, xr, yr, zr ),  ...
                                MR.Data( 1, : ), is_3d, MR.Parameter.Encoding.WorkEncoding.KxOversampling( 1, : ),  ...
                                MR.Parameter.Encoding.WorkEncoding.KyOversampling( 1, : ), MR.Parameter.Encoding.WorkEncoding.KzOversampling( 1, : ),  ...
                                MR.Parameter.Encoding.WorkEncoding.XRange( 1, : ), MR.Parameter.Encoding.WorkEncoding.YRange( 1, : ), MR.Parameter.Encoding.WorkEncoding.ZRange( 1, : ),  ...
                                'UniformOutput', false );
                            
                            MR.Parameter.UpdateImageInfo = 1;
                            MR.Data = MR.UnconvertCell( MR.Data );
                            
                        end
                    end
                end
            end
        end
        
        
        
        
        function K2I( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if all( MR.Parameter.ReconFlags.isimspace )
                error( 'The data is already in image space' );
            end
            
            if ~isempty( MR.Data )
                
                fftdims = find( MR.Parameter.Encoding.WorkEncoding.FFTDims &  ...
                    MR.Parameter.ReconFlags.isimspace == 0 );
                
                MR.Parameter.UpdateImageInfo = 0;
                MR.DataClass.Convert2Cell;
                
                
                if MR.Parameter.Labels.Spectro
                    MR.Data = cellfun( @( x )MR.k2i( x, fftdims, 1, true ), MR.Data, 'UniformOutput', false );
                else
                    
                    MR.Data = cellfun( @( x )MR.k2i( x, fftdims, 1 ), MR.Data, 'UniformOutput', false );
                end
                
                if any( MR.Parameter.Encoding.WorkEncoding.FFTShift ) && any( strcmpi( MR.Parameter.DataFormat, { 'ExportedRaw', 'Raw' } ) )
                    
                    if ~MR.Parameter.Encoding.WorkEncoding.FFTShift( 1 ) || ~MR.Parameter.Encoding.WorkEncoding.FFTDims( 1 )
                        xrange = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.XRange, 'UniformOutput', 0 );
                    else
                        xrange = MR.Parameter.Encoding.WorkEncoding.XRange;
                        MR.Parameter.Encoding.WorkEncoding.FFTShift( 1 ) = 0;
                    end
                    if ~MR.Parameter.Encoding.WorkEncoding.FFTShift( 2 ) || ~MR.Parameter.Encoding.WorkEncoding.FFTDims( 2 )
                        yrange = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.YRange, 'UniformOutput', 0 );
                    else
                        yrange = MR.Parameter.Encoding.WorkEncoding.YRange;
                        MR.Parameter.Encoding.WorkEncoding.FFTShift( 2 ) = 0;
                    end
                    
                    
                    
                    if ~MR.Parameter.Encoding.WorkEncoding.FFTShift( 3 ) || ~MR.Parameter.Encoding.WorkEncoding.FFTDims( 3 )
                        zrange = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.ZRange, 'UniformOutput', 0 );
                        zres = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.ZRes, 'UniformOutput', 0 );
                    else
                        zrange = MR.Parameter.Encoding.WorkEncoding.ZRange;
                        zres = MR.Parameter.Encoding.WorkEncoding.ZRes;
                        MR.Parameter.Encoding.WorkEncoding.FFTShift( 3 ) = 0;
                    end
                    
                    MR.Data = cellfun( @( x, xr, yr, zr, zre )MR.shift_image( x, xr, yr, zr, zre ),  ...
                        MR.Data,  ...
                        xrange,  ...
                        yrange,  ...
                        zrange,  ...
                        zres, 'UniformOutput', 0 );
                end
                
                MR.Parameter.UpdateImageInfo = 1;
                MR.Data = MR.UnconvertCell( MR.Data );
                
                MR.Parameter.ReconFlags.isimspace( fftdims ) = 1;
            end
            
        end
        function K2IM( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if MR.Parameter.ReconFlags.isimspace( 1 )
                error( 'The data has already been fourier transformed in measurement direction' );
            end
            
            if ~isempty( MR.Data )
                MR.Parameter.UpdateImageInfo = 0;
                MR.DataClass.Convert2Cell;
                
                
                if MR.Parameter.Labels.Spectro
                    MR.Data = cellfun( @( x )MR.k2i( x, 1, 1, true ), MR.Data, 'UniformOutput', false );
                else
                    
                    MR.Data = cellfun( @( x )MR.k2i( x, 1, 1 ), MR.Data, 'UniformOutput', false );
                end
                
                if MR.Parameter.Encoding.WorkEncoding.FFTShift( 1 )
                    
                    if ~MR.Parameter.Encoding.WorkEncoding.FFTShift( 1 ) || ~MR.Parameter.Encoding.WorkEncoding.FFTDims( 2 )
                        xrange = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.XRange, 'UniformOutput', 0 );
                    else
                        xrange = MR.Parameter.Encoding.WorkEncoding.XRange;
                        MR.Parameter.Encoding.WorkEncoding.FFTShift( 1 ) = 0;
                    end
                    yrange = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.YRange, 'UniformOutput', 0 );
                    zrange = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.ZRange, 'UniformOutput', 0 );
                    zres = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.ZRes, 'UniformOutput', 0 );
                    
                    xrange = xrange( 1:size( MR.Data, 1 ), 1:size( MR.Data, 2 ) );
                    yrange = yrange( 1:size( MR.Data, 1 ), 1:size( MR.Data, 2 ) );
                    zrange = zrange( 1:size( MR.Data, 1 ), 1:size( MR.Data, 2 ) );
                    zres = zres( 1:size( MR.Data, 1 ), 1:size( MR.Data, 2 ) );
                    
                    MR.Data = cellfun( @( x, xr, yr, zr, zre )MR.shift_image( x, xr, yr, zr, zre ),  ...
                        MR.Data,  ...
                        xrange,  ...
                        yrange,  ...
                        zrange,  ...
                        zres, 'UniformOutput', 0 );
                    
                    MR.Parameter.Encoding.WorkEncoding.FFTShift = [ 0, 1, 1 ] .* MR.Parameter.Encoding.WorkEncoding.FFTShift;
                end
                
                MR.Parameter.UpdateImageInfo = 1;
                MR.Data = MR.UnconvertCell( MR.Data );
                MR.Parameter.ReconFlags.isimspace = [ 1, MR.Parameter.ReconFlags.isimspace( 2:3 ) ];
            end
            
        end
        function K2IP( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if all( MR.Parameter.ReconFlags.isimspace( 2:3 ) )
                error( 'The data has alredy been fourier transformed in phase encoding direction' );
            end
            
            if ~isempty( MR.Data )
                
                fftdims = find( MR.Parameter.Encoding.WorkEncoding.FFTDims &  ...
                    MR.Parameter.ReconFlags.isimspace == 0 );
                fftdims( fftdims == 1 ) = [  ];
                
                MR.Parameter.UpdateImageInfo = 0;
                MR.DataClass.Convert2Cell;
                for i = 1:length( fftdims )
                    
                    if MR.Parameter.Labels.Spectro
                        MR.Data = cellfun( @( x )MR.k2i( x, fftdims( i ), 1, true ), MR.Data, 'UniformOutput', false );
                    else
                        
                        MR.Data = cellfun( @( x )MR.k2i( x, fftdims( i ), 1 ), MR.Data, 'UniformOutput', false );
                    end
                end
                
                if any( MR.Parameter.Encoding.WorkEncoding.FFTShift( 2:3 ) )
                    
                    xrange = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.XRange, 'UniformOutput', 0 );
                    
                    if ~MR.Parameter.Encoding.WorkEncoding.FFTShift( 2 ) || ~MR.Parameter.Encoding.WorkEncoding.FFTDims( 2 )
                        yrange = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.YRange, 'UniformOutput', 0 );
                    else
                        yrange = MR.Parameter.Encoding.WorkEncoding.YRange;
                        MR.Parameter.Encoding.WorkEncoding.FFTShift( 2 ) = 0;
                    end
                    if ~MR.Parameter.Encoding.WorkEncoding.FFTShift( 3 ) || ~MR.Parameter.Encoding.WorkEncoding.FFTDims( 3 )
                        zrange = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.ZRange, 'UniformOutput', 0 );
                        zres = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.ZRes, 'UniformOutput', 0 );
                    else
                        zrange = MR.Parameter.Encoding.WorkEncoding.ZRange;
                        zres = MR.Parameter.Encoding.WorkEncoding.ZRes;
                        MR.Parameter.Encoding.WorkEncoding.FFTShift( 3 ) = 0;
                    end
                    
                    xrange = xrange( 1:size( MR.Data, 1 ), 1:size( MR.Data, 2 ) );
                    yrange = yrange( 1:size( MR.Data, 1 ), 1:size( MR.Data, 2 ) );
                    zrange = zrange( 1:size( MR.Data, 1 ), 1:size( MR.Data, 2 ) );
                    zres = zres( 1:size( MR.Data, 1 ), 1:size( MR.Data, 2 ) );
                    
                    MR.Data = cellfun( @( x, xr, yr, zr, zre )MR.shift_image( x, xr, yr, zr, zre ),  ...
                        MR.Data,  ...
                        xrange,  ...
                        yrange,  ...
                        zrange,  ...
                        zres, 'UniformOutput', 0 );
                    MR.Parameter.Encoding.WorkEncoding.FFTShift = [ 1, 0, 0 ] .* MR.Parameter.Encoding.WorkEncoding.FFTShift;
                end
                
                
                MR.Parameter.UpdateImageInfo = 1;
                MR.Data = MR.UnconvertCell( MR.Data );
                
                MR.Parameter.ReconFlags.isimspace = [ MR.Parameter.ReconFlags.isimspace( 1 ), 1, 1 ];
            end
        end
        function I2K( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if all( ~MR.Parameter.ReconFlags.isimspace )
                error( 'Error in I2K: The data is already in k-space' );
            end
            
            fftdims = find( MR.Parameter.Encoding.WorkEncoding.FFTDims &  ...
                MR.Parameter.ReconFlags.isimspace == 1 );
            
            if ~isempty( MR.Data )
                MR.Parameter.UpdateImageInfo = 0;
                MR.DataClass.Convert2Cell;
                
                
                if MR.Parameter.Labels.Spectro
                    MR.Data = cellfun( @( x )MR.i2k( x, fftdims, 1, true ), MR.Data, 'UniformOutput', false );
                else
                    
                    MR.Data = cellfun( @( x )MR.i2k( x, fftdims, 1 ), MR.Data, 'UniformOutput', false );
                end
                
                MR.Parameter.UpdateImageInfo = 1;
                MR.Data = MR.UnconvertCell( MR.Data );
                
                MR.Parameter.ReconFlags.isimspace( fftdims ) = 0;
            end
        end
        
        
        
        
        function CombineCoils( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if ~isempty( MR.Data )
                if ~strcmpi( MR.Parameter.Recon.CoilCombination, 'no' )
                    if MR.Parameter.ReconFlags.iscombined
                        error( 'Error in CombineCoils: Data is already combined' );
                    end
                    
                    MR.Parameter.UpdateImageInfo = 0;
                    MR.DataClass.Convert2Cell;
                    
                    
                    if MR.Parameter.Labels.Spectro
                        if ( size( MR.Data{ 1 }, MR.dim.coil ) > 1 )
                            if ~isempty( MR.Parameter.Encoding.YRes ) && ~isempty( MR.Parameter.Encoding.ZRes )
                                error( 'SVD coil combination works at the moment only on single voxel data' );
                            end
                        end
                        if ~MR.Parameter.ReconFlags.issorted
                            error( 'The Data should be sorted prior to coil combination' );
                        end
                    else
                        if any( ~MR.Parameter.ReconFlags.isimspace )
                            error( 'Error in CombineCoils: Coil combination has to be performed on image space data' );
                        end
                    end
                    
                    
                    is_multichannel = cellfun( @( x )size( x, 4 ) ~= 1, MR.Data );
                    switch lower( MR.Parameter.Recon.CoilCombination )
                        case 'sos'
                            MR.Data( is_multichannel ) = cellfun( @( x )sos( x, 4, 1 ), MR.Data( is_multichannel ), 'UniformOutput', false );
                            
                        case 'pc'
                            MR.Data( is_multichannel ) = cellfun( @( x )sos( x, 4, 2 ), MR.Data( is_multichannel ), 'UniformOutput', false );
                            
                            
                        case 'svd'
                            if ~MR.Parameter.Labels.Spectro
                                error( 'SVD based coil combination is only available for spectroscopy scans' );
                            end
                            MR.SpectroCombineCoils( 'svd' );
                        case 'snr-weight'
                            if ~MR.Parameter.Labels.Spectro
                                error( 'SNR weighted coil combination is only available for spectroscopy scans' );
                            end
                            if ~MR.Parameter.ReconFlags.isecc
                                error( 'SNR weighted coil combination can only work properly with phased data. Use eddy current correction before' );
                            end
                            MR.SpectroCombineCoils( 'snr-weight' );
                            
                            
                    end
                    
                    MR.Parameter.UpdateImageInfo = 1;
                    
                    
                    MR.Parameter.LabelLookupTable = MR.Convert2Cell( MR.Parameter.LabelLookupTable );
                    MR.Parameter.LabelLookupTable = cellfun( @( x )[  ], MR.Data, 'UniformOutput', 0 );
                    MR.Parameter.LabelLookupTable = MR.UnconvertCell( MR.Parameter.LabelLookupTable );
                    
                    MR.Data = MR.UnconvertCell( MR.Data );
                    
                    MR.Parameter.ReconFlags.iscombined = 1;
                end
                
            end
        end
        
        
        
        
        function PartialFourier( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if strcmpi( MR.Parameter.Recon.PartialFourier, 'yes' )
                if ~MR.Parameter.ReconFlags.issorted
                    error( 'Error in partial Fourier: Please sort the data first' );
                end
                
                if ~isempty( MR.Data )
                    is_kspace = sum( MR.Parameter.ReconFlags.isimspace ) == 0;
                    is_imspace = sum( MR.Parameter.ReconFlags.isimspace ) == 3;
                    
                    
                    
                    if ~is_imspace && ~is_kspace
                        error( 'Error in partial fourier: The data has to be fully in k-space or image-space' );
                    end
                    
                    
                    
                    if is_kspace &&  ...
                            ( ~isempty( MR.Parameter.Scan.SENSEFactor ) &&  ...
                            ~isempty( MR.Parameter.Recon.Sensitivities ) &&  ...
                            strcmpi( MR.Parameter.Recon.SENSE, 'yes' ) )
                        error( 'Error in partial fourier: The partial fourier reconstruction has to be performed in image space if SENSE is enabled' );
                    end
                    
                    if is_imspace && ~isempty( MR.Parameter.Scan.SENSEFactor )
                        if MR.Parameter.ReconFlags.isrotated
                            error( 'The partial Fourier reconstruction cannot be performed on rotated images. Please call the RotateImage function after SENSEUnfold' );
                        end
                        m_ovs = cellfun( @( x )1 / MR.Parameter.Scan.SENSEFactor( 1 ), MR.Parameter.Encoding.WorkEncoding.KxRange, 'UniformOutput', 0 );
                        MR.Parameter.Encoding.WorkEncoding.KxRange = cellfun( @( x, y )MRecon.set_k_ranges( x, y ), MR.Parameter.Encoding.WorkEncoding.KxRange,  ...
                            m_ovs, 'UniformOutput', 0 );
                        p_ovs = cellfun( @( x )1 / MR.Parameter.Scan.SENSEFactor( 2 ), MR.Parameter.Encoding.WorkEncoding.KyRange, 'UniformOutput', 0 );
                        MR.Parameter.Encoding.WorkEncoding.KyRange = cellfun( @( x, y )MRecon.set_k_ranges( x, y ), MR.Parameter.Encoding.WorkEncoding.KyRange,  ...
                            p_ovs, 'UniformOutput', 0 );
                        s_ovs = cellfun( @( x )1 / MR.Parameter.Scan.SENSEFactor( 3 ), MR.Parameter.Encoding.WorkEncoding.KzRange, 'UniformOutput', 0 );
                        MR.Parameter.Encoding.WorkEncoding.KzRange = cellfun( @( x, y )MRecon.set_k_ranges( x, y ), MR.Parameter.Encoding.WorkEncoding.KzRange,  ...
                            s_ovs, 'UniformOutput', 0 );
                    end
                    
                    if any( strcmpi( MR.Parameter.DataFormat, { 'Raw', 'ExportedRaw', 'Bruker' } ) )
                        if all( MR.Parameter.ReconFlags.ispartialfourier )
                            error( 'Error in partial fourier: The partial fourier correction has already been applied' );
                        end
                        
                        MR.Parameter.UpdateImageInfo = 0;
                        MR.DataClass.Convert2Cell;
                        
                        
                        
                        isPF = logical( cellfun( @( x, kx, ky, kz )MRecon.is_partial_fourier( x, kx, ky, kz ),  ...
                            MR.Data( 1, : ), MR.Parameter.Encoding.WorkEncoding.KxRange( 1, : ),  ...
                            MR.Parameter.Encoding.WorkEncoding.KyRange( 1, : ),  ...
                            MR.Parameter.Encoding.WorkEncoding.KzRange( 1, : ) ) );
                        
                        if any( isPF )
                            apply_filter = ~MR.Parameter.ReconFlags.ispartialfourier( 1 );
                            
                            
                            
                            
                            
                            
                            if is_imspace
                                orig_phase = cellfun( @( x )angle( x ), MR.Data( 1, isPF ), 'UniformOutput', 0 );
                                if apply_filter
                                    
                                    
                                    MR.I2K;
                                    MR.DataClass.Convert2Cell;
                                    
                                    
                                    
                                    
                                end
                            end
                            
                            if apply_filter
                                [ MR.Data( 1, isPF ), MR.PFLowRes ] = cellfun( @( d, x, y, z )MR.partial_fourier_filter( d, x, y, z ),  ...
                                    MR.Data( 1, isPF ), MR.Parameter.Encoding.WorkEncoding.KxRange( 1, isPF ),  ...
                                    MR.Parameter.Encoding.WorkEncoding.KyRange( 1, isPF ),  ...
                                    MR.Parameter.Encoding.WorkEncoding.KzRange( 1, isPF ), 'UniformOutput', false );
                                
                                if is_kspace
                                    MR.PFLowRes = cellfun( @( x, xr, yr, zr, zre )MR.shift_image( x, xr, yr, zr, zre ),  ...
                                        MR.PFLowRes,  ...
                                        MR.Parameter.Encoding.WorkEncoding.XRange( 1, isPF ),  ...
                                        MR.Parameter.Encoding.WorkEncoding.YRange( 1, isPF ),  ...
                                        MR.Parameter.Encoding.WorkEncoding.ZRange( 1, isPF ),  ...
                                        MR.Parameter.Encoding.WorkEncoding.ZRes( 1, isPF ), 'UniformOutput', 0 );
                                end
                            end
                            
                            if any( isPF )
                                if apply_filter || is_kspace
                                    
                                    
                                    MR.K2I;
                                    MR.DataClass.Convert2Cell;
                                    
                                    
                                    
                                    
                                end
                                
                                MR.Data( 1, isPF ) = cellfun( @( x, y )MRecon.partial_fourier_multiply( x, y ), MR.Data( 1, isPF ), MR.PFLowRes, 'UniformOutput', 0 );
                                
                                if is_kspace
                                    
                                    
                                    
                                    
                                    
                                    
                                    MR.I2K;
                                    MR.DataClass.Convert2Cell;
                                else
                                    MR.Data( 1, isPF ) = cellfun( @( x, y )abs( x ) .* ( cos( y ) + 1i .* sin( y ) ), MR.Data( 1, isPF ), orig_phase, 'UniformOutput', 0 );
                                end
                            end
                        end
                        MR.Parameter.UpdateImageInfo = 1;
                        MR.Data = MR.UnconvertCell( MR.Data );
                    end
                end
                MR.Parameter.ReconFlags.ispartialfourier = [ 1, 1 ];
            end
        end
        function PartialFourierFilter( MR )
            if strcmpi( MR.Parameter.Recon.PartialFourier, 'yes' )
                if ~isempty( MR.Data )
                    
                    
                    
                    
                    if isempty( MR.Parameter.Recon.Sensitivities )
                        
                        if ~MR.Parameter.ReconFlags.issorted
                            error( 'Error in PartialFourierFilter: Please sort the data first' );
                        end
                        
                        is_kspace = sum( MR.Parameter.ReconFlags.isimspace ) == 0;
                        if ~is_kspace
                            error( 'Error in PartialFourierFilter: The homodyne filter has to be applied in k-space' );
                        end
                        
                        if any( strcmpi( MR.Parameter.DataFormat, { 'Raw', 'ExportedRaw', 'Bruker' } ) )
                            if MR.Parameter.ReconFlags.ispartialfourier( 1 )
                                error( 'Error in PartialFourierFilter: The homodyne filter has already been applied' );
                            end
                            
                            MR.Parameter.UpdateImageInfo = 0;
                            MR.DataClass.Convert2Cell;
                            
                            
                            
                            isPF = logical( cellfun( @( x, kx, ky, kz )MRecon.is_partial_fourier( x, kx, ky, kz ),  ...
                                MR.Data( 1, : ), MR.Parameter.Encoding.WorkEncoding.KxRange( 1, : ),  ...
                                MR.Parameter.Encoding.WorkEncoding.KyRange( 1, : ),  ...
                                MR.Parameter.Encoding.WorkEncoding.KzRange( 1, : ) ) );
                            
                            if any( isPF )
                                [ MR.Data( 1, isPF ), MR.PFLowRes ] = cellfun( @( d, x, y, z )MR.partial_fourier_filter( d, x, y, z ),  ...
                                    MR.Data( 1, isPF ), MR.Parameter.Encoding.WorkEncoding.KxRange( 1, isPF ),  ...
                                    MR.Parameter.Encoding.WorkEncoding.KyRange( 1, isPF ),  ...
                                    MR.Parameter.Encoding.WorkEncoding.KzRange( 1, isPF ),  ...
                                    'UniformOutput', false );
                                
                                MR.PFLowRes = cellfun( @( x, xr, yr, zr, zre )MR.shift_image( x, xr, yr, zr, zre ),  ...
                                    MR.PFLowRes,  ...
                                    MR.Parameter.Encoding.WorkEncoding.XRange( 1, isPF ),  ...
                                    MR.Parameter.Encoding.WorkEncoding.YRange( 1, isPF ),  ...
                                    MR.Parameter.Encoding.WorkEncoding.ZRange( 1, isPF ),  ...
                                    MR.Parameter.Encoding.WorkEncoding.ZRes( 1, isPF ), 'UniformOutput', 0 );
                            end
                            
                            MR.Parameter.UpdateImageInfo = 1;
                            MR.Data = MR.UnconvertCell( MR.Data );
                            
                        end
                        MR.Parameter.ReconFlags.ispartialfourier( 1 ) = 1;
                    end
                end
            end
        end
        function SENSEUnfold( MR )
            
            if ~isempty( MR.Data ) &&  ...
                    ~isempty( MR.Parameter.Scan.SENSEFactor ) &&  ...
                    strcmpi( MR.Parameter.Recon.SENSE, 'yes' ) &&  ...
                    ~isempty( MR.Parameter.Recon.Sensitivities )
                
                if isempty( MR.Parameter.Recon.Sensitivities.Sensitivity )
                    error( 'Error in SENSEUnfold: No Sensitivities available. Run the MRsense Perform function' );
                end
                if any( ~MR.Parameter.ReconFlags.isimspace )
                    error( 'Error in SENSEUnfold: SENSE Unfolding has to be performed on image space data' );
                end
                if MR.Parameter.ReconFlags.isunfolded
                    error( 'Error in SENSEUnfold: Data is already Unfolded' );
                end
                if isempty( MR.Parameter.Recon.Sensitivities )
                    error( 'Error in SENSEUnfold: Coil sensitivities not found! Please add sensitivity infomation in Parameter.Recon.Sensitivities...' );
                end
                if isempty( MR.Parameter.Scan.SENSEFactor )
                    error( 'Error in SENSEUnfold: SENSE factors not found! Please add them in Parameter.Scan.SENSEFactor...' );
                end
                for i = 1:3
                    if MR.Parameter.ReconFlags.isoversampled( i ) == 0 && MR.Parameter.Scan.SENSEFactor( i ) > 1
                        error( 'Error in SENSEUnfold: The Oversampling cannot be removed in the undersampled direction before the unfolding process' );
                    end
                end
                if MR.Parameter.ReconFlags.iszerofilled( 2 )
                    error( 'Error in SENSEUnfold: The unfodling has to be performed before image space zero filling' );
                end
                if MR.Parameter.ReconFlags.iscombined
                    error( 'Error in SENSEUnfold: The unfodling has to be performed before coil combination' );
                end
                
                
                
                if ( 0 )
                    MR.Data = radon( MR.Data );
                    MR.Data = iradon( MR.Data, 0:179 );
                    fiex_config;
                end
                
                if ~isempty( MR.Data )
                    s_psi = [  ];
                    
                    MR.Parameter.UpdateImageInfo = 0;
                    MR.DataClass.Convert2Cell;
                    
                    
                    res = cellfun( @( x )[ round( size( x, 1 ) * max( [ 1, MR.Parameter.Scan.SENSEFactor( 1, 1 ) ] ) ), round( size( x, 2 ) * max( [ 1, MR.Parameter.Scan.SENSEFactor( 1, 2 ) ] ) ), round( size( x, 3 ) * max( [ 1, MR.Parameter.Scan.SENSEFactor( 1, 3 ) ] ) ) ],  ...
                        MR.Data, 'UniformOutput', 0 );
                    
                    if ( MR.Parameter.ReconFlags.iszerofilled( 1 ) )
                        MR.Parameter.Encoding.WorkEncoding.KxOversampling = cellfun( @( x, y )x( 1 ) / max( [ 1, y ] ),  ...
                            res, MR.Parameter.Encoding.WorkEncoding.XRes, 'UniformOutput', 0 );
                        MR.Parameter.Encoding.WorkEncoding.KyOversampling = cellfun( @( x, y )x( 2 ) / max( [ 1, y ] ),  ...
                            res, MR.Parameter.Encoding.WorkEncoding.YRes, 'UniformOutput', 0 );
                        MR.Parameter.Encoding.WorkEncoding.KzOversampling = cellfun( @( x, y )x( 3 ) / max( [ 1, y ] ),  ...
                            res, MR.Parameter.Encoding.WorkEncoding.ZRes, 'UniformOutput', 0 );
                    end
                    
                    body_ref = [  ];
                    coil_ref = [  ];
                    mc = metaclass( MR.Parameter.Recon.Sensitivities );
                    if strcmpi( mc.Name, 'MRsense' )
                        sens_image = MR.Parameter.Recon.Sensitivities.Sensitivity;
                        body_ref = MR.Parameter.Recon.Sensitivities.ReformatedBodycoilData;
                        coil_ref = MR.Parameter.Recon.Sensitivities.ReformatedCoilData;
                        s_psi = MR.Parameter.Recon.Sensitivities.Psi;
                    elseif isnumeric( MR.Parameter.Recon.Sensitivities )
                        sens_image = MR.Parameter.Recon.Sensitivities;
                    else
                        error( 'Unknown input type for the reference scan' );
                    end
                    
                    
                    
                    try
                        for i = 1:size( coil_ref, 8 )
                            cur_stack = MR.Parameter.Labels.StackIndex( i ) + 1;
                            channel_numbers_measured = MR.Parameter.Labels.CoilNrsPerStack{ cur_stack };
                            set2zero = find( ismember( MR.Parameter.Recon.Sensitivities.ChannelNumbers, channel_numbers_measured ) == 0 );
                            sens_image( :, :, :, set2zero, :, :, :, i, :, :, :, :, : ) = 0;
                            coil_ref( :, :, :, set2zero, :, :, :, i, :, :, :, :, : ) = 0;
                        end
                    end
                    
                    
                    
                    try
                        P = MR.Parameter.Parameter2Read.Copy;
                        P.Update( MR.Parameter.Labels.Index );
                        [ temp, chan_ind ] = ismember( P.chan, MR.Parameter.Recon.Sensitivities.ChannelNumbers );
                        sens_image = sens_image( :, :, :, chan_ind, :, :, :, :, :, :, :, : );
                        coil_ref = coil_ref( :, :, :, chan_ind, :, :, :, :, :, :, :, : );
                        s_psi = s_psi( chan_ind, chan_ind );
                    end
                    
                    
                    
                    nr_locas = max( cellfun( @( x )size( x, 8 ), MR.Data( 1, : ) ) );
                    if nr_locas > size( sens_image, 8 )
                        if MR.Parameter.ReconFlags.iscombined
                            error( 'Error in SENSEUnfold: The number of locations in the data exceeds the one in the sensitivities' );
                        end
                    end
                    if nr_locas < size( sens_image, 8 )
                        if length( MR.Parameter.Parameter2Read.loca ) == nr_locas
                            sens_image = sens_image( :, :, :, :, :, :, :, MR.Parameter.Parameter2Read.loca + 1, :, :, :, : );
                            coil_ref = coil_ref( :, :, :, :, :, :, :, MR.Parameter.Parameter2Read.loca + 1, :, :, :, : );
                            body_ref = body_ref( :, :, :, :, :, :, :, MR.Parameter.Parameter2Read.loca + 1, :, :, :, : );
                        else
                            error( 'Error in SENSEUnfold: The number of locations in the data and Sensitivity maps is different. Cannot determine which locations in the sensitivities belong to the data' );
                        end
                    end
                    
                    sens_dims = MR.Parameter.Scan.SENSEFactor > 1;
                    
                    
                    
                    
                    
                    
                    
                    
                    psi = [  ];
                    if isempty( psi )
                        if ~isempty( s_psi )
                            psi = single( s_psi );
                        else
                            psi = single( eye( size( sens_image, 4 ) ) );
                        end
                    end
                    
                    
                    
                    if strcmpi( MR.Parameter.Recon.ArrayCompression, 'yes' )
                        cur_nr_chans = size( sens_image, 4 );
                        for ac_in = 1:size( MR.Parameter.Recon.ACMatrix, 3 )
                            row_ind = min( [ size( MR.Parameter.Recon.ACMatrix, 1 ), find( isnan( MR.Parameter.Recon.ACMatrix( :, 1, ac_in ) ), 1 ) - 1 ] );
                            col_ind = min( [ size( MR.Parameter.Recon.ACMatrix, 2 ), find( isnan( MR.Parameter.Recon.ACMatrix( 1, :, ac_in ) ), 1 ) - 1 ] );
                            A = MR.Parameter.Recon.ACMatrix( 1:row_ind, 1:col_ind, ac_in );
                            
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
                            psi = A * psi * A;
                        end
                    end
                    
                    MR.Data = cellfun( @( x, y )MRecon.sense_recon( x, sens_image, psi, y, coil_ref, body_ref, MR.Parameter.Recon.SENSERegStrength ), MR.Data( 1, : ), res( 1, : ), 'UniformOutput', false );
                    
                    MR.Parameter.UpdateImageInfo = 1;
                    MR.Data = MR.UnconvertCell( MR.Data );
                    MR.Parameter.ReconFlags.isunfolded = 1;
                    
                end
                
            end
        end
        
        
        
        
        function ZeroFill( MR )
            if ~MR.Parameter.ReconFlags.isread
                error( 'Error in ZeroFill: Please read the data first' );
            end
            if ~MR.Parameter.ReconFlags.issorted
                error( 'Error in ZeroFill: Please sort the data first' );
            end
            
            if ~isempty( MR.Data )
                MR.Parameter.UpdateImageInfo = 0;
                MR.DataClass.Convert2Cell;
                
                if isempty( MR.Parameter.LabelLookupTable )
                    MR.Parameter.LabelLookupTable = cellfun( @( x )[  ], MR.Data, 'UniformOutput', 0 );
                else
                    MR.Parameter.LabelLookupTable = MR.Convert2Cell( MR.Parameter.LabelLookupTable );
                end
                
                if any( MR.Parameter.ReconFlags.isimspace )
                    if strcmpi( MR.Parameter.Recon.ImageSpaceZeroFill, 'yes' )
                        xres = cellfun( @( x, y )round( x * y ), MR.Parameter.Encoding.WorkEncoding.XReconRes, MR.Parameter.Encoding.WorkEncoding.KxOversampling, 'UniformOutput', 0 );
                        yres = cellfun( @( x, y )round( x * y ), MR.Parameter.Encoding.WorkEncoding.YReconRes, MR.Parameter.Encoding.WorkEncoding.KyOversampling, 'UniformOutput', 0 );
                        zres = cellfun( @( x, y )round( x * y ), MR.Parameter.Encoding.WorkEncoding.ZReconRes, MR.Parameter.Encoding.WorkEncoding.KzOversampling, 'UniformOutput', 0 );
                        
                        for i = 1:size( xres, 2 )
                            res = [ xres( :, i ), yres( :, i ), zres( :, i ) ];
                            mps = MR.Parameter.Encoding.WorkEncoding.MPS;
                            res = [ res( :, mps( 1 ) ), res( :, mps( 2 ) ), res( :, mps( 3 ) ) ];
                            xres_temp( :, i ) = res( :, 1 );
                            yres_temp( :, i ) = res( :, 2 );
                            zres_temp( :, i ) = res( :, 3 );
                        end
                        xres = xres_temp;
                        yres = yres_temp;
                        zres = zres_temp;
                        
                        xres = xres( 1:size( MR.Data, 1 ), 1:size( MR.Data, 2 ) );
                        yres = yres( 1:size( MR.Data, 1 ), 1:size( MR.Data, 2 ) );
                        zres = zres( 1:size( MR.Data, 1 ), 1:size( MR.Data, 2 ) );
                        
                        
                        xres_check = find( cellfun( @( x, y )max( [ 0, size( x, 1 ) > y ] ), MR.Data, xres ), 1 );
                        yres_check = find( cellfun( @( x, y )max( [ 0, size( x, 2 ) > y ] ), MR.Data, yres ), 1 );
                        zres_check = find( cellfun( @( x, y )max( [ 0, size( x, 3 ) > y ] ), MR.Data, zres ), 1 );
                        wrong_dim = min( [ xres_check, yres_check, zres_check ] );
                        if ~isempty( wrong_dim )
                            error( 'Error in ZeroFill: The current Data matrix is larger than what it should be after zero filling!\nThe Data matrix size is %d x %d x %d and you want to zero fill it to %d x %d x %d\nCheck the values of XReconRes, YReconRes, ZReconRes in Parameter.Encoding',  ...
                                size( MR.Data{ wrong_dim }, 1 ), size( MR.Data{ wrong_dim }, 2 ), size( MR.Data{ wrong_dim }, 3 ), max( [ xres{ wrong_dim }, 1 ] ), max( [ yres{ wrong_dim }, 1 ] ), max( [ zres{ wrong_dim }, 1 ] ) );
                        end
                        
                        factor = [ max( [ 1, xres{ 1, 1 } ./ size( MR.Data{ 1, 1 }, 1 ) ] ), max( [ 1, yres{ 1, 1 } ./ size( MR.Data{ 1, 1 }, 2 ) ] ), max( [ 1, zres{ 1, 1 } ./ size( MR.Data{ 1, 1 }, 3 ) ] ) ];
                        MR.Parameter.UpdateCurFOV( factor );
                        
                        MR.Data = cellfun( @( x, xr, yr, zr, l )zero_fill( x, xr, yr, zr ), MR.Data, xres, yres, zres, 'UniformOutput', 0 );
                        if ~isempty( MR.Parameter.LabelLookupTable{ 1 } )
                            MR.Parameter.LabelLookupTable = cellfun( @( x, yr, zr, l )zero_fill( x, [  ], yr, zr ), MR.Data, yres, zres, 'UniformOutput', 0 );
                        end
                        
                        MR.Parameter.ReconFlags.iszerofilled( 2 ) = 1;
                    end
                else
                    if strcmpi( MR.Parameter.Recon.kSpaceZeroFill, 'yes' )
                        xres = cellfun( @( x, y )round( x * y ), MR.Parameter.Encoding.WorkEncoding.XRes, MR.Parameter.Encoding.WorkEncoding.KxOversampling, 'UniformOutput', 0 );
                        yres = cellfun( @( x, y )round( x * y ), MR.Parameter.Encoding.WorkEncoding.YRes, MR.Parameter.Encoding.WorkEncoding.KyOversampling, 'UniformOutput', 0 );
                        zres = cellfun( @( x, y )round( x * y ), MR.Parameter.Encoding.WorkEncoding.ZRes, MR.Parameter.Encoding.WorkEncoding.KzOversampling, 'UniformOutput', 0 );
                        
                        if ~isempty( MR.Parameter.Scan.SENSEFactor ) && ~all( MR.Parameter.Scan.SENSEFactor( 1, : ) == 1 ) && ~MR.Parameter.ReconFlags.isunfolded
                            xres = cellfun( @( x )round( x / MR.Parameter.Scan.SENSEFactor( 1, min( [ 1, length( MR.Parameter.Scan.SENSEFactor ) ] ) ) ), xres, 'UniformOutput', 0 );
                            yres = cellfun( @( x )round( x / MR.Parameter.Scan.SENSEFactor( 1, min( [ 2, length( MR.Parameter.Scan.SENSEFactor ) ] ) ) ), yres, 'UniformOutput', 0 );
                            zres = cellfun( @( x )round( x / MR.Parameter.Scan.SENSEFactor( 1, min( [ 3, length( MR.Parameter.Scan.SENSEFactor ) ] ) ) ), zres, 'UniformOutput', 0 );
                        end
                        xres = xres( 1:size( MR.Data, 1 ), 1:size( MR.Data, 2 ) );
                        yres = yres( 1:size( MR.Data, 1 ), 1:size( MR.Data, 2 ) );
                        zres = zres( 1:size( MR.Data, 1 ), 1:size( MR.Data, 2 ) );
                        
                        for i = 1:size( xres, 2 )
                            res = [ xres( :, i ), yres( :, i ), zres( :, i ) ];
                            mps = MR.Parameter.Encoding.WorkEncoding.MPS;
                            res = [ res( :, mps( 1 ) ), res( :, mps( 2 ) ), res( :, mps( 3 ) ) ];
                            xres_temp( :, i ) = res( :, 1 );
                            yres_temp( :, i ) = res( :, 2 );
                            zres_temp( :, i ) = res( :, 3 );
                        end
                        xres = xres_temp;
                        yres = yres_temp;
                        zres = zres_temp;
                        
                        
                        
                        xres_check = find( cellfun( @( x, y )max( [ 0, size( x, 1 ) > y ] ), MR.Data, xres ), 1 );
                        yres_check = find( cellfun( @( x, y )max( [ 0, size( x, 2 ) > y ] ), MR.Data, yres ), 1 );
                        zres_check = find( cellfun( @( x, y )max( [ 0, size( x, 3 ) > y ] ), MR.Data, zres ), 1 );
                        wrong_dim = min( [ xres_check, yres_check, zres_check ] );
                        if ~isempty( wrong_dim )
                            error( 'Error in ZeroFill: The current Data matrix is larger than what it should be after zero filling!\nThe Data matrix size is %d x %d x %d and you want to zero fill it to %d x %d x %d\nCheck the values of XRes, YRes, ZRes in Parameter.Encoding',  ...
                                size( MR.Data{ wrong_dim }, 1 ), size( MR.Data{ wrong_dim }, 2 ), size( MR.Data{ wrong_dim }, 3 ), max( [ xres{ wrong_dim }, 1 ] ), max( [ yres{ wrong_dim }, 1 ] ), max( [ zres{ wrong_dim }, 1 ] ) );
                        end
                        
                        
                        
                        MR.Data = cellfun( @( x, xr, yr, zr, l )zero_fill( x, xr, yr, zr ), MR.Data, xres, yres, zres, 'UniformOutput', 0 );
                        MR.Parameter.LabelLookupTable = cellfun( @( x, yr, zr )zero_fill( x, [  ], yr, zr ), MR.Parameter.LabelLookupTable, yres, zres, 'UniformOutput', 0 );
                        MR.Parameter.ReconFlags.iszerofilled( 1 ) = 1;
                    end
                end
                
                MR.Parameter.LabelLookupTable = MR.UnconvertCell( MR.Parameter.LabelLookupTable );
                MR.Parameter.UpdateImageInfo = 1;
                MR.Data = MR.UnconvertCell( MR.Data );
            end
            
        end
        function RemoveOversampling( MR )
            if ~MR.Parameter.ReconFlags.isread
                error( 'Error in RemoveOversampling: Please read the data first' );
            end
            
            
            
            if ~isempty( MR.Data )
                
                if MR.Parameter.ReconFlags.issorted ||  ...
                        ( any( strcmpi( MR.Parameter.Scan.AcqMode, { 'Cartesian' } ) ) && ( ~strcmpi( MR.Parameter.Gridder.Preset, { 'Epi' } ) || MR.Parameter.ReconFlags.isgridded ) )
                    
                    MR.DataClass.Convert2Cell;
                    if isempty( MR.Parameter.LabelLookupTable )
                        MR.Parameter.LabelLookupTable = cellfun( @( x )[  ], MR.Data, 'UniformOutput', 0 );
                    else
                        MR.Parameter.LabelLookupTable = MR.Convert2Cell( MR.Parameter.LabelLookupTable );
                    end
                    
                    [ MR.Parameter.Encoding.WorkEncoding, MR.Parameter.LabelLookupTable ] = MRecon.check_cell_sizes( MR.Parameter.Encoding.WorkEncoding, MR.Parameter.LabelLookupTable, MR.Data );
                    
                    istransformed = 0;
                    
                    x_ovs = MR.Parameter.Encoding.WorkEncoding.KxOversampling;
                    y_ovs = MR.Parameter.Encoding.WorkEncoding.KyOversampling;
                    z_ovs = MR.Parameter.Encoding.WorkEncoding.KzOversampling;
                    fft_x = 1;
                    fft_y = 1;
                    fft_z = 1;
                    
                    if any( ~MR.Parameter.ReconFlags.isimspace )
                        istransformed = 1;
                        
                        fft_dim_bak = MR.Parameter.Encoding.WorkEncoding.FFTDims;
                        
                        fft_x = any( cellfun( @( x )x > 1 && ~MR.Parameter.ReconFlags.isimspace( 1 ), MR.Parameter.Encoding.WorkEncoding.KxOversampling( 1, : ) ) );
                        
                        if MR.Parameter.ReconFlags.issorted
                            if ~isempty( MR.Parameter.Encoding.KyRange )
                                fft_y = any( cellfun( @( x )max( [ x, 1 ] ) > 1 && ~MR.Parameter.ReconFlags.isimspace( 2 ), MR.Parameter.Encoding.WorkEncoding.KyOversampling( 1, : ) ) );
                            else
                                fft_y = 0;
                            end
                            if ~isempty( MR.Parameter.Encoding.KzRange )
                                fft_z = any( cellfun( @( x )max( [ x, 1 ] ) > 1 && ~MR.Parameter.ReconFlags.isimspace( 3 ), MR.Parameter.Encoding.WorkEncoding.KzOversampling( 1, : ) ) );
                            else
                                fft_z = 0;
                            end
                        else
                            fft_y = 0;
                            fft_z = 0;
                            x_ovs = MR.Parameter.Encoding.WorkEncoding.KxOversampling;
                            y_ovs = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.KyOversampling, 'UniformOutput', 0 );
                            z_ovs = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.KzOversampling, 'UniformOutput', 0 );
                            
                            MR.Parameter.Encoding.WorkEncoding.KxRange = cellfun( @( x, y )MRecon.set_k_ranges( x, y ), MR.Parameter.Encoding.WorkEncoding.KxRange,  ...
                                MR.Parameter.Encoding.WorkEncoding.KxOversampling, 'UniformOutput', 0 );
                            
                        end
                        
                        if all( [ fft_x, fft_y, fft_z ] == 0 )
                            istransformed = 0;
                        else
                            MR.Parameter.Encoding.WorkEncoding.FFTDims = [ fft_x, fft_y, fft_z ];
                        end
                        
                        
                        
                        
                        if ( MR.Parameter.Labels.Spectro && strcmpi( MR.Parameter.Spectro.Downsample, 'yes' ) )
                            
                            if MR.Parameter.ReconFlags.isimspace( 1 )
                                MR.Parameter.Encoding.FFTDims = [ 1, 0, 0 ];
                                MR.I2K;
                                istransformed = 1;
                            else
                                istransformed = 0;
                                MR.Parameter.Encoding.WorkEncoding.FFTDims = fft_dim_bak;
                            end
                        else
                            
                            if istransformed
                                MR.K2I;
                            end
                        end
                    end
                    
                    MR.DataClass.Convert2Cell;
                    
                    MR.Parameter.UpdateImageInfo = 0;
                    
                    if strcmpi( MR.Parameter.Recon.RemoveMOversampling, 'no' )
                        x_ovs = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.KyOversampling, 'UniformOutput', 0 );
                    end
                    if strcmpi( MR.Parameter.Recon.RemovePOversampling, 'no' )
                        y_ovs = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.KyOversampling, 'UniformOutput', 0 );
                        z_ovs = cellfun( @( x )[  ], MR.Parameter.Encoding.WorkEncoding.KzOversampling, 'UniformOutput', 0 );
                    end
                    
                    for i = 1:size( x_ovs, 2 )
                        ovs = [ x_ovs( :, i ), y_ovs( :, i ), z_ovs( :, i ) ];
                        mps = MR.Parameter.Encoding.WorkEncoding.MPS;
                        ovs = [ ovs( :, mps( 1 ) ), ovs( :, mps( 2 ) ), ovs( :, mps( 3 ) ) ];
                        x_ovs_temp( :, i ) = ovs( :, 1 );
                        y_ovs_temp( :, i ) = ovs( :, 2 );
                        z_ovs_temp( :, i ) = ovs( :, 3 );
                    end
                    x_ovs = x_ovs_temp;
                    y_ovs = y_ovs_temp;
                    z_ovs = z_ovs_temp;
                    
                    
                    if ( MR.Parameter.Labels.Spectro && strcmpi( MR.Parameter.Spectro.Downsample, 'yes' ) )
                        
                        MR.SpectroDownsample( x_ovs );
                        
                    else
                        
                        
                        [ MR.Data, MR.Parameter.LabelLookupTable ] = cellfun( @( x, y, ox, oy, oz )MR.rem_ovs( x, y, ox, oy, oz ),  ...
                            MR.Data,  ...
                            MR.Parameter.LabelLookupTable,  ...
                            x_ovs,  ...
                            y_ovs,  ...
                            z_ovs, 'UniformOutput', 0 );
                    end
                    
                    MR.Parameter.UpdateImageInfo = 1;
                    MR.Data = MR.UnconvertCell( MR.Data );
                    MR.Parameter.LabelLookupTable = MR.UnconvertCell( MR.Parameter.LabelLookupTable );
                    
                    
                    if istransformed
                        
                        if ( MR.Parameter.Labels.Spectro && strcmpi( MR.Parameter.Spectro.Downsample, 'yes' ) )
                            MR.K2I;
                            MR.Parameter.Encoding.FFTDims = fft_dim_bak;
                        else
                            
                            MR.I2K;
                            MR.Parameter.Encoding.WorkEncoding.FFTDims = fft_dim_bak;
                        end
                    end
                    
                    if fft_x && strcmpi( MR.Parameter.Recon.RemoveMOversampling, 'yes' )
                        MR.Parameter.ReconFlags.isoversampled( 1 ) = 0;
                    end
                    if fft_y && strcmpi( MR.Parameter.Recon.RemovePOversampling, 'yes' )
                        MR.Parameter.ReconFlags.isoversampled( 2 ) = 0;
                    end
                    if fft_z && strcmpi( MR.Parameter.Recon.RemovePOversampling, 'yes' )
                        MR.Parameter.ReconFlags.isoversampled( 3 ) = 0;
                    end
                end
            end
        end
        function ScaleData( MR )
            if any( ~MR.Parameter.ReconFlags.isimspace )
                error( 'The data must be scaled in image-space' );
            end
            
            if ~isempty( MR.Data )
                MR.Parameter.UpdateImageInfo = 0;
                MR.DataClass.Convert2Cell;
                
                MR.Data = cellfun( @( x )MR.scale_image( x ), MR.Data, 'UniformOutput', 0 );
                
                MR.Parameter.UpdateImageInfo = 1;
                MR.Data = MR.UnconvertCell( MR.Data );
            end
            
        end
        function RotateImage( MR )
            if ~isempty( MR.Data ) && strcmpi( MR.Parameter.Recon.RotateImage, 'yes' )
                if any( ~MR.Parameter.ReconFlags.isimspace )
                    error( 'Error in RotateImage: The data must be in image-space' );
                end
                
                if ~isempty( MR.Parameter.Scan.ijk ) && ~isempty( MR.Parameter.Scan.REC )
                    
                    if isfield( MR.Parameter.Labels, 'StackIndex' )
                        try
                            stack_nr = MR.Parameter.Labels.StackIndex( MR.Parameter.Parameter2Read.loca + 1 );
                        catch
                            stack_nr = [  ];
                        end
                    else
                        stack_nr = [  ];
                    end
                    
                    MR.Parameter.UpdateImageInfo = 0;
                    MR.DataClass.Convert2Cell;
                    
                    MR.Data = cellfun( @( x )MR.rotate_image_new( x, MR.Parameter.Scan.ijk, MR.Parameter.Scan.REC, stack_nr ),  ...
                        MR.Data, 'UniformOutput', 0 );
                    
                    
                    
                    for i = 1:size( MR.Parameter.Scan.curFOV, 1 )
                        if i <= size( MR.Parameter.Scan.ijk, 1 )
                            cur_ind = i;
                        else
                            cur_ind = size( MR.Parameter.Scan.ijk, 1 );
                        end
                        P = MRparameter.get_coord_transformation( MR.Parameter.Scan.ijk( cur_ind, : ), MR.Parameter.Scan.REC( cur_ind, : ) );
                        MR.Parameter.UpdateCurFOV( [  ], P, i );
                    end
                    
                    
                    
                    
                    
                    
                    
                    
                    if any( MR.Parameter.Scan.Venc ~= 0 ) && MR.Parameter.ReconFlags.issegmentsdivided
                        MR.Data = cellfun( @( x )MR.invert_flow_segments( x, MR.Parameter.Scan.Venc, MR.Parameter.Scan.MPS, stack_nr, strcmpi( MR.Parameter.Scan.PCAcqType, 'Hadamard' ) ),  ...
                            MR.Data, 'UniformOutput', 0 );
                    end
                    
                    
                    MR.Parameter.Scan.ijk = MR.Parameter.Scan.REC;
                    MR.Parameter.UpdateImageInfo = 1;
                    MR.Data = MR.UnconvertCell( MR.Data );
                end
                MR.Parameter.ReconFlags.isrotated = 1;
            end
        end
        function DivideFlowSegments( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if ~isempty( MR.Data ) && strcmpi( MR.Parameter.Recon.DivideFlowSegments, 'Yes' )
                if any( ~MR.Parameter.ReconFlags.isimspace )
                    error( 'Error in DivideFlowSegments: The DivideFlowSegments has to be performed in image space' );
                end
                
                MR.Parameter.UpdateImageInfo = 0;
                
                if ~isempty( MR.Parameter.Scan.Venc ) &&  ...
                        any( any( MR.Parameter.Scan.Venc ) ~= 0 ) &&  ...
                        strcmpi( MR.Parameter.Recon.CoilCombination, 'pc' )
                    
                    MR.DataClass.Convert2Cell;
                    MR.Data( 1, : ) = cellfun( @( x )MRecon.divide_segments( x, MR.Parameter.Scan.PCAcqType, MR.Parameter.Recon.TKE ), MR.Data( 1, : ), 'UniformOutput', 0 );
                    MR.Parameter.UpdateImageInfo = 1;
                    MR.Data = MR.UnconvertCell( MR.Data );
                    MR.Parameter.ReconFlags.issegmentsdivided = 1;
                end
            end
        end
        function ReconTKE( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if strcmpi( MR.Parameter.Recon.TKE, 'Yes' )
                if any( ~MR.Parameter.ReconFlags.isimspace )
                    error( 'Error in ReconTKE: The ReconTKE has to be performed in image space' );
                end
                if ( MR.Parameter.Recon.FluidDensity <= 0 )
                    error( 'Error in ReconTKE: Please set a fluid density [kg/m^3] in Parameter.Recon.FluidDensity' );
                end
                MR.DataClass.Convert2Cell;
                [ MR.Data( :, 1 ), MR.Data( :, 2 ) ] = cellfun( @( x )MRecon.recon_tke( x, MR.Parameter.Recon.FluidDensity, MR.Parameter.Recon.kv, MR.Parameter.Scan.Venc ), MR.Data( 1, : ), 'UniformOutput', 0 );
                MR.Data = MR.UnconvertCell( MR.Data );
                
                
                fields = fieldnames( MR.Parameter.Encoding.WorkEncoding );
                for i = 1:length( fields )
                    name = char( fields( i ) );
                    MR.Parameter.Encoding.WorkEncoding.( name )( 2 ) = MR.Parameter.Encoding.WorkEncoding.( name )( 1 );
                end
            end
        end
        function Average( MR )
            if strcmpi( MR.Parameter.Recon.Average, 'yes' )
                MR.DataClass.Convert2Cell;
                if ~MR.Parameter.ReconFlags.issorted
                    error( 'Error in Average: Please sort the data first' );
                end
                
                if MR.Parameter.Labels.Spectro
                    MR.SpectroAverage;
                end
                
                average = any( cellfun( @( x )size( x, 12 ) > 1, MR.Data ) );
                if average && ~MR.Parameter.Labels.Spectro
                    if strcmpi( MR.Parameter.Scan.Diffusion, 'yes' )
                        
                        if ( ~MR.Parameter.ReconFlags.isdepicorr )
                            warning( 'Warning in Average: Diffusion images should be averaged after the the EPI correction' );
                        end
                        
                        MR.Data = cellfun( @( x )mean( abs( x ), 12 ), MR.Data, 'UniformOutput', 0 );
                    else
                        MR.Data = cellfun( @( x )mean( x, 12 ), MR.Data, 'UniformOutput', 0 );
                    end
                end
                MR.Data = MR.UnconvertCell( MR.Data );
                
                MR.Parameter.ReconFlags.isaveraged = 1;
                
            end
        end
        
        
        
        
        function RaleREC( MR )
            try
                data = MR.Data;
                for i = 1:length( MR.Parameter.ImageInformation( : ) )
                    if ( MR.Parameter.ImageInformation( i ).ImageType ~= 3 )
                        data( :, :, i ) = data( :, :, i ) .* MR.Parameter.ImageInformation( i ).RaleSlope + MR.Parameter.ImageInformation( i ).RaleIntercept;
                    else
                        
                        data( :, :, i ) = data( :, :, i ) ./ 4095 .* 2 * pi - pi;
                    end
                end
                MR.Data = data;
            catch exeption
                s = sprintf( 'could not Rale the REC images. Error in: \nfunction: %s\nline: %d\nerror: %s', exeption.stack( 1 ).name, exeption.stack( 1 ).line, exeption.message );
                warning( 'MATLAB:MRecon', s );
            end
        end
        function CreateComplexREC( MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if ~strcmpi( MR.Parameter.DataFormat, 'Rec' )
                error( 'Error in CreateComplexREC: This function can only be executed on REC data' );
            end
            
            try
                if size( MR.Data, 7 ) > 1
                    MR.Data = MR.Data( :, :, :, :, :, :, 1, :, :, :, :, : ) .* exp( 1i .* MR.Data( :, :, :, :, :, :, 2, :, :, :, :, : ) );
                end
            catch exeption
                s = sprintf( 'could not Rale the REC images. Error in: \nfunction: %s\nline: %d\nerror: %s', exeption.stack( 1 ).name, exeption.stack( 1 ).line, exeption.message );
                warning( 'MATLAB:MRecon', s );
            end
        end
        
        
        
        
        function ShowData( MR )
            if isempty( MR.Data )
                error( 'Error in ShowData: The data array is empty' )
            end
            if iscell( MR.Data )
                for i = 1:size( MR.Data, 1 );
                    for j = 1:size( MR.Data, 2 );
                        if ~isempty( MR.Data{ i, j } )
                            if isreal( MR.Data )
                                imslide( MR.Data{ i, j } )
                            else
                                imslide( angle( MR.Data{ i, j } ) )
                                imslide( abs( MR.Data{ i, j } ) )
                            end
                        end
                    end
                end
            else
                if ~isempty( MR.Data )
                    if isreal( MR.Data )
                        imslide( MR.Data )
                    else
                        imslide( angle( MR.Data ) )
                        imslide( abs( MR.Data ) )
                    end
                end
            end
        end
        function CreateVideo( MR, Dimension, Filename, Framerate, OutputFormat, StartFrame, EndFrame )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if ( nargin > 7 )
                error( 'Too many input arguments' );
            elseif nargin > 6
            elseif nargin > 5
                EndFrame =  - 1;
            elseif nargin > 4
                StartFrame = 1;
                EndFrame =  - 1;
            elseif nargin > 3
                OutputFormat = 'avi';
                StartFrame = 1;
                EndFrame =  - 1;
            elseif nargin > 2
                Framerate = 15;
                OutputFormat = 'avi';
                StartFrame = 1;
                EndFrame =  - 1;
            elseif nargin > 1
                Filename = '';
                Framerate = 15;
                OutputFormat = 'avi';
                StartFrame = 1;
                EndFrame =  - 1;
            else
                Dimension = 5;
                Filename = '';
                Framerate = 15;
                OutputFormat = 'avi';
                StartFrame = 1;
                EndFrame =  - 1;
            end
            
            
            
            if ( Dimension < 1 || Dimension > 13 )
                error( 'The dimension has to be between 1 and 13' );
            end
            if ( Framerate < 0 )
                error( 'The framerate has to be larger than 0' );
            end
            
            selection_string = [ '::11111111111';',,,,,,,,,,,,,' ];
            selection_string( 1, Dimension ) = ':';
            %selection_string = selection_string( : );
            selection_string = selection_string( 1:end  - 1 );
            eval( [ 'data = squeeze(abs(MR.Data(', selection_string, ')));' ] );
            
            
            Max = max( max( max( data( :, :, ceil( size( data, 3 ) / 20:size( data, 3 ) ) ) ) ) );
            
            if ( isempty( Filename ) )
                Filename = strcat( 'scan', num2str( MR.Parameter.Scan.AcqNo ), '_framerate', num2str( ceil( Framerate ) ), 'fps.', OutputFormat );
            end
            if ( EndFrame ==  - 1 )
                EndFrame = size( data, 3 );
            end
            if ( EndFrame > size( data, 3 ) )
                EndFrame = size( data, 3 );
            end
            
            if ( StartFrame <= 0 )
                error( 'The start frame has to be larger than 0' );
            end
            if ( StartFrame > EndFrame )
                error( 'The start frame has to be smaller than the end frame' );
            end
            
            
            switch OutputFormat
                
                case 'avi'
                    vidObj = VideoWriter( Filename );
                    vidObj.FrameRate = Framerate;
                    open( vidObj );
                    a = figure;
                    for frame = StartFrame:EndFrame
                        image( data( :, :, frame ), 'CDataMapping', 'scaled' ), caxis( [ 0, Max ] );set( gca, 'DataAspectRatio', [ 1, 1, 1 ] );
                        axis off, colormap gray;
                        frame = getframe( gcf );
                        writeVideo( vidObj, frame );
                    end
                    close( gcf )
                    close( vidObj );
                    
                case 'gif'
                    delaytime = 1 / Framerate;
                    for i = StartFrame:EndFrame
                        I = mat2gray( data( :, :, i ) );
                        [ X, map ] = gray2ind( I, 256 );
                        if i == StartFrame;
                            imwrite( X, map, Filename, 'gif', 'LoopCount', Inf, 'DelayTime', delaytime );
                        else
                            imwrite( X, map, Filename, 'gif', 'WriteMode', 'append', 'DelayTime', delaytime );
                        end
                    end
                otherwise
                    error( 'Video format not supported' );
            end
        end
        
        
        
        
        function varargout = Transform( MR, varargin )
            if isfield( MR.Parameter.Labels, 'StackIndex' )
                stacks = unique( MR.Parameter.Labels.StackIndex );
            else
                stacks = 0;
            end
            nr_stacks = length( stacks );
            matrix_size = [  ];
            fov = [  ];
            angulation = [  ];
            offcentre = [  ];
            slice_gap = [  ];
            
            if length( varargin ) == 0
                error( 'Error in Transform: please specify the input and output coordinate system' );
            end
            if ischar( varargin{ 1 } )
                matrix_only_mode = 1;
            else
                matrix_only_mode = 0;
            end
            
            if matrix_only_mode
                if length( varargin ) < 2
                    error( 'Error in Transform: please specify the input and output coordinate system' );
                end
                if ~ischar( varargin{ 2 } )
                    error( 'Error in Transform: The output coordinate system must be a string' );
                end
                if length( varargin ) == 2
                    stack = 1:nr_stacks;
                    option_start = 3;
                else
                    if ischar( varargin{ 3 } )
                        option_start = 3;
                        stack = 1:nr_stacks;
                    else
                        stack = varargin{ 3 };
                        option_start = 4;
                    end
                end
                from = varargin{ 1 };
                to = varargin{ 2 };
                x = [ 1, 1, 1 ];
            else
                if length( varargin ) < 3
                    error( 'Error in Transform: please specify the input and output coordinate system' );
                end
                if ~ischar( varargin{ 3 } )
                    error( 'Error in Transform: The output coordinate system must be a string' );
                end
                if length( varargin ) == 3
                    stack = 1;
                    option_start = 4;
                else
                    if ischar( varargin{ 4 } )
                        stack = 1;
                        option_start = 4;
                        error( 'Error in Transform: The stack number must be numeric' );
                    else
                        stack = varargin{ 4 };
                        option_start = 5;
                    end
                end
                from = varargin{ 2 };
                to = varargin{ 3 };
                x = varargin{ 1 };
            end
            
            if length( varargin ) >= option_start
                for i = option_start:2:length( varargin )
                    if ischar( varargin{ i } ) && strcmpi( varargin{ i }, 'MatrixSize' )
                        if length( varargin ) < i + 1
                            error( 'Error in Transform: Please specify an option value for MatrixSize' );
                        else
                            matrix_size = varargin{ i + 1 };
                        end
                    end
                    if ischar( varargin{ i } ) && strcmpi( varargin{ i }, 'FOV' )
                        if length( varargin ) < i + 1
                            error( 'Error in Transform: Please specify an option value for FOV' );
                        else
                            fov = varargin{ i + 1 };
                        end
                    end
                    if ischar( varargin{ i } ) && strcmpi( varargin{ i }, 'Angulation' )
                        if length( varargin ) < i + 1
                            error( 'Error in Transform: Please specify an option value for Angulation' );
                        else
                            angulation = varargin{ i + 1 };
                        end
                    end
                    if ischar( varargin{ i } ) && strcmpi( varargin{ i }, 'Offcentre' )
                        if length( varargin ) < i + 1
                            error( 'Error in Transform: Please specify an option value for Offcentre' );
                        else
                            offcentre = varargin{ i + 1 };
                        end
                    end
                    if ischar( varargin{ i } ) && strcmpi( varargin{ i }, 'SliceGap' )
                        if length( varargin ) < i + 1
                            error( 'Error in Transform: Please specify an option value for SliceGap' );
                        else
                            slice_gap = varargin{ i + 1 };
                        end
                    end
                end
            end
            
            [ xT, A ] = MR.Parameter.Transform( x, from, to, stack, angulation, offcentre, matrix_size, fov, slice_gap );
            if matrix_only_mode
                varargout{ 1 } = A;
            else
                varargout{ 1 } = xT;
                varargout{ 2 } = A;
            end
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
            new.DataClass = new.Parameter.DataClass;
        end
        
        
        
        
        function Search( this, search_text, filter )
            if ( nargin == 2 )
                filter = '';
            end
            
            this.Parameter.Search( search_text, filter );
            
            if ( isempty( filter ) || strcmpi( filter, 'mrecon' ) )
                disp( ' ' );
                disp( ' ' );
                disp( '--------------------------------------' );
                disp( 'Search results in MRecon parameter:' );
                disp( '--------------------------------------' );
                MRecon.search( this, search_text, '' );
            end
        end
        
        
        
        
        function Compare( this, other )
            MRecon.compare( this, other, '' );
        end
        
        
        
        
        function [ MemoryNeeded, MemoryAvailable, MaxDataSize ] = GetMemoryInformation( MR )
            P = MR.Parameter.Parameter2Read.Copy;
            
            ProfileMask = ( ismember( MR.Parameter.Labels.Index.typ, P.typ ) &  ...
                ismember( MR.Parameter.Labels.Index.mix, P.mix ) &  ...
                ismember( MR.Parameter.Labels.Index.dyn, P.dyn ) &  ...
                ismember( MR.Parameter.Labels.Index.card, P.card ) &  ...
                ismember( MR.Parameter.Labels.Index.loca, P.loca ) &  ...
                ismember( MR.Parameter.Labels.Index.echo, P.echo ) &  ...
                ismember( MR.Parameter.Labels.Index.extr1, P.extr1 ) &  ...
                ismember( MR.Parameter.Labels.Index.extr2, P.extr2 ) &  ...
                ismember( MR.Parameter.Labels.Index.ky, P.ky ) &  ...
                ismember( MR.Parameter.Labels.Index.kz, P.kz ) );
            
            
            
            if isfield( MR.Parameter.Labels.Index, 'aver' )
                ProfileMask = ( ProfileMask &  ...
                    ismember( MR.Parameter.Labels.Index.aver, P.aver ) &  ...
                    ismember( MR.Parameter.Labels.Index.rtop, P.rtop ) );
            end
            NrImagingProfiles = length( find( ProfileMask ) );
            DataSizeAfterRead = NrImagingProfiles * max( MR.Parameter.Encoding.DataSizeByte );
            
            Nr3dChunks = length( P.mix ) * length( P.chan ) * length( P.dyn ) * length( P.card ) * length( P.loca ) * length( P.echo ) * length( P.extr1 ) * length( P.extr2 ) * length( P.aver );
            Size3dChunk = max( [ 1, max( MR.Parameter.Encoding.XRes ) ] ) * max( [ 1, max( MR.Parameter.Encoding.YRes ) ] ) * max( [ 1, max( MR.Parameter.Encoding.ZRes ) ] ) *  ...
                max( [ 1, max( MR.Parameter.Encoding.KyOversampling ) ] ) * max( [ 1, max( MR.Parameter.Encoding.KzOversampling ) ] ) ./  ...
                prod( MR.Parameter.Scan.SENSEFactor );
            DataSizeAfterZeroFill = Size3dChunk * Nr3dChunks * 2 * 4;
            
            MaxDataSize = max( [ DataSizeAfterRead, DataSizeAfterZeroFill ] );
            MemoryNeeded = 2.3 * MaxDataSize;
            
            try
                [ uV, sV ] = MRecon.memory_mac;
                MemoryAvailable = sV.PhysicalMemory.Available;
            catch
                MemoryAvailable = 1.5 * MemoryNeeded;
            end
        end
        
        
        
        
        
        function EddyCurrentCorrection( MR )
            
            if ~MR.Parameter.Labels.Spectro
                error( 'This eddy current correction procedure is just intended for spectroscopy data' );
            end
            
            switch lower( MR.Parameter.Recon.EddyCurrentCorrection )
                case 'yes'
                    if ~MR.Parameter.ReconFlags.isread
                        error( 'Please read the data first' );
                    end
                    if ~MR.Parameter.ReconFlags.issorted
                        error( 'Please sort the data first' );
                    end
                    if MR.Parameter.ReconFlags.isecc
                        error( 'Data is already eddy current corrected' );
                    end
                    if ( MR.Parameter.Encoding.NrMixes < 2 )
                        error( 'No unsuppressed water scan was found' );
                    end
                    
                    fft_dim_bak = MR.Parameter.Encoding.FFTDims;
                    
                    
                    if MR.Parameter.ReconFlags.isimspace( 1 )
                        MR.Parameter.Encoding.FFTDims = [ 1, 0, 0 ];
                        MR.I2K;
                        istransformed = true;
                    else
                        istransformed = false;
                    end
                    
                    nr_ref_scans = MR.Parameter.Encoding.WorkEncoding.NrFids{ 2 };
                    
                    if ( nr_ref_scans > 1 )
                        warning( 'Ref scan data is not yet averaged. Using an average/dynamic for correction' );
                    end
                    
                    fprintf( 'Applying eddy current correction ...\n' );
                    
                    ref_scan = sum( MR.Data{ 1, 2 }, 12 );
                    ref_scan_phase = exp(  - 1i * angle( ref_scan ) );
                    MR.Data{ 1, 1 } = bsxfun( @times, MR.Data{ 1, 1 }, ref_scan_phase );
                    MR.Data{ 1, 2 } = bsxfun( @times, MR.Data{ 1, 2 }, ref_scan_phase );
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    if istransformed
                        MR.K2I;
                        MR.Parameter.Encoding.FFTDims = fft_dim_bak;
                    end
                    
                    if ( MR.Parameter.Chunk.CurLoop == MR.Parameter.Chunk.NrLoops )
                        MR.Parameter.ReconFlags.isecc = true;
                    end
                    
                otherwise
                    warning( 'Eddy correction is deselected, skipping processing step ...' );
            end
            
        end
        
        
        
        function WriteSdat( MR, varargin )
            
            if ~MR.Parameter.ReconFlags.isread
                error( 'Please read the data first' );
            end
            if ~MR.Parameter.ReconFlags.issorted
                error( 'Expecting already sorted data' );
            end
            
            
            
            if ~( ( MR.Parameter.ReconFlags.isimspace( 1 ) == 0 ) && ( MR.Parameter.ReconFlags.isimspace( 2 ) == 1 ) && ( MR.Parameter.ReconFlags.isimspace( 3 ) == 1 ) )
                
                error( 'Data must be in time domain and real space in order to write sdat' );
            end
            if ( nargin > 2 )
                error( 'Only one input argument should specify the desired filename' );
            end
            
            MR.DataClass.Convert2Cell;
            
            if ( any( [ size( MR.Data{ 1 }, MR.dim.coil ), size( MR.Data{ 1 }, MR.dim.hp ), size( MR.Data{ 1 }, MR.dim.echo ),  ...
                    size( MR.Data{ 1 }, MR.dim.loc ), size( MR.Data{ 1 }, MR.dim.mix ), size( MR.Data{ 1 }, MR.dim.extr1 ), size( MR.Data{ 1 }, MR.dim.extr2 ) ] ) > 1 )
                error( 'Only fully reconstructed SV or CSI data can be saved to SDAT/SPAR files' );
            end
            
            [ path, filename, ~ ] = fileparts( MR.Parameter.Filename.Data );
            path = [ path, filesep ];
            if ( MR.Parameter.IsParameter( 'RFR_STUDY_DICOM_STUDY_DATE' ) )
                scan_date_raw = MR.Parameter.GetValue( 'RFR_STUDY_DICOM_STUDY_DATE' );
                if length( scan_date_raw ) < 8
                    scan_date = '01/01/1900';
                else
                    scan_date = [ scan_date_raw( 7:8 ), '/', scan_date_raw( 5:6 ), '/', scan_date_raw( 1:4 ) ];
                end
            else
                scan_date_raw = char( regexpi( filename, '_\d{8}_\d{7}', 'match' ) );
                if length( scan_date_raw ) < 9
                    scan_date = '01/01/1900';
                else
                    scan_date = [ scan_date_raw( 7:8 ), '/', scan_date_raw( 4:5 ), '/', scan_date_raw( 6:9 ) ];
                end
            end
            
            if ( nargin > 1 )
                [ pp, filename, ~ ] = fileparts( varargin{ 1 } );
                if ~isempty( pp )
                    path = pp;
                else
                    path = [ pwd, filesep ];
                end
            end
            
            par.examination_name = 'unknown';
            par.scan_id = filename( 21:end  );
            
            par.scan_date = [ scan_date( 7:10 ), '.', scan_date( 4:5 ), '.', scan_date( 1:2 ) ];
            
            for mix_cnt = 1:MR.Parameter.Encoding.NrMixes
                par.patient_name = 'unknown';
                par.patient_birth_date = 'unknown';
                par.patient_position = [ '"', MR.Parameter.Scan.PatientPosition, '"' ];
                par.patient_orientation = [ '"', MR.Parameter.Scan.PatientOrientation, '"' ];
                par.samples = MR.Parameter.Encoding.XRes( mix_cnt );
                par.rows = MR.Parameter.Scan.Samples( 2 ) * MR.Parameter.Scan.Samples( 3 ) * MR.Parameter.Encoding.WorkEncoding.NrDyn{ 1 };
                par.synthesizer_frequency = MR.Parameter.Labels.ResonanceFreq;
                par.offset_frequency = 0;
                par.sample_frequency = 32e3 / MR.Parameter.Encoding.KxOversampling( 1 );
                par.echo_nr = 1;
                par.mix_number = 1;
                par.nucleus = '1H';
                par.t0_mu1_direction = 0;
                par.echo_time = MR.Parameter.Scan.TE;
                par.repetition_time = MR.Parameter.Scan.TR( mix_cnt );
                par.averages = 1;
                par.volume_selection_enable = '"yes"';
                par.volumes = 1;
                par.ap_size = MR.Parameter.Scan.FOV( 1 );
                par.lr_size = MR.Parameter.Scan.FOV( 2 );
                par.cc_size = MR.Parameter.Scan.FOV( 3 );
                par.ap_off_center = MR.Parameter.Scan.Offcentre( 1 );
                par.lr_off_center = MR.Parameter.Scan.Offcentre( 2 );
                par.cc_off_center = MR.Parameter.Scan.Offcentre( 3 );
                par.ap_angulation = MR.Parameter.Scan.Angulation( 1 );
                par.lr_angulation = MR.Parameter.Scan.Angulation( 2 );
                par.cc_angulation = MR.Parameter.Scan.Angulation( 3 );
                par.volume_selection_method = 1;
                par.t1_measurement_enable = '"no"';
                par.t2_measurement_enable = '"no"';
                par.time_series_enable = '"no"';
                par.phase_encoding_enable = '"yes"';
                par.nr_phase_encoding_profiles = max( MR.Parameter.Scan.Samples( 2:3 ) );
                par.ps_ap_off_center = 0;
                par.ps_lr_off_center = 0;
                par.ps_cc_off_center = 0;
                par.ps_ap_angulation = 0;
                par.ps_lr_angulation = 0;
                par.ps_cc_angulation = 0;
                
                par.si_ap_off_center = par.ap_off_center;
                par.si_lr_off_center = par.lr_off_center;
                par.si_cc_off_center = par.cc_off_center;
                par.si_ap_off_angulation = par.ap_angulation;
                par.si_lr_off_angulation = par.lr_angulation;
                par.si_cc_off_angulation = par.cc_angulation;
                par.t0_kx_direction = 50;
                par.t0_ky_direction = 50;
                par.nr_of_phase_encoding_profiles_ky = MR.Parameter.Scan.Samples( 3 );
                par.phase_encoding_direction = '"trans"';
                par.phase_encoding_fov = MR.Parameter.Scan.FOV( 1 );
                par.slice_thickness = par.cc_size;
                par.image_plane_slice_thickness = 0;
                par.slice_distance = 0;
                par.nr_of_slices_for_multislice = 1;
                par.Spec_imageinplanetransf = '"plusA-plusB"';
                par.spec_data_type = 'cf';
                par.spec_sample_extension = '[V]';
                par.spec_num_col = par.samples;
                par.spec_col_lower_val = 0;
                par.spec_col_upper_val = 0;
                par.spec_col_extension = '[sec]';
                par.spec_num_row = par.rows;
                par.spec_row_lower_val = 1;
                par.spec_row_upper_val = par.rows;
                par.spec_row_extension = '[index]';
                par.num_dimensions = 3;
                par.dim1_ext = '[sec]';
                par.dim1_pnts = par.samples;
                par.dim1_low_val =  - par.sample_frequency / 2;
                par.dim1_step = 1 / par.sample_frequency;
                par.dim1_direction = 'mu1';
                par.dim1_t0_point = 0;
                par.dim2_ext = '[num]';
                par.dim2_pnts = par.nr_phase_encoding_profiles;
                par.dim2_low_val = 1;
                par.dim2_step = 1;
                par.dim2_direction = 'x';
                par.dim2_t0_point = 50;
                par.dim3_ext = '[num]';
                par.dim3_pnts = par.nr_of_phase_encoding_profiles_ky;
                par.dim3_low_val = 1;
                par.dim3_step = 1;
                par.dim3_direction = 'y';
                par.dim3_t0_point = 50;
                par.echo_acquisition = 'FID';
                par.TSI_factor = 0;
                par.spectrum_echo_time = par.echo_time;
                par.spectrum_inversion_time = 0;
                par.image_chemical_shift = 0;
                par.resp_motion_comp_technique = 'NONE';
                par.de_coupling = 'NO';
                
                switch mix_cnt
                    case 1
                        fullfilename = sprintf( '%s%s', path, filename );
                    case 2
                        fullfilename = sprintf( '%s%s_ref', path, filename );
                    otherwise
                        error( 'Can not handle more than 2 mixes for writing sdat files' );
                end
                
                fid = permute( squeeze( MR.Data{ 1, mix_cnt } ), [ 1, 3, 2 ] );
                
                
                
                fid = reshape( fid, [ par.samples, par.rows ] );
                fid = permute( fid, [ 2, 1 ] );
                
                
                MR.write_sdat( fullfilename, fid, par, 'd' );
            end
            
            MR.Data = MR.UnconvertCell( MR.Data );
        end
        
        
        
        
        
        function obj = set.Data( obj, val )
            obj.DataClass.Matrix = val;
            if obj.Parameter.UpdateImageInfo && strcmpi( obj.Parameter.Recon.AutoUpdateInfoPars, 'Yes' )
                obj.Parameter.UpdateInfoPars;
            end
        end
        function value = get.Data( obj )
            value = obj.DataClass.Matrix;
        end
        
        function ParString = WritePar2String( MR )
            if isempty( MR.Parameter.ImageInformation )
                error( 'Parameter.ImageInformation struct is empty. Please set Parameter.Recon.AutoUpdateInfoPars to yes' );
            end
            
            if any( any( MR.Parameter.Scan.Venc ) ~= 0 )
                MR.Parameter.Recon.ExportRECImgTypes = { 'M', 'P' };
            end
            
            auto_update_status = MR.Parameter.Recon.AutoUpdateInfoPars;
            MR.Parameter.Recon.AutoUpdateInfoPars = 'no';
            
            MR.DataClass.Convert2Cell;
            MR.Parameter.UpdatalingPars;
            
            NY = 'NY';
            
            nr_images = 0;
            for i = 1:size( MR.Data, 2 )
                if ~isempty( MR.Data{ 1, i } )
                    nr_images = nr_images + size( MR.Data{ 1, i }( :, :, : ), 3 );
                end
            end
            
            nr_images2 = 0;
            if ( strcmpi( MR.Parameter.Recon.TKE, 'Yes' ) && ( size( MR.Data, 2 ) == 2 ) )
                nr_images2 = size( MR.Data{ 1, 2 }( :, :, : ), 3 );
            end
            I = InfoPars( nr_images );
            cur_img = 1;
            for i = 1:size( MR.Data, 2 )
                if ~isempty( MR.Data{ 1, i } )
                    
                    if iscell( MR.Parameter.ImageInformation )
                        I( cur_img:cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = MR.Parameter.ImageInformation{ 1, i }( : );
                    else
                        I( cur_img:cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = MR.Parameter.ImageInformation( : );
                    end
                    cur_img = cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 );
                end
            end
            
            if isempty( MR.Parameter.Scan.Multivenc ) || ( strcmpi( MR.Parameter.Scan.Multivenc, 'no' ) )
                if ( ~isempty( MR.Parameter.Recon.Venc ) && sum( MR.Parameter.Recon.Venc ~= 0 ) > 1 )
                    nr_files = size( MR.Data{ 1 }, 10 );
                    for ffile = 1:nr_files
                        ParString{ ffile } = '';
                    end
                else
                    ParString{ 1 } = '';
                end
            else
                venc_dir = sum( MR.Parameter.Recon.Venc > 0, 1 );
                if sum( venc_dir ) > 0
                    for nr = 1:sum( venc_dir )
                        ParString{ nr } = '';
                    end
                    if nr_images2 > 0
                        ParString{ nr + 1 } = '';
                    end
                else
                    ParString{ 1 } = '';
                end
            end
            
            v = MRparameter.convert_parameter2output_struct( MR.Parameter );
            
            slashind = [ strfind( MR.Parameter.Filename.Data, '\' ), strfind( MR.Parameter.Filename.Data, '/' ) ];
            dotind = strfind( MR.Parameter.Filename.Data, '.' );
            if isempty( slashind )
                slashind = 1;
            end
            if isempty( dotind )
                dotind = length( MR.Parameter.Filename.Data );
            end
            dataset_name = MR.Parameter.Filename.Data( slashind( end  ) + 1:dotind( end  ) - 1 );
            
            venc_ind = abs( MRparameter.coord2num( MRparameter.unformat_coord_str( MR.Parameter.Scan.ijk( 1, : ) ) ) );
            for i = 1:length( ParString )
                
                if isempty( MR.Parameter.Recon.Venc )
                    MR.Parameter.Recon.Venc = MR.Parameter.Scan.Venc;
                end
                if size( MR.Parameter.Recon.Venc, 2 ) < 3
                    MR.Parameter.Recon.Venc( :, end  + 1:3 ) = 0;
                end
                
                if strcmpi( MR.Parameter.Scan.Multivenc, 'no' )
                    if ~isempty( MR.Parameter.Recon.Venc )
                        venc = v.PhaseEncodingVelocity .* 0;
                        if sum( MR.Parameter.Recon.Venc ~= 0 ) > 1
                            try
                                venc( venc_ind( i ) ) = MR.Parameter.Recon.Venc( i );
                            catch
                                venc = [ 0, 0, 0 ];
                            end
                        else
                            venc = MR.Parameter.Recon.Venc;
                        end
                    else
                        venc = [ 0, 0, 0 ];
                    end
                else
                    venc = MR.Parameter.Recon.Venc( i, : );
                end
                
                
                ParString{ i } = [ ParString{ i }, sprintf( '# === DATA DRIPTION FILE ======================================================\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '# CAUTION - Investigational device.\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '# Limited by Federal Law to investigational use.\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '# Dataset name: %s\n', dataset_name ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '# Exported by MRecon (c)Gyrotools GmbH, Zuerich Switzerland (http://www.gyrotools.ch/)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '# CLINICAL TRYOUT             Research image export tool     V4.1\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '# === GENERAL INFORMATION ========================================================\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#\n' ) ];
                
                ParString{ i } = [ ParString{ i }, sprintf( '.    Patient name                       :   %s\n', v.PatientName ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Examination name                   :   %s\n', v.ExaminationName ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Protocol name                      :   %s\n', v.ProtocolName ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Examination date/time              :   %s / %s\n', v.ExaminationDate, v.ExaminationTime ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Series_data_type                   :   %d\n', 0 ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Acquisition nr                     :   %d\n', v.AquisitionNumber ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Reconstruction nr                  :   %d\n', v.ReconstructionNumber ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Scan Duration [sec]                :   %0.2f\n', 0 ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Max. number of cardiac phases      :   %d\n', v.MaxNoPhases ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Max. number of echoes              :   %d\n', v.MaxNoEchoes ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Max. number of slices/locations    :   %d\n', v.MaxNoSlices ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Max. number of dynamics            :   %d\n', v.MaxNoDynamics ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Max. number of mixes               :   %d\n', v.MaxNoMixes ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Patient Position                   :   %s\n', v.PatientPosition ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Preparation direction              :   %s\n', v.PreparationDirection( 1, : ) ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Technique                          :   %s\n', v.Technique ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Scan resolution  (x, y)            :   %-3d  %3d\n', v.ScanResolutionX, v.ScanResolutionY ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Scan mode                          :   %s\n', v.ScanMode ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Repetition time [msec]             :   %0.2f\n', v.RepetitionTimes( 1 ) ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    FOV (ap,fh,rl) [mm]                :   %-5.2f %5.2f %5.2f\n', v.FOVAP, v.FOVFH, v.FOVRL ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Water Fat shift [pixels]           :   %0.2f\n', v.WaterFatShift ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Angulation midslice(ap,fh,rl)[degr]:   %-6.2f %-6.2f %-6.2f\n', v.AngulationAP, v.AngulationFH, v.AngulationRL ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Off Centre midslice(ap,fh,rl) [mm] :   %-6.2f %-6.2f %-6.2f\n', v.OffCenterAP, v.OffCenterFH, v.OffCenterRL ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Flow compensation <0=no 1=yes> ?   :   %d\n', findstr( NY, v.FlowCompensation ) - 1 ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Presaturation     <0=no 1=yes> ?   :   %d\n', findstr( NY, v.Presaturation ) - 1 ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Phase encoding velocity [cm/sec]   :   %-5.2f %5.2f %5.2f\n', venc( 1 ), venc( 2 ), venc( 3 ) ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    MTC               <0=no 1=yes> ?   :   %d\n', findstr( NY, v.MTC ) - 1 ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    SPIR              <0=no 1=yes> ?   :   %d\n', findstr( NY, v.SPIR ) - 1 ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    EPI factor        <0,1=no EPI>     :   %d\n', v.EPIfactor ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Dynamic scan      <0=no 1=yes> ?   :   %d\n', findstr( NY, v.DynamicScan ) - 1 ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Diffusion         <0=no 1=yes> ?   :   %d\n', findstr( NY, v.Diffusion ) - 1 ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Diffusion echo time [msec]         :   %0.2f\n', v.DiffusionEchoTime ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Max. number of diffusion values    :   %d\n', v.DiffusionValues ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Max. number of gradient orients    :   %d\n', v.GradientOris ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '.    Number of label types   <0=no ASL> :   %d\n', v.ASLNolabelTypes ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#\n' ) ];
                
                ParString{ i } = [ ParString{ i }, sprintf( '# === PIXEL VALUES =============================================================\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  PV = pixel value in REC file, FP = floating point value, DV = displayed value on console\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  RS = rale slope,           RI = rale intercept,    SS = scale slope\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  DV = PV * RS + RI             FP = PV /  SS\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '# === IMAGE INFORMATION DEFINITION =============================================\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  The rest of this file contains ONE line per image, this line contains the following information:\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  \n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  slice number                             (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  echo number                              (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  dynamic scan number                      (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  cardiac phase number                     (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  image_type_mr                            (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  scanning sequence                        (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  index in REC file (in images)            (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  image pixel size (in bits)               (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  scan percentage                          (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  recon resolution (x,y)                   (2*integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  rale intercept                        (float)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  rale slope                            (float)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  scale slope                              (float)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  window center                            (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  window width                             (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  image angulation (ap,fh,rl in degrees )  (3*float)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  image offcentre (ap,fh,rl in mm )        (3*float)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  slice thickness                          (float)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  slice gap                                (float)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  image_display_orientation                (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  slice orientation ( TRA/SAG/COR )        (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  fmri_status_indication                   (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  image_type_ed_es  (end diast/end syst)   (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  pixel spacing (x,y) (in mm)              (2*float)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  echo_time                                (float)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  dyn_scan_begin_time                      (float)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  trigger_time                             (float)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  diffusion_b_factor                       (float)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  number of averages                       (float)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  image_flip_angle (in degrees)            (float)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  cardiac frequency                        (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  min. RR. interval                        (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  max. RR. interval                        (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  turbo factor                             (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  inversion delay                          (float)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  diffusion b value number    (imagekey!)  (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  gradient orientation number (imagekey!)  (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  contrast type                            (string)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  diffusion anisotropy type                (string)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  diffusion (ap, fh, rl)                   (3*float)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#  label type (ASL)            (imagekey!)  (integer)\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '# === IMAGE INFORMATION ==========================================================\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '#sl ec dyn ph ty  idx pix %% rec size (re)scale     window       angulation      offcentre         thick  gap   info   spacing   echo  dtime ttime    diff avg  flip  freq RR_int  turbo  delay b grad cont anis diffusion\n\n' ) ];
                
                format_str = '%-4d %-3d %-3d %-3d %-3d %-3d %-5d %-2d %-4d %-4d %-4d %8f %8f %8f %6d %6d %6.2f %6.2f %6.2f %7.3f %7.3f %7.3f %5.2f %5.2f %d %d %d %d %5.3f %5.3f %5.3f %9.3f %5.1f %5d %5d %4.1f %5d %5d %5d %3d %4.2f %3d %3d %6d %6d %8f %8f %8f %3d\n';
                datatyp = 'uint16';
            end
            
            total_nr_images = length( v.ImageInformation.Slice );
            
            index = zeros( length( ParString ), 1 );
            for i = 1:total_nr_images - nr_images2
                
                if v.ImageInformation.NoData( i )
                    continue ;
                end
                
                
                if length( ParString ) > 1
                    cur_fid = v.Extr1( i );
                else
                    cur_fid = 1;
                end
                
                switch v.ImageInformation.Type( i, : )
                    case 'M'
                        type = 0;
                    case 'R'
                        type = 1;
                    case 'I'
                        type = 2;
                    case 'P'
                        type = 3;
                end
                
                ri = v.ImageInformation.RaleIntercept( i );
                rs = v.ImageInformation.RaleSlope( i );
                ss = v.ImageInformation.ScaleSlope( i );
                wc = v.ImageInformation.WindowCenter( i );
                ww = v.ImageInformation.WindowWidth( i );
                
                switch v.ImageInformation.Sequence( i, : )
                    case 'FFE'
                        seq = 0;
                    case 'SE'
                        seq = 1;
                end
                switch strtrim( v.ImageInformation.SliceOrientation( i, : ) )
                    case 'Transversal'
                        ori = 1;
                    case 'Coronal'
                        ori = 3;
                    case 'Sagital'
                        ori = 2;
                end
                
                ParString{ cur_fid } = [ ParString{ cur_fid }, sprintf( format_str,  ...
                    v.ImageInformation.Slice( i ),  ...
                    v.ImageInformation.Echo( i ),  ...
                    v.ImageInformation.Dynamic( i ),  ...
                    v.ImageInformation.Phase( i ),  ...
                    type,  ...
                    seq,  ...
                    index( cur_fid ),  ...
                    16,  ...
                    v.ImageInformation.ScanPercentage( i ),  ...
                    v.ImageInformation.ResolutionX( i ),  ...
                    v.ImageInformation.ResolutionY( i ),  ...
                    ri,  ...
                    rs,  ...
                    ss,  ...
                    wc,  ...
                    ww,  ...
                    v.ImageInformation.AngulationAP( i ),  ...
                    v.ImageInformation.AngulationFH( i ),  ...
                    v.ImageInformation.AngulationRL( i ),  ...
                    v.ImageInformation.OffcenterAP( i ),  ...
                    v.ImageInformation.OffcenterFH( i ),  ...
                    v.ImageInformation.OffcenterRL( i ),  ...
                    v.ImageInformation.SliceThickness( i ),  ...
                    v.ImageInformation.SliceGap( i ),  ...
                    0,  ...
                    ori,  ...
                    v.ImageInformation.fMRIStatusIndication( i ),  ...
                    0,  ...
                    v.ImageInformation.PixelSpacing( i, 1 ),  ...
                    v.ImageInformation.PixelSpacing( i, 1 ),  ...
                    v.ImageInformation.EchoTime( i ),  ...
                    v.ImageInformation.DynScanBeginTime( i ),  ...
                    v.ImageInformation.TriggerTime( i ),  ...
                    v.ImageInformation.DiffusionBFactor( i ),  ...
                    v.ImageInformation.NoAverages( i ),  ...
                    v.ImageInformation.ImageFlipAngle( i ),  ...
                    v.ImageInformation.CardiacFrequency( i ),  ...
                    v.ImageInformation.MinRRInterval( i ),  ...
                    v.ImageInformation.MaxRRInterval( i ),  ...
                    v.ImageInformation.TURBOFactor( i ),  ...
                    v.ImageInformation.InversionDelay( i ),  ...
                    v.ImageInformation.BValue( i ),  ...
                    v.ImageInformation.GradOrient( i ),  ...
                    0,  ...
                    0,  ...
                    v.ImageInformation.DiffusionAP( i ),  ...
                    v.ImageInformation.DiffusionFH( i ),  ...
                    v.ImageInformation.DiffusionRL( i ),  ...
                    v.ImageInformation.LabelTypeASL( i ) ) ];
                
                index( cur_fid ) = index( cur_fid ) + 1;
            end
            
            if ( ( nr_images2 > 2 ) && strcmpi( MR.Parameter.Recon.TKE, 'Yes' ) )
                cur_fid = cur_fid + 1;
                for i = total_nr_images - nr_images2 + 1:total_nr_images
                    
                    
                    type = 0;
                    
                    ri = v.ImageInformation.RaleIntercept( i );
                    rs = v.ImageInformation.RaleSlope( i );
                    ss = v.ImageInformation.ScaleSlope( i );
                    wc = v.ImageInformation.WindowCenter( i );
                    ww = v.ImageInformation.WindowWidth( i );
                    
                    switch v.ImageInformation.Sequence( i, : )
                        case 'FFE'
                            seq = 0;
                        case 'SE'
                            seq = 1;
                    end
                    switch strtrim( v.ImageInformation.SliceOrientation( i, : ) )
                        case 'Transversal'
                            ori = 1;
                        case 'Coronal'
                            ori = 3;
                        case 'Sagital'
                            ori = 2;
                    end
                    
                    ParString{ cur_fid } = [ ParString{ i }, sprintf( format_str,  ...
                        v.ImageInformation.Slice( i ),  ...
                        v.ImageInformation.Echo( i ),  ...
                        v.ImageInformation.Dynamic( i ),  ...
                        v.ImageInformation.Phase( i ),  ...
                        type,  ...
                        seq,  ...
                        index( cur_fid ),  ...
                        16,  ...
                        v.ImageInformation.ScanPercentage( i ),  ...
                        v.ImageInformation.ResolutionX( i ),  ...
                        v.ImageInformation.ResolutionY( i ),  ...
                        ri,  ...
                        rs,  ...
                        ss,  ...
                        wc,  ...
                        ww,  ...
                        v.ImageInformation.AngulationAP( i ),  ...
                        v.ImageInformation.AngulationFH( i ),  ...
                        v.ImageInformation.AngulationRL( i ),  ...
                        v.ImageInformation.OffcenterAP( i ),  ...
                        v.ImageInformation.OffcenterFH( i ),  ...
                        v.ImageInformation.OffcenterRL( i ),  ...
                        v.ImageInformation.SliceThickness( i ),  ...
                        v.ImageInformation.SliceGap( i ),  ...
                        0,  ...
                        ori,  ...
                        v.ImageInformation.fMRIStatusIndication( i ),  ...
                        0,  ...
                        v.ImageInformation.PixelSpacing( i, 1 ),  ...
                        v.ImageInformation.PixelSpacing( i, 1 ),  ...
                        v.ImageInformation.EchoTime( i ),  ...
                        v.ImageInformation.DynScanBeginTime( i ),  ...
                        v.ImageInformation.TriggerTime( i ),  ...
                        v.ImageInformation.DiffusionBFactor( i ),  ...
                        v.ImageInformation.NoAverages( i ),  ...
                        v.ImageInformation.ImageFlipAngle( i ),  ...
                        v.ImageInformation.CardiacFrequency( i ),  ...
                        v.ImageInformation.MinRRInterval( i ),  ...
                        v.ImageInformation.MaxRRInterval( i ),  ...
                        v.ImageInformation.TURBOFactor( i ),  ...
                        v.ImageInformation.InversionDelay( i ),  ...
                        v.ImageInformation.BValue( i ),  ...
                        v.ImageInformation.GradOrient( i ),  ...
                        0,  ...
                        0,  ...
                        v.ImageInformation.DiffusionAP( i ),  ...
                        v.ImageInformation.DiffusionFH( i ),  ...
                        v.ImageInformation.DiffusionRL( i ),  ...
                        v.ImageInformation.LabelTypeASL( i ) ) ];
                    
                    index( cur_fid ) = index( cur_fid ) + 1;
                end
            end
            
            for i = 1:length( ParString )
                ParString{ i } = [ ParString{ i }, sprintf( '\n' ) ];
                ParString{ i } = [ ParString{ i }, sprintf( '# === END OF DATA DRIPTION FILE ===============================================\n' ) ];
            end
            
            MR.Data = MR.UnconvertCell( MR.Data );
            MR.Parameter.Recon.AutoUpdateInfoPars = auto_update_status;
        end
        function RecImages = GetRecImages( MR )
            
            if isempty( MR.Data )
                error( 'Error in WriteRec: The data matrix is empty. Please reconstruct the data first' );
            end
            
            
            MR.DataClass.Convert2Cell;
            
            
            if isempty( MR.Parameter.ImageInformation )
                for ci = 1:size( MR.Data, 1 )
                    for cj = 1:size( MR.Data, 2 )
                        dim{ ci, cj } = size( MR.Data{ ci, cj } );
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
                MR.Parameter.CreateInfoPars( dim );
                
            end
            
            if any( any( MR.Parameter.Scan.Venc ) ~= 0 )
                MR.Parameter.Recon.ExportRECImgTypes = { 'M', 'P' };
            end
            
            
            data_type = 'uint16';
            
            
            
            MR.Parameter.UpdateImageInfo = 0;
            
            
            
            
            if size( MR.Data, 1 ) > 1
                warning( 'MATLAB:MRecon', 'Only standard data is written to the .rec file' );
            end
            if size( MR.Data, 2 ) > 1
                if any( cellfun( @( x )size( x, 1 ) ~= size( x, 2 ), MR.Data( 1, : ) ) )
                    warning( 'MATLAB:MRecon', 'There are different sized images in the data. The sizes are made equal before writing' );
                end
            end
            
            
            
            nr_images = 0;
            for i = 1:size( MR.Data, 2 )
                if ~isempty( MR.Data{ 1, i } )
                    nr_images = nr_images + size( MR.Data{ 1, i }( :, :, : ), 3 );
                end
            end
            
            nr_images2 = 0;
            if ( strcmpi( MR.Parameter.Scan.Multivenc, 'Yes' ) && ( size( MR.Data, 2 ) == 2 ) )
                nr_images2 = size( MR.Data{ 1, 2 }( :, :, : ), 3 );
            end
            
            MR.Parameter.UpdatalingPars;
            
            
            
            data = zeros( size( MR.Data{ 1, 1 }, 1 ), size( MR.Data{ 1, 1 }, 2 ), nr_images );
            I = InfoPars( size( data, 3 ) );
            cur_img = 1;
            
            
            
            
            
            for i = 1:size( MR.Data, 2 )
                if ~isempty( MR.Data{ 1, i } )
                    ox = 1;
                    oy = 1;
                    oz = 1;
                    if ~isempty( MR.Parameter.Encoding.WorkEncoding.XReconRes{ 1, 1 } ) &&  ...
                            size( MR.Data{ 1, i }, 1 ) ~= size( data, 1 )
                        ox = size( MR.Data{ 1, i }, 1 ) / size( data, 1 );
                    end
                    if ~isempty( MR.Parameter.Encoding.WorkEncoding.YReconRes{ 1, 1 } ) &&  ...
                            size( MR.Data{ 1, i }, 2 ) ~= size( data, 2 )
                        oy = size( MR.Data{ 1, i }, 2 ) / size( data, 2 );
                    end
                    
                    if any( [ ox, oy, oz ] ~= [ 1, 1, 1 ] )
                        temp = zeros( size( data, 1 ), size( data, 2 ), size( MR.Data{ 1, i }, 3 ) );
                        for j = 1:size( MR.Data{ 1, i }, 3 )
                            temp( :, :, j ) = complex( imresize( real( MR.Data{ 1, i }( :, :, j ) ), [ size( data, 1 ), size( data, 2 ) ] ),  ...
                                imresize( imag( MR.Data{ 1, i }( :, :, j ) ), [ size( data, 1 ), size( data, 2 ) ] ) );
                        end
                        data( :, :, cur_img:cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = temp( :, :, : );
                    else
                        data( :, :, cur_img:cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = MR.Data{ 1, i }( :, :, : );
                    end
                    
                    
                    if iscell( MR.Parameter.ImageInformation )
                        I( cur_img:cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = MR.Parameter.ImageInformation{ 1, i }( : );
                    else
                        I( cur_img:cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 ) - 1 ) = MR.Parameter.ImageInformation( : );
                    end
                    cur_img = cur_img + size( MR.Data{ 1, i }( :, :, : ), 3 );
                end
            end
            
            if isempty( MR.Parameter.Scan.Multivenc ) || strcmpi( MR.Parameter.Scan.Multivenc, 'no' )
                if ( ~isempty( MR.Parameter.Recon.Venc ) && sum( MR.Parameter.Recon.Venc ~= 0 ) > 1 )
                    nr_files = size( MR.Data{ 1 }, 10 );
                    for ffile = 1:nr_files
                        RecImages{ ffile } = [  ];
                    end
                else
                    RecImages{ 1 } = [  ];
                end
            else
                venc_dir = sum( MR.Parameter.Recon.Venc > 0, 1 );
                if sum( venc_dir ) > 0
                    for nr = 1:sum( venc_dir )
                        RecImages{ nr } = [  ];
                    end
                    if nr_images2 > 0
                        RecImages{ nr + 1 } = [  ];
                    end
                else
                    RecImages{ 1 } = [  ];
                end
            end
            
            
            nr_loops = length( MR.Parameter.Recon.ExportRECImgTypes );
            
            
            nr_images_per_par = zeros( length( RecImages ), 1 );
            for phase_loop = 1:nr_loops
                for k = 1:( size( data, 3 ) - nr_images2 )
                    if I( k ).NoData
                        continue ;
                    end
                    cur_fid = min( [ length( RecImages ), I( k ).Extra1 ] );
                    nr_images_per_par( cur_fid ) = nr_images_per_par( cur_fid ) + 1;
                end
            end
            for i = 1:length( RecImages )
                RecImages{ i } = zeros( size( data, 1 ), size( data, 2 ), nr_images_per_par( i ), 'uint16' );
            end
            
            
            cur_image_per_par = zeros( length( RecImages ), 1 );
            for phase_loop = 1:nr_loops
                xres = size( data, 1 );
                yres = size( data, 2 );
                data2write = zeros( size( data, 1 ), size( data, 2 ), nr_images2 );
                for k = 1:( size( data, 3 ) - nr_images2 )
                    if I( k ).NoData
                        continue ;
                    end
                    
                    cur_fid = min( [ length( RecImages ), I( k ).Extra1 ] );
                    cur_image_per_par( cur_fid ) = cur_image_per_par( cur_fid ) + 1;
                    
                    
                    
                    
                    
                    switch MR.Parameter.Recon.ExportRECImgTypes{ phase_loop }
                        case 'M'
                            try
                                RecImages{ cur_fid }( :, :, cur_image_per_par( cur_fid ) ) = uint16( round( ( abs( data( :, :, k ) ) - I( k ).RaleIntercept.M ) ./ I( k ).RaleSlope.M ));
                            catch
                                RecImages{ cur_fid }( :, :, cur_image_per_par( cur_fid ) ) = uint16( round( ( abs( data( :, :, k ) ) - I( k ).RaleIntercept( 1 ) ) ./ I( k ).RaleSlope( 1 ) ));
                            end
                        case 'P'
                            try
                                RecImages{ cur_fid }( :, :, cur_image_per_par( cur_fid ) ) = uint16( round( ( floor( 1000 .* angle( data( :, :, k ) ) ) - I( k ).RaleIntercept.P ) ./ I( k ).RaleSlope.P ) );
                            catch
                                RecImages{ cur_fid }( :, :, cur_image_per_par( cur_fid ) ) = uint16( round( ( floor( 1000 .* angle( data( :, :, k ) ) ) - I( k ).RaleIntercept( 2 ) ) ./ I( k ).RaleSlope( 2 ) ));
                            end
                        case 'R'
                            try
                                RecImages{ cur_fid }( :, :, cur_image_per_par( cur_fid ) ) = uint16( round( ( real( data( :, :, k ) ) - I( k ).RaleIntercept.R ) ./ I( k ).RaleSlope.R ) );
                            catch
                                RecImages{ cur_fid }( :, :, cur_image_per_par( cur_fid ) ) = uint16( round( ( real( data( :, :, k ) ) - I( k ).RaleIntercept( 3 ) ) ./ I( k ).RaleSlope( 3 ) ) );
                            end
                        case 'I'
                            try
                                RecImages{ cur_fid }( :, :, cur_image_per_par( cur_fid ) ) = uint16( round( ( imag( data( :, :, k ) ) - I( k ).RaleIntercept.I ) ./ I( k ).RaleSlope.I ) );
                            catch
                                RecImages{ cur_fid }( :, :, cur_image_per_par( cur_fid ) ) = uint16( round( ( imag( data( :, :, k ) ) - I( k ).RaleIntercept( 4 ) ) ./ I( k ).RaleSlope.( 4 ) ) );
                            end
                    end
                end
            end
            if ( nr_images2 > 0 )
                xres = size( data, 1 );
                yres = size( data, 2 );
                data2write = zeros( size( data, 1 ), size( data, 2 ), length( ( size( data, 3 ) - nr_images2 + 1 ):size( data, 3 ) ) );
                loop = 1;
                for k = ( size( data, 3 ) - nr_images2 + 1 ):size( data, 3 )
                    
                    
                    
                    
                    try
                        RecImages{ cur_fid + 1 }( :, :, loop ) = uint16( round( ( abs( data( :, :, k ) ) - I( k ).RaleIntercept.M ) ./ I( k ).RaleSlope.M ) );
                    catch
                        RecImages{ cur_fid + 1 }( :, :, loop ) = uint16( round( ( abs( data( :, :, k ) ) - I( k ).RaleIntercept( 1 ) ) ./ I( k ).RaleSlope( 1 ) ) );
                    end
                    loop = loop + 1;
                end
            end
            
            
            MR.Data = MR.UnconvertCell( MR.Data );
            MR.Parameter.UpdateImageInfo = 1;
            
        end
    end
    
    methods ( Access = private )
        
        function SpectroDownsample( MR, ox )
            
            
            
            
            
            
            
            
            
            
            
            N = 512;
            offset = N / 2;
            lp_pts = N;
            flag = 'scale';
            win = nuttallwin( N + 1 );
            
            for ccell = 1:numel( MR.Data )
                if ( ~isempty( MR.Data{ ccell } ) && ~isempty( ox{ ccell } ) && ( ox{ ccell } > 1 ) )
                    data_size = size( MR.Data{ ccell } );
                    pts = data_size( 1 );
                    oversampling_factor = ox{ ccell };
                    Fc = 1 / oversampling_factor * 0.95;
                    b = fir1( N, Fc, 'low', win, flag );
                    Hd = dfilt.dffir( b );
                    
                    
                    
                    nr_fids = numel( MR.Data{ ccell } ) / pts;
                    block_size = gcd( nr_fids, 32 );
                    nr_blocks = nr_fids / block_size;
                    short_fid = single( zeros( pts / oversampling_factor, nr_fids ) );
                    for block_cnt = 1:nr_blocks
                        fid_tmp = double( MR.Data{ ccell }( ( block_cnt - 1 ) * pts * block_size + 1:block_cnt * block_size * pts ) );
                        fid_tmp = reshape( fid_tmp, [ pts, block_size ] );
                        pre_insert = MRecon.lpredict( fid_tmp, 4096, lp_pts, 'pre' );
                        post_insert = MRecon.lpredict( fid_tmp, 4096, lp_pts, 'post' );
                        fid_sym = [ pre_insert;fid_tmp;post_insert ];
                        short_fid_sym = filter( Hd, fid_sym );
                        short_fid( :, ( block_cnt - 1 ) * block_size + 1:block_cnt * block_size ) = single( short_fid_sym( offset + lp_pts + 1:oversampling_factor:offset + lp_pts + pts, : ) );
                    end
                    
                    short_fid = reshape( short_fid, [ size( short_fid, 1 ), data_size( 2:end  ) ] );
                    MR.Data{ ccell } = short_fid;
                end
            end
        end
        
        
        
        function SpectroAverage( MR )
            for ccnt = 1:numel( MR.Data )
                nr_fid = size( MR.Data{ ccnt }, MR.dim.meas );
                nr_dyn = size( MR.Data{ ccnt }, MR.dim.dyn );
                blocksize_fid = MR.Parameter.Spectro.Averaging.FID_BlockSize{ ccnt };
                blocksize_dyn = MR.Parameter.Spectro.Averaging.Dyn_BlockSize{ ccnt };
                if ( ( nr_fid > 1 ) || ( MR.Parameter.Spectro.Averaging.Dyn_Averaging && ( nr_dyn > 1 ) ) )
                    
                    if nr_fid > 1 && ( mod( nr_fid, blocksize_fid ) ~= 0 )
                        error( 'The FID block size has to be a common divisor of the available number of FIDs' );
                    end
                    if nr_dyn > 1 && ( mod( nr_dyn, blocksize_dyn ) ~= 0 )
                        error( 'The dynamics block size has to be a common divisor of the available number of dynamics' );
                    end
                    
                    
                    
                    
                    if ( mod( nr_fid, length( MR.Parameter.Spectro.Averaging.FID_Pattern{ ccnt } ) ) ~= 0 )
                        error( 'Averaging Pattern for FIDs does not fit the the data size' );
                    end
                    if ( MR.Parameter.Spectro.Averaging.Dyn_Averaging &&  ...
                            ( mod( nr_dyn, length( MR.Parameter.Spectro.Averaging.Dyn_Pattern{ ccnt } ) ) ~= 0 ) )
                        error( 'Averaging Pattern for Dynamics does not fit the the data size' );
                    end
                    
                    pattern_idx = ( 1:length( MR.Parameter.Spectro.Averaging.FID_Pattern{ ccnt } ) );
                    pattern_idx = repmat( pattern_idx, [ 1, nr_fid / length( pattern_idx ) ] );
                    for meas = 1:nr_fid
                        MR.Data{ ccnt }( :, :, :, :, :, :, :, :, :, :, :, meas ) = MR.Data{ ccnt }( :, :, :, :, :, :, :, :, :, :, :, meas ) *  ...
                            MR.Parameter.Spectro.Averaging.FID_Pattern{ ccnt }( pattern_idx( meas ) );
                    end
                    for pcnt = 1:nr_fid / blocksize_fid
                        MR.Data{ ccnt }( :, :, :, :, :, :, :, :, :, :, :, pcnt ) =  ...
                            mean( MR.Data{ ccnt }( :, :, :, :, :, :, :, :, :, :, :, ( pcnt - 1 ) * blocksize_fid + 1:pcnt * blocksize_fid ), MR.dim.meas );
                    end
                    
                    MR.Data{ ccnt } = MR.Data{ ccnt }( :, :, :, :, :, :, :, :, :, :, :, 1:pcnt );
                    if MR.Parameter.Spectro.Averaging.Dyn_Averaging
                        pattern_idx = ( 1:length( MR.Parameter.Spectro.Averaging.Dyn_Pattern{ ccnt } ) );
                        pattern_idx = repmat( pattern_idx, [ 1, nr_dyn / length( pattern_idx ) ] );
                        for dyn = 1:nr_dyn
                            MR.Data{ ccnt }( :, :, :, :, dyn, :, :, :, :, :, :, : ) = MR.Data{ ccnt }( :, :, :, :, dyn, :, :, :, :, :, :, : ) *  ...
                                MR.Parameter.Spectro.Averaging.Dyn_Pattern{ ccnt }( pattern_idx( dyn ) );
                        end
                        for pcnt = 1:nr_dyn / blocksize_dyn
                            MR.Data{ ccnt }( :, :, :, :, pcnt, :, :, :, :, :, :, : ) =  ...
                                mean( MR.Data{ ccnt }( :, :, :, :, ( pcnt - 1 ) * blocksize_dyn + 1:pcnt * blocksize_dyn, :, :, :, :, :, :, : ), MR.dim.dyn );
                        end
                        
                        MR.Data{ ccnt } = MR.Data{ ccnt }( :, :, :, :, 1:pcnt, :, :, :, :, :, :, : );
                    end
                end
            end
        end
        
        
        
        function V = SpectroCombineCoils( MR, method )
            
            
            mix_idx = MR.Parameter.Encoding.NrMixes;
            weights = zeros( size( MR.Data{ 1 }, MR.dim.coil ), size( MR.Data{ 1 }, MR.dim.dyn ) );
            w = zeros( size( MR.Data{ 1 }, MR.dim.coil ), size( MR.Data{ 1, mix_idx }, MR.dim.meas ) );
            
            switch method
                case 'svd'
                    
                    for dyn = 1:size( MR.Data{ 1, mix_idx }, MR.dim.dyn )
                        for meas = 1:size( MR.Data{ 1, mix_idx }, MR.dim.meas )
                            S = MR.Data{ 1, mix_idx }( :, 1, 1, :, dyn, 1, 1, 1, 1, 1, 1, meas );
                            [ ~, ~, V ] = svd( squeeze(  - S ) );
                            w( :, meas ) = V( :, 1 );
                        end
                        weights( :, dyn ) = mean( w, 2 );
                    end
                case 'snr-weight'
                    for dyn = 1:size( MR.Data{ 1, mix_idx }, MR.dim.dyn )
                        for meas = 1:size( MR.Data{ 1, mix_idx }, MR.dim.meas )
                            S = MR.Data{ 1, mix_idx }( :, 1, 1, :, dyn, 1, 1, 1, 1, 1, 1, meas );
                            if ~MR.Parameter.ReconFlags.isimspace( 1 )
                                S = fft( squeeze( S ), [  ], 1 );
                            end
                            max_sig = max( abs( S ), [  ], 1 );
                            w( :, meas ) = max_sig ./ sqrt( sum( max_sig .^ 2 ) );
                        end
                        weights( :, dyn ) = mean( w, 2 );
                    end
                    
            end
            
            weights = mean( weights, 2 );
            
            
            for ccnt = 1:numel( MR.Data )
                if ~isempty( MR.Data{ ccnt } )
                    for dyn = 1:size( MR.Data{ ccnt }, MR.dim.dyn )
                        for meas = 1:size( MR.Data{ ccnt }, MR.dim.meas )
                            for coils = 1:size( MR.Data{ ccnt }, MR.dim.coil )
                                MR.Data{ ccnt }( :, 1, 1, coils, dyn, 1, 1, 1, 1, 1, 1, meas ) = weights( coils ) * MR.Data{ ccnt }( :, 1, 1, coils, dyn, 1, 1, 1, 1, 1, 1, meas );
                            end
                        end
                    end
                    MR.Data{ ccnt } = sum( MR.Data{ ccnt }, MR.dim.coil );
                end
            end
            
        end
        
        
    end
    
    methods ( Static, Hidden )
        
        
        
        function [ data, data_ind ] = ReadExportedRaw( Filename,  ...
                DataType, Labels, Parameter2Read,  ...
                typ, mix, echo, kx_range, radial_spiral,  ...
                array_compression, ac_nr_channels, ac_matrix )
            
            data = [  ];
            data_ind = [  ];
            
            if ~isempty( kx_range )
                max_chunk_size = 10;
                filename = Filename.Data;
                
                ProfileMask = ( ismember( Labels.Index.typ, Parameter2Read.typ ) &  ...
                    ismember( Labels.Index.mix, Parameter2Read.mix ) &  ...
                    ismember( Labels.Index.dyn, Parameter2Read.dyn ) &  ...
                    ismember( Labels.Index.card, Parameter2Read.card ) &  ...
                    ismember( Labels.Index.loca, Parameter2Read.loca ) &  ...
                    ismember( Labels.Index.echo, Parameter2Read.echo ) &  ...
                    ismember( Labels.Index.extr1, Parameter2Read.extr1 ) &  ...
                    ismember( Labels.Index.extr2, Parameter2Read.extr2 ) &  ...
                    ismember( Labels.Index.ky, Parameter2Read.ky ) &  ...
                    ismember( Labels.Index.kz, Parameter2Read.kz ) );
                
                
                
                if isfield( Labels.Index, 'aver' )
                    ProfileMask = ( ProfileMask &  ...
                        ismember( Labels.Index.aver, Parameter2Read.aver ) &  ...
                        ismember( Labels.Index.rtop, Parameter2Read.rtop ) );
                end
                
                ind = ProfileMask < 0;
                for j = 1:length( echo )
                    for i = 1:length( mix )
                        ind = ind | ( Labels.Index.typ == typ &  ...
                            Labels.Index.mix == mix( i ) &  ...
                            Labels.Index.echo == echo( j ) );
                    end
                end
                ProfileMask = ind & ProfileMask;
                channel_mask = ismember( Labels.Index.chan, Parameter2Read.chan ) & ProfileMask;
                ind = find( ProfileMask );
                coils = unique( Labels.Index.chan( ind ) );
                nr_coils = length( coils );
                
                if ~isempty( ind )
                    
                    
                    
                    
                    if isfield( Labels.Index, 'format' )
                        is_encoded_data = ~isempty( find( Labels.Index.format( ind ) == 6 ) );
                    else
                        is_encoded_data = 0;
                    end
                    
                    curSize = single( Labels.Index.size( ind( 1 ) ) );
                    if isfield( Labels.Index, 'format' )
                        cur_ind = find( DataType.DataTypeNum == single( Labels.Index.format( ind( 1 ) ) ) );
                    else
                        cur_ind = 1;
                    end
                    if radial_spiral
                        kx_range = [  - floor( curSize / 2 ) / 2 / DataType.SampleSizeBytes( cur_ind ), ceil( curSize / 2 ) / 2 / DataType.SampleSizeBytes( cur_ind ) - 1 ];
                    end
                    if diff( abs( kx_range ) ) > 1
                        [ max_range, ind_max ] = max( abs( kx_range ) );
                        if ind_max == 1
                            actual_range = [  - max_range, max_range - 1 ];
                        else
                            actual_range = [  - max_range - 1, max_range ];
                        end
                        samples = length( actual_range( 1 ):actual_range( 2 ) );
                    else
                        kx_range = [  - floor( curSize / 2 ) / 2 / DataType.SampleSizeBytes( cur_ind ), ceil( curSize / 2 ) / 2 / DataType.SampleSizeBytes( cur_ind ) - 1 ];
                        actual_range = kx_range;
                        samples = length( kx_range( 1 ):kx_range( 2 ) );
                    end
                    if samples < ( curSize / 2 / DataType.SampleSizeBytes( cur_ind ) )
                        samples = curSize / 2 / DataType.SampleSizeBytes( cur_ind );
                        kx_range = [  - floor( curSize / 2 ) / 2 / DataType.SampleSizeBytes( cur_ind ), ceil( curSize / 2 ) / 2 / DataType.SampleSizeBytes( cur_ind ) - 1 ];
                        actual_range = kx_range;
                    end
                    
                    data = [  ];
                    data_ind = [  ];
                    kid = fopen( filename, 'r' );
                    
                    if array_compression
                        mean_noise = MRecon.get_mean_noise( Filename, DataType, Labels );
                        
                        if isfield( Labels.Index, 'chan_grp' )
                            channel_groups = unique( Labels.Index.chan_grp( ind ) );
                        else
                            channel_groups = 0;
                        end
                        
                        nr_final_profiles = 0;
                        for i = 1:length( channel_groups )
                            if isfield( Labels.Index, 'chan_grp' )
                                grp_ind = find( ProfileMask & Labels.Index.chan_grp == channel_groups( i ) );
                                nr_coils = length( unique( Labels.Index.chan( grp_ind ) ) );
                                nr_final_profiles = nr_final_profiles + length( grp_ind ) / nr_coils *  ...
                                    ac_nr_channels( i );
                            else
                                [ coil_mask, coils_read ] = ismember( Labels.Index.chan, Parameter2Read.chan );
                                nr_coils = length( unique( coils_read ) );
                                nr_final_profiles = length( find( ProfileMask & coil_mask ) ) / nr_coils *  ...
                                    ac_nr_channels;
                            end
                        end
                    else
                        nr_final_profiles = length( find( ProfileMask & ismember( Labels.Index.chan, Parameter2Read.chan ) ) );
                    end
                    data = zeros( samples, nr_final_profiles, 'single' ) + 1i .* zeros( samples, nr_final_profiles, 'single' );
                    
                    if is_encoded_data
                        
                        if length( ind ) == 1
                            chunk_ind = [  ];
                        else
                            
                            
                            
                            
                            of_ind = find( double( Labels.Index.coded_size( ind ) ) ~= 0 );
                            
                            if ( of_ind( end  ) ~= length( ind ) )
                                of_ind = [ of_ind;length( ind ) ];
                            end
                            
                            offs = double( Labels.Index.offset( ind( of_ind ) ) );
                            codsiz = double( Labels.Index.coded_size( ind( of_ind ) ) );
                            if length( offs ) > 1
                                chunk_ind = sort( unique( [ of_ind( find( diff( offs ) - codsiz( 1:end  - 1 ) ~= 0 ) ),  ...
                                    find( diff( double( Labels.Index.format( ind ) ) ) ~= 0 ) ] ) );
                                
                                chunk_ind = sort( unique( [ of_ind( find( diff( offs ) - codsiz( 1:end  - 1 ) ~= 0 ) ); ...
                                    find( diff( double( Labels.Index.format( ind ) ) ) ~= 0 ); ...
                                    of_ind( find( ind( of_ind ) > Labels.OriginalLabelLength ) ) ] ) );
                            else
                                chunk_ind = [  ];
                            end
                        end
                    else
                        chunk_ind = find( diff( double( Labels.Index.offset( ind ) ) ) - curSize ~= 0 |  ...
                            diff( double( ind ) ) - 1 ~= 0 );
                    end
                    
                    if ( ~isempty( chunk_ind ) && chunk_ind( end  ) == length( ind ) )
                        chunk_ind = [ 1;chunk_ind + 1 ];
                    else
                        chunk_ind = [ 1;chunk_ind + 1;length( ind ) + 1 ];
                    end
                    
                    chunk_is_ok = 0;
                    
                    max_chunk_size_bytes = max_chunk_size * 1024 * 1024;
                    max_chunk_size_bytes = floor( max_chunk_size_bytes / ( nr_coils * curSize ) ) * nr_coils * curSize;
                    while ~chunk_is_ok
                        if is_encoded_data
                            for i = 1:length( chunk_ind ) - 1
                                chunk_size( i ) = sum( Labels.Index.coded_size( ind( chunk_ind( i ) ):ind( chunk_ind( i + 1 ) - 1 ) ) );
                            end
                        else
                            chunk_size = diff( chunk_ind ) .* curSize;
                        end
                        ind_over_max = find( chunk_size > max_chunk_size_bytes, 1 );
                        if isempty( ind_over_max )
                            chunk_is_ok = 1;
                        else
                            
                            new_inds = chunk_ind( ind_over_max ):max_chunk_size_bytes / curSize:chunk_ind( ind_over_max + 1 );
                            if new_inds( end  ) ~= chunk_ind( ind_over_max + 1 )
                                new_inds( end  + 1 ) = chunk_ind( ind_over_max + 1 );
                            end
                            
                            
                            
                            if isfield( Labels.Index, 'coded_size' )
                                for i = 1:length( new_inds )
                                    found = 0;
                                    while ~found
                                        if new_inds( i ) < length( ind ) && ( ind( new_inds( i ) ) - 1 ) > 0
                                            if Labels.Index.coded_size( ind( new_inds( i ) ) - 1 ) == 0
                                                new_inds( i ) = new_inds( i ) - 1;
                                            else
                                                found = 1;
                                            end
                                        else
                                            found = 1;
                                        end
                                    end
                                end
                            end
                            chunk_ind( ind_over_max:ind_over_max + 1 ) = [  ];
                            chunk_ind = [ chunk_ind;new_inds ];
                            chunk_ind = sort( chunk_ind );
                        end
                    end
                    
                    k = 1;
                    k_offset = kx_range( 1 ) - actual_range( 1 ) + 1;
                    if k_offset > 0
                        krange = ismember( actual_range( 1 ):actual_range( 2 ), kx_range( 1 ):kx_range( 2 ) );
                    else
                        krange = ismember( kx_range( 1 ):kx_range( 2 ), actual_range( 1 ):actual_range( 2 ) );
                    end
                    
                    for i = 1:length( DataType.DataType )
                        memfile{ i } = memmapfile( filename, 'Format', DataType.DataType{ i } );
                    end
                    
                    for i = 1:length( chunk_ind ) - 1
                        if isfield( Labels.Index, 'format' )
                            cur_format = double( Labels.Index.format( ind( chunk_ind( i ) ) ) );
                            cur_ind = find( DataType.DataTypeNum == cur_format );
                        else
                            cur_format = 0;
                            cur_ind = 1;
                        end
                        curSize = single( Labels.Index.size( ind( chunk_ind( i ) ) ) );
                        offset = double( Labels.Index.offset( ind( chunk_ind( i ) ) ) );
                        is_encoded_curent_chunk = cur_format == 6;
                        if is_encoded_curent_chunk
                            
                            read_size = sum( double( Labels.Index.coded_size( ind( chunk_ind( i ) ):ind( chunk_ind( i + 1 ) - 1 ) ) ) );
                        else
                            read_size = double( ( chunk_ind( i + 1 ) - chunk_ind( i ) ) * curSize / DataType.SampleSizeBytes( cur_ind ) );
                        end
                        if is_encoded_curent_chunk
                            
                            sample_size2read = 1;
                        else
                            sample_size2read = DataType.SampleSizeBytes( cur_ind );
                        end
                        
                        try
                            fseek( kid, offset,  - 1 );
                            temp = fread( kid, read_size, [ DataType.DataType{ cur_ind }, '=>', DataType.DataType{ cur_ind } ] );
                        catch
                            temp = memfile{ cur_ind }.Data( offset / sample_size2read + 1:offset / sample_size2read + read_size );
                        end
                        
                        if is_encoded_curent_chunk
                            
                            out_size = sum( double( Labels.Index.size( ind( chunk_ind( i ) ):ind( chunk_ind( i + 1 ) - 1 ) ) ) );
                            temp = decode_raw( temp, out_size );
                        end
                        if isfield( Labels, 'Release' ) && ~isempty( Labels.Release ) && Labels.Release == 11
                            temp2 = reshape( temp, nr_coils, curSize / DataType.SampleSizeBytes( cur_ind ), [  ] );
                            temp2 = permute( temp2, [ 2, 1, 3 ] );
                            temp = reshape( complex( temp2( 1:2:end , : ), temp2( 2:2:end , : ) ), curSize / 2 / DataType.SampleSizeBytes( cur_ind ), [  ] );
                        else
                            temp = reshape( complex( temp( 1:2:end , : ), temp( 2:2:end , : ) ), curSize / 2 / DataType.SampleSizeBytes( cur_ind ), [  ] );
                        end
                        
                        temp_ind = ind( chunk_ind( i ):chunk_ind( i + 1 ) - 1 );
                        
                        
                        
                        
                        temp = temp( :, channel_mask( ind( chunk_ind( i ):chunk_ind( i + 1 ) - 1 ) ) );
                        temp_ind = temp_ind( channel_mask( ind( chunk_ind( i ):chunk_ind( i + 1 ) - 1 ) ) );
                        
                        
                        
                        
                        if array_compression
                            temp = single( temp );
                            
                            
                            
                            if ( isfield( Labels, 'FEARFactor' ) && Labels.FEARFactor > 0 )
                                center_k = kx_range( 1 );
                                if ( radial_spiral )
                                    center_k = [  ];
                                end
                                
                                temp = MRecon.fear_corr( temp, Labels, temp_ind, Labels.FEARFactor, center_k );
                            else
                                temp = MRecon.random_phase_corr( temp, Labels, temp_ind );
                            end
                            
                            temp = MRecon.pda_corr( temp, Labels, temp_ind );
                            temp = MRecon.dc_offset_corr( temp, mean_noise, Labels, kx_range, temp_ind, 1 );
                            temp = MRecon.meas_phase_corr( temp, Labels, temp_ind );
                            
                            chan_grps = unique( Labels.Index.chan_grp( temp_ind ) );
                            
                            for cur_grp = 1:length( chan_grps )
                                grp_ind = find( Labels.Index.chan_grp( temp_ind ) == chan_grps( cur_grp ) );
                                cur_nr_chans = length( unique( Labels.Index.chan( temp_ind( grp_ind ) ) ) );
                                
                                for ac_in = 1:size( ac_matrix, 3 )
                                    row_ind = min( [ size( ac_matrix, 1 ), find( isnan( ac_matrix( :, 1, ac_in ) ), 1 ) - 1 ] );
                                    col_ind = min( [ size( ac_matrix, 2 ), find( isnan( ac_matrix( 1, :, ac_in ) ), 1 ) - 1 ] );
                                    A = ac_matrix( 1:row_ind, 1:col_ind, ac_in );
                                    
                                    if size( A, 2 ) ~= cur_nr_chans
                                        continue
                                    end
                                    try
                                        temp_grp = reshape( temp( :, grp_ind ), size( temp, 1 ), cur_nr_chans, [  ] );
                                        temp_ind_grp = reshape( temp_ind( grp_ind ), cur_nr_chans, [  ] );
                                    catch
                                        correct_size = cur_nr_chans * floor( length( grp_ind ) / cur_nr_chans );
                                        temp_grp = reshape( temp( :, grp_ind( 1:correct_size ) ), size( temp, 1 ), cur_nr_chans, [  ] );
                                        temp_ind_grp = reshape( temp_ind( grp_ind( 1:correct_size ) ), cur_nr_chans, [  ] );
                                    end
                                    s3 = size( temp_grp, 3 );
                                    s1 = size( temp_grp, 1 );
                                    cur_channels = Labels.Index.chan( temp_ind_grp( :, 1 ) );
                                    [ sorted_channels, sort_ind ] = sort( cur_channels );
                                    
                                    temp_grp = permute( temp_grp, [ 2, 1, 3 ] );
                                    temp_grp = reshape( temp_grp, size( temp_grp, 1 ), [  ] );
                                    temp_grp = temp_grp( sort_ind, : );
                                    temp_grp = A * temp_grp;
                                    temp_grp = reshape( temp_grp, size( temp_grp, 1 ), s1, s3 );
                                    temp_grp = permute( temp_grp, [ 2, 1, 3 ] );
                                    temp_grp = reshape( temp_grp, size( temp_grp, 1 ), [  ] );
                                    
                                    temp_ind_grp = temp_ind_grp( sort_ind, : );
                                    temp_ind_grp = temp_ind_grp( : );
                                    try
                                        temp_ind( grp_ind ) = temp_ind_grp;
                                    catch
                                        temp_ind( grp_ind( 1:correct_size ) ) = temp_ind_grp;
                                    end
                                    
                                    try
                                        grp_ind_comp = reshape( grp_ind, cur_nr_chans, [  ] );
                                    catch
                                        correct_size = cur_nr_chans * floor( length( grp_ind ) / cur_nr_chans );
                                        grp_ind_comp = reshape( grp_ind( 1:correct_size ), cur_nr_chans, [  ] );
                                    end
                                    
                                    if size( A, 1 ) + 1 <= size( grp_ind_comp, 1 )
                                        grp_ind_del = grp_ind_comp( size( A, 1 ) + 1:end , : );
                                    else
                                        grp_ind_del = [  ];
                                    end
                                    grp_ind_comp = grp_ind_comp( 1:size( A, 1 ), : );
                                    
                                    temp( :, grp_ind_comp( : ) ) = temp_grp;
                                    temp( :, grp_ind_del( : ) ) = NaN;
                                    break ;
                                end
                            end
                        end
                        temp_ind( isnan( temp( 1, : ) ) ) = [  ];
                        temp( :, isnan( temp( 1, : ) ) ) = [  ];
                        
                        if k_offset > 0
                            data( krange, k:k + size( temp, 2 ) - 1 ) = temp;
                        else
                            data( :, k:k + size( temp, 2 ) - 1 ) = temp( krange, : );
                        end
                        data_ind( k:k + size( temp, 2 ) - 1 ) = temp_ind;
                        k = k + size( temp, 2 );
                    end
                    
                    
                    
                    
                    
                    if ~radial_spiral && isfield( Labels.Index, 'random_phase' )
                        data( :, Labels.Index.sign( data_ind ) ==  - 1 ) = data( end : - 1:1, Labels.Index.sign( data_ind ) ==  - 1 );
                    end
                    fclose( kid );
                    
                    
                    if any( size( data ) == 0 )
                        error( 'Error in ReadData: Nothing was read. Please check the values in Parameter.Parameter2Read' );
                    end
                end
            end
        end
        function [ data, read_images_ind ] = readrec( fn, read_params, v )
            
            
            
            
            
            
            
            
            
            
            
            
            parfile = [ fn( 1:end  - 3 ), 'PAR' ];
            
            if nargin == 1
                [ read_params, v, DataFormat ] = MRparameter.ReadParameterFile( fn );
            elseif nargin == 2
                v = parread( parfile );
            end
            
            
            if isfield( v, 'ReconResolution' )
                size1 = v.ReconResolution( 2 );
                size2 = v.ReconResolution( 1 );
            elseif isfield( v.ImageInformation, 'ReconResolution' )
                size1 = v.ImageInformation.ReconResolution( 1, 2 );
                size2 = v.ImageInformation.ReconResolution( 1, 1 );
            else
                size1 = double( v.ImageInformation.ResolutionX( 1 ) );
                size2 = double( v.ImageInformation.ResolutionY( 1 ) );
            end
            
            fid = fopen( fn, 'r', 'l' );
            
            
            if isfield( v.ImageInformation, 'SliceNumber' )
                slice = v.ImageInformation.SliceNumber;
                echo = v.ImageInformation.EchoNumber;
                dynamic = v.ImageInformation.DynamicScanNumber;
                phase = v.ImageInformation.CardiacPhaseNumber;
                type = v.ImageInformation.ImageTypeMr;
                sequence = v.ImageInformation.ScanningSequence;
                index = v.ImageInformation.IndexInRECFile;
            else
                slice = double( v.ImageInformation.Slice );
                echo = double( v.ImageInformation.Echo );
                dynamic = double( v.ImageInformation.Dynamic );
                phase = double( v.ImageInformation.Phase );
                type = double( v.ImageInformation.Type );
                sequence = double( v.ImageInformation.Sequence );
                index = double( v.ImageInformation.Index );
            end
            
            
            
            if size( unique( [ type, sequence ], 'rows' ), 1 ) == length( unique( type ) )
                sequence( : ) = sequence( 1 );
                read_params.mix = sequence( 1 );
            end
            
            nkz = max( [ 1, length( read_params.kz ) ] );
            necho = max( [ 1, length( read_params.echo ) ] );
            ndyn = max( [ 1, length( read_params.dyn ) ] );
            ncard = max( [ 1, length( read_params.card ) ] );
            ntyp = max( [ 1, length( read_params.typ ) ] );
            nmix = max( [ 1, length( read_params.mix ) ] );
            
            
            
            loop = 1;
            ndiff = 0;
            for sl = 1:nkz
                for ec = 1:necho
                    for dy = 1:ndyn
                        for ph = 1:ncard
                            for ty = 1:ntyp
                                for mi = 1:nmix
                                    ind{ 1 } = find( slice == read_params.kz( sl ) );
                                    ind{ 2 } = find( echo == read_params.echo( ec ) );
                                    ind{ 3 } = find( dynamic == read_params.dyn( dy ) );
                                    ind{ 4 } = find( phase == read_params.card( ph ) );
                                    ind{ 5 } = find( type == read_params.typ( ty ) );
                                    ind{ 6 } = find( sequence == read_params.mix( mi ) );
                                    im_ind = ind{ 1 };
                                    for i = 2:6
                                        im_ind = intersect( im_ind, ind{ i } );
                                    end
                                    if length( im_ind ) > 1
                                        ndiff = max( [ ndiff, length( im_ind ) ] );
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            read_images_ind = zeros( 1, 1, nkz, necho, ndyn, ncard, ntyp, nmix, max( [ 1, ndiff ] ), 'single' );
            data = zeros( size1, size2, nkz, necho, ndyn, ncard, ntyp, nmix, max( [ 1, ndiff ] ), 'single' );
            loop = 1;
            for sl = 1:nkz
                for ec = 1:necho
                    for dy = 1:ndyn
                        for ph = 1:ncard
                            for ty = 1:ntyp
                                for mi = 1:nmix
                                    ind{ 1 } = find( slice == read_params.kz( sl ) );
                                    ind{ 2 } = find( echo == read_params.echo( ec ) );
                                    ind{ 3 } = find( dynamic == read_params.dyn( dy ) );
                                    ind{ 4 } = find( phase == read_params.card( ph ) );
                                    ind{ 5 } = find( type == read_params.typ( ty ) );
                                    ind{ 6 } = find( sequence == read_params.mix( mi ) );
                                    im_ind = ind{ 1 };
                                    for i = 2:6
                                        im_ind = intersect( im_ind, ind{ i } );
                                    end
                                    offset = index( im_ind ) * size1 * size2 * 2;
                                    if isempty( offset )
                                        continue
                                    end
                                    for di = 1:length( im_ind )
                                        read_images_ind( 1, 1, sl, ec, dy, ph, ty, mi, di ) = im_ind( di );
                                        loop = loop + 1;
                                        fseek( fid, offset( di ),  - 1 );
                                        im = fread( fid, size1 * size2, 'uint16' );
                                        data( :, :, sl, ec, dy, ph, ty, mi, di ) = reshape( im, size2, size1 );
                                    end
                                end
                            end
                        end
                    end
                end
            end
            fclose( fid );
        end
        function data = read_cpx( file, border, flip_img, kspace, read_params, compression_parameter, MR )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            switch nargin
                case 5
                    compression_parameter = [  ];
                case 4
                    [ read_params, Parameter, DataFormat ] = MRparameter.ReadParameterFile( file );
                    compression_parameter = [  ];
                case 3
                    [ read_params, Parameter, DataFormat ] = MRparameter.ReadParameterFile( file );
                    kspace = 0;
                    compression_parameter = [  ];
                case 2
                    flip_img = 0;
                    kspace = 0;
                    [ read_params, Parameter, DataFormat ] = MRparameter.ReadParameterFile( file );
                    compression_parameter = [  ];
                case 1
                    flip_img = 0;
                    border = 0;
                    kspace = 0;
                    [ read_params, Parameter, DataFormat ] = MRparameter.ReadParameterFile( file );
                    compression_parameter = [  ];
            end
            
            
            header = MR.Parameter.read_cpx_header( file, 'no' );
            [ rows, columns ] = size( header );
            
            
            stacks = length( read_params.loca );
            slices = length( read_params.kz );
            coils = length( read_params.chan );
            hps = length( read_params.card );
            echos = length( read_params.echo );
            dynamics = length( read_params.dyn );
            segments = length( read_params.extr1 );
            segments2 = length( read_params.extr2 );
            
            
            res_x = header( 1, 9 );
            res_y = header( 1, 10 );
            compression = header( 1, 11 );
            flip = header( 1, 12 );
            
            offset_table_cpx = MR.create_offset_table( header );
            
            
            if border
                res = max( [ res_x, res_y ] );
                res_x = res;
                res_y = res;
            end
            
            if ~isempty( compression_parameter )
                data = zeros( res_x, res_y, slices, compression_parameter{ 1 }, dynamics, hps, echos, stacks, 1, segments, segments2, 'single' );
                data3 = zeros( res_x, res_y, coils );
            else
                data = zeros( res_x, res_y, slices, coils, dynamics, hps, echos, stacks, 1, segments, segments2, 'single' );
                data3 = zeros( res_x, res_y, coils );
            end
            
            fid = fopen( file );
            
            
            
            i = 1;
            total_loops = 1;
            for loop = 1:2
                for st = 1:stacks
                    for sl = 1:slices
                        for se2 = 1:segments2
                            for ph = 1:hps
                                for ec = 1:echos
                                    for dy = 1:dynamics
                                        for se = 1:segments
                                            for co = 1:coils
                                                offset = offset_table_cpx( read_params.loca( st ), read_params.kz( sl ), read_params.chan( co ), read_params.card( ph ), read_params.echo( ec ), read_params.dyn( dy ), read_params.extr1( se ), read_params.extr2( se2 ) );
                                                if offset >= 0
                                                    if loop == 2
                                                        image = MR.read_cpx_image( file, offset, border, flip_img );
                                                        if kspace
                                                            image = fftshift( fft2( fftshift( image ) ) );
                                                        end
                                                        data3( :, :, co ) = image;
                                                        i = i + 1;
                                                    else
                                                        total_loops = total_loops + 1;
                                                    end
                                                end
                                            end
                                            if ~isempty( compression_parameter )
                                                
                                                data( :, :, sl, :, dy, ph, ec, st, 1, se, se2 ) = reshape( combine_data_gui( reshape( data3, size( data3, 1 ), size( data3, 2 ), 1, size( data3, 3 ) ), compression_parameter{ 2 } ), size( data3, 1 ), size( data3, 2 ), 1, compression_parameter{ 1 } );
                                            else
                                                data( :, :, sl, :, dy, ph, ec, st, 1, se, se2 ) = reshape( data3, size( data3, 1 ), size( data3, 2 ), 1, size( data3, 3 ) );
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            fclose all;
        end
        function data = read_cpx_image( file, offset, border, flip_img )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            fid = fopen( file );
            
            fseek( fid, offset - 512, 'bof' );
            h1 = fread( fid, 15, 'long' );
            factor = fread( fid, 2, 'float' );
            h2 = fread( fid, 10, 'long' );
            
            res_x = h1( 11 );
            res_y = h1( 12 );
            compression = h1( 14 );
            
            
            fseek( fid, offset, 'bof' );
            switch ( compression )
                case 1
                    data = zeros( res_x * res_y * 2, 1, 'single' );
                    data = fread( fid, res_x * res_y * 2, 'float' );
                case 2
                    data = zeros( res_x * res_y * 2, 1, 'single' );
                    data( : ) = fread( fid, res_x * res_y * 2, 'short' );
                    data = factor( 2 ) + factor( 1 ) .* data;
                case 4
                    data = zeros( res_x * res_y * 2, 1, 'single' );
                    data = fread( fid, res_x * res_y * 2, 'int8' );
                    data = factor( 2 ) + factor( 1 ) .* data;
            end
            data = complex( data( 1:2:end  ), data( 2:2:end  ) );
            data = reshape( data, res_x, res_y );
            
            
            if border & ( res_x ~= res_y )
                res = max( [ res_x, res_y ] );
                data_temp = zeros( res, res );
                if res_x > res_y
                    data_temp( :, floor( ( res - res_y ) / 2 ):res - ceil( ( res - res_y ) / 2 + 0.1 ) ) = data;
                else
                    data_temp( floor( ( res - res_x ) / 2 ):res - ceil( ( res - res_x ) / 2 + 0.1 ), : ) = data;
                end
                data = data_temp;
                clear data_temp;
            end
            
            
            if flip_img
                s = size( data );
                data = data( end : - 1:1, : );
                
                
                
            end
            
            fclose( fid );
        end
        function offset_table_cpx = create_offset_table( header )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            [ rows, columns ] = size( header );
            
            for i = 1:rows
                if header( i, 8 ) == 0;
                    offset_table_cpx( header( i, 1 ) + 1, header( i, 2 ) + 1, header( i, 3 ) + 1, header( i, 4 ) + 1, header( i, 5 ) + 1, header( i, 6 ) + 1, header( i, 7 ) + 1, header( i, 18 ) + 1 ) =  - 100;
                else
                    offset_table_cpx( header( i, 1 ) + 1, header( i, 2 ) + 1, header( i, 3 ) + 1, header( i, 4 ) + 1, header( i, 5 ) + 1, header( i, 6 ) + 1, header( i, 7 ) + 1, header( i, 18 ) + 1 ) = header( i, 8 );
                end
            end
            offset_table_cpx( find( offset_table_cpx == 0 ) ) =  - 1;
            offset_table_cpx( find( offset_table_cpx ==  - 100 ) ) = 0;
        end
        
        
        
        
        function [ datafile, listfile ] = write_eported_raw( MR, filename, data, par )
            
            
            
            dotind = findstr( filename, '.' );
            if ~isempty( dotind )
                dotind = dotind( end  );
                filename = filename( 1:dotind - 1 );
            end
            datafile = [ filename, '.data' ];
            listfile = [ filename, '.list' ];
            
            typ_label = { 'STD', 'REJ', 'PHX', 'FRX', 'NOI', 'NAV' };
            
            if fopen( listfile, 'r' ) ==  - 1
                fid = fopen( datafile, 'w' );
                kid = fopen( listfile, 'w' );
                
                
                fprintf( kid, '# === START OF DATA VECTOR INDEX =================================================\r\n#\r\n' );
                fprintf( kid, '# typ mix   dyn   card  echo  loca  chan  extr1 extr2 ky    kz    n.a.  aver  sign  rf    grad  enc   rtop  rr    size   offset\r\n' );
                fprintf( kid, '# --- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ------ ------\r\n#\r\n' );
            else
                fid = fopen( datafile, 'a' );
                kid = fopen( listfile, 'a' );
            end
            
            data = MR.Convert2Cell( data );
            fseek( fid, 0, 'eof' );
            first_offset = max( [ ftell( fid ), 0 ] );
            fseek( fid, 0, 'bof' );
            loop = 1;
            for i = 1:size( data, 1 )
                if ~isempty( data{ i } )
                    typ = typ_label{ par.typ( loop ) };
                    loop = loop + 1;
                end
                for j = 1:size( data, 2 )
                    if ~isempty( data{ i, j } )
                        [ labels, first_offset ] = MR.create_labels( MR, size( data{ i, j } ), typ, first_offset, par );
                        fprintf( kid, '%s', labels );
                        fwrite( fid, reshape( [ real( data{ i, j }( : ) );imag( data{ i, j }( : ) ) ], 1, [  ] ), 'single' );
                    end
                end
            end
            fclose( 'all' );
        end
        function [ s, first_offset ] = create_labels( MR, data_size, typ, first_offset, par )
            
            if length( data_size ) < 12
                data_size = [ data_size, ones( 1, 12 - length( data_size ) ) ];
            end
            
            
            
            if ~any( strcmpi( MR.Parameter.Chunk.Def, 'ALL' ) ) && ~any( strcmpi( MR.Parameter.Chunk.Def, 'kz' ) )
                kz = MR.Parameter.Parameter2Read.kz;
            else
                kz = (  - floor( data_size( 3 ) / 2 ):ceil( data_size( 3 ) / 2 ) - 1 );
            end
            if ~any( strcmpi( MR.Parameter.Chunk.Def, 'ALL' ) ) && ~any( strcmpi( MR.Parameter.Chunk.Def, 'ky' ) )
                ky = MR.Parameter.Parameter2Read.ky;
            else
                ky = (  - floor( data_size( 2 ) / 2 ):ceil( data_size( 2 ) / 2 ) - 1 );
            end
            
            
            format = '%5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5lu\r\n';
            
            profiles = 1:prod( data_size( 2:end  ) );
            sub = MR.ind2sub( data_size( 2:end  ), profiles );
            offsets = 0:data_size( 1 ) * 8:data_size( 1 ) * 8 * ( size( sub, 1 ) - 1 );
            offsets = offsets + first_offset;
            
            S = [ single( zeros( size( sub, 1 ), 1 ) - 999 ),  ...
                single( par.mix( sub( :, 8 ) ) ),  ...
                single( par.dyn( sub( :, 4 ) ) ),  ...
                single( par.card( sub( :, 5 ) ) ),  ...
                single( par.echo( sub( :, 6 ) ) ),  ...
                single( par.loca( sub( :, 7 ) ) ),  ...
                single( par.chan( sub( :, 3 ) ) ),  ...
                single( par.extr1( sub( :, 9 ) ) ),  ...
                single( par.extr2( sub( :, 10 ) ) ),  ...
                single( ky( sub( :, 1 ) ) ),  ...
                single( kz( sub( :, 2 ) ) ),  ...
                single( zeros( size( sub, 1 ), 1 ) ),  ...
                single( par.aver( sub( :, 11 ) ) ),  ...
                single( zeros( size( sub, 1 ), 1 ) ),  ...
                single( zeros( size( sub, 1 ), 1 ) ),  ...
                single( zeros( size( sub, 1 ), 1 ) ),  ...
                single( zeros( size( sub, 1 ), 1 ) ),  ...
                single( zeros( size( sub, 1 ), 1 ) ),  ...
                single( zeros( size( sub, 1 ), 1 ) ),  ...
                single( zeros( size( sub, 1 ), 1 ) + data_size( 1 ) * 8 ),  ...
                single( offsets ) ];
            
            
            
            
            s = sprintf( format, S );
            s = strrep( s, '-999', typ );
            first_offset = offsets( end  ) + data_size( 1 ) * 8;
        end
        function export_labels( MR, filename )
            
            
            
            
            label_length = length( MR.Parameter.Labels.Index.mix );
            
            lab = MRecon.struct2array( structfun( @( x )double( x ),  ...
                structfun( @( x )x( 1:label_length ), MR.Parameter.Labels.Index, 'UniformOutput', 0 ) ...
                , 'uniformoutput', 0 ) );
            
            format = '%5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %6d %8d %6d %5d %5d %2.2f %5d %5d %5d %5d %5d %5d\r\n';
            lab = sprintf( format, lab );
            
            kid = fopen( filename, 'w' );
            
            if ( kid ==  - 1 )
                error( 'Error in ExportLabels: Cannot open file' );
            end
            
            
            fprintf( kid, '# === START OF DATA VECTOR INDEX =================================================\r\n#\r\n' );
            fprintf( kid, '# typ mix   dyn   card  echo  loca  chan  extr1 extr2 ky    kz    n.a.  aver  sign  rf    grad  enc   rtop  rr    size   offset   rphase mphase pda  pda_f  t_dyn codsiz chgrp format kylab kzlab\r\n' );
            fprintf( kid, '# --- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ------ -------- ------ ----- ----- -----  ----- ------ ----- ------ ----- ------\r\n#\r\n' );
            
            fprintf( kid, '%s', lab );
            
            fclose( kid );
        end
        function log2file( logfile, str, varargin )
            nr_str_values = length( strfind( str, '%' ) );
            if nr_str_values < length( varargin )
                error( 'Error in log2file: Too many logging values given as input' );
            elseif nr_str_values > length( varargin )
                error( 'Error in log2file: Not enough logging values given as input' );
            end
            
            fid = fopen( logfile );
            if fid ==  - 1
                fid = fopen( logfile, 'w' );
            else
                fclose( fid );
                fid = fopen( logfile, 'a' );
            end
            cur_time = datestr( now );
            str = [ cur_time, '          ', str, '\r\n' ];
            
            values_str = [  ];
            for i = 1:length( varargin )
                if ~isstr( varargin{ i } )
                    values_str = [ values_str, num2str( varargin{ i } ) ];
                else
                    values_str = [ values_str, '''', varargin{ i }, '''' ];
                end
                values_str = [ values_str, ', ' ];
            end
            if ~isempty( values_str )
                values_str = values_str( 1:end  - 2 );
            end
            eval_str = [ 'fprintf( fid, ''', str, ''', ', values_str, ');' ];
            eval( eval_str );
            fclose( fid );
        end
        
        
        
        
        function [ data_sorted, data_ind_sorted ] = SortExportedRaw( data, Parameter, data_ind, KyRange, KzRange, KyOversampling, KzOversampling, NoZeroPad, AverageIdenticalProfs, ImmediateAveraging )
            
            data_sorted = [  ];
            data_ind_sorted = [  ];
            data_empty = isempty( data );
            
            if ~data_empty
                
                if ImmediateAveraging
                    aver_bak = Parameter.Index.aver;
                    Parameter.Index.aver = Parameter.Index.aver .* 0;
                end
                
                ind = data_ind;
                
                mixes = unique( Parameter.Index.mix( ind ) );
                dyns = unique( Parameter.Index.dyn( ind ) );
                cards = unique( Parameter.Index.card( ind ) );
                locas = unique( Parameter.Index.loca( ind ) );
                echos = unique( Parameter.Index.echo( ind ) );
                extr1s = unique( Parameter.Index.extr1( ind ) );
                extr2s = unique( Parameter.Index.extr2( ind ) );
                chans = unique( Parameter.Index.chan( ind ) );
                kys = min( Parameter.Index.ky( ind ) ):max( Parameter.Index.ky( ind ) );
                kzs = min( Parameter.Index.kz( ind ) ):max( Parameter.Index.kz( ind ) );
                avers = unique( Parameter.Index.aver( ind ) );
                
                
                nr_mix = length( mixes );
                nr_dyn = length( dyns );
                nr_card = length( cards );
                nr_loca = length( locas );
                nr_echo = length( echos );
                nr_extr1 = length( extr1s );
                nr_extr2 = length( extr2s );
                nr_chan = length( chans );
                nr_ky = length( kys );
                nr_kz = length( kzs );
                nr_aver = length( avers );
                nr_samples = size( data, 1 );
                
                if ~isempty( KyRange ) && ~NoZeroPad( 1 )
                    if isfield( Parameter, 'Samples' )
                        if length( Parameter.Samples ) > 1 && Parameter.Samples( 2 ) * KyOversampling ~= length( KyRange( 1 ):KyRange( 2 ) )
                            nr_ky = round( max( Parameter.Samples( :, 2 ) ) * KyOversampling );
                            KyRange = [ ceil(  - nr_ky / 2 ), ceil( nr_ky / 2 ) - 1 ];
                        end
                    else
                        if abs( diff( abs( KyRange ) ) ) > 1 || abs( KyRange( 2 ) ) > abs( KyRange( 1 ) )
                            [ max_range, ind_max ] = max( abs( KyRange ) );
                            if ind_max == 1
                                KyRange = [  - max_range, max_range - 1 ];
                            else
                                KyRange = [  - max_range - 1, max_range ];
                            end
                            
                        end
                    end
                    nr_ky = length( KyRange( 1 ):KyRange( 2 ) );
                    kys = union( kys, KyRange( 1 ):KyRange( 2 ) );
                end
                if ~isempty( KzRange ) && ~NoZeroPad( 2 )
                    if isfield( Parameter, 'Samples' )
                        if length( Parameter.Samples ) > 2 && round( Parameter.Samples( 3 ) * KzOversampling ) ~= length( KzRange( 1 ):KzRange( 2 ) )
                            nr_kz = round( max( Parameter.Samples( :, 3 ) ) * KzOversampling );
                            KzRange = [ ceil(  - nr_kz / 2 ), ceil( nr_kz / 2 ) - 1 ];
                        end
                    else
                        if abs( diff( abs( KzRange ) ) ) > 1 || abs( KzRange( 2 ) ) > abs( KzRange( 1 ) )
                            
                            [ max_range, ind_max ] = max( abs( KzRange ) );
                            if ind_max == 1
                                KzRange = [  - max_range, max_range - 1 ];
                            else
                                KzRange = [  - max_range - 1, max_range ];
                            end
                        end
                    end
                    nr_kz = length( KzRange( 1 ):KzRange( 2 ) );
                    kzs = union( kzs, KzRange( 1 ):KzRange( 2 ) );
                end
                
                size_sorted = [ nr_ky, nr_kz, nr_chan, nr_dyn, nr_card,  ...
                    nr_echo, nr_loca, nr_mix, nr_extr1, nr_extr2, nr_aver ];
                prod_size = [ 1, cumprod( size_sorted( 1:end  - 1 ) ) ];
                ind_sorted = zeros( 1, length( ind ) );
                
                data_sorted = zeros( nr_samples, prod( size_sorted ), 'single' );
                data_ind_sorted = zeros( 1, prod( size_sorted ), 'single' );
                
                for i = 1:length( ind )
                    mix = find( mixes == Parameter.Index.mix( ind( i ) ) );
                    dyn = find( dyns == Parameter.Index.dyn( ind( i ) ) );
                    card = find( cards == Parameter.Index.card( ind( i ) ) );
                    loca = find( locas == Parameter.Index.loca( ind( i ) ) );
                    echo = find( echos == Parameter.Index.echo( ind( i ) ) );
                    extr1 = find( extr1s == Parameter.Index.extr1( ind( i ) ) );
                    extr2 = find( extr2s == Parameter.Index.extr2( ind( i ) ) );
                    chan = find( chans == Parameter.Index.chan( ind( i ) ) );
                    ky = find( kys == Parameter.Index.ky( ind( i ) ) );
                    kz = find( kzs == Parameter.Index.kz( ind( i ) ) );
                    aver = find( avers == Parameter.Index.aver( ind( i ) ) );
                    ind_sorted( i ) = sum( ( [ ky, kz, chan, dyn, card, echo, loca, mix, extr1, extr2, aver ] - 1 ) .* prod_size ) + 1;
                end
                
                data_ind_sorted( ind_sorted ) = data_ind;
                data_ind_sorted = reshape( data_ind_sorted, [ 1, size_sorted ] );
                
                
                
                
                if AverageIdenticalProfs || ImmediateAveraging
                    s = accumarray( ind_sorted, ones( size( data( 1, : ) ) ), [ size( data_sorted, 2 ), 1 ] );
                    ind_sorted = ( ind_sorted - 1 ) .* size( data, 1 );
                    ind_sorted = repmat( ind_sorted, [ size( data, 1 ), 1 ] );
                    ind_sorted = bsxfun( @plus, ind_sorted, ( 1:size( data, 1 ) ) );
                    data_sorted = accumarray( ind_sorted( : ), data( : ), [ size( data_sorted( : ) ) ] );
                    data_sorted = reshape( data_sorted, size( data, 1 ), [  ] );
                    data_sorted = bsxfun( @rdivide, data_sorted, s );
                    data_sorted( isnan( data_sorted ) ) = 0;
                    
                    
                    
                    
                    
                    
                    
                    
                    
                else
                    data_sorted( :, ind_sorted ) = data;
                end
                data_sorted = reshape( data_sorted, [ nr_samples, size_sorted ] );
                
                if ImmediateAveraging
                    Parameter.Index.aver = aver_bak;
                end
            end
        end
        
        
        
        
        function data = random_phase_corr( data, Labels, data_ind )
            phases = zeros( size( data_ind ) );
            phases( data_ind ~= 0 ) = double( Labels.Index.random_phase( data_ind( data_ind ~= 0 ) ) );
            mul_fac = 2 * pi / double( intmax( 'uint16' ) );
            phases = exp(  - 1i .* phases * mul_fac );
            data = bsxfun( @times, data, phases );
        end
        function data = fear_corr( data, Labels, data_ind, fear_factor, center_k )
            if isempty( data )
                return ;
            end
            phases = zeros( size( data_ind ) );
            phases( data_ind ~= 0 ) = double( Labels.Index.random_phase( data_ind( data_ind ~= 0 ) ) );
            phases( phases > intmax( 'int16' ) ) = phases( phases > intmax( 'int16' ) ) - double( intmax( 'uint16' ) );
            mul_fac = 2 * pi / double( intmax( 'uint16' ) );
            phases = phases * mul_fac;
            
            
            
            signs = zeros( size( data_ind ) );
            signs( data_ind ~= 0 ) = double( Labels.Index.sign( data_ind( data_ind ~= 0 ) ) );
            signs_neg_ind = find( signs < 0 );
            signs_pos_ind = find( signs > 0 );
            
            x = (  - floor( size( data, 1 ) / 2 ):ceil( size( data, 1 ) / 2 ) - 1 );
            
            
            x_inv = x( end : - 1:1 );
            
            if isempty( center_k )
                center_k = x( 1 );
            end
            
            phases_full = zeros( length( x ), size( phases, 2 ) );
            
            phases_full( :, signs_pos_ind ) = bsxfun( @plus, bsxfun( @times, phases( signs_pos_ind ) * fear_factor, x' ), phases( signs_pos_ind ) * ( 1 - fear_factor * center_k ) );
            phases_full( :, signs_pos_ind ) = exp(  - 1i .* phases_full( :, signs_pos_ind ) );
            
            phases_full( :, signs_neg_ind ) = bsxfun( @plus, bsxfun( @times, phases( signs_neg_ind ) * fear_factor, x_inv' ), phases( signs_neg_ind ) * ( 1 - fear_factor * center_k ) );
            phases_full( :, signs_neg_ind ) = exp(  - 1i .* phases_full( :, signs_neg_ind ) );
            
            data = bsxfun( @times, data, phases_full );
        end
        function data = meas_phase_corr( data, Labels, data_ind )
            phases = zeros( size( data_ind ) );
            phases( data_ind ~= 0 ) = double( Labels.Index.meas_phase( data_ind( data_ind ~= 0 ) ) );
            phases = exp(  - 1i .* phases * pi / 2 );
            data = bsxfun( @times, data, phases );
        end
        function data = pda_corr( data, Labels, data_ind )
            try
                
                nr_gain_values = 12;
                
                factors = zeros( size( data_ind ) );
                factors( data_ind ~= 0 ) = double( Labels.PDAFactors( ( Labels.Index.pda_index( data_ind( data_ind ~= 0 ) ) + Labels.Index.chan( data_ind( data_ind ~= 0 ) ) .* nr_gain_values ) + 1 ) );
                data = bsxfun( @times, data, factors );
            catch
                factors = zeros( size( data_ind ) );
                factors( data_ind ~= 0 ) = double( Labels.PDAFactors( Labels.Index.pda_index( data_ind( data_ind ~= 0 ) ) + 1 ) );
                data = bsxfun( @times, data, factors );
            end
        end
        function data = dc_offset_corr( data, mean_noise, Labels, kx_range, data_ind, ispdacorr )
            
            if nargin == 5
                ispdacorr = 1;
            end
            
            coils = unique( double( Labels.Index.chan( data_ind( data_ind ~= 0 ) ) ) );
            for c = 1:length( coils )
                coil_ind = zeros( size( data_ind ) );
                coil_ind( data_ind ~= 0 ) = double( Labels.Index.chan( data_ind( data_ind ~= 0 ) ) ) == coils( c );
                
                pda_ind = zeros( size( data_ind ) );
                pda_ind( data_ind ~= 0 ) = Labels.Index.pda_index( data_ind( data_ind ~= 0 ) );
                if ~isempty( mean_noise ) && ~isempty( find( mean_noise( :, 2 ) == coils( c ) ) )
                    if ~ispdacorr && isfield( Labels, 'PDAFactors' ) && ~isempty( Labels.PDAFactors ) && ~any( mean_noise( :, 3 ) == 0 )
                        
                        
                        pda_factors = Labels.PDAFactors( pda_ind( find( coil_ind ) ) + 1 );
                        data( :, find( coil_ind ) ) = bsxfun( @minus, data( :, find( coil_ind ) ), bsxfun( @rdivide, mean_noise( mean_noise( :, 2 ) == coils( c ), 1 ), pda_factors ) );
                    else
                        data( :, find( coil_ind ) ) = data( :, find( coil_ind ) ) - mean_noise( mean_noise( :, 2 ) == coils( c ), 1 );
                    end
                else
                    profile_min = find( kx_range( 1 ):kx_range( 2 ) == 0 );
                    weight = ( 1:size( data, 1 ) ) + profile_min;
                    weight = ( 0.5 - 0.5 * cos( 2 * pi .* weight / size( data, 1 ) ) ) .^ 2;
                    mean_noise = sum( bsxfun( @times, data( :, find( coil_ind ) ), weight ), 1 ) ./ sum( weight );
                    data( :, find( coil_ind ) ) = bsxfun( @minus, data( :, find( coil_ind ) ), mean_noise );
                end
            end
        end
        function [ mean_noise, std_noise, psi ] = get_mean_noise( filename, DataType, Labels )
            
            mean_noise = [  ];
            std_noise = [  ];
            psi = [  ];
            Parameter2Read = Parameter2ReadPars;
            Parameter2Read.SetMax;
            Parameter2Read.typ = 5;
            Parameter2Read.mix = 0;
            Parameter2Read.echo = 0;
            
            
            
            
            try
                [ data, data_ind ] = MRecon.ReadExportedRaw( filename,  ...
                    DataType, Labels, Parameter2Read,  ...
                    Parameter2Read.typ, Parameter2Read.mix, Parameter2Read.echo, [ 0, 1 ], 0,  ...
                    0, [  ], [  ] );
            catch
                chan_grps = unique( Labels.Index.chan_grp( Labels.Index.typ == 1 ) );
                Labels.Index.typ( ~ismember( Labels.Index.chan_grp( Labels.Index.typ == 5 ), chan_grps ) ) = 2;
                [ data, data_ind ] = MRecon.ReadExportedRaw( filename,  ...
                    DataType, Labels, Parameter2Read,  ...
                    Parameter2Read.typ, Parameter2Read.mix, Parameter2Read.echo, [ 0, 1 ], 0,  ...
                    0, [  ], [  ] );
            end
            
            if ( isempty( data ) )
                return ;
            end
            
            
            if isfield( Labels, 'PDAFactors' )
                pda_factors = Labels.PDAFactors( Labels.Index.pda_index( data_ind ) + 1 );
                if any( pda_factors == 0 )
                    pda_factors = 0 .* pda_factors;
                else
                    data = MRecon.pda_corr( data, Labels, data_ind );
                end
                
            end
            
            if ~isempty( data )
                coils = Labels.Index.chan( data_ind );
                mean_noise = zeros( length( coils ), 2 );
                mean_noise( :, 1 ) = mean( data, 1 );
                mean_noise( :, 2 ) = coils;
                if isfield( Labels, 'PDAFactors' )
                    mean_noise( :, 3 ) = pda_factors;
                end
                
                std_noise = zeros( length( coils ), 2 );
                std_noise( :, 1 ) = std( data, 1 );
                std_noise( :, 2 ) = coils;
                
                [ coils, u_ind ] = unique( mean_noise( :, 2 ) );
                
                mean_noise = sortrows( mean_noise, 2 );
                
                
                [ temp, ind ] = ismember( mean_noise( :, 2 ), coils );
                
                if isfield( Labels, 'PDAFactors' )
                    pda_factors = mean_noise( u_ind, 3 );
                end
                
                psi = conj( cov( data( :, u_ind ) ) );
                std_noise = std_noise( u_ind, : );
                
                temp = accumarray( ind, mean_noise( :, 1 ), [  ], @mean );
                mean_noise = zeros( length( temp ), 2 );
                mean_noise( :, 1 ) = temp;
                mean_noise( :, 2 ) = coils;
                if isfield( Labels, 'PDAFactors' )
                    mean_noise( :, 3 ) = pda_factors;
                end
            end
        end
        function p = get_epi_corr_data( Filename, DataType, Labels, GridderPars,  ...
                EncodingPars, LabelLookupTable, ImagingData, grid, do_zero_fill, rem_oversampling,  ...
                corr_2d, linear, isocenterMPS, array_compression_matrix, per_location )
            
            p = EPICorrDataPars;
            
            dual_sign_corr = 0;
            phx_profiles_mask = Labels.Index.typ == 3;
            Labels.Index.ky( phx_profiles_mask ) = Labels.Index.enc( phx_profiles_mask );
            
            ovs_x = EncodingPars.KxOversampling( find( EncodingPars.Mix == 0, 1 ) );
            if rem_oversampling == 0
                ovs_x = 1;
            end
            
            avers = unique( Labels.Index.aver( phx_profiles_mask ) );
            if length( avers ) > 1
                dual_sign_corr = 1;
            end
            
            if dual_sign_corr
                encs_aver0 = unique( Labels.Index.enc( phx_profiles_mask & Labels.Index.aver == avers( 1 ) ) );
                encs_aver1 = unique( Labels.Index.enc( phx_profiles_mask & Labels.Index.aver == avers( 2 ) ) );
                encs = intersect( encs_aver0, encs_aver1 );
                
            else
                encs = unique( Labels.Index.enc( phx_profiles_mask ) );
                
                
                
                
            end
            
            
            
            
            Parameter2Read = Parameter2ReadPars;
            Parameter2Read.SetMax;
            Parameter2Read.typ = 3;
            Parameter2Read.mix = 0;
            Parameter2Read.echo = 0;
            Parameter2Read.ky = double( encs );
            
            [ phx_profiles, data_ind ] = MRecon.ReadExportedRaw( Filename,  ...
                DataType, Labels, Parameter2Read,  ...
                Parameter2Read.typ, Parameter2Read.mix, Parameter2Read.echo, [ 0, 1 ], 0,  ...
                0, [  ], [  ] );
            
            mean_noise = MRecon.get_mean_noise( Filename, DataType, Labels );
            phx_profiles = MRecon.random_phase_corr( phx_profiles, Labels, data_ind );
            phx_profiles = MRecon.pda_corr( phx_profiles, Labels, data_ind );
            phx_profiles = MRecon.dc_offset_corr( phx_profiles, mean_noise, Labels, EncodingPars.KxRange( find( EncodingPars.Mix == 0, 1 ), : ), data_ind, 1 );
            phx_profiles = MRecon.meas_phase_corr( phx_profiles, Labels, data_ind );
            
            coils = unique( Labels.Index.chan( data_ind( data_ind ~= 0 ) ) );
            nr_coils = length( coils );
            locas = unique( Labels.Index.loca( data_ind( data_ind ~= 0 ) ) );
            nr_locas = length( locas );
            
            
            
            if ~isempty( array_compression_matrix )
                for ac_in = 1:size( array_compression_matrix, 3 )
                    row_ind = min( [ size( array_compression_matrix, 1 ), find( isnan( array_compression_matrix( :, 1, ac_in ) ), 1 ) - 1 ] );
                    col_ind = min( [ size( array_compression_matrix, 2 ), find( isnan( array_compression_matrix( 1, :, ac_in ) ), 1 ) - 1 ] );
                    A = array_compression_matrix( 1:row_ind, 1:col_ind, ac_in );
                    
                    if size( A, 2 ) ~= nr_coils
                        continue
                    end
                    nr_profiles = size( phx_profiles, 1 );
                    phx_profiles = reshape( phx_profiles, nr_profiles, nr_coils, [  ] );
                    phx_profiles = permute( phx_profiles, [ 2, 1, 3 ] );
                    phx_profiles = A * phx_profiles( :, : );
                    phx_profiles = reshape( phx_profiles, size( A, 1 ), nr_profiles, [  ] );
                    phx_profiles = permute( phx_profiles, [ 2, 1, 3 ] );
                    phx_profiles = phx_profiles( :, : );
                    nr_coils = size( A, 1 );
                end
            end
            
            
            
            if grid && isfield( Labels, 'NusEncNrs' )
                out_res = [ round( GridderPars{ 1 }.OutputMatrixSize( 1 ) / GridderPars{ 1 }.GridOvsFactor( 1 ) ), 1 ];
                out_res_z = 1;
                
                kpos = repmat( Labels.NusEncNrs, [ 1, 3 ] );
                kpos( :, 2 ) = 0;
                kpos( :, 3 ) = 0;
                weights = ones( size( kpos, 1 ), 1, 'single' );
                
                phx_profiles = squeeze( gridder( single( kpos ),  ...
                    phx_profiles,  ...
                    weights,  ...
                    single( [ out_res( 1 ), out_res( 2 ), out_res_z ] ),  ...
                    single( GridderPars{ 1 }.GridOvsFactor ),  ...
                    single( GridderPars{ 1 }.KernelWidth ), 1 ) );
            end
            
            if do_zero_fill
                ox = EncodingPars.KxOversampling( find( EncodingPars.Mix == 0, 1 ) );
                xres = EncodingPars.XRes( find( EncodingPars.Mix == 0, 1 ) );
                
                phx_profiles = zero_fill( phx_profiles, ox * xres, [  ], [  ] );
            end
            
            phx_profiles = MRecon.k2i( phx_profiles, 1, 1 );
            
            
            
            if dual_sign_corr
                Labels.Index.aver( phx_profiles_mask ) = ( Labels.Index.sign( phx_profiles_mask ) + 1 ) ./ 2;
            end
            
            encs = unique( Labels.Index.enc( data_ind( data_ind ~= 0 ) ) );
            [ temp, Labels.Index.ky( data_ind( data_ind ~= 0 ) ) ] = ismember( Labels.Index.ky( data_ind( data_ind ~= 0 ) ), double( encs ) );
            Labels.Index.ky( data_ind( data_ind ~= 0 ) ) = Labels.Index.ky( data_ind( data_ind ~= 0 ) ) - 1;
            
            
            if isfield( Labels, 'Samples' )
                samples = Labels.Samples( 1, : );
            else
                samples = [  ];
            end
            no_zero_pad = [ true, true ];
            
            if ( ismac )
                [ phx_profiles, data_ind ] = MRecon.SortExportedRaw( phx_profiles, Labels, data_ind, [ 0, 1 ], [ 0, 1 ], 1, 1, no_zero_pad, 1, false );
            else
                [ phx_profiles, data_ind ] = sort_data( phx_profiles, data_ind, Labels.Index, [ 0, 1 ], [ 0, 1 ], 1, 1, samples, no_zero_pad, 1, false, true );
            end
            
            
            
            if dual_sign_corr
                factor = 1;
                x =  - floor( size( phx_profiles, 1 ) / 2 ):ceil( size( phx_profiles, 1 ) / 2 ) - 1;
                min_x =  - floor( size( phx_profiles, 1 ) / 2 / ovs_x );
                x_center = isocenterMPS( 1 ) + min_x - 1;
                c = conj( phx_profiles( :, :, :, :, :, :, :, :, :, :, :, 2 ) ) .* phx_profiles( :, :, :, :, :, :, :, :, :, :, :, 1 );
                if ( per_location )
                    c = mean( mean( c( :, :, :, :, : ), 2 ), 3 );
                else
                    c = mean( mean( mean( c( :, :, :, :, : ), 2 ), 3 ), 5 );
                end
                c = c ./ ( abs( c ) .^ 0.5 );
                c( isnan( c ) ) = 0;
            else
                l = size( phx_profiles, 2 );
                if mod( l, 2 )
                    if Labels.Index.sign( data_ind( 1 ) ) == 1
                        indp1 = 1:2:l - 1;
                        indp2 = 3:2:l;
                        indm1 = 2:2:l;
                        indm2 = 2:2:l;
                    else
                        indm1 = 1:2:l - 1;
                        indm2 = 3:2:l;
                        indp1 = 2:2:l;
                        indp2 = 2:2:l;
                    end
                else
                    if Labels.Index.sign( data_ind( 1 ) ) == 1
                        indp1 = 1:2:l;
                        indp2 = 3:2:l;
                        indm1 = 2:2:l;
                        indm2 = 2:2:l - 1;
                    else
                        indm1 = 1:2:l;
                        indm2 = 3:2:l;
                        indp1 = 2:2:l;
                        indp2 = 2:2:l - 1;
                    end
                end
                
                factor = 0.5;
                x =  - floor( size( phx_profiles, 1 ) / 2 ):ceil( size( phx_profiles, 1 ) / 2 ) - 1;
                min_x =  - floor( size( phx_profiles, 1 ) / 2 / ovs_x );
                x_center = isocenterMPS( 1 ) + min_x - 1;
                c1 = conj( phx_profiles( :, indp1, :, :, : ) ) .* phx_profiles( :, indm1, :, :, : );
                if ( per_location )
                    c1 = mean( mean( c1( :, :, :, :, : ), 2 ), 3 );
                else
                    c1 = mean( mean( mean( c1( :, :, :, :, : ), 2 ), 3 ), 5 );
                end
                c2 = conj( phx_profiles( :, indp2, :, :, : ) ) .* phx_profiles( :, indm2, :, :, : );
                
                
                if ( per_location )
                    c2 = mean( mean( c2( :, :, :, :, : ), 2 ), 3 );
                else
                    c2 = mean( mean( mean( c2( :, :, :, :, : ), 2 ), 3 ), 5 );
                end
                c = c1 .* c2;
                c = c ./ ( abs( c ) .^ 0.75 );
                c1 = c1 ./ ( abs( c1 ) .^ 0.5 );
                c( isnan( c ) ) = 0;
                c1( isnan( c1 ) ) = 0;
                
                
                
            end
            
            if ( ~per_location )nr_locas = 1;end
            
            for j = 1:nr_locas
                for i = 1:nr_coils
                    slope = sum( conj( c( 1:end  - 2, 1, 1, i, j ) ) .* c( 2:end  - 1, 1, 1, i, j ) );
                    slope =  - angle( slope ./ abs( slope ) );
                    
                    
                    final_slope = factor * slope;
                    offset = x_center * final_slope;
                    linPhase = cos( final_slope .* x + offset ) + 1i .* sin( final_slope .* x + offset );
                    if dual_sign_corr
                        c2 = bsxfun( @times, c( :, 1, 1, i, j ), linPhase );
                    else
                        c2 = bsxfun( @times, c1( :, 1, 1, i, j ), linPhase );
                    end
                    
                    temp2( :, i ) = c2;
                    
                    
                    offset = sum( c2 );
                    offset = offset / abs( offset );
                    offset = angle( conj( offset ) );
                    
                    p.coil( ( j - 1 ) * nr_coils + i ) = coils( i );
                    
                    if per_location
                        p.loca( ( j - 1 ) * nr_coils + i ) = locas( j );
                    end
                    if linear
                        p.offset( ( j - 1 ) * nr_coils + i ) = offset;
                        p.slope( ( j - 1 ) * nr_coils + i ) = final_slope;
                    else
                        linPhase = cos( slope .* x + offset ) + 1i .* sin( slope .* x + offset );
                        cc = bsxfun( @times, c( :, 1, 1, i, j ), linPhase );
                        [ ma, ind_max ] = max( abs( c( :, 1, 1, i, j ) ) );
                        threshold = 0.3 * mean( abs( cc ) );
                        mask = abs( cc ) < threshold;
                        
                        cc = MRecon.smooth( cc );
                        cc = MRecon.unwrap1d( angle( cc ), ind_max );
                        cc( mask ) = 0;
                        cc = factor * cc;
                        
                        linPhase = cos(  - factor * slope .* x - factor * offset ) + 1i .* sin(  - factor * slope .* x - factor * offset );
                        p.corr_factors( :, ( j - 1 ) * nr_coils + i ) = linPhase .* ( cos( cc ) + 1i .* sin( cc ) );
                    end
                    
                end
            end
            
            if corr_2d
                off_orig = p.offset;
                min_d_offset = 0;
                try
                    
                    
                    data_ind = LabelLookupTable( :, :, :, :, 1, 1, 1, 1, 1, 1, 1, 1 );
                    ks = zeros( size( data_ind ) );
                    ks( data_ind == 0 ) = inf;
                    ks( data_ind ~= 0 ) = double( Labels.Index.ky( data_ind( data_ind ~= 0 ) ) );
                    profile_mask = ks >  - 33 & ks < 33;
                    ks( : ) = 0;
                    ks( data_ind ~= 0 ) = double( Labels.Index.kz( data_ind( data_ind ~= 0 ) ) );
                    profile_mask = profile_mask & ( ks >  - 1 & ks < 1 );
                    nr_ys = max( sum( profile_mask( :, :, :, 1 ), 2 ) );
                    nr_zs = max( sum( profile_mask( :, :, :, 1 ), 3 ) );
                    s = size( profile_mask );
                    s( end  + 1:12 ) = 1;
                    data = complex( zeros( [ size( ImagingData, 1 ), nr_ys, nr_zs, s( 4 ), 1, 1, 1, s( 8 ), 1, 1, 1, 1 ] ), zeros( [ size( ImagingData, 1 ), nr_ys, nr_zs, s( 4 ), 1, 1, 1, s( 8 ), 1, 1, 1, 1 ] ) );
                    data( : ) = ImagingData( :, profile_mask );
                    data_ind = data_ind( profile_mask );
                    data_ind = reshape( data_ind, [ 1, size( data, 2 ), size( data, 3 ), s( 4 ), 1, 1, 1, s( 8 ), 1, 1, 1, 1 ] );
                    
                    d_offset =  - 1:0.1:1;
                    datac = zeros( [ size( data ), length( d_offset ) ] ) + 1i .* zeros( [ size( data ), length( d_offset ) ] );
                    for i = 1:length( d_offset )
                        p.offset = off_orig + d_offset( i );
                        datac( :, :, :, :, i ) = MRecon.epi_corr( data, p, Labels, data_ind, per_location );
                    end
                    datac = MRecon.k2i( datac, [ 2, 3 ], 1 );
                    datac = sum( abs( datac ) .^ 2, 4 );
                    
                    t = mean( datac( : ) );
                    datac( datac > t ) = t;
                    sum_datac = squeeze( sum( sum( sum( datac, 1 ), 2 ), 3 ) );
                    [ mi, ind_min ] = min( sum_datac );
                    min_d_offset = d_offset( ind_min );
                    
                    p.offset = off_orig + min_d_offset;
                end
            end
        end
        function data = epi_corr( data, corr_data, Labels, data_ind, linear, per_location )
            if ~isempty( data_ind )
                if linear
                    fitting_order = size( corr_data.slope, 1 );
                    coils = unique( double( Labels.Index.chan( data_ind( data_ind ~= 0 ) ) ) );
                    locas = 0;
                    if ( per_location )
                        locas = unique( double( Labels.Index.loca( data_ind( data_ind ~= 0 ) ) ) );
                    end
                    
                    for l = 1:length( locas )
                        for c = 1:length( coils )
                            if ( per_location )
                                ind = find( corr_data.coil == coils( c ) & corr_data.loca == locas( l ) );
                            else
                                ind = find( corr_data.coil == coils( c ) );
                            end
                            
                            if ~isempty( ind )
                                cur_slope = corr_data.slope;
                                cur_offset = corr_data.offset;
                                for j = 1:fitting_order
                                    cur_slope( j, ind ) = median( corr_data.slope( ind( ~isnan( corr_data.slope( j, ind ) ) ) ) );
                                end
                                cur_offset( ind ) = median( corr_data.offset( ind( ~isnan( corr_data.offset( ind ) ) ) ) );
                                
                                cur_slope( isnan( cur_slope ) ) = 0;
                                cur_offset( isnan( cur_offset ) ) = 0;
                                
                                ind = ind( 1 );
                                sign_ind = zeros( size( data_ind ) );
                                if ( per_location )
                                    sign_ind( data_ind ~= 0 ) = double( Labels.Index.sign( data_ind( data_ind ~= 0 ) ) ) ==  - 1 &  ...
                                        double( Labels.Index.chan( data_ind( data_ind ~= 0 ) ) ) == coils( c ) &  ...
                                        double( Labels.Index.loca( data_ind( data_ind ~= 0 ) ) ) == locas( l );
                                else
                                    sign_ind( data_ind ~= 0 ) = double( Labels.Index.sign( data_ind( data_ind ~= 0 ) ) ) ==  - 1 &  ...
                                        double( Labels.Index.chan( data_ind( data_ind ~= 0 ) ) ) == coils( c );
                                end
                                
                                x = (  - floor( size( data, 1 ) / 2 ):ceil( size( data, 1 ) / 2 ) - 1 );
                                for j = 1:fitting_order
                                    lin_phase = cur_slope( j, ind ) .* x .^ ( fitting_order - j + 1 );
                                end
                                lin_phase = lin_phase + cur_offset( ind );
                                
                                
                                p = exp( 1i .* lin_phase );
                                data( :, find( sign_ind ) ) = bsxfun( @times, data( :, find( sign_ind ) ), p );
                                
                                
                                
                                
                                
                                
                                
                                
                            end
                        end
                    end
                else
                    
                    if isempty( corr_data.corr_factors )
                        error( 'Error in EPIPhaseCorrection: No correction data found' );
                    end
                    
                    
                    if size( corr_data.corr_factors, 1 ) ~= size( data, 1 )
                        error( 'Error in EPIPhaseCorrection: The size of the correction factors does not match the size of the data' );
                    end
                    
                    coils = unique( double( Labels.Index.chan( data_ind( data_ind ~= 0 ) ) ) );
                    for c = 1:length( coils )
                        ind = find( corr_data.coil == coils( c ) );
                        if ~isempty( ind )
                            ind = ind( 1 );
                            sign_ind = zeros( size( data_ind ) );
                            sign_ind( data_ind ~= 0 ) = double( Labels.Index.sign( data_ind( data_ind ~= 0 ) ) ) == 1 &  ...
                                double( Labels.Index.chan( data_ind( data_ind ~= 0 ) ) ) == coils( c );
                            
                            data( :, find( sign_ind ) ) = bsxfun( @times, data( :, find( sign_ind ) ), corr_data.corr_factors( :, ind ) );
                        end
                    end
                end
            end
        end
        function data = hamming_filter( data, filter_strength, sampled_size )
            if ~isempty( data )
                if nargin == 2
                    sampled_size = [  ];
                end
                try
                    ringing_filter( data, filter_strength, sampled_size );
                catch
                    if nargin < 3 || isempty( sampled_size )
                        sampled_size = [ size( data, 1 ), size( data, 2 ), size( data, 3 ) ];
                    end
                    
                    min_hx = 1 - max( [ 0, min( [ 0.92, filter_strength( 1 ) ] ) ] );
                    min_hy = 1 - max( [ 0, min( [ 0.92, filter_strength( 2 ) ] ) ] );
                    min_hz = 1 - max( [ 0, min( [ 0.92, filter_strength( 3 ) ] ) ] );
                    
                    
                    
                    data_size = size( data );
                    nr_images = prod( data_size( 4:end  ) );
                    
                    Mx = 2 * pi * sampled_size( 1 ) / 2 / acos( ( min_hx - 0.54 ) / 0.46 );
                    My = 2 * pi * sampled_size( 2 ) / 2 / acos( ( min_hy - 0.54 ) / 0.46 );
                    Mz = 2 * pi * sampled_size( 3 ) / 2 / acos( ( min_hz - 0.54 ) / 0.46 );
                    
                    
                    
                    
                    
                    
                    nx =  - floor( sampled_size( 1 ) / 2 ):ceil( sampled_size( 1 ) / 2 ) - 1;
                    hfilterx = real( ( 0.54 + 0.46 * cos( 2 * pi .* nx ./ Mx ) ) );
                    
                    ny =  - floor( sampled_size( 2 ) / 2 ):ceil( sampled_size( 2 ) / 2 ) - 1;
                    hfiltery = real( 0.54 + 0.46 * cos( 2 * pi .* ny ./ My ) );
                    
                    nz =  - floor( sampled_size( 3 ) / 2 ):ceil( sampled_size( 3 ) / 2 ) - 1;
                    hfilterz = real( 0.54 + 0.46 * cos( 2 * pi .* nz ./ Mz ) );
                    
                    if size( data, 1 ) ~= size( hfilterx, 1 )
                        
                        hfilterx = zero_fill( hfilterx, size( data, 1 ), 1, 1 );
                    end
                    if size( data, 2 ) ~= size( hfiltery, 2 )
                        hfiltery = zero_fill( hfiltery, 1, size( data, 2 ), 1 );
                        
                    end
                    if size( data, 3 ) ~= size( hfilterz, 2 )
                        hfilterz = zero_fill( hfilterz, 1, size( data, 3 ), 1 );
                        
                    end
                    
                    hfilter2D = ( hfilterx * hfiltery );
                    
                    
                    
                    s = size( data );
                    s( end  + 1:13 ) = 1;
                    nr_volumes = prod( s( 4:end  ) );
                    try
                        hfilter4d = bsxfun( @times, bsxfun( @times, hfilter2D, reshape( hfilterz, 1, 1, [  ] ) ), reshape( ones( nr_volumes, 1 ), 1, 1, 1, [  ] ) );
                        data = reshape( data, s( 1 ), s( 2 ), s( 3 ), nr_volumes ) .* hfilter4d;
                        data = reshape( data, s );
                    catch
                        try
                            hfilter3d = bsxfun( @times, hfilter2D, reshape( hfilterz, 1, 1, [  ] ) );
                            for i = 1:nr_volumes
                                data( :, :, :, i ) = data( :, :, :, i ) .* hfilter3d;
                            end
                        catch
                            
                            
                            for i = 1:nr_images
                                for j = 1:size( data, 3 )
                                    hfilter = hfilter2D .* hfilterz( j );
                                    data( :, :, j, i ) = data( :, :, j, i ) .* hfilter;
                                end
                            end
                        end
                    end
                end
            end
        end
        function [ data, low_res ] = partial_fourier_filter( data, kxrange, kyrange, kzrange )
            
            low_res = homodyne( 'filter', data, kxrange, kyrange, kzrange );
            low_res = MRecon.hamming_filter( low_res, [ 1, 1, 1 ] );
            low_res = MRecon.k2i( low_res, [ 1, 2, 3 ], 1 );
            low_res( isnan( low_res ) ) = 0;
            data( isnan( data ) ) = 0;
        end
        function data = partial_fourier_multiply( data, low_res )
            homodyne( 'multiply', data, low_res );
            data( isnan( data ) ) = 0;
            data( isinf( data ) ) = 0;
        end
        function perform_pf_recon = is_partial_fourier( data, kxrange, kyrange, kzrange )
            perform_pf_recon = 0;
            if ~isempty( kxrange ) && abs( kxrange( 1 ) + kxrange( 2 ) ) > 1
                act_xres = length(  - max( kxrange ):max( kxrange ) );
                hs_ratio_x = length( kxrange( 1 ):kxrange( 2 ) ) / act_xres;
                if hs_ratio_x >= 0.55 && hs_ratio_x < 1
                    perform_pf_recon = 1;
                end
            end
            if ~isempty( kyrange ) && abs( kyrange( 1 ) + kyrange( 2 ) ) > 1
                act_yres = length(  - max( kyrange ):max( kyrange ) );
                hs_ratio_y = length( kyrange( 1 ):kyrange( 2 ) ) / act_yres;
                if hs_ratio_y >= 0.55 && hs_ratio_y < 1
                    perform_pf_recon = 1;
                end
            end
            if ~isempty( kzrange ) && abs( kzrange( 1 ) + kzrange( 2 ) ) > 1
                zres = size( data, 3 );
                full_range = ( ceil(  - zres / 2 ):ceil( zres / 2 ) - 1 );
                if max( full_range ) ~= kzrange( 2 )
                    kzrange( 2 ) = max( full_range );
                end
                
                act_zres = length(  - max( kzrange ):max( kzrange ) );
                hs_ratio_z = length( kzrange( 1 ):kzrange( 2 ) ) / act_zres;
                if hs_ratio_z >= 0.55 && hs_ratio_z < 1
                    perform_pf_recon = 1;
                end
            end
        end
        function data = concom_corr( data, A, concom_factors, stacks, segs, geo_corr_pars )
            
            
            if length( stacks ) ~= size( data, 8 )
                stacks = zeros( size( data, 8 ), 1 );
            end
            if length( segs ) ~= size( data, 10 )
                segs = 0:size( data, 10 ) - 1;
            end
            
            
            unique_stacks = unique( stacks );
            nr_stacks = length( unique_stacks );
            
            for j = 1:nr_stacks
                cur_stack = unique_stacks( j );
                stack_ind = find( stacks == cur_stack );
                
                [ x, y, z ] = ndgrid( 1:size( data, 1 ), 1:size( data, 2 ), 1:size( data, 3 ) );
                xyz = single( A( :, :, min( [ size( A, 3 ), j ] ) ) * [ x( : );y( : );z( : );ones( 1, length( z( : ) ) ) ] );
                
                
                
                [ xcorr, ycorr, zcorr ] = geo_corr_omp( xyz( 1, : ), xyz( 2, : ), xyz( 3, : ), geo_corr_pars );
                xyz( 1, : ) = xcorr;
                xyz( 2, : ) = ycorr;
                xyz( 3, : ) = zcorr;
                
                
                m = 1e-3;
                x = reshape( xyz( 1, : ), size( data, 1 ), size( data, 2 ), size( data, 3 ) ) * m;
                y = reshape( xyz( 2, : ), size( data, 1 ), size( data, 2 ), size( data, 3 ) ) * m;
                z = reshape( xyz( 3, : ), size( data, 1 ), size( data, 2 ), size( data, 3 ) ) * m;
                
                
                for i = 1:size( data, 10 )
                    seg = segs( i );
                    a = concom_factors( ( seg ) * 4 + 1 );
                    b = concom_factors( ( seg ) * 4 + 2 );
                    c =  - concom_factors( ( seg ) * 4 + 3 );
                    d =  - concom_factors( ( seg ) * 4 + 4 );
                    cfc = a * ( z .^ 2 ) + b * ( x .^ 2 + y .^ 2 ) + c * ( x .* z ) + d * ( y .* z );
                    data( :, :, :, :, :, :, :, stack_ind, :, i, :, :, : ) = bsxfun( @times, data( :, :, :, :, :, :, :, stack_ind, :, i, :, :, : ), exp(  - 1i * cfc ) );
                end
            end
        end
        function data = geometry_correction( data, Parameter, stack_nr )
            if isempty( data ) || ( ndims( data ) == 2 && size( data, 2 ) == 1 )
                return ;
            end
            
            s = size( data );
            s( end  + 1:12 ) = 1;
            
            if isempty( stack_nr )
                stack_nr = 0:( size( data, 8 ) - 1 );
            end
            if length( stack_nr ) ~= size( data, 8 )
                stack_nr = 0:( size( data, 8 ) - 1 );
            end
            stacks = unique( stack_nr );
            
            try
                
                
                corr_res = [ 3, 3, 3 ];
                
                P = MRparameter.get_coord_transformation( Parameter.Scan.ijk( 1, : ), 'AP FH RL' );
                FOVPerm = abs( inv( P ) * [ 1;2;3 ] );
                yFOV = Parameter.Scan.FOV( FOVPerm( 2 ) );
                Finit = min( [ corr_res( 1 ), corr_res( 2 ) ] ./ Parameter.Scan.RecVoxelSize( 1:2 ) );
                Dy = yFOV;
                NyCSM = ceil( Dy / ( Finit * Parameter.Scan.RecVoxelSize( 2 ) ) );
                dyCSM = Dy / NyCSM;
                Fr = dyCSM / Parameter.Scan.RecVoxelSize( 2 );
                NxCSM = min( size( data, 1 ), max( 1, ceil( size( data, 1 ) / Fr ) ) );
                NyCSM = min( size( data, 2 ), max( 1, ceil( size( data, 2 ) / Fr ) ) );
                
                
                zFOV = Parameter.Scan.FOV( FOVPerm( 3 ) );
                Finit = max( 1, corr_res( 3 ) / Parameter.Scan.RecVoxelSize( 3 ) );
                Dz = zFOV;
                NzCSM = ceil( Dz / ( Finit * Parameter.Scan.RecVoxelSize( 3 ) ) );
                dzCSM = Dz / NzCSM;
                Frz = dzCSM / Parameter.Scan.RecVoxelSize( 3 );
                NzCSM = min( size( data, 3 ), max( 1, ceil( size( data, 3 ) / Frz ) ) );
                
                nr_i_pixels = NxCSM;
                nr_j_pixels = NyCSM;
                nr_k_pixels = NzCSM;
            catch
                nr_i_pixels = min( size( data, 1 ), 64 );
                nr_j_pixels = min( size( data, 2 ), 64 );
                nr_k_pixels = min( size( data, 3 ), 64 );
            end
            
            nr_i_pixels = size( data, 1 );
            nr_j_pixels = size( data, 2 );
            nr_k_pixels = size( data, 3 );
            
            [ i, j, k ] = ndgrid( linspace( single( 1 ), single( size( data, 1 ) ), nr_i_pixels ), linspace( single( 1 ), single( size( data, 2 ) ), nr_j_pixels ), linspace( single( 1 ), single( size( data, 3 ) ), nr_k_pixels ) );
            
            data = reshape( data, s( 1 ), s( 2 ), s( 3 ), prod( s( 4:7 ) ), s( 8 ), prod( s( 9:end  ) ) );
            for loca = 1:size( data, 5 )
                
                try
                    st = Parameter.Labels.StackIndex( loca ) + 1;
                catch
                    st = 1;
                end
                
                if st > size( Parameter.Scan.ijk, 1 )
                    st = size( Parameter.Scan.ijk, 1 );
                end
                
                try
                    xyz = Parameter.Transform( [ i( : ), j( : ), k( : ) ], 'ijk', 'xyz', st );
                    [ xcorr, ycorr, zcorr ] = geo_corr_omp( xyz( 1, : ), xyz( 2, : ), xyz( 3, : ), single( Parameter.Labels.GeoCorrPars ) );
                    ijk_corr = Parameter.Transform( [ xcorr( : ), ycorr( : ), zcorr( : ) ], 'xyz', 'ijk', st );
                catch
                    warning( 'MATLAB:MRecon', 'Cannot perform geometry correction. Not enough parameters' );
                    return ;
                end
                
                i_corr = reshape( ijk_corr( 1, : ), nr_i_pixels, nr_j_pixels, nr_k_pixels );
                i_corr = MRecon.imresizend( i_corr, [ size( data, 1 ), size( data, 2 ), size( data, 3 ) ], 'cubic' );
                j_corr = reshape( ijk_corr( 2, : ), nr_i_pixels, nr_j_pixels, nr_k_pixels );
                j_corr = MRecon.imresizend( j_corr, [ size( data, 1 ), size( data, 2 ), size( data, 3 ) ], 'cubic' );
                k_corr = reshape( ijk_corr( 3, : ), nr_i_pixels, nr_j_pixels, nr_k_pixels );
                k_corr = MRecon.imresizend( k_corr, [ size( data, 1 ), size( data, 2 ), size( data, 3 ) ], 'cubic' );
                
                for sl = 1:prod( s( 4:7 ) )
                    for re = 1:prod( s( 9:end  ) )
                        if nr_k_pixels == 1
                            data( :, :, :, sl, loca, re ) = reshape( interp2( data( :, :, :, sl, loca, re ), j_corr( : ), i_corr( : ), 'linear' ), size( data, 1 ), size( data, 2 ) );
                        else
                            data( :, :, :, sl, loca, re ) = reshape( interp3( data( :, :, :, sl, loca, re ), j_corr( : ), i_corr( : ), k_corr( : ), 'linear' ), size( data, 1 ), size( data, 2 ), size( data, 3 ) );
                        end
                    end
                end
            end
            data = reshape( data, s );
            data( isnan( data ) ) = 0;
        end
        
        
        
        
        function tmp = grid_data( data, GridderPars )
            isEPI = 0;
            
            tmp = [  ];
            origin_shift = 0;
            
            if ~isempty( data )
                
                no_samples = size( data, 1 );
                no_profiles = size( data, 2 );
                no_slices = size( data, 3 );
                out_res = no_samples;
                
                
                
                if ~isempty( GridderPars.KernelWidth )
                    kernel_width = GridderPars.KernelWidth;
                else
                    kernel_width = 2;
                end
                
                switch GridderPars.Preset
                    case { 'Radial', 'radial', 'RADIAL' }
                        
                        if strcmpi( GridderPars.KooshBall, 'yes' )
                            
                            
                            wrong_sizes = any( [ no_samples, no_profiles, no_slices ] ~= [ size( GridderPars.Kpos, 1 ), size( GridderPars.Kpos, 2 ), size( GridderPars.Kpos, 3 ) ] );
                            iserror = wrong_sizes == 1;
                            if iserror
                                error( 'Error in Gridder: The size of the k-space positions do not match the data size. Parameter.Gridder.Kpos has to be a Matrix of size: %d x %d x %d x 3. ( size(Data,1) x size(Data,2) x size(Data,3) x 3 )', size( data, 1 ), size( data, 2 ), size( data, 3 ) );
                            end
                            
                            out_res = [ round( GridderPars.OutputMatrixSize( 1 ) / GridderPars.GridOvsFactor( 1 ) ),  ...
                                round( GridderPars.OutputMatrixSize( 1 ) / GridderPars.GridOvsFactor( 1 ) ) ];
                            out_res_z = out_res( 1 );
                            s = size( data );
                            s( 1:3 ) = floor( GridderPars.GridOvsFactor( 1 ) * out_res( 1 ) );
                        else
                            
                            wrong_sizes = any( [ no_samples, no_profiles ] ~= [ size( GridderPars.Kpos, 1 ), size( GridderPars.Kpos, 2 ) ] );
                            iserror = wrong_sizes == 1;
                            if iserror
                                error( 'Error in Gridder: The size of the k-space positions do not match the data size. Parameter.Gridder.Kpos has to be a Matrix of size: %d x %d x 1 x 3. ( size(Data,1) x size(Data,2) x 1 x 3 )', size( data, 1 ), size( data, 2 ) );
                            end
                            
                            if strcmpi( GridderPars.RadialPhaseCorr, 'yes' )
                                if ~isempty( GridderPars.RadialAngles )
                                    try
                                        data = MRecon.radial_phase_correction( data, GridderPars );
                                    catch
                                        error( 'Error in Gridder: Could not perform the radial phase correction due to an unknown error. Please turn it off in Parameter.Gridder.RadialPhaseCorr' );
                                    end
                                    
                                else
                                    error( 'Error in Gridder: Could not perform the radial phase correction because the radial angles are unknown. Please set the radial angles in Parameter.Gridder.RadialAngles or turn off the phase correction in Parameter.Gridder.RadialPhaseCorr' );
                                end
                            end
                            
                            s = size( data );
                            out_res = [ round( GridderPars.OutputMatrixSize( 1 ) / GridderPars.GridOvsFactor( 1 ) ),  ...
                                round( GridderPars.OutputMatrixSize( 2 ) / GridderPars.GridOvsFactor( 1 ) ) ];
                            s( 1:2 ) = floor( GridderPars.GridOvsFactor * out_res );
                            data = reshape( data, size( data, 1 ), size( data, 2 ), 1, size( data( :, :, : ), 3 ) );
                            no_slices = 1;
                            out_res_z = 1;
                        end
                        kpos = single( reshape( GridderPars.Kpos, no_samples * no_profiles * no_slices, 3 ) );
                        data = reshape( single( data ), size( data, 1 ) * size( data, 2 ) * size( data, 3 ), size( data( :, :, :, : ), 4 ) );
                        weights = reshape( single( GridderPars.Weights ), no_samples * no_profiles * no_slices, 1 );
                    case { 'Spiral', 'spiral', 'SPIRAL' }
                        
                        
                        if ~isempty( GridderPars.SpiralLeadingSamples )
                            origin_shift = GridderPars.SpiralLeadingSamples;
                        else
                            origin_shift = 0;
                        end
                        data = data( ( 1 + origin_shift ):end , :, :, :, :, :, :, :, :, :, :, :, : );
                        
                        
                        wrong_sizes = any( [ no_samples - origin_shift, no_profiles ] ~= [ size( GridderPars.Kpos, 1 ), size( GridderPars.Kpos, 2 ) ] );
                        iserror = wrong_sizes == 1;
                        if iserror
                            error( 'Error in Gridder: The size of the k-space positions do not match the data size. Parameter.Gridder.Kpos has to be a Matrix of size: %d x %d x 1 x 3. ( size(Data,1)-Parameter.Gridder.SpiralLeadingSamples x size(Data,2) x 1 x 3 )', size( data, 1 ), size( data, 2 ) );
                        end
                        
                        out_res = [ ceil( GridderPars.OutputMatrixSize( 1 ) / GridderPars.GridOvsFactor( 1 ) ),  ...
                            ceil( GridderPars.OutputMatrixSize( 2 ) / GridderPars.GridOvsFactor( 1 ) ) ];
                        s = size( data );
                        s( 1:2 ) = floor( GridderPars.GridOvsFactor * out_res );
                        data = reshape( data, size( data, 1 ), size( data, 2 ), 1, size( data( :, :, : ), 3 ) );
                        no_samples = size( data, 1 );
                        no_slices = 1;
                        out_res_z = 1;
                        kpos = single( reshape( GridderPars.Kpos, no_samples * no_profiles * no_slices, 3 ) );
                        data = reshape( single( data ), size( data, 1 ) * size( data, 2 ) * size( data, 3 ), size( data( :, :, :, : ), 4 ) );
                        weights = reshape( single( GridderPars.Weights ), no_samples * no_profiles * no_slices, 1 );
                    case { 'Epi', 'epi', 'EPI' }
                        wrong_sizes = any( [ no_samples ] ~= [ size( GridderPars.Kpos, 1 ) ] );
                        iserror = wrong_sizes == 1;
                        if iserror
                            error( 'Error in Gridder: The size of the k-space positions do not match the data size. Parameter.Gridder.Kpos has to be a Matrix of size: %d x %d x 1 x 3. ( size(Data,1) x size(Data,2) x 1 x 3 )', size( data, 1 ), size( data, 2 ) );
                        end
                        out_res = [ ceil( GridderPars.OutputMatrixSize( 1 ) / GridderPars.GridOvsFactor( 1 ) ), 1 ];
                        out_res_z = 1;
                        
                        s = size( data );
                        s( 1 ) = floor( GridderPars.GridOvsFactor * out_res( 1 ) );
                        kpos = single( reshape( GridderPars.Kpos, no_samples, 3 ) );
                        data = reshape( single( data ), size( data, 1 ), size( data, 2 ) * size( data, 3 ) * size( data( :, :, :, : ), 4 ) );
                        weights = reshape( single( GridderPars.Weights ), no_samples, 1 );
                        isEPI = 1;
                    otherwise
                        
                        wrong_sizes = any( [ no_samples, no_profiles, no_slices ] ~= [ size( GridderPars.Kpos, 1 ), size( GridderPars.Kpos, 2 ), size( GridderPars.Kpos, 3 ) ] );
                        iserror = wrong_sizes == 1;
                        if iserror
                            error( 'Error in Gridder: The size of the k-space positions do not match the data size. Parameter.Gridder.Kpos has to be a Matrix of size: %d x %d x %d x 3. ( size(Data,1) x size(Data,2) x size(Data,3) x 3 )', size( data, 1 ), size( data, 2 ), size( data, 3 ) );
                        end
                        out_res = [ ceil( GridderPars.OutputMatrixSize( 1 ) / GridderPars.GridOvsFactor( 1 ) ),  ...
                            ceil( GridderPars.OutputMatrixSize( 2 ) / GridderPars.GridOvsFactor( 1 ) ) ];
                        if length( GridderPars.OutputMatrixSize ) > 2
                            out_res_z = round( GridderPars.OutputMatrixSize( 3 ) / GridderPars.GridOvsFactor( 1 ) );
                        else
                            out_res_z = 1;
                        end
                        s = size( data );
                        s( 1:2 ) = [ floor( GridderPars.GridOvsFactor * out_res( 1 ) ), floor( GridderPars.GridOvsFactor * out_res( 2 ) ) ];
                        s( 3 ) = floor( GridderPars.GridOvsFactor * out_res_z );
                        kpos = single( reshape( GridderPars.Kpos, no_samples * no_profiles * no_slices, 3 ) );
                        data = reshape( single( data ), size( data, 1 ) * size( data, 2 ) * size( data, 3 ), size( data( :, :, :, : ), 4 ) );
                        weights = reshape( single( GridderPars.Weights ), no_samples * no_profiles * no_slices, 1 );
                end
                
                
                
                tmp = gridder( kpos,  ...
                    data,  ...
                    weights,  ...
                    single( [ out_res( 1 ), out_res( 2 ), out_res_z ] ),  ...
                    single( GridderPars.GridOvsFactor ),  ...
                    single( kernel_width ), isEPI );
                
                tmp = reshape( tmp, s );
            end
        end
        function [ k, grid_ovs, rot_angles ] = calculate_trajectory( data, kx_ovs, kx_range, GridderPars, nus_enc_nrs, sense_factor )
            rot_angles = [  ];
            k = [  ];
            grid_ovs = [  ];
            
            if ~isempty( data )
                
                
                
                origin_shift = 0;
                if strcmpi( GridderPars.Preset, 'spiral' )
                    if ~isempty( GridderPars.SpiralLeadingSamples )
                        origin_shift = GridderPars.SpiralLeadingSamples;
                    else
                        slice = ceil( size( data, 3 ) / 2 );
                        [ mi, origin_shift ] = min( range( angle( data( 1:20, :, slice, :, : ) ), 2 ) );
                        origin_shift = round( median( squeeze( origin_shift ) ) );
                        GridderPars.SpiralLeadingSamples = origin_shift;
                    end
                end
                
                
                no_samples = size( data, 1 ) - origin_shift;
                no_profiles = size( data, 2 );
                no_interleaves = size( data, 2 );
                no_slices = size( data, 3 );
                
                switch GridderPars.Preset
                    case { 'Radial', 'radial', 'RADIAL' }
                        
                        if isempty( GridderPars.GridOvsFactor )
                            grid_ovs = kx_ovs / 2;
                        else
                            grid_ovs = [  ];
                        end
                        
                        if strcmpi( GridderPars.KooshBall, 'yes' )
                            profiles = linspace(  - ( no_samples - 1 ) / 2, ( no_samples - 1 ) / 2, no_samples );
                            
                            k = zeros( no_samples, no_profiles, no_slices, 3, 'single' );
                            
                            
                            
                            if ~isempty( GridderPars.RadialAngles ) && ( size( GridderPars.RadialAngles, 1 ) == 2 ) && ( size( GridderPars.RadialAngles, 2 ) > 2 )
                                GridderPars.RadialAngles = GridderPars.RadialAngles;
                            end
                            
                            for pz_number = 1:no_slices
                                for py_number = 1:no_profiles
                                    interleaf = pz_number - 1;
                                    
                                    if isempty( GridderPars.RadialAngles )
                                        
                                        z = ( py_number - 1 + 0.5 - no_profiles ) / no_profiles;
                                        
                                        phi = ( sqrt( 2. * no_profiles * pi / no_slices ) * asin( z ) ) + ( interleaf * 2.0 * pi / no_slices );
                                        
                                        if mod( py_number - 1, 2 ) == 1
                                            z =  - z;
                                            phi = phi + pi;
                                        end
                                        
                                    else
                                        
                                        if size( GridderPars.RadialAngles, 2 ) ~= 2
                                            error( 'Error in Gridder: Please specify 2 angles (theta, phi) for the kooshball trajectory. Parameter.Gridder.RadialAngles has to be a vector of size %d x %d', no_profiles * no_slices, 2 );
                                        end
                                        if length( GridderPars.RadialAngles ) < no_profiles * no_slices
                                            error( 'Error in Gridder: the number of user defined rotation angles is smaller than the number of measured profiles. Parameter.Gridder.RadialAngles has to be a vector of size %d x %d', no_profiles * no_slices, 2 );
                                        end
                                        theta = GridderPars.RadialAngles( ( pz_number - 1 ) * no_profiles + py_number, 1 );
                                        phi = GridderPars.RadialAngles( ( pz_number - 1 ) * no_profiles + py_number, 2 );
                                        z = cos( theta );
                                        
                                    end
                                    
                                    sin_theta = sqrt( 1.0 - z * z );
                                    rsinphi = profiles .* sin( phi );
                                    rcosphi = profiles .* cos( phi );
                                    
                                    k( :, py_number, pz_number, 1 ) = rsinphi .* sin_theta;
                                    k( :, py_number, pz_number, 2 ) = rcosphi .* sin_theta;
                                    k( :, py_number, pz_number, 3 ) = profiles .* z;
                                end
                            end
                        else
                            k = zeros( no_samples, 3, no_profiles, 'single' );
                            rot_angles = zeros( no_profiles, 1 );
                            
                            
                            
                            if no_samples / 2 ~= floor( no_samples / 2 )
                                k0 = single( [ zeros( 1, no_samples );linspace(  - floor( no_samples / 2 ), floor( no_samples / 2 ), no_samples ) ] );
                            else
                                k0 = single( [ zeros( 1, no_samples );linspace(  - floor( no_samples / 2 ), ceil( no_samples / 2 - 1 ), no_samples ) ] );
                            end
                            
                            for i = 0:no_profiles - 1
                                if isempty( GridderPars.RadialAngles )
                                    rot_angle =  - i * pi / no_profiles;
                                    
                                    if strcmpi( GridderPars.AlternatingRadial, 'yes' ) && mod( i, 2 )
                                        rot_angle = rot_angle + pi;
                                    end
                                else
                                    if length( GridderPars.RadialAngles ) < no_profiles
                                        error( 'Error in Gridder: the number of user defined rotation angles is smaller than the number of measured profiles. Parameter.Gridder.RadialAngles has to be a vector of size %d x %d', no_profiles, 1 );
                                    end
                                    rot_angle = GridderPars.RadialAngles( i + 1 );
                                end
                                rot_angles( i + 1 ) = rot_angle;
                                R = [ cos( rot_angle ),  - sin( rot_angle );sin( rot_angle ), cos( rot_angle ) ];
                                k( :, 1:2, i + 1 ) = ( R * k0 );
                            end
                            k = permute( k, [ 1, 3, 4, 2 ] );
                            clear k0 R;
                        end
                    case { 'Spiral', 'spiral', 'SPIRAL' }
                        if isempty( GridderPars.GridOvsFactor )
                            grid_ovs = kx_ovs / 1;
                        else
                            grid_ovs = [  ];
                        end
                        
                        
                        
                        channel_delay = 0;
                        phase_offset = 0;
                        lambda = 3;
                        
                        
                        
                        
                        acq_samples = round( length( kx_range( 1 ):kx_range( 2 ) ) / kx_ovs );
                        no_turns = acq_samples / ( 2 * no_interleaves );
                        lambda = min( no_turns, lambda );
                        phi_top = pi * acq_samples * sqrt( 1 + lambda ) / ( no_interleaves * no_samples );
                        A = no_interleaves / ( 2 * pi );
                        k = zeros( no_samples, no_interleaves, 3, 'single' );
                        
                        
                        
                        
                        for interleave = 0:no_interleaves - 1
                            phi_0 = 2 * pi * interleave / no_interleaves + phase_offset;
                            for sample = fix( channel_delay ):no_samples - 1
                                samp = channel_delay - fix( channel_delay ) + sample;
                                phi_t = phi_top * samp / sqrt( 1 + lambda * samp / no_samples );
                                k( sample + 1, interleave + 1, 1 ) = A * phi_t * cos( phi_t - phi_0 );
                                k( sample + 1, interleave + 1, 2 ) = A * phi_t * sin( phi_t - phi_0 );
                            end
                        end
                        k = reshape( k, size( k, 1 ), size( k, 2 ), 1, size( k, 3 ) );
                    case { 'Epi', 'epi', 'EPI' }
                        k = [  ];
                        if ~isempty( nus_enc_nrs )
                            if length( nus_enc_nrs ) ~= size( data, 1 )
                                error( 'Error in GridData: The length of the EPI NUS samples and nr of dsamples in Data is different --> cannot grid the EPI data' );
                            end
                            k = zeros( size( data, 1 ), 1, 1, 3 );
                            kx = nus_enc_nrs;
                            k( :, :, :, 1 ) = kx;
                            k( :, :, :, 2 ) = 0;
                            k( :, :, :, 3 ) = 0;
                            grid_ovs = 1;
                        end
                    case { 'Cartesian', 'cartesian', 'CARTESIAN' }
                        r_res = [ size( data, 1 ), size( data, 2 ), size( data, 3 ) ];
                        res = round( sense_factor( 1, : ) .* r_res );
                        
                        for i = 1:3
                            pos = 0:sense_factor( 1, i ):ceil( res( i ) / 2 - 1 );
                            neg =  - sense_factor( 1, i ): - sense_factor( 1, i ): - floor( res( i ) / 2 );
                            kxyz{ i } = [ neg( end : - 1:1 ), pos ];
                        end
                        [ kx, ky, kz ] = ndgrid( kxyz{ 1 }, kxyz{ 2 }, kxyz{ 3 } );
                        k = zeros( length( kx( : ) ), 3, 'single' );
                        k( :, 1 ) = kx( : );
                        k( :, 2 ) = ky( : );
                        k( :, 3 ) = kz( : );
                        k = reshape( k, r_res( 1 ), r_res( 2 ), r_res( 3 ), 3 );
                        grid_ovs = kx_ovs / 1;
                    otherwise
                        error( 'Error in Gridder: Gridder Preset Unknown' );
                end
            end
        end
        function weight = calculate_weights( k, GridderPars )
            weight = [  ];
            if ~isempty( k )
                switch GridderPars.Preset
                    case { 'Radial', 'radial', 'RADIAL' }
                        if strcmpi( GridderPars.KooshBall, 'yes' )
                            weight = k( :, :, :, 1 ) .^ 2 + k( :, :, :, 2 ) .^ 2 + k( :, :, :, 3 ) .^ 2;
                            weight = weight ./ ( size( k, 1 ) / 2 ) ^ 2;
                        else
                            
                            
                            gk = k( 2:end , :, :, : ) - k( 1:end  - 1, :, :, : );
                            gk( end  + 1, :, :, : ) = gk( end , :, :, : );
                            weight = abs( k( :, :, :, 1 ) .* gk( :, :, :, 1 ) + k( :, :, :, 2 ) .* gk( :, :, :, 2 ) );
                            weight( end , :, :, : ) = weight( end  - 1, :, :, : );
                            weight = weight ./ ( max( [ size( k, 1 ), size( k, 2 ) ] ) / 2 );
                            clear gk;
                        end
                    case { 'Spiral', 'spiral', 'SPIRAL' }
                        
                        
                        gk = abs( abs( k( 2:end , :, :, 1 ) + 1i * k( 2:end , :, :, 2 ) ) - abs( k( 1:end  - 1, :, :, 1 ) + 1i * k( 1:end  - 1, :, :, 2 ) ) );
                        gk( end  + 1, :, :, : ) = gk( end , :, :, : );
                        weight = abs( k( :, :, :, 1 ) + 1i * k( :, :, :, 2 ) ) .* gk;
                        weight( end , :, :, : ) = weight( end  - 1, :, :, : );
                        weight( 1, :, :, : ) = 0;
                        clear gk;
                    case { 'Epi', 'epi', 'EPI' }
                        weight = ones( size( k, 1 ), 1, 1 );
                    case { 'Cartesian', 'cartesian', 'CARTESIAN' }
                        weight = ones( size( k, 1 ), size( k, 2 ), size( k, 3 ) );
                    otherwise
                        weight = ones( size( k, 1 ), size( k, 2 ), size( k, 3 ) );
                end
            end
        end
        function data = gridder_normalization( data, kernel_width, is_3d, ovs_x, ovs_y, ovs_z, x_range, y_range, z_range )
            
            if ( nargin == 3 )
                ovs_x = 1;
                ovs_y = 1;
                ovs_z = 1;
                x_range = [  ];
                y_range = [  ];
                z_range = [  ];
            end
            if ( nargin == 4 )
                ovs_y = ovs_x;
                ovs_z = ovs_x;
                x_range = [  ];
                y_range = [  ];
                z_range = [  ];
            end
            if ( nargin == 5 )
                ovs_z = ovs_y;
                x_range = [  ];
                y_range = [  ];
                z_range = [  ];
            end
            if ( nargin == 6 )
                x_range = [  ];
                y_range = [  ];
                z_range = [  ];
            end
            if ( nargin == 7 )
                y_range = [  ];
                z_range = [  ];
            end
            if ( nargin == 8 )
                z_range = [  ];
            end
            
            if ( isempty( ovs_x ) )
                ovs_x = 1;
            end
            if ( isempty( ovs_y ) )
                ovs_y = 1;
            end
            if ( isempty( ovs_z ) )
                ovs_z = 1;
            end
            
            
            
            out_res_x = size( data, 1 );
            out_res_y = size( data, 2 );
            out_res_z = size( data, 3 );
            
            fnorm_x = zeros( out_res_x, 1 );
            fnorm_y = zeros( out_res_y, 1 );
            fnorm_z = zeros( out_res_z, 1 );
            
            beta_x = pi * sqrt( ( ( 2 * kernel_width ) ^ 2 / ovs_x ^ 2 ) * ( ovs_x - 0.5 ) ^ 2 - 0.8 );
            xx_pix = (  - floor( kernel_width / 2 * ovs_x ):floor( kernel_width / 2 * ovs_x ) );
            xx = xx_pix ./ ovs_x;
            bessel_lookup_x = besseli( 0, beta_x * sqrt( 1 - ( 2 * ( xx ) / kernel_width ) .^ 2 ) );
            bessel_lookup_x = bessel_lookup_x ./ max( bessel_lookup_x );
            center_x = floor( out_res_x / 2 ) + 1 + xx_pix;
            mask_x = center_x > 0 & center_x <= out_res_x;
            center_x = center_x( mask_x );
            
            beta_y = pi * sqrt( ( ( 2 * kernel_width ) ^ 2 / ovs_y ^ 2 ) * ( ovs_y - 0.5 ) ^ 2 - 0.8 );
            yy_pix = (  - floor( kernel_width / 2 * ovs_y ):floor( kernel_width / 2 * ovs_y ) );
            yy = yy_pix ./ ovs_y;
            bessel_lookup_y = besseli( 0, beta_y * sqrt( 1 - ( 2 * ( yy ) / kernel_width ) .^ 2 ) );
            bessel_lookup_y = bessel_lookup_y ./ max( bessel_lookup_y );
            center_y = floor( out_res_y / 2 ) + 1 + yy_pix;
            mask_y = center_y > 0 & center_y <= out_res_y;
            center_y = center_y( mask_y );
            
            beta_z = pi * sqrt( ( ( 2 * kernel_width ) ^ 2 / ovs_z ^ 2 ) * ( ovs_z - 0.5 ) ^ 2 - 0.8 );
            zz_pix = (  - floor( kernel_width / 2 * ovs_z ):floor( kernel_width / 2 * ovs_z ) );
            zz = zz_pix ./ ovs_z;
            bessel_lookup_z = besseli( 0, beta_z * sqrt( 1 - ( 2 * ( zz ) / kernel_width ) .^ 2 ) );
            bessel_lookup_z = bessel_lookup_z ./ max( bessel_lookup_z );
            center_z = floor( out_res_z / 2 ) + 1 + zz_pix;
            mask_z = center_z > 0 & center_z <= out_res_z;
            center_z = center_z( mask_z );
            
            fnorm_x( center_x ) = bessel_lookup_x( mask_x );
            fnorm_y( center_y ) = bessel_lookup_y( mask_y );
            fnorm_z( center_z ) = bessel_lookup_z( mask_z );
            
            fnorm_x = fftshift( fft( fnorm_x ) );
            fnorm_y = fftshift( fft( fnorm_y ) );
            fnorm_z = fftshift( fft( fnorm_z ) );
            
            if ( ~is_3d )
                fnorm_z = ones( size( fnorm_z ) );
            end
            
            fnorm_x = MRecon.shift_image( fnorm_x, x_range, [  ], [  ], [  ] );
            fnorm_y = squeeze( MRecon.shift_image( reshape( fnorm_y, 1, length( fnorm_y ) ), [  ], y_range, [  ], [  ] ) );
            fnorm_z = squeeze( MRecon.shift_image( reshape( fnorm_z, 1, 1, length( fnorm_z ) ), [  ], [  ], [  ], z_range ) );
            
            for j = 1:size( data( :, :, :, : ), 4 )
                for i = 1:size( data, 3 )
                    fnorm2d = abs( fnorm_x ) * abs( fnorm_y ) .* abs( fnorm_z( i ) );
                    data( :, :, i, j ) = data( :, :, i, j ) ./ fnorm2d;
                end
            end
        end
        function data = radial_phase_correction( data, GridderPars )
            GridderPars.Kpos = MRecon.Convert2Cell( GridderPars.Kpos );
            GridderPars.RadialAngles = MRecon.Convert2Cell( GridderPars.RadialAngles );
            
            no_samples = size( data, 1 );
            no_profiles = size( data, 2 );
            wrong_sizes = cellfun( @( x )any( [ no_samples, no_profiles ] ~= [ size( x, 1 ), size( x, 2 ) ] ), GridderPars.Kpos );
            iserror = all( wrong_sizes );
            cell_index = find( wrong_sizes == 0 );
            if iserror || isempty( cell_index )
                error( 'Error in Gridder: The size of the k-space positions do not match the data size. Parameter.Gridder.Kpos has to be a Matrix of size: %d x %d x 1 x 3. ( size(Data,1) x size(Data,2) x 1 x 3 )', size( data, 1 ), size( data, 2 ) );
            end
            
            zero2pi = 0;
            signs = zeros( length( GridderPars.RadialAngles{ cell_index } ), 1 );
            radial_angles = mod( GridderPars.RadialAngles{ cell_index }, 2 * pi );
            if ~isempty( radial_angles )
                even_profiles = radial_angles > 0 & radial_angles < pi;
                odd_profiles = radial_angles > pi & radial_angles < 2 * pi;
                
                if length( find( even_profiles ) ) ~= length( find( odd_profiles ) ) && mod( length( find( radial_angles == 0 ) ), 2 )
                    if length( find( even_profiles ) ) > length( find( odd_profiles ) )
                        radial_angles( radial_angles == 0 ) = 2 * pi;
                        zero2pi = 1;
                    end
                end
                even_profiles = radial_angles >= 0 & radial_angles < pi;
                odd_profiles = radial_angles > pi & radial_angles <= 2 * pi;
            else
            end
            signs( even_profiles ) = 1;
            signs( odd_profiles ) =  - 1;
            
            radial_angles = mod( radial_angles, pi );
            if zero2pi
                radial_angles( radial_angles == 0 ) = pi;
            end
            [ sorted_angles, ind_sorted ] = sort( radial_angles );
            signs = signs( ind_sorted );
            
            ind_even = find( signs == 1 );
            ind_odd = find( signs ==  - 1 );
            l = min( [ length( ind_even ), length( ind_odd ) ] );
            ind_even = ind_even( 1:l );
            ind_odd = ind_odd( 1:l );
            
            data = MRecon.k2i( data, 1, 1 );
            
            linPhase = sum( bsxfun( @times, data( 1:end  - 2, ind_sorted( ind_even ), :, :, : ), conj( data( 2:end  - 1, ind_sorted( ind_even ), :, :, : ) ) ) );
            linPhase2 = sum( bsxfun( @times, data( 1:end  - 2, ind_sorted( ind_odd ), :, :, : ), conj( data( 2:end  - 1, ind_sorted( ind_odd ), :, :, : ) ) ) );
            
            linPhase = linPhase ./ abs( linPhase );
            linPhase( isnan( linPhase ) ) = 0;
            linPhase = angle( linPhase );
            linPhase2 = linPhase2 ./ abs( linPhase2 );
            linPhase2( isnan( linPhase2 ) ) = 0;
            linPhase2 = angle( linPhase2 );
            linPhaseavr = ( linPhase + linPhase2 ) / 2;
            
            
            
            
            linPhaseavr = median( linPhaseavr, 2 );
            
            phase_off =  - size( data, 2 ) * linPhaseavr;
            data( :, ind_sorted( ind_even ), :, :, : ) = bsxfun( @times, data( :, ind_sorted( ind_even ), :, :, : ), exp( 1i .* bsxfun( @plus, bsxfun( @times, ( 0:( size( data, 1 ) - 1 ) ), linPhaseavr ), phase_off ) ) );
            data( :, ind_sorted( ind_odd ), :, :, : ) = bsxfun( @times, data( :, ind_sorted( ind_odd ), :, :, : ), exp( 1i .* bsxfun( @plus, bsxfun( @times, ( 0:( size( data, 1 ) - 1 ) ), linPhaseavr ), phase_off ) ) );
            
            
            absPhase = sum( data( 1:end  - 1, :, :, :, : ), 1 );
            
            
            
            [ ma, ind_max ] = max( reshape( abs( sum( sum( absPhase( :, :, :, :, : ), 2 ), 5 ) ), [  ], 1 ) );
            [ sl, co ] = ind2sub( [ size( absPhase, 3 ), size( absPhase, 4 ) ], ind_max );
            absPhase = absPhase( :, :, sl, co, : );
            absPhase = absPhase ./ abs( absPhase );
            absPhase( isnan( absPhase ) ) = 0;
            
            absPhase = angle( absPhase );
            absPhasem = sum( sum( absPhase( :, :, :, :, : ), 2 ), 5 );
            absPhasem = absPhasem ./ ( 1 * size( absPhase( :, :, :, :, : ), 5 ) );
            absPhase = bsxfun( @minus, absPhase, absPhasem );
            data( :, :, :, :, : ) = bsxfun( @times, data( :, :, :, :, : ), exp( 1i * ( bsxfun( @plus,  - absPhase, absPhasem ) ) ) );
            
            data = MRecon.i2k( data, 1, 1 );
            
            GridderPars.Kpos = MRecon.UnconvertCell( GridderPars.Kpos );
            GridderPars.RadialAngles = MRecon.UnconvertCell( GridderPars.RadialAngles );
        end
        
        
        
        
        function img = k2i( img, dims, inplace, spectro )
            if nargin < 2
                dims = 1:ndims( img );
            end
            if nargin < 3
                inplace = 0;
            end
            
            if nargin < 4
                spectro = false;
            end
            
            for dim = dims
                if size( img, dim ) ~= 1
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    n = size( img, dim );
                    
                    if ~spectro
                        img = ifftshift( img, dim );
                    end
                    
                    img = sqrt( n ) .* ifft( img, [  ], dim );
                    img = fftshift( img, dim );
                    
                end
            end
        end
        function img = i2k( img, dims, inplace, spectro )
            if nargin < 2
                dims = 1:ndims( img );
            end
            if nargin < 3
                inplace = 0;
            end
            
            if nargin < 4
                spectro = false;
            end
            
            for dim = dims
                if size( img, dim ) ~= 1
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    n = size( img, dim );
                    img = ifftshift( img, dim );
                    img = 1 / sqrt( n ) .* fft( img, [  ], dim );
                    
                    if ~spectro
                        img = fftshift( img, dim );
                    end
                    
                    
                end
            end
        end
        function img = shift_image( img, xrange, yrange, zrange, ZRes )
            if nargin < 5
                ZRes = [  ];
            end
            xshift = 0;
            yshift = 0;
            zshift = 0;
            
            shiftx = 0;
            shifty = 0;
            shiftz = 0;
            
            if ~isempty( xrange )
                if xrange( 1 ) > xrange( 2 )
                    
                    xrange = xrange( end : - 1:1 );
                end
                nr_xsamples = length( xrange( 1 ):xrange( 2 ) );
                min_x =  - floor( nr_xsamples / 2 );
                shiftx = min_x - xrange( 1 );
                if 2 * shiftx - nr_xsamples == 0
                    xshift = 1;
                    shiftx = 0;
                else
                    
                    
                    
                    if abs( nr_xsamples - size( img, 1 ) ) > 1
                        shiftx = round( shiftx / nr_xsamples * size( img, 1 ) );
                    end
                end
                
                
                
                
                
                shiftx =  - shiftx - 1;
            end
            
            if ~isempty( yrange )
                if yrange( 1 ) > yrange( 2 )
                    
                    yrange = yrange( end : - 1:1 );
                end
                nr_ysamples = length( yrange( 1 ):yrange( 2 ) );
                min_y =  - floor( nr_ysamples / 2 );
                shifty = min_y - yrange( 1 );
                if 2 * shifty - nr_ysamples == 0
                    yshift = 1;
                    shifty = 0;
                else
                    
                    
                    
                    if abs( nr_ysamples - size( img, 2 ) ) > 1
                        shifty = round( shifty / nr_ysamples * size( img, 2 ) );
                    end
                    
                end
                
                
                
                
                shifty = shifty - 1;
            end
            if ~isempty( zrange )
                if zrange( 1 ) > zrange( 2 )
                    
                    zrange = zrange( end : - 1:1 );
                end
                nr_zsamples = length( zrange( 1 ):zrange( 2 ) );
                min_z =  - floor( nr_zsamples / 2 );
                shiftz = min_z - zrange( 1 );
                
                if mod( round( 2 * shiftz / nr_zsamples ), 2 )
                    zshift = 1;
                end
                
            end
            if xshift
                ifftshiftc( img, 1 );
            end
            if yshift
                ifftshiftc( img, 2 );
            end
            if zshift
                
                
                
                if abs( nr_zsamples - size( img, 3 ) ) > 1
                    if ~isempty( ZRes ) && ~mod( ZRes, 2 )
                        shiftz = shiftz + 1;
                    end
                    shiftz = floor( shiftz / nr_zsamples * size( img, 3 ) );
                else
                    if ~isempty( ZRes ) && ( ~mod( size( img, 3 ), 2 ) && ~mod( ZRes, 2 ) )
                        shiftz = shiftz + 1;
                    end
                end
                shiftz =  - shiftz;
            end
            
            
            img = circshift( img, [ shiftx, shifty, shiftz ] );
            
        end
        
        
        
        
        function V_sos = sos( V, dim )
            
            if size( V, dim ) > 1
                if nargin == 1
                    dim = 4;
                end
                V_sos = V .* conj( V );
                V_sos = sum( V_sos, dim );
                V_sos = sqrt( V_sos );
            else
                V_sos = V;
            end
        end
        function V = pcsos( V, dim )
            seg_dim = 10;
            
            if size( V, dim ) > 1
                
                if nargin == 1
                    dim = 4;
                end
                
                
                
                sos = sqrt( sum( abs( V ) .^ 2, dim ) );
                
                
                
                
                weight = mean( abs( V ), seg_dim );
                V = bsxfun( @times, sos, exp( 1i .* angle( sum( bsxfun( @times, weight, V ), dim ) ) ) );
            end
            
        end
        
        
        
        
        function data = sense_recon( coil_red, sens_image, psi, res, coil_ref, body_ref, reg_strength )
            
            
            if ( reg_strength == 0 ), reg_strength = eps;end
            
            res = round( res );
            s = size( coil_red );
            s( end  + 1:12 ) = 1;
            
            
            
            body_ref( body_ref == 0 ) = 0.001;
            
            data = sense_unfold_omp( coil_red, sens_image, psi, res, coil_ref, body_ref, reg_strength );
            data = reshape( data, res( 1 ), res( 2 ), res( 3 ), 1, s( 5 ), s( 6 ), s( 7 ), s( 8 ), s( 9 ), s( 10 ), s( 11 ), s( 12 ) );
            data( isnan( data ) ) = 0;
            data( isinf( data ) ) = 0;
        end
        
        
        
        
        function [ data, data_ind ] = ZeroPad( data, xres, yres, zres, data_ind )
            if nargin == 4
                data_ind = [  ];
            end
            if isempty( xres )
                xres =  - 1;
            end
            if isempty( yres )
                yres =  - 1;
            end
            if isempty( zres )
                zres =  - 1;
            end
            n = round( [ xres, yres, zres ] );
            if ~isempty( data )
                padind = find( n ~=  - 1 );
                if ~isempty( padind )
                    data_size = size( data );
                    newdata_size( padind ) = n( n ~=  - 1 );
                    center_newdata = floor( newdata_size ./ 2 ) + 1;
                    for i = padind
                        nr_zeros = n( i ) - size( data, i );
                        if nr_zeros > 0
                            s = size( data );
                            s( i ) = nr_zeros;
                            shift = zeros( 1, length( s ) );
                            shift( i ) = floor( nr_zeros / 2 );
                            z = zeros( s );
                            data = cat( i, data, z );
                            data = circshift( data, shift );
                            
                            if ~isempty( data_ind ) && i ~= 1
                                try
                                    z = zeros( [ 1, s( 2:end  ) ] );
                                    data_ind = cat( i, data_ind, z );
                                    data_ind = circshift( data_ind, shift );
                                catch
                                    data_ind = [  ];
                                end
                            end
                        end
                    end
                end
            end
        end
        function [ data, data_ind ] = rem_ovs( data, data_ind, ox, oy, oz )
            if isempty( ox )
                ox = 1;
            end
            if isempty( oy )
                oy = 1;
            end
            if isempty( oz )
                oz = 1;
            end
            oversampling = [ ox, oy, oz ];
            nr_dims = min( length( oversampling ), ndims( data ) );
            s = size( data );
            str = [  ];
            for i = 1:ndims( data )
                if i <= nr_dims
                    os = oversampling( i );
                else
                    os = 1;
                end
                res = size( data, i );
                nrsamples2keep = round( res / os );
                nrsamples2remove = res - nrsamples2keep;
                samples2keep = [ ceil( nrsamples2remove / 2 ) + 1, res - floor( nrsamples2remove / 2 ) ];
                
                str = [ str, num2str( samples2keep( 1 ) ), ':', num2str( samples2keep( 2 ) ), ',' ];
            end
            
            str_data = [ 'data = data(', str( 1:end  - 1 ), ');' ];
            eval( str_data );
            if ~isempty( data_ind )
                try
                    comma_ind = findstr( str, ',' );
                    str_data_ind = [ 'data_ind = data_ind(:, ', str( comma_ind( 1 ) + 1:end  - 1 ), ');' ];
                    eval( str_data_ind );
                catch
                    data_ind = [  ];
                end
            end
        end
        function data = scale_image( data )
            if ~isempty( data )
                thresh = 0.98;
                
                [ h, x ] = hist( data( : ), 100 );
                c = cumsum( h );
                ind_thresh = find( c ./ c( end  ) > thresh, 1 );
                data( data( : ) > x( ind_thresh ) ) = x( ind_thresh );
            end
        end
        function data = rotate_image_new( data, from_system, to_system, stack_nr )
            if isempty( stack_nr )
                stack_nr = 0:( size( data, 8 ) - 1 );
            end
            if length( stack_nr ) ~= size( data, 8 )
                stack_nr = 0:( size( data, 8 ) - 1 );
            end
            stacks = unique( stack_nr );
            
            
            
            
            permuted = 0;
            if size( data, 1 ) ~= size( data, 2 )
                P = MRparameter.get_coord_transformation( from_system( 1, : ), to_system( 1, : ) );
                perm = P * [ 1;2;3 ];
                perm = abs( perm );
                perm( end  + 1:13 ) = ( length( perm ) + 1 ):13;
                data = permute( data, perm );
                permuted = 1;
            end
            
            for i = 1:length( stacks )
                
                stack_ind = find( stack_nr == stacks( i ) );
                if i <= size( from_system, 1 ) && i <= size( to_system, 1 )
                    cur_from_system = from_system( i, : );
                    cur_to_system = to_system( i, : );
                else
                    cur_from_system = from_system( end , : );
                    cur_to_system = to_system( end , : );
                end
                
                P = MRparameter.get_coord_transformation( cur_from_system, cur_to_system );
                perm = P * [ 1;2;3 ];
                sign_perm = sign( perm );
                perm = abs( perm );
                perm( end  + 1:13 ) = ( length( perm ) + 1 ):13;
                
                if ~permuted
                    data( :, :, :, :, :, :, :, stack_ind, :, :, :, :, :, : ) = permute( data( :, :, :, :, :, :, :, stack_ind, :, :, :, :, :, : ), perm );
                end
                if sign_perm( 1 ) ==  - 1
                    data( :, :, :, :, :, :, :, stack_ind, :, :, :, :, :, : ) = flipdim( data( :, :, :, :, :, :, :, stack_ind, :, :, :, :, :, : ), 1 );
                end
                if sign_perm( 2 ) ==  - 1
                    data( :, :, :, :, :, :, :, stack_ind, :, :, :, :, :, : ) = flipdim( data( :, :, :, :, :, :, :, stack_ind, :, :, :, :, :, : ), 2 );
                end
                if sign_perm( 3 ) ==  - 1
                    data( :, :, :, :, :, :, :, stack_ind, :, :, :, :, :, : ) = flipdim( data( :, :, :, :, :, :, :, stack_ind, :, :, :, :, :, : ), 3 );
                end
            end
        end
        function [ data, mps ] = rotate_image( data, action, isepi, isradial )
            mps = [ 1, 2, 3 ];
            if ~isempty( data )
                data = flipdim( data, 3 );
                
                if isradial
                    dim = 1:ndims( data );
                    dim( 1 ) = 2;
                    dim( 2 ) = 1;
                    data = permute( data, dim );
                    mps = [ mps( 2 ), mps( 1 ), mps( 3 ) ];
                end
                
                
                
                
                
                
                if isepi
                    data = reshape( data( end : - 1:1, end : - 1:1, : ), size( data ) );
                end
                switch action
                    case 'RotateLeft'
                        s = size( data );
                        v = [ 2, 1, 3:ndims( data ) ];
                        data = permute( data( :, s( 2 ): - 1:1, : ), v );
                        data = reshape( data, s( v ) );
                        mps = [ mps( 2 ), mps( 1 ), mps( 3 ) ];
                    case 'RotateRight'
                        s = size( data );
                        v = [ 2, 1, 3:ndims( data ) ];
                        data = reshape( data( s( 1 ): - 1:1, : ), s );
                        data = permute( data, v );
                        mps = [ mps( 2 ), mps( 1 ), mps( 3 ) ];
                    case 'Flip'
                        data = flipdim( flipdim( data, 1 ), 2 );
                end
                
                
                data = flipdim( data, 2 );
                
                
                
                
                
                
            end
        end
        function data = invert_flow_segments( data, venc, mps_system, stack_nr, is_hadamard )
            try
                if isempty( stack_nr )
                    stack_nr = 0:( size( data, 8 ) - 1 );
                end
                if length( stack_nr ) ~= size( data, 8 )
                    stack_nr = 0:( size( data, 8 ) - 1 );
                end
                stacks = unique( stack_nr );
                
                for j = 1:length( stacks )
                    stack_ind = find( stack_nr == stacks( j ) );
                    if j <= size( mps_system, 1 )
                        cur_mps_system = mps_system( j, : );
                    else
                        cur_mps_system = mps_system( end , : );
                    end
                    
                    cur_segment = 1;
                    c = cellstr( MRparameter.unformat_coord_str( cur_mps_system ) );
                    for i = 1:length( venc )
                        
                        
                        if venc( i ) ~= 0
                            
                            
                            cur_flow_dir = strtrim( c{ i } );
                            
                            
                            if i == 3 && ~is_hadamard
                                temp = cur_flow_dir( 1 );
                                cur_flow_dir( 1 ) = cur_flow_dir( 2 );
                                cur_flow_dir( 2 ) = temp;
                            end
                            if any( strcmpi( cur_flow_dir, { 'HF', 'PA', 'LR' } ) )
                                if size( data, 10 ) >= cur_segment
                                    data( :, :, :, :, :, :, :, stack_ind, :, cur_segment, :, :, : ) = conj( data( :, :, :, :, :, :, :, stack_ind, :, cur_segment, :, :, : ) );
                                end
                            end
                            cur_segment = cur_segment + 1;
                        end
                    end
                end
            catch
                warning( 'Could not invert all the flow segments. An unknown error occured' );
            end
        end
        function data = convert2int( data, type, imin, imax )
            if nargin == 1 || isempty( type )
                type = 'abs';
            end
            if nargin < 3 || isempty( imin )
                imin = 0;
            end
            if nargin < 4 || isempty( imax )
                imax = 4095;
            end
            
            if ~isempty( data )
                switch type
                    case 'M'
                        data = floor( single( imax - imin ) .* mat2gray( abs( data ) ) + single( imin ) );
                    case 'P'
                        data = floor( single( imax - imin ) .* mat2gray( angle( data ) ) + single( imin ) );
                    case 'R'
                        data = floor( single( imax - imin ) .* mat2gray( real( data ) ) + single( imin ) );
                    case 'I'
                        data = floor( single( imax - imin ) .* mat2gray( imag( data ) ) + single( imin ) );
                end
            end
        end
        function data = divide_segments( data, method, tke )
            if isempty( method )
                method = 'MPS';
            end
            if isempty( tke )
                tke = 'No';
            end
            if size( data, 10 ) > 1
                if strcmpi( method, 'Hadamard' )
                    if size( data, 10 ) < 4
                        error( [ 'Error in DivideFlowSegments: Four segments are needed to reconstruct the Hadamard encoding scheme. Currently only ', num2str( size( data, 10 ) ), ' are present' ] );
                    end
                    data_norm = data ./ abs( data );
                    
                    data( :, :, :, :, :, :, :, :, :, 2, :, :, : ) = abs( data( :, :, :, :, :, :, :, :, :, 2, :, :, : ) ) .* ( data_norm( :, :, :, :, :, :, :, :, :, 1, :, :, : ) ./ data_norm( :, :, :, :, :, :, :, :, :, 3, :, :, : ) ) .^ 0.5 .* ( data_norm( :, :, :, :, :, :, :, :, :, 2, :, :, : ) ./ data_norm( :, :, :, :, :, :, :, :, :, 4, :, :, : ) ) .^ 0.5;
                    data( :, :, :, :, :, :, :, :, :, 3, :, :, : ) = abs( data( :, :, :, :, :, :, :, :, :, 4, :, :, : ) ) .* ( data_norm( :, :, :, :, :, :, :, :, :, 1, :, :, : ) ./ data_norm( :, :, :, :, :, :, :, :, :, 2, :, :, : ) ) .^ 0.5 .* ( data_norm( :, :, :, :, :, :, :, :, :, 3, :, :, : ) ./ data_norm( :, :, :, :, :, :, :, :, :, 4, :, :, : ) ) .^ 0.5;
                    data( :, :, :, :, :, :, :, :, :, 4, :, :, : ) = abs( data( :, :, :, :, :, :, :, :, :, 3, :, :, : ) ) .* ( data_norm( :, :, :, :, :, :, :, :, :, 2, :, :, : ) ./ data_norm( :, :, :, :, :, :, :, :, :, 1, :, :, : ) ) .^ 0.5 .* ( data_norm( :, :, :, :, :, :, :, :, :, 3, :, :, : ) ./ data_norm( :, :, :, :, :, :, :, :, :, 4, :, :, : ) ) .^ 0.5;
                else
                    data = bsxfun( @times, conj( data ), exp( 1i * angle( data( :, :, :, :, :, :, :, :, :, 1, :, :, : ) ) ) );
                end
                if strcmpi( tke, 'no' )
                    data = bsxfun( @times, mean( abs( data ), 10 ), exp( 1i * angle( data( :, :, :, :, :, :, :, :, :, 2:end , :, :, : ) ) ) );
                    
                end
                data( isnan( data ) ) = 0;
                data( isinf( data ) ) = 0;
            end
        end
        function [ data, tke_map ] = recon_tke( data, rho, kv, venc )
            tke_thrsh = 1000;
            if size( data, 10 ) == size( kv, 1 )
                datasize = size( data );
                kv_directions = sum( abs( kv ) ) > 0;
                tke_map = zeros( [ datasize( 1:9 ), sum( kv_directions ), datasize( 11:end  ) ], 'single' );
                abs_map = mean( abs( data ), 10 );
                idx = 1;
                for MPS = find( kv_directions > 0 )
                    idx = idx + 1;
                    data_idx = [ 1;find( kv( :, MPS ) ~= 0 ) ];
                    max_venc = max( abs( venc( :, MPS ) ), [  ], 1 ) / 100;
                    for card = 1:datasize( 6 )
                        tic
                        [ out_v, out_D ] = solve_TKE_mex( double( permute( reshape( data( :, :, :, :, :, card, :, :, :, data_idx, :, :, : ),  ...
                            [ prod( datasize( 1:3 ) ), length( data_idx ) ] ), [ 2, 1 ] ) ),  ...
                            abs( kv( data_idx, MPS ) ) );
                        tke_map( :, :, :, :, :, card, :, :, :, MPS ) = reshape( out_D, datasize( 1:3 ) );
                        out_v( out_v > max_venc ) = max_venc;
                        out_v( out_v <  - max_venc ) =  - max_venc;
                        out_v = out_v ./ max_venc .* pi;
                        data( :, :, :, :, :, card, :, :, :, idx ) = abs_map( :, :, :, :, :, card, :, :, :, :, :, :, : ) .* exp( 1i * reshape( out_v, datasize( 1:3 ) ) );
                        disp( sprintf( 'direction %d of %d, card %d of %d', MPS, sum( kv_directions ), card, datasize( 6 ) ) );
                        toc
                    end
                end
                data = data( :, :, :, :, :, :, :, :, :, 2:sum( kv_directions ) + 1 );
                data( isnan( data ) ) = 0;
                data( isinf( data ) ) = 0;
                tke_map( isnan( tke_map ) ) = 0;
                tke_map( isinf( tke_map ) ) = 0;
                tke_map = 0.5 * rho * ( sum( tke_map .^ 2, 10 ) );
                tke_map( tke_map > tke_thrsh ) = tke_thrsh;
            end
        end
        function data = fit_flow_phase( data )
            for i = 1:size( data, 3 )
                for j = 1:size( data, 8 )
                    for k = 1:size( data, 10 )
                        cur_img = mean( data( :, :, i, 1, 1, :, 1, j, 1, k, 1, 1, 1 ), 6 );
                        w = ( abs( cur_img ) ./ max( abs( cur_img( : ) ) ) ) ./ exp( 2 .* abs( angle( cur_img ) ) );
                        p = MRecon.polyfitweighted2( 1:size( cur_img, 2 ), 1:size( cur_img, 1 ), angle( cur_img ), 3, w );
                        cur_phase = MRecon.polyval2( p, 1:size( cur_img, 2 ), 1:size( cur_img, 1 ) );
                        data( :, :, i, :, :, :, :, j, :, k, :, :, : ) = bsxfun( @times, data( :, :, i, :, :, :, :, j, :, k, :, :, : ), exp(  - 1i .* cur_phase ) );
                    end
                end
            end
        end
        
        
        
        
        function filename = write_sdat( filename, fid, par, machineformat )
            
            
            
            
            
            
            
            
            
            
            
            
            if nargin < 1
                help( mfilename )
                return
            end
            
            error( nargchk( 2, 4, nargin ) );
            if nargin < 4
                machineformat = 'd';
            end
            if isempty( filename ),
                [ filename, pname ] = uiputfile( { '*.sdat' }, 'Choose filename' );
                
                filename = [ pname, filename ]
                if isnumeric( filename ), if filename == 0, return ;end ;end
            end
            if isempty( regexpi( filename, '\.sdat' ) ),
                filename = [ filename, '.sdat' ];
            end
            if exist( filename, 'var' ),
                fprintf( 'File %s is existing\n', filename );
                str = input( 'continue?  ', 's' );
                if str( 1 ) ~= 'y',
                    fprintf( 'aborting\n' );
                    return ;
                end
            end
            
            [ x, y ] = size( fid );
            
            
            if exist( 'par', 'var' )
                if par.samples ~= y,
                    warning( 'Samples in par-file wrong: correcting' );
                    par.samples = y;
                end
                if par.rows ~= x,
                    warning( 'Rows in par-file wrong: correcting' );
                    par.rows = x;
                end
                MRecon.write_spar( filename( 1:end  - 5 ), par );
            end
            
            
            if ( machineformat == 'n' )
                fileid = fopen( filename, 'w', machineformat );
                ff( :, 1:2:2 * y ) = real( fid );
                ff( :, 2:2:2 * y ) = imag( fid );
                fwrite( fileid, ff.ESC, 'float' );
                fclose( fileid );
            else
                fileid = fopen( filename, 'w', 'ieee-le' );
                ff( :, 1:2:2 * y ) = real( fid );
                ff( :, 2:2:2 * y ) = imag( fid );
                MRecon.fwriteVAXD( fileid, ff.ESC, 'float' );
                fclose( fileid );
            end
            
            [ xx, yy ] = size( ff );
            if xx ~= x | yy ~= 2 * y
                error( 'size' );
            end
        end
        function write_spar( filename, par, sall )
            
            
            
            
            
            
            
            
            
            
            if isempty( regexpi( filename, '\.spar' ) ),
                filename = [ filename, '.spar' ];
            end
            if exist( filename ),
                fprintf( 'File %s is existing\n', filename );
                str = input( 'continue?  ', 's' );
                if str( 1 ) ~= 'y',
                    fprintf( 'aborting\n' );
                    return ;
                end
            end
            
            
            fileid = fopen( filename, 'wt' );
            if exist( 'sall' ) ~= 1
                MRecon.print_header( fileid, true );
            end
            names = fieldnames( par );
            [ x, y ] = size( names );
            for l = 1:x,
                field = getfield( par, names{ l } );
                if isempty( field ), field = ' ';end
                if ~isnan( field ),
                    if ischar( field ),
                        fprintf( fileid, '%s : %s\n', names{ l }, field );
                    else
                        if ( ( ceil( field ) - field ) ~= 0 ),
                            fprintf( fileid, '%s : %.6f\n', names{ l }, field );
                        else
                            fprintf( fileid, '%s : %g\n', names{ l }, field );
                        end
                    end
                    if exist( 'sall' ) ~= 1, fprintf( fileid, '\n' );end
                else
                    fprintf( 'Warning (write_spar): not writing %s : %s (NaN)\n', names{ l }, field );
                end
            end
            fclose( fileid );
        end
        function print_header( fileid, ds )
            fprintf( fileid, [ '!-------------------------------------------------' ...
                , '-------------------\n' ] );
            if ds, fprintf( fileid, '\n' );end ;
            fprintf( fileid, [ '!      GYROSCAN spectro parameter file \n' ] );
            if ds, fprintf( fileid, '\n' );end ;
            fprintf( fileid, '!      Last revised by Spectro Group.\n' );
            if ds, fprintf( fileid, '\n' );end ;
            fprintf( fileid, [ '!-------------------------------------------------' ...
                , '-------------------\n' ] );
            if ds, fprintf( fileid, '\n' );end ;
            fprintf( fileid, '!   This file was created using MRecon_spectro from RAW data.\n' );
            if ds, fprintf( fileid, '\n' );end ;
            fprintf( fileid, '!   It contains data in k-space and time (FID) domain.\n' );
            if ds, fprintf( fileid, '\n' );end ;
            fprintf( fileid, [ '!   S15/ACS: set of *.SPAR and *.SDAT files is' ...
                , ' created, (dataformat: VAX CPX floats)\n' ] );
            if ds, fprintf( fileid, '\n' );end ;
            fprintf( fileid, [ '!-------------------------------------------------' ...
                , '-------------------\n' ] );
            if ds, fprintf( fileid, '\n' );end ;
        end
        function count = fwriteVAX( fid, A, precision, method )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            switch method
                
                case { 'vaxd', 'VAXD' }
                    count = MRecon.fwriteVAXD( fid, A, precision );
                    
                case { 'vaxg', 'VAXG' }
                    count = MRecon.fwriteVAXG( fid, A, precision );
                    
                otherwise
                    error( [ method, ' is an unsupported method' ] )
                    
            end
            
        end
        function count = fwriteVAXD( fid, A, precision )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if nargin < 2
                error( 'Not enough input arguments.' )
            end
            
            
            [ filename, permission, machineformat ] = fopen( fid );
            if ~strcmp( machineformat, 'ieee-le' )
                error( 'Use FOPEN with ieee-le precision' );
            end
            
            switch precision
                
                case { 'float32', 'single' }
                    rawUINT32 = MRecon.VAXF_to_uint32le( A );
                    count = fwrite( fid, rawUINT32, 'uint32' );
                    
                case { 'float64', 'double' }
                    rawUINT32 = MRecon.VAXD_to_uint64le( A );
                    count = fwrite( fid, rawUINT32, 'uint32' );
                    count = count / 2;
                    
                case { 'float' }
                    if intmax == 2147483647
                        rawUINT32 = MRecon.VAXF_to_uint32le( A );
                        count = fwrite( fid, rawUINT32, 'uint32' );
                    else
                        rawUINT32 = MRecon.VAXD_to_uint64le( A );
                        count = fwrite( fid, rawUINT32, 'uint32' );
                        count = count / 2;
                    end
                    
                otherwise
                    
                    count = fwrite( fid, A, precision, 'vaxd' );
                    
            end
            
        end
        function count = fwriteVAXG( fid, A, precision )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if nargin < 2
                error( 'Not enough input arguments.' )
            end
            
            
            [ filename, permission, machineformat ] = fopen( fid );
            if ~strcmp( machineformat, 'ieee-le' )
                error( 'Use FOPEN with ieee-le precision' );
            end
            
            switch precision
                
                case { 'float32', 'single' }
                    rawUINT32 = MRecon.VAXF_to_uint32le( A );
                    count = fwrite( fid, rawUINT32, 'uint32' );
                    
                case { 'float64', 'double' }
                    rawUINT32 = MRecon.VAXG_to_uint64le( A );
                    count = fwrite( fid, rawUINT32, 'uint32' );
                    count = count / 2;
                    
                case { 'float' }
                    if intmax == 2147483647
                        rawUINT32 = MRecon.VAXF_to_uint32le( A );
                        count = fwrite( fid, rawUINT32, 'uint32' );
                    else
                        rawUINT32 = MRecon.VAXG_to_uint64le( A );
                        count = fwrite( fid, rawUINT32, 'uint32' );
                        count = count / 2;
                    end
                    
                otherwise
                    
                    count = fwrite( fid, A, precision, 'vaxg' );
                    
            end
        end
        function [ uint32le ] = VAXD_to_uint64le( doubleVAXD )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            A = 2;
            B = 128;
            C = 0.5;
            D = log( 2 );
            
            
            S = zeros( size( doubleVAXD ) );
            if any( doubleVAXD( : ) < 0 )
                indices = find( doubleVAXD < 0 );
                doubleVAXD( indices ) = (  - 1 ) .* doubleVAXD( indices );
                S = zeros( size( doubleVAXD ) );
                S( indices ) = 1;
            end
            
            
            E = floor( ( log( doubleVAXD ) ./ D ) + 1 + B );
            F = ( ( doubleVAXD ./ A .^ ( double( E ) - B ) ) ) - C;
            
            F = F * 72057594037927936;
            
            
            
            
            
            
            S = bitshift( bitshift( uint64( S ), 0 ), 63 );
            E = bitshift( bitshift( uint64( E ), 0 ), 56 );
            F = bitshift( bitshift( uint64( F ), 0 ), 9 );
            
            
            vaxInt = bitor( bitor( S, bitshift( E,  - 1 ) ), bitshift( F,  - 9 ) );
            
            
            
            
            
            
            
            
            
            
            
            vaxIntA = uint32( bitshift( bitshift( vaxInt, 0 ),  - 32 ) );
            vaxIntB = uint32( bitshift( bitshift( vaxInt, 32 ),  - 32 ) );
            
            
            
            word2 = bitshift( bitshift( vaxIntA, 16 ),  - 16 );
            word1 = bitshift( vaxIntA,  - 16 );
            uint32leA = bitor( bitshift( word2, 16 ), word1 );
            
            
            
            word4 = bitshift( bitshift( vaxIntB, 16 ),  - 16 );
            word3 = bitshift( vaxIntB,  - 16 );
            uint32leB = bitor( bitshift( word4, 16 ), word3 );
            
            uint32le( :, 1 ) = reshape( uint32leA, numel( uint32leA ), [  ] );
            uint32le( :, 2 ) = reshape( uint32leB, numel( uint32leB ), [  ] );
            
            uint32le = uint32le;
            
            
            
            
            
        end
        function [ uint32le ] = VAXF_to_uint32le( floatVAXF )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            A = 2;
            B = 128;
            C = 0.5;
            D = log( 2 );
            
            
            S = zeros( size( floatVAXF ) );
            if any( floatVAXF( : ) < 0 )
                indices = find( floatVAXF < 0 );
                floatVAXF( indices ) = (  - 1 ) .* floatVAXF( indices );
                S = zeros( size( floatVAXF ) );
                S( indices ) = 1;
            end
            
            
            E = floor( ( log( floatVAXF ) ./ D ) + 1 + B );
            F = ( ( floatVAXF ./ A .^ ( double( E ) - B ) ) ) - C;
            
            F = floor( F * 16777216 );
            
            
            S = bitshift( bitshift( uint32( S ), 0 ), 31 );
            E = bitshift( bitshift( uint32( E ), 0 ), 24 );
            F = bitshift( bitshift( uint32( F ), 0 ), 9 );
            
            
            vaxInt = bitor( bitor( S, bitshift( E,  - 1 ) ), bitshift( F,  - 9 ) );
            
            
            
            
            
            word1 = bitshift( vaxInt, 16 );
            word2 = bitshift( vaxInt,  - 16 );
            
            uint32le = bitor( word1, word2 );
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
        end
        function [ uint32le ] = VAXG_to_uint64le( doubleVAXG )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            A = 2;
            B = 1024;
            C = 0.5;
            D = log( 2 );
            
            
            S = zeros( size( doubleVAXG ) );
            if any( doubleVAXG( : ) < 0 )
                indices = find( doubleVAXG < 0 );
                doubleVAXG( indices ) = (  - 1 ) .* doubleVAXG( indices );
                S = zeros( size( doubleVAXG ) );
                S( indices ) = 1;
            end
            
            
            E = floor( ( log( doubleVAXG ) ./ D ) + 1 + B );
            F = ( ( doubleVAXG ./ A .^ ( double( E ) - B ) ) ) - C;
            
            F = F * 9007199254740992;
            
            
            
            
            
            
            S = bitshift( bitshift( uint64( S ), 0 ), 63 );
            E = bitshift( bitshift( uint64( E ), 0 ), 53 );
            F = bitshift( bitshift( uint64( F ), 0 ), 12 );
            
            
            vaxInt = bitor( bitor( S, bitshift( E,  - 1 ) ), bitshift( F,  - 12 ) );
            
            
            
            
            
            
            
            
            
            
            
            vaxIntA = uint32( bitshift( bitshift( vaxInt, 0 ),  - 32 ) );
            vaxIntB = uint32( bitshift( bitshift( vaxInt, 32 ),  - 32 ) );
            
            
            
            word2 = bitshift( bitshift( vaxIntA, 16 ),  - 16 );
            word1 = bitshift( vaxIntA,  - 16 );
            uint32leA = bitor( bitshift( word2, 16 ), word1 );
            
            
            
            word4 = bitshift( bitshift( vaxIntB, 16 ),  - 16 );
            word3 = bitshift( vaxIntB,  - 16 );
            uint32leB = bitor( bitshift( word4, 16 ), word3 );
            
            uint32le( :, 1 ) = reshape( uint32leA, numel( uint32leA ), [  ] );
            uint32le( :, 2 ) = reshape( uint32leB, numel( uint32leB ), [  ] );
            
            uint32le = uint32le;
            
            
            
            
        end
        
        
        
        
        function data = Convert2Cell( data )
            if ~iscell( data )
                data = { data };
            end
        end
        function data = UnconvertCell( data )
            if ~isempty( data ) && iscell( data )
                filled_cells = find( ~cellfun( @isempty, data ) );
                if iscell( data ) && length( filled_cells ) == 1
                    data = data{ filled_cells, 1 };
                end
                if isempty( filled_cells )
                    data = data{ 1 };
                end
            end
        end
        function [ work_encoding, lookup_table ] = check_cell_sizes( work_encoding, lookup_table, data )
            
            if size( lookup_table, 2 ) ~= size( data, 2 )
                lookup_table = repmat( lookup_table, [ 1, 2 ] );
            end
            
            if size( work_encoding.KxRange, 2 ) ~= size( data, 2 )
                work_encoding.KxRange = repmat( work_encoding.KxRange, [ 1, 2 ] );
            end
            
            if size( work_encoding.KyRange, 2 ) ~= size( data, 2 )
                work_encoding.KyRange = repmat( work_encoding.KyRange, [ 1, 2 ] );
            end
            
            if size( work_encoding.KzRange, 2 ) ~= size( data, 2 )
                work_encoding.KzRange = repmat( work_encoding.KzRange, [ 1, 2 ] );
            end
            
            if size( work_encoding.KxOversampling, 2 ) ~= size( data, 2 )
                work_encoding.KxOversampling = repmat( work_encoding.KxOversampling, [ 1, 2 ] );
            end
            
            if size( work_encoding.KyOversampling, 2 ) ~= size( data, 2 )
                work_encoding.KyOversampling = repmat( work_encoding.KyOversampling, [ 1, 2 ] );
            end
            
            if size( work_encoding.KzOversampling, 2 ) ~= size( data, 2 )
                work_encoding.KzOversampling = repmat( work_encoding.KzOversampling, [ 1, 2 ] );
            end
            
            if size( work_encoding.XRange, 2 ) ~= size( data, 2 )
                work_encoding.XRange = repmat( work_encoding.XRange, [ 1, 2 ] );
            end
            
            if size( work_encoding.YRange, 2 ) ~= size( data, 2 )
                work_encoding.YRange = repmat( work_encoding.YRange, [ 1, 2 ] );
            end
            
            if size( work_encoding.ZRange, 2 ) ~= size( data, 2 )
                work_encoding.ZRange = repmat( work_encoding.ZRange, [ 1, 2 ] );
            end
            
            if size( work_encoding.XRes, 2 ) ~= size( data, 2 )
                work_encoding.XRes = repmat( work_encoding.XRes, [ 1, 2 ] );
            end
            
            if size( work_encoding.YRes, 2 ) ~= size( data, 2 )
                work_encoding.YRes = repmat( work_encoding.YRes, [ 1, 2 ] );
            end
            
            if size( work_encoding.ZRes, 2 ) ~= size( data, 2 )
                work_encoding.ZRes = repmat( work_encoding.ZRes, [ 1, 2 ] );
            end
            
            if size( work_encoding.XReconRes, 2 ) ~= size( data, 2 )
                work_encoding.XReconRes = repmat( work_encoding.XReconRes, [ 1, 2 ] );
            end
            
            if size( work_encoding.YReconRes, 2 ) ~= size( data, 2 )
                work_encoding.YReconRes = repmat( work_encoding.YReconRes, [ 1, 2 ] );
            end
            
            if size( work_encoding.ZReconRes, 2 ) ~= size( data, 2 )
                work_encoding.ZReconRes = repmat( work_encoding.ZReconRes, [ 1, 2 ] );
            end
            
            if size( work_encoding.KxOversamplingOrig, 2 ) ~= size( data, 2 )
                work_encoding.KxOversamplingOrig = repmat( work_encoding.KxOversamplingOrig, [ 1, 2 ] );
            end
            
            if size( work_encoding.KyOversamplingOrig, 2 ) ~= size( data, 2 )
                work_encoding.KyOversamplingOrig = repmat( work_encoding.KyOversamplingOrig, [ 1, 2 ] );
            end
            
            if size( work_encoding.KzOversamplingOrig, 2 ) ~= size( data, 2 )
                work_encoding.KzOversamplingOrig = repmat( work_encoding.KzOversamplingOrig, [ 1, 2 ] );
            end
            
            if size( work_encoding.DataSizeByte, 2 ) ~= size( data, 2 )
                work_encoding.DataSizeByte = repmat( work_encoding.DataSizeByte, [ 1, 2 ] );
            end
            
        end
        function sub = ind2sub( siz, ndx )
            siz = double( siz );
            n = length( siz );
            k = [ 1, cumprod( siz( 1:end  - 1 ) ) ];
            sub = zeros( length( ndx ), n );
            for i = n: - 1:1,
                vi = rem( ndx - 1, k( i ) ) + 1;
                vj = ( ndx - vi ) / k( i ) + 1;
                sub( :, i ) = vj;
                ndx = vi;
            end
        end
        function path = DisplayVersion
            base_path = which( 'MRecon.m' );
            if isempty( base_path )
                base_path = which( 'MRecon.p' );
                base_path = strrep( base_path, 'MRecon.p', '' );
            else
                base_path = strrep( base_path, 'MRecon.m', '' );
            end
            path = [ base_path, 'license', base_path( end  ) ];
            
            fid = fopen( [ path, 'Version.txt' ] );
            while ~feof( fid )
                s = fgetl( fid );
                disp( s );
            end
        end
        function add_path(  )
            base_path = which( 'MRecon.m' );
            if ~isempty( base_path )
                base_path = strrep( base_path, 'MRecon.m', '' );
            else
                base_path = which( 'MRecon.p' );
                if ~isempty( base_path )
                    base_path = strrep( base_path, 'MRecon.p', '' );
                end
            end
            if ~isempty( base_path )
                if exist( [ base_path, '/license' ], 'dir' )
                    addpath( MRecon.genpath( [ base_path, '/license' ] ) );
                end
                if exist( [ base_path, '/mex/64bit' ], 'dir' )
                    addpath( MRecon.genpath( [ base_path, '/mex/64bit' ] ) );
                end
                if exist( [ base_path, '/mex/32bit' ], 'dir' )
                    addpath( MRecon.genpath( [ base_path, '/mex/32bit' ] ) );
                end
                if exist( [ base_path, '/par' ], 'dir' )
                    addpath( MRecon.genpath( [ base_path, '/par' ] ) );
                end
                if exist( [ base_path, '/userdata' ], 'dir' )
                    addpath( MRecon.genpath( [ base_path, '/userdata' ] ), '-END' );
                end
                if exist( [ base_path, '/ScannerRecon' ], 'dir' )
                    addpath( MRecon.genpath( [ base_path, '/ScannerRecon' ] ) );
                end
                if exist( [ base_path, '/tools' ], 'dir' )
                    addpath( MRecon.genpath( [ base_path, '/tools' ] ) );
                end
                if exist( [ base_path, '/doc' ], 'dir' )
                    addpath( MRecon.genpath( [ base_path, '/doc' ] ) );
                end
            end
        end
        function p = genpath( d )
            
            classsep = '@';
            packagesep = '+';
            p = '';
            
            
            files = dir( d );
            if isempty( files )
                return
            end
            
            
            p = [ p, d, pathsep ];
            
            
            isdir = logical( cat( 1, files.isdir ) );
            
            
            
            
            dirs = files( isdir );
            
            for i = 1:length( dirs )
                dirname = dirs( i ).name;
                if ~strcmp( dirname, '.' ) &&  ...
                        ~strcmp( dirname, '..' ) &&  ...
                        ~strncmp( dirname, classsep, 1 ) &&  ...
                        ~strncmp( dirname, packagesep, 1 ) &&  ...
                        ~strcmp( dirname, 'private' ) &&  ...
                        ~strcmp( dirname, '.svn' )
                    p = [ p, genpath( fullfile( d, dirname ) ) ];
                end
            end
        end
        function filename = DisplayFileList( directory, title )
            if isempty( title )
                title = 'Pick a file';
            end
            [ filename, pathname, filterindex ] = uigetfile(  ...
                { 'sri*.*;*.raw;*.cpx;*.rec;*.data;fid', 'All MR Data (sri*.*, *.raw, *.cpx, *.rec, *.data, fid)';
                'sri*.*;*.raw;*.cpx;*.rec;*.data', 'All Philips MR Data (sri*.*, *.raw, *.cpx, *.rec, *.data)'; ...
                'sri*.*; *.raw; *.data', 'Raw data (sri*, *.raw, *.data)'; ...
                '*.cpx', 'Complex data (*.cpx)'; ...
                '*.rec', 'Reconstructed data (*.rec)'; ...
                'fid', 'Bruker data (fid)'; ...
                '*.*', 'All Files' },  ...
                title, directory );
            
            if filename == 0
                filename = '';
            else
                filename = [ pathname, filename ];
            end
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
        end
        function new_range = set_k_ranges( krange, ovs )
            
            if ~isempty( krange ) && ~isempty( ovs )
                
                
                nr_pixels = krange( 2 ) - krange( 1 ) + 1;
                new_nr_pixels = round( nr_pixels / ovs );
                max_range = max( abs( krange ) );
                ind_max = find( ismember( abs( krange ), max_range ) );
                ind_max = ind_max( end  );
                if ind_max == 1
                    lower_range = round( krange( 1 ) / ovs );
                    upper_range = lower_range + new_nr_pixels - 1;
                else
                    upper_range = round( krange( 2 ) / ovs );
                    lower_range = upper_range - new_nr_pixels + 1;
                end
                new_range = [ lower_range, upper_range ];
                
            else
                new_range = [  ];
            end
        end
        function a = struct2array( s )
            
            
            
            
            
            
            error( nargchk( 1, 1, nargin, 'struct' ) );
            
            
            c = struct2cell( s );
            
            
            a = [ c{ : } ];
        end
        function [ mask, cutoff ] = mask_image( I, mode )
            
            
            
            
            
            I = abs( I );
            if nargin == 1
                mode = 'normal';
            end
            
            for i = 5:100
                [ n, x ] = hist( mat2gray( I( : ) ), i );
                
                d( i - 4 ) = ( n( 2 ) + 1 ) / n( 1 ) / sum( n( 3:end  ) );
            end
            [ mi, in ] = min( d );
            [ n, x ] = hist( mat2gray( I( : ) ), in + 4 );
            dx = x( 2 ) - x( 1 );
            switch mode
                case 'low'
                    cutoff = x( 2 ) - dx / 2;
                case 'normal'
                    cutoff = x( 2 );
                case 'high'
                    cutoff = x( 2 ) + dx / 2;
            end
            
            
            
            
            
            
            
            mask = im2bw( mat2gray( I ), cutoff );
        end
        function data = scale_data( data, limits )
            if nargin > 2
                error( 'Error in scale_data: Too many input arguments' );
            end
            if nargin < 1
                error( 'Error in scale_data: Too few input arguments' );
            end
            data = data - min( data( : ) );
            data = data ./ max( data( : ) );
            
            if nargin ~= 1
                data = data .* ( limits( 2 ) - limits( 1 ) ) + limits( 1 );
            end
            
        end
        function A = imresizend( A, M, method, N )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if M( end  ) == 1 & length( M ) ~= ndims( A )
                for i = length( M ): - 1:1
                    if M( i ) ~= 1
                        i = i + 1;
                        break
                    end
                end
                M( i:end  ) = [  ];
            end
            
            if length( M ) ~= ndims( A )
                error( 'Length of resize vector has to be the same length than the number of dimensions' );
            end
            add_singleton = 0;
            if length( M ) / 2 ~= floor( length( M ) / 2 )
                M( end  + 1 ) = M( end  );
                M( end  - 1 ) = 1;
                s = size( A );
                s( end  + 1 ) = s( end  );
                s( end  - 1 ) = 1;
                A = reshape( A, s );
                add_singleton = 1;
            end
            for i = 1:2:length( M )
                permuted = 0;
                s = size( A );
                if ( M( i ) ~= s( i ) ) | ( M( i + 1 ) ~= s( i + 1 ) )
                    s_temp = s;
                    s_temp( i:i + 1 ) = M( i:i + 1 );
                    if i > 2
                        s_temp = circshift( s_temp, [ 1, i - 1 ] );
                        A = shiftdim( A, i - 1 );
                        permuted = 1;
                    end
                    if nargin == 2
                        A = imresize_old( A, s_temp( 1:2 ) );
                    elseif nargin == 3
                        A = imresize_old( A, s_temp( 1:2 ), method );
                    else
                        A = imresize_old( A, s_temp( 1:2 ), method, N );
                    end
                    if permuted
                        A = shiftdim( A, length( M ) - i + 1 );
                    end
                end
            end
            if add_singleton
                A = squeeze( A );
            end
        end
        function p = polyfit_weighted( varargin )
            
            if length( varargin ) < 3
                error( 'Not enough input arguments' );
            elseif length( varargin ) == 3
                y = varargin{ 1 };
                weights = varargin{ 2 };
                n = varargin{ 3 };
                x = ( 1:length( y ) );
            elseif length( varargin ) == 4
                x = varargin{ 1 };
                y = varargin{ 2 };
                weights = varargin{ 3 };
                n = varargin{ 4 };
            end
            
            if size( x, 1 ) == 1
                x = x;
            end
            if size( y, 1 ) == 1
                y = y;
            end
            if size( weights, 1 ) == 1
                weights = weights;
            end
            if size( x, 2 ) > 1
                error( 'x must be a 1 dimensional vector' );
            end
            if size( y, 2 ) > 1
                error( 'y must be a 1 dimensional vector' );
            end
            if size( weights, 2 ) > 1
                error( 'the weights must be a 1 dimensional vector' );
            end
            
            A = [  ];
            for i = 1:n
                A = [ x .^ i, A ];
            end
            A = [ A, ones( length( x ), 1 ) ];
            
            p = ( A * bsxfun( @times, weights .^ 2, A ) )\bsxfun( @times, A, weights .^ 2 ) * y;
        end
        function p = polyfitweighted2( x, y, z, n, w )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            x = x( : );
            y = y( : );
            
            lx = length( x );
            ly = length( y );
            
            if ~isequal( size( z ), size( w ), [ ly, lx ] )
                error( 'polyfitweighted2:XYSizeMismatch',  ...
                    [ ' X,Y *must* be vectors' ...
                    , '  Z,W *must* be 2D arrays of size [length(X) length(Y)]' ] )
            end
            
            y = y * ones( 1, lx );
            x = ones( ly, 1 ) * x;
            x = x( : );
            y = y( : );
            z = z( : );
            w = w( : );
            
            pts = length( z );
            
            
            V = zeros( pts, ( n + 1 ) * ( n + 2 ) / 2 );
            V( :, 1 ) = w;
            
            ordercolumn = 1;
            for order = 1:n
                for ordercolumn = ordercolumn + ( 1:order )
                    V( :, ordercolumn ) = x .* V( :, ordercolumn - order );
                end
                ordercolumn = ordercolumn + 1;
                V( :, ordercolumn ) = y .* V( :, ordercolumn - order - 1 );
            end
            
            
            [ Q, R ] = qr( V, 0 );
            ws = warning( 'off', 'all' );
            p = R\( Q * ( w .* z ) );
            warning( ws );
            if size( R, 2 ) > size( R, 1 )
                warning( 'polyfitweighted2:PolyNotUnique',  ...
                    'Polynomial is not unique; degree >= number of data points.' )
            elseif condest( R ) > 1.0e10
                warning( 'polyfitweighted2:RepeatedPointsOrRale',  ...
                    [ 'Polynomial is badly conditioned. Remove repeated data points\n' ...
                    , '         or try centering and scaling as dribed in HELP POLYFIT.' ] )
            end
            
            p = p.ESC;
        end
        function z = polyval2( p, x, y )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            x = x( : );
            y = y( : );
            lx = length( x );
            ly = length( y );
            lp = length( p );
            pts = lx * ly;
            
            y = y * ones( 1, lx );
            x = ones( ly, 1 ) * x;
            x = x( : );
            y = y( : );
            
            n = ( sqrt( 1 + 8 * length( p ) ) - 3 ) / 2;
            
            if ~( isvector( p ) || mod( n, 1 ) == 0 || lx == ly )
                error( 'MATLAB:polyval2:InvalidP',  ...
                    'P must be a vector of length (N+1)*(N+2)/2, where N is order. X and Y must be same size.' );
            end
            
            
            V = zeros( pts, lp );
            V( :, 1 ) = ones( pts, 1 );
            ordercolumn = 1;
            for order = 1:n
                for ordercolumn = ordercolumn + ( 1:order )
                    V( :, ordercolumn ) = x .* V( :, ordercolumn - order );
                end
                ordercolumn = ordercolumn + 1;
                V( :, ordercolumn ) = y .* V( :, ordercolumn - order - 1 );
            end
            
            z = V * p;
            z = reshape( z, ly, lx );
        end
        function data = smooth( data, rel_kernel_size )
            is2d = 0;
            if nargin == 1 || isempty( rel_kernel_size )
                rel_kernel_size = 16;
            end
            
            nr_images = size( data( :, :, : ), 3 );
            res1 = size( data, 1 );
            res2 = size( data, 2 );
            
            if res1 ~= 1 && res2 ~= 1
                is2d = 1;
            end
            
            kernel = zeros( res1, res2 );
            for i = 1:nr_images
                if ~is2d
                    kernel_size = round( max( res1, res2 ) / rel_kernel_size );
                    center = floor( length( kernel ) / 2 ) + 1;
                    if ~mod( kernel_size, 2 )
                        kernel_size = kernel_size + 1;
                    end
                    kernel( center - floor( kernel_size / 2 ):center + floor( kernel_size / 2 ) ) = 1 / kernel_size;
                    data( :, :, i ) = conv( data( :, :, i ), kernel, 'same' );
                else
                    kernel_size1 = round( res1 / rel_kernel_size );
                    kernel_size2 = round( res2 / rel_kernel_size );
                    center = [ floor( size( kernel, 1 ) / 2 ) + 1, floor( size( kernel, 2 ) / 2 ) + 1 ];
                    if ~mod( kernel_size1, 2 )
                        kernel_size1 = kernel_size1 + 1;
                    end
                    if ~mod( kernel_size2, 2 )
                        kernel_size2 = kernel_size2 + 1;
                    end
                    kernel( center( 1 ) - floor( kernel_size1 / 2 ):center( 1 ) + floor( kernel_size1 / 2 ), center( 2 ) - floor( kernel_size2 / 2 ):center( 2 ) + floor( kernel_size2 / 2 ) ) = 1 / ( kernel_size1 * kernel_size1 );
                    data( :, :, i ) = conv2( data( :, :, i ), kernel, 'same' );
                end
            end
        end
        function phase = unwrap1d( phase, ref, modulus )
            if nargin == 1 || isempty( ref )
                ref = 1;
            end
            
            phase( ref:end  ) = unwrap( phase( ref:end  ) );
            phase( ref: - 1:1 ) = unwrap( phase( ref: - 1:1 ) );
        end
        function y = SA( x )
            y = sqrt( sum( abs( x( : ) ) .^ 2 ) / length( x( : ) ) );
        end
        function data = resize( data, siz, dim, canvas_only )
            if nargin < 4 || isempty( canvas_only )
                canvas_only = true;
            end
            if ( isempty( data ) )
                return ;
            end
            if ( size( data, dim ) == siz )
                return ;
            end
            if ( dim > ndims( data ) )
                error( 'Error in resize: The dimension to resize is larger than the number of dimensions in the data' );
            end
            
            if ( size( data, dim ) < siz )
                if canvas_only
                    nr_zeros = siz - size( data, dim );
                    if nr_zeros > 0
                        s = size( data );
                        s( dim ) = nr_zeros;
                        shift = zeros( 1, length( s ) );
                        shift( dim ) = floor( nr_zeros / 2 );
                        z = zeros( s );
                        data = cat( dim, data, z );
                        data = circshift( data, shift );
                    end
                else
                    s = size( data );
                    s( dim ) = siz;
                    data = MRecon.imresizend( data, s );
                end
            else
                if canvas_only
                    res = size( data, dim );
                    nrsamples2remove = res - siz;
                    samples2keep = [ floor( nrsamples2remove / 2 ) + 1, res - ceil( nrsamples2remove / 2 ) ];
                    
                    selection = repmat( ':', [ 1, 12 ] );
                    selection( dim ) = '1';
                    selection = [ selection;repmat( ',', [ 1, 12 ] ) ];
                    selection = selection( : );
                    selection = selection( 1:end  - 1 );
                    selection = strrep( selection, '1', [ num2str( samples2keep( 1 ) ), ':', num2str( samples2keep( 2 ) ) ] );
                    
                    str_data = [ 'data = data(', selection, ');' ];
                    eval( str_data );
                else
                    s = size( data );
                    s( dim ) = siz;
                    data = MRecon.imresizend( data, s );
                end
            end
        end
        function search( this, search_text, prefix )
            
            if ~isempty( prefix )
                prefix = [ prefix, '.' ];
            end
            if isstruct( this )
                p = fieldnames( this );
            else
                mc = eval( [ '?', class( this ) ] );
                
                p = mc.Properties;
            end
            for i = 1:length( p )
                if isstruct( this )
                    name = p{ i };
                else
                    name = p{ i }.Name;
                    if ( p{ i }.Hidden )
                        continue ;
                    end
                end
                try
                    mc_this = eval( [ '?', class( this.( name ) ) ] );
                catch
                    return ;
                end
                
                try
                    if isempty( this.( name ) )
                        value = '[]';
                    else
                        if ( length( this.( name ) ) < 1000 )
                            value = num2str( this.( name ) );
                        else
                            value = NaN;
                        end
                    end
                catch
                    value = NaN;
                end
                
                if ~isempty( strfind( lower( name ), lower( search_text ) ) )
                    output_str = [ prefix, name ];
                    try
                        if ~isnan( value )
                            output_str = [ output_str, ' = ', value ];
                        end
                    end
                    disp( output_str );
                end
                
                if isstruct( this.( name ) )
                    prefix = [ prefix, name ];
                    MRecon.search( this.( name ), search_text, prefix );
                    prefix = strrep( prefix, name, '' );
                elseif ~isempty( mc_this.Properties )
                    prefix = [ prefix, name ];
                    MRecon.search( this.( name ), search_text, prefix );
                    prefix = strrep( prefix, name, '' );
                end
            end
        end
        function compare( this, other, prefix )
            
            if ~isempty( prefix )
                prefix = [ prefix, '.' ];
            end
            if isstruct( this )
                p = fieldnames( this );
            else
                mc = eval( [ '?', class( this ) ] );
                
                p = mc.Properties;
            end
            for i = 1:length( p )
                if isstruct( this )
                    name = p{ i };
                else
                    name = p{ i }.Name;
                    if ( p{ i }.Hidden )
                        continue ;
                    end
                end
                try
                    mc_this = eval( [ '?', class( this.( name ) ) ] );
                catch
                    return ;
                end
                
                try
                    if isempty( this.( name ) )
                        value_this = '[]';
                    else
                        value_this = num2str( this.( name ) );
                    end
                catch
                    value_this = NaN;
                end
                try
                    if isempty( other.( name ) )
                        value_other = '[]';
                    else
                        value_other = num2str( other.( name ) );
                    end
                catch
                    value_other = NaN;
                end
                
                
                try
                    if ~all( isnan( value_this( : ) ) ) && ~all( isnan( value_other( : ) ) )
                        if any( size( this.( name ) ) ~= size( other.( name ) ) ) || any( this.( name ) ~= other.( name ) )
                            output_str = [ prefix, name ];
                            try
                                output_str = [ output_str, ': this = ', value_this, ';    other = ', value_other ];
                            end
                            disp( output_str );
                        end
                    end
                end
                
                if isstruct( this.( name ) )
                    prefix = [ prefix, name ];
                    MRecon.compare( this.( name ), other.( name ), prefix );
                    prefix = strrep( prefix, name, '' );
                elseif ~isempty( mc_this.Properties )
                    prefix = [ prefix, name ];
                    MRecon.compare( this.( name ), other.( name ), prefix );
                    prefix = strrep( prefix, name, '' );
                end
            end
        end
        function [ uV, sV ] = memory_mac
            
            
            
            
            
            
            
            
            
            
            
            if ismac
                
                [ ~, getmem ] = system( 'top -l 1 | head -n 10 | grep PhysMem' );
                
                
                result1 = regexp( getmem, '(?<memory_used>[0-9MGKT]+) used .* (?<memory_unused>[0-9MGKT]+)', 'names' );
                result2 = cellfun( @( x )str2double( strrep( strrep( strrep( strrep( result1.( x ), 'K', repmat( '0', 1, 3 ) ), 'M', repmat( '0', 1, 6 ) ), 'G', repmat( '0', 1, 9 ) ), 'T', repmat( '0', 1, 12 ) ) ), fieldnames( result1 ), 'uniformoutput', true );
                
                
                uV = [  ];
                sV = struct( 'VirtualAddressSpace', [  ],  ...
                    'SystemMemory', [  ],  ...
                    'PhysicalMemory',  ...
                    struct( 'Available', result2( 2 ),  ...
                    'Used', result2( 1 ) ) );
                
            else
                [ uV, sV ] = memory;
            end
        end
        
        
        
        function [ y, a ] = lpredict( x, np, npred, pos )
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if nargin < 3
                error( 'Not enough input arguments' );
            end
            
            if np < 2
                error( 'np must be >=2' );
            end
            
            if nargin < 4
                pos = 'post';
            end
            
            
            
            
            
            cols = size( x, 2 );
            if cols > 1
                y = zeros( npred, cols );
                a = zeros( cols, np + 1 );
                for k = 1:size( x, 2 )
                    [ y( :, k ), a( k, : ) ] = MRecon.lpredict( x( :, k ), np, npred, pos );
                end
                return
            end
            
            
            
            
            
            if nargin == 4 && strcmpi( pos, 'pre' )
                x = x( end : - 1:1 );
            end
            
            
            
            try
                a = lpc( x, np );
            catch
                
                m = lasterror(  );
                if strcmp( m.identifier, 'MATLAB:UndefinedFunction' )
                    error( 'Requires the LPC function from the Signal Processing Toolbox' );
                else
                    rethrow( lasterror );
                end
            end
            
            
            cc =  - a( 2:end  );
            
            
            y = zeros( npred, 1 );
            
            y( 1 ) = cc * x( end : - 1:end  - np + 1 );
            
            for k = 2:min( np, npred )
                y( k ) = cc * [ y( k - 1: - 1:1 );x( end : - 1:end  - np + k ) ];
            end
            
            for k = np + 1:npred
                y( k ) = cc * y( k - 1: - 1:k - np );
            end
            
            
            if nargin == 4 && strcmpi( pos, 'pre' )
                y = y( end : - 1:1 );
            end
            
            return
        end
        
    end
end



