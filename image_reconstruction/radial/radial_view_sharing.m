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
f=@(ww)(2*(ww-1)+1);

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
    tmp=dynamic_indexing(data,dim(2),t); 
    fin{t}=dynamic_indexing(fin{t},dim(1),f(1):dims(dim(1)),tmp);
    
    % Fill in shared data
    for w=1:width
        % Curval 1 / 2 process both sides
        if t+w < 1 || t+w > dims(dim(2))
            curval1=zeros(size(tmp),'single');
        else
            curval1=kernel(abs(w))*dynamic_indexing(data,dim(2),t+w);
        end
        if t-w < 1 || t-w > dims(dim(2))
            curval2=zeros(size(tmp),'single');
        else
            curval2=kernel(abs(w))*dynamic_indexing(data,dim(2),t-w);
        end
        
        % Assign to large matrix
        idx1=1+f(w)*dims(dim(1)):(1+f(w))*dims(dim(1));
        idx2=1+(f(w)+1)*dims(dim(1)):(2+f(w))*dims(dim(1));
        fin{t}=dynamic_indexing(fin{t},dim(1),idx1,curval1);
        fin{t}=dynamic_indexing(fin{t},dim(1),idx2,curval2);
    end        
    
    % Display
    %disp(['Timepoint  =  ',num2str(t),' / ',num2str(dims(dim(2)))])
end
    
% Index everything
res=cat(dim(2),fin{1:end});

disp(['+Data is view-shared to dimensions: ',num2str(size(res))])

% END
end