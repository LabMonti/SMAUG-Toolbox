function RUN_ME()

    %Add all folder and sub-folders in the packaged to the file path
    current_location = pwd;
    addpath(genpath(current_location));
    
    %Remove the ClusteringRuns folder from the path (because we want each
    %run to use a different version of the RunSOPTICS script)
    rmpath(genpath('ClusteringRuns'));
    
    %Remove all temporary/in-development folders from the path so that 
    %there is no confusion in accidentally running something that is
    %not in a completed form yet
    rmpath(genpath('InDevelopment_OrTemporary'));

end
