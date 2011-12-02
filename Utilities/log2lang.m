function out = log2lang(x)

if x 
    if islogical(x)
        out='Yes';
    elseif isnumeric(x)
        out=num2str(x);
    elseif ischar(x)
        out=x;
    end
else
    out='No';
end