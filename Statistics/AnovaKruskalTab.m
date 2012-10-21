function p=AnovaKruskalTab(NormIRfinal,group,slcstatest)

%Create grouptable to run anova
grouptable=cell(max(size(NormIRfinal{1})),1);

b=zeros(1,max(size(NormIRfinal)));
for i=1:max(size(NormIRfinal))
    b(i)=min(size(NormIRfinal{i}));
end

for j=1:max(size(NormIRfinal{1}))
    for i=1:max(size(NormIRfinal))
        test=NormIRfinal{i}(j,:)';
        if max(size(test))<max(b(i))
            for m=max(size(test))+1:max(b(i))
                test(m)=NaN;
            end
        end
        grouptable{j}(1:max(b(i)),i)=test;
    end
end

%Kruskal-Wallis Test per gene
if slcstatest==1
    p=zeros(1,max(size(grouptable)));
    for i=1:max(size(grouptable))
        progressbar(i/max(size(grouptable)),0,'Running Kruskal-Wallis...')
        %[p(i),table{i},stat{i}] = kruskalwallis(grouptable{i},group,'off');
        p(i)=kruskalwallis(grouptable{i},group,'off');
    end
    
%Anova1 Test per gene
elseif slcstatest==2 || slcstatest==4
    p=zeros(1,max(size(grouptable)));
    for i=1:max(size(grouptable))
        progressbar(i/max(size(grouptable)),0,'Running ANOVA...')
        %[p(i),table{i},stat{i}] = anova1(grouptable{i},group,'off');
        p(i)=anova1(grouptable{i},group,'off');
    end
end
p=p';