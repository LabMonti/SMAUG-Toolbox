function TraceStruct = load_library_entry(dataset_library, id2load)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Loads a single trace structure listed in the 
    %dataset library given its ID number
    %
    %~~~INPUTS~~~:
    %
    %dataset_library: a structure containing a dataset "library" created by
    %   build_library.m
    %
    %id2load: the integer id# corresponding to a row in the dataset library
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %TraceStruct: a trace structure for the dataset ID specified in the
    %   library
    
    
    %Read in from the LabMonti library
    if isfield(dataset_library,'path_name')
        %Where all the data is located
        base_path = 'D:\Transport_Data';

        %Where the specific file containing the dataset we are looking for is
        %located
        file_path = fullfile(base_path, dataset_library.path_name{id2load},...
            strcat(dataset_library.file_name{id2load},'.mat'));
        
    %Read in from the example library for the public version on GitHub
    else
        file_path = fullfile('DataSets',strcat(...
            dataset_library.file_name{id2load},'.mat'));
    end

    %Load the file
    TraceStruct = importdata(file_path);
    
    %If the file contains multiple trace structures, select just the one we
    %want (only relevant for LabMonti library)
    if isfield(dataset_library,'path_name') && ...
            ~isempty(dataset_library.section_name{id2load})
        TraceStruct = TraceStruct.(dataset_library.section_name{id2load});
    end

end