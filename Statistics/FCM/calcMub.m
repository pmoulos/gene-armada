function [mub,it] = calcMub(Xdat,seuil,itmax,epsilon)
%   function [mub,it] = calcMub(Xdat,seuil,itmax,epsilon);
%
%   Compute upper bound value of fuzzy parameter
%
%   Xdat = data set of size (M,N)
%
%   Caution :
%   This funtion can take a lot of time when data set
%   has high dimensions. In such case we recommend to
%   compute the vector of distances using "C" or other
%   compiled langage and then use the function
%   "mub = searchMub(...)"
%
%   Write by : DD
%       date : 2001/06/24

% Modified on 2007/09/05 by PM to fix some m-lint errors

M = size(Xdat);
M = M(1);
vD = calcDataDist(Xdat); %% can be computationally expensive
%   User can modify the following three parameters
%seuil = 0.03;   itmax = 500;    epsilon = 0.001;

cv_mub = seuil*M;
[mub,it] = searchMub(vD,cv_mub,epsilon,itmax);
