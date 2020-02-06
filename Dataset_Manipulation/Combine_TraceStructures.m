function ComboStruct = Combine_TraceStructures(TraceStructCellArray, ...
    ComboName, AttenuationOverrideList)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Combine any number of TraceStructs (which may 
    %or may not already be combos) into a single combined TraceStruct.  
    %All fields will be filled in with default values if left unspecified.
    %
    %~~~INPUTS~~~:
    %
    %TraceStructCellArray: a 1D cell array containing all the TraceStructs
    %   to be merged
    %
    %ComboName: the name that should be given to the new combination
    %   structure
    %
    %AttenuationOverrideList: an optional vector of new attenuations to use
    %   to re-convert each input TraceStruct before merging them
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %ComboStruct: a combination trace structure created by merging the two
    %   input structures
    

    Nstructs = length(TraceStructCellArray);

    %If attenuation overrides are specified, convert the attenuation of
    %each input trace structure
    if nargin == 3 && ~isempty(AttenuationOverrideList)
        
        %Make sure # of overrides matches # of trace structures
        if length(TraceStructCellArray) ~= length(AttenuationOverrideList)
            error('Number of attenuation overrides must match number of input structures!');
        end
        
        for i = 1:Nstructs
            TraceStructCellArray{i} = ChangeTraceStruct_Attenuation(TraceStructCellArray{i},AttenuationOverrideList(i)); 
        end
    end
    
    %Load in each trace structure
    for i = 1:Nstructs
        TraceStructCellArray{i} = LoadTraceStruct(TraceStructCellArray{i});
    end
    
    %Combine trace structures as objects:
    ComboStruct = combine_TSOs(TraceStructCellArray, ComboName);
    
    %Convert combo back to plain structure
    ComboStruct = UnLoadTraceStruct(ComboStruct);
    
end