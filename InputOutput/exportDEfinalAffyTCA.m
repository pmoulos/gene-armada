function [headers,finaldata] = exportDEfinalAffyTCA(exprp,names,DataCellNormLo,DataCellStat,tind,opts,filename,prin)

% This function works as a helper for ARMADA to export files. The variable opts
% contains certain export option fields (sse code of ExportDEEditor). When I find some
% time, I will write a complete help.
% opts.outtype='text' for tab delimited textm typ='excel' for excel file (faster but
% probably bigger file), default is text
% prin : true or false, print the file or not (for internal ARMADA use only)

if nargin<6
    opts.sp=true;
    opts.genenames=true;
    opts.pvalues=true;
    opts.qvalues=false;
    opts.fdr=false;
    opts.foldchange=true;
    opts.rawint=false;
    opts.meanrawint=false;
    opts.medianrawint=false;
    opts.stdevrawint=false;
    opts.backint=false;
    opts.meanbackint=false;
    opts.medianbackint=false;
    opts.stdevbackint=false;
    opts.normint=true;
    opts.meannormint=true;
    opts.mediannormint=false;
    opts.stdevnormint=true;
    opts.trustfactors=true;
    opts.cvs=true;
    opts.calls=true;
    opts.scale.natural=false;
    opts.scale.log=false;
    opts.scale.log2=true;
    opts.scale.log10=false;
    opts.outtype='text';
    
    [filename,pathname]=uiputfile('*.txt','Save your gene list');
    if filename==0
        uiwait(msgbox('No file specified','Export list','modal'));
        return
    else
        filename=strcat(pathname,filename);
    end
    prin=true;
end    
if nargin<7
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
    prin=true;
end
if nargin<8
    prin=true;
end

