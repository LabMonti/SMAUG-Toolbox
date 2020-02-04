%NDB 03May19: Reads in the dataset library from the csv file in this folder
%and constructs a cell array to store this library information
function dataset_library = build_library()

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