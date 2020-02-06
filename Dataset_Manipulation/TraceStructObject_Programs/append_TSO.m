function append_TSO(ComboTSO, TSO_addon)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: appends a non-combo trace structure object (TSO)
    %to a combination TSO
    %
    %~~~INPUTS~~~:
    %
    %ComboTSO: A combo trace structure object which will have TSO_addon
    %   appended to it by this program
    %
    %TSO_addon: a non-combo trace structure object to be appended onto the
    %   end of ComboTSO


    %Make sure that the TSO to append is not already a combo
    if ~strcmp(TSO_addon.combo, 'no')
        error('The appended TraceStruct must be a raw, non-combo structure!');
    end   

    %Increment # of combined structures by 1
    NCI = ComboTSO.Ncombo + 1; %(new combo index)
    ComboTSO.Ncombo = NCI;
    
    %Add component properties for the new section being appended:
    ComboTSO.ComponentProperties.ChopMethods{NCI} = TSO_addon.ChopMethod;
    ComboTSO.ComponentProperties.names{NCI} = TSO_addon.name;
    ComboTSO.ComponentProperties.files_made_by{NCI} = TSO_addon.file_made_by;
    ComboTSO.ComponentProperties.dates_made{NCI} = TSO_addon.date_made;
    ComboTSO.ComponentProperties.Formats{NCI} = TSO_addon.Format;
    ComboTSO.ComponentProperties.NoiseFloors{NCI} = TSO_addon.NoiseFloor;
    ComboTSO.ComponentProperties.attenuation_ratios{NCI} = TSO_addon.attenuation_ratio;
    ComboTSO.ComponentProperties.NumsTotalPoints{NCI} = TSO_addon.NumTotalPoints;
    ComboTSO.ComponentProperties.PauseNumbers{NCI} = TSO_addon.PauseNumbers;
    ComboTSO.ComponentProperties.CalibrationDriftCorrection{NCI} = TSO_addon.CalibrationDriftCorrection;
    ComboTSO.ComponentProperties.Ref_NoiseFloor_Voltage{NCI} = TSO_addon.Ref_NoiseFloor_Voltage;
    
    %If chop method does not match, change to mixed
    if ~strcmp(ComboTSO.ChopMethod,'mixed')
        if ~strcmp(ComboTSO.ChopMethod, TSO_addon.ChopMethod)
            ComboTSO.ChopMethod = 'mixed';
            warning('Structures being combined have different chop methods!');
        end
    end
    
    %Average in attenuation ratio: (weighted average)
    ComboTSO.attenuation_ratio = ((NCI - 1) / NCI)*ComboTSO.attenuation_ratio + ...
        (1 / NCI)*TSO_addon.attenuation_ratio;
    
    %If Format does not match, change to mixed
    if ~strcmp(ComboTSO.Format,'mixed')
        if ~strcmp(ComboTSO.Format, TSO_addon.Format)
            ComboTSO.Format = 'mixed';
            warning('Structures being combined have different formats!');
        end
    end    
    
    %If CalibrationDriftCorrection does not match, change to mixed
    if ~strcmp(ComboTSO.CalibrationDriftCorrection,'mixed')
        if ComboTSO.CalibrationDriftCorrection ~= TSO_addon.CalibrationDriftCorrection
            ComboTSO.CalibrationDriftCorrection = 'mixed';
            warning('Structures being combined have different calibration drift settings!');
        end
    end

    %If Ref_NoiseFloor_Voltage does not match, change to mixed
    if ~strcmp(ComboTSO.Ref_NoiseFloor_Voltage,'mixed')
        if abs(ComboTSO.Ref_NoiseFloor_Voltage - TSO_addon.Ref_NoiseFloor_Voltage) > 0.0005 && ...
                ~(isnan(ComboTSO.Ref_NoiseFloor_Voltage) && isnan(TSO_addon.Ref_NoiseFloor_Voltage))
            ComboTSO.Ref_NoiseFloor_Voltage = 'mixed';
            warning('Structures being combined have different reference noise floor voltages!');
        end
    end    
    
    %Add # of traces in new component (very important!!)
    ComboTSO.Ntraces_components(NCI) = TSO_addon.Ntraces;
    
    %Concatenate pause numbers
    ComboTSO.PauseNumbers = [ComboTSO.PauseNumbers; ...
        TSO_addon.PauseNumbers+ComboTSO.Ntraces]; %Note: ComboStruct.Ntraces is still the old # of traces in it!
    
    %Add each per_traceField if it exists in both structures:
    for i = 1:length(ComboTSO.per_traceFields)
        name_of_field = ComboTSO.per_traceFields{i};
        if ~isempty(ComboTSO.(name_of_field))
            if ~isempty(TSO_addon.(name_of_field))
                ComboTSO.(name_of_field) = [ComboTSO.(name_of_field); TSO_addon.(name_of_field)];
            else
                %If the combo has motor positions but the appended block
                %doesn't, remove all motor positions to be consistent
                ComboTSO.(name_of_field) = [];
            end
        end
    end       
    
    %Add noise floor: (weighted average)
    ComboTSO.NoiseFloor = ((NCI - 1) / NCI)*ComboTSO.NoiseFloor + ...
        (1 / NCI)*TSO_addon.NoiseFloor;
    
    %Get total # of traces:
    ComboTSO.Ntraces = ComboTSO.Ntraces + TSO_addon.Ntraces;
    
    %Get total # of points: (first make sure # of points for new section is
    %determined)
    ComboTSO.NumTotalPoints = ComboTSO.NumTotalPoints + TSO_addon.NumTotalPoints;
    
    %Add the traces from the new section to the combo struct:
    counter = sum(ComboTSO.Ntraces_components(1:NCI-1));
    old_traces = ComboTSO.Traces;
    new_traces = cell(ComboTSO.Ntraces,1);
    new_traces(1:counter) = old_traces;
    for i = 1:TSO_addon.Ntraces
        counter = counter + 1;
        new_traces{counter} = TSO_addon.Traces{i};
    end
    ComboTSO.Traces = new_traces;

end