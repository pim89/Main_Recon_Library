function soft_weights = mrriddle_respiratory_filter(respiration,xy_resolution,varargin)
%%Auto adapt the soft-weights for motion-weighted image reconstruction
% The filter has the form of sw[c1,c2,c3]

% Check input
if size(respiration,1)==1
    respiration=respiration';
end

if nargin < 3
    pos='midpos';
else
    pos=varargin;
end

% Calculate reference surrogate
if strcmpi(pos,'inhale')    
    ref=max(respiration);
elseif strcmpi(pos,'exhale')  
    ref=min(respiration);
else
    ref=mean(respiration);
end

for n=1:numel(respiration)
    d(n)=abs(ref-respiration(n));
end

% Parametrize exponential function
c1=prctile(d,5); % Threshold to do nothing
c2=optimize_sgw(d,xy_resolution,c1); % Parametrize exponential function automatically

% Compute soft-weights
for n=1:numel(respiration)
    if d(n)<= c1
        soft_weights(n)=1;
    else
        soft_weights(n)=exp(-c2*(d(n)-c1));
    end
end

% END
end
