function exportNorm(exprp,exptab,DataCellNormLo,gnID,names,fcinds,opts,filename)

% This function works as a helper for ARMADA to export files. The variable opts
% contains certain export option fields (sse code of ExportDEEditor). When I find some
% time, I will write a complete help.
% opts.outtype='text' for tab delimited textm typ='excel' for excel file (faster but
% probably bigger file), default is text

if nargin<7
    opts.sp=true;
    opts.genenames=true;
    opts.foldchange=true;
    opts.rawratio=false;
    opts.logratio=false;
    opts.meanrawratio=false;
    opts.meanlogratio=false;
    opts.medianrawratio=false;
    opts.medianlogratio=false;
    opts.stdevrawratio=false;
    opts.stdevlogratio=false;
    opts.intensity=false;
    opts.meanintensity=true;
    opts.medianintensity=false;
    opts.stdevintensity=true;
    opts.normlogratio=true;
    opts.meannormlogratio=true;
    opts.mediannormlogratio=false;
    opts.stdevnormlogratio=true;
    opts.normrawratio=false;
    opts.meannormrawratio=false;
    opts.mediannormrawratio=false;
    opts.stdevnormrawratio=false;
    opts.cvs=true;
    opts.outtype='text';
    
    [filename,pathname]=uiputfile('*.txt','Save your gene list');
    if filename==0
        uiwait(msgbox('No file specified','Export list','modal'));
        return
    else
        filename=strcat(pathname,filename);
    end
elseif nargin<8
    if strcmpi(opts.outtype,'text')
        [filename,pathname]=uiputfile('*.txt','Save your gene list');
        if filename==0
            uiwait(msgbox('No file specified','Export list','modal'));
            return
        else
            filename=strcat(pathname,filename);
        end
    elseif strcmpi(opts.outtype,'excel')
        [filename,pathname]=uiputfile('*.xls','Save your gene list');
        if filename==0
            uiwait(msgbox('No file specified','Export list','modal'));
            return
        else
            filename=strcat(pathname,filename);
        end
    end
end

% Number of conditions
t=length(names);
% Data
slipos=1:length(gnID);
slipos=slipos';
lograt=DataCellNormLo{1};
logratnorm=DataCellNormLo{2};
inten=DataCellNormLo{3};
for i=1:length(names)
    lograt{i}=cell2mat(lograt{i});
    logratnorm{i}=cell2mat(logratnorm{i});
    inten{i}=cell2mat(inten{i});
end
rawratio=cell(1,t);
for i=1:t
    rawratio{i}=nan(size(exptab{i}{1},1),size(exptab{i},2));
    for j=1:size(exptab{i},2)
        rawratio{i}(:,j)=exptab{i}{j}(:,3);
    end
end
% Find number of replicates for each condition
cellsize=size(lograt);
repcol=zeros(size(lograt,2));
for ind=1:cellsize(2)
    repsize=size(lograt{ind});
    repcol(ind)=repsize(2);
end

