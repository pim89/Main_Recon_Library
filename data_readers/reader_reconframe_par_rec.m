function image_data = reader_reconframe_par_rec(loc)
%% RECONFRAME PAR/REC reader
% Read the PAR/REC images

% Read data
MR=MRecon(loc);
MR.Perform;
image_data=MR.Data;

end
