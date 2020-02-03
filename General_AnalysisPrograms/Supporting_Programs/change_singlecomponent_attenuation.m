function change_singlecomponent_attenuation(TSO, NewAttenuation)

    %Load in trace structure to make sure it is in object form:
    TSO = LoadTraceStruct(TSO);
    
    if strcmp(TSO.combo,'yes')
        error('Program expects single component trace structure, not combo');
    end
    
    OldAttenuation = TSO.attenuation_ratio;
    
    if ~isfinite(OldAttenuation) || OldAttenuation == 0
        error('Cannot change attenuation because current attenuation is undefined');
    end
    
    %Walk through traces and convert each:
    for i = 1:TSO.Ntraces
        trace = TSO.Traces{i};
        
        %Unconvert from old attenuation and reconvert using new
        trace(:,1) = trace(:,1) * NewAttenuation/OldAttenuation;
        
        TSO.Traces{i} = trace;
    end
    
    %Update attenuation ratio!
    TSO.attenuation_ratio = NewAttenuation;
    
end