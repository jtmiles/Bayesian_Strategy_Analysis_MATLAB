function expts = find_expts(sesh_table,learnts,strats)
    expts = [];
    blocks = unique(sesh_table.block)'; blocks = blocks(blocks>=2);
    expts = [expts;1];
    for block = blocks
        cur_block = sesh_table(sesh_table.block==block&sesh_table.trial>2,strats);
        btrials = sesh_table.trial(sesh_table.block==block&sesh_table.trial>2);
        % strat with max likelihood on first trial in block will be prev strat
        [~,strat_ix] = max(table2array(cur_block(1,:)));
        strat = strats(strat_ix);
        s_curve = table2array(cur_block(:,strats==strat));
        % find the trial where s_curve (prior strat) hits its max
        [~,ex_ix] = max(s_curve);
        expt = btrials(ex_ix);
        if ~(expt<learnts(block))
            warning("Explore and exploit phases not aligned!")
            display(expt); display(learnts(block))
        end
%         assert(expt<learnts(block), "Explore phase can't begin after exploit!"+" (block "+string(block)+")")
        expts = [expts;expt];
    end
    % for sessions when rats guess initial strategy right away
    if min(learnts)<=2 
        if numel(expts) == 3
            expts = [1;expts];
        end
    end

end