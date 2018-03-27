function check_compressed_sense_input(par,varargin)

if isempty(varargin) % matlab
    if ~isfield(par,'TV')
        disp('+Error: par.TV is not defined.')
    end

    if ~isfield(par,'S')
        disp('+Error: par.S is not defined.')
    end

    if ~isfield(par,'N')
        disp('+Error: par.N is not defined.')
    end

    if ~isfield(par,'y')
        disp('+Error: par.y is not defined.')
    end

    if ~isfield(par,'W')
        disp('+Error: par.W is not defined.')
    end

    if ~isfield(par,'Niter')
        disp('+Error: par.Niter is not defined.')
    end

    if ~isfield(par,'idim')
        disp('+Error: par.idim is not defined.')
    end

    if ~isfield(par,'beta')
        disp('+Error: par.idim is not defined.')
    end

else % BART
    if ~isfield(par,'csm')
        disp('+Error: par.csm is not defined.')
    end
    
    if ~isfield(par,'kspace_data')
        disp('+Error: par.kspace_data is not defined.')
    end
    
    if ~isfield(par,'mask') && ~isfield(par,'traj')
        par.mask=ones(size(par.kspace_data));
    end
end
% END
end