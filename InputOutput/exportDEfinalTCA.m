function exportDEfinalTCA(exprp,names,exptab,DataCellNormLo,DataCellStat,tind,opts,filename)


% This function works as a helper for ANDROMEDA to export files. The variable opts
% contains certain export option fields (sse code of ExportDEEditor). When I find some
% time, I will write a complete help.
% opts.outtype='text' for tab delimited textm typ='excel' for excel file (faster but
% probably bigger file), default is text

if nargin<7
    opts.sp=true;
    opts.genenames=true;
    opts.pvalues=true;
    opts.qvalues=false;
    opts.fdr=false;
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
    opts.trustfactors=true;
    opts.cvs=true;
    opts.outtype='text';
    
    [filename,pathname]=uiputfile('*.txt','Save your gene list');
    if filename==0
        uiwait(msgbox('No file specified','Export list','modal'));
        return
    else
        filename=strcat(pathname,filename);
    end
end
if nargin<8
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
s=length(DataCellStat{6});
% Find number of replicates for each condition
ncellsize=size(DataCellNormLo{2});
scellsize=size(DataCellStat{5});
nrepcol=zeros(size(DataCellNormLo{2},2));
srepcol=zeros(size(DataCellStat{5},2));
for ind=1:ncellsize(2)
    repsize=size(DataCellNormLo{2}{ind});
    nrepcol(ind)=repsize(2);
