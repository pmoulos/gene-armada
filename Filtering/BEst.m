% Function for Background Estimation (BEst)
%
% Author: Sifakis G. Emmanouil
% Date: 29/07/2010
% MATLAB 2009b
%
% Comments: - INPUTS:
%                                       F = foreground signal
%                                       B = background signal
%                                       method = choice of estimating B
%                                             {
%                                               method = 'NBC': NO Background Correction
%                                               method = 'LBS': Local Background Subtraction
%                                               method = 'MBC': Multiplicative Background Correction
%                                               method = '3Qs': based on the 3 quartiles
%                                               method = '9Ds': based on the 9 deciles
%                                               method = 'LsBC': based on Loess (quadratic, non-robust, f=20%) 
%                                               method = 'RLsBC': based on Robust Loess (quadratic, robust, f=20%) 
%                                             }
%
%                       - OUTPUT: Fc = corrected foreground signal


function Fc = BEst(F, B, method)


switch method
    
    case 'NBC' % NO Background Correction

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
              
    case '3QBC' % Method based on the 3 quartiles
        
         step = 25;

        % Take the logarithms base 2 of foreground & background signals
        F = log2(F);
        B = log2(B);
        
        % Compute percentiles with step (%)
        Ps = prctile(B,(0:step:100));


        % For the first interval: (in order to include the first value (Ps(1)=min(B)) )
        j = 1;

        % Find indices of the first interval only of background signal 
        ifirst_ind = find( B >= Ps(j) & B <= Ps(j+1) );

        % Compute the mean for the first interval
        ifirst_Bmean = mean(B(ifirst_ind,:));

        % Substract background estimation of the first interval (actually is division since logarithms are taken)
        Fc(ifirst_ind,:) = F(ifirst_ind,:) - ifirst_Bmean;

        
        % Repeat the same procedure for the rest intervals:
        for j = 2:(100/step)

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
                    
    case '9DBC' % Method based on the 9 deciles
        
        step = 10;
        
        % Take the logarithms base 2 of foreground & background signals
        F = log2(F);
        B = log2(B);
        
        % Compute percentiles with step (%)
        Ps = prctile(B,(0:step:100));


        % For the first interval: (in order to include the first value (Ps(1)=min(B)) )
        j = 1;

        % Find indices of the first interval only of background signal 
        ifirst_ind = find( B >= Ps(j) & B <= Ps(j+1) );

        % Compute the mean for the first interval
        ifirst_Bmean = mean(B(ifirst_ind,:));

        % Substract background estimation of the first interval (actually is division since logarithms are taken)
        Fc(ifirst_ind,:) = F(ifirst_ind,:) - ifirst_Bmean;

        
        % Repeat the same procedure for the rest intervals:
        for j = 2:(100/step)

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

     case 'LsBC' % Method based on Loess
         
            % Take the logarithms base 2 of foreground & background signals
            F = log2(F);
            B = log2(B);
                   
            % Smooth log2(Background) using lo(w)ess method
            Bsmooth = smooth(F,B, 0.2, 'loess');

            % Substract background estimation 
            Fc = F - Bsmooth;
            
%             % Plot Background vs. Foreground + the lo(w)ess curve fit
%             figure;
%             scatter(F, B,'.')
%             hold on
%             scatter(F, Bsmooth,'r','+')      
%             xlabel('log2 (foreground)');
%             ylabel('log2 (background)');
%             title('Background vs. Foreground + the lo(w)ess curve fit');

            % Take the inverse logarithms base 2 of foreground & background signals
            Fc = 2.^Fc;

% -------------------------------------------------------------------------

     case 'rLsBC' % Method based on Robust Loess
         
            % Take the logarithms base 2 of foreground & background signals
            F = log2(F);
            B = log2(B);
                   
            % Smooth log2(Background) using robust lo(w)ess method
            Bsmooth = smooth(F,B, 0.2, 'rloess');
            
            % Substract background estimation 
            Fc = F - Bsmooth;
            
%             % Plot Background vs. Foreground + the lo(w)ess curve fit
%             figure;
%             scatter(F, B,'.')
%             hold on
%             scatter(F, Bsmooth,'r','+')      
%             xlabel('log2 (foreground)');
%             ylabel('log2 (background)');
%             title('Background vs. Foreground + the lo(w)ess curve fit');

            % Take the inverse logarithms base 2 of foreground & background signals
            Fc = 2.^Fc;

% -------------------------------------------------------------------------
            
    otherwise
        
      disp('Unknown method!')
      return;
      
      
end



