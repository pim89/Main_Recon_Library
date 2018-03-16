function ppe_pars = reader_reconframe_ppe_pars(MR)
%% PPE parameter reader
% Extract PPE parameters from the reconframe MR object
% Checks for each parameter if they exist in the PPE, if so assign to
% struct

if MR.Parameter.IsParameter('UGN1_ACQ_golden_angle');ppe_pars.goldenangle=MR.Parameter.GetValue('`UGN1_ACQ_golden_angle');end
if MR.Parameter.IsParameter('UGN1_ACQ_ga_calibration_spokes');ppe_pars.number_of_calibration_spokes=MR.Parameter.GetValue('`UGN1_ACQ_ga_calibration_spokes');end
if MR.Parameter.IsParameter('EX_TOM_goldenangle');ppe_pars.goldenangle=MR.Parameter.GetValue('`EX_TOM_goldenangle');end
if MR.Parameter.IsParameter('UGN1_TOM_calibrationspokes');ppe_pars.number_of_calibration_spokes=MR.Parameter.GetValue('`UGN1_TOM_calibrationspokes');end
if MR.Parameter.IsParameter('EX_TOM_mrf');ppe_pars.fingerprinting=MR.Parameter.GetValue('`EX_TOM_mrf');end

% END
end
