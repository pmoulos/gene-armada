function outBGPoints=FindBGBadpointsAuto(datstruct,BGBadpoints,BelowBackgroundPoints,chvec,conds)

% Function to return good or bad points according to chvec (see FindBadPoints.m)

if nargin<5
    conds=input('Give the Conditions in Cell String Format: ');
end

if islogical(chvec)
    chvec=find(chvec);
end

% Start building outputs depending on user choices
for i=1:length(chvec)
    z=chvec(i);
    switch z
        case 1 %Bad Points for each Condition
            outBGPoints=badEachCond(datstruct,BGBadpoints,BelowBackgroundPoints,conds,1);
        case 2 %Good Points for each Condition
            outBGPoints=goodEachCond(datstruct,BGBadpoints,BelowBackgroundPoints,conds,1);
        case 3 %Bad Points for each Condition and Replicate
            outBGPoints=badEachCondRep(datstruct,BGBadpoints,BelowBackgroundPoints,conds,1);
        case 4 %Good Points for each Condition and Replicate
            outBGPoints=goodEachCondRep(datstruct,BGBadpoints,BelowBackgroundPoints,conds,1);
        case 5 %Common Bad Points between Replicates for each Condition
            outBGPoints=commonBadEachCond(datstruct,BGBadpoints,BelowBackgroundPoints,conds,1);
        case 6 %Common Good Points between Replicates for each Condition
            outBGPoints=commonGoodEachCond(datstruct,BGBadpoints,BelowBackgroundPoints,conds,1);
        case 7 %Common Bad Points between Replicates for all Conditions
            outBGPoints=commonBadAllCond(datstruct,BGBadpoints,BelowBackgroundPoints,conds,1);
        case 8 %Common Good Points between Replicates for all Conditions
            outBGPoints=commonGoodAllCond(datstruct,BGBadpoints,BelowBackgroundPoints,conds,1);

    end
end