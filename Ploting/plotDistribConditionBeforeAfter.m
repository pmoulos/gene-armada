function plotDistribConditionBeforeAfter(lograt,logratnorm,titre,leg,soustitres)

if nargin<4
    soustitres{1}='Before normalization';
    soustitres{2}='After normalization';
end

nbins=100;
figure

% Plot before normalization
subplot(2,1,1)
hist(lograt,nbins);
h=findobj(gca,'Type','specgraph.barseries');
set(h,'EdgeColor','w','BarWidth',1)
title(soustitres{1},'FontSize',10,'FontWeight','bold')
set(gca,'FontSize',8,'FontWeight','bold')
xlabel('Ratio','FontSize',9,'FontWeight','bold');
ylabel('Gene Frequency','FontSize',9,'FontWeight','bold')
legend(strrep(leg,'_','-'))
grid on

% Plot after normalization
subplot(2,1,2)
hist(logratnorm,nbins);
h=findobj(gca,'Type','specgraph.barseries');
set(h,'EdgeColor','w','BarWidth',1)
title(soustitres{2},'FontSize',10,'FontWeight','bold')
set(gca,'FontSize',8,'FontWeight','bold')
xlabel('Ratio','FontSize',9,'FontWeight','bold');
ylabel('Gene Frequency','FontSize',9,'FontWeight','bold')
legend(strrep(leg,'_','-'))
grid on

set(gcf,'Name',titre)
