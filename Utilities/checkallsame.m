function allsame = checkallsame(x)

if isscalar(x)
    error('x is not a vector! Please read help.')
end

if isnumeric(x) || ischar(x)
    xx=shuffle(x);
    z=xx==x;
    if isvector(z)
        allsame=all(z);
    else
        allsame=all(all(z));
    end
elseif iscellstr(x)
        xx=shuffle(x);
        z=strcmp(x,xx);
        if isvector(z)
            allsame=all(z);
        else
            allsame=all(all(z));
        end
elseif iscell(x)
    % Try using cell2mat in case the cell contains only numeric arrays of same size
    try
        x=cell2mat(x);
        xx=shuffle(x);
        z=xx==x;
        if isvector(z)
            allsame=all(z);
        else
            allsame=all(all(z));
        end
    catch
        error('Cannot perform the check due to input argument inconsistency')
    end
end


function [s,myorder]=shuffle(x,dim)

%
% Taken from MatLab exchange, submitted by Sara Silva, minor modifications made by me for
% the purposes of this function
%

rand('state',sum(100*clock));

switch nargin
    case 1
        if size(x,1)==1 || size(x,2)==1
            [nw,myorder]=sort(rand(1,length(x)));
            s=x(myorder);
        else
            s=zeros(size(x));
            [nw,myorder]=sort(rand(size(x,1),size(x,2)));
            for c=1:size(x,2)
                s(:,c)=x(myorder(:,c),c);
            end
        end
    case 2
        switch dim
            case 1
                [nw,myorder]=sort(rand(1,size(x,1)));
                s=x(myorder,:);
            case 2
                [nw,myorder]=sort(rand(1,size(x,2)));
                s=x(:,myorder);
            otherwise
                error('SHUFFLE: Unknown command option.')
        end
end
