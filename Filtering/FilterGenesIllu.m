function [DataCellNormLo,TotalBadpoints] = FilterGenesIllu(datstruct,DataCellNormLo,varargin)

% Function to apply several quality filters in Illumina data

% Set defaults
pset=[0.98 0.99];  % Limits for present/marginal/absent
margasabs=false;   % Marginal as absent from MAS5 calls
iqrpct=[];         % Empty IQR percentile cutoff
varpct=[];         % Empty variance percentile cutoff
intencut=[];       % Empty intensity cutoff
custfilt='';       % Empty custom filter
reptest='t-test';  % t-test reproducibility test by default
pval=0.05;         % Default p-value for reproducibility tests
dishis=false;      % Do not display p-value histograms
exportfilt=false;  % Do not export noise filtered genes
condnames=[];      % Empty array since the default of exportfilt is false
htext=[];          % Empty handle

% Check various input arguments
if length(varargin)>1
    if rem(nargin,2)~=0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'detection','marginasabsent','iqr','variance','intensity','custom','reptest',...
            'pval','showhist','exportfilt','conditions','htext'};
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
                case 1 % Detection call options
                    if isempty(cell2mat(parVal))
                        pset=[];
                    else
                        if ~isvector(parVal) || ~length(parVal)==2
                            error('The %s parameter value must be a vector of length 2',parName)
                        else
                            if ~isnumeric(parVal(1)) || parVal(1)<0 || parVal(1)>1
                                error('The 1st value of %s parameter value must be a number between 0 and 1',parName)
                            end
                            if ~isnumeric(parVal(2)) || parVal(2)<0 || parVal(2)>1
                                error('The 2nd value of %s parameter value must be a number between 0 and 1',parName)
                            end
                        end
                        pset=parVal;
                    end
                case 2 % Marginal as absent points
                    if ~islogical(parVal)
                        error('The %s parameter value must be a true or false',parName)
                    end
                    margasabs=parVal;
                case 3 % IQR percentile
                    if ~(isscalar(parVal) || isnumeric(parVal) || parVal<0 || parVal>100) && ~isempty(parVal)
                        error('The %s parameter value must be a number between 1 and 100',parName)
                    end
                    iqrpct=parVal;
                case 4 % Variance percentile
                    if ~(isscalar(parVal) || isnumeric(parVal) || parVal<0 || parVal>100) && ~isempty(parVal)
                        error('The %s parameter value must be a number between 1 and 100',parName)
                    end
                    varpct=parVal;
                case 5 % Intensity cutoff
                    if ~(isscalar(parVal) || isnumeric(parVal)) && ~isempty(parVal)
                        error('The %s parameter value must be a number',parName)
                    end
                    intencut=parVal;
                case 6 % Custom filter
                    if ~ischar(parVal) && ~isempty(parVal)
                        error('The %s parameter value must be a string',parName)
                    end
                    custfilt=parVal;
                case 7 % Reproducibility test
                    oktests={'t-test','wilcoxon','none'};
                    if isempty(strmatch(lower(parVal),oktests))
                        error('The %s parameter value must be one of ''t-test'',''wilcoxon'' or ''none''',parName)
                    end
                    reptest=parVal;
                case 8 % Reproducibility test p-value
                    if ~isempty(parVal)
                        if ~isscalar(parVal) || ~isnumeric(parVal) || parVal<0 || parVal>1
                            error('The %s parameter value must be a number between 0 and 1',parName)
                        end
                    end
                    pval=parVal;
                case 9 % Show reproducibility test p-value histograms
                    if ~islogical(parVal)
                        error('The %s parameter value must be a true or false',parName)
                    end
                    dishis=parVal;
                case 10 % Export bad points
                    if ~islogical(parVal)
                        error('The %s parameter value must be a true or false',parName)
                    end
                    exportfilt=parVal;
                case 11 % Condition names for exporting
                    if ~iscell(parVal)
                        error('The %s parameter value must be a cell',parName)
                    end
                    if exportfilt && isempty(parVal)
                        parVal=cell(1,length(DataCellNormLo{1}));
                        for k=1:length(DataCellNormLo{1})
                            parVal{k}=['Condition ',num2str(k)];
                        end
                    end
                    condnames=parVal;
                case 12 % Textbox handle
                    if ~ishandle(parVal)
                        htext=[];
                    else
                        htext=parVal;
                    end
            end
        end
    end
