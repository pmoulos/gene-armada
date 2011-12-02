function NewDataCellNormLo = SelectConditions(DataCellNormLo,selCond,selRep)

%
% Function to select a subset of conditions and replicates to continue the analysis. This
% function can be very useful because the user does not have to repeat the time consuming
% normalization procedure in order to perform statistical tests among condition subsets
%
% User interacts with the command window
%
% Usage: DataCellNormLo=SelectConditions(DataCellNormLo)
%        DataCellNormLo=SelectConditions(DataCellNormLo,selCond)
%        DataCellNormLo=SelectConditions(DataCellNormLo,selCond,selRep)
%
% Arguments:
% DataCellNormLo : A cell array containing experiment information after normalization
%                    (output from NormalizationStart or other normalization functions)
% selCond        : A vector (optional) in MATLAB format declaring which conditions to use in
%                  the output file (e.g. selCond=[1 2 5:7 9]). Defaults to 1:t (all)
% selRep         : A cell array of vectors of length as selCond. Each element of this
%                  cell is a vector containing the replicate numbers of each new condition
%                  that will be included in the new subset. For example, if selCond=[1 3]
%                  then selRep={[1 3],[1 2]} is a valid expression. If not given, selRep
%                  selects by default all the replicates of each new subset of conditions
%
% Output:
% DataCellNormLo : A cell array containing experiment information after normalization
%                    (output from NormalizationStart or other normalization functions)
%                    for the specific conditions in selCond
%

% Get variables from DataCellNormLo
LogRat=DataCellNormLo{1};
LogRatnormlo=DataCellNormLo{2};
Intens=DataCellNormLo{3};
LogRatsmth=DataCellNormLo{6};

% Some preallocation
ActionConditions=zeros(1,length(selCond));
NewLogRat=cell(1,length(ActionConditions));
NewLogRatnormlo=cell(1,length(ActionConditions));
NewIntens=cell(1,length(ActionConditions));
if ~isempty(LogRatsmth)
    NewLogRatsmth=cell(1,length(ActionConditions));
else
    NewLogRatsmth=LogRatsmth;
end
ActionReplicates=cell(1,length(ActionConditions));


for i=1:length(selCond)
    ActionConditions(i)=selCond(i);
end

for i=1:length(ActionConditions)
    NewLogRatnormlo{i}=LogRatnormlo{ActionConditions(i)};
    NewIntens{i}=Intens{ActionConditions(i)};
    if ~isempty(LogRatsmth)
        NewLogRatsmth{i}=LogRatsmth{ActionConditions(i)};
    end
    NewLogRat{i}=LogRat{ActionConditions(i)};
end

for i=1:length(ActionConditions)
    ActionReplicates{i}=selRep{i};
end

for i=1:length(ActionConditions)
    for j=1:length(ActionReplicates{i})
        New2LogRatnormlo{i}{j}=NewLogRatnormlo{i}{ActionReplicates{i}(j)};
        New2Intens{i}{j}=NewIntens{i}{ActionReplicates{i}(j)};
        if ~isempty(LogRatsmth)
            New2LogRatsmth{i}{j}=NewLogRatsmth{i}{ActionReplicates{i}(j)};
        end
        New2LogRat{i}{j}=NewLogRat{i}{ActionReplicates{i}(j)};
    end
end
if isempty(LogRatsmth)
    New2LogRatsmth=NewLogRatsmth;
end

NewDataCellNormLo={New2LogRat,...
                   New2LogRatnormlo,...
                   New2Intens,...
                   DataCellNormLo{4},...
                   DataCellNormLo{5},...
                   New2LogRatsmth};

% If subgrid normalization has been performed keep the area indices
if length(DataCellNormLo)==7
    NewDataCellNormLo=[NewDataCellNormLo DataCellNormLo{7}];
end