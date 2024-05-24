function converted_data = convert_behav_data(beh_data)
% Convert to Maggi et al. format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Convert data from ePrime set shifting task to format that can be analyzed
% by Maggi et al. 2022 for trial-by-trial analysis of strategy usage
%
%%%% Current format 
% CSV with a mess of columns for tracking meta-data
% using:
%%%%%%%% Trial - trial number
%%%%%%%% cResp - correct response
%%%%%%%% TestStimulus.RESP - participant's response
%%%%%%%% TestStimulus_ACC - whether response was correct (1 = yes; 2 = no)
%%%%%%%% Stimulus
%%%%%%%% MixedTrialList
%%%%%%%% Cue or AudioCue - the target cue to respond to
%
%%%% Needs to be:
% TrialIndex - integer that just counts up for a given table
% SessionIndex - integer that identifies session (*seem not to be using*)
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
% reformatted as function 2023-07-19
% branch for GEMs project (Webb/Rea) 2024-04-29
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% bcols = ["Trial";"cResp";"TestStimulus.RESP";"TestStimulus_ACC"];
varnames = beh_data.Properties.VariableNames;
if any(contains(varnames,"AudioCue"))
    % rename the old cue variable, which is not the target cue
    beh_data = renamevars(beh_data,"Cue","XcueX"); 
    beh_data = renamevars(beh_data,"AudioCue","Cue");
    % bcols = [bcols;"AudioCue"];
elseif any(contains(varnames,"Cue"))
    % WARNING - v2 files also contain "Cue", but it's a different variable!
    % bcols = [bcols;"Cue"];
else
    warning("Did not find a 'Cue' column with expected format")
end

converted_data = table();
% mixstart = find(~isnan(beh_data.MixedTrialList),1,"first");
endpract = contains(string(beh_data.Stimulus),"Prac","IgnoreCase",true);
tstart = find(endpract,1,"last")+1;
% converted_data.TrialIndex = string(1+beh_data.Trial-beh_data.Trial(mixstart));
% converted_data.TrialIndex(1:mixstart-1) = nan;
% TrialCount_Trial starts counting after the first couple of practices
converted_data.TrialIndex = beh_data.MixedTrialList(tstart:end);

% create TargetRule vector
% possible options are - 'color' or 'shape'
TargetRule = strings(height(beh_data),1);
TargetRule(contains(beh_data.Cue,"shape","IgnoreCase",true)) = "shape";
TargetRule(contains(beh_data.Cue,"color","IgnoreCase",true)) = "color";
converted_data.TargetRule = TargetRule(tstart:end);

% designate "left" vs. "right" choices
choice = strings(height(beh_data),1);
lefts = beh_data.TestStimulus_RESP==1;
choice(lefts) = "left";
rights = beh_data.TestStimulus_RESP==5;
choice(rights) = "right";
converted_data.Choice = choice(tstart:end);

% designate outcome as yes/no instead of 1/0, respectively
% (keeping variable name as "reward" for now)
accuracy = strings(height(beh_data),1);
accuracy(beh_data.TestStimulus_ACC==1) = "yes";
accuracy(beh_data.TestStimulus_ACC==0) = "no";
converted_data.Reward = accuracy(tstart:end);

% designate whether they chose shape
shape = strings(height(beh_data),1);
shape(contains(beh_data.Cue,"shape","IgnoreCase",true) & accuracy == "yes") = "yes";
% shapes and colors are always mismatched, so if they get a color trial
% wrong it's because they were choosing based on shape
shape(contains(beh_data.Cue,"color","IgnoreCase",true)  & accuracy == "no") = "yes";
shape(shape~="yes") = "no";
converted_data.Shape = shape(tstart:end);

% designate "A" vs. "B" for color
% (no indicator of actual color presented)
% TO DO:
% check if this is just the complement of shape ...
color = strings(height(beh_data),1);
color(contains(beh_data.Cue,"color","IgnoreCase",true)  & accuracy == "yes") = "yes";
color(contains(beh_data.Cue,"shape","IgnoreCase",true)  & accuracy == "no") = "yes";
color(color~="yes") = "no";
converted_data.Color = color(tstart:end);

% should not actually need these ...
% % add some meta data
% % designate when a rule/task contingency changes
% % For Mizumori lab data, this is the beginning of a "block"
% rulechanges = zeros(numel(beh_data.trial),1);
% rulechanges(beh_data.block_trial==1) = 1;
% converted_data.RuleChangeTrials = string(rulechanges);
% 
% % add NewSessionTrials column
% new_session = zeros(numel(beh_data.trial),1);
% new_session(1) = 1;
% converted_data.NewSessionTrials = string(new_session);
% 
% % adding placeholder CuePosition nan column
% converted_data.CuePosition = nan(numel(beh_data.trial),1);
 