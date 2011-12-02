function outPoints = badEachCond(datstruct,BGBadpoints,BelowBackgroundPoints,conds,auto)

% Help Function for the process of saving initially filtered genes
% auto: Logical (0 or 1), if auto then the file containing the gene information
%       will be automatically created and stored, else the user is prompted to
%       select a filename and directory. By default, auto=0 (FALSE)

if nargin<6
    auto=0;
end

outPoints=cell(max(max(BelowBackgroundPoints))+2,3*length(conds)-1);

% Get Bad points' names and Slide Positions from datstruct for each Condition
for d=1:max(size(datstruct))
    for i=1:max(size(datstruct{d}))
        BGBadPointsSliPosTemp{d}{i}=datstruct{d}{i}.Number(BGBadpoints{d}{i});
    end
end

% Create a new cell with unique names for each condition to help with the final output printing
for d=1:max(size(datstruct))
    outBGBadPointsSliPosTemp{d}=BGBadPointsSliPosTemp{d}{1};
    for i=2:max(size(BGBadPointsSliPosTemp{d}))
        outBGBadPointsSliPosTemp{d}=[outBGBadPointsSliPosTemp{d};BGBadPointsSliPosTemp{d}{i}];
    end
    outBGBadPointsSliPosTemp{d}=unique(outBGBadPointsSliPosTemp{d});
    outBGBadPointsNameTemp{d}=datstruct{d}{1}.GeneNames(outBGBadPointsSliPosTemp{d});
end

% Create data Cell for xls writing
% Columns first
for j=1:length(conds)
    outPoints(1,3*j-2)=conds(j); %p+2*(p-1)=3*p-2
    outPoints(2,3*j-2)=cellstr('Slide Position');
    outPoints(2,3*j-1)=cellstr('GeneID');
    % Now rows
    for i=3:length(outBGBadPointsSliPosTemp{j})+2
        outPoints(i,3*j-2)=cellstr(num2str(outBGBadPointsSliPosTemp{j}(i-2)));
        outPoints(i,3*j-1)=outBGBadPointsNameTemp{j}(i-2);
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
    nam=strcat(nam,'_','BadEachCondition');
    xlswrite(nam,outPoints)
end
