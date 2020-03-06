%Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
%licensed under the Creative Commons Attribution-NonCommercial 4.0 
%International License. To view a copy of this license, visit 
%http://creativecommons.org/licenses/by-nc/4.0/.  

%Script to run the "standard" segment clustering approach on a list of
%specified datasets

%The ID# of each dataset to be clustered in the dataset library
dataset_library_IDs = [2,3];
N = length(dataset_library_IDs);

%Build dataset library:
dataset_library = build_library();

%Loop over all datasets requested
for i = 1:N
    name = create_name_for_library_entry(dataset_library, dataset_library_IDs(i));
    
    %Load dataset and chop at first cross
    T = load_library_entry(dataset_library, dataset_library_IDs(i));
    
    %Run the clustering
    Standard_SegmentClustering(T,name);
    
end
