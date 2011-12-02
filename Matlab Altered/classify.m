function [outclass, err, posterior, logp, coeffs] = classify(sample, training, group, type, prior)
%CLASSIFY Discriminant analysis.
%   CLASS = CLASSIFY(SAMPLE,TRAINING,GROUP) classifies each row of the data
%   in SAMPLE into one of the groups in TRAINING.  SAMPLE and TRAINING must
%   be matrices with the same number of columns.  GROUP is a grouping
%   variable for TRAINING.  Its unique values define groups, and each
%   element defines which group the corresponding row of TRAINING belongs
%   to.  GROUP can be a categorical variable, numeric vector, a string
%   array, or a cell array of strings.  TRAINING and GROUP must have the
%   same number of rows.  CLASSIFY treats NaNs or empty strings in GROUP as
%   missing values, and ignores the corresponding rows of TRAINING. CLASS
%   indicates which group each row of SAMPLE has been assigned to, and is
%   of the same type as GROUP.
%
%   CLASS = CLASSIFY(SAMPLE,TRAINING,GROUP,TYPE) allows you to specify the
%   type of discriminant function, one of 'linear', 'quadratic',
%   'diagLinear', 'diagQuadratic', or 'mahalanobis'.  Linear discrimination
%   fits a multivariate normal density to each group, with a pooled
%   estimate of covariance.  Quadratic discrimination fits MVN densities
%   with covariance estimates stratified by group.  Both methods use
%   likelihood ratios to assign observations to groups.  'diagLinear' and
%   'diagQuadratic' are similar to 'linear' and 'quadratic', but with
%   diagonal covariance matrix estimates.  These diagonal choices are
%   examples of naive Bayes classifiers.  Mahalanobis discrimination uses
%   Mahalanobis distances with stratified covariance estimates.  TYPE
%   defaults to 'linear'.
%
%   CLASS = CLASSIFY(SAMPLE,TRAINING,GROUP,TYPE,PRIOR) allows you to
%   specify prior probabilities for the groups in one of three ways.  PRIOR
%   can be a numeric vector of the same length as the number of unique
%   values in GROUP (or the number of levels defined for GROUP, if GROUP is
%   categorical).  If GROUP is numeric or categorical, the order of PRIOR
%   must correspond to the ordered values in GROUP, or, if GROUP contains
%   strings, to the order of first occurrence of the values in GROUP. PRIOR
%   can also be a 1-by-1 structure with fields 'prob', a numeric vector,
%   and 'group', of the same type as GROUP, and containing unique values
%   indicating which groups the elements of 'prob' correspond to. As a
%   structure, PRIOR may contain groups that do not appear in GROUP. This
%   can be useful if TRAINING is a subset of a larger training set.
%   CLASSIFY ignores any groups that appear in the structure but not in the
%   GROUPS array.  Finally, PRIOR can also be the string value 'empirical',
%   indicating that the group prior probabilities should be estimated from
%   the group relative frequencies in TRAINING.  PRIOR defaults to a
%   numeric vector of equal probabilities, i.e., a uniform distribution.
%   PRIOR is not used for discrimination by Mahalanobis distance, except
%   for error rate calculation.
%
%   [CLASS,ERR] = CLASSIFY(...) returns ERR, an estimate of the
%   misclassification error rate that is based on the training data.
%   CLASSIFY returns the apparent error rate, i.e., the percentage of
%   observations in the TRAINING that are misclassified, weighted by the
%   prior probabilities for the groups.
%
%   [CLASS,ERR,POSTERIOR] = CLASSIFY(...) returns POSTERIOR, a matrix
%   containing estimates of the posterior probabilities that the j'th
%   training group was the source of the i'th sample observation, i.e.
%   Pr{group j | obs i}.  POSTERIOR is not computed for Mahalanobis
%   discrimination.
%
%   [CLASS,ERR,POSTERIOR,LOGP] = CLASSIFY(...) returns LOGP, a vector
%   containing estimates of the logs of the unconditional predictive
%   probability density of the sample observations, p(obs i) is the sum of
%   p(obs i | group j)*Pr{group j} taken over all groups.  LOGP is not
%   computed for Mahalanobis discrimination.
%
%   [CLASS,ERR,POSTERIOR,LOGP,COEF] = CLASSIFY(...) returns COEF, a
%   structure array containing coefficients describing the boundary between
%   the regions separating each pair of groups.  Each element COEF(I,J)
%   contains information for comparing group I to group J, defined using
%   the following fields:
%       'type'      type of discriminant function, from TYPE input
%       'name1'     name of first group of pair (group I)
%       'name2'     name of second group of pair (group J)
%       'const'     constant term of boundary equation (K)
%       'linear'    coefficients of linear term of boundary equation (L)
%       'quadratic' coefficient matrix of quadratic terms (Q)
%
%   For the 'linear' and 'diaglinear' types, the 'quadratic' field is
%   absent, and a row x from the SAMPLE array is classified into group I
%   rather than group J if
%         0 < K + x*L
%   For the other types, x is classified into group I if
%         0 < K + x*L + x*Q*x'
%
%   Example:
%      % Classify Fisher iris data using quadratic discriminant function
%      load fisheriris
%      x = meas(51:end,1:2);  % for illustrations use 2 species, 2 columns
%      y = species(51:end);
%      [c,err,post,logl,str] = classify(x,x,y,'quadratic');
%      gscatter(x(:,1),x(:,2),y,'rb','v^')
%
%      % Classify a grid of values
%      [X,Y] = meshgrid(linspace(4.3,7.9), linspace(2,4.4));
%      X = X(:); Y = Y(:);
%      C = classify([X Y],x,y,'quadratic');
%      hold on; gscatter(X,Y,C,'rb','.',1,'off'); hold off
%
%      % Draw boundary between two regions
%      hold on
%      K = str(1,2).const;
%      L = str(1,2).linear;
%      Q = str(1,2).quadratic;
%      f = sprintf('0 = %g + %g*x + %g*y + %g*x^2 + %g*x.*y + %g*y.^2', ...
%                  K,L,Q(1,1),Q(1,2)+Q(2,1),Q(2,2));
%      ezplot(f,[4 8 2 4.5]);
%      hold off
%      title('Classification of Fisher iris data')
%
%   See also TREEFIT.

