function [outdata,repbadpoints]=mknanavg(data,avgdata)

[n,p]=find(isnan(data));
outdata=data;
if ~isscalar(avgdata) && ~isempty(n)
    for k=1:max(size(n))
        outdata(n(k),p(k))=avgdata(n(k))';
    end
end
[repbadpoints1,p]=find(isnan(outdata));
repbadpoints=unique(repbadpoints1);