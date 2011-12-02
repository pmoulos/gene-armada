function tree = myexplorestruct(h,stru,name,ind)

import javax.swing.tree.*;

root=ouitreenode('Main','New Project',[],false);
set(root,'Name',name);
tree=ouitree(h,'Root',root,'ExpandFcn',@myExpfcn);
set(tree,'Units','normalized','Position',[0.005 0.027 0.17 0.91]); %was [0.005 0.027 0.25 0.92]
set(tree,'NodeWillExpandCallback',@nodeWillExpand);
set(tree,'NodeSelectedCallback',@nodeSelected);
% projExp=uicontrol(h,'String','Project Explorer','Units','normalized','Style','Text',...
%                   'Position',[0.005 0.975 0.17 0.015],...%'BackgroundColor',[235/255 233/255 237/255],...
%                   'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'),...
%                   'FontSize',8,'Tag','projExpText');
projExp=findobj('Tag',['projExpStatic',num2str(ind)]);
set(projExp,'Visible','on')
global itemInfo
% itemInfo=uicontrol(h,'String','Item Information','Units','normalized','Style','Edit',...
%                    'Position',[0.005 0.9425 0.17 0.028],'BackgroundColor',[.925 .914 .847],...
%                    'FontSize',9,'FontWeight','demi','Tag','itemInfo');
itemInfo=findobj('Tag',['itemInfoEdit',num2str(ind)]);
set(itemInfo,'Visible','on')%,'BackgroundColor',[.925 .914 .847],...
             %'FontSize',9,'FontWeight','demi')
tmp=tree.FigureComponent;
cellData=cell(2,1);
cellData{1}=stru;
set(tmp,'UserData',cellData);


function cNode = nodeSelected(tree,ev)

global itemInfo

cNode=ev.getCurrentNode;
tmp=tree.FigureComponent;
cellData=get(tmp,'UserData');
cellData{2}=cNode;
set(tmp,'UserData',cellData);
tmp=tree.FigureComponent;
S=get(tmp,'UserData');
s=S{1};
cNode=S{2};
val=getcNodevalue(cNode,s);
if ischar(val)
    outstr=val;
elseif isnumeric(val)
    outstr=num2str(val);
else
    outstr='Selected node is not a string';
end
set(itemInfo,'String',outstr)

    
function nodes = myExpfcn(tree,value)

try
    tmp=tree.FigureComponent;
    S=get(tmp,'UserData');
    s=S{1};
    cNode=S{2};
    [val,cNode]=getcNodevalue(cNode,s);
    fnames=fieldnames(val);
    pth='I:\Microarray Tool\Icons\';
    L=length(val);
    count=0;
    if L>1
        iconpath=[pth,'struct_icon.GIF'];
        for J=1:L
            count=count+1;
            cNode=S{2};
            fname=strcat(cNode.getValue,'(',num2str(J),')');
            nodes(count)=ouitreenode(fname,fname,iconpath,0);
        end
    else
        for i=1:length(fnames)
            count=count+1;
            x=getfield(val,fnames{i});
            if isstruct(x)
                if length(x)>1
                    iconpath=[pth,'structarray_icon.GIF'];
                else
                    iconpath=[pth,'struct_icon.GIF'];
                end
            elseif isnumeric(x)
                iconpath=[pth,'double_icon.GIF'];
            elseif iscell(x)
                iconpath=[pth,'cell_icon.GIF'];
            elseif ischar(x)
                iconpath=[pth,'char_icon.GIF'];
            elseif islogical(x)
                iconpath=[pth,'logic_icon.GIF'];
            elseif isobject(x)
                iconpath=[pth,'obj_icon.GIF'];
            else
                iconpath=[pth,'unknown_icon.GIF'];
            end
            nodes(count)=ouitreenode(fnames{i},fnames{i},iconpath,~isstruct(x));
        end
    end
catch
    uiwait(errordlg({'The uitree node type is not recognized.',...
                     'You may need to define an ExpandFcn for the nodes.',...
                     lasterr},'Error'));
end
if (count==0)
    nodes=[];
end


function cNode = nodeWillExpand(tree,ev)

cNode=ev.getCurrentNode;
tmp=tree.FigureComponent;
cellData=get(tmp,'UserData');
cellData{2}=cNode;
set(tmp,'UserData',cellData);


function [val,displayed,cNode] = getcNodevalue(cNode,s)
        
fields={};        
while cNode.getLevel~=0
    fields=[fields;cNode.getValue];
    c=findstr(cNode.getValue,'(');
    if ~isempty(c) && cNode.getLevel~=0
        cNode=cNode.getParent;
    end

    if  cNode.getLevel==0
        break
    end
    cNode=cNode.getParent;
end
val=s;
if ~isempty(fields)
    L=length(fields);
    displayed=fields{L};
    for j=L-1:-1:1
        displayed=strcat(displayed,'.',fields{j});
    end
    for i=L:-1:1
        field=fields{i};
        d=findstr(field,'(');
        if ~isempty(d)
            idx=str2num(field(d+1));
            field=field(1:d-1);
            if (strcmp(field,cNode.getValue))
                val=val(idx);
            else
                val=getfield(val,field,{idx});
            end
        else
            val=getfield(val,field);
        end
    end
else
    displayed=cNode.getValue;
    return
end
