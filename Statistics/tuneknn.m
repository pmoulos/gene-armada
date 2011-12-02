function tuneknn(data,clg,varargin)

%
% Function to perform tuning (and evaluation) of knn classifier given data matrix and
% class vectors. This function uses knnclassify and crossvalind. For further help please 
% see help on the functions knnclassify and crossvalind of the Bioinformatics Toolbox.
%
% TUNEKNN performs several rounds of classification for several values of nearest neigbors
% different distances and ties breaking rules. It also validates the results using n-fold
% cross validation, training and test and leave m out strategies. The results are
% displayed in the form of text or plots and the user can decide.
%
% Syntax:
% ---------------------------
%
% ?=tuneknn(data,clg)
% ?=tuneknn(data,clg,'PropertyName',PropertyValue)
%
% Arguments:
%
% data : A data marix where rows represent samples or observations and columns variables
%        or features.        
% clg  : A vector of classes. It can be a numeric array or cell array of strings. See
%        knnclassify for more details.
%
% PropertyName   PropertyValue                                                  
% -----------------------------------------------------------------------------
% NNRange        : The range of nearest neighbors to use for determining the best.
%                  Defaults to 1:10.
%
% Distances      : A cell array of strings containing distance metrics to be used. See
%                  knnclassify for supported metrics.
%
% Rules          : A cell array of strings containing tie breaking rules to be used. See
%                  knnclassify for supported rules.
%
% ValidMethods   : Validation method to be used for the evaluation of classifier. See
%                  crossvalind for more details. Note that currently the crossvalind
%                  option 'Resubstitution' is not implemented.
%
% ValidParams    : Values for each validation method used. Pay attention so as the order
%                  of the given parameters is the same as the order of the methods given.
%                  See crossvalind for more details. The default values are the same.
%
% ShowPlots      : Display evaluation plots for the classifier.
%                  Values : true (default)
%                           false
%
% ShowResults    : Display summary results at the end of the procedure
%                  Values : true (default)
%                           false
%
% UseWaitbar     : Display a multiple waitbar to show the progress for each step of the
%                  validation. This feature uses the cwaitbar function implemented by
%                  Rasmus Anthin taken from MATLAB exchange and very slightly modified.
%                  Values : true (default)
%                           false
%
% Verbose        : Display verbose messages.
%                  Values : true
%                           false (default)
%
%
% Outputs : A report (command window or report window if available) containing several
%           statistics on classification tuning results
%
%
% Example 1 :
% 
% z=rand(100,100);
% z(51:100,:)=z(51:100,:)+0.5*rand(1);
% c=[repmat(0,[50 1]);repmat(1,[50 1])];
% tuneknn(z,c,'NNRange',1:10,...
%             'Distances',{'euclidean','cityblock','correlation','cosine'},...
%             'Rules',{'nearest','random'},...
%             'ValidMethods',{'kfold','leavemout','holdout'},...
%             'ValidParams',[10,1,0.4],...
%             'UseWaitbar',true,...
%             'Verbose',false,...
%             'ShowPlots',true)
% 
% Example 2 : 
% 
% z=rand(100,100);
% z(33:66,:)=z(33:66,:)+0.5*rand(1);
% z(67:100,:)=z(67:100,:)+rand(1);
% c=cellstr([repmat('Class1',[33 1]);repmat('Class2',[33 1]);repmat('Class3 ',[33 1])]);
% tuneknn(z,c,'NNRange',1:3,...
%             'Distances',{'euclidean','correlation'},...
%             'Rules',{'nearest','random'},...
%             'ValidMethods',{'kfold','leavemout','holdout'},...
%             'ValidParams',[10,1,0.4],...
%             'UseWaitbar',true,...
%             'Verbose',true)
% 
% See also : KNNCLASSIFY, CROSSVALIND, GRP2IDX
%

% Author        : Panagiotis Moulos (pmoulos@eie.gr)
% First created : March 15, 2008
% Last modified : -
% 
% This function uses a slightly modified version of the following function taken from
% MATLAB exchange:
% CWAITBAR by Rasmus Anthin (File Id: 4121)

