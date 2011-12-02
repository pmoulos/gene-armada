function out = flatData(tab,dim)

if nargin<2
    dim=1;
end

% Get dataset size
n=0;
for i=1:length(tab)
    for j=1:length(tab{i})
        n=n+1;
    end
end

out=zeros(size(tab{1}{1},1),n);
currcol=0;
for i=1:length(tab)
    for j=1:length(tab{i})
        currcol=currcol+1;
        out(:,currcol)=tab{i}{j}(:,dim);
    end
end