end

inmsg={' ';'                          Gene Quality Filtering';...
       '=====================================================================';' '};
message(inmsg,htext)

% Check the validity of custom filter if in command line
if ~isempty(htext) && ~isempty(custfilt)
    checkExpression(custfilt)
end

if ~isempty(custfilt) % Run only this
    
    % Cancel all other filters
    TotalBadpoints=cell(1,length(datstruct));
    rest=cell(1,length(datstruct));
    
    % Define expressions
    mexp='[A-Z]+\s*=\s*(((\+|-)?[0-9]+\.[0-9]*)|(\+?[0-9]+))';
    rexp='[\s\(\|&\+-\*\\]*(PL|PU)+\s*=\s*(((\+|-)?[0-9]+\.[0-9]*)|(\+?[0-9]+))[\s\)\|&\+-\*\\]*';
    
    % Parse custom filter
    args=regexp(custfilt,mexp,'match');
    cal=false;
    for i=1:length(args)
        k=strfind(args{i},'=');
        switch args{i}(1:2)
            case 'PL'
                pset(1)=str2double(args{i}(k+1:end));
                cal=true;
            case 'PU'
                pset(2)=str2double(args{i}(k+1:end));
                cal=true;
            case 'IN'
                intencut=str2double(args{i}(k+1:end));
            case 'IR'
                iqrpct=str2double(args{i}(k+1:end));
            case 'VR'
                varpct=str2double(args{i}(k+1:end));
        end
    end

    if cal
        message('Filtering genes based on detection calls...',htext)
        calls=getIlluCalls(datstruct,pset);
        if margasabs
            for i=1:length(datstruct)
                for j=1:length(datstruct{i})
                    detbad{i}{j}=union(strmatch('A',calls{i}{j}),strmatch('M',calls{i}{j}));
                end
            end
        else
            for i=1:length(datstruct)
                for j=1:length(datstruct{i})
                    detbad{i}{j}=strmatch('A',calls{i}{j});
                end
            end
        end
        DataCellNormLo{6}=calls;
    end
    
    % Get the rest of the expression after calculating MAS5 calls
    restfilt=regexprep(custfilt,rexp,'');
    % Change multiplication and division symbols to MATLAB valids
    restfilt=strrep(restfilt,'*','.*');
    restfilt=strrep(restfilt,'/','./');
    % Flatten data
    fdata=flatData(DataCellNormLo{2});
    
    % Replace with valid expressions
    restfilt=regexprep(restfilt,'IR\s*=\s*(((\+|-)?[0-9]+\.[0-9]*)|(\+?[0-9]+))',...
                                '(iqr(fdata,2)<prctile(iqr(fdata,2),iqrpct))');
    restfilt=regexprep(restfilt,'VR\s*=\s*(((\+|-)?[0-9]+\.[0-9]*)|(\+?[0-9]+))',...
                                '(var(fdata,0,2)<prctile(var(fdata,0,2),varpct))');
    switch DataCellNormLo{5}{2}
        case 'log'
            restfilt=regexprep(restfilt,'IN\s*=\s*(((\+|-)?[0-9]+\.[0-9]*)|(\+?[0-9]+))',...
                                        '(exp(DataCellNormLo{2}{i}{j})<intencut)');
        case 'log2'
            restfilt=regexprep(restfilt,'IN\s*=\s*(((\+|-)?[0-9]+\.[0-9]*)|(\+?[0-9]+))',...
                                        '(2.^DataCellNormLo{2}{i}{j}<intencut)');
        case 'log10'
            restfilt=regexprep(restfilt,'IN\s*=\s*(((\+|-)?[0-9]+\.[0-9]*)|(\+?[0-9]+))',...
                                        '(10.^DataCellNormLo{2}{i}{j}<intencut)');
        otherwise
            restfilt=regexprep(restfilt,'IN\s*=\s*(((\+|-)?[0-9]+\.[0-9]*)|(\+?[0-9]+))',...
                                        '(DataCellNormLo{2}{i}{j}<intencut)');
    end
    
    try
        for i=1:length(datstruct)
            for j=1:length(datstruct{i})
                rest{i}{j}=eval(['find(' restfilt ')']);
            end
        end
    catch
        uiwait(errordlg(lasterr,'Error'));
    end

    % Unify filtered spots
    for i=1:length(datstruct)
        for j=1:length(datstruct{i})
            TotalBadpoints{i}{j}=union(detbad{i}{j},rest{i}{j});
        end
    end
    
