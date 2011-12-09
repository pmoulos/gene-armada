function [datstruct,exprp,attributes]=CreateDatstruct(exprp,t,imgsw,pathnames,h,instr,emSpotCh)

%
% Create MATLAB structures containing array information to be used internally from the
% rest of the analysis
%
% Usage : [datstruct,exprp,attributes]=CreateDatstruct(exprp,t,imgsw,pathnames,h,instr,emSpotCh)
%
% exprp     : A cell containing filenames. Serves for the importing procedure and as slide
%             identifier. Output from inputstxt
% t         : The number of conditions. Exists also in the workspace as output of
%             inputstxt
% imgsw     : A scalar declaring the image analysis software (currently QuantArray,
%             ImaGene and GenePix supported)
%             imgsw=1: QuantArray
%             imgsw=2: ImaGene
%             imgsw=3: GenePix
%             imgsw=4: Tab delimited or Excel
%             imgsw=5: Agilent Feature Extraction Software
% pathnames : The path names for the files containing output from image analysis software
%             (exist in the workspace as output from inputstxt)
% h         : Handle to a textbox where the output messages should appear
% instr     : Input cell array of strings where output messages will append
% emSpotCh  : A scalar decalring whether to mark empty spots as poor quality spots for the
%             ImaGene case
%             emSpotCh=1 : Mark as poor (default)
%             emSpotCh=2 : Do not mark as poor
%
% See also STMAIN, INPUTSTXT, COLSEPREADAUTO
%

if nargin<7
    emSpotCh=1; % Treat array empty spots as bad points (ImaGene)
end

