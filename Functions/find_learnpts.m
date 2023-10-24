function learnpts = find_learnpts(sesh_table,strats)
    learnpts = [];
    for block = unique(sesh_table.block)'
        cur_block = sesh_table(sesh_table.block==block,strats);
        btrials = sesh_table.trial(sesh_table.block==block);
        [~,strat_ix] = max(table2array(cur_block(end,:)));
        strat = strats(strat_ix);
        s_curve = table2array(cur_block(:,strats==strat));
        non_strats = table2array(cur_block(:,strats~=strat));
        % find when target strategy becomes most likely
        learnpt = btrials(find(sum(s_curve<=non_strats,2)>0,1,'last'));
%         learnpt = btrials(find(prod(s_curve>=non_strats,2)>0,1,'first'));

        % if target strategy starts out as most likely/always most likely
        if isempty(learnpt) || all(prod(s_curve>=non_strats,2))
            % look for max in other strats that occur after target strat's min
    %         [~,sloc] = min(s_curve);
    %         ns1loc = find(non_strats(:,1)>min(s_curve),1,"last");
    %         ns2loc = find(non_strats(:,2)>min(s_curve),1,"last");
    %         if (ns1loc>sloc) && (ns1loc>ns2loc)  
    %             learnpt = btrials(ns1loc);
    %         elseif (ns2loc>sloc) && (ns2loc>ns1loc)
    %             learnpt = btrials(ns2loc);
    %         elseif (sloc>ns1loc) && (sloc>ns2loc)
    %             learnpt = btrials(1);
    %         else
    %             disp("Didn't find learning point, "+" block "+string(block)+" "+sesh_table.ID(1))
    %             disp(sloc)
    %             disp(ns1loc)
    %             disp(ns2loc)
    %         end
    %         learnpt = max([sloc ns1loc ns2loc]);
            [~,learnpt] = min(s_curve);
            learnpt = learnpt-1+btrials(1);
        end
        learnpts = [learnpts,learnpt];
    end

    % can be hard to determine learn pt in first block if they guess
    % correctly right away
    if min(learnpts) == 1
        learnpts(1) = 2;
    end

    % check to see whether we have all four
    if numel(learnpts)==3
        % often happens if rat is pulled early b/c of ephys issue
        warning("Only 3 learning points found, assigning final trial as 4th!")
        learnpts = [learnpts,height(sesh_table)];
    elseif numel(learnpts)==2
        % check that strat estimates weren't messed up
        warning("Only 2 learning points found! Check data")
        figure
        hold on
        for s = 1:numel(strats)
            plot(sesh_table,"trial",strats(s),'LineWidth',1.5)
        end
        vline(sesh_table.trial(sesh_table.trial_in_block==1),'k--')
    elseif numel(learnpts)==1
        warning("Only 1 learning point found! Check data")
        % check that strat estimates weren't messed up
        warning("Only 2 learning points found! Check data")
        figure
        hold on
        for s = 1:numel(strats)
            plot(sesh_table,"trial",strats(s),'LineWidth',1.5)
        end
        vline(sesh_table.trial(sesh_table.trial_in_block==1),'k--')
    end
    
end