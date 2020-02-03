function new_folder_location = CreateClusterOutputFolder(new_folder_name, optional_parent)

    %Adding an empty string to a path does nothing
    if nargin < 2
        optional_parent = '';
    end
    
    %Get path to ClusteringOutputData (and maybe sub-folder within it)
    path_stem = GetAbsolutePath('ClusteringOutputData',optional_parent);
    
    %Make new directory in that location with requested name
    mkdir(path_stem, new_folder_name);
    
    %Return the path of the directory just created
    new_folder_location = fullfile(path_stem, new_folder_name);

end