end
for ind=1:scellsize(2)
    repsize=size(DataCellStat{5}{ind});
    srepcol(ind)=repsize(2);
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
    % p-values
    if opts.pvalues
        frmth=[frmth,'%s\t'];
        evalhead=[evalhead,'''p-value'','];
    end
    % FDR
    if opts.fdr && ~isempty(DataCellStat{8})
        frmth=[frmth,'%s\t'];
        evalhead=[evalhead,'''FDR'','];
    end
    % q-values
    if opts.qvalues && ~isempty(DataCellStat{8})
        frmth=[frmth,'%s\t'];
        evalhead=[evalhead,'''q-value'','];
    end

    for i=1:t

        % Raw Ratios
        if opts.rawratio
            ftemp=repmat('%s\t',[1 nrepcol(i)]);
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
            ftemp=repmat('%s\t',[1 nrepcol(i)]);
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
        
        % Intensities
        if opts.intensity
            ftemp=repmat('%s\t',[1 nrepcol(i)]);
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
        
    end
    
    for i=1:s

        % Normalized Raw Ratios
        if opts.normrawratio
            ftemp=repmat('%s\t',[1 srepcol(i)]);
            frmth=[frmth,ftemp];
            etemp=cell(1,length(exprp{tind(i)}));
            for j=1:length(exprp{tind(i)})
                etemp{j}=['''Normalized Raw Ratio ',exprp{tind(i)}{j},''','];
            end
            evalhead=[evalhead,cell2mat(etemp)];
        end

        % Mean Normalized Raw Ratios
        if opts.meannormrawratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''Mean Normalized Raw Ratio ',names{tind(i)},''','];
        end

        % Median Normalized Raw Ratios
        if opts.mediannormrawratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''Median Normalized Raw Ratio ',names{tind(i)},''','];
        end

        % StDev Normalized Raw Ratios
        if opts.stdevnormrawratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''StDev Normalized Raw Ratio ',names{tind(i)},''','];
        end

        % Normalized Log2 Ratios
        if opts.normlogratio
            ftemp=repmat('%s\t',[1 srepcol(i)]);
            frmth=[frmth,ftemp];
            etemp=cell(1,length(exprp{tind(i)}));
            for j=1:length(exprp{tind(i)})
                etemp{j}=['''Normalized Log2 Ratio ',exprp{tind(i)}{j},''','];
            end
            evalhead=[evalhead,cell2mat(etemp)];
        end

        % Mean Normalized Raw Ratios
        if opts.meannormlogratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''Mean Normalized Log2 Ratio ',names{tind(i)},''','];
        end

        % Median Normalized Raw Ratios
        if opts.mediannormlogratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''Median Normalized Log2 Ratio ',names{tind(i)},''','];
        end

        % StDev Normalized Raw Ratios
        if opts.stdevnormlogratio
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''StDev Normalized Log2 Ratio ',names{tind(i)},''','];
        end

        % Coefficients of Variation
        if opts.cvs
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''CV ',names{tind(i)},''','];
        end

        % Trust Factors
        if opts.trustfactors
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''TF ',names{tind(i)},''','];
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
    % Create some help variables (for the case where we have to calculate some means, medians
    % etc. and they are placed in different cells)
    sigsp=DataCellStat{3}; % Indices
    rawratio=cell(1,t);
    inten=cell(1,t);
    for i=1:t
        rawratio{i}=nan(size(exptab{i}{1},1),size(exptab{i},2));
        for j=1:size(exptab{i},2)
            rawratio{i}(:,j)=exptab{i}{j}(:,3);
        end
    end
    for i=1:t
        inten{i}=nan(size(DataCellNormLo{3}{i}{1},1),size(DataCellNormLo{3}{i},2));
        for j=1:size(DataCellNormLo{3}{i},2)
            inten{i}(:,j)=DataCellNormLo{3}{i}{j};
        end
    end

    % Slide Positions
    if opts.sp
        frmtv=[frmtv,'%u\t'];
        evaltext=[evaltext,'DataCellStat{3}(currentIndex),'];
    end
    % Gene Names
    if opts.genenames
        frmtv=[frmtv,'%s\t'];
        evaltext=[evaltext,'DataCellStat{2}{currentIndex},'];
    end
    % p-values
    if opts.pvalues
        frmtv=[frmtv,'%8.6g\t'];
        evaltext=[evaltext,'DataCellStat{1}(currentIndex,2),'];
    end
    % FDR
    if opts.fdr && ~isempty(DataCellStat{8})
        frmtv=[frmtv,'%8.6g\t'];
        evaltext=[evaltext,'DataCellStat{8}(currentIndex,1),'];
    end
    % q-values
    if opts.qvalues && ~isempty(DataCellStat{8})
        frmtv=[frmtv,'%8.6g\t'];
        evaltext=[evaltext,'DataCellStat{8}(currentIndex,2),'];
    end

    for j=1:t

        % Raw Ratios
        if opts.rawratio
            ftemp=repmat('%8.6g\t',[1 nrepcol(j)]);
            frmtv=[frmtv,ftemp];
            etemp=cell(1,length(exprp{j}));
            for k=1:length(exprp{j})
                etemp{k}=['2.^exptab{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex),3),'];
            end
            evaltext=[evaltext,cell2mat(etemp)];
        end

        % Mean Raw Ratios
        if opts.meanrawratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanmean(2.^rawratio{',num2str(j),'}(sigsp(currentIndex),:),2),'];
        end

        % Median Raw Ratios
        if opts.medianrawratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanmedian(2.^rawratio{',num2str(j),'}(sigsp(currentIndex),:),2),'];
        end

        % StDev Raw Ratios
        if opts.stdevrawratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanstd(2.^rawratio{',num2str(j),'}(sigsp(currentIndex),:),0,2),'];
        end

        % Log Ratios
        if opts.logratio
            ftemp=repmat('%8.6g\t',[1 nrepcol(j)]);
            frmtv=[frmtv,ftemp];
            etemp=cell(1,length(exprp{j}));
            for k=1:length(exprp{j})
                etemp{k}=['exptab{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex),3),'];
            end
            evaltext=[evaltext,cell2mat(etemp)];
        end

        % Mean Log Ratios
        if opts.meanlogratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanmean(rawratio{',num2str(j),'}(sigsp(currentIndex),:),2),'];
        end

        % Median Log Ratios
        if opts.medianlogratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanmedian(rawratio{',num2str(j),'}(sigsp(currentIndex),:),2),'];
        end

        % StDev Log Ratios
        if opts.stdevlogratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanstd(rawratio{',num2str(j),'}(sigsp(currentIndex),:),0,2),'];
        end
        
        % Intensities
        if opts.intensity
            ftemp=repmat('%8.6g\t',[1 nrepcol(j)]);
            frmtv=[frmtv,ftemp];
            etemp=cell(1,length(exprp{j}));
            for k=1:length(exprp{j})
                etemp{k}=['DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)),'];
            end
            evaltext=[evaltext,cell2mat(etemp)];
        end

        % Mean Intensites
        if opts.meanintensity
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanmean(inten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
        end

        % Median Intensity
        if opts.medianintensity
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanmedian(inten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
        end

        % StDev Intensity
        if opts.stdevintensity
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'nanstd(inten{',num2str(j),'}(sigsp(currentIndex),:),0,2),'];
        end
        
    end
    
    for j=1:s

        % Normalized Raw Ratios
        if opts.normrawratio
            ftemp=repmat('%8.6g\t',[1 srepcol(j)]);
            frmtv=[frmtv,ftemp];
            etemp=cell(1,length(exprp{tind(j)}));
            for k=1:length(exprp{tind(j)})
                etemp{k}=['2.^DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),'),'];
            end
            evaltext=[evaltext,cell2mat(etemp)];
        end

        % Mean Normalized Raw Ratios
        if opts.meannormrawratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'mean(2.^DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];
        end

        % Median Normalized Raw Ratios
        if opts.mediannormrawratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'median(2.^DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];
        end

        % StDev Normalized Raw Ratios
        if opts.stdevnormrawratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'std(2.^DataCellStat{5}{',num2str(j),'}(currentIndex,:),0,2),'];
        end

        % Normalized Log2 Ratios
        if opts.normlogratio
            ftemp=repmat('%8.6g\t',[1 srepcol(j)]);
            frmtv=[frmtv,ftemp];
            etemp=cell(1,length(exprp{tind(j)}));
            for k=1:length(exprp{tind(j)})
                etemp{k}=['DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),'),'];
            end
            evaltext=[evaltext,cell2mat(etemp)];
        end

        % Mean Normalized Log2 Ratios
        if opts.meannormlogratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'mean(DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];
        end

        % Median Normalized Log2 Ratios
        if opts.mediannormlogratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'median(DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];
        end

        % StDev Normalized Log2 Ratios
        if opts.stdevnormlogratio
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'std(DataCellStat{5}{',num2str(j),'}(currentIndex,:),0,2),'];
        end

        % Coefficients of Variation
        if opts.cvs
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'std(DataCellStat{5}{',num2str(j),'}(currentIndex,:),0,2)./',...
                'mean(DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];
        end

        % Trust Factors
        if opts.trustfactors
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'DataCellStat{7}(currentIndex,',num2str(j),'),'];
        end

    end

    % Remove last comma (,) from evaltext (will produce error in fprintf otherwise)...
    evaltext=evaltext(1:end-1);
    % ...and add a newline
    frmtv=[frmtv,'\n'];

    % Write the rest of the lines (may the Force be with us...)
    for i=1:length(sigsp)
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
    % p-values
    if opts.pvalues
        headers=[headers,'p-value'];
    end
    % FDR
    if opts.fdr && ~isempty(DataCellStat{8})
        headers=[headers,'FDR'];
    end
    % q-values
    if opts.qvalues && ~isempty(DataCellStat{8})
        headers=[headers,'q-value'];
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
        
    end
    
    for i=1:s

        % Normalized Raw Ratios
        if opts.normrawratio
            for j=1:length(exprp{tind(i)})
                headers=[headers,['Normalized Raw Ratio ' exprp{tind(i)}{j}]];
            end
        end

        % Mean Normalized Raw Ratios
        if opts.meannormrawratio
            headers=[headers,['Mean Normalized Raw Ratio ',names{tind(i)}]];
        end

        % Median Normalized Raw Ratios
        if opts.mediannormrawratio
            headers=[headers,['Median Normalized Raw Ratio ',names{tind(i)}]];
        end

        % StDev Normalized Raw Ratios
        if opts.stdevnormrawratio
            headers=[headers,['StDev Normalized Raw Ratio ',names{tind(i)}]];
        end

        % Normalized Log2 Ratios
        if opts.normlogratio
            for j=1:length(exprp{tind(i)})
                headers=[headers,['Normalized Log2 Ratio ' exprp{tind(i)}{j}]];
            end
        end

        % Mean Normalized Log2 Ratios
        if opts.meannormlogratio
            headers=[headers,['Mean Normalized Log2 Ratio ',names{tind(i)}]];
        end

        % Median Normalized Log2 Ratios
        if opts.mediannormlogratio
            headers=[headers,['Median Normalized Log2 Ratio ',names{tind(i)}]];
        end

        % StDev Normalized Log2 Ratios
        if opts.stdevnormlogratio
            headers=[headers,['StDev Normalized Log2 Ratio ',names{tind(i)}]];
        end

        % Coefficients of Variation
        if opts.cvs
            headers=[headers,['CV ',names{tind(i)},]];
        end

        % Trust Factors
        if opts.trustfactors
            headers=[headers,['TF ',names{tind(i)}]];
        end

    end

    % Create some help variables (for the case where we have to calculate some means, medians
    % etc. and they are placed in different cells)
    sigsp=DataCellStat{3}; % Indices
    rawratio=cell(1,t);
    inten=cell(1,t);
    for i=1:t
        rawratio{i}=nan(size(exptab{i}{1},1),size(exptab{i},2));
        for j=1:size(exptab{i},2)
            rawratio{i}(:,j)=exptab{i}{j}(:,3);
        end
    end
    for i=1:t
        inten{i}=nan(size(DataCellNormLo{3}{i}{1},1),size(DataCellNormLo{3}{i},2));
        for j=1:size(DataCellNormLo{3}{i},2)
            inten{i}(:,j)=DataCellNormLo{3}{i}{j};
        end
    end
    
    finaldata={};
    % Slide Positions
    if opts.sp
        finaldata=[finaldata,DataCellStat{3}];
    end
    % Gene Names
    if opts.genenames
        finaldata=[finaldata,DataCellStat(2)];
    end
    % p-values
    if opts.pvalues
        finaldata=[finaldata,DataCellStat{1}(:,2)];
    end
    % FDR
    if opts.fdr && ~isempty(DataCellStat{8})
        finaldata=[finaldata,DataCellStat{8}(:,1)];
    end
    % q-values
    if opts.qvalues && ~isempty(DataCellStat{8})
        finaldata=[finaldata,DataCellStat{8}(:,2)];
    end

    for j=1:t

        % Raw Ratios
        if opts.rawratio
            finaldata=[finaldata,2.^rawratio{j}(sigsp,:)];
        end

        % Mean Raw Ratios
        if opts.meanrawratio
            finaldata=[finaldata,nanmean(2.^rawratio{j}(sigsp,:),2)];
        end

        % Median Raw Ratios
        if opts.medianrawratio
            finaldata=[finaldata,nanmedian(2.^rawratio{j}(sigsp,:),2)];
        end

        % StDev Raw Ratios
        if opts.stdevrawratio
            finaldata=[finaldata,nanstd(2.^rawratio{j}(sigsp,:),0,2)];
        end

        % Log Ratios
        if opts.logratio
            finaldata=[finaldata,rawratio{j}(sigsp,:)];
        end

        % Mean Log Ratios
        if opts.meanlogratio
            finaldata=[finaldata,nanmean(rawratio{j}(sigsp,:),2)];
        end

        % Median Log Ratios
        if opts.medianlogratio
            finaldata=[finaldata,nanmedian(rawratio{j}(sigsp,:),2)];
        end

        % StDev Log Ratios
        if opts.stdevlogratio
            finaldata=[finaldata,nanstd(rawratio{j}(sigsp,:),0,2)];
        end
        
        % Intensities
        if opts.intensity
            finaldata=[finaldata,inten{j}(sigsp,:)];
        end

        % Mean Intensites
        if opts.meanintensity
            finaldata=[finaldata,nanmean(inten{j}(sigsp,:),2)];
        end

        % Median Intensity
        if opts.medianintensity
            finaldata=[finaldata,nanmedian(inten{j}(sigsp,:),2)];
        end

        % StDev Intensity
        if opts.stdevintensity
            finaldata=[finaldata,nanstd(inten{j}(sigsp,:),0,2)];
        end
        
    end
    
    for j=1:s

        % Normalized Raw Ratios
        if opts.normrawratio
            finaldata=[finaldata,2.^DataCellStat{5}{j}];
        end

        % Mean Normalized Raw Ratios
        if opts.meannormrawratio
            finaldata=[finaldata,mean(2.^DataCellStat{5}{j},2)];
        end

        % Median Normalized Raw Ratios
        if opts.mediannormrawratio
            finaldata=[finaldata,median(2.^DataCellStat{5}{j},2)];
        end

        % StDev Normalized Raw Ratios
        if opts.stdevnormrawratio
            finaldata=[finaldata,std(2.^DataCellStat{5}{j},0,2)];
        end

        % Normalized Log2 Ratios
        if opts.normlogratio
            finaldata=[finaldata,DataCellStat{5}{j}];
        end

        % Mean Normalized Log2 Ratios
        if opts.meannormlogratio
            finaldata=[finaldata,mean(DataCellStat{5}{j},2)];
        end

        % Median Normalized Log2 Ratios
        if opts.mediannormlogratio
            finaldata=[finaldata,median(DataCellStat{5}{j},2)];
        end

        % StDev Normalized Log2 Ratios
        if opts.stdevnormlogratio
            finaldata=[finaldata,std(DataCellStat{5}{j},0,2)];
        end

        % Coefficients of Variation
        if opts.cvs
            finaldata=[finaldata,std(DataCellStat{5}{j},0,2)./mean(DataCellStat{5}{j},2)];
        end

        % Trust Factors
        if opts.trustfactors
            finaldata=[finaldata,DataCellStat{7}(:,j)];
        end

    end
    
    % Create the final cell for exporting
    if opts.genenames && opts.sp % Fix problem of non-arithmetic data
        final_p1=finaldata(:,1);
        final_p1=cell2mat(final_p1);
        final_p1=mat2cell(final_p1,ones(length(final_p1),1),1);
        final_p2=finaldata{:,2};
        final_p3=finaldata(:,3:end);
        final_p3=cell2mat(final_p3);
        final_p3=mat2cell(final_p3,ones(size(final_p3,1),1),ones(size(final_p3,2),1));
        final=[headers;final_p1,final_p2,final_p3];
    elseif opts.genenames && ~opts.sp % Fix problem of non-arithmetic data
        final_p2=finaldata{:,1};
        final_p3=finaldata(:,2:end);
        final_p3=cell2mat(final_p3);
        final_p3=mat2cell(final_p3,ones(size(final_p3,1),1),ones(size(final_p3,2),1));
        final=[headers;final_p2,final_p3];
    else % No problem
        finaldata=cell2mat(finaldata);
        finaldata=mat2cell(finaldata,ones(size(finaldata,1),1),ones(size(finaldata,2),1));
        final=[headers;finaldata];
    end
    
    xlswrite(filename,final)
    
end
