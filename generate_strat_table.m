save = true; 
% basedir = 'C:\Users\jesse\Desktop\to_analyze\behavior_dataset\';
% cd(basedir)
fdir = uigetdir(cd);
cd(fdir)

bf_info = dir('*behav.txt'); % gets ALL behav.txt files
bfiles = {bf_info.name};

strats = ["go_west", "go_east", "alternate_allo"];
npad = 20;
niter = 150; % this number should be ~150 or more
bcols = {'trial','block','block_trial','correct_arm','outcome',...
         'start_arm','chosen_arm','delay'};

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
    
    % smooth_tab = smooth_strats(cur_table,1,5);
    all_data = [beh_data, cur_table];
    all_data = renamevars(all_data,"block_trial","trial_in_block");
    
    % plot using a "try/catch" which will plot a nice figure if all 4 blocks
    % are completed and a more basic figure if they aren't.
    try
        trial_table = gen_strat_fig(all_data,strats);
        trial_table.phase(ismissing(trial_table.phase)) = "perseverate";
    catch
        warning("Couldn't plot explore/exploit on figure")
        figure, plot(all_data,"trial",strats)
        xlim([min(all_data.trial) max(all_data.trial)])
        hold on
        % vertical lines at block starts (vline if you have it in your path)
        plot([all_data.trial(all_data.trial_in_block==1), all_data.trial(all_data.trial_in_block==1)]',...
        repmat([0 1],sum(all_data.trial_in_block==1),1)','k:','LineWidth',2)
    end
    
%     dstrat = sqrt(diff(trial_table.go_west-trial_table.go_east).^2+diff(trial_table.alternate_allo).^2);
%     trial_table.flex = [nan;dstrat];
    [~,id_end] = regexp(fname, "([a-zA-Z]{2}-\d{3})");
    r_id = fname(id_end-2:id_end);
    [~,id_end] = regexp(fname, "(20\d{2})");
    date_id = datestr(fname(1:id_end), "yyyy-mm-dd");
    save_id = string(r_id)+"_"+date_id;
    trial_table.ID = repmat(save_id,height(trial_table),1);
    % figure, plot(normalize(trial_table.flex,'zscore','robust'))
    % hold on
    % plot([min(trial_table.trial), max(trial_table.trial)],[2 2],'k:')
    % xlim([1 max(trial_table.trial)])
    
    answer = questdlg('Continue to save?', ...
                       'Want to save?',...
                       'Yes','No','Yes');
    % Handle response
    switch answer
        case 'Yes'
            disp('Okay, saving data')
        case 'No'
            disp('Whoops...')
            error('Shutting it down')
    end
 
    savefile = "strat_table_"+save_id+".csv"
    writetable(trial_table,savefile);
    
end