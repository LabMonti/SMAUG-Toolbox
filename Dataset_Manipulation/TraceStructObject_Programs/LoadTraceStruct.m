%Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
%licensed under the Creative Commons Attribution-NonCommercial 4.0 
%International License. To view a copy of this license, visit 
%http://creativecommons.org/licenses/by-nc/4.0/.  

%A class of object that can "load in" a TraceStruct, store
%its information, and supply that information upon request.  The advantages
%of using an object for this instead of just the original TraceStruct is
%that I can now change default values and/or add new options in a single
%place instead of throughout my programs
classdef LoadTraceStruct < handle
    
    properties (SetAccess = public, GetAccess = public)
        %Property that identifies this object as a loaded trace structure:
        isLoaded = true;        
        
        %The TraceStruct MUST have a "Traces" field
        Traces;
        
        %These fields can be deduced even if they don't exist
        Ntraces;
        NumTotalPoints;
        
        %These fields should really be included, but if not they can be set
        %to default values
        Format = 'ConductanceTraces';
        ChopMethod = 'unknown';
        date_made = 'unkonwn';
        attenuation_ratio = NaN;
        file_made_by = 'unknown';
        name = 'unknown';  
        NoiseFloor = 1E-6;
        CalibrationDriftCorrection = false;
        Ref_NoiseFloor_Voltage = NaN;
        
        %These fields may or may not exist; if not, they are set to empty
        %arrays by defuault
        PauseNumbers = [];
        
        %These fields are all similar in that each (if it existed) would be
        %a vector with one element per each trace.  Thus a list of their
        %names is kept so that they can all be treated the same by later
        %programs
        per_traceFields = {'MotorPositions','LabViewTraceNums',...
            'MotorStepsBefore','FormingTunnelingSlopes'};
        MotorPositions = [];
        LabViewTraceNums = [];
        MotorStepsBefore = [];
        FormingTunnelingSlopes = [];
        
        %These fields will usually be assumed to be these default values,
        %but can be included in TraceStruct too
        x_units = 'nm';
        y_units = 'G_0';
        x_Log = 0;
        y_Log = 1;
        
        %These fields are only needed for combos; by default they are set
        %to null values
        combo = 'no';
        Ncombo = NaN;
        Ntraces_components = [];
        ComponentProperties = [];
        
        %A holder for additional fields found in the TraceStruct;
        other_fields = struct();
        
    end  
    
    methods
        
        function obj = LoadTraceStruct(TraceStruct)
            
            %If the trace structure passed in is ALREADY loaded, just
            %return it unchanged
            if isobject(TraceStruct) && TraceStruct.isLoaded
                obj = TraceStruct;
            %Otherwise, load in trace structure
            else
            
                %User can pass a file name or a library ID number instead
                %of the TraceStruct itself
                if ~isstruct(TraceStruct)
                    TraceStruct = import_dataset(TraceStruct);
                end
                
                %Save traces:
                if isfield(TraceStruct,'Traces')
                    obj.Traces = TraceStruct.Traces;
                %To make this backwards compatible with old style of
                %TraceStructs (convert them to new style before continuing)
                elseif isfield(TraceStruct,'Trace1')
                    TraceStruct = Convert_OldStyle_To_NewStyle(TraceStruct);
                    obj.Traces = TraceStruct.Traces;
                else
                    error('TraceStruct has no defined traces, cannot be loaded!');
                end

                %Save number of traces and number of points:
                if isfield(TraceStruct,'Ntraces')
                    obj.Ntraces = TraceStruct.Ntraces;
                else
                    obj.Ntraces = length(obj.Traces);
                    TraceStruct.Ntraces = obj.Ntraces;
                end
                if isfield(TraceStruct,'NumTotalPoints')
                    obj.NumTotalPoints = TraceStruct.NumTotalPoints;
                else
                    obj.NumTotalPoints = getNumPoints(TraceStruct);
                end

                %Save the attenuation ratio; it may be in the TraceStruct as
                %either attenuation_ratio or distance_conversion_used:
                if isfield(TraceStruct,'attenuation_ratio')
                    obj.attenuation_ratio = TraceStruct.attenuation_ratio;
                elseif isfield(TraceStruct,'distance_conversion_used')
                    obj.attenuation_ratio = TraceStruct.distance_conversion_used/1000;
                end

                %Save the noise floor; if it seems to be in log space, convert
                %it to linear space
                if isfield(TraceStruct,'NoiseFloor')
                    obj.NoiseFloor = TraceStruct.NoiseFloor;
                end
                %If the noise floor is negative, it must be in log space
                if obj.NoiseFloor < 0
                    obj.NoiseFloor = 10^obj.NoiseFloor; 
                end

                %For backwards compatibility: if Component properties
                %contains distance_conversions_used, replace with
                %attenuation_ratios (needs to happen before component
                %properties are loaded into object)
                if isfield(TraceStruct,'ComponentProperties')
                    if isfield(TraceStruct.ComponentProperties, 'distance_conversions_used')
                        TraceStruct.ComponentProperties.attenuation_ratios = cell(1, TraceStruct.Ncombo);
                        for i = 1:TraceStruct.Ncombo
                            TraceStruct.ComponentProperties.attenuation_ratios{i} = ...
                                TraceStruct.ComponentProperties.distance_conversions_used{i}/1000;
                        end
                        %Remove the distance_conversions_used field now
                        %that we've replaced it with the attenuation_ratios
                        %field so as not to cause problems down the line
                        TraceStruct.ComponentProperties = rmfield(...
                            TraceStruct.ComponentProperties,'distance_conversions_used');
                    end
                end                
                
                %Save any additional expected fields from TraceStruct if they
                %exist (otherwise they will be left at default values):
                possible_fields = {'Format','ChopMethod','date_made','file_made_by',...
                    'name','PauseNumbers','x_units','y_units','combo',...
                    'Ncombo','Ntraces_components','ComponentProperties',...
                    'x_Log','y_Log','CalibrationDriftCorrection','Ref_NoiseFloor_Voltage'};
                possible_fields = [possible_fields, obj.per_traceFields];
                for i = 1:length(possible_fields)
                    if isfield(TraceStruct,possible_fields{i})
                        obj.(possible_fields{i}) = TraceStruct.(possible_fields{i});
                    end
                end

                %Other fields that have already been dealt with
                other_expected_fields = {'Traces','Ntraces','NumTotalPoints',...
                    'NoiseFloor','attenuation_ratio','distance_conversion_used'};

                %Store any other fields:
                all_fn = fieldnames(TraceStruct);
                ignore_fields = [possible_fields, other_expected_fields];
                for i = 1:length(all_fn)

                    %Check if this field has already been dealt with or not:
                    new = true;
                    for j = 1:length(ignore_fields)
                        if strcmp(all_fn{i},ignore_fields{j})
                            new = false;
                        end
                    end

                    %If the field was not already dealt with, add it to the
                    %other fields:
                    if new
                        obj.other_fields.(all_fn{i}) = TraceStruct.(all_fn{i});
                    end

                end
            end

        end
        
        %Allows user to convert the "space" each trace is stored in, for
        %both dimensions (i.e. Linear in x, Logarithmic in y, Linear in
        %both, etc.)
        function convertTraces(obj, x_Log, y_Log)
            
            %If user used character input, convert to logical style
            if strcmp(x_Log,'Log')
                x_Log = 1;
            elseif strcmp(x_Log,'Lin')
                x_Log = 0;
            end
            if strcmp(y_Log,'Log')
                y_Log = 1;
            elseif strcmp(y_Log,'Lin')
                y_Log = 0;
            end            
            
            %For both x and y, should the traces be left alone (0),
            %converted to log space (1), or converted back to linear space
            %(-1)?
            convert = [0, 0];
            desired = [x_Log, y_Log];
            actual = [obj.x_Log, obj.y_Log];
            for i = 1:2
                if desired(i) == actual(i)
                    convert(i) = 0;
                else
                    if desired(i)
                        convert(i) = 1;
                    else
                        convert(i) = -1;
                    end
                end
            end
            
            %Go through all traces and convert x- and y-values if necessary:
            for i = 1:2
                if convert(i) == 1
                    for j = 1:obj.Ntraces
                        obj.Traces{j}(:,i) = log10(obj.Traces{j}(:,i));
                    end
                elseif convert(i) == -1
                    for j = 1:obj.Ntraces
                        obj.Traces{j}(:,i) = 10.^obj.Traces{j}(:,i);
                    end                    
                end
            end
            
            %Update format of traces in the object:
            obj.x_Log = x_Log;
            obj.y_Log = y_Log;

        end
        
        function AllData = getAllData(obj, type, StartTrace, EndTrace)
            %type should be equal to "distance", "conductance", or "both"
            %(or the starts of any of those words)
            
            if nargin < 4
                EndTrace = obj.Ntraces;
            end
            if nargin < 3
                StartTrace = 1;
            end
            if nargin < 2
                type = 'both';
            end
            
            if startsWith(type,'d')
                column = 1;
                dim = 1;
            elseif startsWith(type,'c')
                column = 2;
                dim = 1;
            elseif startsWith(type,'b')
                column = [1 2];
                dim = [1 2];
            else
                error('Unrecognized data type');
            end
            
            AllData = zeros(obj.NumTotalPoints, length(column));
            counter = 0;
            for i = StartTrace:EndTrace
                tr = obj.Traces{i};
                n = size(tr,1);
                AllData(counter+1:counter+n,dim) = tr(:,column);
                counter = counter + n;
            end
            AllData = AllData(1:counter,:);
            
        end
        
        %Remove portion of each trace before it passes below a certain
        %conductance level for the last time
        function chopAtConductanceCeiling(obj, CondCeiling)
            %Note: CondCeiling is assummed to be in the same units as the
            %traces are currenlty in!
            obj.Traces = choptraces_aboveCondValue(obj.Traces, CondCeiling, 0);
            
            %If any traces got completely (or almost completely) chopped
            %off, we need to remove them
            removeIDs = zeros(floor(obj.Ntraces/10),1);
            counter = 0;
            for i = 1:obj.Ntraces
                if size(obj.Traces{i},1) < 2
                    counter = counter + 1;
                    removeIDs(counter) = i;
                end
            end
            if counter > 0
                removeIDs = removeIDs(1:counter);
                obj.removeTraces(removeIDs);
                disp(strcat(num2str(counter),' traces removed due to top chop'));
            end
                
        end
        
        %Remove portion of each trace before (left of) a given distance
        %value. Optionally remove traces that start to the right of the given
        %distance.  
        function apply_LeftChop(obj, leftchop, remove_traces)
            if nargin < 3
                remove_traces = false;
            end
            
            %Save some time if leftchop was set to -Inf, implying no left
            %chop is requested
            if leftchop ~= -Inf
                
                do_not_reach = false(obj.Ntraces,1);
                for i = 1:obj.Ntraces
                    tr = obj.Traces{i};
                    if tr(1,1) > leftchop
                        %If the trace starts AFTER the leftchop we may want
                        %to remove it
                        do_not_reach(i) = true;
                    else
                        %Otherwise, remove portion of trace from before the
                        %leftchop and re-save it
                        tr = tr(tr(:,1) >= leftchop, :);
                        obj.Traces{i} = tr;
                    end                
                end
                
                %If requested, remove traces that do not reach back as far
                %as the left chop
                if remove_traces && sum(do_not_reach) > 0
                    removeIDs = find(do_not_reach);
                    obj.removeTraces(removeIDs);
                    disp(strcat(num2str(sum(do_not_reach)), ...
                        ' traces removed for starting after left-chop'));
                end
                
                %Re-calculate total # of datapoints
                obj.NumTotalPoints = getNumPoints(obj);
            end
        end
        
        %Remove specified traces from trace structure, and update other
        %data accordingly.
        function removeTraces(obj, TraceIDs)
            if strcmp(obj.combo,'yes')
                %Break the combo up into sections:
                TSOlist = get_TSO_combo_components(obj);
                sectionIDs = assign_traceIDs_to_components(obj.Ntraces_components,...
                    TraceIDs);
                
                %Remove traces from each section
                for i = 1:length(TSOlist)
                    TSOlist{i}.removeTraces(sectionIDs{i});
                end
                
                %Now put the sections back together
                NewTSO = combine_TSOs(TSOlist,obj.name);
                obj.replace_all_properties(NewTSO);
            else
                %Get logical array of traces to keep
                keep = true(obj.Ntraces,1);
                keep(TraceIDs) = false;
                
                %Update traces, trace lab view numbers, and motor positions
                obj.Traces = obj.Traces(keep);
                if ~isempty(obj.LabViewTraceNums)
                    obj.LabViewTraceNums = obj.LabViewTraceNums(keep);
                end
                if ~isempty(obj.MotorPositions)
                    obj.MotorPositions = obj.MotorPositions(keep);
                end
                if ~isempty(obj.MotorStepsBefore)
                    obj.MotorStepsBefore = obj.MotorStepsBefore(keep);
                end
                
                %Update number of traces
                obj.Ntraces = sum(keep);
                
                %Update pause numbers:
                TraceIDs = sort(TraceIDs,'descend'); %We need to go from highest to lowest,
                %b/c hard to explain
                for i = 1:length(obj.PauseNumbers)
                    for j = 1:length(TraceIDs)
                        if obj.PauseNumbers(i) > TraceIDs(j)
                            obj.PauseNumbers(i) = obj.PauseNumbers(i) - 1;
                        end
                    end
                end
                
                %Update total number of points
                obj.NumTotalPoints = getNumPoints(obj);
            end
        end
        
        %Chop off the "tails" that we see at the beginning of traces where
        %the conductance initially rises (we still don't understand why).
        %Do this by removing all points that occur before the maximum
        %conductance.
        function remove_initial_rise(obj)
            
            NP_Total = 0;
            for i = 1:obj.Ntraces
                %Find index of maximum conductance
                tr = obj.Traces{i};
                n = size(tr,1);
                [~, maxI] = max(tr(:,2));
                
                %Trim trace
                tr = tr(maxI:n,:);
                
                %Over-write trace and update total points
                obj.Traces{i} = tr;
                NP_Total = NP_Total + (n - maxI + 1);
            end
            obj.NumTotalPoints = NP_Total;
            
        end
        
        %Chop each trace the FIRST time it passes below the noise floor
        function convert_to_ChopFirstCross(obj)
            chop_TSO_first_cross(obj);
        end
        
        %Raise Noise Floor and re-chop traces accordingly
        function RaiseNoiseFloor(obj, new_floor)
            raise_noise_floor(obj,new_floor);
        end
        
        %Removes any trace that never passes below the conductance value
        %"conductance" (NOT in log space!!!)
        function RemoveTracesThatDoNotReach(obj, conductance)
            
            %Split up combos
            components = obj.get_combo_components();
            n_comp = length(components);
            
            %For each component, remove the traces that do not reach below
            %the conductance value
            for i = 1:n_comp
                components{i}.remove_donotreach_traces(conductance);
            end
            
            %Now, recombine the traces and replace obj with that combo
            new_obj = combine_TSOs(components, obj.name);
            obj.replace_all_properties(new_obj);            
            
        end
        
        %Merge new structure onto end of current structure to create a
        %combo of two
        function merge_withStruct(obj, TrStrObj)
            
            %Make sure TrStrObj is really an object, if not load it in
            if ~isobject(TrStrObj)
                TrStrObj = LoadTraceStruct(TrStrObj);
            end
            
            %Merge TrStrObj onto the back end of the original trace struct
            %object to create a combo
            merge_two_TSOs(obj, TrStrObj);
          
        end
        
        %Append new structure onto end of combo
        function append_Struct(obj, TrStrObj)
            
            %Make sure TrStrObj is really an object, if not load it in
            if ~isobject(TrStrObj)
                TrStrObj = LoadTraceStruct(TrStrObj);
            end     
            
            %Make sure obj is already a combo:
            if ~strcmp(obj.combo, 'yes')
                error('append can only be used on a trace struct object that is already a combo, for a non-combo use merge');
            end
            
            %Append TrStrObj to obj
            append_TSO(obj, TrStrObj);
        end
        
        %Return a cell array of all components that were combined together
        %if it's a combo
        function component_list = get_combo_components(obj)
            
            if strcmp(obj.combo, 'no')
                component_list = {obj};
            elseif strcmp(obj.combo, 'yes')
                component_list = get_TSO_combo_components(obj);
            else
                error('Unrecognized value for obj.combo');
            end
            
        end
        
        %Return one or more subsections
        function SubSection_TSO = get_subsections(obj, SectionsBounds)
            SubSection_TSO = get_TSO_subsections(obj, SectionsBounds);
        end
        
        %Return a single subsection not from a combo
        function SS_obj = get_simple_subsection(obj, StartTrace, EndTrace)
            
            if strcmp(obj.combo, 'yes')
                error('This method only works on non-combos, for combos use get_subsections');
            end
            
            SS_obj = get_simple_TSO_subsection(obj, StartTrace, EndTrace);
            
        end   

    end
    
    methods (Access = private)
        
        function remove_donotreach_traces(obj, conductance)         
            remove_incomplete_traces(obj, conductance); 
        end
        
        %Replace all properties with properties of "new" trace struct
        %object
        function replace_all_properties(obj, replacement_obj)
            props = properties(replacement_obj);
            n_props = length(props);
            for i = 1:n_props
                obj.(props{i}) = replacement_obj.(props{i});
            end
        end
        
    end
    
end