if strcmpi(opts.outtype,'text') % Text tab delimited files
    
    % Open file for writing
    fid=fopen(filename,'w');

    frmth='';
    evalhead='';
    % Slide Positions
    if opts.sp
        frmth=[frmth,'%s\t'];
        evalhead=[evalhead,'''Slide Position'','];
    end
    % Gene Names
    if opts.genenames
        frmth=[frmth,'%s\t'];
        evalhead=[evalhead,'''GeneID'','];
    end
    
    % Fold Changes
    if opts.foldchange && length(DataCellNormLo)>6 && ~isempty(fcinds)
        for i=1:length(fcinds{1})
            frmth=[frmth,'%s\t%s\t'];
            evalhead=[evalhead,'''Fold Change (log2) ',names{fcinds{2}(i)},'vs',names{fcinds{1}(i)},''',',...
                               '''Fold Change (natural) ',names{fcinds{2}(i)},'vs',names{fcinds{1}(i)},''','];
        end
    end

    for i=1:t

        % Raw Ratios
        if opts.rawratio
            ftemp=repmat('%s\t',[1 repcol(i)]);
            frmth=[frmth,ftemp];
            etemp=cell(1,length(exprp{i}));
            for j=1:length(exprp{i})
                etemp{j}=['''Raw Ratio ',exprp{i}{j},''','];
            end
            evalhead=[evalhead,cell2mat(etemp)];
        end

        % Mean Raw Ratios
        if opts.meanrawratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''Mean Raw Ratio ',names{i},''','];
        end

        % Median Raw Ratios
        if opts.medianrawratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''Median Raw Ratio ',names{i},''','];
        end

        % StDev Raw Ratios
        if opts.stdevrawratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''StDev Raw Ratio ',names{i},''','];
        end

        % Log Ratios
        if opts.logratio
            ftemp=repmat('%s\t',[1 repcol(i)]);
            frmth=[frmth,ftemp];
            etemp=cell(1,length(exprp{i}));
            for j=1:length(exprp{i})
                etemp{j}=['''Log2 Ratio ',exprp{i}{j},''','];
            end
            evalhead=[evalhead,cell2mat(etemp)];
        end

        % Mean Log Ratios
        if opts.meanlogratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''Mean Log2 Ratio ',names{i},''','];
        end

        % Median Log Ratios
        if opts.medianlogratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''Median Log2 Ratio ',names{i},''','];
        end

        % StDev Log Ratios
        if opts.stdevlogratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''StDev Log2 Ratio ',names{i},''','];
        end

        % Normalized Raw Ratios
        if opts.normrawratio
            ftemp=repmat('%s\t',[1 repcol(i)]);
            frmth=[frmth,ftemp];
            etemp=cell(1,length(exprp{i}));
            for j=1:length(exprp{i})
                etemp{j}=['''Normalized Raw Ratio ',exprp{i}{j},''','];
            end
            evalhead=[evalhead,cell2mat(etemp)];
        end

        % Mean Normalized Raw Ratios
        if opts.meannormrawratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''Mean Normalized Raw Ratio ',names{i},''','];
        end

        % Median Normalized Raw Ratios
        if opts.mediannormrawratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''Median Normalized Raw Ratio ',names{i},''','];
        end

        % StDev Normalized Raw Ratios
        if opts.stdevnormrawratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''StDev Normalized Raw Ratio ',names{i},''','];
        end

        % Normalized Log2 Ratios
        if opts.normlogratio
            ftemp=repmat('%s\t',[1 repcol(i)]);
            frmth=[frmth,ftemp];
            etemp=cell(1,length(exprp{i}));
            for j=1:length(exprp{i})
                etemp{j}=['''Normalized Log2 Ratio ',exprp{i}{j},''','];
            end
            evalhead=[evalhead,cell2mat(etemp)];
        end

        % Mean Normalized Raw Ratios
        if opts.meannormlogratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''Mean Normalized Log2 Ratio ',names{i},''','];
        end

        % Median Normalized Raw Ratios
        if opts.mediannormlogratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''Median Normalized Log2 Ratio ',names{i},''','];
        end

        % StDev Normalized Raw Ratios
        if opts.stdevnormlogratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''StDev Normalized Log2 Ratio ',names{i},''','];
        end

        % Intensities
        if opts.intensity
            ftemp=repmat('%s\t',[1 repcol(i)]);
            frmth=[frmth,ftemp];
            etemp=cell(1,length(exprp{i}));
            for j=1:length(exprp{i})
                etemp{j}=['''Intensity ',exprp{i}{j},''','];
            end
            evalhead=[evalhead,cell2mat(etemp)];
        end

        % Mean Intensites
        if opts.meanintensity
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''Mean Intensity ',names{i},''','];
        end

        % Median Intensity
        if opts.medianintensity
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''Median Intensity ',names{i},''','];
        end

        % StDev Intensity
        if opts.stdevintensity
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''StDev Intensity ',names{i},''','];
        end

        % Coefficients of Variation
        if opts.cvs
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''CV ',names{i},''','];
        end

    end

    % Remove last comma (,) from evalhead (will produce error in fprintf otherwise)...
    evalhead=evalhead(1:end-1);
    % ...and add a newline
    frmth=[frmth,'\n'];

    % Write headers (first line)
    evalstr=['fprintf(fid,frmth,',evalhead,');'];
    eval(evalstr);

    frmtv='';
    evaltext='';
   
    % Slide Positions
    if opts.sp
        frmtv=[frmtv,'%u\t'];
        evaltext=[evaltext,'slipos(currentIndex),'];
    end
    % Gene Names
    if opts.genenames
        frmtv=[frmtv,'%s\t'];
        evaltext=[evaltext,'gnID{currentIndex},'];
    end
    
    % Fold changes
    if opts.foldchange && length(DataCellNormLo)>6 && ~isempty(fcinds)
        for j=1:length(fcinds{1})
            frmtv=[frmtv,'%8.6g\t%8.6g\t'];
            evaltext=[evaltext,'DataCellNormLo{7}(currentIndex,',num2str(j),'),',...
                               '2.^DataCellNormLo{7}(currentIndex,',num2str(j),'),'];
        end
    end

    for j=1:t

        % Raw Ratios
        if opts.rawratio
            ftemp=repmat('%8.6g\t',[1 repcol(j)]);
            frmtv=[frmtv,ftemp];
            etemp=cell(1,length(exprp{j}));
            for k=1:length(exprp{j})
                etemp{k}=['2.^exptab{',num2str(j),'}{',num2str(k),'}(slipos(currentIndex),3),'];
            end
            evaltext=[evaltext,cell2mat(etemp)];
        end

        % Mean Raw Ratios
        if opts.meanrawratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanmean(2.^rawratio{',num2str(j),'}(slipos(currentIndex),:),2),'];
        end

        % Median Raw Ratios
        if opts.medianrawratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanmedian(2.^rawratio{',num2str(j),'}(slipos(currentIndex),:),2),'];
        end

        % StDev Raw Ratios
        if opts.stdevrawratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanstd(2.^rawratio{',num2str(j),'}(slipos(currentIndex),:),0,2),'];
        end

        % Log Ratios
        if opts.logratio
            ftemp=repmat('%8.6g\t',[1 repcol(j)]);
            frmtv=[frmtv,ftemp];
            etemp=cell(1,length(exprp{j}));
            for k=1:length(exprp{j})
                etemp{k}=['exptab{',num2str(j),'}{',num2str(k),'}(slipos(currentIndex),3),'];
            end
            evaltext=[evaltext,cell2mat(etemp)];
        end

        % Mean Log Ratios
        if opts.meanlogratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanmean(rawratio{',num2str(j),'}(slipos(currentIndex),:),2),'];
        end

        % Median Log Ratios
        if opts.medianlogratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanmedian(rawratio{',num2str(j),'}(slipos(currentIndex),:),2),'];
        end

        % StDev Log Ratios
        if opts.stdevlogratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanstd(rawratio{',num2str(j),'}(slipos(currentIndex),:),0,2),'];
        end

        % Normalized Raw Ratios
        if opts.normrawratio
            ftemp=repmat('%8.6g\t',[1 repcol(j)]);
            frmtv=[frmtv,ftemp];
            etemp=cell(1,length(exprp{j}));
            for k=1:length(exprp{j})
                etemp{k}=['2.^logratnorm{',num2str(j),'}(currentIndex,',num2str(k),'),'];
            end
            evaltext=[evaltext,cell2mat(etemp)];
        end

        % Mean Normalized Raw Ratios
        if opts.meannormrawratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanmean(2.^logratnorm{',num2str(j),'}(currentIndex,:),2),'];
        end

        % Median Normalized Raw Ratios
        if opts.mediannormrawratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanmedian(2.^logratnorm{',num2str(j),'}(currentIndex,:),2),'];
        end

        % StDev Normalized Raw Ratios
        if opts.stdevnormrawratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanstd(2.^logratnorm{',num2str(j),'}(currentIndex,:),0,2),'];
        end

        % Normalized Log2 Ratios
        if opts.normlogratio
            ftemp=repmat('%8.6g\t',[1 repcol(j)]);
            frmtv=[frmtv,ftemp];
            etemp=cell(1,length(exprp{j}));
            for k=1:length(exprp{j})
                etemp{k}=['logratnorm{',num2str(j),'}(currentIndex,',num2str(k),'),'];
            end
            evaltext=[evaltext,cell2mat(etemp)];
        end

        % Mean Normalized Log2 Ratios
        if opts.meannormlogratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanmean(logratnorm{',num2str(j),'}(currentIndex,:),2),'];
        end

        % Median Normalized Log2 Ratios
        if opts.mediannormlogratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanmedian(logratnorm{',num2str(j),'}(currentIndex,:),2),'];
        end

        % StDev Normalized Log2 Ratios
        if opts.stdevnormlogratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanstd(logratnorm{',num2str(j),'}(currentIndex,:),0,2),'];
        end

        % Intensities
        if opts.intensity
            ftemp=repmat('%8.6g\t',[1 repcol(j)]);
            frmtv=[frmtv,ftemp];
            etemp=cell(1,length(exprp{j}));
            for k=1:length(exprp{j})
                etemp{k}=['DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(slipos(currentIndex)),'];
            end
            evaltext=[evaltext,cell2mat(etemp)];
        end

        % Mean Intensites
        if opts.meanintensity
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanmean(inten{',num2str(j),'}(slipos(currentIndex),:),2),'];
        end

        % Median Intensity
        if opts.medianintensity
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanmedian(inten{',num2str(j),'}(slipos(currentIndex),:),2),'];
        end

        % StDev Intensity
        if opts.stdevintensity
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanstd(inten{',num2str(j),'}(slipos(currentIndex),:),0,2),'];
        end

        % Coefficients of Variation
        if opts.cvs
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanstd(logratnorm{',num2str(j),'}(currentIndex,:),0,2)./',...
                'nanmean(logratnorm{',num2str(j),'}(currentIndex,:),2),'];
        end

    end

    % Remove last comma (,) from evaltext (will produce error in fprintf otherwise)...
    evaltext=evaltext(1:end-1);
    % ...and add a newline
    frmtv=[frmtv,'\n'];

    % Write the rest of the lines (may the Force be with us...)
    for i=1:length(slipos)
        evalstr=['fprintf(fid,frmtv,',evaltext,');'];
        evalstr=strrep(evalstr,'currentIndex',num2str(i));
        eval(evalstr)
    end

    % Close file
    fclose(fid);
    
elseif strcmpi(opts.outtype,'excel') % Excel files
    
    headers={};
    % Slide Positions
    if opts.sp
        headers=[headers,'Slide Position'];
    end
    % Gene Names
    if opts.genenames
        headers=[headers,'GeneID'];
    end
    
    % Fold changes
    if opts.foldchange && length(DataCellNormLo)>6 && ~isempty(fcinds)
        for i=1:length(fcinds{1})
            headers=[headers,['''Fold Change (log2) ',names{fcinds{2}(i)},'vs',names{fcinds{1}(i)},''','],...
                             ['''Fold Change (natural) ',names{fcinds{2}(i)},'vs',names{fcinds{1}(i)},''',']];
        end
    end
    
    for i=1:t

        % Raw Ratios
        if opts.rawratio
            for j=1:length(exprp{i})
                headers=[headers,['Raw Ratio ' exprp{i}{j}]];
            end
        end

        % Mean Raw Ratios
        if opts.meanrawratio
            headers=[headers,['Mean Raw Ratio ',names{i}]];
        end

        % Median Raw Ratios
        if opts.medianrawratio
            headers=[headers,['Median Raw Ratio ',names{i}]];
        end

        % StDev Raw Ratios
        if opts.stdevrawratio
            headers=[headers,['StDev Raw Ratio ',names{i}]];
        end

        % Log Ratios
        if opts.logratio
            for j=1:length(exprp{i})
                headers=[headers,['Log2 Ratio ' exprp{i}{j}]];
            end
        end

        % Mean Log Ratios
        if opts.meanlogratio
            headers=[headers,['Mean Log2 Ratio ',names{i}]];
        end

        % Median Log Ratios
        if opts.medianlogratio
            headers=[headers,['Median Log2 Ratio ',names{i}]];
        end

        % StDev Log Ratios
        if opts.stdevlogratio
            headers=[headers,['StDev Log2 Ratio ',names{i}]];
        end

        % Normalized Raw Ratios
        if opts.normrawratio
            for j=1:length(exprp{i})
                headers=[headers,['Normalized Raw Ratio ' exprp{i}{j}]];
            end
        end

        % Mean Normalized Raw Ratios
        if opts.meannormrawratio
            headers=[headers,['Mean Normalized Raw Ratio ',names{i}]];
        end

        % Median Normalized Raw Ratios
        if opts.mediannormrawratio
            headers=[headers,['Median Normalized Raw Ratio ',names{i}]];
        end

        % StDev Normalized Raw Ratios
        if opts.stdevnormrawratio
            headers=[headers,['StDev Normalized Raw Ratio ',names{i}]];
        end

        % Normalized Log2 Ratios
        if opts.normlogratio
            for j=1:length(exprp{i})
                headers=[headers,['Normalized Log2 Ratio ' exprp{i}{j}]];
            end
        end

        % Mean Normalized Raw Ratios
        if opts.meannormlogratio
            headers=[headers,['Mean Normalized Raw Ratio ',names{i}]];
        end

        % Median Normalized Raw Ratios
        if opts.mediannormlogratio
            headers=[headers,['Median Normalized Raw Ratio ',names{i}]];
        end

        % StDev Normalized Raw Ratios
        if opts.stdevnormlogratio
            headers=[headers,['StDev Normalized Raw Ratio ',names{i}]];
        end

        % Intensities
        if opts.intensity
            for j=1:length(exprp{i})
                headers=[headers,['Intensity ' exprp{i}{j}]];
            end
        end

        % Mean Intensites
        if opts.meanintensity
            headers=[headers,['Mean Intensity ',names{i}]];
        end

        % Median Intensity
        if opts.medianintensity
            headers=[headers,['Median Intensity ',names{i}]];
        end

        % StDev Intensity
        if opts.stdevintensity
            headers=[headers,['StDev Intensity ',names{i}]];
        end

        % Coefficients of Variation
        if opts.cvs
            headers=[headers,['CV ',names{i},]];
        end

    end
    
    finaldata=[];
    % finaldata={};
    % Slide Positions
    if opts.sp
        finaldata=[finaldata,slipos];
    end
    % Gene Names - Apparently there is a problem here that does not appear while expoting
    % from DE lists with exactly the same code!!! Fixed anyway...
    if opts.genenames
       finaldata={finaldata,gnID};
    end
    
    % Fold Changes
    if opts.foldchange && length(DataCellNormLo)>6 && ~isempty(fcinds)
        for j=1:length(fcinds{1})
            finaldata=[finaldata,DataCellNormLo{7}(:,j)];
            finaldata=[finaldata,2.^DataCellNormLo{7}(:,j)];
        end
    end
       
    for j=1:t

        % Raw Ratios
        if opts.rawratio
            finaldata=[finaldata,2.^rawratio{j}(slipos,:)];
        end

        % Mean Raw Ratios
        if opts.meanrawratio
            finaldata=[finaldata,nanmean(2.^rawratio{j}(slipos,:),2)];
        end

        % Median Raw Ratios
        if opts.medianrawratio
            finaldata=[finaldata,nanmedian(2.^rawratio{j}(slipos,:),2)];
        end

        % StDev Raw Ratios
        if opts.stdevrawratio
            finaldata=[finaldata,nanstd(2.^rawratio{j}(slipos,:),0,2)];
        end

        % Log Ratios
        if opts.logratio
            finaldata=[finaldata,rawratio{j}(slipos,:)];
        end

        % Mean Log Ratios
        if opts.meanlogratio
            finaldata=[finaldata,nanmean(rawratio{j}(slipos,:),2)];
        end

        % Median Log Ratios
        if opts.medianlogratio
            finaldata=[finaldata,nanmedian(rawratio{j}(slipos,:),2)];
        end

        % StDev Log Ratios
        if opts.stdevlogratio
            finaldata=[finaldata,nanstd(rawratio{j}(slipos,:),0,2)];
        end

        % Normalized Raw Ratios
        if opts.normrawratio
            finaldata=[finaldata,2.^logratnorm{j}];
        end

        % Mean Normalized Raw Ratios
        if opts.meannormrawratio
            finaldata=[finaldata,nanmean(2.^logratnorm{j},2)];
        end

        % Median Normalized Raw Ratios
        if opts.mediannormrawratio
            finaldata=[finaldata,nanmedian(2.^logratnorm{j},2)];
        end

        % StDev Normalized Raw Ratios
        if opts.stdevnormrawratio
            finaldata=[finaldata,nanstd(2.^logratnorm{j},0,2)];
        end

        % Normalized Log2 Ratios
        if opts.normlogratio
            finaldata=[finaldata,logratnorm{j}];
        end

        % Mean Normalized Log2 Ratios
        if opts.meannormlogratio
            finaldata=[finaldata,nanmean(logratnorm{j},2)];
        end

        % Median Normalized Log2 Ratios
        if opts.mediannormlogratio
            finaldata=[finaldata,nanmedian(logratnorm{j},2)];
        end

        % StDev Normalized Log2 Ratios
        if opts.stdevnormlogratio
            finaldata=[finaldata,nanstd(logratnorm{j},0,2)];
        end

        % Intensities
        if opts.intensity
            finaldata=[finaldata,inten{j}(slipos,:)];
        end

        % Mean Intensites
        if opts.meanintensity
            finaldata=[finaldata,nanmean(inten{j}(slipos,:),2)];
        end

        % Median Intensity
        if opts.medianintensity
            finaldata=[finaldata,nanmedian(inten{j}(slipos,:),2)];
        end

        % StDev Intensity
        if opts.stdevintensity
            finaldata=[finaldata,nanstd(inten{j}(slipos,:),0,2)];
        end

        % Coefficients of Variation
        if opts.cvs
            finaldata=[finaldata,nanstd(logratnorm{j},0,2)./nanmean(logratnorm{j},2)];
        end

    end
    
    % Create the final cell for exporting
    if opts.genenames
        finaldata=saveday(finaldata);
        final=[headers;finaldata];
    end 
    
%     if opts.genenames && opts.sp % Fix problem of non-arithmetic data
%         final_p1=finaldata(:,1);
%         final_p1=mat2cell(final_p1,ones(length(final_p1),1),1);
%         final_p2=gnID;
%         final_p3=finaldata(:,2:end);
%         final_p3=mat2cell(final_p3,ones(size(final_p3,1),1),ones(size(final_p3,2),1));
%         final=[headers;final_p1,final_p2,final_p3];
%     elseif opts.genenames && ~opts.sp
%         final_p2=gnID;
%         final_p3=finaldata;
%         final_p3=mat2cell(final_p3,ones(size(final_p3,1),1),ones(size(final_p3,2),1));
%         final=[headers;final_p2,final_p3];
%     else % No problem
%         finaldata=mat2cell(finaldata,ones(size(finaldata,1),1),ones(size(finaldata,2),1));
%         final=[headers;finaldata];
%     end
    
    xlswrite(filename,final)
    
end


function saved = saveday(bull)

% Function to correct the final cell in the case of exporting to Excel for the presence of
% arithmetic and non-arithmetic data

% Assign final variable to initial
saved=bull;

% Locate non-numeric data
l=length(bull);
whocells=zeros(1,l);
for i=1:l
    if iscell(bull{i})
        whocells(i)=1;
    end
end
indcells=find(whocells);

% Numerigy them by converting those to NaN
for i=1:length(indcells)
    saved{indcells(i)}=nan(length(bull{indcells(i)}),1);
end
saved=cell2mat(saved);

% Now fix the problem of multiple column double cells which casue the final dimensionality
% to expand and make indcells useless
[m n]=size(saved);
whoallnans=zeros(1,n);
for i=1:n
    if all(isnan(saved(:,i)))
        whoallnans(i)=1;
    end
end
allnans=find(whoallnans);
% length(allnans)==length(indcells) % MUST TRUE
saved=mat2cell(saved,ones(m,1),ones(n,1));
for i=1:length(allnans)
    saved(:,allnans(i))=bull{indcells(i)};
end
    