function message(str,htext,emp)

if nargin<2
    htext=[];
    emp=0;
end
if nargin<3
    emp=0;
end

% Get the message from the ARMADA main textbox
if ~isempty(htext)
    mainmsg=get(htext,'String');
    % Update it
    mainmsg=[mainmsg;repmat(' ',[emp 1]);str;repmat(' ',[emp 1])];
    set(htext,'String',mainmsg)
    drawnow;
else
    str=char(str);
    for i=1:emp
        disp(' ')
    end
    for i=1:size(str,1)
        disp(str(i,:))
    end
    for i=1:emp
        disp(' ')
    end
end