function outPoints = commonBadAllCond(datstruct,BGBadpoints,BelowBackgroundPoints,conds,auto)

% Help Function for the process of saving initially filtered genes
% auto: Logical (0 or 1), if auto then the file containing the gene information
%       will be automatically created and stored, else the user is prompted to
%       select a filename and directory. By default, auto=0 (FALSE)

if nargin<6
    auto=0;
end

outPoints=cell(max(max(BelowBackgroundPoints))+2,2);

% Get Bad points' names and Slide Positions from datstruct for each Condition
for d=1:max(size(datstruct))
    for i=1:max(size(datstruct{d}))
        BGBadPointsSliPosTemp{d}{i}=datstruct{d}{i}.Number(BGBadpoints{d}{i});
    end
end

% Create a new cell with the intersection (a little tricky since there is no matlab
% command for the intersection of more than 2 sets)
universe=cell(1,max(size(datstruct)));
counts=cell(1,max(size(datstruct)));
for d=1:max(size(datstruct))
    for i=1:max(size(datstruct{d}))
        universe{d}=sort(unique([universe{d};BGBadPointsSliPosTemp{d}{i}]));
    end
    for p=1:length(universe{d})
        for q=1:max(size(BGBadPointsSliPosTemp{d}))
            counts{d}(p,q)=ismember(universe{d}(p),BGBadPointsSliPosTemp{d}{q});
        end
    end
    outBGBadPointsSliPosTemp{d}=[];
    [m n]=size(counts{d});
    for j=1:m
        z=find(counts{d}(j,:)==ones(1,n));
        if length(z)==n
            outBGBadPointsSliPosTemp{d}=[outBGBadPointsSliPosTemp{d};universe{d}(j)];
        end
    end
end

% Repeat the process for conditions (after having found the commons between repolicates)
universeAll=[];
countsAll=[];
for d=1:max(size(datstruct))
    universeAll=sort(unique([universeAll;outBGBadPointsSliPosTemp{d}]));
end
% Find counts for all conditions now
for p=1:length(universeAll)
    for q=1:length(outBGBadPointsSliPosTemp)
        countsAll(p,q)=ismember(universeAll(p),outBGBadPointsSliPosTemp{q});
    end
end
outBGBadPointsSliPosTempFinal=[];
[m n]=size(countsAll);
for j=1:m
    z=find(countsAll(j,:)==ones(1,n));
    if length(z)==n
        outBGBadPointsSliPosTempFinal=[outBGBadPointsSliPosTempFinal;universeAll(j)];
    end
end
outBGBadPointsNameTempFinal=datstruct{d}{1}.GeneNames(outBGBadPointsSliPosTempFinal);

% Create data Cell for xls writing
outPoints(1,1)=cellstr('Common Bad Points');
outPoints(2,1)=cellstr('Slide Position');
outPoints(2,2)=cellstr('GeneID');
for i=3:length(outBGBadPointsSliPosTempFinal)+2
    outPoints(i,1)=cellstr(num2str(outBGBadPointsSliPosTempFinal(i-2)));
    outPoints(i,2)=outBGBadPointsNameTempFinal(i-2);
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
    nam=strcat(nam,'_','CommonBadAllConditions');
    xlswrite(nam,outPoints)
end
