function [dMASK] = outlines(MASK)
% Function which takes derivative of a MASK
% Version 20151019 || t.bruijnen@student.tue.nl

dMASK=zeros(size(MASK)); % Allocate matrix
for z=2:size(MASK,3)-1
    for y=2:size(MASK,1)-1  % Do not take first/last pixel
        for x=2:size(MASK,2)-1
            if ((MASK(y-1,x,z)==0 || MASK(y+1,x,z)==0 || MASK(y,x-1,z)==0 || MASK(y,x+1,z)==0 ||...
                  MASK(y,x,z+1)==0 || MASK(y,x,z-1)==0) && MASK(y,x,z)>0)
                dMASK(y,x,z)=1; % Get 1st order derivative for outline
            end
        end
    end
end

% END
end