function hScrollpanel = imscrollpanel(varargin)
%IMSCROLLPANEL Scroll panel for interactive image navigation.
%   HPANEL = IMSCROLLPANEL(HPARENT, HIMAGE) creates a scroll panel
%   containing the target image (the image to be navigated). HIMAGE
%   is a handle to the target HIMAGE.  HPARENT is the handle to the
%   figure or uipanel object that will contain the new scroll panel.
%   HPANEL is the handle to the scroll panel, which is a uipanel object.
%
%   A scroll panel makes an image scrollable. If the size or magnification
%   makes an image too large to display in a figure on the screen, the
%   scroll panel displays a portion of the image at 100% magnification
%   (one screen pixel represents one image pixel). The scroll panel adds
%   horizontal and vertical scroll bars to enable navigation around the
%   image.
%
%   IMSCROLLPANEL changes the object hierarchy of the target image. Instead
%   of the familiar figure->axes->image object hierarchy, IMSCROLLPANEL
%   inserts several uipanel and uicontrol objects between the figure and
%   the axes object.
%
%   API Function Syntaxes
%   ---------------------
%   A scroll panel contains a structure of function handles,
%   called an API. You can use the functions in this API to manipulate
%   the scroll panel. To retrieve this structure, use the IPTGETAPI
%   function, as in the following.
%
%       api = iptgetapi(HPANEL)
%
%   Functions in the API, listed in the order they appear in the structure,
%   include:
%
%   setMagnification
%
%       Sets the magnification of the target image in units of
%       screen pixels per image pixel.
%
%           api.setMagnification(new_mag)
%
%       where new_mag is a scalar magnification factor.
%
%   getMagnification
%
%      Returns the current magnification factor of the target image
%      in units of screen pixels per image pixel.
%
%           mag = api.getMagnification()
%
%      Multiply mag by 100 to convert to percentage. For example,
%      if mag=2, the magnification is 200%.
%
%   setMagnificationAndCenter
%
%       Changes the magnification and makes the point cx,cy in the
%       target image appear in the center of the scroll panel. This
%       operation is equivalent to a simultaneous zoom and recenter.
%
%           api.setMagnificationAndCenter(mag,cx,cy)
%
%   findFitMag
%
%       Returns the magnification factor that would make the target
%       image just fit in the scroll panel.
%
%           mag = api.findFitMag()
%
%   setVisibleLocation
%
%       Moves the target image so that the specified location is
%       visible. Scrollbars update.
%
%           api.setVisibleLocation(xmin,ymin)
%           api.setVisibleLocation([xmin ymin])
%
%   getVisibleLocation
%
%       Returns the location of the currently visible portion of the
%       target image.
%
%           loc = api.getVisibleLocation()
%
%       where loc is a vector [xmin ymin].
%
%   getVisibleImageRect
%
%       Returns the current visible portion of the image.
%
%           r = api.getVisibleImageRect()
%
%       where r is a rectangle [xmin ymin width height].
%
%   addNewMagnificationCallback
%
%       Adds the function handle FCN to the list of new-magnification callback
%       functions.
%
%           id = api.addNewMagnificationCallback(fcn)
%
%       Whenever the scroll panel magnification changes, each function in
%       the list is called with the syntax:
%
%           fcn(mag)
%
%       where mag is a scalar magnification factor.
%
%       The return value, id, is used only with
%       removeNewMagnificationCallback.
%
%   removeNewMagnificationCallback
%
%       Removes the corresponding function from the new-magnification callback
%       list.
%
%           api.removeNewMagnificationCallback(id)
%
%       where id is the identifier returned by
%       api.addNewMagnificationCallback.
%
%   addNewLocationCallback
%
%       Adds the function handle FCN to the list of new-location callback
%       functions.
%
%           id = api.addNewLocationCallback(fcn)
%
%       Whenever the scroll panel location changes, each function in
%       the list is called with the syntax:
%
%           fcn(loc)
%
%       where loc is [xmin ymin].
%
%       The return value, id, is used only with
%       removeNewLocationCallback.
%
%   removeNewLocationCallback
%
%       Removes the corresponding function from the new-location callback
%       list.
%
%           api.removeNewLocationCallback(id)
%
%       where id is the identifier returned by
%       api.addNewLocationCallback.
%
%   replaceImage
%
%       Replaces the existing image data in the scrollpanel.       
%
%           api.replaceImage(I)
%           api.replaceImage(BW)
%           api.replaceImage(RGB)
%           api.replaceImage(I, MAP)
%           api.replaceImage(FILENAME)
%
%       The new image data is displayed centered, at 100% magnification.
%       The image handle is unchanged. 
%
%   Notes
%   -----
%   Scrollbar navigation as provided by IMSCROLLPANEL is incompatible with the
%   default MATLAB figure navigation buttons (pan, zoom in, zoom out). The
%   corresponding menu items and toolbar buttons should be removed in a custom
%   GUI that includes a scrollable uipanel created by IMSCROLLPANEL.
%
%   When you run IMSCROLLPANEL, it appears to take over the entire figure
%   because by default HPANEL has 'Units' set to 'normalized' and 'Position'
%   set to [0 0 1 1]. If you want to see other children of HPARENT while
%   using your new scroll panel, you must manually set the 'Position' property
%   of HPANEL.
%
%   Example
%   -------
%
%       % Create a scroll panel
%       hFig = figure('Toolbar','none',...
%                     'Menubar','none');
%       hIm = imshow('saturn.png');
%       hSP = imscrollpanel(hFig,hIm);
%       set(hSP,'Units','normalized',...
%               'Position',[0 .1 1 .9])
%
%       % Add a magnification box and an overview tool
%       hMagBox = immagbox(hFig,hIm);
%       pos = get(hMagBox,'Position');
%       set(hMagBox,'Position',[0 0 pos(3) pos(4)])
%       imoverview(hIm)
%
%       % Get the scroll panel API to programmatically control the view
%       api = iptgetapi(hSP);
%
%       % Get the current magnification and position
%       mag = api.getMagnification()
%       r = api.getVisibleImageRect()
%
%       % View the top left corner of the image
%       api.setVisibleLocation(0.5,0.5)
%
%       % Change the magnification to the value that just fits
%       api.setMagnification(api.findFitMag())
%
%       % Zoom in to 1600% on the dark spot
%       api.setMagnificationAndCenter(16,306,800)
%
%   See also IMMAGBOX, IMOVERVIEW, IMOVERVIEWPANEL, IMTOOL, IPTGETAPI.

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2006/12/10 20:06:29 $

