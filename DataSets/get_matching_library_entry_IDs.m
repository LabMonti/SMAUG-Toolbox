%NDB 07May19: Inputting a list of fields and a corresponding list of what
%those fields should match results in this function giving you the ID#s for
%every library entry meeting those conditions.  For the moment, different
%fields are always ANDed together, whereas multiple matches for the same
%field are ORed together.  
function IDs = get_matching_library_entry_IDs(dataset_library, field_list, ...
    match_list)

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