%22Feb2018 NDB: This program reads in a trace structure and outputs the
%same trace structure file just with the attenuation changed to some
%different value.  Can be used to take a trace structure in interelectrode
%distance back to piezo distance by using 1/1000 as the new attenuation.  
function TraceStruct = ChangeTraceStruct_Attenuation(TraceStruct, NewAttenuation)
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all the traces in a dataset
    %   and associated information
    %
    %NewAttenuation: the new attenuation that the TraceStruct should be
    %   converted using, in units of nm/um (so an attenuation of 1/1000
    %   converts the TraceStruct back to Piezo distance)
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %TraceStruct: the same as the input TraceStruct, just with the
    %   attenuation re-converted

    
    %Load in trace structure:
    TraceStruct = LoadTraceStruct(TraceStruct);
    
    %Break trace structure into components:
    Components = TraceStruct.get_combo_components();
    
    %Convert attenuation of each component separately (because they may
    %have different starting attenuations)
    for i = 1:length(Components)
        change_singlecomponent_attenuation(Components{i}, NewAttenuation)
    end
    
    %Re-combine TSOs and unload object back to plain trace struct
    TraceStruct = UnLoadTraceStruct(combine_TSOs(Components,TraceStruct.name));

end