iptchecknargin(2, 2, nargin, mfilename);
parent = varargin{1};
hIm = varargin{2};
hAx = ancestor(hIm,'Axes');

validateHandles(parent,hIm,hAx)

[imageWidth,imageHeight] = validateImageDims(hIm);

validateXYData(hIm,imageWidth,imageHeight)

sbw = 13; % scroll bar width

% Magnification as ratio of screen per image pixel.
screenPerImagePixel = 1;

maxMag = 1024; % arbritrary big choice, 1024 screen pixels for one
               % image pixel seems more than anyone could want

% hScrollpanel contains:
%    hSliderHor
%    hSliderVer
%    hFrame
%    hScrollable
hScrollpanel= uipanel(...
    'BorderType','none',...
    'parent', parent,...
    'Units','normalized',...
    'Position',[0 0 1 1]);

sliderColor = [.9 .9 .9];

hSliderHor = uicontrol(...
    'Style','slider',...
    'Parent',hScrollpanel,...
    'Value', 0.5,...
    'BackgroundColor',sliderColor);

hSliderVer = uicontrol(...
    'Style','slider',...
    'Parent',hScrollpanel,...
    'Value', 0.5,...
    'BackgroundColor',sliderColor);

if isJavaFigure
    % Must use these ActionEvents to get continuous events fired as slider
    % thumb is dragged. Regular callbacks on sliders give only one event
    % when the thumb is released.
    hSliderHorListener = handle.listener(hSliderHor,...
        'ActionEvent',@scrollHorizontal);
    hSliderVerListener = handle.listener(hSliderVer,...
        'ActionEvent',@scrollVertical);
    setappdata(hScrollpanel,'sliderListeners',...
        [hSliderHorListener hSliderVerListener]);
else
    % Unfortunately, the ActionEvent route is only available with Java
    % Figures, so platforms without Java Figure support get discrete
    % events only when the mouse is released from dragging the slider
    % thumb.
    set(hSliderHor,'callback',@scrollHorizontal)
    set(hSliderVer,'callback',@scrollVertical)
end

hFrame = uicontrol(...
    'Style','frame',...
    'Parent',hScrollpanel);

% hScrollpanel contains:
%    hAx
hScrollable = uipanel(...
    'BorderType','none',...
    'parent', hScrollpanel,...
    'units', 'pixels',...
    'Position',[1 1 getOnScreenImW() getOnScreenImH()]);

setChildColorToMatchParent(hScrollable,parent);

