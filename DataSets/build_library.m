function dataset_library = build_library()
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: reads in the dataset library from the dataset 
    %library csv file and constructs a structure to store this library 
    %information
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %dataset_library: a structure containing fields for each column in the
    %   library spreadsheet, with each field then containing a list of the
    %   values in that column for each dataset from the library

    %Read in the library as a table (read in our library if it exists on
    %the path, otherwise read in the example library available publicly on
    %GitHub)
    if exist('Transport_Dataset_Library.csv','file') == 2
        dataset_table = readtable('Transport_Dataset_Library.csv');
    else
        dataset_table = readtable('Example_Dataset_Library.csv');
    end

    %Get the names of each column
    col_names = dataset_table.Properties.VariableNames;
    Ncol = length(col_names);
    
    %Convert the table to a cell array
    dataset_cell = table2cell(dataset_table);
    
    %Build a structure with a field containing a cell-vector for each
    %column of the library
    dataset_library = struct();
    for i = 1:Ncol
        dataset_library.(col_names{i}) = dataset_cell(:,i);        
    end
    
end