function trial_type = alternate_allo(trial_data)

% ALTERNATE checks if subject chose different spatial options on consecutive trials
% TYPE = ALTERNATE(TRIAL_DATA) takes the Table of data TRIAL_DATA up to the current trial, and
% returns the TYPE ('success','failure'); returns 'null' for the first trial
%
% Mark Humphries 31/3/2022

number_trials = size(trial_data,1);
    
if number_trials == 1
    trial_type = "null";
elseif trial_data.Location(end) ~= trial_data.Location(end-1)
    % chose different spatial option on consecutive trials, so is a success
    trial_type = "success";
else
    % chose the same option on consecutive trials
    trial_type = "failure"; 
end
