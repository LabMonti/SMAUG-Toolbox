function RUN_ME()
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Adds all relevant folders in the SMAUG package
    %to the MATLAB path so that functions can be called from all of them
   
    
    %Add all folder and sub-folders in the package to the file path
    current_location = pwd;
    addpath(genpath(current_location));
    
    %Remove all temporary/in-development/obsolete folders from the path so 
    %there is no confusion in accidentally running something that is
    %not in a completed form yet (only applicable for the LabMonti
    %"in-house" version, not for the public version)
    rmpath(genpath(fullfile('SMAUG-Development',...
        'InDevelopment_OrTemporary')));
    rmpath(genpath(fullfile('SMAUG-Development','Obsolete')));

end
