function Cmat = fcm_dataInitC(Xdat,K)
%   Cmat = fcm_dataInitC(Xdat,K);
%
%   form initial matrix of centroids using K random samples of data set
%
%   Xdat = data matrix of size (M,N)
%   Cmat = matrix of initial centroids of size (M,K)
%
%   write by : DD
%       date : 2001/07/24

% Modified on 2007/09/05 by PM to fix some m-lint errors

[M,N] = size(Xdat);
Cidx = floor((N-1)*rand(K,1)+1);
for ik=1:K
    Cmat(:,ik) = Xdat(:,Cidx(ik));
end
