function outPoints = badEachCondRep(datstruct,BGBadpoints,BelowBackgroundPoints,conds,auto)

% Help Function for the process of saving initially filtered genes
% auto: Logical (0 or 1), if auto then the file containing the gene information
%       will be automatically created and stored, else the user is prompted to
%       select a filename and directory. By default, auto=0 (FALSE)

if nargin<6
    auto=0;
end

numRep=zeros(1,max(size(datstruct)));
for i=1:length(numRep)
    numRep(i)=max(size(datstruct{i}));
end

outPoints=cell(max(max(BelowBackgroundPoints))+3,2*sum(numRep)+length(conds)-1);

% Get Bad points' names and Slide Positions from datstruct for each Condition
for d=1:max(size(datstruct))
    for i=1:max(size(datstruct{d}))
        BGBadPointsSliPosTemp{d}{i}=datstruct{d}{i}.Number(BGBadpoints{d}{i});
        BGBadPointsNameTemp{d}{i}=datstruct{d}{i}.GeneNames(BGBadpoints{d}{i});
    end
end

% Columns first
for j=1:length(conds)
    a=2*sum(numRep(1:j-1))+j;
    outPoints(1,a)=conds(j);
    for p=1:numRep(j)
        b=a+2*(p-1);
        outPoints(2,b)=cellstr(strcat('Replicate_',num2str(p)));
        outPoints(3,b)=cellstr('Slide Position');
        outPoints(3,b+1)=cellstr('GeneID');
        % Now rows
        for i=4:length(BGBadPointsSliPosTemp{j}{p})+3
            outPoints(i,b)=cellstr(num2str(BGBadPointsSliPosTemp{j}{p}(i-3)));
            outPoints(i,b+1)=BGBadPointsNameTemp{j}{p}(i-3);
        end
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
    nam=strcat(nam,'_','BadEachConditionRep');
    xlswrite(nam,outPoints)
end