switch imgsw
    
    case 1 % QuantArray
        for d=1:t
            for i=1:max(size(exprp{d}))    
                str1=['Reading data -> Condition : ',num2str(d),',',' Replicate : ',num2str(i),' / ',...
                num2str(max(size(exprp{d}))),'-Filename : ','[',exprp{d}{i},']'];
                instr=[instr;str1];
                if ishandle(h)
                    set(h,'String',instr)
                else
                    disp(str1)
                end
                drawnow;
        
                %Create data structure for QuantArray using some of the QuantArray output fields 
                [datstruct{d}{i}]=Quant2Struct(strcat(pathnames{d}{i},exprp{d}{i}));
            end
        end

        % Create attributes
        % gnID=datstruct{1}{1}.GeneNames;
        attributes.Number=datstruct{1}{1}.Number;
        attributes.gnID=datstruct{1}{1}.GeneNames;
        attributes.Indices=datstruct{1}{1}.Indices;
        attributes.Shape=datstruct{1}{1}.Shape;
        attributes.Channels = datstruct{1}{1}.Channels;
        % Save some memory
        for d=1:t
            for i=1:max(size(exprp{d}))
                datstruct{d}{i}=rmfield(datstruct{d}{i},{'Number','GeneNames','Indices','Shape','Channels'});
            end
        end
        
    case 2 % ImaGene
        datstruct=[];
        for d=1:t
            for i=1:max(size(exprp{d}))/2  
                str1=['Reading data -> Condition : ',num2str(d),',',' Replicate : ',num2str(i),' / ',...
                num2str(max(size(exprp{d}))/2),'-Filenames : ','[',exprp{d}{2*i-1},'-AND-',exprp{d}{2*i},']'];
                instr=[instr;str1];
                if ishandle(h)
                    set(h,'String',instr)
                else
                    disp(str1)
                end
                drawnow;
                
                %Create data structure for ImaGene using some of the ImaGene output fields
                [datstruct{d}{i}] = ImGn2Struct(strcat(pathnames{d}{2*i-1},exprp{d}{2*i-1}),...
                                                strcat(pathnames{d}{2*i},exprp{d}{2*i}),emSpotCh);
                               
            end
        end

        %Fix exprp so as to have 1/2 of filenames, since we created the datstruct with both channels
        exprpTmp=[];
        for d=1:t
            for i=1:max(size(exprp{d}))/2
                exprpTmp{d}{i} = [exprp{d}{2*i-1},'-AND-',exprp{d}{2*i}];
            end
        end
        exprp=exprpTmp;
        
        % Create attributes
        attributes.Number=datstruct{1}{1}.Number;
        attributes.gnID=datstruct{1}{1}.GeneNames;
        attributes.Indices=datstruct{1}{1}.Indices;
        attributes.Shape=datstruct{1}{1}.Shape;
        attributes.Channels=datstruct{1}{1}.Channels;
        % Save some memory
        for d=1:t
            for i=1:max(size(exprp{d}))
                datstruct{d}{i}=rmfield(datstruct{d}{i},{'Number','GeneNames','Indices','Shape','Channels'});
            end
        end
        
    case 3 % GenePix
        datstruct=[];
        for d=1:t
            for i=1:max(size(exprp{d})) 
                str1=['Reading data -> Condition : ',num2str(d),',',' Replicate : ',num2str(i),' / ',...
                num2str(max(size(exprp{d}))),'-Filename : ','[',exprp{d}{i},']'];
                instr=[instr;str1];
                if ishandle(h)
                    set(h,'String',instr)
                else
                    disp(str1)
                end
                drawnow;
                
                %Create data structure for GenePix using some of the GenePix output fields
                [datstruct{d}{i}] = GnPx2Struct(strcat(pathnames{d}{i},exprp{d}{i}));
                               
            end
        end
        
        % Create attributes
        attributes.Number=datstruct{1}{1}.Number;
        attributes.gnID=datstruct{1}{1}.GeneNames;
        attributes.Indices=datstruct{1}{1}.Indices;
        attributes.Shape=datstruct{1}{1}.Shape;
        attributes.Channels=datstruct{1}{1}.Channels;
        % Save some memory
        for d=1:t
            for i=1:max(size(exprp{d}))
                datstruct{d}{i}=rmfield(datstruct{d}{i},{'Number','GeneNames','Indices','Shape','Channels'});
            end
        end
        
    case 4 % Text delimited files
        
        % Get proper file format and columns from first file
        if ~isempty(strfind(exprp{1}{1},'.xls'))
            
            try
                [res,head]=xlsread2xlsread8(strcat(pathnames{1}{1},exprp{1}{1}));
            catch
                rethrow(lasterror)
                datstruct=[];
                exprp=[];
                %gnID=[];
                attributes=[];
                return
            end
            head=head(:);
            [cols,cancel]=GetColumnsUI(['Select...';head]);
            if ~cancel
                colnums{1}=cols(1);
                colnums{2}=cols(2);
                colnums{3}=[cols(3) cols(4)];
                colnums{4}=[cols(5) cols(6)];
                colnums{5}=cols(7);
                colnums{6}=[cols(9) cols(15)];
                colnums{7}=[cols(10) cols(16)];
                colnums{8}=[cols(12) cols(18)];
                colnums{9}=[cols(13) cols(19)];
                colnums{10}=[cols(11) cols(17)];
                colnums{11}=[cols(14) cols(20)];
                colnums{12}=cols(8);
                colnums{13}='\t';
            else
                datstruct=[];
                exprp=[];
                attributes=[];
                return
            end
            
            for d=1:t
                for i=1:max(size(exprp{d}))
                    str1=['Reading data -> Condition : ',num2str(d),',',' Replicate : ',num2str(i),' / ',...
                          num2str(max(size(exprp{d}))),'-Filename : ','[',exprp{d}{i},']'];
                    instr=[instr;str1];
                    if ishandle(h)
                        set(h,'String',instr)
                    else
                        disp(str1)
                    end
                    drawnow;

                    datstruct{d}{i}=excelread(strcat(pathnames{d}{i},exprp{d}{i}),colnums);
                end
            end
            
        else
            
            fid=fopen(strcat(pathnames{1}{1},exprp{1}{1}));
            fline=fgetl(fid);
            fclose(fid);
            flineconts=textscan(fline,'%s','Delimiter','\t');
            [cols,cancel]=GetColumnsUI(['Select...';flineconts{1}]);
            if cancel
                datstruct=[];
                exprp=[];
                attributes=[];
                return
            end
            for d=1:t
                for i=1:max(size(exprp{d}))
                    str1=['Reading data -> Condition : ',num2str(d),',',' Replicate : ',num2str(i),' / ',...
                          num2str(max(size(exprp{d}))),'-Filename : ','[',exprp{d}{i},']'];
                    instr=[instr;str1];
                    set(h,'String',instr)
                    drawnow;
                    %disp(str1)

                    [datstruct{d}{i}]=TabDelim2Struct(strcat(pathnames{d}{i},exprp{d}{i}),...
                                                      cols,flineconts{1});
                end
            end
            
        end
        
        % Create attributes
        attributes.Number=datstruct{1}{1}.Number;
        attributes.gnID=datstruct{1}{1}.GeneNames;
        attributes.Indices=datstruct{1}{1}.Indices;
        attributes.Shape=datstruct{1}{1}.Shape;
        attributes.Channels=datstruct{1}{1}.Channels;
        % Save some memory
        for d=1:t
            for i=1:max(size(exprp{d}))
                datstruct{d}{i}=rmfield(datstruct{d}{i},{'Number','GeneNames','Indices','Shape','Channels'});
            end
        end
        
    case 5 % Agilent Feature Extraction
        datstruct=[];
        for d=1:t
            for i=1:max(size(exprp{d}))
                str1=['Reading data -> Condition : ',num2str(d),',',' Replicate : ',num2str(i),' / ',...
                    num2str(max(size(exprp{d}))),'-Filename : ','[',exprp{d}{i},']'];
                instr=[instr;str1];
                if ishandle(h)
                    set(h,'String',instr)
                else
                    disp(str1)
                end
                drawnow;

                %Create data structure for Agilent using some of the Agilent output fields
                [datstruct{d}{i}] = AgFeEx2Struct(strcat(pathnames{d}{i},exprp{d}{i}));

            end
        end

        % Create attributes
        attributes.Number=datstruct{1}{1}.Number;
        attributes.gnID=datstruct{1}{1}.GeneNames;
        attributes.Indices=datstruct{1}{1}.Indices;
        attributes.Shape=datstruct{1}{1}.Shape;
        attributes.Channels=datstruct{1}{1}.Channels;
        % Save some memory
        for d=1:t
            for i=1:max(size(exprp{d}))
                datstruct{d}{i}=rmfield(datstruct{d}{i},{'Number','GeneNames','Indices','Shape','Channels'});
            end
        end
            
end
