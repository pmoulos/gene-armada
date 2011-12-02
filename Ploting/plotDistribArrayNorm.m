function plotDistribArrayNorm(logratnorm,titre)

% Treat infs... might rarely happen
infs=find(isinf(logratnorm));
if ~isempty(infs)
    logratnorm(infs)=NaN;
end

nbins=100;
[n,xout]=hist(logratnorm,nbins);
figure
h=bar(xout,n,1,'b');
set(h,'EdgeColor','w')
titre=strrep(titre,'_','-');
title(titre,'FontSize',11,'FontWeight','bold')
set(gca,'FontSize',9,'FontWeight','bold')
xlabel('Ratio','FontSize',10,'FontWeight','bold');
ylabel('Gene Frequency','FontSize',10,'FontWeight','bold')
grid on
 