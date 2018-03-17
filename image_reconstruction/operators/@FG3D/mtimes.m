function res = mtimes(fg,data)
% Perform the 3D NUFFT

if fg.adjoint 
        
    % Check what dimensions require new trajectory coordinates
    idim=fg.idim;
    kdim=fg.kdim;

	for avg=1:size(data,12) % Averages
	for ex2=1:size(data,11) % Extra2
	for ex1=1:size(data,10) % Extra1
	for mix=1:size(data,9)  % Locations
	for loc=1:size(data,8)  % Mixes
	for ech=1:size(data,7)  % Phases
	for ph=1:size(data,6)   % Echos
	for dyn=1:size(data,5)  % Dynamics
        
        % Convert data to doubles, required for the function
        data_tmp=double(data(:,:,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg));
        
        % Preallocate temporary matrix
        res_tmp=zeros([idim(1:3) idim(4)]);
        
        % Parallize over the receivers (always has same traj)
        if ~fg.parfor
            for coil=1:size(data,4) % Coils
                % Do the nufft
                res_tmp(:,:,:,coil)=...
                    nufft_adj(matrix_to_vec(data_tmp(:,:,:,coil)),...
                    fg.st{dyn,ph,ech,loc,mix,ex1,ex2,avg})/sqrt(prod(fg.idim(1:3)));                                        
            end % Coils
        else
            parfor coil=1:size(data,4) % Coils
                % Do the nufft
                res_tmp(:,:,:,coil)=...
                    nufft_adj(matrix_to_vec(data_tmp(:,:,:,coil)),...
                    fg.st{dyn,ph,ech,loc,mix,ex1,ex2,avg})/sqrt(prod(fg.idim(1:3)));
            end % Coils
        end
    
        % Store output from all receivers   
        res(:,:,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg)=res_tmp;
        
	end % Dynamics
	end % Echos
	end % Phases
	end % Mixes
	end % Locations
	end % Extra1
	end % Extra2
	end % Averages
else
    % Check what dimensions require new trajectory coordinates
    idim=fg.idim;
    kdim=fg.kdim;
	for avg=1:size(data,12) % Averages
	for ex2=1:size(data,11) % Extra2
	for ex1=1:size(data,10) % Extra1
	for mix=1:size(data,9)  % Locations
	for loc=1:size(data,8)  % Mixes
	for ech=1:size(data,7)  % Phases
	for ph=1:size(data,6)   % Echos
	for dyn=1:size(data,5)  % Dynamics
        
         % Convert data to doubles, required for the function
        data_tmp=double(data(:,:,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg));
        
        % Preallocate temporary matrix
        res_tmp=zeros([prod(kdim(1:3)) idim(4)]);
        
        % Parallize over the receivers (always has same traj)
        if ~fg.parfor
            for coil=1:size(data,4) % Coils
                % Forward operator
                res_tmp(:,coil)=...
                    nufft(reshape(data_tmp(:,:,:,coil),fg.idim(1:3)),...
                    fg.st{dyn,ph,ech,loc,mix,ex1,ex2,avg})/sqrt(prod(fg.idim(1:3))); 
            end % Coils
        else
            parfor coil=1:size(data,4) % Coils
                % Forward operator
                res_tmp(:,coil)=...
                    nufft(reshape(data_tmp(:,:,:,coil),fg.idim(1:3)),...
                    fg.st{dyn,ph,ech,loc,mix,ex1,ex2,avg})/sqrt(prod(fg.idim(1:3))); 
            end % Coils
        end

	    % Store output from all receivers
	    res(:,:,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg)=reshape(res_tmp,fg.kdim(1:4));

	end % Dynamics
	end % Echos
	end % Phases
	end % Mixes
	end % Locations
	end % Extra1
	end % Extra2
	end % Averages
	end % Data chunks

end

