function [tMA, ma] = MovingAverage(sig, t, tFilt, type)
% [tMA, ma] = MovingAverage(sig, t, tFilt, type)
% input
% sig: signal(s) to be filtered in columns
% t: time vector
% tFilt: filter window length
% type: 'same' length or 'valid' without zero padding at the edges

%% Get parameters
N = size(sig, 1); % number of measured points
M = size(sig, 2); % number of observations
dt = abs(t(2) - t(1) ); % time step [s]
% Demean the input signal
u = mean(sig);
sig = bsxfun(@minus, sig, u);
% Set filter parameters
span = round(tFilt / dt); % length of filter in points
win = hamming(span); % hamming filter kernel
% win = ones(span, 1); % rectangluar filter kernel
win = win ./ sum(win); % normalized filter kernel
% Apply filter per observation
if strcmp(type, 'valid')
    len = N - span + 1;
    ma = zeros(len, M);
    for m = 1 : M
        ma(:, m) = conv(sig(:, m), win, 'valid');
    end
    tMA = t(round(0.5 * span) : round(0.5 * span) + len - 1); % time vector [s]
elseif strcmp(type, 'same')
    ma = zeros(N, M);
    for m = 1 : M
        ma(:, m) = conv(sig(:, m), win, 'same');
    end
    tMA = t;
else
    error('type should be "valid" or "same"')
end
% Add the mean to the ouput signal
ma = bsxfun(@plus, ma, u);

end