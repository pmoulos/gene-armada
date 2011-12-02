function him = myheatmap(datamat,varargin)

% Set defaults
clusters=[];
hier=false;
hierparams.pdist='euclidean';
hierparams.linkage='average';
hierparams.dimension=1;
cmap='redgreenfixed';
cmapden=64;
scalerows=false;
scalecolumns=false;
scalecolors=false;
labels={};
colnames={};
titre=false;

% Check various input arguments
if length(varargin)>1
    if rem(nargin,2)==0
        error('Incorrect number of arguments to %s.',mfilename);
    end
    okargs={'clusters','hierarchical','hierparams','colormap','density','scalerows','scalecolumns',...
            'scalecolors','labels','columnnames','title'};
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
                case 1 % Clusters
                    if ~isvector(parVal) && ~isnumeric(parVal)
                        error('The %s parameter value must be a vector of integers',parName)
                    else
                        clusters=parVal;
                    end
                case 2 % Hierachical clustering
                    if ~islogical(parVal)
                        error('The %s parameter value must be logical',parName)
                    else
                        hier=parVal;
                    end
                case 3 % Hierachical clustering parameters
                    if ~isstruct(parVal)
                        error('The %s parameter value must be a structure with clustergram parameters',parName)
                    else
                        hierparams=parVal;
                    end
                case 4 % Colormap for heatmap
                    acceptable={'redgreen','redgreenfixed','jet','hot','cool','spring','summer','autumn',...
                                'winter','gray','bone','copper','pink','lines'};
                    if ~ischar(parVal) && ~ismember(parVal,acceptable)
                        error('The %s parameter value must be a character vector and one of the acceptable colormaps',parName)
                    else
                        cmap=parVal;
                    end
                case 5 % Colormap density
                    if ~isscalar(cmapden)
                        error('The %s parameter value must be a scalar',parName)
                    else
                        cmapden=parVal;
                    end
                case 6 % Scale rows
                    if ~islogical(parVal)
                        error('The %s parameter value must be logical',parName)
                    else
                        scalerows=parVal;
                    end
                case 7 % Scale columns
                    if ~islogical(parVal)
                        error('The %s parameter value must be logical',parName)
                    else
                        scalecolumns=parVal;
                    end
                case 8 % Scale colors
                    if ~islogical(parVal)
                        error('The %s parameter value must be logical',parName)
                    else
                        scalecolors=parVal;
                    end
                case 9 % Labels
                    if ~iscellstr(parVal)
                        error('The %s parameter value must be a cell array of strings',parName)
                    else
                        labels=parVal;
                    end
                case 10 % Column names
                    if ~iscellstr(parVal)
                        error('The %s parameter value must be a cell array of strings',parName)
                    else
                        colnames=parVal;
                    end
                case 11 % Give titles
                    if ~islogical(parVal)
                        error('The %s parameter value must be logical',parName)
                    else
                        titre=parVal;
                    end
            end
        end
    end
end

% Scale data if required
if scalerows
    means=mean(datamat,2);
    stds=std(datamat,[],2);
    for i=1:size(datamat,1)
        datamat(i,:)=(datamat(i,:)-means(i))./stds(i);
    end
end
if scalecolumns
    means=mean(datamat);
    stds=std(datamat);
    for i=1:size(datamat,2)
        datamat(:,j)=(datamat(:,i)-means(i))./stds(i);
    end
end
if scalecolors
    if min(min(datamat))<0
        maxmap=max(max(abs(datamat)));
        minmap=-maxmap;
    else
        minmap=min(min(datamat));
        maxmap=max(max(datamat));
    end
else
    minmap=[];
    maxmap=[];
end

% Do da job
if ~hier
    
    if isempty(clusters)
        ax=axes('Units','normalized');
        him=createDataImage(datamat,labels,colnames,ax);
        setFigure(ax,datamat,cmap,cmapden,scalecolors,minmap,maxmap)
        if titre
            title('Heatmap')
        end
    else
        for i=1:length(unique(clusters))
            figure;
            ax=axes('Units','normalized');
            him=createDataImage(datamat(clusters==i,:),labels(clusters==i),colnames,ax);
            setFigure(ax,datamat,cmap,cmapden,scalecolors,minmap,maxmap)
            if titre
                title(['Heatmap ',num2str(i)])
            end
        end
    end
    
else
        
    if isempty(clusters)
       figure;
       myclustergram(datamat,'rowlabels',labels,...
                             'columnlabels',colnames,...
                             'pdist',hierparams.pdist,...
                             'linkage',hierparams.linkage,...
                             'dimension',hierparams.dimension);
       justColormap(cmap,cmapden)
       if scalecolors
           set(gca,'CLim',[minmap maxmap])
       end
       if titre
           title('Clustered heatmap')
       end
    else
        for i=1:length(unique(clusters))
            figure;
            myclustergram(datamat(clusters==i,:),'rowlabels',labels,...
                                                 'columnlabels',colnames,...
                                                 'pdist',hierparams.pdist,...
                                                 'linkage',hierparams.linkage,...
                                                 'dimension',hierparams.dimension);
            justColormap(cmap,cmapden)
            if scalecolors
                set(gca,'CLim',[minmap maxmap])
            end
            if titre
                title(['Clustered heatmap ',num2str(i)])
            end
        end
    end
    
end


function setFigure(h,dm,cm,cn,sc,mn,mx)

if sc
    climprop=[mn mx];
else
    if min(min(dm))<0
        climprop=[-max(max(abs(dm))) max(max(abs(dm)))];
    else
        climprop=[min(min(dm)) max(max(dm))];
    end
end
set(h,'CLim',climprop)
if strcmpi(cm,'redgreen')
    strcmap=['redgreencmap','(',num2str(cn),')'];
    colormap(strcmap)
elseif strcmpi(cm,'redgreenfixed')
    % Load my adjusted fixed 64-colormap
    S=load('MyColormaps','mycmap');
    mycmap=S.mycmap;
    set(gcf,'Colormap',mycmap)
else
    strcmap=[lower(cm),'(',num2str(cn),')'];
    colormap(strcmap)
end

function justColormap(cm,cn)

if strcmpi(cm,'redgreen')
    strcmap=['redgreencmap','(',num2str(cn),')'];
    colormap(strcmap)
elseif strcmpi(cm,'redgreenfixed')
    % Load my adjusted fixed 64-colormap
    S=load('MyColormaps','mycmap');
    mycmap=S.mycmap;
    set(gcf,'Colormap',mycmap)
else
    strcmap=[lower(cm),'(',num2str(cn),')'];
    colormap(strcmap)
end