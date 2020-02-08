%NDB 29Jun18: This function appends the date and time to the given output
%tag, creates a new directory with that name in the ClusteringOutput
%folder, and puts a copy of the input file in the new output directory
function [Output_Location, output_tag] = SetUpOutputDirectory(output_tag,...
    running_folder, input_file_path)

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