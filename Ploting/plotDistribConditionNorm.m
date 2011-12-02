function plotDistribConditionNorm(logratnorm,titre,leg)
    
nbins=100;
figure
hist(logratnorm,nbins);
h=findobj(gca,'Type','specgraph.barseries');
set(h,'EdgeColor','w','BarWidth',1)
titre=strrep(titre,'_','-');
title(titre,'FontSize',11,'FontWeight','bold')
set(gca,'FontSize',9,'FontWeight','bold')
xlabel('Ratio','FontSize',10,'FontWeight','bold');
ylabel('Gene Frequency','FontSize',10,'FontWeight','bold')
legend(strrep(leg,'_','-'))
grid on