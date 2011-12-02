function [left,bottom,width,height] = createGrid(m,n)

% Create an m x n grid for a multiple clustering plot. This function returns the proper
% axes positions. Made because subplot leaves by default too much empty space.

offset=0.03;

% Swap them for better final appearance
if m>n
    t=m;
    m=n;
    n=t;
end

left=linspace(offset,1,m+1);
bottom=linspace(offset,1,n+1);
bottom=fliplr(bottom);
left(end)=[];
bottom(1)=[];

if length(left)==1
    width=1-2*offset;
else
    width=diff(left)-offset;
end
width(end+1)=width(end);
if length(bottom)==1
    height=1-2*offset;
else
    height=diff(fliplr(bottom))-offset;
end
height(end+1)=height(end);

if m>n
    left=repmat(left,[1 min(m,n)]);
    bottom=repmat(bottom,[max(m,n) 1]);
    width=repmat(width,[1 min(m,n)]);
    height=repmat(height,[max(m,n) 1]);
else
    left=repmat(left,[1 max(m,n)]);
    bottom=repmat(bottom,[min(m,n) 1]);
    width=repmat(width,[1 max(m,n)]);
    height=repmat(height,[min(m,n) 1]);
end
bottom=bottom(:);
bottom=bottom';
height=height(:);
height=height';