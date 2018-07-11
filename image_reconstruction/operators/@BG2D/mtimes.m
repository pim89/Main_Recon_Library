function res = mtimes(fg,data) 
% Fessler 2D NUFFT operator working on 12D reconframe data
    
% Check what dimensions require new trajectory coordinates
idim=fg.idim;
kdim=fg.kdim;

if fg.adjoint==1    % non-Cartesian k-space to Cartesian image domain || type 1

    % Reshape data that goes together into the nufft operator
    data=reshape(data,[kdim(1)*kdim(2) kdim(3:end)]);

    % Loop over all dimensions and update k if required
    % For now I assumed that different Z always has the same trajectory
    for avg=1:kdim(12) % Averages
    for ex2=1:kdim(11) % Extra2
    for ex1=1:kdim(10) % Extra1
    for mix=1:kdim(9)  % Locations
    for loc=1:kdim(8)  % Mixes
    for ech=1:kdim(7)  % Echos
    for ph=1:kdim(6)   % Phases
    for dyn=1:kdim(5)  % Dynamics
    for z=1:kdim(3)    % Slices (2D)

        % Convert data to doubles, required for the function
        data_tmp=data(:,z,:,dyn,ph,ech,loc,mix,ex1,ex2,avg);

        % Preallocate temporary matrix
        res_tmp=zeros([prod(idim(1:2)) idim(4)]);

        % Parallize over the receivers (always has same traj)
        for coil=1:kdim(4)
            % Save in temporarily matrix, saves indexing time
            res_tmp(:,coil)=matrix_to_vec(nufft_adj(data_tmp(:,:,coil),...
                fg.st{dyn,ph,ech,loc,mix,ex1,ex2,avg})/sqrt(prod(fg.idim(1:2))));
            
%             res_tmp(:,coil)=matrix_to_vec(bart(bg.nufft_adj,
%             
%             (data_tmp(:,:,coil),...
%                 fg.st{dyn,ph,ech,loc,mix,ex1,ex2,avg})/sqrt(prod(fg.idim(1:2))));
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

            % Parallize over the receivers (always has same traj)
            if ~fg.parfor
                for coil=1:kdim(4)
                    % Save in temporarily matrix, saves indexing time
                    res_tmp(:,coil)=matrix_to_vec(nufft(data_tmp(:,:,coil),...
                        fg.st{dyn,ph,ech,loc,mix,ex1,ex2,avg})/sqrt(prod(fg.idim(1:2))));
                end
            else
                parfor coil=1:kdim(4)
                    % Save in temporarily matrix, saves indexing time
                    res_tmp(:,coil)=matrix_to_vec(nufft(data_tmp(:,:,coil),...
                        fg.st{dyn,ph,ech,loc,mix,ex1,ex2,avg})/sqrt(prod(fg.idim(1:2))));
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