% Set defaults
kr=1:10; 
distances={'euclidean'};
rules={'nearest'};
validmethods={'kfold'};
validparams=5;
showplots=false;
showresults=true;
usewaitbar=true;
verbose=false;

% Check various input arguments
if length(varargin)>1
    valok=true; % To be used to exclude validation parameters in case of problem with methods
    if rem(nargin,2)~=0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'nnrange','distances','rules','validmethods','validparams',...
            'showplots','showresults','usewaitbar','verbose'};
    for i=1:2:length(varargin)-1
        parName=varargin{i};
        parVal=varargin{i+1};
        j=strmatch(lower(parName),okargs);
        if isempty(j)
            error('Unknown parameter name: %s.',parName);
        elseif length(j)>1
            error('Ambiguous parameter name: %s.',parName);
        else
            switch(j)
                case 1 % Range of k in kNN
                    if ~isnumeric(parVal) || ~all(rem(parVal,1)==0)
                        error('The %s parameter value must be a vector of integers.',parName)
                    else
                        kr=parVal;
                    end
                case 2 % Distance metrics
                    okmets={'euclidean','cityblock','cosine','correlation','hamming'};
                    if ~iscell(parVal)
                        error('The %s parameter value must be a cell array of strings argument. See help.',parName)
                    else
                        matches=cell(1,length(parVal));
                        keepd=true(1,length(parVal));
                        for k=1:length(parVal)
                            matches{k}=strmatch(lower(parVal{k}),okmets,'exact');
                            if isempty(matches{k})
                                warning('TunekNN:UnknownDistance',['The distance ',parVal{k},...
                                        'is unknown and will be ignored.']);
                                keepd(k)=false;
                            elseif length(matches{k})>1
                                warning('TunekNN:AmbiguousDistance',['The distance ',parVal{k},' appears',...
                                        'more that once. Only the first appearance will be considered.']);
                                keepd(matches{k}(2:end))=false;
                            end
                        end
                        parVal=parVal(keepd);
                        if isempty(parVal)
                            error('Please provide valid arguments to parameter %s',parName)
                        else
                            distances=parVal;
                        end
                    end
                case 3 % Rules
                    okrulz={'nearest','random','consensus'};
                    if ~iscell(parVal)
                        error('The %s parameter value must be a cell array of strings. See help.',parName)
                    else
                        matches=cell(1,length(parVal));
                        keepr=true(1,length(parVal));
                        for k=1:length(parVal)
                            matches{k}=strmatch(lower(parVal{k}),okrulz,'exact');
                            if isempty(matches{k})
                                warning('TunekNN:UnknownRule',['The rule ',parVal{k},...
                                        'is unknown and will be ignored.']);
                                keepr(k)=false;
                            elseif length(matches{k})>1
                                warning('TunekNN:AmbiguousRule',['The rule ',parVal{k},' appears',...
                                        'more that once. Only the first appearance will be considered.']);
                                keepr(matches{k}(2:end))=false;
                            end
                        end
                        parVal=parVal(keepr);
                        if isempty(parVal)
                            error('Please provide valid arguments to parameter %s',parName)
                        else
                            rules=parVal;
                        end
                    end
                case 4 % Validation models
                    okmods={'kfold','leavemout','holdout'};
                    if ~iscell(parVal)
                        error('The %s parameter value must be a cell array of strings argument. See help.',parName)
                    else
                        matches=cell(1,length(parVal));
                        keepv=true(1,length(parVal));
                        for k=1:length(parVal)
                            matches{k}=strmatch(lower(parVal{k}),okmods,'exact');
                            if isempty(matches{k})
                                warning('TunekNN:UnknownMethod',['The validation method ',...
                                        parVal{k},'is unknown and will be ignored.']);
                                keepv(k)=false;
                                valok=false;
                            elseif length(matches{k})>1
                                warning('TunekNN:AmbiguousMethod',['The validation method ',parVal{k},' appears',...
                                        'more that once. Only the first appearance will be considered.']);
                                keepv(matches{k}(2:end))=false;
                                valok=false;
                            end
                        end
                        parVal=parVal(keepv);
                        if isempty(parVal)
                            error('Please provide valid arguments to parameter %s',parName)
                        else
                            validmethods=parVal;
                        end
                    end
                case 5 % Validation method parameters
                    if ~isnumeric(parVal)
                        error('The %s parameter value must be a numeric vector. See help.',parName)
                    elseif ~valok % boolean vector keepv must have been created
                        validparams=parVal(keepv);
                    else
                        validparams=parVal;
                    end                        
                case 6 % Show evaluation plots
                    if ~islogical(parVal)
                        error('The %s parameter value must be true or false.',parName)
                    else
                        showplots=parVal;
                    end
                case 7 % Show evaluation results
                    if ~islogical(parVal)
                        error('The %s parameter value must be true or false.',parName)
                    else
                        showresults=parVal;
                    end
                case 8 % Use waitbar
                    if ~islogical(parVal)
                        error('The %s parameter value must be true or false.',parName)
                    else
                        usewaitbar=parVal;
                    end
                case 9 % Display verbose messages
                    if ~islogical(parVal)
                        error('The %s parameter value must be true or false.',parName)
                    else
                        verbose=parVal;
                    end
            end
        end
    end
