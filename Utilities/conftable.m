function [conftab,final] = conftable(hat,cl,out,dis)

% Display confusion matrix
% hat: the vector of predicted classes
% cls: the vector of classes
% out: 'cell' or 'matrix', if cell, labels can be added to indicate class 
% dis: display the confusion matrix in read-friendly format
% conftab: the confusion table
% final: a character version of conftab for better visualization

if nargin<3
    out='cell';
    dis=true;
elseif nargin<4
    dis=true;
end

len=length(unique(cl));
fac=unique(cl);
conf=zeros(len,len);

if isnumeric(cl)
    for i=1:len
        for j=1:len
            if i==j
                conf(i,j)=length(find(hat==fac(i) & cl==fac(j)));
            elseif i>j
                conf(i,j)=length(find(hat==fac(i) & cl==fac(j)));
            elseif i<j
                conf(i,j)=length(find(hat==fac(i) & cl==fac(j)));
            end
        end
    end
else
    for i=1:len
        for j=1:len
            if i==j
                conf(i,j)=length(find(strcmp(fac{i},hat) & strcmp(fac{j},cl)));
            elseif i>j
                conf(i,j)=length(find(strcmp(fac{i},hat) & strcmp(fac{j},cl)));
            elseif i<j
                conf(i,j)=length(find(strcmp(fac{i},hat) & strcmp(fac{j},cl)));
            end
        end
    end
end

if nargout==2 || dis
    % Confusion matrix has to be converted to cell
    tconf=conv2cell(fac,conf);
    slen=zeros(1,length(fac));
    clen=zeros(size(conf));
    % Same for factors
    if isnumeric(fac)
        fnew=cell(1,length(fac));
        for i=1:length(fac)
            fnew{i}=num2str(fac(i));
        end
    else
        fnew=fac;
    end
    % Find the maximum length of any element so as to define cell width
    for i=1:length(fnew)
        slen(i)=length(fnew{i});
    end
    for i=1:size(conf,1)
        for j=1:size(conf,2)
            clen(i,j)=length(tconf{i,j});
        end
    end
    maxlen=max(max(max(clen)),max(slen));
    % Initialize final viualization matrix, the size is the 2*#classes+1 because the
    % number of out-layer lines is larger (think of a margined table)
    final=repmat(' ',[2*(length(fac)+1)+1,maxlen*(length(fac)+1)+length(fac)+2]);
    % Add horizontal lines in odd lines (inside cells)
    for i=1:length(fac)+2
        for j=1:length(fac)+1
            final(2*i-1,(j-1)*maxlen+j+1:j*(maxlen+1))='-';
        end
    end
    % Add vertical lines columns between the cells
    for i=1:maxlen+1:size(final,2)
        final(:,i)='|';
    end
    % Fill the cells, attention should be paid to the different offsets, for each cell we
    % calculate the number of positions that have to be left behind using the width of
    % each cell. Justification is right.
    for i=1:size(tconf,1)
        for j=1:size(tconf,2)
            offset=maxlen-length(tconf{i,j})+1;
            final(2*i,(j-1)*maxlen+j+offset:j*(maxlen+1))=tconf{i,j};
        end
    end
    if dis
        disp(' ')
        disp(final)
        disp(' ')
    end
end

if strcmpi(out,'cell')
    conftab=conv2cell(fac,conf);
elseif strcmpi(out,'matrix')
    conftab=conf;
else
    error('The input argument out must be one of ''cell'' or ''matrix''')
end


function c = conv2cell(f,tab)

c=cell(length(f)+1,length(f)+1);
for i=1:size(tab,1)
    for j=1:size(tab,2)
        c{i+1,j+1}=num2str(tab(i,j));
    end
end
if isnumeric(f)
    f=f(:);
    f=mat2cell(f,ones(1,length(f)),1);
    for i=1:length(f)
        f{i}=num2str(f{i});
    end
end
c{1,1}='Class';
c(1,2:end)=f;
c(2:end,1)=f;
