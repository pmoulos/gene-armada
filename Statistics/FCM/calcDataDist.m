function vDist = calcDataDist(Xdat)
%   function vDist = calcDataDist(Xdat);
%
%   Compute the matrix of distances between samples of a data set
%
%   Xdat = data set of size (M,N)
%   vDist = vector of distances of size (N(N-1)/2,1)
%
%   Write by : DD
%       date : 2001/06/26

% Modified on 2007/09/05 by PM to fix some m-lint errors

[M,N] = size(Xdat);
id = 1;
vDist = zeros(1,N*(N-1)/2);
for r=1:N
    for c=r+1:N
        vect = Xdat(:,r)-Xdat(:,c);
        vDist(id) = vect'*vect;
        id = id+1;
    end
end
