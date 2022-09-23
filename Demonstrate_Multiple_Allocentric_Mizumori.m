% script to demonstrate Bayesian strategy analysis of multiple strategies
% - specify strategues in string array
% - using data from one example rat from Peyrache Y-maze data-set
%
% Stores results in dynamically-created struct; users may want to recast as
% Tables to save data
%
% Initial version 3/4/2022
% Mark Humphries 
%
% Updated file that handles Mizumori lab data
% Jesse Miles Sept. 21, 2022

addpath Strategy_models\        % must add this path to access strategy models
addpath Functions\              % must add this path to access functions that implement analysis
clearvars; close all;

% load data into a Table - strategy models will use variable names stored with Table to
% access each column's data
[bfile, floc] = uigetfile('*strat_table.csv', 'Pick *behav.txt file');
testData = readtable([floc, bfile],'TextType','string');

%% choose strategies to evaluate
% list of function names in Strategy_models/ folder - runs all of them to
% check they work...
strategies = ["go_east", "go_west", "alternate_allo",...
              "lose_shift_spatial_allo", "win_stay_spatial_allo"];

%% choose type of prior
prior_type = "Uniform";

%% set decay rate: gamma parameter
decay_rate = 0.90;

%% define priors
[alpha0,beta0] = set_Beta_prior(prior_type);

%% main loop: for each trial, update strategy probability estimates
number_of_trials = numel(testData.TrialIndex);
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
        trial_type = evaluate_strategy(strategies(index_strategy),testData(1:index_trial,:));

        % update its alpha, beta  
        [Output.(charStrategy).alpha(index_trial),Output.(charStrategy).beta(index_trial),Output.(charStrategy).success_total,Output.(charStrategy).failure_total] = ...
               update_strategy_posterior_probability(trial_type,decay_rate,Output.(charStrategy).success_total,Output.(charStrategy).failure_total,alpha0,beta0);
        
        % compute current MAP probability and precision    
        Output.(charStrategy).MAPprobability(index_trial) = Summaries_of_Beta_distribution(Output.(charStrategy).alpha(index_trial),Output.(charStrategy).beta(index_trial),'MAP');
        Output.(charStrategy).precision(index_trial) = Summaries_of_Beta_distribution(Output.(charStrategy).alpha(index_trial),Output.(charStrategy).beta(index_trial),'Precision');
    end  
end

%% plot time-series of MAP probability estimates and precision

new_session_trials = find(testData.NewSessionTrials);
rule_change_trials = find(testData.RuleChangeTrials);
sequence_of_rules = [testData.TargetRule(1); testData.TargetRule(rule_change_trials)];


% rule strategies
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 20 9]);
hold on;
% plot(Output.go_left.MAPprobability,'Color',[0.4 0.4 0.8]);
plot(Output.go_east.MAPprobability,'Color',[0.8 0.6 0.5]);
% plot(Output.go_right.MAPprobability,'Color',[0.4 0.8 0.5]);
plot(Output.go_west.MAPprobability,'Color',[0.1 0.4 0.9]);
plot(Output.alternate_allo.MAPprobability,'Color',[0.2 0.2 0.2]);
plotSessionStructure(gca,number_of_trials,new_session_trials,rule_change_trials,sequence_of_rules)
% line([1,number_of_trials],[0.5 0.5],'Color',[0.7 0.7 0.7]) % chance
xlabel('Trials'); ylabel('P(strategy)')
% strLabel = {'go left','go east','go right','go west','alternate'};
strLabel = {'go east','go west','alternate'};
legend(strLabel,'Location','northeastoutside','Box','off')
hold off

%% explore strategies...
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 20 9]);
hold on
plot(Output.win_stay_spatial_allo.MAPprobability,'o','Color',[0.4 0.8 0.5]); 
plot(Output.lose_shift_spatial_allo.MAPprobability,'o','Color',[0.8 0.6 0.5]);
plotSessionStructure(gca,number_of_trials,new_session_trials,rule_change_trials,sequence_of_rules);
% line([1,number_of_trials],[0.5 0.5],'Color',[0.7 0.7 0.7]) % chance
xlabel('Trials'); ylabel('P(strategy)')
strLabel = {'win-stay-spatial','lose-shift-spatial'};
legend(strLabel,'Location','northeastoutside','Box','off')
hold off