end

% Start process

% Vectorize class array and convert to class numeric ids if cell
clg=clg(:);
% if ~isnumeric(clg) && ~islogical(clg)
%     txt=true;
[cl,cln]=grp2idx(clg);
% else
%     txt=false;
%     cl=clg;
% end
% Lower parameter names
validmethods=lower(validmethods);
distances=lower(distances);
rules=lower(rules);
% Create validation methods names for good visualization purposes
if verbose || showplots || showresults
    validnames=cell(1,length(validmethods));
    for i=1:length(validmethods)
        switch validmethods{i}
            case 'kfold'
                validnames{i}=[num2str(validparams(i)),'-fold cross validation'];
            case 'leavemout'
                validnames{i}=['leave-',num2str(validparams(i)),'-out validation'];
            case 'holdout'
                validnames{i}=['training and test split : ',num2str(100*(1-validparams(i))),...
                               '% training and ',num2str(100*(validparams(i))),'% test'];
        end
    end
end

% % Initialize classifier performance object
% cp=classperf(cl);

% Initialize waitbar
if usewaitbar
    h=cwaitbar([0 0 0 0],{'Number of Nearest Neighbors - Progress',...
               'Distance metric - Progress','Classification rule - Progress',...
               'Classifier evaluation method - Progress'},...
               {'b','r','g','y'});
end

% Initialize the misclassification error matrix, for all validation, distance, rule and ks
mise=zeros(length(kr),length(distances),length(rules),length(validmethods));
conf=cell(length(kr),length(distances),length(rules),length(validmethods));

