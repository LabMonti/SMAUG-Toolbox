function TraceStruct = ChangeTraceStruct_Attenuation(TraceStruct, NewAttenuation)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Reads in a trace structure and outputs the
    %same trace structure file just with the attenuation changed to a
    %different value.  
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all the traces in a dataset
    %   and associated information
    %
    %NewAttenuation: the new attenuation that the TraceStruct should be
    %   converted using (should be a unitless ratio of inter-electrode
    %   distance to piezo distance)
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