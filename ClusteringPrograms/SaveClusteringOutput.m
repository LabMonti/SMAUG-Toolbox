function SaveClusteringOutput(OutputStruct, Output_Location, output_tag)

    output_name = strcat('ClustOut_',output_tag,'.mat');
    save(fullfile(Output_Location,output_name),'OutputStruct'); 
    display(strcat('Output saved in: "',Output_Location));

end