function [ t, pc, noiseVar ] = noiseNav(MR, filter)
%Calculate the noise navigator from MR data
%   input: MR from "MRecon"
%        : filter should be 1 to apply a moving average filter; 0 for no filter
%   output: time vector "t"
%         : combined coil signal "pc"
%         : individual coil signals "noiseVar"

%% Check input
if filter > 1
    error('filter has value %i \nfilter should be 0 (no filter) or 1 (moving average filter)', ...
        filter);
end

%% Grab corrected MRI data
% chron_data = MR.Data{1}; // TB
chron_data = MR.Data; 

%% Get required parameters
acq_vox_size = MR.Parameter.Scan.AcqVoxelSize; % acquired voxel sizes [mm]
TR = MR.Parameter.Scan.TR * 1e-3; % repetition time [s]
TE = MR.Parameter.Scan.TE * 1e-3; % echo time [s]
acq_samp = size(chron_data, 1); % number of acquired samples [-]
tse_factor = MR.Parameter.GetValue('RC_tse_factor'); % TSE factor [-]
nChan = numel(MR.Parameter.Parameter2Read.chan); % number of channels used for acquistion [-]
nKl = size(chron_data, 2) / nChan; % number of acquired k-space lines [-]
nKy=numel(MR.Parameter.Parameter2Read.ky);

%% Correct the repetition time for tse factor if necessary
if tse_factor > 0
    TR = TR / tse_factor; % [s]
end

%% Reshape data
chron_data = reshape(chron_data, [acq_samp, nChan, nKl]);

%% Calculate noise only part
% the data is zero centered and it is assumed there is no MR signal 36 cm away from isocenter
noise_samp = floor(0.5 * (2 * acq_samp - (720 / acq_vox_size(1) ) ) );  % 2 * for radial sampling?
indNoise = [1:noise_samp, (acq_samp - noise_samp + 1):acq_samp];

%% Calculate noise variance
noiseVar = zeros(nKl, nChan);
for c = 1:nChan
    % Convert to hybrid space
    tmp = fftshift(ifft(ifftshift(squeeze(chron_data(:, c, :) ), 1), [], 1), 1);
    % Calculate variance over noise only part
    noiseVar(:, c) = var(tmp(indNoise, :), 1);
end
clear chron_data

%% Normalize data
noiseVar = bsxfun(@rdivide, noiseVar, median(noiseVar) );
noiseVar = bsxfun(@minus, noiseVar, mean(noiseVar) );

%% Apply SVD
[~, ~, V] = svd(noiseVar, 0);

%% Select desired principal component
[ft, f] = fourierCoeff(noiseVar * V, 1 / TR);
pow_rel = sum(ft(f < 1, :).^2) ./ sum(ft.^2); % relative power within full frequency range
cw = V(:, pow_rel == max(pow_rel) ); % select singular vector based on relative power

pc = -noiseVar * cw;

%% Create time vector
t = TE + (0:(nKl - 1) ) .* TR;

%% Apply filter if necessary
if filter == 1
    tFilt = 1; % filter window width [s]
    [~, ma] = MovingAverage(pc, t, tFilt, 'same');
    pc = ma;
    [~, ma] = MovingAverage(noiseVar, t, tFilt, 'same');
    noiseVar = ma;
    clear ma
end

%% Reduce to per shot navigator
pc=interp1(1:numel(pc),pc,linspace(1,numel(pc),nKy));
t=interp1(1:numel(t),t,linspace(1,numel(t),nKy));

%% Save to hacked variable
MR.Parameter.Bruker=pc;

disp('+Noise navigator calculated.')
end