else % Run the others

    % Initialize TotalBadpoints and all bad points (apart from custom filter)
    [TotalBadpoints,detbad,iqrbad,varbad,intenbad]=initVars(datstruct);

    % MAS5 calls filter
    if ~isempty(pset)

        message('Retrieving Illumina detection calls...',htext,1)
        calls=getIlluCalls(datstruct,pset);

        message('Filtering absent genes...',htext)
        if margasabs
            for i=1:length(datstruct)
                for j=1:length(datstruct{i})
                    detbad{i}{j}=union(strmatch('A',calls{i}{j}),strmatch('M',calls{i}{j}));
                end
            end
        else
            for i=1:length(datstruct)
                for j=1:length(datstruct{i})
                    detbad{i}{j}=strmatch('A',calls{i}{j});
                end
            end
        end
        DataCellNormLo{6}=calls;
        
    end

    % IQR percentile filter
    if ~isempty(iqrpct)
        message(['Filtering genes presenting IQR less than the ',num2str(iqrpct),' percentile ',...
                 'of the IQR distribution of all arrays...'],htext)
        % Flatten dataset and find IQRs
        fdata=flatData(DataCellNormLo{2});
        iqrs=iqr(fdata,2);
        iqrbad=find(iqrs<prctile(iqrs,iqrpct));
    end

    % Variance filter
    if ~isempty(varpct)
        message(['Filtering genes presenting variance less than the ',num2str(iqrpct),' percentile ',...
                 'of the variance distribution of all arrays...'],htext)
        % Flatten dataset and find IQRs
        fdata=flatData(DataCellNormLo{2});
        vars=var(fdata,0,2);
        varbad=find(vars<prctile(vars,varpct));
    end

    % Low intensity filter
    if ~isempty(intencut)

        message('Filtering low intensity genes...',htext)
        for i=1:length(datstruct)
            for j=1:length(datstruct{i})
                switch DataCellNormLo{5}{2}
                    case 'log'
                        intenbad{i}{j}=find(exp(DataCellNormLo{2}{i}{j})<intencut);
                    case 'log2'
                        intenbad{i}{j}=find(2.^DataCellNormLo{2}{i}{j}<intencut);
                    case 'log10'
                        intenbad{i}{j}=find(10.^DataCellNormLo{2}{i}{j}<intencut);
                    otherwise
                        intenbad{i}{j}=find(DataCellNormLo{2}{i}{j}<intencut);
                end
            end
        end
    
    end
    
    % Unify filtered spots
    for i=1:length(datstruct)
        for j=1:length(datstruct{i})
            TotalBadpoints{i}{j}=union(detbad{i}{j},union(intenbad{i}{j},union(iqrbad,varbad)));
        end
    end
    
end

