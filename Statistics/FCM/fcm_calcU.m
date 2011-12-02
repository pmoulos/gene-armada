function Umat = fcm_calcU(mfuz,Dmat)
%   function Umat = fcm_calcU(mfuz,Dmat);
%
%   Compute the partition matrix using matrix of distances
%
%   mfuz = fuzzy parameter (> 1)
%   Dmat = matrix of distances of size (K,N)
%   Umat = fuzzy partition matrix of size (K,N)
%
%   write by : DD
%       date : 2001/05/07
%      modif : 2001/06/27

% Modified on 2007/09/05 by PM to fix some m-lint errors

[K,N] = size(Dmat);
Umat = zeros(K,N);
for r=1:N
    cardIr = 0;
    for s=1:K
        if (Dmat(s,r) == 0.0)
            cardIr = cardIr+1;
        end
    end
    if (cardIr == 0)
        for s=1:K
            nume = Dmat(s,r);
            deno = (nume./Dmat(:,r)).^(1/(mfuz-1));
            Umat(s,r) = 1.0/sum(deno);
        end    
    else
       for s=1:K
           if (Dmat(s,r) == 0.0)
               Umat(s,r) = 1.0/cardIr;
           else
               Umat(s,r)= 0.0;
           end
       end
    end
end
