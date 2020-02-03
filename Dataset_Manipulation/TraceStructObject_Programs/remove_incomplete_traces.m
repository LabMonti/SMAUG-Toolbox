function remove_incomplete_traces(TSO, conductance)

    NT = TSO.Ntraces;
    KeepTraces = false(NT, 1);
    NPoints = 0;

    %If trace conductances are in log space, put cutoff in log
    %space too so that they are comparable
    if TSO.y_Log
        conductance = log10(conductance);
    end

    %Walk through all traces and figure out which ones to keep
    for i = 1:NT
        tr = TSO.Traces{i};
        min_cond = min(tr(:,2));

        if min_cond <= conductance
            KeepTraces(i) = true;
            NPoints = NPoints + size(tr,1);
        end
    end
    newNT = sum(KeepTraces);

    %Display number and percentage of traces being removed:
    n_removed = NT - newNT;
    pct_removed = n_removed/NT * 100;
    disp(strcat(num2str(n_removed), ' traces removed (', num2str(pct_removed),...
        '%)'));

    %Update Ntraces, NumTotalPoints, and the Traces themselves:
    TSO.Traces = TSO.Traces(KeepTraces);
    TSO.NumTotalPoints = NPoints;
    TSO.Ntraces = newNT;

    %Update each per_traceField:
    for i = 1:length(ComboTSO.per_traceFields)
        name_of_field = ComboTSO.per_traceFields{i};
        if ~isempty(TSO.(name_of_field))
            TSO.(name_of_field) = TSO.(name_of_field)(KeepTraces);
        end
    end

    %Need to deal with pause numbers by subtracting the number of
    %removed traces below each pause number
    for i = 1:length(TSO.PauseNumbers)
        TSO.PauseNumbers(i) = TSO.PauseNumbers(i) - ...
            sum(~KeepTraces(1:floor(TSO.PauseNumbers(i))));
    end

end