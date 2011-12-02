function [exprp,cdfname,celpathnames,cdfpath,Datatable]=selectFilesAffy(names)

%
% selectFileAffy creates the exprp cell, which contains the filenames for all slides.
% It serves as slide unique identifier for the rest of the analysis
% 

% Find experiments directory 
currentWD=cd;
dirname=uigetdir('C:\','Select your Experiments Directory');
if ischar(dirname)
    cd(dirname)
elseif dirname==0
    uiwait(msgbox('Process interrupted by user','Interruption','modal'));
    exprp=[];
    Datatable=[];
    celpathnames=[];
    cdfname=[];
    cdfpath=[];
    return
end

Datatable=cell(1,length(names));
exprp=cell(1,length(names));
celpathnames=cell(1,length(names));

% Get the CEL files
for i=1:length(names)
    celfilenames=uipickfiles('FilterSpec',[dirname,filesep,'*.CEL'],...
                             'Prompt',['Select files for condition ',names{i}]);
    if isempty(celfilenames) || (~iscell(celfilenames) && celfilenames==0)
        uiwait(errordlg('You must specify the files! Process interrupted by user',...
                        'Error'));
        exprp=[];
        Datatable=[];
        celpathnames=[];
        return
    else
        pathname=getPath(celfilenames{1});
        r=length(celfilenames);
        exprp{i}=cell(1,r);
        celpathnames{i}=cell(1,r);
        for j=1:r;
            Datatable{j,i}=removePath(celfilenames{j});
            exprp{i}{j}=removePath(celfilenames{j});
            celpathnames{i}{j}=pathname;
        end
    end
end
        
% Return to initial working directory
cd(currentWD)

% Now get the CDF file with probe sequence IDs
[cdfname,cdfpath]=uigetfile({'*.CDF','Affymetrix CDF files (*.CDF)'},...
                                     'Select CDF file');
if cdfname==0
    uiwait(errordlg('You must specify the files! Process interrupted by user',...
                    'Error'));
    cdfname=[];
    return
end

function out = getPath(in)

f=filesep;
in=char(in);
z=strfind(in,f);
if ~isempty(z)
    out=in(1:z(end));
else
    out=in;
end


function out = removePath(in)

f=filesep;
z=strfind(in,f);
if ~isempty(z)
    out=in((z(end)+1):end);
else
    out=in;
end
