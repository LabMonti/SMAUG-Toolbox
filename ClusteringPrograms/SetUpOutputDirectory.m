%NDB 29Jun18: This function appends the date and time to the given output
%tag, creates a new directory with that name in the ClusteringOutput
%folder, and puts a copy of the input file in the new output directory
function [Output_Location, output_tag] = SetUpOutputDirectory(output_tag,...
    running_folder, input_file_path)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: This function appends the date and time to the
    %given output tag, creates a new directory with that name in the
    %ClusteringOutput folder, and puts a copy of the input file in the new
    %output directory
    %
    %~~~INPUTS~~~:
    %
    %output_tag: an identifying character string that will be appended to
    %   the output and its folder
    %
    %running_folder: the folder where the clustering function was run
    %
    %input_file_path: the path for where the clustering function was run
    %   from, including the file itself (but not the extension
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %Output_Location: the path of the new output directory created by this
    %   function
    %
    %output_tag: that output tag that was used
    
    
    %In default case, use running folder as output_tag
    if strcmp(output_tag, 'default')
       output_tag = running_folder;
    end
    
    %Append the date and time to the output_tag
    date_time_tag = GetDateTimeTag();
    output_tag = strcat(date_time_tag,'_',output_tag);

    %Create new directory to store output in:
    Output_Location = CreateClusterOutputFolder(output_tag);
    
    %Copy the input file into the new output directory:
    copyfile(strcat(input_file_path,'.m'), fullfile(Output_Location,...
        strcat('InputUsed_', output_tag,'.m')));

end