% Condition names
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

        % In natural scale
        if opts.scale.natural
        
            % Raw Intensities
            if opts.rawint
                ftemp=repmat('%s\t',[1 nrepcol(i)]);
                frmth=[frmth,ftemp];
                etemp=cell(1,length(exprp{i}));
                for j=1:length(exprp{i})
                    etemp{j}=['''Raw Intensity (natural) ',exprp{i}{j},''','];
                end
                evalhead=[evalhead,cell2mat(etemp)];
            end

            % Mean Raw Intensities
            if opts.meanrawint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Mean Raw Intensity (natural) ',names{i},''','];
            end

            % Median Raw Intensities
            if opts.medianrawint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Median Raw Intensity (natural) ',names{i},''','];
            end

            % StDev Raw Intensities
            if opts.stdevrawint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''StDev Raw Intensity (natural) ',names{i},''','];
            end

            % Background Adjusted Intensities
            if opts.backint
                ftemp=repmat('%s\t',[1 repcol(i)]);
                frmth=[frmth,ftemp];
                etemp=cell(1,length(exprp{i}));
                for j=1:length(exprp{i})
                    etemp{j}=['''Background Adjusted Intensity (natural) ',exprp{i}{j},''','];
                end
                evalhead=[evalhead,cell2mat(etemp)];
            end

            % Mean Background Adjusted Intensities
            if opts.meanbackint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Mean Background Adjusted Intensity (natural) ',names{i},''','];
            end

            % Median Background Adjusted Intensities
            if opts.medianbackint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Median Background Adjusted Intensity (natural) ',names{i},''','];
            end

            % StDev Background Adjusted Intensities
            if opts.stdevbackint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''StDev Background Adjusted Intensity (natural) ',names{i},''','];
            end
        
        end
        
        % In ln scale
        if opts.scale.log
        
            % Raw Intensities
            if opts.rawint
                ftemp=repmat('%s\t',[1 nrepcol(i)]);
                frmth=[frmth,ftemp];
                etemp=cell(1,length(exprp{i}));
                for j=1:length(exprp{i})
                    etemp{j}=['''Raw Intensity (ln) ',exprp{i}{j},''','];
                end
                evalhead=[evalhead,cell2mat(etemp)];
            end

            % Mean Raw Intensities
            if opts.meanrawint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Mean Raw Intensity (ln) ',names{i},''','];
            end

            % Median Raw Intensities
            if opts.medianrawint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Median Raw Intensity (ln) ',names{i},''','];
            end

            % StDev Raw Intensities
            if opts.stdevrawint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''StDev Raw Intensity (ln) ',names{i},''','];
            end

            % Background Adjusted Intensities
            if opts.backint
                ftemp=repmat('%s\t',[1 repcol(i)]);
                frmth=[frmth,ftemp];
                etemp=cell(1,length(exprp{i}));
                for j=1:length(exprp{i})
                    etemp{j}=['''Background Adjusted Intensity (ln) ',exprp{i}{j},''','];
                end
                evalhead=[evalhead,cell2mat(etemp)];
            end

            % Mean Background Adjusted Intensities
            if opts.meanbackint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Mean Background Adjusted Intensity (ln) ',names{i},''','];
            end

            % Median Background Adjusted Intensities
            if opts.medianbackint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Median Background Adjusted Intensity (ln) ',names{i},''','];
            end

            % StDev Background Adjusted Intensities
            if opts.stdevbackint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''StDev Background Adjusted Intensity (ln) ',names{i},''','];
            end
            
        end
        
        % In log2 scale
        if opts.scale.log2
        
            % Raw Intensities
            if opts.rawint
                ftemp=repmat('%s\t',[1 nrepcol(i)]);
                frmth=[frmth,ftemp];
                etemp=cell(1,length(exprp{i}));
                for j=1:length(exprp{i})
                    etemp{j}=['''Raw Intensity (log2) ',exprp{i}{j},''','];
                end
                evalhead=[evalhead,cell2mat(etemp)];
            end

            % Mean Raw Intensities
            if opts.meanrawint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Mean Raw Intensity (log2) ',names{i},''','];
            end

            % Median Raw Intensities
            if opts.medianrawint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Median Raw Intensity (log2) ',names{i},''','];
            end

            % StDev Raw Intensities
            if opts.stdevrawint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''StDev Raw Intensity (log2) ',names{i},''','];
            end

            % Background Adjusted Intensities
            if opts.backint
                ftemp=repmat('%s\t',[1 repcol(i)]);
                frmth=[frmth,ftemp];
                etemp=cell(1,length(exprp{i}));
                for j=1:length(exprp{i})
                    etemp{j}=['''Background Adjusted Intensity (log2) ',exprp{i}{j},''','];
                end
                evalhead=[evalhead,cell2mat(etemp)];
            end

            % Mean Background Adjusted Intensities
            if opts.meanbackint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Mean Background Adjusted Intensity (log2) ',names{i},''','];
            end

            % Median Background Adjusted Intensities
            if opts.medianbackint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Median Background Adjusted Intensity (log2) ',names{i},''','];
            end

            % StDev Background Adjusted Intensities
            if opts.stdevbackint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''StDev Background Adjusted Intensity (log2) ',names{i},''','];
            end

        end
        
        % In log10 scale
        if opts.scale.log10
        
            % Raw Intensities
            if opts.rawint
                ftemp=repmat('%s\t',[1 nrepcol(i)]);
                frmth=[frmth,ftemp];
                etemp=cell(1,length(exprp{i}));
                for j=1:length(exprp{i})
                    etemp{j}=['''Raw Intensity (log10) ',exprp{i}{j},''','];
                end
                evalhead=[evalhead,cell2mat(etemp)];
            end

            % Mean Raw Intensities
            if opts.meanrawint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Mean Raw Intensity (log10) ',names{i},''','];
            end

            % Median Raw Intensities
            if opts.medianrawint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Median Raw Intensity (log10) ',names{i},''','];
            end

            % StDev Raw Intensities
            if opts.stdevrawint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''StDev Raw Intensity (log10) ',names{i},''','];
            end

            % Background Adjusted Intensities
            if opts.backint
                ftemp=repmat('%s\t',[1 repcol(i)]);
                frmth=[frmth,ftemp];
                etemp=cell(1,length(exprp{i}));
                for j=1:length(exprp{i})
                    etemp{j}=['''Background Adjusted Intensity (log10) ',exprp{i}{j},''','];
                end
                evalhead=[evalhead,cell2mat(etemp)];
            end

            % Mean Background Adjusted Intensities
            if opts.meanbackint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Mean Background Adjusted Intensity (log10) ',names{i},''','];
            end

            % Median Background Adjusted Intensities
            if opts.medianbackint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Median Background Adjusted Intensity (log10) ',names{i},''','];
            end

            % StDev Background Adjusted Intensities
            if opts.stdevbackint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''StDev Background Adjusted Intensity (log10) ',names{i},''','];
            end

        end
        
        % Calls
        if opts.calls && ~isempty(DataCellNormLo{6})
            ftemp=repmat('%s\t',[1 repcol(i)]);
            frmth=[frmth,ftemp];
            etemp=cell(1,length(exprp{i}));
            for j=1:length(exprp{i})
                etemp{j}=['''Present Calls ',exprp{i}{j},''','];
            end
            evalhead=[evalhead,cell2mat(etemp)];
        end

    end
    
    for i=1:s

        % In natural scale
        if opts.scale.natural

            % Adjusted Normalized Intensities
            if opts.normint
                ftemp=repmat('%s\t',[1 srepcol(i)]);
                frmth=[frmth,ftemp];
                etemp=cell(1,length(exprp{i}));
                for j=1:length(exprp{i})
                    etemp{j}=['''Adjusted Normalized Intensity (natural) ',exprp{i}{j},''','];
                end
                evalhead=[evalhead,cell2mat(etemp)];
            end

            % Mean Adjusted Normalized Intensities
            if opts.meannormint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Mean Adjusted Normalized Intensity (natural) ',names{i},''','];
            end

            % Median Adjusted Normalized Intensities
            if opts.mediannormint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Median Adjusted Normalized Intensity (natural) ',names{i},''','];
            end

            % StDev Adjusted Normalized Intensities
            if opts.stdevnormint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''StDev Adjusted Normalized Intensity (natural) ',names{i},''','];
            end
        
        end
        
        % In ln scale
        if opts.scale.log

            % Adjusted Normalized Intensities
            if opts.normint
                ftemp=repmat('%s\t',[1 srepcol(i)]);
                frmth=[frmth,ftemp];
                etemp=cell(1,length(exprp{i}));
                for j=1:length(exprp{i})
                    etemp{j}=['''Adjusted Normalized Intensity (ln) ',exprp{i}{j},''','];
                end
                evalhead=[evalhead,cell2mat(etemp)];
            end

            % Mean Adjusted Normalized Intensities
            if opts.meannormint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Mean Adjusted Normalized Intensity (ln) ',names{i},''','];
            end

            % Median Adjusted Normalized Intensities
            if opts.mediannormint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Median Adjusted Normalized Intensity (ln) ',names{i},''','];
            end

            % StDev Adjusted Normalized Intensities
            if opts.stdevnormint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''StDev Adjusted Normalized Intensity (ln) ',names{i},''','];
            end
        
        end
        
        % In log2 scale
        if opts.scale.log2

            % Adjusted Normalized Intensities
            if opts.normint
                ftemp=repmat('%s\t',[1 srepcol(i)]);
                frmth=[frmth,ftemp];
                etemp=cell(1,length(exprp{i}));
                for j=1:length(exprp{i})
                    etemp{j}=['''Adjusted Normalized Intensity (log2) ',exprp{i}{j},''','];
                end
                evalhead=[evalhead,cell2mat(etemp)];
            end

            % Mean Adjusted Normalized Intensities
            if opts.meannormint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Mean Adjusted Normalized Intensity (log2) ',names{i},''','];
            end

            % Median Adjusted Normalized Intensities
            if opts.mediannormint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Median Adjusted Normalized Intensity (log2) ',names{i},''','];
            end

            % StDev Adjusted Normalized Intensities
            if opts.stdevnormint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''StDev Adjusted Normalized Intensity (log2) ',names{i},''','];
            end
        
        end
        
        % In log10 scale
        if opts.scale.log10

            % Adjusted Normalized Intensities
            if opts.normint
                ftemp=repmat('%s\t',[1 srepcol(i)]);
                frmth=[frmth,ftemp];
                etemp=cell(1,length(exprp{i}));
                for j=1:length(exprp{i})
                    etemp{j}=['''Adjusted Normalized Intensity (log10) ',exprp{i}{j},''','];
                end
                evalhead=[evalhead,cell2mat(etemp)];
            end

            % Mean Adjusted Normalized Intensities
            if opts.meannormint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Mean Adjusted Normalized Intensity (log10) ',names{i},''','];
            end

            % Median Adjusted Normalized Intensities
            if opts.mediannormint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''Median Adjusted Normalized Intensity (log10) ',names{i},''','];
            end

            % StDev Adjusted Normalized Intensities
            if opts.stdevnormint
                frmth=[frmth,'%s\t'];
                evalhead=[evalhead,'''StDev Adjusted Normalized Intensity (log10) ',names{i},''','];
            end
        
        end

        % Coefficients of Variation
        if opts.cvs
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''CV ',names{i},''','];
        end

        % Trust Factors
        if opts.trustfactors
            frmth=[frmth,'%s\t'];
            evalhead=[evalhead,'''TF ',names{i},''','];
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
    rawinten=cell(1,t);
    backinten=cell(1,t);
    for i=1:t
        rawinten{i}=nan(size(DataCellNormLo{1}{i}{1},1),size(DataCellNormLo{1}{i},2));
        for j=1:size(DataCellNormLo{1}{i},2)
            rawinten{i}(:,j)=DataCellNormLo{1}{i}{j};
        end
    end
    for i=1:t
        backinten{i}=nan(size(DataCellNormLo{3}{i}{1},1),size(DataCellNormLo{3}{i},2));
        for j=1:size(DataCellNormLo{3}{i},2)
            backinten{i}(:,j)=DataCellNormLo{3}{i}{j};
        end
    end
    
    % Get the used scale so as to make recalculations
    scal=DataCellNormLo{5}{4};

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
        
        % In natural scale
        if opts.scale.natural
            
            % Raw Intensities
            if opts.rawint
                ftemp=repmat('%8.6g\t',[1 nrepcol(j)]);
                frmtv=[frmtv,ftemp];
                etemp=cell(1,length(exprp{j}));
                for k=1:length(exprp{j})
                    switch scal
                        case 'natural'
                            etemp{k}=['DataCellNormLo{1}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)),'];
                        case 'log'
                            etemp{k}=['exp(DataCellNormLo{1}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex))),'];
                        case 'log2'
                            etemp{k}=['2.^DataCellNormLo{1}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)),'];
                        case 'log10'
                            etemp{k}=['10.^DataCellNormLo{1}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)),'];
                    end
                end
                evaltext=[evaltext,cell2mat(etemp)];
            end

            % Mean Raw Intensities
            if opts.meanrawint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmean(rawinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmean(exp(rawinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmean(2.^rawinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmean(10.^rawinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
                end
            end

            % Median Raw Intensitites
            if opts.medianrawint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmedian(rawinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmedian(exp(rawinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmedian(2.^rawinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmedian(10.^rawinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
                end
            end

            % StDev Raw Intensitites
            if opts.stdevrawint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanstd(rawinten{',num2str(j),'}(sigsp(currentIndex),:),0,2),'];
                    case 'log'
                        evaltext=[evaltext,'nanstd(exp(rawinten{',num2str(j),'}(sigsp(currentIndex),:)),0,2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanstd(2.^rawinten{',num2str(j),'}(sigsp(currentIndex),:),0,2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanstd(10.^rawinten{',num2str(j),'}(sigsp(currentIndex),:),0,2),'];
                end
            end
            
            % Background Adjusted Intensities
            if opts.backint
                ftemp=repmat('%8.6g\t',[1 repcol(j)]);
                frmtv=[frmtv,ftemp];
                etemp=cell(1,length(exprp{j}));
                for k=1:length(exprp{j})
                    switch scal
                        case 'natural'
                            etemp{k}=['DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)),'];
                        case 'log'
                            etemp{k}=['exp(DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex))),'];
                        case 'log2'
                            etemp{k}=['2.^DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)),'];
                        case 'log10'
                            etemp{k}=['10.^DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)),'];
                    end
                end
                evaltext=[evaltext,cell2mat(etemp)];
            end

            % Mean Background Adjusted Intensities
            if opts.meanbackint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmean(backinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmean(exp(backinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmean(2.^backinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmean(10.^backinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
                end
            end

            % Median Background Adjusted Intensitites
            if opts.medianbackint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmedian(backinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmedian(exp(backinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmedian(2.^backinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmedian(10.^backinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
                end
            end

            % StDev Background Adjusted Intensitites
            if opts.stdevbackint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanstd(backinten{',num2str(j),'}(sigsp(currentIndex),:),0,2),'];
                    case 'log'
                        evaltext=[evaltext,'nanstd(exp(backinten{',num2str(j),'}(sigsp(currentIndex),:)),0,2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanstd(2.^backinten{',num2str(j),'}(sigsp(currentIndex),:),0,2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanstd(10.^backinten{',num2str(j),'}(sigsp(currentIndex),:),0,2),'];
                end
            end
            
        end
        
        % In ln scale
        if opts.scale.log
            
            % Raw Intensities
            if opts.rawint
                ftemp=repmat('%8.6g\t',[1 nrepcol(j)]);
                frmtv=[frmtv,ftemp];
                etemp=cell(1,length(exprp{j}));
                for k=1:length(exprp{j})
                    switch scal
                        case 'natural'
                            etemp{k}=['log(DataCellNormLo{1}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex))),'];
                        case 'log'
                            etemp{k}=['DataCellNormLo{1}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)),'];
                        case 'log2'
                            etemp{k}=['log(2.^DataCellNormLo{1}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex))),'];
                        case 'log10'
                            etemp{k}=['log(10.^DataCellNormLo{1}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex))),'];
                    end
                end
                evaltext=[evaltext,cell2mat(etemp)];
            end

            % Mean Raw Intensities
            if opts.meanrawint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmean(log(rawinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmean(rawinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmean(log(2.^rawinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmean(log(10.^rawinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                end
            end

            % Median Raw Intensitites
            if opts.medianrawint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmedian(log(rawinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmedian(rawinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmedian(log(2.^rawinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmedian(log(10.^rawinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                end
            end

            % StDev Raw Intensitites
            if opts.stdevrawint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanstd(log(rawinten{',num2str(j),'}(sigsp(currentIndex),:)),0,2),'];
                    case 'log'
                        evaltext=[evaltext,'nanstd(rawinten{',num2str(j),'}(sigsp(currentIndex),:),0,2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanstd(log(2.^rawinten{',num2str(j),'}(sigsp(currentIndex),:)),0,2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanstd(log(10.^rawinten{',num2str(j),'}(sigsp(currentIndex),:)),0,2),'];
                end
            end
            
            % Background Adjusted Intensities
            if opts.backint
                ftemp=repmat('%8.6g\t',[1 repcol(j)]);
                frmtv=[frmtv,ftemp];
                etemp=cell(1,length(exprp{j}));
                for k=1:length(exprp{j})
                    switch scal
                        case 'natural'
                            etemp{k}=['log(DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex))),'];
                        case 'log'
                            etemp{k}=['DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)),'];
                        case 'log2'
                            etemp{k}=['log(2.^DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex))),'];
                        case 'log10'
                            etemp{k}=['log(10.^DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex))),'];
                    end
                end
                evaltext=[evaltext,cell2mat(etemp)];
            end

            % Mean Background Adjusted Intensities
            if opts.meanbackint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmean(log(backinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmean(backinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmean(log(2.^backinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmean(log(10.^backinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                end
            end

            % Median Background Adjusted Intensitites
            if opts.medianbackint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmedian(log(backinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmedian(backinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmedian(log(2.^backinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmedian(log(10.^backinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                end
            end

            % StDev Background Adjusted Intensitites
            if opts.stdevbackint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanstd(log(backinten{',num2str(j),'}(sigsp(currentIndex),:)),0,2),'];
                    case 'log'
                        evaltext=[evaltext,'nanstd(backinten{',num2str(j),'}(sigsp(currentIndex),:),0,2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanstd(log(2.^backinten{',num2str(j),'}(sigsp(currentIndex),:)),0,2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanstd(log(10.^backinten{',num2str(j),'}(sigsp(currentIndex),:)),0,2),'];
                end
            end

        end
        
        % In log2 scale
        if opts.scale.log2
            
            % Raw Intensities
            if opts.rawint
                ftemp=repmat('%8.6g\t',[1 nrepcol(j)]);
                frmtv=[frmtv,ftemp];
                etemp=cell(1,length(exprp{j}));
                for k=1:length(exprp{j})
                    switch scal
                        case 'natural'
                            etemp{k}=['log2(DataCellNormLo{1}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex))),'];
                        case 'log'
                            etemp{k}=['log2(exp(DataCellNormLo{1}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)))),'];
                        case 'log2'
                            etemp{k}=['DataCellNormLo{1}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)),'];
                        case 'log10'
                            etemp{k}=['log2(10.^DataCellNormLo{1}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex))),'];
                    end
                end
                evaltext=[evaltext,cell2mat(etemp)];
            end

            % Mean Raw Intensities
            if opts.meanrawint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmean(log2(rawinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmean(log2(exp(rawinten{',num2str(j),'}(sigsp(currentIndex),:))),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmean(rawinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmean(log2(10.^rawinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                end
            end

            % Median Raw Intensitites
            if opts.medianrawint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmedian(log2(rawinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmedian(log2(exp(rawinten{',num2str(j),'}(sigsp(currentIndex),:))),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmedian(rawinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmedian(log2(10.^rawinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                end
            end

            % StDev Raw Intensitites
            if opts.stdevrawint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanstd(log2(rawinten{',num2str(j),'}(sigsp(currentIndex),:)),0,2),'];
                    case 'log'
                        evaltext=[evaltext,'nanstd(log2(exp(rawinten{',num2str(j),'}(sigsp(currentIndex),:))),0,2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanstd(rawinten{',num2str(j),'}(sigsp(currentIndex),:),0,2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanstd(log2(10.^rawinten{',num2str(j),'}(sigsp(currentIndex),:)),0,2),'];
                end
            end
            
            % Background Adjusted Intensities
            if opts.backint
                ftemp=repmat('%8.6g\t',[1 repcol(j)]);
                frmtv=[frmtv,ftemp];
                etemp=cell(1,length(exprp{j}));
                for k=1:length(exprp{j})
                    switch scal
                        case 'natural'
                            etemp{k}=['log2(DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex))),'];
                        case 'log'
                            etemp{k}=['log2(exp(DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)))),'];
                        case 'log2'
                            etemp{k}=['DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)),'];
                        case 'log10'
                            etemp{k}=['log2(10.^DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex))),'];
                    end
                end
                evaltext=[evaltext,cell2mat(etemp)];
            end

            % Mean Background Adjusted Intensities
            if opts.meanbackint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmean(log2(backinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmean(log2(exp(backinten{',num2str(j),'}(sigsp(currentIndex),:))),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmean(backinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmean(log2(10.^backinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                end
            end

            % Median Background Adjusted Intensitites
            if opts.medianbackint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmedian(log2(backinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmedian(log2(exp(backinten{',num2str(j),'}(sigsp(currentIndex),:))),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmedian(backinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmedian(log2(10.^backinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                end
            end

            % StDev Background Adjusted Intensitites
            if opts.stdevbackint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanstd(log2(backinten{',num2str(j),'}(sigsp(currentIndex),:)),0,2),'];
                    case 'log'
                        evaltext=[evaltext,'nanstd(log2(exp(backinten{',num2str(j),'}(sigsp(currentIndex),:))),0,2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanstd(backinten{',num2str(j),'}(sigsp(currentIndex),:),0,2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanstd(log2(10.^backinten{',num2str(j),'}(sigsp(currentIndex),:)),0,2),'];
                end
            end
            
        end
        
        % In log10 scale
        if opts.scale.log10
            
            % Raw Intensities
            if opts.rawint
                ftemp=repmat('%8.6g\t',[1 nrepcol(j)]);
                frmtv=[frmtv,ftemp];
                etemp=cell(1,length(exprp{j}));
                for k=1:length(exprp{j})
                    switch scal
                        case 'natural'
                            etemp{k}=['log10(DataCellNormLo{1}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex))),'];
                        case 'log'
                            etemp{k}=['log10(exp(DataCellNormLo{1}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)))),'];
                        case 'log2'
                            etemp{k}=['log10(2.^DataCellNormLo{1}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex))),'];
                        case 'log10'
                            etemp{k}=['DataCellNormLo{1}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)),'];
                    end
                end
                evaltext=[evaltext,cell2mat(etemp)];
            end

            % Mean Raw Intensities
            if opts.meanrawint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmean(log10(rawinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmean(log10(exp(rawinten{',num2str(j),'}(sigsp(currentIndex),:))),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmean(log10(2.^rawinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmean(rawinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
                end
            end

            % Median Raw Intensitites
            if opts.medianrawint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmedian(log10(rawinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmedian(log10(exp(rawinten{',num2str(j),'}(sigsp(currentIndex),:))),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmedian(log10(2.^rawinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmedian(rawinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
                end
            end

            % StDev Raw Intensitites
            if opts.stdevrawint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanstd(log10(rawinten{',num2str(j),'}(sigsp(currentIndex),:)),0,2),'];
                    case 'log'
                        evaltext=[evaltext,'nanstd(log10(exp(rawinten{',num2str(j),'}(sigsp(currentIndex),:))),0,2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanstd(log10(2.^rawinten{',num2str(j),'}(sigsp(currentIndex),:)),0,2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanstd(rawinten{',num2str(j),'}(sigsp(currentIndex),:),0,2),'];
                end
            end
            
            % Background Adjusted Intensities
            if opts.backint
                ftemp=repmat('%8.6g\t',[1 repcol(j)]);
                frmtv=[frmtv,ftemp];
                etemp=cell(1,length(exprp{j}));
                for k=1:length(exprp{j})
                    switch scal
                        case 'natural'
                            etemp{k}=['log10(DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex))),'];
                        case 'log'
                            etemp{k}=['log10(exp(DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)))),'];
                        case 'log2'
                            etemp{k}=['log10(2.^DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex))),'];
                        case 'log10'
                            etemp{k}=['DataCellNormLo{3}{',num2str(j),'}{',num2str(k),'}(sigsp(currentIndex)),'];
                    end
                end
                evaltext=[evaltext,cell2mat(etemp)];
            end

            % Mean Background Adjusted Intensities
            if opts.meanbackint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmean(log10(backinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmean(log10(exp(backinten{',num2str(j),'}(sigsp(currentIndex),:))),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmean(log10(2.^backinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmean(backinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
                end
            end

            % Median Background Adjusted Intensitites
            if opts.medianbackint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmedian(log10(backinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmedian(log10(exp(backinten{',num2str(j),'}(sigsp(currentIndex),:))),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmedian(log10(2.^backinten{',num2str(j),'}(sigsp(currentIndex),:)),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmedian(backinten{',num2str(j),'}(sigsp(currentIndex),:),2),'];
                end
            end

            % StDev Background Adjusted Intensitites
            if opts.stdevbackint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanstd(log10(backinten{',num2str(j),'}(sigsp(currentIndex),:)),0,2),'];
                    case 'log'
                        evaltext=[evaltext,'nanstd(log10(exp(backinten{',num2str(j),'}(sigsp(currentIndex),:))),0,2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanstd(log10(2.^backinten{',num2str(j),'}(sigsp(currentIndex),:)),0,2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanstd(backinten{',num2str(j),'}(sigsp(currentIndex),:),0,2),'];
                end
            end
            
        end
        
        % Present Calls
        if opts.calls && ~isempty(DataCellNormLo{6})
            ftemp=repmat('%c\t',[1 repcol(j)]);
            frmtv=[frmtv,ftemp];
            etemp=cell(1,length(exprp{j}));
            for k=1:length(exprp{j})
                etemp{k}=['DataCellNormLo{6}{',num2str(j),'}{',num2str(k),'}{sigsp(currentIndex)},'];
            end
            evaltext=[evaltext,cell2mat(etemp)];
        end
        
    end
    
    for j=1:s
        
        % In natural scale
        if opts.scale.natural
                        
            % Normalized Intensities
            if opts.normint
                ftemp=repmat('%8.6g\t',[1 srepcol(j)]);
                frmtv=[frmtv,ftemp];
                etemp=cell(1,length(exprp{j}));
                for k=1:length(exprp{j})
                    switch scal
                        case 'natural'
                            etemp{k}=['DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),'),'];
                        case 'log'
                            etemp{k}=['exp(DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),')),'];
                        case 'log2'
                            etemp{k}=['2.^DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),'),'];
                        case 'log10'
                            etemp{k}=['10.^DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),'),'];
                    end
                end
                evaltext=[evaltext,cell2mat(etemp)];
            end

            % Mean Normalized Intensities
            if opts.meannormint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmean(DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmean(exp(DataCellStat{5}{',num2str(j),'}(currentIndex,:)),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmean(2.^DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmean(10.^DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];
                end
            end

            % Median Normalized Intensitites
            if opts.mediannormint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'median(DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];
                    case 'log'
                        evaltext=[evaltext,'median(exp(DataCellStat{5}{',num2str(j),'}(currentIndex,:)),2),'];
                    case 'log2'
                        evaltext=[evaltext,'median(2.^DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'median(10.^DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];
                end
            end

            % StDev Normalized Intensitites
            if opts.stdevnormint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'std(DataCellStat{5}{',num2str(j),'}(currentIndex,:),0,2),'];
                    case 'log'
                        evaltext=[evaltext,'std(exp(DataCellStat{5}{',num2str(j),'}(currentIndex,:)),0,2),'];
                    case 'log2'
                        evaltext=[evaltext,'std(2.^DataCellStat{5}{',num2str(j),'}(currentIndex,:),0,2),'];    
                    case 'log10'
                        evaltext=[evaltext,'std(10.^DataCellStat{5}{',num2str(j),'}(currentIndex,:),0,2),'];
                end
            end
            
        end
        
        % In ln scale
        if opts.scale.log
            
            % Normalized Intensities
            if opts.normint
                ftemp=repmat('%8.6g\t',[1 srepcol(j)]);
                frmtv=[frmtv,ftemp];
                etemp=cell(1,length(exprp{j}));
                for k=1:length(exprp{j})
                    switch scal
                        case 'natural'
                            etemp{k}=['log(DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),')),'];
                        case 'log'
                            etemp{k}=['DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),'),'];
                        case 'log2'
                            etemp{k}=['log(2.^DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),')),'];
                        case 'log10'
                            etemp{k}=['log(10.^DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),')),'];
                    end
                end
                evaltext=[evaltext,cell2mat(etemp)];
            end

            % Mean Normalized Intensities
            if opts.meannormint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmean(log(DataCellStat{5}{',num2str(j),'}(currentIndex,:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmean(DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmean(log(2.^DataCellStat{5}{',num2str(j),'}(currentIndex,:)),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmean(log(10.^DataCellStat{5}{',num2str(j),'}(currentIndex,:)),2),'];
                end
            end

            % Median Normalized Intensitites
            if opts.mediannormint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'median(log(DataCellStat{5}{',num2str(j),'}(currentIndex,:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'median(DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];
                    case 'log2'
                        evaltext=[evaltext,'median(log(2.^DataCellStat{5}{',num2str(j),'}(currentIndex,:)),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'median(log(10.^DataCellStat{5}{',num2str(j),'}(currentIndex,:)),2),'];
                end
            end

            % StDev Normalized Intensitites
            if opts.stdevnormint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'std(log(DataCellStat{5}{',num2str(j),'}(currentIndex,:)),0,2),'];
                    case 'log'
                        evaltext=[evaltext,'std(DataCellStat{5}{',num2str(j),'}(currentIndex,:),0,2),'];
                    case 'log2'
                        evaltext=[evaltext,'std(log(2.^DataCellStat{5}{',num2str(j),'}(currentIndex,:)),0,2),'];    
                    case 'log10'
                        evaltext=[evaltext,'std(log(10.^DataCellStat{5}{',num2str(j),'}(currentIndex,:)),0,2),'];
                end
            end
            
        end
        
        % In log2 scale
        if opts.scale.log2

            % Normalized Intensities
            if opts.normint
                ftemp=repmat('%8.6g\t',[1 srepcol(j)]);
                frmtv=[frmtv,ftemp];
                etemp=cell(1,length(exprp{j}));
                for k=1:length(exprp{j})
                    switch scal
                        case 'natural'
                            etemp{k}=['log2(DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),')),'];
                        case 'log'
                            etemp{k}=['log2(exp(DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),'))),'];
                        case 'log2'
                            etemp{k}=['DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),'),'];
                        case 'log10'
                            etemp{k}=['log2(10.^DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),')),'];
                    end
                end
                evaltext=[evaltext,cell2mat(etemp)];
            end

            % Mean Normalized Intensities
            if opts.meannormint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmean(log2(DataCellStat{5}{',num2str(j),'}(currentIndex,:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmean(log2(exp(DataCellStat{5}{',num2str(j),'}(currentIndex,:))),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmean(DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmean(log2(10.^DataCellStat{5}{',num2str(j),'}(currentIndex,:)),2),'];
                end
            end

            % Median Normalized Intensitites
            if opts.mediannormint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'median(log2(DataCellStat{5}{',num2str(j),'}(currentIndex,:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'median(log2(exp(DataCellStat{5}{',num2str(j),'}(currentIndex,:))),2),'];
                    case 'log2'
                        evaltext=[evaltext,'median(DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'median(log2(10.^DataCellStat{5}{',num2str(j),'}(currentIndex,:)),2),'];
                end
            end

            % StDev Normalized Intensitites
            if opts.stdevnormint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'std(log2(DataCellStat{5}{',num2str(j),'}(currentIndex,:)),0,2),'];
                    case 'log'
                        evaltext=[evaltext,'std(log2(exp(DataCellStat{5}{',num2str(j),'}(currentIndex,:))),0,2),'];
                    case 'log2'
                        evaltext=[evaltext,'std(DataCellStat{5}{',num2str(j),'}(currentIndex,:),0,2),'];    
                    case 'log10'
                        evaltext=[evaltext,'std(log2(10.^DataCellStat{5}{',num2str(j),'}(currentIndex,:)),0,2),'];
                end
            end
            
        end
        
        % In log10 scale
        if opts.scale.log10
            
            % Normalized Intensities
            if opts.normint
                ftemp=repmat('%8.6g\t',[1 srepcol(j)]);
                frmtv=[frmtv,ftemp];
                etemp=cell(1,length(exprp{j}));
                for k=1:length(exprp{j})
                    switch scal
                        case 'natural'
                            etemp{k}=['log10(DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),')),'];
                        case 'log'
                            etemp{k}=['log10(exp(DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),'))),'];
                        case 'log2'
                            etemp{k}=['log10(2.^DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),')),'];
                        case 'log10'
                            etemp{k}=['DataCellStat{5}{',num2str(j),'}(currentIndex,',num2str(k),'),'];
                    end
                end
                evaltext=[evaltext,cell2mat(etemp)];
            end

            % Mean Normalized Intensities
            if opts.meannormint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'nanmean(log10(DataCellStat{5}{',num2str(j),'}(currentIndex,:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'nanmean(log10(exp(DataCellStat{5}{',num2str(j),'}(currentIndex,:))),2),'];
                    case 'log2'
                        evaltext=[evaltext,'nanmean(log10(2.^DataCellStat{5}{',num2str(j),'}(currentIndex,:)),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'nanmean(DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];
                end
            end

            % Median Normalized Intensitites
            if opts.mediannormint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'median(log10(DataCellStat{5}{',num2str(j),'}(currentIndex,:)),2),'];
                    case 'log'
                        evaltext=[evaltext,'median(log10(exp(DataCellStat{5}{',num2str(j),'}(currentIndex,:))),2),'];
                    case 'log2'
                        evaltext=[evaltext,'median(log10(2.^DataCellStat{5}{',num2str(j),'}(currentIndex,:)),2),'];    
                    case 'log10'
                        evaltext=[evaltext,'median(DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];
                end
            end

            % StDev Normalized Intensitites
            if opts.stdevnormint
                frmtv=[frmtv,'%8.6g\t'];
                switch scal
                    case 'natural'
                        evaltext=[evaltext,'std(log10(DataCellStat{5}{',num2str(j),'}(currentIndex,:)),0,2),'];
                    case 'log'
                        evaltext=[evaltext,'std(log10(exp(DataCellStat{5}{',num2str(j),'}(currentIndex,:))),0,2),'];
                    case 'log2'
                        evaltext=[evaltext,'std(log10(2.^DataCellStat{5}{',num2str(j),'}(currentIndex,:)),0,2),'];    
                    case 'log10'
                        evaltext=[evaltext,'std(DataCellStat{5}{',num2str(j),'}(currentIndex,:),0,2),'];
                end
            end
            
        end
       
        % Coefficients of Variation
        if opts.cvs
            frmtv=[frmtv,'%8.6g\t'];
            evaltext=[evaltext,'std(DataCellStat{5}{',num2str(j),'}(currentIndex,:),0,2)./',...
                'nanmean(DataCellStat{5}{',num2str(j),'}(currentIndex,:),2),'];
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
    headers=[];
    finaldata=[];
    
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
        
        % In natural scale
        if opts.scale.natural
        
            % Raw Intensities
            if opts.rawint
                for j=1:length(exprp{i})
                    headers=[headers,['Raw Intensity (natural) ' exprp{i}{j}]];
                end
            end

            % Mean Raw Intensities
            if opts.meanrawint
                headers=[headers,['Mean Raw Intensity (natural) ',names{i}]];
            end

            % Median Raw Intensities
            if opts.medianrawint
                headers=[headers,['Median Raw Intensity (natural) ',names{i}]];
            end

            % StDev Raw Intensities
            if opts.stdevrawint
                headers=[headers,['StDev Raw Intensity (natural) ',names{i}]];
            end

            % Background Adjusted Intensities
            if opts.backint
                for j=1:length(exprp{i})
                    headers=[headers,['Background Adjusted Intensity (natural) ' exprp{i}{j}]];
                end
            end

            % Mean Background Adjusted Intensities
            if opts.meanbackint
                headers=[headers,['Mean Background Adjusted Intensity (natural) ',names{i}]];
            end

            % Median Background Adjusted Intensities
            if opts.medianbackint
                headers=[headers,['Median Background Adjusted Intensity (natural) ',names{i}]];
            end

            % StDev Background Adjusted Intensities
            if opts.stdevbackint
                headers=[headers,['StDev Background Adjusted Intensity (natural) ',names{i}]];
            end
        
        end
        
        % In ln scale
        if opts.scale.log
        
            % Raw Intensities
            if opts.rawint
                for j=1:length(exprp{i})
                    headers=[headers,['Raw Intensity (ln) ' exprp{i}{j}]];
                end
            end

            % Mean Raw Intensities
            if opts.meanrawint
                headers=[headers,['Mean Raw Intensity (ln) ',names{i}]];
            end

            % Median Raw Intensities
            if opts.medianrawint
                headers=[headers,['Median Raw Intensity (ln) ',names{i}]];
            end

            % StDev Raw Intensities
            if opts.stdevrawint
                headers=[headers,['StDev Raw Intensity (ln) ',names{i}]];
            end

            % Background Adjusted Intensities
            if opts.backint
                for j=1:length(exprp{i})
                    headers=[headers,['Background Adjusted Intensity (ln) ' exprp{i}{j}]];
                end
            end

            % Mean Background Adjusted Intensities
            if opts.meanbackint
                headers=[headers,['Mean Background Adjusted Intensity (ln) ',names{i}]];
            end

            % Median Background Adjusted Intensities
            if opts.medianbackint
                headers=[headers,['Median Background Adjusted Intensity (ln) ',names{i}]];
            end

            % StDev Background Adjusted Intensities
            if opts.stdevbackint
                headers=[headers,['StDev Background Adjusted Intensity (ln) ',names{i}]];
            end
        
        end
        
        % In log2 scale
        if opts.scale.log2
        
            % Raw Intensities
            if opts.rawint
                for j=1:length(exprp{i})
                    headers=[headers,['Raw Intensity (log2) ' exprp{i}{j}]];
                end
            end

            % Mean Raw Intensities
            if opts.meanrawint
                headers=[headers,['Mean Raw Intensity (log2) ',names{i}]];
            end

            % Median Raw Intensities
            if opts.medianrawint
                headers=[headers,['Median Raw Intensity (log2) ',names{i}]];
            end

            % StDev Raw Intensities
            if opts.stdevrawint
                headers=[headers,['StDev Raw Intensity (log2) ',names{i}]];
            end

            % Background Adjusted Intensities
            if opts.backint
                for j=1:length(exprp{i})
                    headers=[headers,['Background Adjusted Intensity (log2) ' exprp{i}{j}]];
                end
            end

            % Mean Background Adjusted Intensities
            if opts.meanbackint
                headers=[headers,['Mean Background Adjusted Intensity (log2) ',names{i}]];
            end

            % Median Background Adjusted Intensities
            if opts.medianbackint
                headers=[headers,['Median Background Adjusted Intensity (log2) ',names{i}]];
            end

            % StDev Background Adjusted Intensities
            if opts.stdevbackint
                headers=[headers,['StDev Background Adjusted Intensity (log2) ',names{i}]];
            end
        
        end
        
        % In log2 scale
        if opts.scale.log10
        
            % Raw Intensities
            if opts.rawint
                for j=1:length(exprp{i})
                    headers=[headers,['Raw Intensity (log10) ' exprp{i}{j}]];
                end
            end

            % Mean Raw Intensities
            if opts.meanrawint
                headers=[headers,['Mean Raw Intensity (log10) ',names{i}]];
            end

            % Median Raw Intensities
            if opts.medianrawint
                headers=[headers,['Median Raw Intensity (log10) ',names{i}]];
            end

            % StDev Raw Intensities
            if opts.stdevrawint
                headers=[headers,['StDev Raw Intensity (log10) ',names{i}]];
            end

            % Background Adjusted Intensities
            if opts.backint
                for j=1:length(exprp{i})
                    headers=[headers,['Background Adjusted Intensity (log10) ' exprp{i}{j}]];
                end
            end

            % Mean Background Adjusted Intensities
            if opts.meanbackint
                headers=[headers,['Mean Background Adjusted Intensity (log10) ',names{i}]];
            end

            % Median Background Adjusted Intensities
            if opts.medianbackint
                headers=[headers,['Median Background Adjusted Intensity (log10) ',names{i}]];
            end

            % StDev Background Adjusted Intensities
            if opts.stdevbackint
                headers=[headers,['StDev Background Adjusted Intensity (log10) ',names{i}]];
            end
        
        end
        
        % Present Calls
        if opts.calls && ~isempty(DataCellNormLo{6})
            for j=1:length(exprp{i})
                headers=[headers,['Present Calls ' exprp{i}{j}]];
            end
        end

    end
    
    for i=1:s
     
        % In natural scale
        if opts.scale.natural
        
            % Adjusted Normalized Intensities
            if opts.normint
                 for j=1:length(exprp{i})
                    headers=[headers,['Adjusted Normalized Intensity (natural) ' exprp{i}{j}]];
                end
            end

            % Mean Adjusted Normalized Intensities
            if opts.meannormint
                headers=[headers,['Mean Adjusted Normalized Intensity (natural) ',names{i}]];
            end

            % Median Adjusted Normalized Intensities
            if opts.mediannormint
                headers=[headers,['Median Adjusted Normalized Intensity (natural) ',names{i}]];
            end

            % StDev Adjusted Normalized Intensities
            if opts.stdevnormint
                headers=[headers,['StDev Adjusted Normalized Intensity (natural) ',names{i}]];
            end
        
        end
        
        % In ln scale
        if opts.scale.log
        
            % Adjusted Normalized Intensities
            if opts.normint
                 for j=1:length(exprp{i})
                    headers=[headers,['Adjusted Normalized Intensity (ln) ' exprp{i}{j}]];
                end
            end

            % Mean Adjusted Normalized Intensities
            if opts.meannormint
                headers=[headers,['Mean Adjusted Normalized Intensity (ln) ',names{i}]];
            end

            % Median Adjusted Normalized Intensities
            if opts.mediannormint
                headers=[headers,['Median Adjusted Normalized Intensity (ln) ',names{i}]];
            end

            % StDev Adjusted Normalized Intensities
            if opts.stdevnormint
                headers=[headers,['StDev Adjusted Normalized Intensity (ln) ',names{i}]];
            end
        
        end
        
        % In log2 scale
        if opts.scale.log2
        
            % Adjusted Normalized Intensities
            if opts.normint
                 for j=1:length(exprp{i})
                    headers=[headers,['Adjusted Normalized Intensity (log2) ' exprp{i}{j}]];
                end
            end

            % Mean Adjusted Normalized Intensities
            if opts.meannormint
                headers=[headers,['Mean Adjusted Normalized Intensity (log2) ',names{i}]];
            end

            % Median Adjusted Normalized Intensities
            if opts.mediannormint
                headers=[headers,['Median Adjusted Normalized Intensity (log2) ',names{i}]];
            end

            % StDev Adjusted Normalized Intensities
            if opts.stdevnormint
                headers=[headers,['StDev Adjusted Normalized Intensity (log2) ',names{i}]];
            end
        
        end
        
        % In log2 scale
        if opts.scale.log10
        
            % Adjusted Normalized Intensities
            if opts.normint
                 for j=1:length(exprp{i})
                    headers=[headers,['Adjusted Normalized Intensity (log10) ' exprp{i}{j}]];
                end
            end

            % Mean Adjusted Normalized Intensities
            if opts.meannormint
                headers=[headers,['Mean Adjusted Normalized Intensity (log10) ',names{i}]];
            end

            % Median Adjusted Normalized Intensities
            if opts.mediannormint
                headers=[headers,['Median Adjusted Normalized Intensity (log10) ',names{i}]];
            end

            % StDev Adjusted Normalized Intensities
            if opts.stdevnormint
                headers=[headers,['StDev Adjusted Normalized Intensity (log10) ',names{i}]];
            end
        
        end
        
        % Coefficients of Variation
        if opts.cvs
            headers=[headers,['CV ',names{i},]];
        end

        % Trust Factors
        if opts.trustfactors
            headers=[headers,['TF ',names{i}]];
        end

    end

    % Create some help variables (for the case where we have to calculate some means, medians
    % etc. and they are placed in different cells)
    sigsp=DataCellStat{3}; % Indices
    rawinten=cell(1,t);
    backinten=cell(1,t);
    for i=1:t
        rawinten{i}=nan(size(DataCellNormLo{1}{i}{1},1),size(DataCellNormLo{1}{i},2));
        for j=1:size(DataCellNormLo{1}{i},2)
            rawinten{i}(:,j)=DataCellNormLo{1}{i}{j};
        end
    end
    for i=1:t
        backinten{i}=nan(size(DataCellNormLo{3}{i}{1},1),size(DataCellNormLo{3}{i},2));
        for j=1:size(DataCellNormLo{3}{i},2)
            backinten{i}(:,j)=DataCellNormLo{3}{i}{j};
        end
    end
    
    % Get the used scale so as to make recalculations
    scal=DataCellNormLo{5}{4};
    
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
     
        % In natural scale
        if opts.scale.natural

            % Raw Intensities
            if opts.rawint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,rawinten{j}(sigsp,:)];
                    case 'log'
                        finaldata=[finaldata,exp(rawinten{j}(sigsp,:))];
                    case 'log2'
                        finaldata=[finaldata,2.^rawinten{j}(sigsp,:)];
                    case 'log10'
                        finaldata=[finaldata,10.^rawinten{j}(sigsp,:)];
                end
            end
            
            % Mean Raw Intensities
            if opts.meanrawint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmean(rawinten{j}(sigsp,:),2)];
                    case 'log'
                        finaldata=[finaldata,nanmean(exp(rawinten{j}(sigsp,:)),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmean(2.^rawinten{j}(sigsp,:),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmean(10.^rawinten{j}(sigsp,:),2)];
                end
            end
            
            % Median Raw Intensities
            if opts.medianrawint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmedian(rawinten{j}(sigsp,:),2)];
                    case 'log'
                        finaldata=[finaldata,nanmedian(exp(rawinten{j}(sigsp,:)),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmedian(2.^rawinten{j}(sigsp,:),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmedian(10.^rawinten{j}(sigsp,:),2)];
                end
            end
            
            % StDev Raw Intensities
            if opts.stdevrawint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanstd(rawinten{j}(sigsp,:),0,2)];
                    case 'log'
                        finaldata=[finaldata,nanstd(exp(rawinten{j}(sigsp,:)),0,2)];
                    case 'log2'
                        finaldata=[finaldata,nanstd(2.^rawinten{j}(sigsp,:),0,2)];
                    case 'log10'
                        finaldata=[finaldata,nanstd(10.^rawinten{j}(sigsp,:),0,2)];
                end
            end
            
            % Background Adjusted Intensities
            if opts.backint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,backinten{j}(sigsp,:)];
                    case 'log'
                        finaldata=[finaldata,exp(backinten{j}(sigsp,:))];
                    case 'log2'
                        finaldata=[finaldata,2.^backinten{j}(sigsp,:)];
                    case 'log10'
                        finaldata=[finaldata,10.^backinten{j}(sigsp,:)];
                end
            end
            
            % Mean Background Adjusted Intensities
            if opts.meanbackint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmean(backinten{j}(sigsp,:),2)];
                    case 'log'
                        finaldata=[finaldata,nanmean(exp(backinten{j}(sigsp,:)),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmean(2.^backinten{j}(sigsp,:),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmean(10.^backinten{j}(sigsp,:),2)];
                end
            end
            
            % Median Background Adjusted Intensities
            if opts.medianbackint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmedian(backinten{j}(sigsp,:),2)];
                    case 'log'
                        finaldata=[finaldata,nanmedian(exp(backinten{j}(sigsp,:)),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmedian(2.^backinten{j}(sigsp,:),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmedian(10.^backinten{j}(sigsp,:),2)];
                end
            end
            
            % StDev Background Adjusted Intensities
            if opts.stdevbackint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanstd(backinten{j}(sigsp,:),0,2)];
                    case 'log'
                        finaldata=[finaldata,nanstd(exp(backinten{j}(sigsp,:)),0,2)];
                    case 'log2'
                        finaldata=[finaldata,nanstd(2.^backinten{j}(sigsp,:),0,2)];
                    case 'log10'
                        finaldata=[finaldata,nanstd(10.^backinten{j}(sigsp,:),0,2)];
                end
            end
         
        end

        % In ln scale
        if opts.scale.log

            % Raw Intensities
            if opts.rawint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,log(rawinten{j}(sigsp,:))];
                    case 'log'
                        finaldata=[finaldata,rawinten{j}(sigsp,:)];
                    case 'log2'
                        finaldata=[finaldata,log(2.^rawinten{j}(sigsp,:))];
                    case 'log10'
                        finaldata=[finaldata,log(10.^rawinten{j}(sigsp,:))];
                end
            end
            
            % Mean Raw Intensities
            if opts.meanrawint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmean(log(rawinten{j}(sigsp,:)),2)];
                    case 'log'
                        finaldata=[finaldata,nanmean(rawinten{j}(sigsp,:),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmean(log(2.^rawinten{j}(sigsp,:)),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmean(log(10.^rawinten{j}(sigsp,:)),2)];
                end
            end
            
            % Median Raw Intensities
            if opts.medianrawint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmedian(log(rawinten{j}(sigsp,:)),2)];
                    case 'log'
                        finaldata=[finaldata,nanmedian(rawinten{j}(sigsp,:),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmedian(log(2.^rawinten{j}(sigsp,:)),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmedian(log(10.^rawinten{j}(sigsp,:)),2)];
                end
            end
            
            % StDev Raw Intensities
            if opts.stdevrawint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanstd(log(rawinten{j}(sigsp,:)),0,2)];
                    case 'log'
                        finaldata=[finaldata,nanstd(rawinten{j}(sigsp,:),0,2)];
                    case 'log2'
                        finaldata=[finaldata,nanstd(log(2.^rawinten{j}(sigsp,:)),0,2)];
                    case 'log10'
                        finaldata=[finaldata,nanstd(log(10.^rawinten{j}(sigsp,:)),0,2)];
                end
            end
            
            % Background Adjusted Intensities
            if opts.backint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,log(backinten{j}(sigsp,:))];
                    case 'log'
                        finaldata=[finaldata,backinten{j}(sigsp,:)];
                    case 'log2'
                        finaldata=[finaldata,log(2.^backinten{j}(sigsp,:))];
                    case 'log10'
                        finaldata=[finaldata,log(10.^backinten{j}(sigsp,:))];
                end
            end
            
            % Mean Background Adjusted Intensities
            if opts.meanbackint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmean(log(backinten{j}(sigsp,:)),2)];
                    case 'log'
                        finaldata=[finaldata,nanmean(backinten{j}(sigsp,:),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmean(log(2.^backinten{j}(sigsp,:)),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmean(log(10.^backinten{j}(sigsp,:)),2)];
                end
            end
            
            % Median Background Adjusted Intensities
            if opts.medianbackint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmedian(log(backinten{j}(sigsp,:)),2)];
                    case 'log'
                        finaldata=[finaldata,nanmedian(backinten{j}(sigsp,:),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmedian(log(2.^backinten{j}(sigsp,:)),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmedian(log(10.^backinten{j}(sigsp,:)),2)];
                end
            end
            
            % StDev Background Adjusted Intensities
            if opts.stdevbackint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanstd(log(backinten{j}(sigsp,:)),0,2)];
                    case 'log'
                        finaldata=[finaldata,nanstd(backinten{j}(sigsp,:),0,2)];
                    case 'log2'
                        finaldata=[finaldata,nanstd(log(2.^backinten{j}(sigsp,:)),0,2)];
                    case 'log10'
                        finaldata=[finaldata,nanstd(log(10.^backinten{j}(sigsp,:)),0,2)];
                end
            end
         
        end
        
        % In log2 scale
        if opts.scale.log2

            % Raw Intensities
            if opts.rawint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,log2(rawinten{j}(sigsp,:))];
                    case 'log'
                        finaldata=[finaldata,log2(exp(rawinten{j}(sigsp,:)))];
                    case 'log2'
                        finaldata=[finaldata,rawinten{j}(sigsp,:)];
                    case 'log10'
                        finaldata=[finaldata,log2(10.^rawinten{j}(sigsp,:))];
                end
            end
            
            % Mean Raw Intensities
            if opts.meanrawint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmean(log2(rawinten{j}(sigsp,:)),2)];
                    case 'log'
                        finaldata=[finaldata,nanmean(log2(exp(rawinten{j}(sigsp,:))),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmean(rawinten{j}(sigsp,:),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmean(log2(10.^rawinten{j}(sigsp,:)),2)];
                end
            end
            
            % Median Raw Intensities
            if opts.medianrawint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmedian(log2(rawinten{j}(sigsp,:)),2)];
                    case 'log'
                        finaldata=[finaldata,nanmedian(log2(exp(rawinten{j}(sigsp,:))),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmedian(rawinten{j}(sigsp,:),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmedian(log2(10.^rawinten{j}(sigsp,:)),2)];
                end
            end
            
            % StDev Raw Intensities
            if opts.stdevrawint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanstd(log2(rawinten{j}(sigsp,:)),0,2)];
                    case 'log'
                        finaldata=[finaldata,nanstd(log2(exp(rawinten{j}(sigsp,:))),0,2)];
                    case 'log2'
                        finaldata=[finaldata,nanstd(rawinten{j}(sigsp,:),0,2)];
                    case 'log10'
                        finaldata=[finaldata,nanstd(log2(10.^rawinten{j}(sigsp,:)),0,2)];
                end
            end
            
            % Background Adjusted Intensities
            if opts.backint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,log2(backinten{j}(sigsp,:))];
                    case 'log'
                        finaldata=[finaldata,log2(exp(backinten{j}(sigsp,:)))];
                    case 'log2'
                        finaldata=[finaldata,backinten{j}(sigsp,:)];
                    case 'log10'
                        finaldata=[finaldata,log2(10.^backinten{j}(sigsp,:))];
                end
            end
            
            % Mean Background Adjusted Intensities
            if opts.meanbackint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmean(log2(backinten{j}(sigsp,:)),2)];
                    case 'log'
                        finaldata=[finaldata,nanmean(log2(exp(backinten{j}(sigsp,:))),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmean(backinten{j}(sigsp,:),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmean(log2(10.^backinten{j}(sigsp,:)),2)];
                end
            end
            
            % Median Background Adjusted Intensities
            if opts.medianbackint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmedian(log2(backinten{j}(sigsp,:)),2)];
                    case 'log'
                        finaldata=[finaldata,nanmedian(log2(exp(backinten{j}(sigsp,:))),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmedian(backinten{j}(sigsp,:),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmedian(log2(10.^backinten{j}(sigsp,:)),2)];
                end
            end
            
            % StDev Background Adjusted Intensities
            if opts.stdevbackint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanstd(log2(backinten{j}(sigsp,:)),0,2)];
                    case 'log'
                        finaldata=[finaldata,nanstd(log2(exp(backinten{j}(sigsp,:))),0,2)];
                    case 'log2'
                        finaldata=[finaldata,nanstd(backinten{j}(sigsp,:),0,2)];
                    case 'log10'
                        finaldata=[finaldata,nanstd(log2(10.^backinten{j}(sigsp,:)),0,2)];
                end
            end
         
        end
        
        % In log10 scale
        if opts.scale.log10

            % Raw Intensities
            if opts.rawint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,log10(rawinten{j}(sigsp,:))];
                    case 'log'
                        finaldata=[finaldata,log10(exp(rawinten{j}(sigsp,:)))];
                    case 'log2'
                        finaldata=[finaldata,log10(2.^rawinten{j}(sigsp,:))];
                    case 'log10'
                        finaldata=[finaldata,rawinten{j}(sigsp,:)];
                end
            end
            
            % Mean Raw Intensities
            if opts.meanrawint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmean(log10(rawinten{j}(sigsp,:)),2)];
                    case 'log'
                        finaldata=[finaldata,nanmean(log10(exp(rawinten{j}(sigsp,:))),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmean(log10(2.^rawinten{j}(sigsp,:)),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmean(rawinten{j}(sigsp,:),2)];
                end
            end
            
            % Median Raw Intensities
            if opts.medianrawint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmedian(log10(rawinten{j}(sigsp,:)),2)];
                    case 'log'
                        finaldata=[finaldata,nanmedian(log10(exp(rawinten{j}(sigsp,:))),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmedian(log10(2.^rawinten{j}(sigsp,:)),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmedian(rawinten{j}(sigsp,:),2)];
                end
            end
            
            % StDev Raw Intensities
            if opts.stdevrawint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanstd(log10(rawinten{j}(sigsp,:)),0,2)];
                    case 'log'
                        finaldata=[finaldata,nanstd(log10(exp(rawinten{j}(sigsp,:))),0,2)];
                    case 'log2'
                        finaldata=[finaldata,nanstd(log10(2.^rawinten{j}(sigsp,:)),0,2)];
                    case 'log10'
                        finaldata=[finaldata,nanstd(rawinten{j}(sigsp,:),0,2)];
                end
            end
            
            % Background Adjusted Intensities
            if opts.backint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,log10(backinten{j}(sigsp,:))];
                    case 'log'
                        finaldata=[finaldata,log10(exp(backinten{j}(sigsp,:)))];
                    case 'log2'
                        finaldata=[finaldata,log10(2.^backinten{j}(sigsp,:))];
                    case 'log10'
                        finaldata=[finaldata,backinten{j}(sigsp,:)];
                end
            end
            
            % Mean Background Adjusted Intensities
            if opts.meanbackint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmean(log10(backinten{j}(sigsp,:)),2)];
                    case 'log'
                        finaldata=[finaldata,nanmean(log10(exp(backinten{j}(sigsp,:))),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmean(log10(2.^backinten{j}(sigsp,:)),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmean(backinten{j}(sigsp,:),2)];
                end
            end
            
            % Median Background Adjusted Intensities
            if opts.medianbackint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmedian(log10(backinten{j}(sigsp,:)),2)];
                    case 'log'
                        finaldata=[finaldata,nanmedian(log10(exp(backinten{j}(sigsp,:))),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmedian(log10(2.^backinten{j}(sigsp,:)),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmedian(backinten{j}(sigsp,:),2)];
                end
            end
            
            % StDev Background Adjusted Intensities
            if opts.stdevbackint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanstd(log10(backinten{j}(sigsp,:)),0,2)];
                    case 'log'
                        finaldata=[finaldata,nanstd(log10(exp(backinten{j}(sigsp,:))),0,2)];
                    case 'log2'
                        finaldata=[finaldata,nanstd(log10(2.^backinten{j}(sigsp,:)),0,2)];
                    case 'log10'
                        finaldata=[finaldata,nanstd(backinten{j}(sigsp,:),0,2)];
                end
            end
         
        end
        
        % Present Calls
        if opts.calls && ~isempty(DataCellNormLo{6})
            for k=1:length(exprp{j})
                ct=cell(1);
                temp=DataCellNormLo{6}{j}(k);
                temp=temp{1}(sigsp);
                ct{1}=temp;
                finaldata=[finaldata,ct];
            end
        end

    end
    
    for j=1:s
        
        % In natural scale
        if opts.scale.natural
            
            % Adjusted Normalized Intensities
            if opts.normint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,DataCellStat{5}{j}];
                    case 'log'
                        finaldata=[finaldata,exp(DataCellStat{5}{j})];
                    case 'log2'
                        finaldata=[finaldata,2.^DataCellStat{5}{j}];
                    case 'log10'
                        finaldata=[finaldata,10.^DataCellStat{5}{j}];
                end
            end
            
            % Mean Adjusted Normalized Intensities
            if opts.meannormint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmean(DataCellStat{5}{j},2)];
                    case 'log'
                        finaldata=[finaldata,nanmean(exp(DataCellStat{5}{j}),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmean(2.^DataCellStat{5}{j},2)];
                    case 'log10'
                        finaldata=[finaldata,nanmean(10.^DataCellStat{5}{j},2)];
                end
            end
            
            % Median Adjusted Normalized Intensities
            if opts.mediannormint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,median(DataCellStat{5}{j},2)];
                    case 'log'
                        finaldata=[finaldata,median(exp(DataCellStat{5}{j}),2)];
                    case 'log2'
                        finaldata=[finaldata,median(2.^DataCellStat{5}{j},2)];
                    case 'log10'
                        finaldata=[finaldata,median(10.^DataCellStat{5}{j},2)];
                end
            end
            
            % StDev Adjusted Normalized Intensities
            if opts.stdevnormint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,std(DataCellStat{5}{j},0,2)];
                    case 'log'
                        finaldata=[finaldata,std(exp(DataCellStat{5}{j}),0,2)];
                    case 'log2'
                        finaldata=[finaldata,std(2.^DataCellStat{5}{j},0,2)];
                    case 'log10'
                        finaldata=[finaldata,std(10.^DataCellStat{5}{j},0,2)];
                end
            end
         
        end

        % In ln scale
        if opts.scale.log
            
            % Adjusted Normalized Intensities
            if opts.normint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,log(DataCellStat{5}{j})];
                    case 'log'
                        finaldata=[finaldata,DataCellStat{5}{j}];
                    case 'log2'
                        finaldata=[finaldata,log(2.^DataCellStat{5}{j})];
                    case 'log10'
                        finaldata=[finaldata,log(10.^DataCellStat{5}{j})];
                end
            end
            
            % Mean Adjusted Normalized Intensities
            if opts.meannormint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmean(log(DataCellStat{5}{j}),2)];
                    case 'log'
                        finaldata=[finaldata,nanmean(DataCellStat{5}{j},2)];
                    case 'log2'
                        finaldata=[finaldata,nanmean(log(2.^DataCellStat{5}{j}),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmean(log(10.^DataCellStat{5}{j}),2)];
                end
            end
            
            % Median Adjusted Normalized Intensities
            if opts.mediannormint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,median(log(DataCellStat{5}{j}),2)];
                    case 'log'
                        finaldata=[finaldata,median(DataCellStat{5}{j},2)];
                    case 'log2'
                        finaldata=[finaldata,median(log(2.^DataCellStat{5}{j}),2)];
                    case 'log10'
                        finaldata=[finaldata,median(log(10.^DataCellStat{5}{j}),2)];
                end
            end
            
            % StDev Adjusted Normalized Intensities
            if opts.stdevnormint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,std(log(DataCellStat{5}{j}),0,2)];
                    case 'log'
                        finaldata=[finaldata,std(DataCellStat{5}{j},0,2)];
                    case 'log2'
                        finaldata=[finaldata,std(log(2.^DataCellStat{5}{j}),0,2)];
                    case 'log10'
                        finaldata=[finaldata,std(log(10.^DataCellStat{5}{j}),0,2)];
                end
            end
         
        end
        
        % In log2 scale
        if opts.scale.log2

            % Adjusted Normalized Intensities
            if opts.normint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,log2(DataCellStat{5}{j})];
                    case 'log'
                        finaldata=[finaldata,log2(exp(DataCellStat{5}{j}))];
                    case 'log2'
                        finaldata=[finaldata,DataCellStat{5}{j}];
                    case 'log10'
                        finaldata=[finaldata,log2(10.^DataCellStat{5}{j})];
                end
            end
            
            % Mean Adjusted Normalized Intensities
            if opts.meannormint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmean(log2(DataCellStat{5}{j}),2)];
                    case 'log'
                        finaldata=[finaldata,nanmean(log2(exp(DataCellStat{5}{j})),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmean(DataCellStat{5}{j},2)];
                    case 'log10'
                        finaldata=[finaldata,nanmean(log2(10.^DataCellStat{5}{j}),2)];
                end
            end
            
            % Median Adjusted Normalized Intensities
            if opts.mediannormint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,median(log2(DataCellStat{5}{j}),2)];
                    case 'log'
                        finaldata=[finaldata,median(log2(exp(DataCellStat{5}{j})),2)];
                    case 'log2'
                        finaldata=[finaldata,median(DataCellStat{5}{j},2)];
                    case 'log10'
                        finaldata=[finaldata,median(log2(10.^DataCellStat{5}{j}),2)];
                end
            end
            
            % StDev Adjusted Normalized Intensities
            if opts.stdevnormint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,std(log2(DataCellStat{5}{j}),0,2)];
                    case 'log'
                        finaldata=[finaldata,std(log2(exp(DataCellStat{5}{j})),0,2)];
                    case 'log2'
                        finaldata=[finaldata,std(DataCellStat{5}{j},0,2)];
                    case 'log10'
                        finaldata=[finaldata,std(log2(10.^DataCellStat{5}{j}),0,2)];
                end
            end
         
        end
        
        % In log10 scale
        if opts.scale.log10
            
            % Adjusted Normalized Intensities
            if opts.normint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,log10(DataCellStat{5}{j})];
                    case 'log'
                        finaldata=[finaldata,log10(exp(DataCellStat{5}{j}))];
                    case 'log2'
                        finaldata=[finaldata,log10(2.^DataCellStat{5}{j})];
                    case 'log10'
                        finaldata=[finaldata,DataCellStat{5}{j}];
                end
            end
            
            % Mean Adjusted Normalized Intensities
            if opts.meannormint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,nanmean(log10(DataCellStat{5}{j}),2)];
                    case 'log'
                        finaldata=[finaldata,nanmean(log10(exp(DataCellStat{5}{j})),2)];
                    case 'log2'
                        finaldata=[finaldata,nanmean(log2(2.^DataCellStat{5}{j}),2)];
                    case 'log10'
                        finaldata=[finaldata,nanmean(DataCellStat{5}{j},2)];
                end
            end
            
            % Median Adjusted Normalized Intensities
            if opts.mediannormint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,median(log10(DataCellStat{5}{j}),2)];
                    case 'log'
                        finaldata=[finaldata,median(log10(exp(DataCellStat{5}{j})),2)];
                    case 'log2'
                        finaldata=[finaldata,median(log2(2.^DataCellStat{5}{j}),2)];
                    case 'log10'
                        finaldata=[finaldata,median(DataCellStat{5}{j},2)];
                end
            end
            
            % StDev Adjusted Normalized Intensities
            if opts.stdevnormint
                switch scal
                    case 'natural'
                        finaldata=[finaldata,std(log10(DataCellStat{5}{j}),0,2)];
                    case 'log'
                        finaldata=[finaldata,std(log10(exp(DataCellStat{5}{j})),0,2)];
                    case 'log2'
                        finaldata=[finaldata,std(log2(2.^DataCellStat{5}{j}),0,2)];
                    case 'log10'
                        finaldata=[finaldata,std(DataCellStat{5}{j},0,2)];
                end
            end
         
        end
        
        % Coefficients of Variation
        if opts.cvs
            finaldata=[finaldata,std(DataCellStat{5}{j},0,2)./nanmean(DataCellStat{5}{j},2)];
        end

        % Trust Factors
        if opts.trustfactors
            finaldata=[finaldata,DataCellStat{7}(:,j)];
        end

    end
    
    % Create the final cell for exporting
    if opts.genenames || opts.calls
        finaldata=saveday(finaldata);
        final=[headers;finaldata];
    end 
        
%     if opts.genenames && opts.sp % Fix problem of non-arithmetic data
%         final_p1=finaldata(:,1);
%         final_p1=cell2mat(final_p1);
%         final_p1=mat2cell(final_p1,ones(length(final_p1),1),1);
%         final_p2=finaldata{:,2};
%         final_p3=finaldata(:,3:end);
%         final_p3=cell2mat(final_p3);
%         final_p3=mat2cell(final_p3,ones(size(final_p3,1),1),ones(size(final_p3,2),1));
%         final=[headers;final_p1,final_p2,final_p3];
%     elseif opts.genenames && ~opts.sp % Fix problem of non-arithmetic data
%         final_p2=finaldata{:,1};
%         final_p3=finaldata(:,2:end);
%         final_p3=cell2mat(final_p3);
%         final_p3=mat2cell(final_p3,ones(size(final_p3,1),1),ones(size(final_p3,2),1));
%         final=[headers;final_p2,final_p3];
%     else % No problem
%         finaldata=cell2mat(finaldata);
%         finaldata=mat2cell(finaldata,ones(size(finaldata,1),1),ones(size(finaldata,2),1));
%         final=[headers;finaldata];
%     end
    
    if prin
        xlswrite(filename,final)
    end
    
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
        