function ComboTSO = combine_TSOs(TSOList, ComboName)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Makes a combination trace struct object (TSO)
    %out of a list of TSOs each of which may or may not already be a combo.
    %Not intended for direct call by user.  
    %
    %~~~INPUTS~~~:
    %
    %TSOList: a 1D cell-array containing the list of TSOs to be combined
    %
    %ComboName: the name that will be given to the new trace structure
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %ComboTSO: the new trace structure created by combining the input
    %   structures (still in object form)
    
    
    %Determine total number of different sections in all input structures
    %(so, determine # of components in combos)
    Nsections = 0;
    for i = 1:length(TSOList)
        TS = TSOList{i};
        if strcmp(TS.combo,'yes')
            Nsections = Nsections + TS.Ncombo;
        elseif strcmp(TS.combo, 'no')
            Nsections = Nsections + 1;
        else
            error('Unrecognized combo type');
        end
    end
    
    %Break apart any combos to get a list of raw tracestruct sections
    SectionsToCombine = cell(Nsections,1);
    counter = 0;
    for i = 1:length(TSOList)
        TS = TSOList{i};
        if strcmp(TS.combo,'yes')   
            SectionsList = TS.get_combo_components();
            n = length(SectionsList);
            SectionsToCombine(counter+1:counter+n) = SectionsList;
            counter = counter + n;
        else
            SectionsToCombine{counter+1} = TS;
            counter = counter + 1;
        end
    end
    
    %Set combo equal to the first component
    ComboTSO = SectionsToCombine{1};
    
    %Add second component if applicable
    if Nsections > 1
        ComboTSO.merge_withStruct(SectionsToCombine{2});
    end
    
    %Add third and remaining components if applicable
    for i = 3:Nsections
        ComboTSO.append_Struct(SectionsToCombine{i});
    end
    
    %Add additional information to combo struct:
    ComboTSO.name = ComboName;
    ComboTSO.date_made = date();
    ComboTSO.file_made_by = mfilename();

end