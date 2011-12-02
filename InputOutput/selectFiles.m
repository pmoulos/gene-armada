function [exprp,Datatable,pathnames]=selectFiles(t,imgsw,names)

%
% Inputstxt creates the exprp cell, which contains the filenames for all slides.
% It serves as slide unique identifier for the rest of the analysis
% 

% Find experiments directory 
currentWD = cd;
dirname = uigetdir('C:\','Select your Experiments Directory');
if ischar(dirname)
    cd(dirname)
elseif dirname==0
    uiwait(msgbox('Process interrupted by user','Interruption','modal'));
    exprp=[];
    Datatable=[];
    pathnames=[];
    return
end

switch imgsw
    
    case 1 % Quant Array
        for i=1:t
            filenames=[];
            filenames=uipickfiles('FilterSpec',[dirname,filesep],...
                                  'Prompt',['Select files for condition ',names{i}]);
            if isempty(filenames) || (~iscell(filenames) && filenames==0)
                uiwait(errordlg('You must specify the files! Process interrupted by user',...
                                'Error'));
                exprp=[];
                Datatable=[];
                pathnames=[];
                return
            else
                pathname=getPath(filenames{1});
                r=length(filenames);
                for j=1:r;
                    Datatable{j,i}=removePath(filenames{j});
                    exprp{i}{j}=removePath(filenames{j});
                    pathnames{i}{j}=pathname;
                end
            end
        end
        
    case 2 % Imagene
        for i=1:t
            tempFilenames=[];
            tempFilenames=uipickfiles('FilterSpec',[dirname,filesep],...
                                      'Prompt',['Select files for condition ',names{i}]);
            if isempty(tempFilenames) || (~iscell(tempFilenames) && tempFilenames==0)
                uiwait(errordlg('You must specify the files! Process interrupted by user',...
                                'Error'));
                exprp=[];
                Datatable=[];
                pathnames=[];
                return
            else
                pathname=getPath(tempFilenames{1});
                r=length(tempFilenames);
                if rem(r,2)~=0
                    cherrmsg={'ImaGene output consists of one file or each channel',...
                              'The number of files must be even for each condition'};
                    uiwait(errordlg(cherrmsg,'Bad Input'));
                    exprp=[];
                    Datatable=[];
                    pathnames=[];
                    return
                end
                for m=2:2:r
                    if isempty(strfind(tempFilenames{m},'Cy5'))
                        uiwait(errordlg('The 2nd file for each replicate for each condition must be the Cy5 channel',...
                                        'Bad Input'));
                        exprp=[];
                        Datatable=[];
                        pathnames=[];
                        return
                    end
                end
                filenames=[];
                for n=1:r/2
                    filenames{n}=[removePath(tempFilenames{2*n-1}) '-AND-' ...
                                  removePath(tempFilenames{2*n})];
                end

                for j=1:r/2;
                    Datatable{j,i}=filenames{j};
                end
                for j=1:r
                    exprp{i}{j}=removePath(tempFilenames{j});
                    pathnames{i}{j}=pathname;
                end
            end
        end
        
    case 3 % GenePix
        for i=1:t
            filenames=[];
            filenames=uipickfiles('FilterSpec',[dirname,filesep],...
                                  'Prompt',['Select files for condition ',names{i}]);
            if isempty(filenames) || (~iscell(filenames) && filenames==0)
                uiwait(errordlg('You must specify the files! Process interrupted by user',...
                                'Error'));
                exprp=[];
                Datatable=[];
                pathnames=[];
                return
            else
                pathname=getPath(filenames{1});
                r=length(filenames);
                for j=1:r;
                    Datatable{j,i}=removePath(filenames{j});
                    exprp{i}{j}=removePath(filenames{j});
                    pathnames{i}{j}=pathname;
                end
            end
        end
        
    case 4 % Text tab delimited or Excel files
        for i=1:t
            filenames=[];
            filenames=uipickfiles('FilterSpec',[dirname,filesep],...
                                  'Prompt',['Select files for condition ',names{i}]);
            if isempty(filenames) || (~iscell(filenames) && filenames==0)
                uiwait(errordlg('You must specify the files! Process interrupted by user',...
                                'Error'));
                exprp=[];
                Datatable=[];
                pathnames=[];
                return
            else
                pathname=getPath(filenames{1});
                r=length(filenames);
                for j=1:r;
                    Datatable{j,i}=removePath(filenames{j});
                    exprp{i}{j}=removePath(filenames{j});
                    pathnames{i}{j}=pathname;
                end
            end
        end
        
    case 5 % Agilent Feature Extraction
        for i=1:t
            filenames=[];
            filenames=uipickfiles('FilterSpec',[dirname,filesep],...
                                  'Prompt',['Select files for condition ',names{i}]);
            if isempty(filenames) || (~iscell(filenames) && filenames==0)
                uiwait(errordlg('You must specify the files! Process interrupted by user',...
                    'Error'));
                exprp=[];
                Datatable=[];
                pathnames=[];
                return
            else
                pathname=getPath(filenames{1});
                r=length(filenames);
                for j=1:r;
                    Datatable{j,i}=removePath(filenames{j});
                    exprp{i}{j}=removePath(filenames{j});
                    pathnames{i}{j}=pathname;
                end
            end
        end
        
end

% Return to initial working directory
cd(currentWD)


function out = getPath(in)

f=filesep;
in=char(in);
z=strfind(in,f);
if ~isempty(z)
    out=in(1:z(end));
else
    out=in;
end
% % Replace characters that would cause problems with a harmless underscore
% out=regexprep(out,'[.<>"|?]','_');


function out = removePath(in)

f=filesep;
z=strfind(in,f);
if ~isempty(z)
    out=in((z(end)+1):end);
else
    out=in;
end

