function SaveClusteringOutput(OutputStruct, Output_Location, output_tag)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Saves clustering output data to a specified
    %location.  Not intended for direct call by user.  
    %
    %~~~INPUTS~~~:
    %
    %OutputStruct: structure containing clustering output data
    %
    %Output_Location: absolute file path to the directory the data should
    %   be saved in
    %output_tag: identifying charater string for use in naming the saved
    %   file
    
    output_name = strcat('ClustOut_',output_tag,'.mat');
    save(fullfile(Output_Location,output_name),'OutputStruct'); 
    display(strcat('Output saved in: "',Output_Location));

end