% 1st loop : number of NNs
for m=1:length(kr)

    if verbose
        disp(' ')
        outmsg=['Number of nearest neighbors : ',num2str(kr(m))];
        disp(outmsg)
        disp('############################################################')
        disp(' ')
    end
    
    if usewaitbar
        cwaitbar([1 m/length(kr)])
    end
    
    % 2nd loop : distance metric
    for n=1:length(distances)

        if verbose
            outmsg=['Distance metric : ',distances{n}];
            disp(' ')
            disp(outmsg)
            disp('------------------------------------------------------------')
            disp(' ')
        end
        
        if usewaitbar
            cwaitbar([2 n/length(distances)])
        end
        
        % 2nd loop : classification rule
        for p=1:length(rules)

            if verbose
                outmsg=['Classification rule : ',rules{p}];
                disp(' ')
                disp(outmsg)
                disp('============================================================')
                disp(' ')
            end

            if usewaitbar
                cwaitbar([3 p/length(rules)])
            end
            
            % % Here we initialize the classifier performance object
            %cp=classperf(cl);
            % % We will not use the classperf object, time consuming without purpose
            
            % 4th loop : validation method
            for q=1:length(validmethods)

                if verbose
                    outmsg=['Classifier evaluation method : ',validnames{q},...
                            ' - parameter : ',num2str(validparams(q))];
                    disp(outmsg)
                end

                if usewaitbar
                    cwaitbar([4 q/length(validmethods)])
                end

                switch validmethods{q}
                    case 'kfold'
                        indices=crossvalind(validmethods{q},cl,validparams(q));
                        clnew=zeros(length(cl),1);
                        for i=1:validparams(q)
                            test=indices==i;
                            train=~test;
                            % Classify
                            clnew(test)=knnclassify(data(test,:),data(train,:),cl(train),kr(m),....
                                                    distances{n},rules{p});
                            % % Update classperf object
                            %classperf(cp,clnew,test);
                        end
                        [mise(m,n,p,q),conf{m,n,p,q}]=errmeas(cln(clnew),cln(cl));
                    case 'leavemout'
                        clnew=zeros(length(cl),1);
                        lo=validparams(q);
                        f=floor(length(cl)/lo);
                        r=rem(length(cl),lo);
                        for i=1:f
                            indices=lo*(i-1)+1:lo*i;
                            test=false(length(cl),1);
                            test(indices)=true;
                            train=~test;
                            % Classify
                            clnew(test)=knnclassify(data(test,:),data(train,:),cl(train),kr(m),....
                                                    distances{n},rules{p});
                            % % Update classperf object
                            %classperf(cp,clnew,test);
                        end
                        if r~=0 % Use also the rest of the indices up to length(cl)
                            indices=lo*f+1:length(cl);
                            test=false(length(cl),1);
                            test(indices)=true;
                            train=~test;
                            % Classify
                            clnew(test)=knnclassify(data(test,:),data(train,:),cl(train),kr(m),....
                                                    distances{n},rules{p});
                            % % Update classperf object
                            %classperf(cp,clnew,test);
                        end
                        [mise(m,n,p,q),conf{m,n,p,q}]=errmeas(cln(clnew),cln(cl));
                        
                    case 'holdout'
                        %clnew=zeros(length(cl),1);
                        [train,test]=crossvalind(validmethods{q},cl,validparams(q));
                        % Classify
                        clnew=knnclassify(data(test,:),data(train,:),cl(train),kr(m),...
                                          distances{n},rules{p});
                        % % Update classperf object
                        %classperf(cp,clnew,test);
                        [mise(m,n,p,q),conf{m,n,p,q}]=errmeas(cln(clnew),cln(cl(test)));
                end
                
                % Update mislcassification error matrix
                %mise(m,n,p,q)=cp.ErrorRate;
                %mise(m,n,p,q)=mean(clnew~=cl);
                %if ~txt
                %    [ctab,conf{m,n,p,q}]=conftable(clnew,cl,'matrix',false);
                %else
                %    [ctab,conf{m,n,p,q}]=conftable(cln(clnew),cln(cl),'matrix',false);
                %end

            end
            
        end
        
    end
    
end

if usewaitbar
    close(h)
end

% Create evaluation figures
if showplots
    for i=1:length(validmethods)
        f=figure;
        %[l,b,w,h]=createGrid(1,length(rules));
        for j=1:length(rules)
            ha=zeros(1,length(distances));
            hs=zeros(1,length(distances));
            %ha(j)=subplot('Position',[l(j),b(j),w(j),h(j)]);
            ha(j)=subplot(length(rules),1,j);
            hold on
            for k=1:length(distances)
                hs(k)=plot(kr,mise(:,k,j,i),'.-','Color',rand(1,3),...
                                                 'LineWidth',2,...
                                                 'MarkerSize',15);
            end
            grid on
            set(ha(j),'FontSize',9,'FontWeight','bold','XTick',1:length(kr))
            title(['Misclassification error using rule : ',rules{j}],'FontSize',11,...
                                                                     'FontWeight','bold')
            xlabel('Number of Nearest Neighbors','FontSize',10,'FontWeight','bold')
            ylabel('Misclassification Error','FontSize',10,'FontWeight','bold')
            legend(hs,distances);
        end
        set(f,'Name',['Classifier evaluation method : ',validnames{i}])
    end
