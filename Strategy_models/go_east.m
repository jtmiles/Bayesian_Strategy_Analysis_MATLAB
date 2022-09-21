
function trial_type = go_east(trial_data)

% GO_EAST checks if subject chose the left option on this trial
% TYPE = GO_EAST(TRIAL_DATA) takes the Table of data TRIAL_DATA up to the current trial, and
% returns the TYPE ('success','failure')
%
% Mark Humphries 21/9/2022

% check only the current trial
if trial_data.Location(end) == "East"
    trial_type = "success";
else 
    trial_type = "failure";
end
