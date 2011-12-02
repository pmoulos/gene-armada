function Cmat = fcm_calcC(Xdat,K,mfuz,Umat)
%   function Cmat = fcm_calcC(Xdat,K,mfuz,Umat);
%
%   Compute the matrix of centroids
%   
%   Xdat = matrix of data set of size (M,N)
%   K    = number of clusters
%   mfuz = fuzzy parameter (>1)
%   Umat = fuzzy partition matrix of size (K,N)
%   Cmat = matrix of centroids of size (M,K)
%
%   write by : DD
%       date : 2001/05/07
%      modif : 2001/06/27

% Modified on 2007/09/05 by PM to fix some m-lint errors

for k=1:K
    tmp = (Umat(k,:).^mfuz);
    nume = Xdat*tmp';
    deno = sum(tmp);
    Cmat(:,k) = nume/deno;
end
return %% end of function fcm_calcC()