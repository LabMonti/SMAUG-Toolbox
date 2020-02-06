function SubSection = get_simple_TSO_subsection(TSO,StartTrace,EndTrace)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Pulls a subsection of traces out of a 
    %TraceStruct object (TSO) to make a new TSO
    %
    %~~~INPUTS~~~:
    %
    %TSO: a trace structure object that is NOT a combo
    %
    %StartTrace: the first trace to include in the subsection
    %
    %EndTrace: the last trace to include in the subsection
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %SubSection: new TraceStruct object containing only those traces between
    %   StartTrace and EndTrace (inclusive of course, this is matlab!)
    
    
    %Make sure start and end traces are possible
    N = TSO.Ntraces;
    if EndTrace > N || StartTrace < 1 || StartTrace > EndTrace
        error('Impossible start and end traces!');
    end
    
    %De-load the TSO because we want to create a new TraceStruct first, and
    %that is easier to make from a struct
    TraceStruct = UnLoadTraceStruct(TSO);
    
    SubSection = struct();
    
    if strcmp(TraceStruct.combo, 'yes')
        error("Do not pull a simple subsection from a combo!");
    end
    
    %Copy over all fields from the original, except for the traces:
    all_fields = fieldnames(TraceStruct);
    for i = 1:length(all_fields)
        if ~strcmp(all_fields{i},'Traces')
            SubSection.(all_fields{i}) = TraceStruct.(all_fields{i});
        end
    end

    %Update each per_traceField to only include relevant values (if it
    %exists in the first place):
    for i = 1:length(TSO.per_traceFields)
        name_of_field = TSO.per_traceFields{i};
        if ~isempty(TraceStruct.(name_of_field))
            SubSection.(name_of_field) = TraceStruct.(name_of_field)(StartTrace:EndTrace);
        end
    end
    
    %Copy over relavant traces:
    counter = 0;
    TotalPoints = 0;
    AllTraces = cell(EndTrace - StartTrace + 1, 1);
    for i = StartTrace:EndTrace
        tr = TraceStruct.Traces{i};
        
        counter = counter + 1;
        AllTraces{counter} = tr;
        
        TotalPoints = TotalPoints + size(tr,1);
    end
    SubSection.Traces = AllTraces;
    
    %Get pause numbers that fall within the subsection:
    if ~isempty(TraceStruct.PauseNumbers)
        pauses = TraceStruct.PauseNumbers;
        pauses = pauses - (StartTrace - 1);
        pauses = pauses(pauses > 0);
        pauses = pauses(pauses < (EndTrace - StartTrace + 1));
        SubSection.PauseNumbers = pauses;
    else
        SubSection.PauseNumbers = [];
    end
    
    %Update # of traces and # of points
    SubSection.Ntraces = counter;
    SubSection.NumTotalPoints = TotalPoints;
    
    %Update name:
    SubSection.name = strcat(SubSection.name, '_subsection');
    
    %Convert SubSection to a trace struct object before returning it:
    SubSection = LoadTraceStruct(SubSection);

end
