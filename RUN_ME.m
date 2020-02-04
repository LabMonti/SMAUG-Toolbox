function RUN_ME()

    %Add all folder and sub-folders in the package to the file path
    current_location = pwd;
    addpath(genpath(current_location));
    
    %Remove all temporary/in-development folders from the path so that 
    %there is no confusion in accidentally running something that is
    %not in a completed form yet (only applicable for the LabMonti
    %"in-house" version, not for the public version)
    rmpath(genpath(fullfile('SMAUG-Development',...
        'InDevelopment_OrTemporary')));

end
