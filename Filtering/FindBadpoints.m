function [exptab,TotalBadpoints] = FindBadpoints(datstruct,t,exprp,imgsw,subBefOrAft,...
                                                 filMet,noiseParam,doreptest,meanOrMedian,...
                                                 reptest,pval,dishis,pbp,condnames,htext)
                                                 
%
% Gene filtering by signal-to-noise, signal-noise distribution distance or customized
% filter and reproducibility filters
% Create the structure exptab to continue the analysis by uniting image analysis software
% identified poor quality spots, filter sensitive spots and statistical replicates 
% bad points
%
% User does not interact with the command window
%
% Usage: [exptab,TotalBadpoints]=FindBadpoints(datstruct,t,exprp,imgsw)
%        [exptab,TotalBadpoints]=FindBadpoints(datstruct,t,exprp,imgsw,subBefOrAft)
%        [exptab,TotalBadpoints]=FindBadpoints(datstruct,t,exprp,imgsw,subBefOrAft,filMet)
%        [exptab,TotalBadpoints]=FindBadpoints(datstruct,t,exprp,imgsw,subBefOrAft,filMet,...
%                                              noiseParam)
%        [exptab,TotalBadpoints]=FindBadpoints(datstruct,t,exprp,imgsw,subBefOrAft,filMet,...
%                                              noiseParam,doreptest)
%        [exptab,TotalBadpoints]=FindBadpoints(datstruct,t,exprp,imgsw,subBefOrAft,filMet,...
%                                              noiseParam,doreptest,meanOrMedian)
%        [exptab,TotalBadpoints]=FindBadpoints(datstruct,t,exprp,imgsw,subBefOrAft,filMet,...
%                                              noiseParam,doreptest,meanOrMedian,reptest)
%        [exptab,TotalBadpoints]=FindBadpoints(datstruct,t,exprp,imgsw,subBefOrAft,filMet,...
%                                              noiseParam,doreptest,meanOrMedian,reptest,...
%                                              pval)
%        [exptab,TotalBadpoints]=FindBadpoints(datstruct,t,exprp,imgsw,subBefOrAft,filMet,...
%                                              noiseParam,doreptest,meanOrMedian,reptest,...
%                                              pval,pbp)
%        [exptab,TotalBadpoints]=FindBadpoints(datstruct,t,exprp,imgsw,subBefOrAft,filMet,...
%                                              noiseParam,doreptest,meanOrMedian,reptest,...
%                                              pval,pbp,condnames)
%
% Arguments:
% datstruct    : The data structure containing the experiment info
% t            : The number of experimental conditions
% exprp        : A cell array of strings containing condition and replicate filenames
% imgsw        : A scalar declaring the image analysis software (currently QuantArray,
%                ImaGene and GenePix supported)
%                imgsw=1: QuantArray
%                imgsw=2: ImaGene
%                imgsw=3: GenePix
%                imgsw=4: Text delimited
%                imgsw=5: Agilent Feature Extraction
% subBefOrAft  : A scalar controlling whether to correct for background by background
%                subtraction (where the log ratio is 
%                log2((Signal(Cy5)-Background(Cy5))/(Signal(Cy5)-Background(Cy5))) and the
%                subtraction takes place BEFORE log transformation), by signal-to-noise
%                ratio (where the log ratio is 
%                log2((Signal(Cy5)/Background(Cy5))/(Signal(Cy5)/Background(Cy5))) and the
%                subtraction takes place AFTER log transformation, can be immediately seen
%                by properties of logarithms) or no background subtraction
%                subBefOrAft=1 : Background subtraction (subtraction before in log scale)
%                subBefOrAft=2 : Signal-to-Noise (subtraction after in log scale, default)
%                subBefOrAft=3 : No background correction
% filMet       : A scalar controlling what type of background noise filter to use. Three
%                filters are available. A signal-to-noise filter (default), a signal-noise
%                distribution filter where the noisy points are filtered according to the 
%                inequality 
%                'Mean(Signal) +/- x*StDev(Signal) < Mean(Background) +/- y*StDev(Background)'
%                and a user customizable filter
%                filMet=1 : Signal-to-noise filter (default)
%                filMet=2 : Signal-noise distribution filter
%                filMet=3 : Custom filter
% noiseParam   : A variable of varying type, according to filMet. If filMet=1
%                (signal-to-noise filter) noiseParam is a scalar declaring how many folds
%                up should signal be above background (defaults to 2). If filMet=2
%                (signal-noise distribution distance) noiseParam is a vector of length 2
%                declaring x and y in the inequality above. If filMet=3 (custom filter)
%                noiseParam is a string declaring the filter to use, e.g. 
%                'SigMean < 2*SigStd' or 'SigMedian - BackMedian < 500'
%                Use any of the following symbols in your filter:
%                + , - , * , / , < , > or = and any positive number
%                'SigMean    : Signal Mean'
%                'BackMean   : Background Mean'
%                'SigStd     : Signal Standard Deviation'
%                'BackStd    : Background Standard Deviation'
%                'SigMean    : Signal Mean'
%                'BackMean   : Background Mean'
%                'SigStd     : Signal Standard Deviation'
%                'BackStd    : Background Standard Deviation'
%                'SigMedian  : Signal Median'
%                'BackMedian : Background Median' 
% doreptest    : A logical declaring whether to perform gene reproducibility test or not
%                doreptest=0 : Not perform (default)
%                doreptest=1 : Perform
% meanOrMedian : If you have output files from ImaGene, GenePix or Agilent Feature 
%                Extraction Software then you can use the signal mean instead of median
%                meanOrMedian=1 : Use mean (default)
%                meanOrMedian=2 : Use median (valid only for ImaGene, GenePix or Agilent
%                Feature Extraction Software(imgsw=2
%                or 3 respectively)
% reptest      : If you choose to perform a gene reproducibility test, reptest is a scalar
%                declaring which test to use: t-test or wilcoxon
%                reptest=1 : Wilcoxon
%                reptest=2 : t-test (default)
% pval         : A vector of length as the number of conditions with p-value cutoffs for
%                each condition for the reproducibility test or a scalar. If it is a
%                scalar then its values will be recycled until it becomes a vector of
%                length t. The numbers should lie bewteen 0 and 1. Defaults to 0.05.
% dishis       : A logical controlling whether to display histograms for the
%                reproducibility test or not
%                dishis=0 : Do not display (default)
%                dishis=1 : Display
% pbp          : A logical variable to control whether to export the noise filtered gene 
%                IDs and Slide Positions in Excel format or not
%                pbp=0 : Do not export (default)
%                pbp=1 : Export
% condnames    : A cell array of strings containing condition names in case pbp=1 to be
%                used in the export. If not given, it will be created automatically using
%                the word 'Condition' plus a number from 1 to t.
% 
% Output:
% exptab         : A cell containing signal intensities for both channels and the log ratio
% TotalBadpoints : A cell containing indices for noise filtered genes
%
% See also INPUTSTXT, CREATEDATSTRUCT, FINDBADPOINTS
%

% Check for various inputs
if nargin<5
    subBefOrAft=2;  % Use signal-to-ratio by default
    filMet=1;       % Use signal-to-ratio filter by default
    noiseParam=2;   % Signal 2-folds up above background by default
    doreptest=0;    % Not perform gene reproducibility test by default
    meanOrMedian=1; % Use mean where choice is possible
    reptest=2;      % t-test reproducibility test by default
    pval=0.05;      % Default p-value for reproducibility tests
    dishis=0;       % Do not display histograms
    pbp=0;          % Do not export noise filtered genes
    condnames=[];   % Empty array since the default of pbp is 0
    htext=[];       % Empty handle
elseif nargin<6
    filMet=1;
    noiseParam=2;
    doreptest=0;
    meanOrMedian=1;
    reptest=2;
    pval=0.05;
    dishis=0;
    pbp=0;
    condnames=[];
    htext=[];
elseif nargin<7
    switch filMet
        case 1
            noiseParam=2;
        case 2
            noiseParam=[-1 2];
        case 3
            noiseParam='SigMean/BackMean < 2'; % Signal-to-noise by default
    end
    doreptest=0;
    meanOrMedian=1;
    reptest=2;
    pval=0.05;
    dishis=0;
    pbp=0;
    condnames=[];
    htext=[];
elseif nargin<8
    doreptest=0;
    meanOrMedian=1;
    reptest=2;
    pval=0.05;
    dishis=0;
    pbp=0;
    condnames=[];
    htext=[];
elseif nargin<9
    meanOrMedian=1;
    reptest=2;
    pval=0.05;
    dishis=0;
    pbp=0;
    condnames=[];
    htext=[];
elseif nargin<10
    reptest=2;
    pval=0.05;
    pbp=0;
    condnames=[];
    htext=[];
elseif nargin<11
    pval=0.05;
    dishis=0;
    pbp=0;
    condnames=[];
    htext=[];
elseif nargin<12
    dishis=0;
    pbp=0;
    condnames=[];
    htext=[];
elseif nargin<13
    pbp=0;
    condnames=[];
    htext=[];
elseif nargin<14
    if pbp
        condnames=cell(1,t);
        for i=1:t
            condnames{i}=['Condition ',num2str(i)];
        end
    else
        condnames=[];
    end
    htext=[];
elseif nargin<15
    htext=[];
end

% Get the message from the ARMADA main textbox
if ~isempty(htext)
    mainmsg=get(htext,'String');
    % Update it
    mainmsg=[mainmsg;' ';...
             '                          Spot Quality Filtering';...
             '=====================================================================';' '];
    set(htext,'String',mainmsg)
    drawnow;
else
    disp(' ')
    disp('                          Spot Quality Filtering')
    disp('=====================================================================')
    disp(' ')
end

% Background filtering
switch imgsw
    case 1 %Quant Array
        [exptab,BackgroundBadpoints,badch1,badch2]=findBadpointsInternal(datstruct,exprp,...
            t,noiseParam,subBefOrAft,filMet,1);
    case 2 %ImaGene
        [exptab,BackgroundBadpoints,badch1,badch2]=findBadpointsInternal(datstruct,exprp,...
            t,noiseParam,subBefOrAft,filMet,meanOrMedian);
    case 3 %GenePix
        [exptab,BackgroundBadpoints,badch1,badch2]=findBadpointsInternal(datstruct,exprp,...
            t,noiseParam,subBefOrAft,filMet,meanOrMedian);
    case 4 %Text delimited
        if meanOrMedian==2 && isempty(datstruct{1}{1}.ch1IntensityMedian)
            uiwait(warndlg('Median fields not found... proceeding with Mean instead...','Warning'));
            if filMet==3
                noiseParam=strrep(noiseParam,'SigMedian','SigMean');
                noiseParam=strrep(noiseParam,'BackMedian','BackMean');
            end
            [exptab,BackgroundBadpoints,badch1,badch2]=findBadpointsInternal(datstruct,exprp,...
                t,noiseParam,subBefOrAft,filMet,1);
        else
            [exptab,BackgroundBadpoints,badch1,badch2]=findBadpointsInternal(datstruct,exprp,...
                t,noiseParam,subBefOrAft,filMet,meanOrMedian);
        end
    case 5 %Agilent Feature Extraction
        if meanOrMedian==2 && isempty(datstruct{1}{1}.ch1IntensityMedian)
            uiwait(warndlg(['Median fields not found or are treated as means because of ',...
                            'means absence in Agilent FE output... proceeding with Mean instead...'],...
                            'Warning'));
            if filMet==3
                noiseParam=strrep(noiseParam,'SigMedian','SigMean');
                noiseParam=strrep(noiseParam,'BackMedian','BackMean');
            end
            [exptab,BackgroundBadpoints,badch1,badch2]=findBadpointsInternal(datstruct,exprp,...
                t,noiseParam,subBefOrAft,filMet,1);
        else
            [exptab,BackgroundBadpoints,badch1,badch2]=findBadpointsInternal(datstruct,exprp,...
                t,noiseParam,subBefOrAft,filMet,meanOrMedian);
        end
end

% View Background Badpoints
for j=1:t
    for y=1:length(exprp{j})
        BelowBackgroundBadpoints(y,j)=length(BackgroundBadpoints{j}{y});
    end
end

if ~isempty(htext)
    mainmsg=[mainmsg;' ';...
             'These are the poor quality spots per Condiition and Replicate';...
             'Columns are the Conditions - Rows are the replicates';...
             '-----------------------------------------------------------';...
             num2str(BelowBackgroundBadpoints);...
             '-----------------------------------------------------------';' '];
    set(htext,'String',mainmsg)
    drawnow;
else
    disp(' ')
    disp('These are the poor quality spots per Condiition and Replicate')
    disp('Columns are the Conditions - Rows are the replicates')
    disp('-----------------------------------------------------------')
    disp(num2str(BelowBackgroundBadpoints))
    disp('-----------------------------------------------------------')
    disp(' ')
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choose to print filtered genes or not (currently available only for cDNA microarrays)
if pbp
    [choices,cancel]=checkboxBad;
    if ~cancel
        hh=showinfowindow('Exporting background noise filtered genes in Excel format. Please wait...');
        outBGBadPoints=FindBGBadpointsAuto(datstruct,BackgroundBadpoints,BelowBackgroundBadpoints,...
                                           logical(choices),condnames);
        set(hh,'CloseRequestFcn','closereq')
        close(hh)
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if doreptest
    %hh=showinfowindow('Performing reproducibility test, please wait...');
    [TotalBadpoints Totalbadch1 Totalbadch2] = reprodTest(t,exprp,exptab,badch1,badch2,...
                                                          BackgroundBadpoints,reptest,pval,...
                                                          dishis,htext);
    %set(hh,'CloseRequestFcn','closereq')
    %close(hh)
else
    Totalbadch1=badch1;
    Totalbadch2=badch2;
    TotalBadpoints=BackgroundBadpoints;
end

% Mark poor quality spots as NaN
hh=showinfowindow('Marking poor quality spots... Please wait');
for d=1:t
    for i=1:max(size(exprp{d}))
        exptab{d}{i}(Totalbadch1{d}{i},1)=NaN;
        exptab{d}{i}(Totalbadch2{d}{i},2)=NaN;
        exptab{d}{i}(TotalBadpoints{d}{i},3)=NaN;
    end
end
set(hh,'CloseRequestFcn','closereq')
close(hh)
drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%                            Subfunctions                            %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [datatab,bgbadspot,bad1,bad2]=findBadpointsInternal(datstr,nams,t,bbc,subba,fil,mm)

% Calculate expression means for signal and background
if (mm==1)
    for d=1:t
        for i=1:max(size(nams{d}))
            % Transform data to avoid inf at the log2 trasform
            intensdata{d}{i}(:,1)=mkoneconst(datstr{d}{i}.ch1Intensity);
            outdata{d}{i}(:,1)=mkzeroconst(datstr{d}{i}.ch1Background);
            intensdata{d}{i}(:,2)=mkoneconst(datstr{d}{i}.ch2Intensity);
            outdata{d}{i}(:,2)=mkzeroconst(datstr{d}{i}.ch2Background);
        end
    end
elseif (mm==2)
    for d=1:t
        for i=1:max(size(nams{d}))
            % Transform data to avoid inf at the log2 trasform
            intensdata{d}{i}(:,1)=mkoneconst(datstr{d}{i}.ch1IntensityMedian);
            outdata{d}{i}(:,1)=mkzeroconst(datstr{d}{i}.ch1BackgroundMedian);
            intensdata{d}{i}(:,2)=mkoneconst(datstr{d}{i}.ch2IntensityMedian);
            outdata{d}{i}(:,2)=mkzeroconst(datstr{d}{i}.ch2BackgroundMedian);
        end
    end
end

% Calculate expression standard deviations for signal and background (if needed)
if fil==2 || fil==3
    for d=1:t
        for i=1:max(size(nams{d}))
            % Transform data to avoid inf at the log2 trasform
            intensdataStd{d}{i}(:,1)=mkoneconst(datstr{d}{i}.ch1IntensityStd);
            outdataStd{d}{i}(:,1)=mkzeroconst(datstr{d}{i}.ch1BackgroundStd);
            intensdataStd{d}{i}(:,2)=mkoneconst(datstr{d}{i}.ch2IntensityStd);
            outdataStd{d}{i}(:,2)=mkzeroconst(datstr{d}{i}.ch2BackgroundStd);
        end
    end
end
    
% Subtract background before or after log2 data transformation
if subba==1
    for d=1:t
        for i=1:max(size(nams{d}))
            % Subtract Background for both channels BEFORE
            datatab{d}{i}(:,1)=log2(intensdata{d}{i}(:,1)-outdata{d}{i}(:,1));
            datatab{d}{i}(:,2)=log2(intensdata{d}{i}(:,2)-outdata{d}{i}(:,2));            
        end
    end
elseif subba==2
    for d=1:t
        for i=1:max(size(nams{d}))
            % Subtract Background for both channels AFTER
            datatab{d}{i}(:,1)=log2(intensdata{d}{i}(:,1))-log2(outdata{d}{i}(:,1));
            datatab{d}{i}(:,2)=log2(intensdata{d}{i}(:,2))-log2(outdata{d}{i}(:,2));        
        end
    end
elseif subba==3
    for d=1:t
        for i=1:max(size(nams{d}))
            % Do NOT subtract Background for any channel
            datatab{d}{i}(:,1)=log2(intensdata{d}{i}(:,1));
            datatab{d}{i}(:,2)=log2(intensdata{d}{i}(:,2));        
        end
    end
end

% Calculate filtering condition badpoints for both channels
if fil==1
    [ConditionFiltered1,ConditionFiltered2]=findConditionalBadpoints(fil,nams,t,intensdata,...
                                                                     outdata,bbc);
elseif fil==2 || fil==3
    [ConditionFiltered1,ConditionFiltered2]=findConditionalBadpoints(fil,nams,t,intensdata,...
                                                                     outdata,bbc,intensdataStd,...
                                                                     outdataStd);
elseif fil==4 % No filtering
    for d=1:t
        for i=1:max(size(nams{d}))
            ConditionFiltered1{d}{i}=[];
            ConditionFiltered2{d}{i}=[];
        end
    end
end

% Calculate final badpoints
for d=1:t
    for i=1:max(size(nams{d}))
        % Find Image Software flagged Badpoints
        IMGSWbadpoints{d}{i}=find(datstr{d}{i}.IgnoreFilter==0)';
        % Union Image Software Badpoints and conditional filtered elements
        bad1{d}{i}=union(IMGSWbadpoints{d}{i},ConditionFiltered1{d}{i});
        bad2{d}{i}=union(IMGSWbadpoints{d}{i},ConditionFiltered2{d}{i});
        bgbadspot{d}{i}=union(bad1{d}{i},bad2{d}{i});
        bgbadspot{d}{i}=unique(bgbadspot{d}{i});
        % Calculate ratio
        datatab{d}{i}(:,3)=datatab{d}{i}(:,2)-datatab{d}{i}(:,1);
    end
end


function [ConditionFiltered1,ConditionFiltered2] = findConditionalBadpoints(fil,nams,t,...
                                                                            signal,...
                                                                            background,...
                                                                            bbc,...
                                                                            signalStd,...
                                                                            backgroundStd)

% Subfunction to subtract elements BelowBackground factor for both channels
% bbc is scalar here, since the use of this function is internal so we don not perform any
% additional controls for its validity
% bbc is scalar for signal-to-noise, 1x2 vector for signal-noise distribution distance and
% a string for custom filter

if nargin<7
    signalStd=[];
    backgroundStd=[];
elseif nargin<8
    backgroundStd=[];
end

switch fil
    
    case 1 % Signal-to-Noise ratio
        for i=1:t
            for j=1:max(size(nams{i}))
                ConditionFiltered1{i}{j}=find(signal{i}{j}(:,1)./background{i}{j}(:,1)<bbc);
                ConditionFiltered2{i}{j}=find(signal{i}{j}(:,2)./background{i}{j}(:,2)<bbc);
            end
        end
    case 2 % Signal-Noise distribution distance
        for i=1:t
            for j=1:max(size(nams{i}))
                ConditionFiltered1{i}{j}=find(signal{i}{j}(:,1)+bbc(1)*signalStd{i}{j}(:,1)<...
                                         background{i}{j}(:,1)+bbc(2)*backgroundStd{i}{j}(:,1));
                ConditionFiltered2{i}{j}=find(signal{i}{j}(:,2)+bbc(1)*signalStd{i}{j}(:,2)<...
                                         background{i}{j}(:,2)+bbc(2)*backgroundStd{i}{j}(:,2));
            end
        end
    case 3 % Custom filter
        
        % Change multiplication and division symbols to MATLAB valids
        bbc=strrep(bbc,'*','.*');
        bbc=strrep(bbc,'/','./');
        
        % Find badpoints for channel 1        
        bbc=strrep(bbc,'SigMean','signal{i}{j}(:,1)');
        bbc=strrep(bbc,'BackMean','background{i}{j}(:,1)');
        bbc=strrep(bbc,'SigMedian','signal{i}{j}(:,1)');
        bbc=strrep(bbc,'BackMedian','background{i}{j}(:,1)');
        bbc=strrep(bbc,'SigStd','signalStd{i}{j}(:,1)');
        bbc=strrep(bbc,'BackStd','backgroundStd{i}{j}(:,1)');
        try
            for i=1:t
                for j=1:max(size(nams{i}))
                    ConditionFiltered1{i}{j}=eval(['find(' bbc ')']);
                end
            end
        catch
            uiwait(errordlg(lasterr,'Error'));
        end
        
        % Find badpoints for channel 2
        bbc=strrep(bbc,'(:,1)','(:,2)');
        try
            for i=1:t
                for j=1:max(size(nams{i}))
                    ConditionFiltered2{i}{j}=eval(['find(' bbc ')']);
                end
            end
        catch
            uiwait(errordlg(lasterr,'Error'));
        end
        
end


function [totbad totch1 totch2] = reprodTest(t,nams,datatab,bch1,bch2,bbp,settest,pv,dh,ht)

% Statistical test for spot measurement reproducibility

% Statistical test for replication significance
if ~isempty(ht)
    mainmsg=get(ht,'String');
    mainmsg=[mainmsg;' ';...
             'Replicate Statistical test is now running...';' '];
    set(ht,'String',mainmsg)
    drawnow;
else
    disp(' ')
    disp('Replicate Statistical test is now running...');
    disp(' ')
end

% Check for various wrong input cases of p-value cutoff
if ~isnumeric(pv)
    pv=0.05;
end
if length(pv)>1
    if length(pv)==t
        if ~all(pv>0 && pv<1)
            pv=0.05;
        end
    else
        wmsg=['p-value vector must be of length ',num2str(t)];
        uiwait(warndlg(wmsg,'Warning'));
        pv=0.05;
    end
end
if length(pv)==1
    if pv<0 || pv>1
        pv=0.05;
    end
    pv=repmat(pv,[1 t]);
end

for d=1:t
    for i=1:length(nams{d})
        ExpRepRatios{d}{i}=datatab{d}{i}(:,3);
    end
end

for d=1:t
    c2mExpRepRatios{d}=cell2mat(ExpRepRatios{d});
end

% Display a waitbar because this test takes toooooo long
hw=cwaitbar([0 0],{'Condition number - Progress','Reproducibility test - Progress'},{'r','b'});

% Statistical for replicates reaffirmation per Condition
if settest==1 % Wilcoxon
    pw=zeros(length(datatab{1}{1}),t);
    for i=1:t
        cwaitbar([1 i/t])
        for j=1:length(datatab{1}{1})
            %drawnow;
            cwaitbar([2 j/length(datatab{1}{1})])
            pw(j,i)=mysignrank(2.^c2mExpRepRatios{i}(j,:),2.^median(c2mExpRepRatios{i}(j,:)));
        end
    end
elseif settest==2 % t-test
    pt=zeros(length(datatab{1}{1}),t);
    for i=1:t
        cwaitbar([1 i/t])
        for j=1:length(datatab{1}{1})
            %drawnow;
            cwaitbar([2 j/length(datatab{1}{1})])
            [h,pt(j,i)]=ttest(2.^c2mExpRepRatios{i}(j,:),2.^mean(c2mExpRepRatios{i}(j,:)));
        end
    end
end

close(hw);

if dh
    % Create p-values vs Genes plurality histogram per Condition
    % for the Wilcoxon test an for the t-test
    lab=cell(1,t);
    if settest==1
        for y=1:t
            figure % Wilcoxon histogram
            hist(pw(:,y),0.1:0.01:0.99);
            xlabel('p-value')
            ylabel('Genes plurality');
            title('Wilcoxon');
            lab{y}=strcat('Condition - ',num2str(y),' - Replicates : ',num2str(length(nams{y})));
            set(gcf,'Name',lab{y})
        end
    elseif settest==2 % t-test histogram
        for y=1:t
            figure
            hist(pt(:,y),0.1:0.01:0.99);
            xlabel('p-value')
            ylabel('Genes plurality');
            title('t-test');
            lab{y}=strcat('Condition - ',num2str(y),' - Replicates : ',num2str(length(nams{y})));
            set(gcf,'Name',lab{y})
        end
    end
end

if settest==1
    p=pw;
elseif settest==2
    p=pt;
end

%View Total Badpoints
for d=1:t
    [StatRepBadpoints column]=find(p(:,d)<=pv(d));
    for i=1:length(nams{d})
        totbad{d}{i}=union(bbp{d}{i},StatRepBadpoints);
        totch1{d}{i}=union(bch1{d}{i},StatRepBadpoints);
        totch2{d}{i}=union(bch2{d}{i},StatRepBadpoints);
    end
end

for i=1:t
    for j=1:length(nams{i})
        TotalReplicateBadpoints(j,i)=length(totbad{i}{j});
    end
end

if ~isempty(ht)
    mainmsg=get(ht,'String');
    mainmsg=[mainmsg;' ';...
             'These are the total poor quality spots per Condiition and Replicate';...
             'Columns are the Conditions - Rows are the replicates';...
             '-----------------------------------------------------------';...
             num2str(TotalReplicateBadpoints);...
             '-----------------------------------------------------------';' '];
    set(ht,'String',mainmsg)
    drawnow;
else
    disp(' ')
    disp('These are the total poor quality spots per Condiition and Replicate')
    disp('Columns are the Conditions - Rows are the replicates')
    disp('-----------------------------------------------------------')
    disp(num2str(TotalReplicateBadpoints))
    disp('-----------------------------------------------------------')
    disp(' ')
end


function fout = cwaitbar(x,name,col)

% Very slight alterations of the function cwaitbar, writter from Rasmus Anthin and taken
% from MATLAB exchange

xline=[100 0 0 100 100];
yline=[0 0 1 1 0];

switch nargin
    case 1   % waitbar(x) update
        bar=x(1);
        x=max(0,min(100*x(2),100));
        f=findobj(allchild(0),'flat','Tag','CWaitbar');
        if ~isempty(f)
            f=f(1);
        end
        a=sort(get(f,'child')); % axes objects
        if isempty(f) || isempty(a),
            error('Couldn''t find waitbar handles.');
        end
        bar=length(a)+1-bar; % first bar is the topmost bar instead
        if length(a)<bar
            error('Bar number exceeds number of available bars.')
        end
        p=zeros(1,length(a));
        l=zeros(1,length(a));
        for i=1:length(a)
            p(i)=findobj(a(i),'type','patch');
            l(i)=findobj(a(i),'type','line');
        end
        p=p(bar);
        l=l(bar);
        xpatchold=get(p,'xdata');
        xold=xpatchold(2);
        if xold>x % erase old patches (if bar is shorter than before)
            set(p,'erase','normal')
        end
        xold=0;
        % previously: (continue on old patch)
        xpatch=[xold x x xold];
        set(p,'xdata',xpatch,'erase','none')
        set(l,'xdata',xline) 
    case 2   % waitbar(x,name)  initialize   
        x=fliplr(max(0,min(100*x,100)));
        oldRootUnits=get(0,'Units');
        set(0,'Units','points');
        pos=get(0,'ScreenSize');
        pointsPerPixel=72/get(0,'ScreenPixelsPerInch');
        L=length(x)*.6+.4;
        width =360*pointsPerPixel;
        height=75*pointsPerPixel*L;
        pos=[pos(3)/2-width/2 pos(4)/2-height/2 width height];
        f=figure('Units','points', ...
                  'Position', pos, ...
                  'Resize','off', ...
                  'CreateFcn','', ...
                  'NumberTitle','off', ...
                  'IntegerHandle','off', ...
                  'MenuBar', 'none', ...
                  'Tag','CWaitbar',...
                  'Name','Measurement reproducibility test - Overall progress');
        colormap([]);
        for i=1:length(x)
            h=axes('XLim',[0 100],'YLim',[0 1]);
            if ~iscell(name)
                if i==length(x)
                    title(name,'FontSize',8);
                end
            else
                if length(name)~=length(x)
                    error('There must be equally many titles as waitbars, or only one title.')
                end
                title(name{end+1-i},'FontSize',8)
            end
            set(h,'Box','on', ...
                  'Position',[.05 .3/L*(2*i-1) .9 .2/L],...
                  'XTickMode','manual',...
                  'YTickMode','manual',...
                  'XTick',[],...
                  'YTick',[],...
                  'XTickLabelMode','manual',...
                  'XTickLabel',[],...
                  'YTickLabelMode','manual',...
                  'YTickLabel',[]);
            xpatch=[0 x(i) x(i) 0];
            ypatch=[0 0 1 1];
            patch(xpatch,ypatch,'r','edgec','r','erase','none')
            line(xline,yline,'color','k','erase','none');
        end  
        set(f,'HandleVisibility','callback');
        set(0, 'Units', oldRootUnits);
    case 3
        if iscell(col) && length(col)~=length(x)
            error('There must be equally many colors as waitbars, or only one color.')
        end
        f=cwaitbar(x,name);
        a=get(f,'child');
        p=findobj(a,'type','patch');
        l=findobj(a,'type','line');
        if ~iscell(col)
            set(p,'facec',col,'edgec',col)
        else
            for i=1:length(col)
                set(p(i),'facec',col{i},'edgec',col{i})
            end
        end
        set(l,'xdata',xline')
end
drawnow
figure(f)
if nargout==1,
    fout=f;
end
