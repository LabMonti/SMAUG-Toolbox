function new_path = GetAbsolutePath(dir_name, optional_parent_name)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: find the full file path to a specific locaiton
    %inside the SMAUG directory structure, and maybe a sub-folder within it
    %
    %~~~INPUTS~~~:
    %
    %dir_name: the name of the directory that we are searching for
    %
    %optional_parent_name: the name of a folder inside dir_name
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %  
    %new_path: the full absolute path to the specified location
    
    
    %The name of the top-level directory for this package
    main_dir_name = {'SMAUG-Toolbox','SMAUG-Toolbox-master'};

    %Get all the pieces of the current path
    path_parts = split(pwd,filesep);
    n = length(path_parts);
    
    %Look in the current path for the top-level package directory
    found_main_dir = false;
    i = n;
    while ~found_main_dir && i >= 1
        
        if any(strcmp(path_parts{i},main_dir_name))
            found_main_dir = true;
            dir_location = i;
        else
            i = i - 1;
        end
    end
    
    %This will only work in a child of the top-level directory!
    if ~found_main_dir
        error(strcat('ERROR: neither "',main_dir_name{1},'" nor "', ...
            main_dir_name{2},'" was not found as a parent directory!'));
    end
    
    %Construct aboslute path to top-level directory:
    if isempty(path_parts{1})
        new_path = fullfile('/',path_parts{2});
        istart = 3;
    else
        new_path = path_parts{1};
        istart = 2;
    end
    for i = istart:dir_location
        new_path = fullfile(new_path, path_parts{i});
    end
    
    %Add the requested sub-directory to the path (possibly with an
    %intermediate directory(s) as well
    if nargin < 2
        new_path = fullfile(new_path, dir_name);
    else
        new_path = fullfile(new_path, optional_parent_name, dir_name);
    end

end