%   Copyright 1993-2006 The MathWorks, Inc. 
%   $Revision: 2.15.4.6 $  $Date: 2006/11/11 22:55:00 $

%   References:
%     [1] Krzanowski, W.J., Principles of Multivariate Analysis,
%         Oxford University Press, Oxford, 1988.
%     [2] Seber, G.A.F., Multivariate Observations, Wiley, New York, 1984.

if nargin < 3
    error('stats:classify:TooFewInputs','Requires at least three arguments.');
end

% grp2idx sorts a numeric grouping var ascending, and a string grouping
% var by order of first occurrence
[gindex,groups] = grp2idx(group);
nans = find(isnan(gindex));
if length(nans) > 0
    training(nans,:) = [];
    gindex(nans) = [];
end
ngroups = length(groups);
gsize = hist(gindex,1:ngroups);
nonemptygroups = find(gsize>0);

[n,d] = size(training);
if size(gindex,1) ~= n
    error('stats:classify:InputSizeMismatch',...
          'The length of GROUP must equal the number of rows in TRAINING.');
elseif isempty(sample)
    sample = zeros(0,d,class(sample));  % accept any empty array but force correct size
elseif size(sample,2) ~= d
    error('stats:classify:InputSizeMismatch',...
          'SAMPLE and TRAINING must have the same number of columns.');
end
m = size(sample,1);

if nargin < 4 || isempty(type)
    type = 'linear';
