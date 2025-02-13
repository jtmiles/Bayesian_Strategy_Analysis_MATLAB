%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script to convert Mizumori lab "behav.txt" data from LabView strategy
% switching tasks into trial-by-trial strategy likelihood estimates using
% the method from Maggi et al. 2022:
% (https://doi.org/10.1101/2022.08.30.505807)
%
% Can process multiple behav files at once if they're in the same folder,
% just make sure to select that folder when the script prompts you to.
%
% The script is hardcoded to analyze "go_west", "go_east", and
% "alternate_allo" strategies, but can analyze any of the strategy types
% modeled in the "Strategy_models" folder - just add them into the *strats*
% string array
%
% The script is also hardcoded to pre-pad the session with *npad* randomly
% selected trials from the data to temper some of the big swings in
% likelihood estimates often seen in the first 10 or so trials. This
% process repeats with niter estimates and averages those estimates to get 
% a stable result (seems like it takes ~ 100 iters to get the same result 
% every time).
%
%%%% Increasing niter slows down the program a lot, so don't let your data
%%%% pile up too much or else it'll take forever to process!
%
% Will be asked to save file if the data can be processed - if the user
% selects not to save, it will end the program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fdir = uigetdir(cd);
cd(fdir)

strats = ["go_west", "go_east", "alternate_allo"];
npad = 20;
niter = 150; % this number should be ~100 or more for same result each time

bcols = {'trial','block','block_trial','correct_arm','outcome',...
         'start_arm','chosen_arm','delay'};
bf_info = dir('*behav.txt'); % gets ALL behav.txt files
bfiles = {bf_info.name};

% go through files in the folder
for f_ix = 1:numel(bfiles)
    fname = bfiles{f_ix};
    beh_data = readtable(fname);
    beh_data.Properties.VariableNames = bcols;
    converted_data = convert_behav_data(beh_data);
    smat = nan(height(converted_data)+npad,numel(strats),niter);
    % this takes awhile, but ensures the same result almost every time
    for iter = 1:niter 
        Output = multiple_allocentric_analysis(converted_data,strats,npad);
        tab = struct2table(Output);
        cur_mat = nan(size(smat,[1,2]));
        c = 1;
        for f = strats
            fstr = tab.(f{:});
            cur_mat(:,c) = smoothdata(fstr.MAPprobability,'gaussian',5);
            c = c+1;
        end
        smat(:,:,iter) = cur_mat;
    end
    cur_table = array2table(mean(smat,3),"VariableNames",strats);

    if height(cur_table)>height(beh_data) && (exist('npad','var')==1 && npad>0)
        cur_table = cur_table(npad+1:end,:);
    end
    
    all_data = [beh_data, cur_table];
    all_data = renamevars(all_data,"block_trial","trial_in_block");
    
    % plot using a "try/catch" which will plot a nice figure if all 4 blocks
    % are completed and a more basic figure if they aren't. 
    try
        trial_table = gen_strat_fig(all_data,strats);
        trial_table.phase(ismissing(trial_table.phase)) = "perseverate";
    catch
        warning("Couldn't plot full figure, trial phases unresolved")
        figure, plot(all_data,"trial",strats)
        xlim([min(all_data.trial) max(all_data.trial)])
        hold on
        % vertical lines at block starts (vline if you have it in your path)
        plot([all_data.trial(all_data.trial_in_block==1), all_data.trial(all_data.trial_in_block==1)]',...
        repmat([0 1],sum(all_data.trial_in_block==1),1)','k:','LineWidth',2)
        trial_table = all_data;
    end
    
    % compute flexibility score from strategy likelihoods
    flex = [nan;sum(abs(diff(table2array(trial_table(:,strats)),1,1)),2)];
    trial_table.flex = flex;
    
    % add a column with session ID (ratID_yyyy-mm-dd)
    [~,id_end] = regexp(fname, "([a-zA-Z]{2}-\d{3})");
    r_id = fname(id_end-2:id_end);
    [~,id_end] = regexp(fname, "(20\d{2})");
    date_id = datestr(fname(1:id_end), "yyyy-mm-dd");
    save_id = string(r_id)+"_"+date_id;
    trial_table.ID = repmat(save_id,height(trial_table),1);
    answer = questdlg('Continue to save?', ...
                       'Want to save?',...
                       'Yes','No','Yes');
    % Handle response
    switch answer
        case 'Yes'
            disp('Okay, saving data')
        case 'No'
            disp('Okay, shutting down')
            error('Program ended by user')
    end
 
    savefile = "strat_table_"+save_id+".csv"
    writetable(trial_table,savefile);
end