function newstruct = tracestruct_from_subset(TraceStruct, traces2include,...
    new_name)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Extracts a subset of (not neccessarily 
    %consectuive!) traces from a trace structure to make a new trace 
    %structure.  Useful as a shortcut inside some functions, not designed
    %to be called directly by the user. Eliminates combo information. 
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all breaking traces for the
    %   dataset in question
    %
    %traces2include: vector containing the ID#s of all traces to be
    %   included in the new trace structure
    %
    %new_name: optional string input to be used as the dataset name for the
    %   new trace structure
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %  
    %newstruct: trace structure containing the extracted traces only
    
    
    %Load and unload trace struct to make sure all fields are filled with
    %at least default values
    TraceStruct = LoadTraceStruct(TraceStruct);
    TraceStruct = UnLoadTraceStruct(TraceStruct);
    
    fnames = fieldnames(TraceStruct);
    n = length(fnames);
    newstruct = struct;
    
    %Copy over all fields except those in the skip list
    skip_list = {'Ncombo','combo','Ntraces_components','ComponentProperties',...
        'Traces','Ntraces','NumTotalPoints','date_made','file_made_by',...
        'PauseNumbers'};
    skip_list = [skip_list, TraceStruct.per_traceFields];
    for i = 1:n
        if ~any(strcmp(fnames{i}, skip_list))
            newstruct.(fnames{i}) = TraceStruct.(fnames{i});
        end
    end
    
    %Set some easy fields:
    newstruct.combo = 'no';
    newstruct.date_made = date();
    newstruct.file_made_by = mfilename();
    
    %Get all the traces:
    n = length(traces2include);
    newstruct.Ntraces = n;
    Traces = cell(n,1);
    counter = 0;
    for i = 1:n
        counter = counter + 1;       
        Traces{counter} = TraceStruct.Traces{traces2include(i)};
    end
    newstruct.Traces = Traces;
    
    %Fill in per-trace fields
    counter = 0;
    per_traceFields = TraceStruct.per_traceFields;
    for i = 1:length(per_traceFields)
        if ~isempty(TraceStruct.(per_traceFields{i}))
            values = zeros(n,1);
            for j = 1:n
                counter = counter + 1;
                values(counter) = TraceStruct.(per_traceFields{i})(traces2include(j));
            end
            values = values(1:counter);
            newstruct.(per_traceFields{i}) = values;
        end
    end
    
    %Re-set name if requested
    if nargin == 3
        newstruct.name = new_name;
    end
    
    %Add field to indicate that non-consecutive traces have been pulled!
    newstruct.NonConsecutiveTraces = true;
    
    %Other fields are OK to leave missing

end
