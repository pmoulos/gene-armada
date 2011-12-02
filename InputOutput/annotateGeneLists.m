function annotateGeneLists(flist,fann,unidg,unida,anncols)

% Function to add annotation element to an output file of ARMADA
% flist   : the gene list file (Excel or tab delimited)
% fann    : the file that contains the annotation elements (Excel or tab delimited)
% unidg   : the unique identifier of genes in the list file (could be one of 'Slide
%           Position' or 'GeneID'
% unida   : the column number or the name of the unique identifier element in the
%           annotation file
% anncols : the names or numbers of columns containing the annotation elements that will
%           be added to the genes list file and whose elements must correspond to the
%           unique identifier. If numbers are given, a vector containing the column
%           numbers, else a cell array of strings with the column names

% Perform some error checking
if (~ischar(flist) && ~iscell(flist)) || ~ischar(fann)
    errmsg=['The first two arguments should be strings denoting gene list ',...
            'and annotation files respectively. The first argument can also '...
            'a cell array of strings representing filenames.'];
    error(errmsg)
end
if ~isscalar(unidg) && ~ischar(unidg)
    error('The third argument must be a single numeric value or a string.')
end
if ~isscalar(unida) && ~ischar(unida)
    error('The fourth argument must be a single numeric value or a string.')
end
if ~isvector(anncols) && ~iscell(anncols)
    error('The last argument must be a numeric vector or a cell array of strings.')
end

if ischar(flist)
    if isempty(strfind(flist,'.xls')) % Text file
        excelL=false;
    else % Excel file
        excelL=true;
    end
    multi=false;
elseif iscell(flist)
    if isempty(strfind(flist{1},'.xls')) % Text file
        excelL=false;
    else % Excel file
        excelL=true;
    end
    multi=true;
end

% Open and read the gene list file
if ~excelL % Text file
    
    if multi
        fidL=fopen(flist{1},'r');
    else
        fidL=fopen(flist,'r');
    end
    flineL=fgetl(fidL);
    colnamesL=textscan(flineL,'%s','Delimiter','\t');
    colnamesL=colnamesL{1};
    if isscalar(unidg)
        listUID=unidg;
    else
        listUID=strmatch(unidg,colnamesL,'exact');
    end
    if isempty(listUID)
        errmsg=['The given unique gene identifier in the gene list does not match ',...
                'any of the column names in the gene list file.'];
        error(errmsg)
    end
    
    % Format for reading the rest of the file: generally, ARMADA outputs consist of
    % numeric data. The first column will contain either Slide Positions either GeneIDs
    % (depending on the users preference. So it will be either all data numeric, or the
    % 1st column text and other numeric, or the 1st column numeric, the 2nd text and all
    % other numeric. So...
    if ~isempty(strmatch('Slide Position',colnamesL{1},'exact')) && ...
       ~isempty(strmatch('GeneID',colnamesL{2},'exact'))
        spg='SPG';
        frmtL='%u%s';
        frmtL=[frmtL,repmat('%f',[1 length(colnamesL)-2])];
    elseif ~isempty(strmatch('Slide Position',colnamesL{1},'exact')) && ...
            isempty(strmatch('GeneID',colnamesL{2},'exact'))
        spg='SP';
        frmtL='%u';
        frmtL=[frmtL,repmat('%f',[1 length(colnamesL)-1])];
    elseif ~isempty(strmatch('GeneID',colnamesL{1},'exact')) && ...
            isempty(strmatch('Slide Position',colnamesL{1},'exact'))
        spg='G';
        frmtL='%s';
        frmtL=[frmtL,repmat('%f',[1 length(colnamesL)-1])];
    else
        error(['The file does not seem to be an output gene list file from ARMADA ',...
               'or you have chosen a column which does not represent one of the unique ',...
               'identifiers supported by ARMADA.'])
    end
    
    % Read data
    if ~multi
        alldata=textscan(fidL,frmtL,'Delimiter','\t');
        if strcmp(spg,'SPG') && listUID==1
            iddataL=alldata(1:2);
            restdataL=cell2mat(alldata(3:end));
        else
            iddataL=alldata(1:listUID);
            restdataL=cell2mat(alldata(listUID+1:end));
        end
        fclose(fidL);
    else
        fclose(fidL);
        alldata=cell(1,length(flist));
        iddataL=cell(1,length(flist));
        restdataL=cell(1,length(flist));
        fidL=zeros(1,length(flist));
        for i=1:length(flist)
            fidL(i)=fopen(flist{i});
            alldata{i}=textscan(fidL(i),frmtL,'Delimiter','\t','HeaderLines',1);
            if strcmp(spg,'SPG') && listUID==1
                iddataL{i}=alldata{i}(1:2);
                restdataL{i}=cell2mat(alldata{i}(3:end));
            else
                iddataL{i}=alldata{i}(1:listUID);
                restdataL{i}=cell2mat(alldata{i}(listUID+1:end));
            end
            fclose(fidL(i));
        end
    end
                 
else % Excel file
    
    if multi
        [res,head]=xlsread2xlsread8(flist{1});
    else
        [res,head]=xlsread2xlsread8(flist);
    end
    colnamesL=head;
    if isscalar(unidg)
        listUID=unidg;
    else
        listUID=strmatch(unidg,colnamesL);
    end
    if isempty(listUID)
        errmsg=['The given unique gene identifier in the gene list does not match ',...
                'any of the column names in the gene list file.'];
        error(errmsg)
    end
    
    % This can change in a later more general version
    if ~multi
        iddataL=res(:,1:listUID);
        restdataL=res(:,listUID+1:end);
    else
        res=cell(1,length(flist));
        head=cell(1,length(flist));
        iddataL=cell(1,length(flist));
        restdataL=cell(1,length(flist));
        for i=1:length(flist)
            [res{i},head{i}]=xlsread2xlsread8(flist{i});
            iddataL{i}=res{i}(:,1:listUID);
            restdataL{i}=res{i}(:,listUID+1:end);
        end
    end

end

% Open and read the annotation file
if isempty(strfind(fann,'.xls')) % Text file
    
    excelA=false; % Excel file flag
    fidA=fopen(fann,'r');
    flineA=fgetl(fidA);
    colnamesA=textscan(flineA,'%s','Delimiter','\t');
    colnamesA=colnamesA{1};
    
    % Unique ID column
    if isscalar(unida)
        annUID=unida;
    else
        annUID=strmatch(unida,colnamesA);
    end
    if isempty(annUID)
        errmsg=['The given unique gene identifier in the gene list does not match ',...
                'any of the column names in the gene list file.'];
        error(errmsg)
    end
    
    % Rest desired annotation columns
    descols=findDesiredColumns(anncols,colnamesA);
        
    % Format for reading the rest of the file: we suppose that all columns contain
    % strings. If a column contains numeric data (e.g. locuslink IDs), then it will be
    % read as string, does not matter anyway...
    frmtA=repmat('%s',[1 length(colnamesA)]);
    
    % Read data
    anndata=textscan(fidA,frmtA,'Delimiter','\t');
    iddataA=anndata(annUID);
    restdataA=anndata(descols);
    fclose(fidA);
    
else % Excel file
    
    excelA=true; % Excel file flag
    [res,head]=xlsread2xlsread8(fann);
    colnamesA=head;
    if isscalar(unida)
        annUID=unida;
    else
        annUID=strmatch(unida,colnamesA);
    end
    if isempty(annUID)
        errmsg=['The given unique gene identifier in the gene list does not match ',...
                'any of the column names in the gene list file.'];
        error(errmsg)
    end
    
    % Rest desired annotation columns
    descols=findDesiredColumns(anncols,colnamesA);
    
    iddataA=res(:,annUID);
    restdataA=res(:,descols);
    
end

% So we have iddataL, restdataL, iddataA, restdataL and we have to build the file from the
% beginning using these shit...

% Do the process for the case of one gene list file
if ~multi

    if size(iddataL,2)==2 % We have both slide positions and gene ids in the gene list file
        if listUID==1
            if excelL
                idL=iddataL(:,1);
            else
                idL=iddataL{1};
            end
        elseif listUID==2
            if excelL
                idL=iddataL(:,2);
            else
                idL=iddataL{2};
            end
        end
    else
        if excelL
            idL=iddataL(:,listUID);
        else
            idL=iddataL{listUID};
        end
    end

    % Find elements from annotation file
    try
        idL=cell2mat(idL);
    catch
        % Nothing, idL is either already numeric or string
    end
    if isnumeric(idL)
        % If idL contains slide positions, the unique ID column from annotation file should
        % also contain slide positions
        try
            if excelA
                idA=cell2mat(iddataA);
            else
                % Data have been read as strings
                idA=str2double(iddataA{1});
            end
            if ~isnumeric(idA)
                error(['The unique ID columns of both the gene list and annotation files should ',...
                    'contain the same data type.'])
            end
        catch
            disp(['The unique ID columns of both the gene list and annotation files should ',...
                'contain the same data type.'])
            rethrow(lasterror)
        end
        % Now that tests passed find the rows from annotation file that correspond to the same
        % rows in the gene list file using the slide position.
        inds=zeros(length(idL),1);
        for i=1:length(idL)
            inds(i)=find(idA==idL(i));
        end
    else
        % If idL contains strings, the unique ID column from annotation file should also
        % contain strings
        if excelA
            idA=iddataA;
        else
            idA=iddataA{1};
        end
        try
            idA=cell2mat(idA);
            if isnumeric(idA)
                error(['The unique ID columns of both the gene list and annotation files should ',...
                    'contain the same data type.'])
            end
        catch
            % Quietly do nothing
        end
        % Now that tests passed find the rows from annotation file that correspond to the same
        % rows in the gene list file using the string unique ID.
        inds=zeros(length(idL),1);
        try
            try % Cell or matrix
                for i=1:length(idL)
                    inds(i)=strmatch(idL{i},idA,'exact');
                end
            catch
                for i=1:length(idL)
                    inds(i)=strmatch(idL(i,:),idA,'exact');
                end
            end
        catch
            % If strmatch returns more than one element, geneIDs are not unique, error!
            error('The gene IDs you provided are not unique.')
        end
    end
    if any(inds==0)
        warning('Annotator:ElementsNotFound',['Some elements from the list file cound not ',...
            'be found in the annotation file'])
        inds=(inds~=0);
    end

    % Now, find annotation elements from annotation file
    if excelA && excelL
        seldata=restdataA(inds,:);
    elseif ~excelA && ~excelL
        seldata=cell(1,length(restdataA));
        for i=1:length(restdataA)
            for j=1:length(inds)
                seldata{i}(j)=restdataA{i}(inds(j));
            end
        end
    elseif excelA && ~excelL
        tseldata=restdataA(inds,:);
        seldata=cell(1,size(tseldata,2));
        for p=1:size(tseldata,2)
            seldata{p}=tseldata(:,p);
        end
    elseif ~excelA && excelL
        seldata=cell(length(inds),length(restdataA));
        for i=1:length(inds)
            for j=1:length(restdataA)
                seldata{i,j}=restdataA{j}{inds(i)};
            end
        end
    end

    % Now we have to rebuild the final gene list file, merging annotation data
    if excelL

        colnamesA=colnamesA';
        colnamesL=colnamesL';
        colnamesLeft=colnamesL(1:listUID);
        colnamesMiddle=colnamesA(descols);
        colnamesRight=colnamesL(listUID+1:end);
        final=[colnamesLeft,colnamesMiddle,colnamesRight;iddataL,seldata,restdataL];
        [pathstr,name]=fileparts(flist);
        if ispc
            xlswrite([pathstr,'\',name,'_Annotated'],final)
        else
            xlswrite([pathstr,'/',name,'_Annotated'],final)
        end

    else

        colnamesL=colnamesL';
        colnamesA=colnamesA';
        switch spg
            case 'SPG'
                colnamesLeft=colnamesL(1:2);
                colnamesMiddle=colnamesA(descols);
                colnamesRight=colnamesL(3:end);
            otherwise
                colnamesLeft=colnamesL(1:listUID);
                colnamesMiddle=colnamesA(descols);
                colnamesRight=colnamesL(listUID+1:end);
        end
        newheaders=[colnamesLeft,colnamesMiddle,colnamesRight];
        [pathstr,name,ext]=fileparts(flist);
        if ispc
            newfile=[pathstr,'\',name,'_Annotated',ext];
        else
            newfile=[pathstr,'/',name,'_Annotated',ext];
        end
        fid=fopen(newfile,'w+');

        % Print headers
        for i=1:length(newheaders)-1
            fprintf(fid,'%s\t',newheaders{i});
        end
        fprintf(fid,'%s\n',newheaders{end});

        % Construct format for the rest of data
        switch spg
            case 'SPG'
                for i=1:size(iddataL{1},1)
                    fprintf(fid,'%u\t%s\t',iddataL{1}(i),iddataL{2}{i});
                    for j=1:length(descols)
                        fprintf(fid,'%s\t',seldata{j}{i});
                    end
                    for k=1:size(restdataL,2)-1
                        fprintf(fid,'%f\t',restdataL(i,k));
                    end
                    fprintf(fid,'%f\n',restdataL(i,end));
                end
            case 'SP'
                for i=1:size(iddataL{1},1)
                    fprintf(fid,'%u\t',iddataL{1}(i));
                    for j=1:length(descols)
                        fprintf(fid,'%s\t',seldata{j}{i});
                    end
                    for k=1:size(restdataL,2)-1
                        fprintf(fid,'%f\t',restdataL(i,k));
                    end
                    fprintf(fid,'%f\n',restdataL(i,end));
                end
            case 'G'
                for i=1:size(iddataL{1},1)
                    fprintf(fid,'%s\t',iddataL{1}{i});
                    for j=1:length(descols)
                        fprintf(fid,'%s\t',seldata{j}{i});
                    end
                    for k=1:size(restdataL,2)-1
                        fprintf(fid,'%f\t',restdataL(i,k));
                    end
                    fprintf(fid,'%f\n',restdataL(i,end));
                end
        end

        fclose(fid);

    end

else % Multiple gene list file inputs
    
    colnamesA=colnamesA';
    colnamesL=colnamesL';
    
    for i=1:length(flist)
        
        idL=cell(1,length(flist));
        final=cell(1,length(flist));
        
        if size(iddataL{i},2)==2 % We have both slide positions and gene ids in the gene list file
            if listUID==1
                if excelL
                    idL{i}=iddataL{i}(:,1);
                else
                    idL{i}=iddataL{i}{1};
                end
            elseif listUID==2
                if excelL
                    idL{i}=iddataL{i}(:,2);
                else
                    idL{i}=iddataL{i}{2};
                end
            end
        else
            if excelL
                idL{i}=iddataL{i}(:,listUID);
            else
                idL{i}=iddataL{i}{listUID};
            end
        end

        % Find elements from annotation file
        try
            idL{i}=cell2mat(idL{i});
        catch
            % Nothing, idL is either already numeric or string
        end
        if isnumeric(idL{i})
            % If idL contains slide positions, the unique ID column from annotation file should
            % also contain slide positions
            try
                if excelA
                    idA=cell2mat(iddataA);
                else
                    % Data have been read as strings
                    idA=str2double(iddataA{1});
                end
                if ~isnumeric(idA)
                    error(['The unique ID columns of both the gene list and annotation files should ',...
                        'contain the same data type.'])
                end
            catch
                disp(['The unique ID columns of both the gene list and annotation files should ',...
                    'contain the same data type.'])
                rethrow(lasterror)
            end
            % Now that tests passed find the rows from annotation file that correspond to the same
            % rows in the gene list file using the slide position.
            inds=zeros(length(idL{i}),1);
            for j=1:length(idL{i})
                inds(j)=find(idA==idL{i}(j));
            end
        else
            % If idL contains strings, the unique ID column from annotation file should also
            % contain strings
            if excelA
                idA=iddataA;
            else
                idA=iddataA{1};
            end
            try
                idA=cell2mat(idA);
                if isnumeric(idA)
                    error(['The unique ID columns of both the gene list and annotation files should ',...
                        'contain the same data type.'])
                end
            catch
                % Quietly do nothing
            end
            % Now that tests passed find the rows from annotation file that correspond to the same
            % rows in the gene list file using the string unique ID.
            inds=zeros(length(idL{i}),1);
            try
                try % Cell or matrix
                    for j=1:length(idL{i})
                        inds(j)=strmatch(idL{i}{j},idA,'exact');
                    end
                catch
                    for j=1:length(idL{i})
                        inds(j)=strmatch(idL{i}(j,:),idA,'exact');
                    end
                end
            catch
                % If strmatch returns more than one element, geneIDs are not unique, error!
                error('The gene IDs you provided are not unique.')
            end
        end
        if any(inds==0)
            warning('Annotator:ElementsNotFound',['Some elements from the list file cound not ',...
                'be found in the annotation file'])
            inds=(inds~=0);
        end

        % Now, find annotation elements from annotation file
        if excelA && excelL
            seldata=restdataA(inds,:);
        elseif ~excelA && ~excelL
            seldata=cell(1,length(restdataA));
            for j=1:length(restdataA)
                for k=1:length(inds)
                    seldata{j}(k)=restdataA{j}(inds(k));
                end
            end
        elseif excelA && ~excelL
            tseldata=restdataA(inds,:);
            seldata=cell(1,size(tseldata,2));
            for p=1:size(tseldata,2)
                seldata{p}=tseldata(:,p);
            end
        elseif ~excelA && excelL
            seldata=cell(length(inds),length(restdataA));
            for j=1:length(inds)
                for k=1:length(restdataA)
                    seldata{j,k}=restdataA{k}{inds(j)};
                end
            end
        end

        % Now we have to rebuild the final gene list file, merging annotation data
        if excelL
            
            colnamesLeft=colnamesL(1:listUID);
            colnamesMiddle=colnamesA(descols);
            colnamesRight=colnamesL(listUID+1:end);
            final{i}=[colnamesLeft,colnamesMiddle,colnamesRight;iddataL{i},seldata,restdataL{i}];
            [pathstr,name]=fileparts(flist{i});
            if ispc
                xlswrite([pathstr,'\',name,'_Annotated'],final{i})
            else
                xlswrite([pathstr,'/',name,'_Annotated'],final{i})
            end

        else

            switch spg
                case 'SPG'
                    colnamesLeft=colnamesL(1:2);
                    colnamesMiddle=colnamesA(descols);
                    colnamesRight=colnamesL(3:end);
                otherwise
                    colnamesLeft=colnamesL(1:listUID);
                    colnamesMiddle=colnamesA(descols);
                    colnamesRight=colnamesL(listUID+1:end);
            end
            newheaders=[colnamesLeft,colnamesMiddle,colnamesRight];
            [pathstr,name,ext]=fileparts(flist{i});
            if ispc
                newfile=[pathstr,'\',name,'_Annotated',ext];
            else
                newfile=[pathstr,'/',name,'_Annotated',ext];
            end
            fid=fopen(newfile,'w+');

            % Print headers
            for j=1:length(newheaders)-1
                fprintf(fid,'%s\t',newheaders{j});
            end
            fprintf(fid,'%s\n',newheaders{end});

            % Construct format for the rest of data
            switch spg
                case 'SPG'
                    for j=1:size(iddataL{i}{1},1)
                        fprintf(fid,'%u\t%s\t',iddataL{i}{1}(j),iddataL{i}{2}{j});
                        for k=1:length(descols)
                            fprintf(fid,'%s\t',seldata{k}{j});
                        end
                        for l=1:size(restdataL{i},2)-1
                            fprintf(fid,'%f\t',restdataL{i}(j,l));
                        end
                        fprintf(fid,'%f\n',restdataL{i}(j,end));
                    end
                case 'SP'
                    for j=1:size(iddataL{i}{1},1)
                        fprintf(fid,'%u\t',iddataL{i}{1}(j));
                        for k=1:length(descols)
                            fprintf(fid,'%s\t',seldata{k}{j});
                        end
                        for l=1:size(restdataL{i},2)-1
                            fprintf(fid,'%f\t',restdataL{i}(j,l));
                        end
                        fprintf(fid,'%f\n',restdataL{i}(j,end));
                    end
                case 'G'
                    for j=1:size(iddataL{i}{1},1)
                        fprintf(fid,'%s\t',iddataL{i}{1}{j});
                        for k=1:length(descols)
                            fprintf(fid,'%s\t',seldata{k}{j});
                        end
                        for l=1:size(restdataL{i},2)-1
                            fprintf(fid,'%f\t',restdataL{i}(j,l));
                        end
                        fprintf(fid,'%f\n',restdataL{i}(j,end));
                    end
            end

            fclose(fid);

        end
    
    end
    
end
    

function descols = findDesiredColumns(anncols,colnames)

% Function to return desired annotation columns from all column names of the annotation
% file, together with some error checking. Function returns column numbers

if isvector(anncols) && ~iscell(anncols)
    if max(anncols)>length(colnames)-1
        warning('Annotator:PossibleWrongColumnNumber',['The desired annotation fields ',...
                'appear to be more than the existing fields. Using existing fields...'])
        anncols=sort(anncols);
        descols=anncols(length(colnames)-1<max(anncols));
    else
        descols=anncols;
    end
elseif iscell(anncols)
    descols=zeros(1,length(anncols));
    for i=1:length(anncols)
        z=strmatch(anncols{i},colnames,'exact');
        if ~isempty(z)
            descols(i)=z;
        end
    end
    descols=descols(descols~=0);
    % What if some names given wrong?
    if length(descols)<length(anncols)
        v=length(anncols)-length(descols);
        vv=cell(1,v);
        newcols=colnames(descols);
        mis=zeros(1,length(anncols));
        for i=1:length(anncols)
            z=strmatch(anncols{i},newcols,'exact');
            if isempty(z)
                mis(i)=i;
            end
        end
        mis=mis(mis~=0);
        for i=1:length(mis)
            vv{i}=[anncols{mis(i)},', '];
        end
        vv=cell2mat(vv);
        warning('Annotator:ColumnsMissing',['Columns ',vv,'not found in annotation file']);
    end
end
