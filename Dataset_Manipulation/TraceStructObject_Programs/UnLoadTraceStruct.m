%04Oct18 NDB: Takes a trace structure that was "loaded" to create an
%object, and reverses the process to get back the trace structure
function TraceStruct = UnLoadTraceStruct(TraceStructObject)

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