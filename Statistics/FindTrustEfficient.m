function [trustcoef]=FindTrustEfficient(data)

[n,p]=size(data);
for k=1:p
    trustcoef(k)=(numel(find(isnan(data(:,k)))))/n;
%    trustcoef=trustcoef'; %!!!BUG!!! Trustcoef changes orientation in each step!!!
end

trustcoef=trustcoef';