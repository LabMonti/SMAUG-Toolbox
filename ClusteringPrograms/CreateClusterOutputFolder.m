function new_folder_location = CreateClusterOutputFolder(...
    new_folder_name, optional_parent)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: creates a new directory inside
    %ClusteringOutputData (and possibly inside a sub-directory as well)
    %
    %~~~INPUTS~~~:
    %
    %new_folder_name: the name of the new folder to be created
    %
    %optional_parent: optionally include the name of a folder inside
    %   ClusteringOutputData in which to create the new folder
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %new_folder_location: full path to the newly created folder
    
    
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