% Position axes just above horizontal scrollbar to make coordinate
% calculations simpler.
set(hAx,...
    'Parent',hScrollable,...
    'Units','pixels',...
    'Position',[1 1 getOnScreenImW() getOnScreenImH()],...
    'TickDir', 'out', ...
    'XGrid', 'off', ...
    'YGrid', 'off', ...
    'XLim',[.5 (imageWidth  + .5)],... % in case someone set xlim,ylim
    'YLim',[.5 (imageHeight + .5)],...
    'Visible','off');

% newMagnificationCallbackFunctions is used by sendNewMagnification() to
% notify interested parties whenever the magnification changes.
newMagnificationCallbackFunctions = makeList;

% Pattern for set associated with callbacks that get called as a
% result of the set.
insideSetMagnification = false;

% newLcationCallbackFunctions is used by sendNewLocation() to
% notify interested parties whenever the location changes.
newLocationCallbackFunctions = makeList;

% Pattern for set associated with callbacks that get called as a
% result of the set.
insideSetVisibleLocation = false;

% Stores the id returned by IPTADDCALLBACK for the image object's
% ButtonDownFcn callback.
imageButtonDownFcnId = [];

viewport = []; % gets set by call to updatePositions

updatePositions

% Initialize so scrollbars are in sync with location of image
cxInit = 0.5 + imageWidth/2; % Must add 0.5 for default spatial coords
cyInit = 0.5 + imageHeight/2;
setMagnificationAndCenter(screenPerImagePixel,cxInit,cyInit)

set(hScrollpanel,'ResizeFcn',@resizeView);

api.setMagnification                = @setMagnification;
api.getMagnification                = @getMagnification;
api.setMagnificationAndCenter       = @setMagnificationAndCenter;
api.findFitMag                      = @findFitMag;
api.setVisibleLocation              = @setVisibleLocation;
api.getVisibleLocation              = @getVisibleLocation;
api.getVisibleImageRect             = @getVisibleImageRect;
api.addNewMagnificationCallback     = @addNewMagnificationCallback;
api.removeNewMagnificationCallback  = @removeNewMagnificationCallback;
api.addNewLocationCallback          = @addNewLocationCallback;
api.removeNewLocationCallback       = @removeNewLocationCallback;
api.replaceImage                    = @replaceImage;

% undocumented interface, may change in the future
api.setImageButtonDownFcn           = @setImageButtonDownFcn;
api.findMagnification               = @findMagnification;
api.turnOffScrollpanel              = @turnOffScrollpanel;
api.getMinMag                       = @getMinMag;
    
