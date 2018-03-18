function res = regularized_iterative_sense(x,params,transp_flag)

% Forward and backward operations
if strcmp(transp_flag,'transp') % Nonuniform k-space uncombined --> uniform image space combined  
    
    % Vector to matrix
    x1=vec_to_matrix(x(1:prod(params.kdim)),params.kdim);
    x2=x(prod(params.kdim)+1:end);

    % Data fidelity part 
    res=params.N'*(params.W*x1);
    
    % Total variation part
    D=params.TV'*x2;

    % Coil sensitivity maps operator
    res=params.S*res;
    
    % Matrix to vector
    res=matrix_to_vec(res)+complex(D);
    
elseif strcmp(transp_flag,'notransp') % uniform image combined --> nonuniform k-space uncombined
    
    % Total variation part
    D=params.TV*matrix_to_vec(x);

    % Vector to matrix
    x=vec_to_matrix(x,[params.idim(1:3) 1 params.idim(5:12)]);
    
    % S operator
    x=params.S'*x;
    
    % Data fidelity part
    res=params.W*(params.N*x);
    
    % Vectorize
    res=[matrix_to_vec(res); complex(D)];    
   
end

% END
end