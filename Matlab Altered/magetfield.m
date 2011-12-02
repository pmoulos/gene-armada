function data = magetfield(maStruct,fieldname)
%MAGETFIELD extracts data for a given field from a microarray structure.
%
%   MAGETFIELD(MASTRUCT,FIELDNAME) extracts data column FIELDNAME from a
%   microarray structure MASTRUCT.
%
%   Examples:
%
%       maStruct = gprread('mouse_a1wt.gpr');
%       cy3data = magetfield(maStruct,'F635 Median');
%       cy5data = magetfield(maStruct,'F532 Median');
%       mairplot(cy3data,cy5data,'title','R vs G IR plot');
%
%   See also AGFEREAD, GPRREAD, IMAGENEREAD, MABOXPLOT, MAIRPLOT, MALOGLOG,
%   MALOWESS, SPTREAD.

% Copyright 2003-2005 The MathWorks, Inc.
% $Revision: 1.1.10.1 $   $Date: 2005/11/11 16:19:47 $

if ~isstruct(maStruct) || ~isfield(maStruct,'ColumnNames') || ~isfield(maStruct,'Data')
    error('Bioinfo:MagetfieldNotStruct',...
        'The first input to MAGETFIELD must be a structure with fields Data and ColumnNames.')
end

theCol = strmatch(fieldname,maStruct.ColumnNames);
if isempty(theCol)
    error('Bioinfo:MagetfieldUnknownField',...
        'Unknown field name %s.',fieldname)
end
if numel(theCol) > 1
    theCol = strmatch(fieldname,maStruct.ColumnNames,'exact');
    if numel(theCol) == 0
        error('Bioinfo:MagetfieldAmbiguousField',...
            'Ambiguous field name %s',fieldname)
    end
end
try
    data = maStruct.Data(:,theCol);
catch
    error('Bioinfo:MagetfieldBadColumn',...
        'Problem extracting field %s. The Data field does not contain the column associated with this field.',fieldname)
end