setappdata(hScrollpanel,'API',api);

    %-------------------------------
    function setMagnification(ratio)

        % Pattern to break recursion
        if insideSetMagnification
            return
        else
            insideSetMagnification = true;
        end

        if ishandle(parent)

            [cx,cy] = getCurrentCenter();

            setMagnificationAndCenter(ratio,cx,cy)

        end

        % Pattern to break recursion
        insideSetMagnification = false;


        %----------------------------------
        function [cx,cy] = getCurrentCenter

            % Get current center so we can hold it.
            r = getVisibleImageRect();
            cx = r(1) + r(3)/2;
            cy = r(2) + r(4)/2;

        end

    end

    %--------------------------------
    function ratio = getMagnification

        if ishandle(parent)
            ratio = screenPerImagePixel;
        else
            ratio = [];
        end

    end

    %------------------------------------------
    function setMagnificationAndCenter(s,cx,cy)
        % cx and cy are center of new viewport
        % s is requested mag in screenPerImagePixels

        screenPerImagePixel = constrainMag(s);

        % Find xmin,ymin that correspond to holding this cx, cy in the center.
        [xmin,ymin] = findXminYmin(cx,cy,screenPerImagePixel);

        updateScrollablePosition(xmin,ymin)
        resizeView()

        sendNewMagnification()
        sendNewLocation()

        %--------------------------------------------
        function ratio = constrainMag(candidateRatio)

            minMag = getMinMag();
            ratio = max(min(candidateRatio,maxMag),minMag);

        end

        %----------------------------
        function sendNewMagnification

            list = newMagnificationCallbackFunctions.getList();
            for k = 1:numel(list)
                fun = list{k};
                fun(screenPerImagePixel);
            end

        end

        %-----------------------------------------------------------
        function [xmin,ymin] = findXminYmin(desired_cx,desired_cy,s)

            % desired_cx, desired_cy is the requested center in image coordinates.

            imW = imageWidth;
            imH = imageHeight;

            vpW = viewport(1);
            vpH = viewport(2);

            visImW = findVisImageDim(imW,vpW);
            visImH = findVisImageDim(imH,vpH);

            onScreenImW = imW*s;
            onScreenImH = imH*s;

            xmin = findValidImTL(desired_cx,imW,onScreenImW,vpW,visImW);
            ymin = findValidImTL(desired_cy,imH,onScreenImH,vpH,visImH);

            %-------------------------------------------
            function dim = findVisImageDim(imDim, vpDim)

                visibleImDim = vpDim/s;
                dim = min(visibleImDim,imDim);

            end

            %-------------------------------------------------
            function TL = findValidImTL(desiredVisImCenter,...
                    imDim,...
                    onScreenImDim,...
                    vpDim,...
                    visImDim)

                if (onScreenImDim <= vpDim) % TL is TL of image
                    TL = 0;

                else % constrain TL so you cannot scroll past the edge of image

                    desiredVisImTL = desiredVisImCenter - vpDim/s/2.;

                    validVisImTL = clip(desiredVisImTL,imDim,visImDim);
                    TL = validVisImTL;
                end

                %---------------------------------------
                function out = clip(in, imDim, visImDim)
                    % clip so coordinate stays inside image

                    out = max(in,0.5);
                    out = min(out, imDim - visImDim + 0.5);

                end

            end

        end % findXminYmin

    end % setMagnificationAndCenter

    %---------------------------
    function fitMag = findFitMag

        candidateFitMag = findMagnification(imageWidth, imageHeight);
        fitMag = max(candidateFitMag,getMinMag());

    end

    %------------------------------------
    function setVisibleLocation(varargin)

        % Pattern to break recursion
        if insideSetVisibleLocation
            return
        else
            insideSetVisibleLocation = true;
        end

        iptchecknargin(1, 2, nargin, sprintf('%s/setVisibleLocation',mfilename));

        switch nargin
            case 1
                loc = varargin{1};
                xIm = loc(1);
                yIm = loc(2);
            case 2
                xIm = varargin{1};
                yIm = varargin{2};
        end

        % xIm, yIm is the location of the minimum image coordinates in the
        % corner of the viewport.
        %
        % If 'YDir' is 'reverse' this will be the top left corner. If 'YDir' is
        % 'normal' this will be the bottom left corner.

        updateScrollablePosition(xIm,yIm)

        sendNewLocation()

        % Pattern to break recursion
        insideSetVisibleLocation = false;

    end

    %--------------------------------
    function loc = getVisibleLocation

        pos = getVisibleImageRect();
        loc = pos(1:2);

    end

    %---------------------------------
    function pos = getVisibleImageRect

        % xmin, ymin should be edge of pixel with row=1, col=1.
        % The units are user units as defined by XData and YData

        hScrollablePos = get(hScrollable,'Position');

        xdata = get(hIm,'XData');
        ydata = get(hIm,'YData');

        if isFullImageWShowing()
            [xmin,width] = getMinAndDim(xdata,imageWidth);
        else
            dxOnePixel = getDeltaOnePixel(xdata,imageWidth);
            xmin = -dxOnePixel * (hScrollablePos(1)-1)/screenPerImagePixel + ...
                xdata(1) - dxOnePixel/2;
            width = dxOnePixel * viewport(1) / screenPerImagePixel;

        end

        if isFullImageHShowing()
            ydata = get(hIm,'YData');
            [ymin,height] = getMinAndDim(ydata,imageHeight);

        else
            dyOnePixel = getDeltaOnePixel(ydata,imageHeight);

            % account for scrollbar if showing
            hScrollablePosY = hScrollablePos(2);
            if isSliderHorShowing
                hScrollablePosY = hScrollablePosY - sbw; % shift Y-origin by sbw
            end

            maxYInScreenPixels = getOnScreenImH() - viewport(2);
            ymin = dyOnePixel*(maxYInScreenPixels + (hScrollablePosY-1) )/screenPerImagePixel + ...
                ydata(1) - dyOnePixel/2;

            height = dyOnePixel * viewport(2) / screenPerImagePixel;

        end

        pos = [xmin ymin width height];

        %--------------------------------------------------
        function [dimMin,dim] = getMinAndDim(dimData,imDim)

            delta = dimData(2) - dimData(1);
            deltaOnePixel = getDeltaOnePixel(dimData,imDim);
            dimMin = dimData(1) - deltaOnePixel/2;
            dim = delta + deltaOnePixel;

        end

    end

    %---------------------------------------------
    function id = addNewMagnificationCallback(fun)
        id = newMagnificationCallbackFunctions.appendItem(fun);
    end

    %------------------------------------------
    function removeNewMagnificationCallback(id)
        newMagnificationCallbackFunctions.removeItem(id);
    end

    %----------------------------------------
    function id = addNewLocationCallback(fun)
        id = newLocationCallbackFunctions.appendItem(fun);
    end

    %-------------------------------------
    function removeNewLocationCallback(id)
        newLocationCallbackFunctions.removeItem(id);
    end

    %----------------------------------
    function setImageButtonDownFcn(fun)

        if ~isempty(imageButtonDownFcnId)
            iptremovecallback(hIm,'ButtonDownFcn',imageButtonDownFcnId);
        end

        if ~isempty(fun)
            imageButtonDownFcnId = iptaddcallback(hIm,'ButtonDownFcn',fun);
        else
            imageButtonDownFcnId = [];
        end

    end

    %------------------------------------
    function mag = findMagnification(w,h)

        % Calculate screenPerImagePixel so image region
        % with width w, height h fits in scrollpanel with no scrollbars showing.
        set(hScrollpanel, 'units', 'pixels');
        spPos = get(hScrollpanel, 'position');
        spWidth  = spPos(3);
        spHeight = spPos(4);
        set(hScrollpanel,'units','normalized')

        xMag = spWidth / w;
        yMag = spHeight / h;
        mag = min(xMag,yMag);

    end

    %--------------------------
    function turnOffScrollpanel
        % This function turns off the scrollpanel. First, it sets the axes parent
        % to the current parent of the scrollpanel, then it deletes the handle
        % to the scrollpanel. This is needed by clients who want to reuse the
        % handles to an image and/or axes object.

        spParent = parent;
        if ishandle(spParent)

            % Remove current ButtonDownFcn as it may not work with scrollpanel off
            if ~isempty(imageButtonDownFcnId)
                iptremovecallback(hIm,'ButtonDownFcn',imageButtonDownFcnId);
            end

            set(hAx,'Parent',spParent)
            delete(hScrollpanel)
        end

    end

    %--------------------------
    function minMag = getMinMag
        % Calculate the minimum magnification to always show at least one
        % pixel in each dimension.

        minMag = 1/max(1,min(imageWidth,imageHeight)); % ensure denom~=0
    end

    %------------------------------
    function replaceImage(varargin)
        % The input image will replace the existing image in the
        % scrollpanel.
        % The new image will be displayed centered, at 100% magnification.
        % An active mode, e.g.pan, zoom, set with setImageButtonDownFcn
		% will continue in effect after the image is replaced.
        % The image handle will remain active and
        % unchanged.

        % No more than 2 input arguments allowed.
        % This check weeds out the parameter-value pairs allowed by
        % imageDisplayParseInputs.
        num_args = length(varargin);
        iptchecknargin(0,2,num_args,mfilename);

        specificArgNames = {}; % No specific args needed

        common_args = imageDisplayParseInputs(specificArgNames,varargin{:});
       
		% Set properties of new image into the figure, axes and image
		% objects to assure correct display.
		
        % update the hg image object
        set(hIm, ...
            'CData',common_args.CData,...
            'CDataMapping', common_args.CDataMapping, ...
            'XData', common_args.XData, ...
            'YData', common_args.YData);

        % adjust the axes  
        if ~isempty(common_args.DisplayRange)
            set(hAx, 'CLim', common_args.DisplayRange);
        end

        % if the image has a colormap, update the figure
        if ~isempty(common_args.Map)
            hF = ancestor(hAx,'Figure');
            set(hF, 'Colormap', common_args.Map);
        end
        
        % perform input validation as imscrollpanel does      
        [imageWidth,imageHeight] = validateImageDims(hIm);      
        validateXYData(hIm,imageWidth,imageHeight)

        % adjust the axes limits with the new image dimensions
        set(hAx,'XLim', [0.5 imageWidth+0.5])
        set(hAx,'YLim', [0.5 imageHeight+0.5])

        updatePositions

        % Calculate the center point
        xCenter = 0.5 + imageWidth/2; % Must add 0.5 for spatial coords
        yCenter = 0.5 + imageHeight/2;
        
        % set to 100%, centered
        setMagnificationAndCenter(1, xCenter, yCenter);

    end


    %-------------------------------------------
    function updateScrollablePosition(xmin,ymin)

        pos = get(hScrollable,'Position');

        if isFullImageWShowing()
            x = pos(1);
        else
            x = calcVisibleX(xmin);
            updateSliderX(x)
        end

        if isFullImageHShowing()
            y = pos(2);
        else
            y = calcVisibleY(ymin);
            updateSliderY(y)
        end

        [w,h] = calcScrollableDims();

        set(hScrollable,'Position',[x y w h])

        %--------------------------------
        function xVis = calcVisibleX(xIm)

            xdata = get(hIm,'XData');
            dxOnePixel = getDeltaOnePixel(xdata,imageWidth);

            xVis = -(xIm - xdata(1) + dxOnePixel/2)*screenPerImagePixel / ...
                dxOnePixel + 1;

        end

        %--------------------------------
        function yVis = calcVisibleY(yIm)

            ydata = get(hIm,'YData');
            dyOnePixel = getDeltaOnePixel(ydata,imageHeight);

            maxYInScreenPixels = getOnScreenImH() - viewport(2);
            yVis = (yIm - ydata(1) + dyOnePixel/2)*screenPerImagePixel / ...
                dyOnePixel - maxYInScreenPixels + 1;
            if isSliderHorShowing
                yVis = yVis + sbw; % shift Y-origin by sbw
            end

        end

        %---------------------------
        function updateSliderX(xVis)

            numerator = 1 - xVis;
            xSlider = numerator/(getOnScreenImW() - viewport(1));
            xSlider = min(max(xSlider,0),1);
            set(hSliderHor,'Value',xSlider)

        end

        %---------------------------
        function updateSliderY(yVis)

            maxYInScreenPixels = getOnScreenImH() - viewport(2);
            numerator = yVis - 1 + maxYInScreenPixels;
            if isSliderHorShowing
                numerator = numerator - sbw;
            end
            ySlider = 1 - numerator/(getOnScreenImH() - viewport(2));
            ySlider = min(max(ySlider,0),1);
            set(hSliderVer,'Value',ySlider)
        end

    end % updateScrollablePosition

    %------------------------------------------------------
    function [scrollableW,scrollableH] = calcScrollableDims

        % Need to change size of hScrollable to match new mag
        vpW = viewport(1);
        vpH = viewport(2);
        scrollableW = calcDim(vpW,getOnScreenImW());
        scrollableH = calcDim(vpH,getOnScreenImH());

        %------------------------------------------------------
        function [scrollableDim] = calcDim(vpDim,onScreenImDim)

            if isFullImageShowing(vpDim,onScreenImDim)
                scrollableDim = vpDim;
            else
                scrollableDim = onScreenImDim;
            end

        end

    end

    %-----------------------
    function sendNewLocation

        list = newLocationCallbackFunctions.getList();
        for k = 1:numel(list)
            fun = list{k};
            fun(getVisibleLocation);
        end

    end

    %----------------------------------
    function scrollHorizontal(varargin) %#ok varargin needed by HG caller

        hScrollablePos = get(hScrollable, 'Position');
        xPos = findPos(viewport(1),getOnScreenImW(),hSliderHor);
        set(hScrollable,'Position', [xPos hScrollablePos(2:4)]);

        sendNewLocation()

    end

    %--------------------------------
    function scrollVertical(varargin) %#ok varargin needed by HG caller

        hScrollablePos = get(hScrollable, 'Position');
        yPos = findYPos;
        set(hScrollable,'Position',[hScrollablePos(1) yPos hScrollablePos(3:4)]);

        sendNewLocation()

    end

    %----------------------------
    function resizeView(varargin) %#ok varargin needed by HG caller

        % Temporarily disable ResizeFcn to avoid recursion
        actualResizeFcn = get(hScrollpanel,'ResizeFcn');
        set(hScrollpanel,'ResizeFcn','')

        hScrollablePos = get(hScrollable, 'Position');
        updateViewport() % Need to do this to get positions correctly

        xPos = findPos(viewport(1),getOnScreenImW(),hSliderHor);
        yPos = findYPos();

        set(hScrollable,'Position', [xPos yPos hScrollablePos(3:4)]);

        updatePositions() % call this last to make sure position of hAx and
        % hScrollable are right even if full image visible

        % Restore ResizeFcn
        set(hScrollpanel,'ResizeFcn',actualResizeFcn)

    end

    %------------------------
    function [pos] = findYPos

        pos = findPos(viewport(2),getOnScreenImH(),hSliderVer);

        if isSliderHorShowing
            pos = pos + sbw;
        end

    end

    %--------------------------------------
    function isShowing = isSliderHorShowing

        isShowing = strcmp('on',get(hSliderHor,'Visible'));

    end

    %----------------------
    function updateViewport

        spPos = hgconvertunits(iptancestor(hScrollpanel, 'figure'), ...
            get(hScrollpanel, 'Position'), ...
            get(hScrollpanel, 'Units'), ...
            'pixels', ...
            get(hScrollpanel, 'Parent'));

        spWidth  = spPos(3);
        spHeight = spPos(4);

        set(hSliderVer, 'units', 'pixels');
        set(hSliderHor, 'units', 'pixels');
        set(hFrame, 'units', 'pixels');

        onScreenImW = getOnScreenImW();
        onScreenImH = getOnScreenImH();

        showSlider = @(onScreenImDim,spDim) (onScreenImDim > spDim) && (spDim-sbw > 0);
        
        % Decide whether scrollbar is showing based on scrollpanel size 
        showSliderHor = showSlider(onScreenImW,spWidth);
        showSliderVer = showSlider(onScreenImH,spHeight);
        % adjust viewport based on whether sliders show
        viewport = adjustViewportBasedOnWhichSlidersShow();
        
        % Fine tune viewport size based on initial size estimate above.
        % When the viewport size is smaller than the scrollpanel size, by
        % about the size of the scrollbar, the initial size estimate will be
        % wrong. see g347083.
        showSliderHor = showSlider(onScreenImW,viewport(1));
        showSliderVer = showSlider(onScreenImH,viewport(2));
        viewport = adjustViewportBasedOnWhichSlidersShow();
        
        set(hSliderVer, 'units', 'normalized');
        set(hSliderHor, 'units', 'normalized');
        set(hFrame, 'units', 'normalized');

        % Only update sliders if they are showing
        if showSliderHor
            updateSliderThumb(viewport(1), onScreenImW, hSliderHor)
        end

        if showSliderVer
            updateSliderThumb(viewport(2), onScreenImH, hSliderVer)
        end

        %--------------------------------------------------------
        function viewport = adjustViewportBasedOnWhichSlidersShow

            viewport(2) = getViewportDim(showSliderHor,hSliderHor,spHeight);
            viewport(1) = getViewportDim(showSliderVer,hSliderVer,spWidth);

            % Slider and frame positions depend on which sliders are showing
            if showSliderVer && ~showSliderHor
                set(hSliderVer, 'position', [(spWidth-sbw)+1 1 sbw spHeight]);
                set(hFrame,'Visible','off')

            elseif ~showSliderVer && showSliderHor
                set(hSliderHor, 'position', [1 1 spWidth sbw]);
                set(hFrame,'Visible','off')

            elseif showSliderVer && showSliderHor
                set(hSliderHor, 'position', [1 1 (spWidth-sbw) sbw]);
                set(hSliderVer, 'position', [(spWidth-sbw)+1 sbw+1 sbw (spHeight-sbw)]);
                set(hFrame,'position', [(spWidth-sbw)+1 1 sbw sbw]);
                set(hFrame,'Visible','on')

            else
                set(hFrame,'Visible','off')

            end

            %--------------------------------------------------------
            function vpDim = getViewportDim(showSlider,hSlider,spDim)

                if showSlider
                    set(hSlider,'visible','on')
                    vpDim = (spDim  - sbw);
                else
                    set(hSlider,'visible','off')
                    vpDim = spDim;
                end

            end

        end

        %------------------------------------------------------
        function updateSliderThumb(vpDim,onScreenImDim,hSlider)
        % This routine is a workaround to a limitation in the
        % uicontrol(...,'Style','slider') so that the "thumb" has a length
        % proportional to the amount of image being shown.
        
            if isFullImageShowing(vpDim,onScreenImDim)
                maxStep = inf;
                minStep = 0.01;
            else
                f = vpDim/onScreenImDim;
                maxStep = 1/(1/f - 1);
                minStep = min(1, maxStep/10); % must be between 0 and 1.
            end

            set(hSlider,'SliderStep',[minStep maxStep]);

        end

    end % updateViewport

    %-----------------------
    function updatePositions

        onScreenImW = getOnScreenImW();
        onScreenImH = getOnScreenImH();

        updateViewport()
        adjustPositions()
        sendNewLocation()

        %-----------------------
        function adjustPositions

            % Make adjustments in case image fits fully inside viewport ("Full View")
            hScrollablePos = get(hScrollable,'position');

            [axX,scrollableX] = ...
                getAdjustedAxPos(viewport(1), hScrollablePos(1), onScreenImW);
            [axY,scrollableY] = ...
                getAdjustedAxPos(viewport(2), hScrollablePos(2), onScreenImH);
            [scrollableW,scrollableH] = calcScrollableDims();

            set(hScrollable,'position',[scrollableX scrollableY scrollableW scrollableH]);

            if isSliderHorShowing && isFullImageHShowing()
                axY = axY + sbw;
            end

            % Also make sure axes dimensions match onScreenDims
            set(hAx,'position',[axX axY onScreenImW onScreenImH])

            %-----------------------------------
            function [axPos,scrollablePos] = ...
                    getAdjustedAxPos(vpDim,scrollablePos,onScreenImDim)

                if isFullImageShowing(vpDim,onScreenImDim)
                    axPos = (vpDim - onScreenImDim)/2 + 1;
                    scrollablePos = 1;
                else
                    axPos = 1;
                end

            end

        end

    end % updatePositions

    %---------------------------------------
    function isShowing = isFullImageWShowing

        isShowing = isFullImageShowing(viewport(1),getOnScreenImW());

    end

    %---------------------------------------
    function isShowing = isFullImageHShowing

        isShowing = isFullImageShowing(viewport(2),getOnScreenImH());

    end

    %------------------------------------
    function onScreenImW = getOnScreenImW

        onScreenImW = imageWidth * screenPerImagePixel;

    end

    %------------------------------------
    function onScreenImH = getOnScreenImH

        onScreenImH = imageHeight * screenPerImagePixel;

    end