elseif ischar(type)
    types = {'linear','quadratic','diaglinear','diagquadratic','mahalanobis'};
    i = strmatch(lower(type), types);
    if length(i) > 1
        error('stats:classify:BadType','Ambiguous value for TYPE:  %s.', type);
    elseif isempty(i)
        error('stats:classify:BadType','Unknown value for TYPE:  %s.', type);
    end
    type = types{i};
else
    error('stats:classify:BadType','TYPE must be a string.');
end

% Default to a uniform prior
if nargin < 5 || isempty(prior)
    %    prior = zeros(1,ngroups);
    %    prior(nonemptygroups) = ones(size(nonemptygroups)) / length(nonemptygroups);
    prior = ones(1, ngroups) / ngroups;

% Estimate prior from relative group sizes
elseif ischar(prior) && ~isempty(strmatch(lower(prior), 'empirical'))
    prior = gsize(:)' / sum(gsize);
% Explicit prior
elseif isnumeric(prior)
    if min(size(prior)) ~= 1 || max(size(prior)) ~= ngroups
        error('stats:classify:InputSizeMismatch',...
              'PRIOR must be a vector one element for each group.');
    elseif any(prior < 0)
        error('stats:classify:BadPrior',...
              'PRIOR cannot contain negative values.');
    end
    prior = prior(:)' / sum(prior); % force a normalized row vector
elseif isstruct(prior)
    [pgindex,pgroups] = grp2idx(prior.group);
    ord = repmat(NaN,1,ngroups);
    for i = 1:ngroups
        j = strmatch(groups(i), pgroups(pgindex), 'exact');
        if ~isempty(j)
            ord(i) = j;
        end
    end
    if any(isnan(ord))
        error('stats:classify:BadPrior',...
        'PRIOR.group must contain all of the unique values in GROUP.');
    end
    prior = prior.prob(ord);
    if any(prior < 0)
        error('stats:classify:BadPrior',...
              'PRIOR.prob cannot contain negative values.');
    end
    prior = prior(:)' / sum(prior); % force a normalized row vector
else
    error('stats:classify:BadType',...
        'PRIOR must be a a vector, a structure, or the string ''empirical''.');
end

% Add training data to sample for error rate estimation
if nargout > 1
    sample = [sample; training];
    mm = m+n;
else
    mm = m;
end

gmeans = NaN(ngroups, d);
for k = nonemptygroups
    gmeans(k,:) = mean(training(gindex==k,:),1);
end

D = repmat(NaN, mm, ngroups);
isquadratic = false;
switch type
case 'linear'
    if n <= ngroups
        error('stats:classify:BadTraining',...
              'TRAINING must have more observations than the number of groups.');
    end
    % Pooled estimate of covariance.  Do not do pivoting, so that A can be
    % computed without unpermuting.  Instead use SVD to find rank of R.
    [Q,R] = qr(training - gmeans(gindex,:), 0);
    R = R / sqrt(n - ngroups); % SigmaHat = R'*R
    s = svd(R);
    if any(s <= max(n,d) * eps(max(s)))
        error('stats:classify:BadVariance',...
              'The pooled covariance matrix of TRAINING must be positive definite.');
    end
    logDetSigma = 2*sum(log(s)); % avoid over/underflow

    % MVN relative log posterior density, by group, for each sample
    for k = nonemptygroups
        A = (sample - repmat(gmeans(k,:), mm, 1)) / R;
        D(:,k) = log(prior(k)) - .5*(sum(A .* A, 2) + logDetSigma);
    end

