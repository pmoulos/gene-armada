function plotDistribArray(lograt,titre)

% Treat infs... might rarely happen
infs=find(isinf(lograt));
if ~isempty(infs)
    lograt(infs)=NaN;
end

nbins=100;
[n,xout]=hist(lograt,nbins);
figure
h=bar(xout,n,1,'r');
set(h,'EdgeColor','w')
titre=strrep(titre,'_','-');
title(titre,'FontSize',11,'FontWeight','bold')
set(gca,'FontSize',9,'FontWeight','bold')
xlabel('Ratio','FontSize',10,'FontWeight','bold');
ylabel('Gene Frequency','FontSize',10,'FontWeight','bold')
grid on
 