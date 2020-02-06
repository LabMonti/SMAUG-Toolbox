function TraceStruct = import_dataset(id_info)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: allows the user to specify a file name or
    %library ID# instead of passing in an actual trace structure
    %
    %~~~INPUTS~~~:
    %
    %id_info: either the name of a .mat file containing a single trace
    %   structure (.mat extension is optional) or the ID# of a dataset
    %   included in the dataset library
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %  
    %TraceStruct: the trace structure corresponding to the id information
    %   passed in by the user


    %First let's check if the id info is the name of a dataset in the
    %DataSets directory
    if ischar(id_info)
        
        %User can choose to include the ".mat" part of the file name or not
        n = length(id_info);
        if ~strcmp(id_info(n-3:n),'.mat')
            id_info = strcat(id_info,'.mat');
        end
        
        %Try to load in the dataset
        TraceStruct = importdata(id_info);
        
    %Next let's check if the id info is the ID # of a dataset in the
    %dataset library
    elseif isnumeric(id_info)
        
        if max(size(id_info)) > 1
            error('Unrecognized TraceStruct identifier type');
        end
        
        lib = build_library();
        TraceStruct = load_library_entry(lib,id_info);
        
    else
        error('Unrecognized TraceStruct identifier type');
    end

end