case 'diaglinear'
    if n <= ngroups
        error('stats:classify:BadTraining',...
              'TRAINING must have more observations than the number of groups.');
    end
    % Pooled estimate of variance: SigmaHat = diag(S.^2)
    S = std(training - gmeans(gindex,:)) * sqrt((n-1)./(n-ngroups));
    R = diag(S);
    if any(S <= n * eps(max(S)))
        error('stats:classify:BadVariance',...
              'The pooled variances of TRAINING must be positive.');
    end
    logDetSigma = 2*sum(log(S)); % avoid over/underflow

    % MVN relative log posterior density, by group, for each sample
    for k = nonemptygroups
        A = (sample - repmat(gmeans(k,:), mm, 1))./repmat(S,mm,1);
        D(:,k) = log(prior(k)) - .5*(sum(A .* A, 2) + logDetSigma);
    end

case {'quadratic' 'mahalanobis'}
    if any(gsize == 1)
        error('stats:classify:BadTraining',...
              'Each group in TRAINING must have at least two observations.');
    end
    isquadratic = true;
    logDetSigma = zeros(ngroups,1,class(training));
    R = zeros(d,d,ngroups,class(training));
    for k = nonemptygroups
        % Stratified estimate of covariance.  Do not do pivoting, so that A
        % can be computed without unpermuting.  Instead use SVD to find rank
        % of R.
        [Q,Rk] = qr(training(gindex==k,:) - repmat(gmeans(k,:), gsize(k), 1), 0);
        Rk = Rk / sqrt(gsize(k) - 1); % SigmaHat = R'*R
        s = svd(Rk);
        if any(s <= max(gsize(k),d) * eps(max(s)))
            error('stats:classify:BadVariance',...
                  'The covariance matrix of each group in TRAINING must be positive definite.');
        end
        logDetSigma(k) = 2*sum(log(s)); % avoid over/underflow

        A = (sample - repmat(gmeans(k,:), mm, 1)) / Rk;
        switch type
        case 'quadratic'
            % MVN relative log posterior density, by group, for each sample
            D(:,k) = log(prior(k)) - .5*(sum(A .* A, 2) + logDetSigma(k));
        case 'mahalanobis'
            % Negative squared Mahalanobis distance, by group, for each
            % sample.  Prior probabilities are not used
            D(:,k) = -sum(A .* A, 2);
        end
        if ~isempty(Rk) %???
            R(:,:,k) = inv(Rk);
        end
    end
    
case 'diagquadratic'
    if any(gsize <= 1)
        error('stats:classify:BadTraining',...
              'Each group in TRAINING must have at least two observations.');
    end
    isquadratic = true;
    logDetSigma = zeros(ngroups,1,class(training));
    R = zeros(d,d,ngroups,class(training));
    for k = nonemptygroups
        % Stratified estimate of variance:  SigmaHat = diag(S.^2)
        S = std(training(gindex==k,:));
        if any(S <= gsize(k) * eps(max(S)))
            error('stats:classify:BadVariance',...
                  'The variances in each group of TRAINING must be positive.');
        end
        logDetSigma(k) = 2*sum(log(S)); % avoid over/underflow
        
        % MVN relative log posterior density, by group, for each sample
        A = (sample - repmat(gmeans(k,:), mm, 1)) ./ repmat(S,mm,1);
        D(:,k) = log(prior(k)) - .5*(sum(A .* A, 2) + logDetSigma(k));
        R(:,:,k) = diag(1./S);
    end
end

% find nearest group to each observation in sample data
[maxD,outclass] = max(D, [], 2);

% Compute apparent error rate: percentage of training data that
% are misclassified, weighted by the prior probabilities for the groups.
if nargout > 1
    trclass = outclass(m+(1:n));
    outclass = outclass(1:m);
    
    miss = trclass ~= gindex;
    e = repmat(NaN,ngroups,1);
    for k = nonemptygroups
        e(k) = sum(miss(gindex==k)) / gsize(k);
    end
    err = prior*e;
end

