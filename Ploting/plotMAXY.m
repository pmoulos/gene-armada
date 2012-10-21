function plotMAXY(x,opts,colnams,sup)

if nargin<3
    m=size(x,2);
    colnams=cell(1,m);
    for i=1:m
        colnams{i}=['Sample ',num2str(i)];
    end
end
if nargin<4
    sup='';
end

x=affytransform(x,opts);
n=size(x,2);
mn=nanmean(x);
md=nanmedian(x);
st=nanstd(x);
iq=iqr(x);
[l,b,w,h]=createGrid(n,n);
colnams=strrep(colnams,'_','-');

if size(x,1)>1e+5
    msize=2;
else
    msize=6;
end

figure;
c=0;
for i=1:n
    for j=1:n
        c=c+1;
        subplot('Position',[l(c),b(c),w(c),h(c)]);
        if (i>j) % Mean-difference
            plot((x(:,j)+x(:,i))/2,x(:,i)-x(:,j),'.r','MarkerSize',msize)
            title(['MA ',colnams{j},' vs ',colnams{i}],'FontSize',8,'FontWeight','bold')
            set(gca,'FontSize',7,'FontWeight','bold')
            grid on
        elseif (i<j) % Scatterplot
            plot(x(:,i),x(:,j),'.b','MarkerSize',msize)
            title(['XY ',colnams{i},' vs ',colnams{j}],'FontSize',8,'FontWeight','bold')
            set(gca,'FontSize',7,'FontWeight','bold')
            grid on
        else
            if ~isempty(sup)
            displ={colnams{i},['Mean ',num2str(mn(i))],['Median ',num2str(md(i))],...
                   ['StDev ',num2str(st(i))],['IQR ',num2str(iq(i))],sup};
            else
                displ={colnams{i},['Mean ',num2str(mn(i))],['Median ',num2str(md(i))],...
                       ['StDev ',num2str(st(i))],['IQR ',num2str(iq(i))]};
            end
            set(gca,'XTick',[],'YTick',[],'ZTick',[])
            box on
            text(0.5,0.5,displ,'Units','normalized',...
                               'HorizontalAlignment','center',...
                               'FontSize',9,...
                               'FontWeight','bold')
        end
    end
end


function tx = affytransform(x,opts)

% Change of scale, everything must be in log2
if ismember(opts.type,107:109) 
    switch opts.scale
        case 'log'
            tx=log2(exp(x));
        case 'log2'
            tx=x;
        case 'log10'
            tx=log2(10.^x);
        case 'natural'
            tx=log2(x);
    end
else
    tx=log2(x);
end
