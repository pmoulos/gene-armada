function plotDistribArrayBeforeAfter(lograt,logratnorm,titre,soustitres)

if nargin<4
    soustitres{1}='Before normalization';
    soustitres{2}='After normalization';
    soustitres{3}='Before and after normalization';
end

nbins=100;
figure

% Treat infs... might rarely happen
infsu=find(isinf(lograt));
if ~isempty(infsu)
    lograt(infsu)=NaN;
end
infsn=find(isinf(logratnorm));
if ~isempty(infsn)
    logratnorm(infsn)=NaN;
end

% Before normalization
subplot(2,2,1)
[nbef,xoutbef]=hist(lograt,nbins);
hbef=bar(xoutbef,nbef,1,'r');
set(hbef,'EdgeColor','w')
title(soustitres{1},'FontSize',10,'FontWeight','bold')
set(gca,'FontSize',8,'FontWeight','bold')
xlabel('Ratio','FontSize',9,'FontWeight','bold');
ylabel('Gene Frequency','FontSize',9,'FontWeight','bold')
grid on

% After normalization
subplot(2,2,2)
[naft,xoutaft]=hist(logratnorm,nbins);
haft=bar(xoutaft,naft,1,'b');
set(haft,'EdgeColor','w')
title(soustitres{2},'FontSize',10,'FontWeight','bold')
set(gca,'FontSize',8,'FontWeight','bold')
xlabel('Ratio','FontSize',9,'FontWeight','bold');
ylabel('Gene Frequency','FontSize',9,'FontWeight','bold')
grid on

% Before and after normalization
subplot(2,2,3:4)
hbefaft1=bar(xoutbef,nbef,1,'r');
set(hbefaft1,'EdgeColor','w')
hold on
hbefaft2=bar(xoutaft,naft,1,'b');
set(hbefaft2,'EdgeColor','w')
title(soustitres{3},'FontSize',10,'FontWeight','bold')
set(gca,'FontSize',8,'FontWeight','bold')
xlabel('Ratio','FontSize',9,'FontWeight','bold');
ylabel('Gene Frequency','FontSize',9,'FontWeight','bold')
hall=[hbefaft1;hbefaft2];
strleg={'Before normalization','After normalization'};
legend(hall,strleg)
grid on

set(gcf,'Name',titre)
 