if nargout > 2
    if strcmp(type, 'mahalanobis')
        % Mahalanobis discrimination does not use the densities, so it's
        % possible that the posterior probs could disagree with the
        % classification.
        posterior = [];
        logp = [];
    else
        % Bayes' rule: first compute p{x,G_j} = p{x|G_j}Pr{G_j} ...
        % (scaled by max(p{x,G_j}) to avoid over/underflow)
        P = exp(D(1:m,:) - repmat(maxD(1:m),1,ngroups));
        sumP = nansum(P,2);
        % ... then Pr{G_j|x) = p(x,G_j} / sum(p(x,G_j}) ...
        % (numer and denom are both scaled, so it cancels out)
        posterior = P ./ repmat(sumP,1,ngroups);
        if nargout > 3
            % ... and unconditional p(x) = sum(p(x,G_j}).
            % (remove the scale factor)
            logp = log(sumP) + maxD(1:m) - .5*d*log(2*pi);
        end
    end
end

% Convert back to original grouping variable type
if isa(group,'categorical')
   labels = getlabels(group);
   if isa(group,'nominal')
       groups = nominal(groups,[],labels);
   else
       groups = ordinal(groups,[],getlabels(group));
   end
elseif isnumeric(group)
   groups = str2num(char(groups));
   groups=cast(groups,class(group)); 
elseif islogical(group)
   groups = logical(str2num(char(groups)));
elseif ischar(group)
   groups = char(groups);
%else may be iscellstr
end
if isvector(groups)
    groups = groups(:);
end
outclass = groups(outclass,:);

if nargout>=5
    pairs = combnk(nonemptygroups,2)';
    npairs = size(pairs,2);
    K = zeros(1,npairs,class(training));
    L = zeros(d,npairs,class(training));
    if ~isquadratic
        % Methods with equal covariances across groups
        for j=1:npairs
            % Compute const (K) and linear (L) coefficients for
            % discriminating between each pair of groups
            i1 = pairs(1,j);
            i2 = pairs(2,j);
            mu1 = gmeans(i1,:)';
            mu2 = gmeans(i2,:)';
            b = R \ ((R') \ (mu1 - mu2));
            L(:,j) = b;
            K(j) = 0.5 * (mu1 + mu2)' * b;
        end
    else
        % Methods with separate covariances for each group
        Q = zeros(d,d,npairs,class(training));
        for j=1:npairs
            % As above, but compute quadratic (Q) coefficients as well
            i1 = pairs(1,j);
            i2 = pairs(2,j);
            mu1 = gmeans(i1,:)';
            mu2 = gmeans(i2,:)';
            R1i = R(:,:,i1);    % note here the R array contains inverses
            R2i = R(:,:,i2);
            Rm1 = R1i' * mu1;
            Rm2 = R2i' * mu2;
            K(j) = 0.5 * (sum(Rm1.^2) - sum(Rm2.^2));
            if ~strcmp(type, 'mahalanobis')
                K(j) = K(j) + 0.5 * (logDetSigma(i1)-logDetSigma(i2));
            end
            L(:,j) = (R1i*Rm1 - R2i*Rm2);
            Q(:,:,j) = -0.5 * (R1i*R1i' - R2i*R2i');
        end
    end
    
    % For all except Mahalanobis, adjust for the priors
    if ~strcmp(type, 'mahalanobis')
        K = K - log(prior(pairs(1,:))) + log(prior(pairs(2,:)));
    end
    
    % Return information as a structure
    coeffs = struct('type',repmat({type},ngroups,ngroups));
    for k=1:npairs
        i = pairs(1,k);
        j = pairs(2,k);
        coeffs(i,j).name1 = groups(i,:);
        coeffs(i,j).name2 = groups(j,:);
        coeffs(i,j).const = -K(k);
        coeffs(i,j).linear = L(:,k);

        coeffs(j,i).name1 = groups(j,:);
        coeffs(j,k).name2 = groups(i,:);
        coeffs(j,i).const = K(k);
        coeffs(j,i).linear = -L(:,k);

        if isquadratic
            coeffs(i,j).quadratic = Q(:,:,k);
            coeffs(j,i).quadratic = -Q(:,:,k);
        end
    end
end
    
