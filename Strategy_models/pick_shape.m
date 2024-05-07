function trial_type = pick_shape(trial_data)

% GO_LEFT checks if subject chose the left option on this trial
% TYPE = GO_LEFT(TRIAL_DATA) takes the Table of data TRIAL_DATA up to the current trial, and
% returns the TYPE ('success','failure')
%
% Jesse Miles - May 06, 2024

% check only the current trial
if trial_data.Shape(end) == "yes"
    trial_type = "success";
else 
    trial_type = "failure";
end