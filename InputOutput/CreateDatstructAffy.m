function [datstruct,cdfstruct,exprp,attributes]=CreateDatstructAffy(exprp,t,pathnames,cdfname,cdfpath,h,instr)
% function [datstruct,exprp,cdfstruct,gnID]=CreateDatstructAffy(exprp,t,pathnames,cdfpath,h,instr)

%
% Create MATLAB structures containing array information to be used internally from the
% rest of the analysis
%
% In the automated version the user tells fot the ImaGene case whether to mark empty spots
% as bad spots
%
% Usage : [datstruct,exprp,gnID]=CreateDatstruct(exprp,t,imgsw,pathnames)
%
% exprp     : A cell containing filenames. Serves for the importing procedure and as slide
%             identifier. Output from inputstxt
% t         : The number of conditions. Exists also in the workspace as output of
%             inputstxt
% pathnames : The path names for the files containing output from image analysis software
%             (exist in the workspace as output from inputstxt)
% cdfname   : The name of the Affymetrix library file
% cdfpath   : The path of the cdf library
% h         : Handle to a textbox where the output messages should appear
% instr     : Input cell array of strings where output messages will append
%
% See also SELECTFILES
%

if nargin<6
    h=[];
    instr={''};
end
if nargin<7
    instr={''};
end

% % Read once the cdf file to obtain a field...
% cdfstruct=affyread(cdfname,cdfpath);
    
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
        %disp(str1)

        %Create data structure for Affymetrix using some of the affy output fields
        datstruct{d}{i}=Affy2Struct(strcat(pathnames{d}{i},exprp{d}{i}),cdfpath);
        %datstruct{d}{i}.NumProbeSets=cdfstruct.NumProbeSets;
    end
end
cdfstruct=affyread(fullfile(cdfpath,cdfname));

% Create gene IDs
% gnID={};
% Create attributes
attributes.Number=[];
attributes.gnID={};
attributes.Indices=datstruct{1}{1}.Indices;
attributes.Shape=datstruct{1}{1}.Shape;
% Save some memory
for d=1:t
    for i=1:max(size(exprp{d}))
        datstruct{d}{i}=rmfield(datstruct{d}{i},{'Indices','Shape'});
    end
end
