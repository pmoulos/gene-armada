function node = ouitreenode(value, string, icon, isLeaf)
% WARNING: This feature is not supported in MATLAB
% and the API and functionality may change in a future release.

%   UITREENODE(Value, Description, Icon, Leaf)
%   creates a tree node object for the uitree with the specified
%   properties. All properties must be specified for the successful
%   creation of a node object.
%
%   Value can be a string or handle represented by this node.
%   Description is a string which is used to identify the node.
%   Icon can be a qualified pathname to an image to be used as an icon
%   for this node. It may be set to [] to use default icons.
%   Leaf can be true or false to denote whether this node has children.
%
%   Example:
%     t = uitree('Root', 'D:\')
%
%     %Creates a uitree widget in a figure window with which acts as a
%     %directory browser with the D: drive as the root node.
%
%     surf(peaks)
%     f = figure
%     t = uitree(f, 'Root', 0)
%
%     %Creates a uitree object in the specified figure window which acts as
%     %a MATLAB hierarchy browser with the MATLAB root (0) as the root node.
%
%     root = uitreenode('S:\', 'S', [], false);
%     t = uitree('Root', root, 'ExpandFcn', @myExpfcn, ...
%                'SelectionChangeFcn', 'disp(''Selection Changed'')');
%
%     %Creates a uitree object with the specified root node and a custom
%     %function to return child nodes for any given node. The function
%     %myExpfcn is a user defined m-file in the MATLAB path.
%
%     % This function should be added to the path
%     % ---------------------------------------------
%     function nodes = myExpfcn(tree, value)
%
%     try
%         count = 0;
%         ch = dir(value);
%
%         for i=1:length(ch)
%             if (any(strcmp(ch(i).name, {'.', '..', ''})) == 0)
%                 count = count + 1;
%                 if ch(i).isdir
%                     iconpath = [matlabroot, '/toolbox/matlab/icons/foldericon.gif'];
%                 else
%                     iconpath = [matlabroot, '/toolbox/matlab/icons/pageicon.gif'];
%                 end
%                 nodes(count) = uitreenode([value, ch(i).name, filesep], ...
%                     ch(i).name, iconpath, ~ch(i).isdir);
%             end
%         end
%     catch
%         error(['The uitree node type is not recognized. You may need to ', ...
%             'define an ExpandFcn for the nodes.']);
%     end
%
%     if (count == 0)
%         nodes = [];
%     end
%     % ---------------------------------------------
%       
%   See also UITREE, UITABLE, JAVACOMPONENT

% Copyright 2003-2006 The MathWorks, Inc.

import com.mathworks.hg.peer.UITreeNode;
node = handle(UITreeNode(value, string, icon, isLeaf));
schema.prop(node, 'UserData', 'MATLAB array');
