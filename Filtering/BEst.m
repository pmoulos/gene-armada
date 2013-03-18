function Fc = BEst(F, B, varargin)
%{
Calculation of various background estimation and correction methods for
two-channel microarray data. Among the typical choices, this function implements
(i) the Percentiles-based Background Correction, and (ii) the
oess-based Background Correction methods proposed by Sifakis et al., 2012,
along with the (iii) Multiplicative Background Correction proposed by Zhang et al., 2006).

Fc = BEst(F,B, method) utilizes the background signal B to background correct
the foregound signal F using the specified method.
The available methods are:
                                  'NBC':  No Background Correction (default)
                                  'LBS':   Local Background Subtraction
                                  'MBC': Multiplicative Background Correction
                                  'PBC':  Percentiles-based Background Correction
                                             (with the default step=0.1)
                                  'LSBC': Loess-based Background Correction
                                             (with the default span=0.2 and lsmethod='loess' )

Fc = BEst(F,B, 'PBC', step) additionally specifies the user-defined step parameter
to be used in the PBC method. The step value determines the percentiles that'll split
B distribution into equal segments. The step value is a scalar less than or equal to 1
(e.g. Fc = BEst(F,B, 'PBC', 0.1) calculates the percentiles every 10% of the B distribution data).

Fc = BEst(F,B, 'LSBC', span, lsmethod) additionally specifies (i) the span parameter, and
(ii) the lo(w)ess smoothing method in the LSBC method. The span value determines the
smoothing window, while the lsmethod parameter determines the smoothing
method applied to the scatter-plot, in which the predictor variable is F
and the response variable is B. The span value is a scalar less than or
equal to 1. The available choices for the lsmethod parameter are:
          'lowess':   Lowess (linear fit)
          'loess':     Loess (quadratic fit)
          'rlowess': Robust Lowess (linear fit)
          'rloess':    Robust Loess (quadratic fit)
(e.g. Fc = BEst(F,B, 'LSBC', 0.2, 'rloess') smoothes B distribution data
using a 20% span and a robust quadratic fit).
%}

%{
Author: Sifakis G. Emmanouil (sifakise@biomed.ntua.gr)
Date created: 29/07/2010
Date modified: 12/11/2012
MATLAB 2009b

References:
[1] Sifakis EG, Prentza A, Koutsouris D, Chatziioannou AA, "Evaluating the effect
of various background correction methods regarding noise reduction,
in two-channel microarray data", Computers in Biology and Medicine,
2012 Jan;42(1):19-29.

[2] D. Zhang, M. Zhang, M.T. Wells, Multiplicative background correction
for spotted microarrays to improve reproducibility, Genetical Research,
2006 Jun; 87(3):195–206.
%}

% Check if the number of input arguments is ok
if nargin < 2
    error('BEst.m: Function needs more arguments. See help.');
end

% Check if method is given, else use default method
method = 'NBC'; % Default value
if nargin > 2
    if ischar(varargin{1})
        method = varargin{1};
    else
        error('BEst.m: Method argument should be a string');
    end
end


switch method
    
    case 'NBC' % No Background Correction

        Fc = F;

% -------------------------------------------------------------------------

    case 'LBS' % Local Background Correction

        % Substract local background estimation
        Fc = F - B;
  
% -------------------------------------------------------------------------

    case 'MBC' % Multiplicative Background Correction
    
        % Take the logarithms base 2 of foreground & background signals
        F = log2(F);
        B = log2(B);

        % Substract background estimation (actually is division since logarithms are taken)
        Fc = F - B;
        
        % Take the inverse logarithms base 2 of foreground & background signals
        Fc = 2.^Fc;
        
% -------------------------------------------------------------------------
              
    case 'PBC' % Percentiles-based Background Correction

        % Default values
        step = 0.1;

        % Check if step parameter is ok
        if nargin > 3
            if isnumeric(varargin{2})
                step = varargin{2};
                    if step > 1
                        error('BEst.m: PBC''s step parameter argument should be within the range (0 1)');
                    end
            else
                error('BEst.m: PBC''s step parameter argument should be numeric');
            end
        end
        
    
       % Take the logarithms base 2 of foreground & background signals
        F = log2(F);
        B = log2(B);
        
        % Compute percentiles with step (%)
        Ps = prctile(B,(0:100*step:100));


        % For the first interval: (in order to include the first value (Ps(1)=min(B)) )
        j = 1;

        % Find indices of the first interval only of background signal 
        ifirst_ind = find( B >= Ps(j) & B <= Ps(j+1) );

        % Compute the mean for the first interval
        ifirst_Bmean = mean(B(ifirst_ind,:));

        % Substract background estimation of the first interval (actually is division since logarithms are taken)
        Fc(ifirst_ind,:) = F(ifirst_ind,:) - ifirst_Bmean;

        
        % Repeat the same procedure for the rest intervals:
        for j = 2:(1/step)

            % Find indices of the rest intervals of background signal
            i_ind = find( B > Ps(j) & B <= Ps(j+1) );

            % Compute the mean for each of the intervals
            i_ind_Bmean = mean(B(i_ind,:));

            % Substract background estimation per interval (actuall is division since logarithms are taken)
            Fc(i_ind,:) = F(i_ind,:) - i_ind_Bmean;

        end
        
       % Take the inverse logarithms base 2 of foreground & background signals
        Fc = 2.^Fc;

% -------------------------------------------------------------------------

     case 'LSBC' % Loess-based Background Correction
         
            % Default values
            span = 0.2;
            lsmethod = 'loess';
            
            % Check if span parameters is ok
            if nargin > 3
                if isnumeric(varargin{2})
                    span = varargin{2};
                    if span > 1
                        error('BEst.m: LSBC''s span parameter argument should be within the range (0 1)');
                    end
                else
                    error('BEst.m: LSBC''s span parameter argument should be numeric');
                end
                
                % Check if lsmethod parameters is ok
                 if ischar(varargin{3})
                     lsmethod = varargin{3};
                     if ~strcmp(lsmethod,'lowess') && ~strcmp(lsmethod,'loess') && ~strcmp(lsmethod,'rlowess') && ~strcmp(lsmethod,'rloess')
                        error('BEst.m: LSBC''s lsmethod parameter argument should be a valid method argument. See help.');
                    end
                else
                    error('BEst.m: LSBC''s lsmethod parameter argument should be a string');
                 end
                          
            end
        
            
            % Take the logarithms base 2 of foreground & background signals
            F = log2(F);
            B = log2(B);
                   
            % Smooth log2(Background) using lo(w)ess method
            Bsmooth = smooth(F,B, span, lsmethod);

            % Substract background estimation 
            Fc = F - Bsmooth;

            % Take the inverse logarithms base 2 of foreground & background signals
            Fc = 2.^Fc;

% -------------------------------------------------------------------------
            
    otherwise
        
        error('The %s parameter value must be a valid method argument. See help.',method)
        return;
 
end

end
