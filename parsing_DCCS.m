[fname, path] = uigetfile("*.csv", "Pick DCCS .csv file");
cd(path)

trialtab = readtable([path fname]); 
varnames = trialtab.Properties.VariableNames';
keepcols = ["Trial";"cResp";"TestStimulus_RESP";"TestStimulus_ACC";...
            "Stimulus";"MixedTrialList"];
if any(contains(varnames,"AudioCue"))
    % rename the old cue variable, which is not the target cue
    trialtab = renamevars(trialtab,"Cue","XcueX"); 
    trialtab = renamevars(trialtab,"AudioCue","Cue");
    keepcols = [keepcols;"Cue"];
elseif any(contains(varnames,"Cue"))
    % WARNING - v2 files also contain "Cue", but it's a different variable!
    keepcols = [keepcols;"Cue"];
else
    warning("Did not find a 'Cue' column with expected format")
end


keeptab = trialtab(:,keepcols);

beh_data = convert_behav_data(trialtab);

strategies = ["pick_color"; "pick_right"; "pick_shape"];
npad = 20;
niter = 20;
smat = nan(height(beh_data)+npad,numel(strategies),niter);
% this takes awhile, but ensures the same result almost every time
for iter = 1:niter 
    Output = DCCS_strategy_analysis(beh_data,strategies,npad);
    tab = struct2table(Output);
    cur_mat = nan(size(smat,[1,2]));
    c = 1;
    for f = strategies'
        fstr = tab.(f{:});
        cur_mat(:,c) = smoothdata(fstr.MAPprobability,'gaussian',5);
        c = c+1;
    end
    smat(:,:,iter) = cur_mat;
end
all_data = array2table(mean(smat,3),"VariableNames",strategies);

if height(all_data)>height(beh_data) && (exist('npad','var')==1 && npad>0)
    all_data = all_data(npad+1:end,:);
end

all_data = [beh_data all_data];
flex = table2array(sum(abs(diff(all_data(:,strategies(1:2)))),2));
all_data = renamevars(all_data,"TrialIndex","trial");
all_data.trial = (1:height(all_data))';
% plot using a "try/catch" which will plot a nice figure if all 4 blocks
% are completed and a more basic figure if they aren't. 
figure, plot(all_data,"trial",strategies,"LineWidth",2)
xlim([min(all_data.trial) max(all_data.trial)]), ylim([0 1])
ylabel("Strategy Likelihood"); xlabel("Trial")
yticks(0.1:0.2:0.9); xticks(5:10:95)
cmap = colororder;
for s = 1:numel(strategies)
    y = table2array(all_data(end,strategies(s)));
    text(101,y,replace(strategies(s),"pick_"," "),"Color",cmap(s,:))
end

figure
plot(all_data.trial(2:end), flex, Color="k", LineWidth=2)
ylim([0 0.1]);
disp(num2str(sum(all_data.Reward=="no"))+" incorrect trials")
% trial_table = all_data;
