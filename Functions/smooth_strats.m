function strats_table = smooth_strats(strats_table,pwin,gwin)
%%%%
% pre-pad strategy likelihood curves and smooth with a gaussian window
% 
% INPUTS:
% strats_table = table containing strategy likelihood estimates. can also
% have "ID" & "trial" columns, as in Demonstrate_Multiple_Allocentric_Mizumori
% script, which this function is intended to process.
%
% pwin = integer number of trials to pre-pend to curves so that smoothing
% will temper the initial behavior of the likelihood estimates, which tend
% to be pretty noisy
%
% gwin = integer number of trials to use for gaussian window (implemented
% with MATLAB's "smoothdata" function)
%
% OUTPUTS:
% Table with same strategy columns as input table, but padded and smoothed.
% If your input table had "ID" and/or "trial" columns, they get dropped!
%
% NOTES:
% Table can have as many strategy columns as you want, but since this
% function just loops over variable names in the table, don't include 
% extra columns that aren't named "ID" and/or "trial"! The program is
% already designed to skip these, but not others.
%
% Prepended values are randomly drawn from a [0.4, 0.6] uniform distribution
%%%%
    pad = 0.4+rand(pwin,1)*0.2;
    for strat = strats_table.Properties.VariableNames
        if strat == "ID" || strat=="trial"
            continue
        end
        s_strat = smoothdata([pad;strats_table(:,strat).Variables],1,'gaussian',gwin,'omitnan');
        strats_table(:,strat) = table(s_strat(pwin+1:end),'VariableNames',strat);
    end
end