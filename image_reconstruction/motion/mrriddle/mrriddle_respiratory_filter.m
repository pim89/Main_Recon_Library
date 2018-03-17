function soft_weights = mrriddle_respiratory_filter(respiration,xy_resolution)
%%Auto adapt the soft-weights for motion-weighted image reconstruction
% The filter has the form of sw[c1,c2,c3]

% Calculate average motion surrogate & compute distances
midp=mean(respiration,1)';
for n=1:numel(respiration)
    d(n)=abs(midp-respiration(n));
end

% Parametrize exponential function
c1=prctile(d,10); % Threshold to do nothing
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