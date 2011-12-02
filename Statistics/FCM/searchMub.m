function [mub,it] = searchMub(vDist,cv_mub,epsilon,itmax)
%   function [mub,it] = searchMub(vDist,cv_mub,epsilon,itmax);
%
%   Search for upper bound value of fuzzy parameter
%
%   vDist   = vector of distances between samples of data set
%   cv_mub  = minimum cv which gives no clustering structure
%   epsilon = scalar (stopping rule 1)
%   itmax   = maximum number of iterations (stopping rule 2)
%
%   Write by : DD
%       date : 2001/06/24

% Modified on 2007/09/05 by PM to fix some m-lint errors

Yo = vDist/max(vDist);
cv = std(Yo)/mean(Yo);
mubMax = 1000; % can be adjusted by user
it = 1;
if (abs(cv-cv_mub)<epsilon)
    mub = 2;
else
    if (cv>cv_mub)
        m1 = 2;
        m2 = mubMax;
    else
        m1 = 1+epsilon;
        m2 = 2;
    end 
    while ((it<itmax) && (abs(cv-cv_mub)>epsilon))
        m = (m1+m2)/2;
        d = 1/(m-1);
        Y = Yo.^d;
        cv = std(Y)/mean(Y);
        if (abs(cv-cv_mub)<epsilon)
            mub = m;
        elseif (cv>cv_mub)
            m1 = m;
        else  
            m2 = m;
        end
        it = it+1;
    end
end