end

% % Display results - command line
% if showresults
%     accper=100*(1-mise); % Accuracy percentage
%     disp(' ')
%     disp('kNN classifier tuning results')
%     disp('============================================================')
%     disp(' ')
%     disp(['Dataset information : Observations - ',num2str(size(data,1)),...
%           ', Variables - ',num2str(size(data,2)),', #Classes - ',num2str(length(unique(cl)))])
%     disp('------------------------------------------------------------')
%     disp(' ')
%     for m=1:length(validmethods)
%         disp(['Classification results using ',validnames{m}])
%         disp('------------------------------------------------------------')
%         disp(' ')
%         for n=1:length(rules)
%             disp(['Classification results using ',rules{n},' classifying rule'])
%             disp('------------------------------------------------------------')
%             disp(' ')
%             for p=1:length(distances)
%                 disp(['Classification results using ',distances{p},' distance'])
%                 disp('------------------------------------------------------------')
%                 disp(' ')
%                 for q=1:length(kr)
%                     disp(['Number of nearest neighbors : ',num2str(kr(q))])
%                     disp(['Misclasification error  : ',num2str(mise(q,p,n,m))])
%                     disp(['Classification accuracy : ',num2str(accper(q,p,n,m)),'%'])
%                     disp(' ')
%                 end
%             end
%         end
%     end
% end

% Display results - create a cell to be displayed in the report window
if showresults
    accper=100*(1-mise); % Accuracy percentage
    main={' ';...
          'kNN classifier tuning results';...
          '==================================================';...
          ' ';...
          'Dataset information : ';...
          ['Observations : ',num2str(size(data,1))];...
          ['Variables : ',num2str(size(data,2))];...
          ['Number of classes : ',num2str(length(unique(cl)))];...
          '--------------------------------------------------';...
          ' '};
    repcell=cell(3*length(validmethods)+3*length(rules)+3*length(distances)+5*length(kr),1);
    ind=0;
    for m=1:length(validmethods)
        ind=ind+1;
        repcell{ind}=['Classification results using ',validnames{m}];
        repcell{ind+1}='--------------------------------------------------';
        repcell{ind+2}=' ';
        ind=ind+2;
        for n=1:length(rules)
            ind=ind+1;
            repcell{ind}=['Classification results using ',rules{n},' classifying rule'];
            repcell{ind+1}='--------------------------------------------------';
            repcell{ind+2}=' ';
            ind=ind+2;
            for p=1:length(distances)
                ind=ind+1;
                repcell{ind}=['Classification results using ',distances{p},' distance'];
                repcell{ind+1}='--------------------------------------------------';
                repcell{ind+2}=' ';
                ind=ind+2;
                for q=1:length(kr)
                    ind=ind+1;
                    repcell{ind}=['Number of nearest neighbors : ',num2str(kr(q))];
                    repcell{ind+1}=['Misclasification error  : ',num2str(mise(q,p,n,m))];
                    repcell{ind+2}=['Classification accuracy : ',num2str(accper(q,p,n,m)),'%'];
                    repcell{ind+3}='Confusion table : ';
                    repcell{ind+4}=conf{q,p,n,m};
                    repcell{ind+5}=' ';
                    ind=ind+5;
                end
            end
        end
    end
    final=[main;repcell];
    %disp(char(final))
    GenericReport(final,'kNN Classifier Tuning Results')
end


function [me,cm] = errmeas(cn,co)

if iscell(cn)
    me=mean(~strcmpi(cn,co));
else
    me=mean(cn~=co);
end
[ctab,cm]=conftable(cn,co,'matrix',false);
                

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

        f = figure('Units','points', ...
                   'Position', pos, ...
                   'Resize','off', ...
                   'CreateFcn','', ...
                   'NumberTitle','off', ...
                   'IntegerHandle','off', ...
                   'MenuBar', 'none', ...
                   'Tag','CWaitbar',...
                   'Name','Classifier Tuning - Overall progress');
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
