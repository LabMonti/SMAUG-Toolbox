function new_path = GetAbsolutePath(dir_name, optional_parent_name)

    %The name of the top-level directory for this package
    main_dir_name = 'SingleMoleculeDataAnalysisToolBox';

    %Get all the pieces of the current path
    path_parts = split(pwd,filesep);
    n = length(path_parts);
    
    %Look in the current path for the top-level package directory
    found_main_dir = false;
    i = 1;
    while ~found_main_dir && i <= n
        
        if strcmp(path_parts{i},main_dir_name)
            found_main_dir = true;
            dir_location = i;
        else
            i = i + 1;
        end
    end
    
    %This will only work in a child of the top-level directory!
    if ~found_main_dir
        error(strcat('ERROR: "',main_dir_name,'" was not found as a parent directory!'));
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