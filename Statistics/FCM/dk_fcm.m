function [Umat,Cmat,it,valJ] = dk_fcm(Xdat,K,mfuz,epsilon,itmax)
%   function [Umat,Cmat,it,valJ] = fcm(Xdat,K,mfuz,epsilon,itmax);
%
%   Fuzzy C-means algorithm for clustering a data set
%
%   Xdat    = input data set of size (M,N)
%   K       = number of clusters in the data set
%   mfuz    = fuzzy parameter
%   epsilon = lower bound for partition matrix used to stop the method
%   itmax   = maximum number of iterations to stop the method
%   Umat    = fuzzy partition matrix
%   Cmat    = matrix of centroids
%   it      = number of iterations done
%
%   write by : DD
%       date : 2001/03/19
%      modif : 2001/06/27

% Modified on 2007/09/05 by PM to fix some m-lint errors

%   initialization of Cmat using random values
Cmat = fcm_dataInitC(Xdat,K);
%   compute matrix of distance
Dmat = fcm_calcD(Xdat,Cmat);
%   compute initial Umat
Umat = fcm_calcU(mfuz,Dmat);
Ut = Umat;
it=1; stab = 0;
while (it<itmax && stab ~=1)
    %   compute Cmat, the matrix of centroids, from Xdat and Ut
    Cmat = fcm_calcC(Xdat,K,mfuz,Ut);
    %   Compute Dmat, the matrix of distances (euclidian)
    Dmat = fcm_calcD(Xdat,Cmat);
    %   update Umat, the fuzzy partition matrix
    Umat = fcm_calcU(mfuz,Dmat);
    %   Calculate difference between Ut and Umat and put it in Ut
    Ut = Ut-Umat;
    fnorm = norm(Ut,'fro');
    if (fnorm<epsilon)
        stab = 1;
    else
        Ut = Umat;
    end
    it = it+1;
end
valJ = fcm_evalJ(Umat,mfuz,Dmat);
