function SQ = extract_sequence_info(MR,sq)
%Extract set of gradient attributesattributes of SQ objects and store to struct.
% Everything is in seconds and T/m/s
%    
% Version: 20171110 
% Author: Tom Bruijnen
% Contact: t.bruijnen@umcutrecht.nl


if MR.Parameter.IsObject(['SQ`',sq])==1;
    SQ.ref=MR.Parameter.GetValue(['SQ`',sq,':ref'])*10^(-3);
    SQ.dur=MR.Parameter.GetValue(['SQ`',sq,':dur'])*10^(-3);  
    SQ.dur2=MR.Parameter.GetValue(['SQ`',sq,':dur2'])*10^(-3);

    % Identify how often I need to repeat the ME object
    if strcmpi(sq,'ME')
        SQ.nechos=MR.Parameter.Encoding.NrEchoes-1;
    end
else
    SQ.ref=0;
    SQ.dur=0;
    SQ.dur2=0;
    SQ.nechos=0;
end

% END
end
