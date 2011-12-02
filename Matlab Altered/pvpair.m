function [k, pval] = pvpair(pname, theVal, okargs,mfile)
% PVPAIR Helper function that looks for partial matches of parameter names
% in a list of inputs and returns the parameter/value pair and matching
% number.
%
% [K, PVAL] = PVPAIR(PNAME, THEVAL, OKARGS) given input string PNAME,
% and corresponding value, THEVAL, finds matching name in the OKARGS list.
% Returns K, the index of the match, and PVAL, the parameter value.

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/09/11 11:42:47 $

k = find(strncmpi(pname, okargs,numel(pname)));
if numel(k) == 1
    pval = theVal;
    return
end

if isempty(k)
    xcptn = MException(sprintf('Bioinfo:%s:UnknownParameterName',mfile),...
        'Unknown parameter name: %s.',pname);
    xcptn.throwAsCaller;

elseif length(k)>1
    xcptn = MException(sprintf('Bioinfo:%s:AmbiguousParameterName',mfile),...
        'Ambiguous parameter name: %s.',pname);
    xcptn.throwAsCaller;
end
