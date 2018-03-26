function tv = TV_sparse(idim,TVdim,lambda)
% Create one sparse matrix to perform all the required TV operations for
% arbitrary dimensions and orders.
% Input: - idim = 12D vector of integers with dimensions. E.g. [240 240 32 12 5 1 1 1 1 1 1]
%        - TVdim = 12D vector of 0/1/2/3 in which dimensions to apply TV. 0
%            = no TV | 1 = first order TV | 2 = second order TV | 3 = first +
%            second order. Example: [3 3 0 0 1 0 0 0 0 0 0 0]
%        - lambda = 12D vector with regularization weights
% 
% Note: if no TVdim is provided Tykhonov regularization is applied with
% lambda = lambda(1)

idim=c12d(idim);
% Check input
if isempty(TVdim)
	TVdim=zeros(1,12);
end

if isempty(lambda)
	lambda=zeros(1,12);
end

% If no TV use tychonov regularization
if nnz(TVdim)==0
    tv=lambda(1)*speye(prod(idim([1:3 5:end])));return;end

% Pre-allocate TV matrix
tv=sparse(prod(idim([1:3 5:end])),prod(idim([1:3 5:end])));

% Loop over all dimensions and compute sparse matrices
for n=1:numel(TVdim)
    if TVdim(n)>0
        tv=tv+lambda(n)*TV(n,idim,TVdim(n));
    end
end
    
disp('+TV sparse matrix operator initialized.')
% END
end