%NDB 07May19: Loads a single trace structure listed in the dataset library
%given its ID number
function TraceStruct = load_library_entry(dataset_library, id2load)

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