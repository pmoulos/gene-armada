function outPoints = commonGoodEachCond(datstruct,BGBadpoints,BelowBackgroundPoints,conds,auto)

% Help Function for the process of saving initially filtered genes
% auto: Logical (0 or 1), if auto then the file containing the gene information
%       will be automatically created and stored, else the user is prompted to
%       select a filename and directory. By default, auto=0 (FALSE)

if nargin<6
    auto=0;
end

n=length(datstruct{1}{1}.Number);
outPoints=cell(n-min(min(BelowBackgroundPoints))+2,3*length(conds)-1);

% Get Good points' names and Slide Positions from datstruct for each Condition
for d=1:max(size(datstruct))
    for i=1:max(size(datstruct{d}))
        bad=zeros(length(BGBadpoints{d}{i}),1);
        bad(BGBadpoints{d}{i})=1;
        BGGoodPointsSliPosTemp{d}{i}=datstruct{d}{i}.Number(~bad);
    end
end

% Create a new cell with the intersection (a little tricky since there is no matlab
% command for the intersection of more than 2 sets)
universe=cell(1,max(size(datstruct)));
counts=cell(1,max(size(datstruct)));
for d=1:max(size(datstruct))
    for i=1:max(size(datstruct{d}))
        universe{d}=sort(unique([universe{d};BGGoodPointsSliPosTemp{d}{i}]));
    end
    for p=1:length(universe{d})
        for q=1:max(size(BGGoodPointsSliPosTemp{d}))
            counts{d}(p,q)=ismember(universe{d}(p),BGGoodPointsSliPosTemp{d}{q});
        end
    end
    outBGGoodPointsSliPosTemp{d}=[];
    [m n]=size(counts{d});
    for j=1:m
        z=find(counts{d}(j,:)==ones(1,n));
        if length(z)==n
            outBGGoodPointsSliPosTemp{d}=[outBGGoodPointsSliPosTemp{d};universe{d}(j)];
        end
    end
    outBGGoodPointsNameTemp{d}=datstruct{d}{1}.GeneNames(outBGGoodPointsSliPosTemp{d});
end

% Create data Cell for xls writing
% Columns first
for j=1:length(conds)
    outPoints(1,3*j-2)=conds(j); %p+2*(p-1)=3*p-2
    outPoints(2,3*j-2)=cellstr('Slide Position');
    outPoints(2,3*j-1)=cellstr('GeneID');
    % Now rows
    for i=3:length(outBGGoodPointsSliPosTemp{j})+2
        outPoints(i,3*j-2)=cellstr(num2str(outBGGoodPointsSliPosTemp{j}(i-2)));
        outPoints(i,3*j-1)=outBGGoodPointsNameTemp{j}(i-2);
    end
end

if ~auto
    [flist,pathS]=uiputfile('.xls','Save your List');
    cd(pathS);
    xlswrite(flist,outPoints)
else
    % Create name for the .xls file
    nam=conds{1};
    for z=2:length(conds)
        nam=strcat(nam,'_',conds{z});
    end
    nam=strcat(nam,'_','CommonGoodEachCondition');
    xlswrite(nam,outPoints)
end
