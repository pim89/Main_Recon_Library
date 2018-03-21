function ADC = extract_adc_info(MR,n)
% Extract set of attributes and store to struct

% ADC.ref=MR.Parameter.GetValue('AQ`base:[1]:ref')*10^(-3); % ref or ref_Act doesnt matter
% ADC.time=MR.Parameter.GetValue('AQ`base:[1]:time')*10^(-3);
% ADC.samples=MR.Parameter.GetValue('AQ`base:[1]:samples_act');
% ADC.dur=MR.Parameter.GetValue('AQ`base:[1]:dur_act')*10^(-3);
% ADC.dt=ADC.dur/ADC.samples;
% ADC.epi_dt=MR.Parameter.GetValue('GR`m[0]:dur')*10^(-3);
% ADC.nr_acq=MR.Parameter.GetValue('AQ`base:[1]:comp_elements');
% ADC.offset=ADC.time-ADC.ref;toc


% Check software version
version=MR.Parameter.GetValue('RFR_SERIES_DICOM_SOFTWARE_VERSIONS0');

% Faster alternative
if n==1
    tmp=MR.Parameter.GetObject('AQ`base');tmp=tmp.attributes{1};
else
    tmp=MR.Parameter.GetObject('AQ`ME');tmp=tmp.attributes{1};
end

if strcmpi(version,'5.3.1')
    ADC.epi_dt=MR.Parameter.GetValue('GR`m_0_:dur')*10^(-3);
    ADC.samples=tmp(74).values;
else
    ADC.samples=tmp(73).values;
    ADC.epi_dt=MR.Parameter.GetValue('GR`m[0]:dur')*10^(-3);
end
 
ADC.ref=tmp(4).values*10^(-3);
ADC.time=tmp(2).values*10^(-3);
ADC.dur=tmp(1).values*10^(-3);
ADC.dt=ADC.dur/ADC.samples;
ADC.nr_acq=tmp(21).values;
ADC.offset=ADC.time-ADC.ref;

% END
end