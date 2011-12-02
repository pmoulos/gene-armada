function api = iptgetapi(varargin)
%IPTGETAPI Get Application Programmer Interface (API) for handle.
%   API = IPTGETAPI(H) returns the API associated with handle H if there
%   is one. Otherwise, IPTGETAPI returns an empty array.
%
%   For more information about handle APIs, see the help for IMMAGBOX, 
%   IMPOSITIONRECT, or IMSCROLLPANEL.
%
%   Example
%   -------
%
%       hFig = figure('Toolbar','none',...
%                     'Menubar','none');
%       hIm = imshow('tape.png');
%       hSP = imscrollpanel(hFig,hIm);
%       api = iptgetapi(hSP);
%       api.setMagnification(2) % 2X = 200%
%  
%   See also IMMAGBOX, IMPOSITIONRECT, IMSCROLLPANEL.

%   Copyright 1993-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/15 20:46:39 $

   iptchecknargin(1, 1, nargin, mfilename);
   h = varargin{1};

   api = getappdata(h,'API');
