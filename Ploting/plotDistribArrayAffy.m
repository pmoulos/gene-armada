function plotDistribArrayAffy(x,what,titre,legtxt,single)

% x: data matrix, one array per column
% what: what the columns represent, text for x-axis
% titre: plot title(s)
% legtxt: for legends
% single: if true, only one figure

% Treat infs... might rarely happen
infs=find(isinf(x));
if ~isempty(infs)
    x(infs)=NaN;
end

m=size(x,2);
nbins=100;
if single && m~=1
    c=zeros(nbins,m);
    n=zeros(nbins,m);
    h=zeros(1,m);
    colors=rand(m,3);
    figure;
    hold on
    for i=1:m
        [c(:,i),n(:,i)]=hist(x(:,i),nbins);
        h(i)=plot(n(:,i),c(:,i),'-','Color',colors(i,:),'LineWidth',2);
    end
    titre=strrep(titre,'_','-');
    title(titre,'FontSize',11,'FontWeight','bold')
    set(gca,'FontSize',9,'FontWeight','bold')
    xlabel(what,'FontSize',10,'FontWeight','bold');
    ylabel('Frequency','FontSize',10,'FontWeight','bold')
    grid on
    if ~isempty(legtxt)
        legend(h,strrep(legtxt,'_','-'));
    end
end
if ~single || m==1
    for i=1:m
        [c,n]=hist(x(:,i),nbins);
        figure;
        h=bar(n,c,'r');
        set(h,'EdgeColor','w')
        titre{i}=strrep(titre{i},'_','-');
        title(titre{i},'FontSize',11,'FontWeight','bold')
        set(gca,'FontSize',9,'FontWeight','bold')
        xlabel(what,'FontSize',10,'FontWeight','bold');
        ylabel('Frequency','FontSize',10,'FontWeight','bold')
        grid on
    end
end
 