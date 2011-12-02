function mfinal = setm(mub)

% Final m parameter setting for automatic m find in fcm clustering
% Rest of the algorithms taken from Dembele and Kastner, in FCM paper in Bioinformatics
% (19(2), 2003, pp 973-980)

% Writen by PM on 2007/09/05

if mub>=10
    mo=1;
else
    mo=mub/10;
end
mfinal=1+mo;