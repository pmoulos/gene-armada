function valJ = fcm_evalJ(Umat,mfuz,Dmat)
%   function valJ = fcm_evalJ(Umat,mfuz,Dmat);
%
%   Compute the value of the criterion
%
%   write by : DD
%       date : 2001/05/07
%      modif : 2001/06/27

% Modified on 2007/09/05 by PM to fix some m-lint errors

[K, N] = size(Umat);
[K2,N2] = size(Dmat);
if ((K ~= K2) || (N ~= N2))
    error('fcm_evalJ() : incompatible dimensions');
end
valJ = 0;
for k=1:K
    valJ = valJ+((Umat(k,:).^mfuz)*Dmat(k,:)');
end
