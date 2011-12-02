function intensity = getProbeIntensity(celstru,cdfstru,numprobes,type)

% Help function to read out the probe intensity from a Affymetrix ARMADA structure.

intensity=zeros(numprobes,1);
numcols=cdfstru.Cols;
paircount=0;

colid=0;
if type==1 % For PM probe intensity 
    colid=3;
elseif type==2
    colid=5; % for MM probe intensity
end
    
for i=1:cdfstru.NumProbeSets
    numpairs=cdfstru.ProbeSets(i).NumPairs;
    thepairs=cdfstru.ProbeSets(i).ProbePairs;
    PX=thepairs(:,colid);
    PY=thepairs(:,colid+1);
    intensity(paircount+1:paircount+numpairs,1)=celstru.Intensity(PY*numcols+PX+1);
    paircount=paircount+numpairs;
end