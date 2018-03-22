function res = ksp_reconframe_to_bart(input)
%Transform 12D arrays from reconframe to bart
%
% V20180129 - Tom Bruijnen

res=permute(input,[3 1 2 4 12 7 6 8 9 10 5 11]);

%BART:
%     READ_DIM,        1
%     PHS1_DIM,        2
%     PHS2_DIM,        3
%     COIL_DIM,        4
%     MAPS_DIM,        5
%     TE_DIM,          6
%     COEFF_DIM,       7
%     COEFF2_DIM,      8
%     ITER_DIM,        9
%     CSHIFT_DIM,      10
%     TIME_DIM,        11
%     TIME2_DIM,       12
%     LEVEL_DIM,       13
%     SLICE_DIM,       14
%     AVG_DIM,         15

%RF:
%     READ_DIM,        1
%     PHS1_DIM,        2
%     PHS2_DIM,        3
%     COIL_DIM,        4
%     TIME1_DIM,       5
%     TIME2_DIM,       6
%     TE_DIM,          7
%     MIX_DIM,         8
%     LOC_DIM,         9
%     EX1_DIM,         10
%     EX2_DIM,         11
%     AVG_DIM,         12

% END
end