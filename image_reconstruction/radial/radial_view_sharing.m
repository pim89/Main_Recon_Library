function res = radial_view_sharing(data,kernel,width,dim)
% Generic view sharing function to increase size of matrix M
% Data = matrix
% kernel = function handle to apply weights
% width = number of neighbours to share
% dim = what dimension to share [

% If width ==0 return
if width==0
    res=data;
    return
end

% Get dimensions
dims=size(data);

% Get output dimensions and preallocate
ndims=dims;ndims(dim(1))=ndims(dim(1))+2*width*ndims(dim(1));

% If view kernel is empty assume ones
if isempty(kernel)
    kernel=@(x)(1);
end

% Fill in shared values
for t=1:dims(dim(2))

    % Dimensionality stuff
    curdims=ndims;curdims(dim(2))=1;
    fin{t}=zeros(curdims);
    
    % Fill in old data
    for j=1:dims(dim(1))
        A=dynamic_indexing(dynamic_indexing(data,dim(2),t),dim(1),j);
        fin{t}=dynamic_indexing(fin{t},dim(1),j,A);
    end
        
    % Fill in shared data
    for w=1:width
        if t+w < 1 || t+w > dims(dim(2))
            curval1=zeros(curdims);
        else
            curval1=kernel(abs(w))*dynamic_indexing(data,dim(2),t+w);
        end
        if t-w < 1 || t-w > dims(dim(2))
            curval2=zeros(curdims);
        else
            curval2=kernel(abs(w))*dynamic_indexing(data,dim(2),t-w);
        end
        
        % Index
        for k=1:dims(dim(1))
            A1=dynamic_indexing(curval1,dim(1),k);
            A2=dynamic_indexing(curval2,dim(1),k);
            fin{t}=dynamic_indexing(fin{t},dim(1),j+6*(w-1)+2*k-1,A1);
            fin{t}=dynamic_indexing(fin{t},dim(1),j+1+6*(w-1)+2*k-1,A2);
        end
    end        
    
    % Display
    disp(['Timepoint  =  ',num2str(t),' / ',num2str(dims(dim(2)))])
end
    
% Index everything
res=cat(dim(2),fin{1:end});

% END
end