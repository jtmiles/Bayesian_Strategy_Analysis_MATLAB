function trial_table = gen_strat_fig(trial_table,strats)
%
% input is a table with strategy likelihood estimates
% best for table to have already been assigned task phases and for strategy
% likelihood estimates to have been smoothed. will find learning points and
% explore points (end of perseveration) if the table doesn't already have a
% "phase" column, though
%
% returns the table and plots a figure with the explore phase shaded
% yellow for each block and the exploit phase shaded green, along with the
% strategy likelihoods overlaid
%
% NOTES:
%%%% currently only set up to plot "go_west", "go_east", and
%%%% "alternate_allo" strategy types! Add others in the plotting section
%

figure
hold all

blockstarts = trial_table.trial(trial_table.trial_in_block == 1);
blockstarts = [blockstarts(2:end);max(trial_table.trial)];

if any(contains(trial_table.Properties.VariableNames,"phase"))
    learnts = splitapply(@min,trial_table.trial(trial_table.phase=="exploit"), ...
              findgroups(trial_table.block(trial_table.phase=="exploit")));
    explorets = splitapply(@min,trial_table.trial(trial_table.phase=="explore"), ...
                findgroups(trial_table.block(trial_table.phase=="explore")));
else
    learnts = find_learnpts(trial_table,strats);
    explorets = find_expts(trial_table,learnts,strats);
    trial_table.phase = strings(height(trial_table),1);
    for block = unique(trial_table.block)'
        trial_table.phase(explorets(block):learnts(block)) = "explore";
        trial_table.phase(learnts(block):find(trial_table.block==block,1,'last')) = "exploit";
    end
end

% need to ensure alignment is right for plotting, but this is gross
if isrow(learnts)
    learnts = learnts';
end
if isrow(explorets)
   explorets = explorets';
end

learnts(1)
% blockstarts
% explorets

learnXs = [learnts';blockstarts';blockstarts';learnts'];
zeroYs = zeros(1,numel(learnts));
oneYs = ones(1,numel(zeroYs));
patchYs = [zeroYs;zeroYs;oneYs;oneYs];
learnCs = permute(ones(3,1,numel(learnts)).*[0,0.6,0.2]',[3 2 1]);
exploreXs = [explorets'; learnts'; learnts'; explorets'];
exploreCs = permute(ones(3,1,numel(learnts)).*[0.8,0.66,0.2]',[3 2 1]);
patch(exploreXs,patchYs,exploreCs,'FaceAlpha',0.2,'EdgeColor','none')
patch(learnXs,patchYs,learnCs,'FaceAlpha',0.2,'EdgeColor','none')
%%%% plot the strategy likelihood curves
plot(trial_table.trial, trial_table.go_east,'LineWidth',2);
plot(trial_table.trial, trial_table.go_west,'LineWidth',2);
plot(trial_table.trial,trial_table.alternate_allo,'LineWidth',2);
%%%%
xlim([1 max(trial_table.trial)])
ylabel("Strategy likelihoods")
xlabel("Trial in session")

end