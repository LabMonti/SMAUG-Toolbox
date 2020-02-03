%NDB 16Aug18: Combine any number of TraceStructs (which may or may not
%already be combos) into a single combined TraceStruct
%NDB 05Oct18: Updated to convert to trace struct objects, combine, then
%convert back.  This has the advantage of ensuring all fields are filled
%in with default values if values are unspecified
function ComboStruct = Combine_TraceStructures(TraceStructCellArray, ...
    ComboName, AttenuationOverrideList)
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