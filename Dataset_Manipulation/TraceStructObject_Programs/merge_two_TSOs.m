%20Aug2018 NDB: Takes in a trace struct object (TSO), and merges on a
%second TSO to the end of it (both TSOs must be non-combos)
function merge_two_TSOs(TSO, TSO_addon)
    %~~~INPUTS~~~:
    %
    %TSO: A TSO which is NOT a combination of multiple data blocks.  This
    %   TSO will end up modified by this program to become a combo
    %   containing both the original TSO and TSO_addon
    %
    %TSO_addon: A TSO which is NOT a combination of multiple data blocks

    
    %Next, make sure that both TSOs are not combos
    if ~strcmp(TSO.combo, 'no') || ~strcmp(TSO_addon.combo, 'no')
        error('This function can only merge two raw, non-combo structures!');
    end
    
    %Update TSO to now be a combination of two components
    TSO.combo = 'yes';
    TSO.Ncombo = 2;
    
    %Save component properties:
    TSO.ComponentProperties.ChopMethods = {TSO.ChopMethod, TSO_addon.ChopMethod};
    TSO.ComponentProperties.names = {TSO.name, TSO_addon.name};
    TSO.ComponentProperties.files_made_by = {TSO.file_made_by, TSO_addon.file_made_by};
    TSO.ComponentProperties.dates_made = {TSO.date_made, TSO_addon.date_made};
    TSO.ComponentProperties.Formats = {TSO.Format, TSO_addon.Format};
    TSO.ComponentProperties.NoiseFloors = {TSO.NoiseFloor, TSO_addon.NoiseFloor};
    TSO.ComponentProperties.attenuation_ratios = {TSO.attenuation_ratio, TSO_addon.attenuation_ratio};
    TSO.ComponentProperties.NumsTotalPoints = {TSO.NumTotalPoints, TSO_addon.NumTotalPoints};
    TSO.ComponentProperties.PauseNumbers = {TSO.PauseNumbers, TSO_addon.PauseNumbers};
    TSO.ComponentProperties.CalibrationDriftCorrection = {TSO.CalibrationDriftCorrection, TSO_addon.CalibrationDriftCorrection};
    TSO.ComponentProperties.Ref_NoiseFloor_Voltage = {TSO.Ref_NoiseFloor_Voltage, TSO_addon.Ref_NoiseFloor_Voltage};
    
    %Update chop method of combo if mixed:
    if ~strcmp(TSO.ChopMethod, TSO_addon.ChopMethod)
        TSO.ChopMethod = 'mixed';
        warning('Structures being combined have different chop methods!');
    end
    
    %Update attenuation with averaged attenuation:
    TSO.attenuation_ratio = (TSO.attenuation_ratio + TSO_addon.attenuation_ratio) / 2;
    
    %Update Format of combo if mixed:
    if ~strcmp(TSO.Format, TSO_addon.Format)
        TSO.Format = 'mixed';
        warning('Structures being combined have different formats!');
    end    
    
    %Update bridge amp drift correction of combo if mixed:
    if TSO.CalibrationDriftCorrection ~= TSO_addon.CalibrationDriftCorrection
        TSO.CalibrationDriftCorrection = 'mixed';
        warning('Structures being combined have different calibration drift settings!');
    end
    
    %Update reference noise floor voltage of combo if mixed:
    if abs(TSO.Ref_NoiseFloor_Voltage - TSO_addon.Ref_NoiseFloor_Voltage) > 0.0005 && ...
            ~(isnan(TSO.Ref_NoiseFloor_Voltage) && isnan(TSO_addon.Ref_NoiseFloor_Voltage))
        TSO.Ref_NoiseFloor_Voltage = 'mixed';
        warning('Structures being combined have different reference noise floor voltages!');
    end
    
    %Save # of traces in each component (very important!!)
    TSO.Ntraces_components = [TSO.Ntraces, TSO_addon.Ntraces];
    
    %Merge pause vectors:
    n1 = length(TSO.PauseNumbers);
    n2 = length(TSO_addon.PauseNumbers);
    TSO.PauseNumbers = [TSO.PauseNumbers; zeros(n2, 1)];
    TSO.PauseNumbers(n1+1:n1+n2) = (TSO_addon.PauseNumbers + ...
        TSO.Ntraces); %Make sure shifte pause numbers over so they are 
                         %still on top of second component!
    
    %Combine each type of per_traceField if it exists in both structures; 
    %otherwise, set the entire field to default value (empty):
    for i = 1:length(TSO.per_traceFields)
        name_of_field = TSO.per_traceFields{i};
        if ~isempty(TSO.(name_of_field)) && ~isempty(TSO_addon.(name_of_field))
            TSO.(name_of_field) = [TSO.(name_of_field); TSO_addon.(name_of_field)];
        else
            TSO.(name_of_field) = [];
        end
    end  
    
    %Combined noise floors by averaging:
    TSO.NoiseFloor = (TSO.NoiseFloor + TSO_addon.NoiseFloor) / 2;
    
    %Update total # of traces:
    TSO.Ntraces = TSO.Ntraces + TSO_addon.Ntraces;
    
    %Update total # of points: 
    TSO.NumTotalPoints = TSO.NumTotalPoints + TSO_addon.NumTotalPoints;
    
    %Add all the traces to the combo structure!
    Traces1 = TSO.Traces;
    Traces2 = TSO_addon.Traces;
    AllTraces = cell(TSO.Ntraces, 1);
    AllTraces(1:length(Traces1)) = Traces1;
    counter = length(Traces1);
    for i = 1:TSO_addon.Ntraces
        counter = counter + 1;
        AllTraces{counter} = Traces2{i};
    end
    TSO.Traces = AllTraces;
    
end