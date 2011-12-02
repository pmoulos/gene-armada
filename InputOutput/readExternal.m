function [attributes,lograt,intens,DataCellNormLo] = readExternal(filename,exprp,islog,inten,annc)

% filename  : The path and name of the file that contains normalized data
% exprp     : The column names of NORMALIZED log ratios
% islog     : Data already log-transformed? If not they will be
% inten     : The column names of intensities (optional)
% annc      : How many annotation columns do we have
% 
% DataCellNormLo : Our known and beloved DataCellNormLo...
%
% This function, if used as command line and not with the GUI ImportExternalEditor from
% within ARMADA, implies that the user knows exactly what doing. lograt and intens will
% be used in the case of unnormalized data. Inten is an obligatory input in this case. If
% data already normalized, inten is not necessary (only for plotting MA plots) and
% DataCellNormLo is used directly. In the other case, lograt and intens are used in the
% normalization function which creates DataCellNormLo and the DataCellNormLo output from
% this function is not used at all.

if nargin<4 || isempty(inten{1})
    inten=[];
end

% We must create a format for reading the columns of the file... first column contains an
% annotation field and the rest of them will contain ONLY numbers and the separator will
% be the tab character. Also, if intensities are given, we assume that they are pairs with
% ratios and this check has been performed from the input GUI... However... since this
% function can be called manually, we put as comments a ratio-intensity pair checking...

% Ratio-intensity pair integrity check
% if ~isempty(inten)
%     allok=ones(1,length(exprp));
%     for i=1:length(exprp)
%         if length(exprp{i})~=length(inten{i})
%             allok(i)=0;
%         end
%     end
%     if ~all(allok)
%         errmsg={'The ratio columns must be exactly paired with intensity columns.',...
%                 'Please review your selections and make sure that the number of',...
%                 'ratio columns is the same as the intensity columns.'};
%         uiwait(errordlg(errmsg,'Bad Input'));
%         DataCellNormLo=[];
%         return
%     end
% end

% Create basic reading format
count=0;
for i=1:length(exprp)
    for j=1:length(exprp{i})
        count=count+1;
    end
end
frmt=repmat('%f',[1 count]);
if ~isempty(inten)
    frmt=[frmt frmt];
end
% Add the leading annotation columns
frmt=[repmat('%s',[1 annc]),frmt];
% Excel file flag
isexcel=false;

% Read the column names of file
if ~isempty(strfind(filename,'.xls'))
    
    isexcel=true;
    try
        [res,head]=xlsread2xlsread8(filename);
    catch
        errmsg1={'The following error occured trying to read the file :',...
                 filename,...
                 lasterr,...
                 'Please make sure that the file name and path name are correct',...
                 'and that your file exists. If the problem is not corrected,',...
                 'save your file in text tab delimited format and try again.'};
        
        uiwait(errordlg(errmsg1,'Error!'));
        lograt=[];
        intens=[];
        DataCellNormLo=[];
        return
    end
    colnames=head(:);
    
else
    
    fid=fopen(filename,'r');
    if fid==-1
        errmsg2={'An error occured trying to read file: ',...
                 filename,...
                 'Please make sure that the file name and path name are',...
                 'correct and that your file exists.'};
        uiwait(errordlg(errmsg2,'Error!'));
        lograt=[];
        intens=[];
        DataCellNormLo=[];
        return
    else
        fline=fgetl(fid);
        fclose(fid);
        colnames=textscan(fline,'%s','Delimiter','\t');
        colnames=colnames{1};
    end
    
end

% Assign data...
lograt=cell(1,length(exprp));       % Log ratio (will be same as normalized ratio)
logratnormlo=cell(1,length(exprp)); % Normalized log ratio
intens=cell(1,length(exprp));       % Intensity
logratsmth=cell(1,length(exprp));   % Log ratio smoother (NaN)

if isexcel
    
    for i=1:length(exprp)
        for j=1:length(exprp{i})
            z=strmatch(exprp{i}{j},colnames);
            lograt{i}{j}=cell2mat(res(:,z));
            logratnormlo{i}{j}=cell2mat(res(:,z));
            logratsmth{i}{j}=nan(size(lograt{i}{j},1),1);
        end
    end
    if ~isempty(inten)
       for i=1:length(inten)
           for j=1:length(inten{i})
               z=strmatch(inten{i}{j},colnames);
               intens{i}{j}=cell2mat(res(:,z));
           end
       end
    else
        for i=1:length(exprp)
           for j=1:length(exprp{i})
               intens{i}{j}=nan(size(lograt{i}{j},1),1);
           end
       end
    end
    gnID=res(:,1);
    
else
    
    fid=fopen(filename);
    alldata=textscan(fid,frmt,'Delimiter','\t','HeaderLines',1);
    fclose(fid);
    
    for i=1:length(exprp)
        for j=1:length(exprp{i})
            z=strmatch(exprp{i}{j},colnames);
            lograt{i}{j}=alldata{z};
            logratnormlo{i}{j}=alldata{z};
            logratsmth{i}{j}=nan(size(lograt{i}{j},1),1);
        end
    end
    if ~isempty(inten)
       for i=1:length(inten)
           for j=1:length(inten{i})
               z=strmatch(inten{i}{j},colnames);
               intens{i}{j}=alldata{z};
           end
       end
    else
        for i=1:length(exprp)
           for j=1:length(exprp{i})
               intens{i}{j}=nan(size(lograt{i}{j},1),1);
           end
       end
    end
    gnID=alldata{1};
    
end

if ~islog
    for i=1:length(exprp)
        for j=1:length(exprp{i})
            lograt{i}{j}=log2(lograt{i}{j});
            logratnormlo{i}{j}=log2(logratnormlo{i}{j});
            intens{i}{j}=log2(intens{i}{j});
        end
    end
end

DataCellNormLo{1}=lograt;
DataCellNormLo{2}=logratnormlo;
DataCellNormLo{3}=intens;
DataCellNormLo{6}=logratsmth;
DataCellNormLo{4}=NaN; % There is no span (The Matrix moto 'there is no spoon' adjusted 
                       % for microarray data analysis)
DataCellNormLo{5}=100; % A large value that denotes externally normalized data

attributes.Number=[];
attributes.gnID=gnID;
attributes.Indices=[];
attributes.Shape=[];


