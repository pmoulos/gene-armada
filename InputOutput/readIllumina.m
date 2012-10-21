function [datstruct,expinfo,attributes]=readIllumina(filename,h,instr)

if nargin<2
    h=[];
    instr={''};
end
if nargin<3
    instr={''};
end

% Read data with specialized Illumina function... for memory, read first headers to select
str1=['Reading data from file : ',filename];
instr=[instr;str1];
updateText(h,str1,instr);
tempstru=ilmnbsread(filename,'HeaderOnly',true);
colnames=tempstru.ColumnNames;
siginds=strmatch('AVG_Signal',colnames);
detpinds=strmatch('Detection Pval',colnames);
detsinds=strmatch('Detection Sco',colnames);
detinds=strmatch('Detection',colnames);

invertFlag=0;
signalstru=ilmnbsread(filename,'Columns',colnames(siginds));
if isempty(detpinds) && isempty(detsinds)
    wmsg={'ARMADA was unable to automatically determine whether the detections',...
          'present in your file are p-values or detection scores. Please use the',...
          'invert detection option in the Preprocessing->Filtering window if the',...
          'detections in the file are detection p-values and not detection scores.'};
    uiwait(warndlg(wmsg,'Warning'));
    detectionstru=ilmnbsread(filename,'Columns',colnames(detinds));
    invertFlag=1;
elseif ~isempty(detpinds) && isempty(detsinds)
    detectionstru=ilmnbsread(filename,'Columns',colnames(detpinds));
elseif isempty(detpinds) && ~isempty(detsinds)
    detectionstru=ilmnbsread(filename,'Columns',colnames(detsinds));
elseif ~isempty(detpinds) && ~isempty(detsinds)
    detectionstru=ilmnbsread(filename,'Columns',colnames(detpinds));
end

% Somewhere here the GUI that creates exprp and returns proper column indices...
[expinfo.numberOfConditions,expinfo.conditionNames,expinfo.exprp,...
 expinfo.datatable,strategy,offset,cancel]=IlluminaImportEditor(colnames(siginds));

% Fill in missing expinfo fields
pathnames=cell(1,length(expinfo.exprp));
pathname=getPath(filename);
for i=1:length(pathnames)
    pathnames{i}=cell(1,length(expinfo.exprp{i}));
    for j=1:length(expinfo.exprp{i})
        pathnames{i}{j}=pathname;
    end
end
expinfo.pathnames=pathnames;
expinfo.imgsw=98; % Convention for Illumina

if ~cancel
    
    datstruct=cell(1,length(expinfo.exprp));
    for d=1:length(expinfo.exprp)
        datstruct{d}=cell(1,length(expinfo.exprp{d}));
        for i=1:max(size(expinfo.exprp{d}))
            str1=['Creating data structure -> Condition : ',num2str(d),',',' Replicate : ',num2str(i),' / ',...
                num2str(max(size(expinfo.exprp{d}))),'-Column : ','[',expinfo.exprp{d}{i},']'];
            instr=[instr;str1];
            updateText(h,str1,instr);

            %Create data structure for QuantArray using some of the QuantArray output fields
            z=strmatch(expinfo.exprp{d}{i},signalstru.ColumnNames,'exact');
            datstruct{d}{i}.Header=signalstru.Header;
            datstruct{d}{i}.Intensity=removeZeros(signalstru.Data(:,z),strategy,offset);
            
            if isempty(detpinds) && isempty(detsinds)
                datstruct{d}{i}.Detection=detectionstru.Data(:,z);
            elseif ~isempty(detpinds) && isempty(detsinds)
                datstruct{d}{i}.Detection=1-detectionstru.Data(:,z);
            elseif isempty(detpinds) && ~isempty(detsinds)
                datstruct{d}{i}.Detection=detectionstru.Data(:,z);
            elseif ~isempty(detpinds) && ~isempty(detsinds)
                datstruct{d}{i}.Detection=1-detectionstru.Data(:,z);
            end

            datstruct{d}{i}.Detection=detectionstru.Data(:,z);
            datstruct{d}{i}.Blocks=ones(size(signalstru.Data(:,z)));
            datstruct{d}{i}.ColumnNames=signalstru.ColumnNames;
        end
    end

    % Create attributes
    attributes.Number=[];
    attributes.gnID=signalstru.TargetID;
    attributes.pbID=attributes.gnID;
    attributes.Indices=[];
    attributes.Shape.NumBlocks=1;
    attributes.Shape.BlockRange=[1 1];
    attributes.invertFlag=invertFlag;
    
else 
    datstruct=[];
    expinfo=[];
    attributes=[];
    return            
end

function y = removeZeros(x,strategy,offset)

if nargin<2
    strategy='constant';
    offset=1;
elseif nargin<3
    offset=1;
end

switch strategy
    case 'constant'
        x(x<=0)=1;
    case 'offset'
        x(x<=0)=x(x<=0)+offset;
    case 'minpos'
        x(x<=0)=min(x(x>0));
    case 'rnoise'
        ind=find(x<=0);
        m=min(x(x>0));
        for i=1:length(ind)
            x(ind(i))=m+rand(1);
        end
    case 'none'
        % Nothing
end
y=x;


function out = getPath(in)

f=filesep;
in=char(in);
z=strfind(in,f);
if ~isempty(z)
    out=in(1:z(end));
else
    out=in;
end

function updateText(h,str1,instr)

if ishandle(h)
    set(h,'String',instr)
else
    disp(str1)
end
drawnow;
