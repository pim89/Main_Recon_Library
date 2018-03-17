function res = mtimes(gg,data) 
% Greengard 2D NUFFT operator working on 12D reconframe data
% Data and kspace come in as cells, which represent different data chunks
% Try indexing in parfor loop only on first entry, probably saves speed
%
% Tom Bruijnen - University Medical Center Utrecht - 201704 
    
% Set parameters
eps=gg.precision; 
    
% Check what dimensions require new trajectory coordinates
idim=gg.idim;
kdim=gg.kdim;

if gg.adjoint==-1 % NUFFT^(-1)
    % non-Cartesian k-space to Cartesian image domain || type 1

    % Reshape data that goes together into the nufft operator
    data=reshape(data,[kdim(1)*kdim(2) kdim(3:end)]);

    % Get number of k-space points per chunk
    nj=gg.nj;

    % Loop over all dimensions and update k if required
    % For now I assumed that different Z always has the same trajectory
    for avg=1:kdim(12) % Averages
    for ex2=1:kdim(11) % Extra2
    for ex1=1:kdim(10) % Extra1
    for mix=1:kdim(9)  % Locations
    for loc=1:kdim(8)  % Mixes
    for ech=1:kdim(7)  % Phases
    for ph=1:kdim(6)   % Echos
    for dyn=1:kdim(5)  % Dynamics
    for z=1:kdim(3)    % Slices (2D)

        % Convert data to doubles, required for the function
        data_tmp=double(data(:,z,:,dyn,ph,ech,loc,mix,ex1,ex2,avg));

        % Select k-space trajectory
        k_tmp=gg.k(1:2,:,1,1,dyn,ph,ech,loc,mix,ex1,ex2,avg);

        % Preallocate res_tmp
        res_tmp=zeros(prod(gg.idim(1:2)),gg.idim(4));

        % Parallize over the receivers (always has same traj)
        if ~gg.parfor
            for coil=1:kdim(4)
                % Save in temporarily matrix, saves indexing time
                res_tmp(:,coil)=matrix_to_vec(nufft2d1(nj,k_tmp(2,:),...
                    k_tmp(1,:),data_tmp(:,:,coil),-1,eps,idim(1),idim(2)))*sqrt(prod(gg.idim(1:2)));
            end
        else
            parfor coil=1:kdim(4)
                % Save in temporarily matrix, saves indexing time
                res_tmp(:,coil)=matrix_to_vec(nufft2d1(nj,k_tmp(2,:),...
                    k_tmp(1,:),data_tmp(:,:,coil),-1,eps,idim(1),idim(2)))*sqrt(prod(gg.idim(1:2)));
            end
        end

        % Store output from all receivers
        res(:,:,z,:,dyn,ph,ech,loc,mix,ex1,ex2,avg)=reshape(res_tmp,idim([1:2 4]));

    end % Slices
    end % Dynamics
    end % Echos
    end % Phases
    end % Mixes
    end % Locations
    end % Extra1
    end % Extra2
    end % Averages
else         % Cartesian image domain to non-Cartesian k-space || type 2
    % Get number of k-space points per chunk
    nj=gg.nj;

    % Loop over all dimensions and update k if required
    % For now I assumed that different Z always has the same trajectory
    for avg=1:kdim(12) % Averages
    for ex2=1:kdim(11) % Extra2 
    for ex1=1:kdim(10) % Extra1
    for mix=1:kdim(9)  % Locations
    for loc=1:kdim(8)  % Mixes
    for ech=1:kdim(7)  % Phases
    for ph=1:kdim(6)   % Echos
    for dyn=1:kdim(5)  % Dynamics
    for z=1:kdim(3)    % Slices (2D)

            % Convert data to doubles, required for the function
            data_tmp=double(data(:,:,z,:,dyn,ph,ech,loc,mix,ex1,ex2,avg));

            % Select k-space trajectory
            k_tmp=gg.k(1:2,:,1,1,dyn,ph,ech,loc,mix,ex1,ex2,avg);

            % Preallocate res_tmp
            res_tmp=zeros(prod(gg.kdim(1:2)),gg.idim(4));

            % Parallize over the receivers (always has same traj)
            if ~gg.parfor
                for coil=1:kdim(4)
                    % Save in temporarily matrix, saves indexing time
                    res_tmp(:,coil)=matrix_to_vec(nufft2d2(nj,k_tmp(2,:),...
                        k_tmp(1,:),1,eps,idim(1),idim(2),data_tmp(:,:,:,coil)))/sqrt(prod(gg.idim(1:2)));
                end
            else
                parfor coil=1:kdim(4)
                    % Save in temporarily matrix, saves indexing time
                    res_tmp(:,coil)=matrix_to_vec(nufft2d2(nj,k_tmp(2,:),...
                        k_tmp(1,:),1,eps,idim(1),idim(2),data_tmp(:,:,:,coil)))/sqrt(prod(gg.idim(1:2)));
                end
            end

            % Store output from all receivers
            res(:,:,z,:,dyn,ph,ech,loc,mix,ex1,ex2,avg)=reshape(res_tmp,kdim([1:2 4]));

    end % Slices
    end % Dynamics
    end % Echos
    end % Phases
    end % Mixes
    end % Locations
    end % Extra1
    end % Extra2
    end % Averages
end

% END  
end  

