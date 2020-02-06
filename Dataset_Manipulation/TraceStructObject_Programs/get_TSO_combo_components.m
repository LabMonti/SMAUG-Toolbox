function TSOList = get_TSO_combo_components(ComboTSO)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: takes a combination Trace struct object (TSO) 
    %and splits it up into separate TSOs for each individual block of data
    %that was originally merged together
    %
    %~~~INPUTS~~~:
    %
    %ComboStruct: a combination trace struct object consisting of two of 
    %   more blocks of data that have been merged together
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %TSOList: a cell array containing separate trace strub objects for each
    %   original block of data from the ComboTSO


    Ncombo = ComboTSO.Ncombo;
    TSOList = cell(Ncombo, 1);
    
    %Loop through and make new stand-along structures for each section from
    %the combo structure:
    trace_count = 0;
    for i = 1:Ncombo
        
        %Make new stand-alone trace structure
        TS = struct();
        
        %Add fields from component properties:
        TS.ChopMethod = ComboTSO.ComponentProperties.ChopMethods{i};
        TS.name = ComboTSO.ComponentProperties.names{i};
        TS.file_made_by = ComboTSO.ComponentProperties.files_made_by{i};
        TS.date_made = ComboTSO.ComponentProperties.dates_made{i};
        TS.Format = ComboTSO.ComponentProperties.Formats{i};
        TS.NoiseFloor = ComboTSO.ComponentProperties.NoiseFloors{i};
        TS.attenuation_ratio = ComboTSO.ComponentProperties.attenuation_ratios{i};
        TS.NumTotalPoints = ComboTSO.ComponentProperties.NumsTotalPoints{i};
        TS.PauseNumbers = ComboTSO.ComponentProperties.PauseNumbers{i};
        TS.CalibrationDriftCorrection = ComboTSO.ComponentProperties.CalibrationDriftCorrection{i};
        TS.Ref_NoiseFloor_Voltage = ComboTSO.ComponentProperties.Ref_NoiseFloor_Voltage{i};
        
        %Get # of traces:
        TS.Ntraces = ComboTSO.Ntraces_components(i);
        
        %Get each per_traceField if it exists:
        for j = 1:length(ComboTSO.per_traceFields)
            name_of_field = ComboTSO.per_traceFields{j};
            if ~isempty(ComboTSO.(name_of_field))
                TS.(name_of_field) = ComboTSO.(name_of_field)(trace_count+1:trace_count+TS.Ntraces);
            end
        end       
        
        %Add the traces! (And update cumulative total of traces seen)
        TS.Traces = cell(TS.Ntraces, 1);
        for j = 1:TS.Ntraces
            trace_count = trace_count + 1;
            %%%TS.(strcat('Trace',num2str(j))) = ComboStruct.(strcat('Trace',num2str(trace_count)));
            TS.Traces{j} = ComboTSO.Traces{trace_count};
        end
        
        %Add stand-alone trace struct object to the list
        TSOList{i} = LoadTraceStruct(TS);
        
    end

end