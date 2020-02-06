function TraceStruct = UnLoadTraceStruct(TraceStructObject)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Takes a trace structure that was "loaded" to 
    %create an object, and reverses the process to get back the trace 
    %structure
    %
    %~~~INPUTS~~~:
    %
    %TraceStructObject: a trace structure object containing a "loaded"
    %   dataset
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %   
    %TraceStruct: a structure containing all of the information from the
    %   inputted TSO, but no longer in object form
    
    
    %If the variable passed in is already a trace structure that should be
    %OK, just pass it back:
    if isstruct(TraceStructObject)
        TraceStruct = TraceStructObject;
    else
        %Make new empty trace structure
        TraceStruct = struct();

        %Get all properties of object
        all_properties = properties(TraceStructObject);
        n_prop = length(all_properties);

        %Copy over all properties except other_fields and isLoaded
        for i = 1:n_prop
            if ~strcmp(all_properties{i},'isLoaded') && ~strcmp(...
                    all_properties{i},'other_fields')
                TraceStruct.(all_properties{i}) = TraceStructObject.(all_properties{i});
            end
        end

        %Copy over any "other_fields"
        if ~isempty(TraceStructObject.other_fields)
            fn = fieldnames(TraceStructObject.other_fields);
            for i = 1:length(fn)
                TraceStruct.(fn{i}) = TraceStructObject.other_fields.(fn{i});
            end       
        end
    end

end