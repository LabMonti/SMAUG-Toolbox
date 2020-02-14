%Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
%licensed under the Creative Commons Attribution-NonCommercial 4.0 
%International License. To view a copy of this license, visit 
%http://creativecommons.org/licenses/by-nc/4.0/.  
%
%Script Description: This script is used to perform clustering runs on a
%computational cluster running a PBS queing system.  It is submitted by
%ExamplePBS_ClusteringScript.pbs, in the directory above


%The user can change these values to match the type of run they wish to
%perform on a cluster
Dataset_ID = 1;
nCores = 28;

%Get requested dataset and create a name for it
lib = build_library();
T = load_library_entry(lib,Dataset_ID);
name = create_name_for_library_entry(lib,Dataset_ID);

%Run the clustering
EasySegmentClustering(T,name,true,nCores);