% Reproducibility test
if ~strcmpi(reptest,'none')
    repbadp=reprodTest(condnames,DataCellNormLo{2},reptest,pval,DataCellNormLo{5}{2},...
                       dishis,htext);
    for i=1:length(datstruct)
        for j=1:length(datstruct{i})
            TotalBadpoints{i}{j}=union(TotalBadpoints{i}{j},repbadp{i});
        end
    end
end

for i=1:length(datstruct)
    for j=1:length(datstruct{i})
        viz(j,i)=length(TotalBadpoints{i}{j});
    end
end

fmsg={'These are the total poor quality spots per Condiition and Replicate';...
      'Columns are the Conditions - Rows are the replicates';...
      '-----------------------------------------------------------';...
      num2str(viz);...
      '-----------------------------------------------------------'};
message(fmsg,htext,1)

% Now mark filtered genes as NaN
message('Marking filtered genes...',htext,1)
for i=1:length(datstruct)
    for j=1:length(datstruct{i})
        DataCellNormLo{1}{i}{j}(TotalBadpoints{i}{j})=NaN;
        DataCellNormLo{2}{i}{j}(TotalBadpoints{i}{j})=NaN;
        DataCellNormLo{3}{i}{j}(TotalBadpoints{i}{j})=NaN;
    end
end


function checkExpression(expr)

% PL : Detection Lower
% PU : Detection Upper
% IR : Interquartile Range
% VR : VaRiance
% IN : Intensity

% Form error messages
errmsg1={'Your filter expression is probably malformed.',...
         'Please check your expression again.'};
     
% Preallocate some random numbers to check the validity of the expression
pl=1;
pu=1;
ir=1;
vr=1;
in=1;

expr=strrep(expr,'*','.*');
expr=strrep(expr,'/','./');
expr=strrep(expr,'=','==');
expr=strrep(expr,'PL','pl');
expr=strrep(expr,'PU','pu');
expr=strrep(expr,'IR','ir');
expr=strrep(expr,'VR','vr');
expr=strrep(expr,'IN','in');
expr=[expr ';'];
try
    eval(expr);
catch
    error(errmsg1)
end

function [TB,db,ib,vb,inb]=initVars(stru)

TB=cell(1,length(stru));
ib=[];
vb=[];
db=cell(1,length(stru));
for i=1:length(stru)
    db{i}=cell(1,length(stru{i}));
end
inb=cell(1,length(stru));
for i=1:length(stru)
    inb{i}=cell(1,length(stru{i}));
end


function calls = getIlluCalls(datstruct,plims)

calls=cell(1,length(datstruct));
n=length(datstruct{1}{1}.Detection);

for i=1:length(datstruct)
    calls{i}=cell(1,length(datstruct{i}));  
    for j=1:length(datstruct{i})
        calls{i}{j}=repmat('A',[n 1]);
        calls{i}{j}(datstruct{i}{j}.Detection>plims(2))='P';
        calls{i}{j}(datstruct{i}{j}.Detection>plims(1) & datstruct{i}{j}.Detection<plims(2))='M';
        calls{i}{j}=cellstr(calls{i}{j});
    end
end


function repbad = reprodTest(nams,datatab,settest,pv,wh,dh,ht)

% Statistical test for spot measurement reproducibility and replication significance

message('Replicate Statistical test is now running...',ht,1)
t=length(nams);

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

c2mExpr=cell(1,t);
for d=1:t
    c2mExpr{d}=cell2mat(datatab{d});
end

% Display a waitbar because this test takes toooooo long
hw=cwaitbar([0 0],{'Condition number - Progress','Reproducibility test - Progress'},{'r','b'});

