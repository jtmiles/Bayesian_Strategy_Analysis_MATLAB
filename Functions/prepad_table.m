function pad_tab = prepad_table(behav_table,npad)
%%%%
% loads in (Mizumori lab "behav") table, pads table with npad trials of
% random data. Helps smooth out the first few trials of the strategy
% likelihood analysis, which tend to be pretty dramatic for about 10 trials
% since the algorithm requires an accumulation of trials to stabilize its
% estimation of a prior
%%%%

    % to keep data's structure, just permute indices from the table itself
    t_ixs = randsample(height(behav_table),npad,true);
    pad_tab = [behav_table(t_ixs,:);behav_table];
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS DOES NOT NEED TO BE A FUNCTION
% JUST ADD IT AS AN OPTION IN CONVERT_MIZUMORI_DATA
% MAYBE THROW IN A VARARGIN FLAG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%