end % imscrollpanel

%----------------------------------------------------
function [pos] = findPos(vpDim,onScreenImDim,hSlider)

% Find position of hScrollable with respect to viewport
if isFullImageShowing(vpDim,onScreenImDim)
    pos = 1;
else
    pos = (vpDim-onScreenImDim) * get(hSlider, 'value') + 1;
end

end

%--------------------------------------------------------
function isFull = isFullImageShowing(vpDim,onScreenImDim)

if (vpDim >= onScreenImDim)
    isFull = true;
else
    isFull = false;
end

end


%-------------------------------------------------------
function deltaOnePixel = getDeltaOnePixel(dimData,imDim)
% Calculate the extent of one pixel in terms of the user units as defined by
% dimData which will be either the 'XData' or 'YData' associated with an image.

delta = dimData(2) - dimData(1);
if (imDim ~= 1)
    deltaOnePixel = delta/(imDim-1);
else
    deltaOnePixel = 1;
end

end

%---------------------------------------
function validateHandles(parent,hIm,hAx)

iptcheckhandle(parent,...
    {'figure','uipanel','uicontainer'},...
    mfilename,'HPARENT',1)
iptcheckhandle(hIm,{'image'},mfilename,'HIMAGE',2)

% Check that hIm is only image child of axes
axKids = get(hAx,'Children');
axImKids = findobj(axKids,'flat','Type','image');
if ~isequal(get(hIm,'parent'),hAx) || ~isscalar(axImKids)
    eid =  sprintf('Images:%s:axDoesNotContainOneImage',mfilename);
    error(eid,'Expected axes to contain a single image object HIMAGE.')