% Statistical for replicates reaffirmation per Condition
switch settest
    
    case 'wilcoxon'
        
        pw=zeros(length(datatab{1}{1}),t);
        switch wh
            case 'log'
                for i=1:t
                    cwaitbar([1 i/t])
                    for j=1:length(datatab{1}{1})
                        cwaitbar([2 j/length(datatab{1}{1})])
                        pw(j,i)=mysignrank(exp(c2mExpr{i}(j,:)),exp(median(c2mExpr{i}(j,:))));
                    end
                end
            case 'log2'
                for i=1:t
                    cwaitbar([1 i/t])
                    for j=1:length(datatab{1}{1})
                        cwaitbar([2 j/length(datatab{1}{1})])
                        pw(j,i)=mysignrank(2.^c2mExpr{i}(j,:),2.^median(c2mExpr{i}(j,:)));
                    end
                end
            case 'log10'
                for i=1:t
                    cwaitbar([1 i/t])
                    for j=1:length(datatab{1}{1})
                        cwaitbar([2 j/length(datatab{1}{1})])
                        pw(j,i)=mysignrank(10.^c2mExpr{i}(j,:),10.^median(c2mExpr{i}(j,:)));
                    end
                end
            otherwise
                for i=1:t
                    cwaitbar([1 i/t])
                    for j=1:length(datatab{1}{1})
                        cwaitbar([2 j/length(datatab{1}{1})])
                        pw(j,i)=mysignrank(c2mExpr{i}(j,:),median(c2mExpr{i}(j,:)));
                    end
                end
        end
        p=pw;
        
    case 't-test'
        
        pt=zeros(length(datatab{1}{1}),t);
        switch wh
            case 'log'
                for i=1:t
                    cwaitbar([1 i/t])
                    for j=1:length(datatab{1}{1})
                        cwaitbar([2 j/length(datatab{1}{1})])
                        [h,pt(j,i)]=ttest(exp(c2mExpr{i}(j,:)),exp(mean(c2mExpr{i}(j,:))));
                    end
                end
            case 'log2'
                for i=1:t
                    cwaitbar([1 i/t])
                    for j=1:length(datatab{1}{1})
                        cwaitbar([2 j/length(datatab{1}{1})])
                        [h,pt(j,i)]=ttest(2.^c2mExpr{i}(j,:),2.^mean(c2mExpr{i}(j,:)));
                    end
                end
            case 'log10'
                for i=1:t
                    cwaitbar([1 i/t])
                    for j=1:length(datatab{1}{1})
                        cwaitbar([2 j/length(datatab{1}{1})])
                        [h,pt(j,i)]=ttest(10.^c2mExpr{i}(j,:),10.^mean(c2mExpr{i}(j,:)));
                    end
                end
            otherwise
                for i=1:t
                    cwaitbar([1 i/t])
                    for j=1:length(datatab{1}{1})
                        cwaitbar([2 j/length(datatab{1}{1})])
                        [h,pt(j,i)]=ttest(c2mExpr{i}(j,:),mean(c2mExpr{i}(j,:)));
                    end
                end
        end
        p=pt;
        
end

close(hw);

if dh
    % Create p-values vs Genes plurality histogram per Condition
    % for the Wilcoxon test an for the t-test
    lab=cell(1,t);
    switch settest
        case 'wilcoxon'
            for y=1:t
                figure % Wilcoxon histogram
                hist(pw(:,y),0.1:0.01:0.99);
                xlabel('p-value')
                ylabel('Genes plurality');
                title('Wilcoxon');
                lab{y}=strcat('Condition - ',num2str(y),' - Replicates : ',num2str(length(nams{y})));
                set(gcf,'Name',lab{y})
            end
        case 't-test'
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

repbad=cell(1,t);
for d=1:t
    [repbad{d} column]=find(p(:,d)<=pv(d));
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

% [DataCellNormLo,TotalBadpoints] = FilterGenesAffy(datstruct,DataCellNormLo1,cdfstruct,...
%                                                   'IQR',10,'Variance',10,'Intensity',100,...
%                                                   'RepTest','none','Conditions',{'Control','apoE'},...
%                                                   'ShowHist',true);
