function [kspace_data,MR] = reader_reconframe_lab_raw(loc,varargin)
%% RECONFRAME LAB/RAW READER
% Read lab/raw data using reconframe and convert to list format.
% Such that the "corrected" and "sorted" k-space data is returned.
% Varargin defines the type of data, i.e. noise data, imaging data
% 1=imaging data | 2= .. | 3=.. | 4=... | 5=noise data

% Process data type
curdir=get_data_dir(loc);

% Coil compression input
if nargin < 3
    coil_comp=0;
else
    coil_comp=varargin{2};
end

% Data type input
if nargin < 2
    type=1;
else
    type=varargin{1};
end

% Read data
MR=MRecon(loc);
MR=reconframe_read_sort_correct(MR,type,coil_comp);
kspace_data=MR.Data;

end
