function Output = multiple_allocentric_analysis(converted_data, varargin)

% function to demonstrate Bayesian strategy analysis of multiple strategies
% - specify strategues in string array
% - using data from one example rat from Peyrache Y-maze data-set
%
% Stores results in dynamically-created struct; users may want to recast as
% Tables to save data
%
% Initial version 3/4/2022
% Mark Humphries 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% JTM updated file to handle allocentric Mizumori lab data, 2022-09-21
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% JTM updates, 2023-07-19
%
% made into function
%
% added varargin options:
%%%% 1: a string array of strategy types. if not supplied, chooses
%%%%    several already in the script
%%%% 2: an integer that specifies number of trials to prepend to 
%%%%    data to help smooth the initial likelihood estimates in the 
%%%%    session if a second argument isn't give, no trials will be added

addpath Strategy_models\ % must add this path to access strategy models
addpath Functions\       % must add this path to access analysis functions

% check for varargin
if length(varargin) == 1 

    if isstring(varargin{1})
        strategies = varargin{1};
    else
        npad = varargin{1};
    end % if isstring...

elseif length(varargin) == 2

    if isstring(varargin{1})
        strategies = varargin{1};
        npad = varargin{2};
    elseif isstring(varargin{2})
        strategies = varargin{2};
        npad = varargin{1};
    end % if isstring... 

end % if length...

if exist('strategies','var')==0 % haven't declared the variable
    strategies = ["go_east", "go_west", "alternate_allo",...
                  "lose_shift_spatial_allo", "win_stay_spatial_allo"];
end

if exist('npad','var')==0 || ~isnumeric(npad)
    npad = 0;
end

% add npad rows to converted_data to help smooth out initial strategy
% likelihood estimates
if npad>0
    t_ixs = randsample(height(converted_data),npad,true);
    converted_data = [converted_data(t_ixs,:);converted_data];
end

%% choose type of prior
prior_type = "Uniform";

%% set decay rate: gamma parameter
decay_rate = 0.90;

%% define priors
[alpha0,beta0] = set_Beta_prior(prior_type);

%% main loop: for each trial, update strategy probability estimates
number_of_trials = numel(converted_data.TrialIndex);
number_of_strategies = numel(strategies);

% create storage, using dynamic field names in struct
% struct Output will have a field per strategy
for index_strategy = 1:number_of_strategies
    charStrategy = char(strategies(index_strategy)); % cast as Char for old MATLAB < 2018
    Output.(charStrategy).alpha = zeros(number_of_trials,1);
    Output.(charStrategy).beta = zeros(number_of_trials,1);
    Output.(charStrategy).MAPprobability = zeros(number_of_trials,1);
    Output.(charStrategy).precision = zeros(number_of_trials,1);
    Output.(charStrategy).success_total = 0;
    Output.(charStrategy).failure_total = 0;
end

% loop over trials and update each
for index_trial = 1:number_of_trials
    for index_strategy = 1:number_of_strategies
        charStrategy = char(strategies(index_strategy)); % cast as Char for old MATLAB < 2018

        % test current strategy model
        trial_type = evaluate_strategy(strategies(index_strategy),converted_data(1:index_trial,:));

        % update its alpha, beta  
        [Output.(charStrategy).alpha(index_trial),Output.(charStrategy).beta(index_trial),Output.(charStrategy).success_total,Output.(charStrategy).failure_total] = ...
               update_strategy_posterior_probability(trial_type,decay_rate,Output.(charStrategy).success_total,Output.(charStrategy).failure_total,alpha0,beta0);
        
        % compute current MAP probability and precision    
        Output.(charStrategy).MAPprobability(index_trial) = Summaries_of_Beta_distribution(Output.(charStrategy).alpha(index_trial),Output.(charStrategy).beta(index_trial),'MAP');
        Output.(charStrategy).precision(index_trial) = Summaries_of_Beta_distribution(Output.(charStrategy).alpha(index_trial),Output.(charStrategy).beta(index_trial),'Precision');
    end % for index_strategy ...
end % for index_trial ...

end % function