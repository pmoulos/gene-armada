function outPoints = commonGoodAllCond(datstruct,BGBadpoints,BelowBackgroundPoints,conds,auto)

% Help Function for the process of saving initially filtered genes
% auto: Logical (0 or 1), if auto then the file containing the gene information
%       will be automatically created and stored, else the user is prompted to
%       select a filename and directory. By default, auto=0 (FALSE)

if nargin<6
    auto=0;
end

n=length(datstruct{1}{1}.Number);
outPoints=cell(n-min(min(BelowBackgroundPoints))+2,2);

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
end

% Repeat the process for conditions (after having found the commons between repolicates)
universeAll=[];
countsAll=[];
for d=1:max(size(datstruct))
    universeAll=sort(unique([universeAll;outBGGoodPointsSliPosTemp{d}]));
end
% Find counts for all conditions now
for p=1:length(universeAll)
    for q=1:length(outBGGoodPointsSliPosTemp)
        countsAll(p,q)=ismember(universeAll(p),outBGGoodPointsSliPosTemp{q});
    end
end
outBGGoodPointsSliPosTempFinal=[];
[m n]=size(countsAll);
for j=1:m
    z=find(countsAll(j,:)==ones(1,n));
    if length(z)==n
        outBGGoodPointsSliPosTempFinal=[outBGGoodPointsSliPosTempFinal;universeAll(j)];
    end
end
outBGGoodPointsNameTempFinal=datstruct{d}{1}.GeneNames(outBGGoodPointsSliPosTempFinal);

% Create data Cell for xls writing
outPoints(1,1)=cellstr('Common Good Points');
outPoints(2,1)=cellstr('Slide Position');
outPoints(2,2)=cellstr('GeneID');
for i=3:length(outBGGoodPointsSliPosTempFinal)+2
    outPoints(i,1)=cellstr(num2str(outBGGoodPointsSliPosTempFinal(i-2)));
    outPoints(i,2)=outBGGoodPointsNameTempFinal(i-2);
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
    nam=strcat(nam,'_','CommonGoodAllConditions');
    xlswrite(nam,outPoints)
end
