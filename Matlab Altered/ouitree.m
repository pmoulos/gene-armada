function [tree, container] = ouitree(varargin)
% WARNING: This feature is not supported in MATLAB
% and the API and functionality may change in a future release.

% UITREE creates a uitree component with hierarchical data in a figure window.
%   UITREE creates an empty uitree object with default property values in
%   a figure window.
%
%   UITREE('PropertyName1', 'Value1', 'PropertyName2', 'Value2', ...)
%   creates a uitree object with the specified properties. The properties
%   that can be set are: Root, ExpandFcn, SelectionChangeFcn, Parent and
%   Position. The 'Root' property must be specified to successfully to
%   create a uitree. The other properties are optional.
%
%   UITREE(figurehandle, ...) creates a uitree object in the figure
%   window specified by the figurehandle.
%
%   HANDLE = UITREE(...) creates a uitree object and returns its handle.
%
%   Properties:
%
%   Root - Root node for the uitree object. Could be handle to a HG
%   object, a string, an open block diagram name, or handle to a
%   UITREENODE object.
%   ExpandFcn - Node expansion function. String or function handle.
%   SelectionChangeFcn - Selection callback function. String or function
%   handle.
%   Parent - Parent figure handle. If not specified, it is the gcf.
%   Position: 4 element vector specifying the position.
%
%   DndEnabled: Boolean specifying if drag and drop is enabled (false).
%   MultipleSelectionEnabled: Boolean specifying if multiple selection is
%   allowed (false).
%   SelectedNodes: vector of uitreenodes to be selected.
%   Units: String - pixels/normalized/inches/points/centimeters.
%   Visible: Boolean specifying if table is visible.
%   NodeDroppedCallback: Callback for a drag and drop action.
%   NodeExpandedCallback: Callback for a node expand action.
%   NodeCollapsedCallback: Callback function for a node collapse action.
%   NodeSelectedCallback: Callback for a node selection action.
%
%
%   Examples:
%           t = uitree('Root', 'D:\')
%
%       %Creates a uitree widget in a figure window with which acts as a
%       %directory browser with the D: drive as the root node.
%
%           surf(peaks)
%           f = figure
%           t = uitree(f, 'Root', 0)
%
%       %Creates a uitree object in the specified figure window which acts as
%       %a MATLAB hierarchy browser with the MATLAB root (0) as the root node.
%
%           root = uitreenode('S:\', 'S', [], false);
%           t = uitree('Root', root, 'ExpandFcn', @myExpfcn, ...
%                     'SelectionChangeFcn', 'disp(''Selection Changed'')');
%
%       %Creates a uitree object with the specified root node and a custom
%       %function to return child nodes for any given node. The function
%       %myExpfcn is an m-file in the MATLAB path with the following code:
%
%       %This function should be added to your path
%       % ---------------------------------------------
%       function nodes = myExpfcn(tree, value)
%
%       try
%           count = 0;
%           ch = dir(value);
%
%           for i=1:length(ch)
%               if (any(strcmp(ch(i).name, {'.', '..', ''})) == 0)
%                   count = count + 1;
%                   if ch(i).isdir
%                       iconpath = [matlabroot, '/toolbox/matlab/icons/foldericon.gif'];
%                   else
%                       iconpath = [matlabroot, '/toolbox/matlab/icons/pageicon.gif'];
%                   end
%                   nodes(count) = uitreenode([value, ch(i).name, filesep], ...
%                       ch(i).name, iconpath, ~ch(i).isdir);
%               end
%           end
%       catch
%           error(['The uitree node type is not recognized. You may need to ', ...
%               'define an ExpandFcn for the nodes.']);
%       end
%
%       if (count == 0)
%           nodes = [];
%     	end
%       % ---------------------------------------------
%
%   See also UITREENODE, UITABLE, PATH

%   Copyright 2003-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.15 $  $Date: 2006/11/29 21:53:14 $

%   Release: R14. This feature will not work in previous versions of MATLAB.

%% Setup and P-V parsing.

error(javachk('awt'));
error(nargoutchk(0, 2, nargout));

fig = [];
numargs = nargin;

if (nargin > 0 && isscalar(varargin{1}) && ishandle(varargin{1}))
    if ~isa(handle(varargin{1}), 'figure')
        error('MATLAB:uitree:InvalidFigureHandle', 'Unrecognized parameter.');
    end
    fig = varargin{1};
    varargin = varargin(2:end);
    numargs = numargs - 1;
end

% RootFound = false;
root   = [];
expfcn = [];
selfcn = [];
pos    = [];
% parent = [];

if (numargs == 1)
    error('MATLAB:uitree:InvalidNumInputs', 'Unrecognized parameter.');
end

for i = 1:2:numargs-1
    if ~ischar(varargin{i})
        error('MALTAB:uitree:UnrecognizedParameter', 'Unrecognized parameter.');

    end
    switch lower(varargin{i})
        case 'root'
            root = varargin{i+1};
        case 'expandfcn'
            expfcn = varargin{i+1};
        case 'selectionchangefcn'
            selfcn = varargin{i+1};
        case 'parent'
            if ishandle(varargin{i+1})
                f = varargin{i+1};
                if isa(handle(f), 'figure')
                    fig = f;
                end
            end
        case 'position'
            p = varargin{i+1};
            if isnumeric(p) && (length(p) == 4)
                pos = p;
            end
        otherwise
            error('MALTAB:uitree:UnknownParameter', ['Unrecognized parameter: ', varargin{i}]);
    end
end

if isempty(expfcn)
    [root, expfcn] = processNode(root);
else
    root = processNode(root);
end

tree_h = com.mathworks.hg.peer.UITreePeer;
tree_h.setRoot(root);

if isempty(fig)
    fig = gcf;
end

if isempty(pos)
    figpos = get(fig, 'Position');
    pos =  [0 0 min(figpos(3), 200) figpos(4)];
end

% pass the figure child in, let javacomponent introspect
[obj, container] = javacomponent(tree_h, pos, fig);
% javacomponent returns a UDD handle for the java component passed in.
tree = obj;

if ~isempty(expfcn)
    set(tree, 'NodeExpandedCallback', {@nodeExpanded, tree, expfcn});
end

if ~isempty(selfcn)
    set(tree, 'NodeSelectedCallback', {@nodeSelected, tree, selfcn});
end

end

%% -----------------------------------------------------
function nodeExpanded(src, evd, tree, expfcn)                           %#ok

% tree = handle(src);
% evdsrc = evd.getSource;

evdnode  = evd.getCurrentNode;
% indices = [];

if ~tree.isLoaded(evdnode)
    value = evdnode.getValue;

    % <call a user function(value) which returns uitreenodes>;
    cbk = expfcn;
    if iscell(cbk)
        childnodes = feval(cbk{1}, tree, value, cbk{2:end});
    else
        childnodes = feval(cbk, tree, value);
    end

    if (length(childnodes) == 1)
        % Then we dont have an array of nodes. Create an array.
        chnodes = childnodes;
        childnodes = javaArray('com.mathworks.hg.peer.UITreeNode', 1);
        childnodes(1) = java(chnodes);
    end

    tree.add(evdnode, childnodes);
    tree.setLoaded(evdnode, true);
end

end

%% -----------------------------------------------------
function nodeSelected(src, evd, tree, selfcn)                           %#ok
cbk = selfcn;
hgfeval(cbk, tree, evd);

end

%% -----------------------------------------------------
function [node, expfcn] = processNode(root)
expfcn = [];

if isempty(root) || isa(root, 'com.mathworks.hg.peer.UITreeNode') || ...
        isa(root, 'javahandle.com.mathworks.hg.peer.UITreeNode')
    node = root;
elseif ishghandle(root)
    % Try to process as an HG object.
    try
        node = uitreenode(handle(root), get(root, 'Type'), ...
            [], isempty(get(0, 'children')));
    catch
        node = [];
    end
    expfcn = @hgBrowser;
elseif ismodel(root)
    % Try to process as an open Simulink system

    % TODO if there is an open simulink system and a directory on the path with
    % the same name, the system will hide the directory. Perhaps we should
    % warn about this.
    try
        h = handle(get_param(root,'Handle'));
        % TODO we pass root to the tree as a string,
        % it would be better if we could just pass the
        % handle up
        node = uitreenode(root, get(h, 'Name'), ...
            [], isempty(h.getHierarchicalChildren));
    catch
        node = [];
    end
    expfcn = @mdlBrowser;
elseif ischar(root)
    % Try to process this as a directory structure.
    try
        iconpath = [matlabroot, '/toolbox/matlab/icons/foldericon.gif'];
        node = uitreenode(root, root, iconpath, ~isdir(root));
    catch
        node = [];
    end
    expfcn = @dirBrowser;
else
    node = [];
end

end

%% -----------------------------------------------------
function nodes = hgBrowser(tree, value)                                 %#ok

try
    count = 0;
    parent = handle(value);
    ch = parent.children;

    for i=1:length(ch)
        count = count+1;
        nodes(count) = uitreenode(handle(ch(i)), get(ch(i), 'Type'), [], ...
            isempty(get(ch(i), 'children')));
    end
catch
    error('MATLAB:uitree:UnknownNodeType', ['The uitree node type is not recognized. You may need to ', ...
        'define an ExpandFcn for the nodes.']);
end

if (count == 0)
    nodes = [];
end

end

%% -----------------------------------------------------
function nodes = mdlBrowser(tree, value)                                %#ok

try
    count = 0;
    parent = handle(get_param(value,'Handle'));
    ch = parent.getHierarchicalChildren;

    for i=1:length(ch)
        if isempty(findstr(class(ch(i)),'SubSystem'))
            % not a subsystem
        else
            % is a subsystem
            count = count+1;
            descr = get(ch(i),'Name');
            isleaf = true;
            cch =  ch(i).getHierarchicalChildren;
            if ~isempty(cch)
                for j = 1:length(cch)
                    if ~isempty(findstr(class(cch(j)),'SubSystem'))
                        isleaf = false;
                        break;
                    end
                end
            end
            nodes(count) = uitreenode([value '/' descr], descr, [], ...
                isleaf);
        end
    end
catch
    error('MATLAB:uitree:UnknownNodeType', ['The uitree node type is not recognized. You may need to ', ...
        'define an ExpandFcn for the nodes.']);
end

if (count == 0)
    nodes = [];
end

end


%% -----------------------------------------------------
function nodes = dirBrowser(tree, value)                                %#ok

try
    count = 0;
    ch = dir(value);

    for i=1:length(ch)
        if (any(strcmp(ch(i).name, {'.', '..', ''})) == 0)
            count = count + 1;
            if ch(i).isdir
                iconpath = [matlabroot, '/toolbox/matlab/icons/foldericon.gif'];
            else
                iconpath = [matlabroot, '/toolbox/matlab/icons/pageicon.gif'];
            end
            nodes(count) = uitreenode([value, ch(i).name, filesep], ...
                ch(i).name, iconpath, ~ch(i).isdir);
        end
    end
catch
    error('MATLAB:uitree:UnknownNodeType', ['The uitree node type is not recognized. You may need to ', ...
        'define an ExpandFcn for the nodes.']);
end

if (count == 0)
    nodes = [];
end

end

%% -----------------------------------------------------
function yesno = ismodel(input)
yesno = false;

try
    get_param(input,'handle');
    yesno = true;
catch
end

end
