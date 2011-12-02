function tunesvm(data,clg,varargin)

%
% Function to perform tuning (and evaluation) of suport vector machines classifier given 
% data matrix and class vectors. This function uses the OSU SVM Toolbox
% (http://sourceforge.net/projects/svm/) and the function crossvlind. For further help 
% please see help of the OSU SVM Toolbox and the function crossvalind of the 
% Bioinformatics Toolbox.
%
% TUNESVM performs several rounds of classification for several types of support vector
% kernels and kernel parameter sets. It also validates the results using n-fold
% cross validation, training and test and leave m out strategies. The results are
% displayed in the form of text or plots and the user can decide.
%
% Note: The OSU SVM Toolbox can handle multiclass datasets.
%
% Syntax:
% ---------------------------
%
% ?=tunesvm(data,clg)
% ?=tunesvm(data,clg,'PropertyName',PropertyValue)
%
% Arguments:
%
% data : A data marix where rows represent samples or observations and columns variables
%        or features.        
% clg  : A vector of classes. It can be a numeric array or cell array of strings. See
%        the OSU SVM Toolbox for more details.
%
% PropertyName   PropertyValue                                                  
% -----------------------------------------------------------------------------
% Kernel         : A vector containing SVM kernel tyoes. For further details please see 
%                  the help of the OSU SVM Toolbox. Briefly, kernels can be 'linear',
%                  'polynomial', 'rbf' or 'mlp'                   
%
% Parameters     : A cell containing cells of vectors of kernel type parameters. For
%                  further help please consult the OSU SVM Toolbox
%
% Normalize      : Normalize input data matrix to have mean 0 and standard deviation 1
%                  Values : true
%                           false (default)
%
% Scale          : Scale input data matrix so that all data values lie between a given
%                  range
%                  Values : true
%                           false (default)
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
% tunesvm(z,c,'Kernel',{'linear','polynomial','rbf','mlp'},...
%             'Parameters',{{[]},...
%                           {[1 0 3],[1 0 4],[1 0 5],[1 1 3],[1 2 4],[1 3 5]},...
%                           {1,2,3,4,5},...
%                           {[1 3],[1 4],[1 5],[2 3]}},...
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
% tunesvm(z,c,'Kernel',{'polynomial','rbf','mlp'},...
%             'Parameters',{{[1 0 3],[1 0 4],[1 0 5],[1 1 3],[1 2 4],[1 3 5]},...
%                           {1,2,3,4,5,6},...
%                           {[1 3],[1 4],[1 5],[2 3],[2 4],[2 5]}},...
%             'ValidMethods',{'kfold','leavemout','holdout'},...
%             'ValidParams',[10,1,0.4],...
%             'UseWaitbar',true,...
%             'Verbose',true,...
%             'ShowPlots',true)
%
% See also : CROSSVALIND, GRP2IDX
%

% Author        : Panagiotis Moulos (pmoulos@eie.gr)
% First created : March 19, 2008
% Last modified : -
% 
% This function uses a slightly modified version of the following function taken from
% MATLAB exchange:
% CWAITBAR by Rasmus Anthin (File Id: 4121)
% SVM classification is based on the OSU SVM Toolbox which can be downloaded from
% http://sourceforge.net/projects/svm/

% Set defaults
kernels={'linear'};
params={[]};
nrmlz=false;
scl=false;
validmethods={'kfold'};
validparams=5;
showplots=false;
showresults=true;
usewaitbar=true;
verbose=false;
kchanged=false; % Help flag to check kernel-parameters integrity

% Check various input arguments
if length(varargin)>1
    valok=true; % To be used to exclude validation parameters in case of problem with methods
    if rem(nargin,2)~=0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'kernel','parameters','normalize','scale','validmethods','validparams',...
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
                case 1 % SVM kernel type
                    okkers={'linear','polynomial','mlp','rbf'};
                    if ~iscell(parVal)
                        error('The %s parameter value must be a cell array of strings argument. See help.',parName)
                    else
                        matches=cell(1,length(parVal));
                        keepk=true(1,length(parVal));
                        for k=1:length(parVal)
                            matches{k}=strmatch(lower(parVal{k}),okkers,'exact');
                            if isempty(matches{k})
                                warning('TuneSVM:UnknownKernel',['The kernel function type ',parVal{k},...
                                        'is unknown and will be ignored with the corresponding parameters.']);
                                keepk(k)=false;
                            elseif length(matches{k})>1
                                warning('TuneSVM:AmbiguousKernel',['The kernel function type ',parVal{k},...
                                        ' appears more that once. Only the first appearance will be considered.']);
                                keepk(matches{k}(2:end))=false;
                            end
                        end
                        parVal=parVal(keepk);
                        if isempty(parVal)
                            error('Please provide valid arguments to parameter %s',parName)
                        else
                            kernels=parVal;
                            kchanged=true;
                        end
                    end
                case 2 % Kernel parameters
                    if ~iscell(parVal)
                        error('The %s parameter value must be a cell array. See help.',parName)
                    else
                        % Remove parameters of possibly removed kernel
                        if kchanged
                            parVal=parVal(keepk);
                        end
                        keepp=true(1,length(parVal));
                        for k=1:length(parVal)
                            if ~iscell(parVal{k}) && ~isvector(parVal{k})
                                warning('TuneSVM:UnknownParameter',['The kernel parameters ',parVal{k},...
                                        ' are unknown and will be ignored with the corresponding kernel.']);
                                keepp(k)=false;
                            end
                        end
                        parVal=parVal(keepp);
                        try
                            kernels=kernels(keepp);
                        catch
                            error('The kernels and kernel parameters cells should have the same length.')
                        end
                        if isempty(parVal)
                            error('Please provide valid arguments to parameter %s',parName)
                        else
                            params=parVal;
                        end
                    end
                case 3 % Normalize data matrix
                    if ~islogical(parVal)
                        error('The %s parameter value must be true or false.',parName)
                    else
                        nrmlz=parVal;
                    end
                case 4 % Scale data matrix
                    if ~islogical(parVal)
                        error('The %s parameter value must be true or false.',parName)
                    else
                        scl=parVal;
                    end
                case 5 % Validation models
                    okmods={'kfold','leavemout','holdout'};
                    if ~iscell(parVal)
                        error('The %s parameter value must be a cell array of strings argument. See help.',parName)
                    else
                        matches=cell(1,length(parVal));
                        keepv=true(1,length(parVal));
                        for k=1:length(parVal)
                            matches{k}=strmatch(lower(parVal{k}),okmods,'exact');
                            if isempty(matches{k})
                                warning('TuneSVM:UnknownMethod',['The validation method ',...
                                        parVal{k},'is unknown and will be ignored.']);
                                keepv(k)=false;
                                valok=false;
                            elseif length(matches{k})>1
                                warning('TuneSVM:AmbiguousMethod',['The validation method ',parVal{k},' appears',...
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
                case 6 % Validation method parameters
                    if ~isnumeric(parVal)
                        error('The %s parameter value must be a numeric vector. See help.',parName)
                    elseif ~valok % boolean vector keepv must have been created
                        validparams=parVal(keepv);
                    else
                        validparams=parVal;
                    end                        
                case 7 % Show evaluation plots
                    if ~islogical(parVal)
                        error('The %s parameter value must be true or false.',parName)
                    else
                        showplots=parVal;
                    end
                case 8 % Show evaluation results
                    if ~islogical(parVal)
                        error('The %s parameter value must be true or false.',parName)
                    else
                        showresults=parVal;
                    end
                case 9 % Use waitbar
                    if ~islogical(parVal)
                        error('The %s parameter value must be true or false.',parName)
                    else
                        usewaitbar=parVal;
                    end
                case 10 % Display verbose messages
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

% Convert class array to row vector and convert to class numeric ids if cell
[cl,cln]=grp2idx(clg);
cl=cl(:);
cl=cl';
% Transpose data matrix required for OSU SVM Toolbox
data=data';
% Normalize and scale (if chosen)
if nrmlz
    data=NormalizeMatrix(data);
end
if scl
    data=ScaleMatrix(data);
end
% Lower validation method names
validmethods=lower(validmethods);

% % Create kernels vector
% kervec=zeros(1,length(kernels));
% for i=1:length(kernels)
%     switch kernels{i}
%         case 'linear'
%             kervec(i)=0;
%         case 'polynomial'
%             kervec(i)=1;
%         case 'rbf'
%             kervec(i)=2;
%         case 'mlp'
%             kervec(i)=3;
%     end
% end

if verbose || showresults || showplots 
    % Create kernel names for better visualization
    kernames=cell(1,length(kernels));
    for i=1:length(kernels)
        switch kernels{i}
            case 'linear'
                kernames{i}='Linear';
            case 'polynomial'
                kernames{i}='Polynomial';
            case 'rbf'
                kernames{i}='Radial Basis Function (RBF)';
            case 'mlp'
                kernames{i}='Sigmoid - MultiLayer Perceptron (MLP)';
        end
    end
    % Create validation methods names for better visualization
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
                
% Initialize waitbar
if usewaitbar
    h=cwaitbar([0 0 0],{'Kernel function type - Progress',...
                        'Kernel parameter set - Progress',...
                        'Classifier evaluation method - Progress'},...
               {'b','r','g'});
end

% Initialize the misclassification error matrix, for all validation, kernel type and
% parameter set
mise=cell(length(kernels),length(params),length(validmethods));
conf=cell(length(kernels),length(params),length(validmethods));

% 1st loop : kernel type
for m=1:length(kernels)

    if verbose
        disp(' ')
        outmsg=['Kernel function type : ',kernames{m}];
        disp(outmsg)
        disp('############################################################')
        disp(' ')
    end
    
    if usewaitbar
        cwaitbar([1 m/length(kernels)])
    end
    
    % 2nd loop : kernel parameter sets
    for n=1:length(params{m})

        if verbose
            switch kernels{m}
                case 'linear'
                    outmsg='Kernel parameter set : none, linear kernel';
                case 'polynomial'
                    outmsg=['Kernel parameter set : ','Gamma: ',num2str(params{m}{n}(1)),...
                            ' Coeficient: ',num2str(params{m}{n}(2)),...
                            ' Degree: ',num2str(params{m}{n}(3))];
                case 'rbf'
                    outmsg=['Kernel parameter set : ','Gamma: ',num2str(params{m}(n))];
                case 'mlp'
                    outmsg=['Kernel parameter set : ','Gamma: ',num2str(params{m}{n}(1)),...
                            ' Coeficient: ',num2str(params{m}{n}(2))];
            end
            disp(' ')
            disp(outmsg)
            disp('------------------------------------------------------------')
            disp(' ')
        end
        
        if usewaitbar
            cwaitbar([2 n/length(params{m})])
        end
            
        % 3rd loop : validation method
        for q=1:length(validmethods)

            if verbose
                outmsg=['Classifier evaluation method : ',validnames{q},...
                        ' - parameter : ',num2str(validparams(q))];
                disp(outmsg)
            end

            if usewaitbar
                cwaitbar([3 q/length(validmethods)])
            end

            switch validmethods{q}
                case 'kfold'
                    indices=crossvalind(validmethods{q},cl,validparams(q));
                    clnew=zeros(length(cl),1);
                    for i=1:validparams(q)
                        test=indices==i;
                        train=~test;
                        % Classify
                        switch kernels{m}
                            case 'linear'
                                [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=...
                                    LinearSVC(data(:,train),cl(train));
                                clnew(test)=...
                                    SVMClass(data(:,test),AlphaY,SVs,Bias,Parameters,nSV,nLabel);
                            case 'polynomial'
                                g=params{m}{n}(1);
                                c=params{m}{n}(2);
                                d=params{m}{n}(3);
                                [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=...
                                    PolySVC(data(:,train),cl(train),d,1,g,c);
                                clnew(test)=...
                                    SVMClass(data(:,test),AlphaY,SVs,Bias,Parameters,nSV,nLabel);
                            case 'rbf'
                                g=params{m}(n);
                                [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=...
                                    RbfSVC(data(:,train),cl(train),g);
                                clnew(test)=...
                                    SVMClass(data(:,test),AlphaY,SVs,Bias,Parameters,nSV,nLabel);
                            case 'mlp'
                                g=params{m}{n}(1);
                                c=params{m}{n}(2);
                                [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=...
                                    MlpSVC(data(:,train),cl(train),g,c);
                                clnew(test)=...
                                    SVMClass(data(:,test),AlphaY,SVs,Bias,Parameters,nSV,nLabel);
                        end
                    end
                    % Update misclassification error matrix
                    clnew=clnew';
                    [mise{m,n,q},conf{m,n,q}]=errmeas(cln(clnew),cln(cl));
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
                        switch kernels{m}
                            case 'linear'
                                [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=...
                                    LinearSVC(data(:,train),cl(train));
                                clnew(test)=...
                                    SVMClass(data(:,test),AlphaY,SVs,Bias,Parameters,nSV,nLabel);
                            case 'polynomial'
                                g=params{m}{n}(1);
                                c=params{m}{n}(2);
                                d=params{m}{n}(3);
                                [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=...
                                    PolySVC(data(:,train),cl(train),d,1,g,c);
                                clnew(test)=...
                                    SVMClass(data(:,test),AlphaY,SVs,Bias,Parameters,nSV,nLabel);
                            case 'rbf'
                                g=params{m}(n);
                                [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=...
                                    RbfSVC(data(:,train),cl(train),g);
                                clnew(test)=...
                                    SVMClass(data(:,test),AlphaY,SVs,Bias,Parameters,nSV,nLabel);
                            case 'mlp'
                                g=params{m}{n}(1);
                                c=params{m}{n}(2);
                                [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=...
                                    MlpSVC(data(:,train),cl(train),g,c);
                                clnew(test)=...
                                    SVMClass(data(:,test),AlphaY,SVs,Bias,Parameters,nSV,nLabel);
                        end
                    end
                    if r~=0 % Use also the rest of the indices up to length(cl)
                        indices=lo*f+1:length(cl);
                        test=false(length(cl),1);
                        test(indices)=true;
                        train=~test;
                        % Classify
                        switch kernels{m}
                            case 'linear'
                                [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=...
                                    LinearSVC(data(:,train),cl(train));
                                clnew(test)=...
                                    SVMClass(data(:,test),AlphaY,SVs,Bias,Parameters,nSV,nLabel);
                            case 'polynomial'
                                g=params{m}{n}(1);
                                c=params{m}{n}(2);
                                d=params{m}{n}(3);
                                [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=...
                                    PolySVC(data(:,train),cl(train),d,1,g,c);
                                clnew(test)=...
                                    SVMClass(data(:,test),AlphaY,SVs,Bias,Parameters,nSV,nLabel);
                            case 'rbf'
                                g=params{m}(n);
                                [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=...
                                    RbfSVC(data(:,train),cl(train),g,c);
                                clnew(test)=...
                                    SVMClass(data(:,test),AlphaY,SVs,Bias,Parameters,nSV,nLabel);
                            case 'mlp'
                                g=params{m}{n}(1);
                                c=params{m}{n}(2);
                                [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=...
                                    MlpSVC(data(:,train),cl(train),g,c);
                                clnew(test)=...
                                    SVMClass(data(:,test),AlphaY,SVs,Bias,Parameters,nSV,nLabel);
                        end
                    end
                    % Update misclassification error matrix
                    clnew=clnew';
                    [mise{m,n,q},conf{m,n,q}]=errmeas(cln(clnew),cln(cl));
                case 'holdout'
                    [train,test]=crossvalind(validmethods{q},cl,validparams(q));
                    % Classify
                    switch kernels{m}
                        case 'linear'
                            [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=...
                                LinearSVC(data(:,train),cl(train));
                            clnew=SVMClass(data(:,test),AlphaY,SVs,Bias,Parameters,nSV,nLabel);
                        case 'polynomial'
                            g=params{m}{n}(1);
                            c=params{m}{n}(2);
                            d=params{m}{n}(3);
                            [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=...
                                PolySVC(data(:,train),cl(train),d,1,g,c);
                            clnew=SVMClass(data(:,test),AlphaY,SVs,Bias,Parameters,nSV,nLabel);
                        case 'rbf'
                            g=params{m}(n);
                            [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=...
                                RbfSVC(data(:,train),cl(train),g);
                            clnew=SVMClass(data(:,test),AlphaY,SVs,Bias,Parameters,nSV,nLabel);
                        case 'mlp'
                            g=params{m}{n}(1);
                            c=params{m}{n}(2);
                            [AlphaY,SVs,Bias,Parameters,nSV,nLabel]=...
                                MlpSVC(data(:,train),cl(train),g,c);
                            clnew=SVMClass(data(:,test),AlphaY,SVs,Bias,Parameters,nSV,nLabel);
                    end
                    % Update misclassification error matrix
                    clnew=clnew';
                    [mise{m,n,q},conf{m,n,q}]=errmeas(cln(clnew),cln(cl(test)));
            end

        end

    end

end

if usewaitbar
    close(h)
end

% Create evaluation figures
if showplots
    figure;
    ha=zeros(1,length(validmethods));
    hs=cell(1,length(validmethods));
    % Calculate maximum parameter set size to place ticks
    len=zeros(1,length(kernels));
    for i=1:length(kernels)
        len(i)=length(params{i});
    end
    nam=cell(1,max(len));
    for i=1:length(nam)
        nam{i}=['Set ',num2str(i)];
    end
    for i=1:length(validmethods)
        ha(i)=subplot(length(validmethods),1,i);
        hs{i}=zeros(1,length(kernels));
        for j=1:length(kernels)
            hold on
            hs{i}(j)=plot(1:length(params{j}),cell2mat(mise(j,:,i)),'.-','Color',rand(1,3),...
                                                                    'LineWidth',2,...
                                                                    'MarkerSize',15);
        end
        grid on
        set(ha(i),'FontSize',9,'FontWeight','bold',...
                  'XTick',1:max(len),'XTickLabel',nam)
        tit=['Misclassification error using ',validnames{i},' evaluation'];
        title(tit,'FontSize',11,'FontWeight','bold')
        xlabel('Parameter sets','FontSize',10,'FontWeight','bold')
        ylabel('Misclassification Error','FontSize',10,'FontWeight','bold')
        legend(hs{i},kernels);
    end
end

% % Display results - command line
% if showresults
%     accper=100*(1-cell2mat(mise)); % Accuracy percentage
%     disp(' ')
%     disp('Support Vector Machines classifier tuning results')
%     disp('============================================================')
%     disp(' ')
%     disp(['Dataset information : Observations - ',num2str(size(data',1)),...
%           ', Variables - ',num2str(size(data',2)),', #Classes - ',num2str(length(unique(cl)))])
%     disp('------------------------------------------------------------')
%     disp(' ')
%     for m=1:length(validmethods)
%         disp(['Classification results using ',validnames{m}])
%         disp('------------------------------------------------------------')
%         disp(' ')
%         for n=1:length(kernels)
%             disp(['Classification results using ',kernels{n},' kernel function'])
%             disp('------------------------------------------------------------')
%             disp(' ')
%             for q=1:length(params{n})
%                 switch kernels{n}
%                     case 'linear'
%                         disp('Parameter set : none (linear kernel)')
%                         disp(['Misclasification error  : ',num2str(mise{q,n,m})])
%                         disp(['Classification accuracy : ',num2str(accper(q,n,m)),'%'])
%                         disp(' ')
%                     case 'polynomial'
%                         g=params{n}{q}(1);
%                         c=params{n}{q}(2);
%                         d=params{n}{q}(3);
%                         disp(['Parameter set : Gamma: ',num2str(g),' Degree: ',num2str(d),...
%                               ' Coefficient: ',num2str(c)]) 
%                         disp(['Misclasification error  : ',num2str(mise{q,n,m})])
%                         disp(['Classification accuracy : ',num2str(accper(q,n,m)),'%'])
%                         disp(' ')
%                     case 'rbf'
%                         g=params{n}(q);
%                         disp(['Parameter set : Gamma: ',num2str(g)])
%                         disp(['Misclasification error  : ',num2str(mise{q,n,m})])
%                         disp(['Classification accuracy : ',num2str(accper(q,n,m)),'%'])
%                         disp(' ')
%                     case 'mlp'
%                         g=params{n}{q}(1);
%                         c=params{n}{q}(2);
%                         disp(['Parameter set : Gamma: ',num2str(g),' Coefficient: ',num2str(c)]) 
%                         disp(['Misclasification error  : ',num2str(mise{q,n,m})])
%                         disp(['Classification accuracy : ',num2str(accper(q,n,m)),'%'])
%                         disp(' ')
%                 end
%           end
%      end
% end

% Display results - create a cell to be displayed in the report window
if showresults
    % Accuracy percentage
    accper=cell(size(mise));
    [p q r]=size(mise);
    for i=1:p
        for j=1:q
            for k=1:r
                accper{i,j,k}=100*(1-mise{i,j,k});
            end
        end
    end
    main={' ';...
          'Support Vector Machines classifier tuning results';...
          '==================================================';...
          ' ';...
          'Dataset information : ';...
          ['Observations : ',num2str(size(data',1))];...
          ['Variables : ',num2str(size(data',2))];...
          ['Number of classes : ',num2str(length(unique(cl)))];...
          '--------------------------------------------------';...
          ' '};
    repcell=cell(3*length(validmethods)+3*length(kernels)+5*length(params),1);
    ind=0;
    for m=1:length(validmethods)
        ind=ind+1;
        repcell{ind}=['Classification results using ',validnames{m}];
        repcell{ind+1}='--------------------------------------------------';
        repcell{ind+2}=' ';
        ind=ind+2;
        for n=1:length(kernels)
            ind=ind+1;
            repcell{ind}=['Classification results using ',kernels{n},' kernel function'];
            repcell{ind+1}='--------------------------------------------------';
            repcell{ind+2}=' ';
            ind=ind+2;
            for q=1:length(params{n})
                ind=ind+1;
                switch kernels{n}
                    case 'linear'
                        repcell{ind}='Parameter set : none (linear kernel)';
                    case 'polynomial'
                        g=params{n}{q}(1);
                        c=params{n}{q}(2);
                        d=params{n}{q}(3);
                        repcell{ind}=['Parameter set : Gamma: ',num2str(g),' Degree: ',num2str(d),...
                                      ' Coefficient: ',num2str(c)];
                    case 'rbf'
                        g=params{n}(q);
                        repcell{ind}=['Parameter set : Gamma: ',num2str(g)];
                    case 'mlp'
                        g=params{n}{q}(1);
                        c=params{n}{q}(2);
                        repcell{ind}=['Parameter set : Gamma: ',num2str(g),' Coefficient: ',num2str(c)];
                end
                repcell{ind+1}=['Misclasification error  : ',num2str(mise{n,q,m})];
                repcell{ind+2}=['Classification accuracy : ',num2str(accper{n,q,m}),'%'];
                repcell{ind+3}='Confusion table : ';
                repcell{ind+4}=conf{n,q,m};
                repcell{ind+5}=' ';
                ind=ind+5;
            end
        end
    end
    final=[main;repcell];
    %disp(char(final))
    GenericReport(final,'SVM Classifier Tuning Results')
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

 
% tunesvm(z,c,'Kernel',{'linear','polynomial','rbf','mlp'},...
%             'Parameters',{{[]},...
%                           {[1 0 3],[1 0 4],[1 0 5],[1 1 3],[1 2 4],[1 3 5]},...
%                           {1,2,3,4,5},...
%                           {[1 3],[1 4],[1 5],[2 3]}},...
%             'ValidMethods',{'kfold','leavemout','holdout'},...
%             'ValidParams',[10,1,0.4],'UseWaitbar',true,'Verbose',false,'ShowPlots',true)
%         
% tunesvm(z,c,'Kernel',{'polynomial','rbf','mlp'},...
%             'Parameters',{{[1 0 3],[1 0 4],[1 0 5],[1 1 3],[1 2 4],[1 3 5]},...
%                           {1,2,3,4,5,6},...
%                           {[1 3],[1 4],[1 5],[2 3],[2 4],[2 5]}},...
%             'ValidMethods',{'kfold','leavemout','holdout'},...
%             'ValidParams',[10,1,0.4],'UseWaitbar',true,'Verbose',false,'ShowPlots',true)