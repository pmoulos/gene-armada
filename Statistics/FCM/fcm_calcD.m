function Dmat = fcm_calcD(Xdat,Cmat)
%   function Dmat = fcm_calcD(Xdat,Cmat);
%
%   Compute matrix of distances between data samples and cluster centers
%
%   Xdat = matrix of data set of size (M,N)
%   Cmat = matrix of centroids of size (M,K)
%   Dmat = matrix of distances of size (K,N)
%
%   write by : DD
%       date : 2001/03/16

% Modified on 2007/09/05 by PM to fix some m-lint errors

[M,N] = size(Xdat);
[M2,K] = size(Cmat);

if (M ~= M2)
    error('fcm_calcD() : incompatible dimensions');
end

Dmat = zeros(K,N);
for ik=1:K
    for ii=1:N
        dvect = Xdat(:,ii)-Cmat(:,ik);
        Dmat(ik,ii) = dvect'*dvect;
    end
end