end

% Check that axes is a child of parent
if ~isequal(get(hAx,'parent'),double(parent))
    eid =  sprintf('Images:%s:axNotChildOfParent',mfilename);
    error(eid,'Expected axes containing HIMAGE to be a child of HPARENT.')
end

end

%---------------------------------------------------------
function [imageWidth,imageHeight] = validateImageDims(hIm)

img = get(hIm,'cdata');
imageWidth  = size(img,2);
imageHeight = size(img,1);

% Force imageWidth and imageHeight to be nonzero in case either is
% zero. Also fake the XData and YData as needed. - geck 221748
if imageWidth==0
    imageWidth  = 1;
    set(hIm,'XData',[1 1])
end

if imageHeight==0
    imageHeight  = 1;
    set(hIm,'YData',[1 1])
end

end

%--------------------------------------------------
function validateXYData(hIm,imageWidth,imageHeight)

% Check if XData or YData are non-default, warn and reset
[isXDataDefault,isYDataDefault] = isDefaultXYData(hIm);
if ~isXDataDefault || ~isYDataDefault
    wid =  sprintf('Images:%s:nonDefaultXDataOrYData',mfilename);
    msg1 = sprintf('IMSCROLLPANEL currently requires default XData and YData.\n');

    if ~isXDataDefault
        set(hIm,'XData',[1 imageWidth])
        msgXData = sprintf('HIM has non-default XData, resetting to [%d %d].\n',...
            1,imageWidth);
    else
        msgXData = '';
    end

    if ~isYDataDefault
        set(hIm,'YData',[1 imageHeight])
        msgYData = sprintf('HIM has non-default YData, resetting to [%d %d].',...
            1,imageHeight);
    else
        msgYData = '';
    end

    warning(wid,'%s%s%s',msg1,msgXData,msgYData)
end

end