
function trial_type = go_west(trial_data)

% GO_WEST checks if subject chose the west option on this trial
% TYPE = GO_WEST(TRIAL_DATA) takes the Table of data TRIAL_DATA up to the current trial, and
% returns the TYPE ('success','failure')
%
% Jesse Miles 21/9/2022

% check only the current trial
if trial_data.Location(end) == "West"
    trial_type = "success";
else 
    trial_type = "failure";
end
