function [alpha,beta,success_total,failure_total] = update_strategy_posterior_probability(trial_type,decay_rate,success_total,failure_total,alpha_zero,beta_zero)

% UPDATE_STRATEGY_POSTERIOR_PROBABILITY updates the Beta distribution parameters
% [ALPHA,BETA,S_TOTAL,F_TOTAL] = UPDATE_STRATEGY_POSTERIOR_PROBABILITY(TYPE,DECAY_RATE,S_TOTAL,F_TOTAL,ALPHA_ZERO,BETA_ZERO)
% updates the Beta distribution parameters (ALPHA, BETA), according to:
% TYPE: a string giving the trial type of the current trial: a "failure",
% "success", or "null" attempt to execute the strategy, as returned by the
% strategy model functions.
% DECAY_RATE: scalar, the decay weight of previous trials' events (parameter "gamma")
% S_TOTAL, F_TOTAL: scalars, respectively the running total of previous successes
% and failures, decayed. Set S_TOTAL = F_TOTAL = 0 for the first trial.
% ALPHA_ZERO, BETA_ZERO: scalars, the priors for alpha and beta  
%
% Mark Humphries 2/4/2022

switch trial_type
    case "success"
        trial_outcome = 1;
    case "failure"
        trial_outcome = 0;       
    case "null"
        trial_outcome = -1;
end

% Bernoulli trial update, exponentially weighting prior outcome; 
% Heaviside function causes both totals to only decay on "null" trials
success_total = decay_rate * success_total + trial_outcome*(trial_outcome >= 0);
failure_total = decay_rate * failure_total + (1-trial_outcome)*(trial_outcome >= 0);
% update Beta distribution parameter estimates
alpha = alpha_zero + success_total; 
beta = beta_zero + failure_total;
