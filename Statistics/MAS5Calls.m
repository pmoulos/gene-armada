function [calls, pvals] = MAS5Calls(datstruct,cdffile,varargin)

%
% This function calculates present calls for Affymetrix chips which are stored in the
% structure datstruct and more specifically in the filed 'Intensity'. The input variable
% datstruct has a format that is supported by ARMADA. For more information on the creation
% of datstruct please consult AFFY2STRUCT and CREATEDATSTRUCTAFFY. The present calls are
% being calculated according to affymetrix statistical reference guide for the MAS5
% algorithm and can be retrieved from
% http://www.affymetrix.com/support/technical/whitepapers/sadd_whitepaper.pdf
%
% Usage : [calls,pvals] = MAS5Calls(datstruct,cdffile,varargin)
%
% Input arguments:
% datstruct : As described above
% cdffile   : The Affymetrix CDF library required for the chip used in the experiment,
%             either as a file with its full path, either as a structure as returned by
%             AFFYREAD.
%
%
% ParameterName          ParameterValue                                                  
% -----------------------------------------------------------------------------
% Alpha       The confidence limit that will be used for the Wilcoxon test. It should be
%             a scalar between 0 and 1 and defaults to 0.05. 
%                       
% Tau         For further definitions on the tau parameter, please consult the statistical
%             reference guide of Affymetrix (link above). It should be a scalar and
%             defaults to 0.015.
%
% Threshold   The p-value thresholds below and above which a gene is considered present or
%             absent. please consult the statistical reference guide of Affymetrix (link 
%             above for further details. It should be a vector of length 2 with numbers
%             between 0 and 1. It defaults to [0.04 0.06].
%
% Usewaitbar  It can be true (default) or false. If true, a multiple waitbar displays 
%             progress of calculations.
%
% HText       Textbox handle for use in ARMADA
%
% Ouputs:
% calls : A cell which contains the calls for every condition and replicate. 'P' denotes a
%         present gene, 'A' an absent and 'M' a marginal one.
% pvals : The same as above, but with the results of the Wilcoxon test
%
% See also : AFFYREAD, AFFY2STRUCT, CREATEDATSTRUCTAFFY
%

% Set defaults
alpha=0.05;
tau=0.015;
alphalims=[0.04 0.06];
usewaitbar=true;
htext=[];

% Check various input arguments
if length(varargin)>1
    if rem(nargin,2)~=0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'alpha','tau','threshold','usewaitbar','htext'};
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
                case 1 % Alpha
                    if ~isscalar(parVal) || parVal<0 || parVal>1
                        error('The %s parameter value must be a number between 0 and 1',parName)
                    end
                    alpha=parVal;
                case 2 % Tau
                    if ~isscalar(parVal)
                        error('The %s parameter value must be a number',parName)
                    end
                    alpha=parVal;
                case 3 % Alpha limits
                    if ~isvector(parVal) || length(parVal)~=2
                        error('The %s parameter value must be a vector of length 2',parName)
                    end
                    if parVal(1)<0 || parVal(1)>1 || parVal(2)<0 || parVal(2)>1
                        error('The %s parameter elements must be numbers between 0 and 1',parName)
                    end
                    alphalims=parVal;
                case 4 % Normalization options
                    if ~islogical(parVal)
                        error('The %s parameter value must be true or false',parName)
                    end
                    usewaitbar=parVal;
                case 5 % Textbox handle
                    if ~ishandle(parVal)
                        htext=[];
                    else
                        htext=parVal;
                    end
            end
        end
    end
end

% If cdffile is structure use it, else read cdf library
if isstruct(cdffile)
    cdfstruct=cdffile;
else
    cdfstruct=affyread(cdffile);
end

% Start job

% Initialize some variables
nProbeSets=cdfstruct.NumProbeSets;

% Initialize waitbar
if usewaitbar
    h=cwaitbar([0 0 0],{'Number of conditions - Progress',...
               'Number of replicates - Progress','Probeset - Progress'},...
               {'b','r','g'});
end

pvals=cell(1,length(datstruct));
calls=cell(1,length(datstruct));

for i=1:length(datstruct)

    pvals{i}=cell(1,length(datstruct{i}));
    calls{i}=cell(1,length(datstruct{i}));
    
    if usewaitbar
        cwaitbar([1 i/length(datstruct)])
    end
    
    for j=1:length(datstruct{i})
        
        pvals{i}{j}=zeros(nProbeSets,1);
        calls{i}{j}=cell(nProbeSets,1);
        
        if usewaitbar
            cwaitbar([2 j/length(datstruct{i})])
        else
            mymessage(['Calculating MAS5 calls for Condition ',num2str(i),' and Replicate ',...
                       num2str(j)],htext,0)
        end
        
        if usewaitbar
            count=0;
            ce=ceil(nProbeSets/1000);
        end
        
        for k=1:nProbeSets
            
            if usewaitbar
                if mod(k,1000)==0
                    count=count+1;
                    cwaitbar([3 count/ce])
                end
            end
            
            [pm,mm]=getPMandMM(datstruct{i}{j},cdfstruct,k);
            dv=(pm-mm)./(pm+mm);
            pvals{i}{j}(k)=signrank(dv,tau,alpha)/2; % To simply correct for 2-sided test
            if pvals{i}{j}(k)<alphalims(1)
                calls{i}{j}{k}='P';
            elseif pvals{i}{j}(k)>alphalims(2)
                calls{i}{j}{k}='A';
            else
                calls{i}{j}{k}='M';
            end
            
        end
    end
end

if usewaitbar
    close(h)
end


function [pm,mm] = getPMandMM(celstru,cdfstru,curr)

numcols=cdfstru.Cols;
colidPM=3; % For PM probe intensity 
colidMM=5; % for MM probe intensity
    
thepairs=cdfstru.ProbeSets(curr).ProbePairs;
PXPM=thepairs(:,colidPM);
PYPM=thepairs(:,colidPM+1);
PXMM=thepairs(:,colidMM);
PYMM=thepairs(:,colidMM+1);
pm=celstru.Intensity(PYPM*numcols+PXPM+1);
mm=celstru.Intensity(PYMM*numcols+PXMM+1);

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
                   'Name','Calling absents... - Overall progress');
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

% drawnow
figure(f)

if nargout==1,
    fout=f;
end

