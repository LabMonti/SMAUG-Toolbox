function IDs = get_matching_library_entry_IDs(dataset_library, field_list, ...
    match_list)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Inputting a list of fields and a corresponding 
    %list of what those fields should match results in this function giving
    %you the ID#s for every library entry meeting those conditions.  For 
    %the moment, different fields are always ANDed together, whereas
    %multiple matches for the same field are ORed together.  
    %
    %~~~INPUTS~~~:
    %
    %dataset_library: a structure containing a dataset "library" created by
    %   build_library.m
    %
    %field_list: a cell array listing the title of each field in the
    %   library that the user wishes to put constraints on
    %
    %match_list: a cell array of cell arrays; the cell array in the nth
    %   positions should contain a list of all acceptable values the the
    %   nth field from field_list can take
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %IDs: vector containing the ID #s of all datasets in the dataset
    %   library that meet the specified conditions

    Ncond = length(field_list);
    Nlib = length(dataset_library.ID);
    
    match_matrix = false(Nlib, Ncond);
    
    for j = 1:Ncond
        
        nMatch = length(match_list{j});
        
        for i = 1:Nlib
            match = false;
            for k = 1:nMatch   
                entry = dataset_library.(field_list{j}){i};
                check = match_list{j}{k};
                
                if isnumeric(entry)
                    match = or(match, entry == check);
                else
                    match = or(match, strcmp(entry, check));
                end
 
            end
            match_matrix(i,j) = match;
        end
    end
    
    match_vector = all(match_matrix,2);
    IDs = find(match_vector);

end