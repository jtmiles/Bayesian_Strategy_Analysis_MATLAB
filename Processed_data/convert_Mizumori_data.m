%% Convert to Maggi et al. format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load in *behav.txt of Mizumori lab strategy switching data and convert it
% to format that can be analyzed by Maggi et al. 2022 for trial-by-trial 
% analysis of strategy usage
%
%%%% Current format (columns, unlabeled in .txt file):
% trial - double, increments each trial
% block - double >=1.0 and <= 4.0
% block_trial - double, number of trials in the current contingency
% correct_arm - double, = 0 (West) or 2(East), arm that would be rewarded
% outcome - double, = 1 if correct arm was chosen, else 0 
% start_arm - double, = 1 (North) or 3 (South)
% chosen_arm - double, = 0 (West) or 2 (East), arm rat chose
% delay - double, duration of delay (in ms)
%
%%%% Needs to be:
% TrialIndex - integer that just counts up for a given table
% SessionIndex - integer that identifies session
% TargetRule - string specifying current contingency
% Choice - 'left' or 'right' (may change to East or West')
% CuePosition - ... no cues in our data, so just nans
% Reward - 'yes' or 'no'
% RuleChangeTrials - 1 if contingency changes on that trial, else 0
% NewSessionTrials - 1 when SessionIndex increments, else 0
%
%%%% Additions:
% This file adds an additional column, Location, to the original format
% The Location column contains strings "West" or "East" that correspond to
% the chosen_arm, which can be read by the "go_east" and "go_west" strategy
% models in the same way "go_left" and "go_right" are interpreted from the
% "Choice" column
%
% JTM - 2022-09-21
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath Processed_data\ 
clearvars
       % must add this path to access data processing
[bfile, floc] = uigetfile('behav.txt', 'Pick *behav.txt file');
beh_data = readtable([floc,bfile]); 
bcols = {'trial','block','block_trial','correct_arm','outcome',...
         'start_arm','chosen_arm','delay'};
beh_data.Properties.VariableNames = bcols;

%%
save_data = table();
save_data.TrialIndex = string(beh_data.trial);
% save_data.SessionIndex = nan(numel(beh_data.trial),1);
% create TargetRule vector
% possible options are - East, West, Alternate
TargetRule = strings(numel(beh_data.trial),1);
for b = 1:max(beh_data.block)
    b_ts = beh_data.block == b;
    b_cs = beh_data.correct_arm(b_ts);

    if all(b_cs == 0)
        TargetRule(b_ts) = "West";
    elseif all(b_cs == 2)
        TargetRule(b_ts) = "East";
    else
        TargetRule(b_ts) = "Alternate";
    end %if
end %for
save_data.TargetRule = TargetRule;

% designate "left" vs. "right" choices
choice = strings(numel(beh_data.trial),1);
lefts = beh_data.start_arm-beh_data.chosen_arm~=1;
choice(lefts) = "left";
rights = beh_data.start_arm-beh_data.chosen_arm==1;
choice(rights) = "right";
save_data.Choice = choice;

% add column with location rat chose (East vs. West)
location = strings(numel(beh_data.trial),1);
location(beh_data.chosen_arm==0) = "West";
location(beh_data.chosen_arm==2) = "East";
save_data.Location = location;

% designate outcome as yes/no instead of 1/0, respectively
reward = strings(numel(beh_data.trial),1);
reward(beh_data.outcome==1) = "yes";
reward(beh_data.outcome==0) = "no";
save_data.Reward = reward;

% add some meta data
% designate when a rule/task contingency changes
% For Mizumori lab data, this is the beginning of a "block"
rulechanges = zeros(numel(beh_data.trial),1);
rulechanges(beh_data.block_trial==1) = 1;
save_data.RuleChangeTrials = string(rulechanges);

% add NewSessionTrials column
new_session = zeros(numel(beh_data.trial),1);
new_session(1) = 1;
save_data.NewSessionTrials = string(new_session);

% adding placeholder CuePosition nan column (no explicit cues in our data)
save_data.CuePosition = nan(numel(beh_data.trial),1);

%% parse filename, re-config into mm-dd-yyy_ID, save table as CSV

[~, d_end] = regexp(bfile, '((\d)-\d{4})');
date = datestr(bfile(1:(d_end)),'yyyy-mm-dd');
[~,str_end] = regexp(bfile, '([A-Z]{2}-[A-Za-z]{2,3}-)');
rat_ID = bfile(str_end+1:str_end+3);
if isempty(date)
    date = datestr(bfile(1:10),'yyyy-mm-dd');
end
save_str = [date,'_',rat_ID,'_','strat_table.csv']
cd('C:\Users\jesse\Documents\GitHub\Bayesian_Strategy_Analysis_MATLAB\Processed_data')
writetable(save_data,save_str)
% 