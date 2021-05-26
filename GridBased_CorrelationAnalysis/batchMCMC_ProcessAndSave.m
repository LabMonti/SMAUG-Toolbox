function batchMCMC_ProcessAndSave(datasetIDs,InputParameters,...
    optional_traceBounds,output_folder)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: This function is useful for running the MCMC
    %feature-finder on a large set of datasets while using the same 
    %parameters (both for the MCMC and for pre-processing the datasets) for
    %each one. It is especially useful for running on a computing cluster,
    %because instead of making output plots in windows, it saves them to an
    %output folder (along with the output data). Requires a dataset library
    %to have been set up. 
    %
    %~~~INPUTS~~~:
    %
    %datasetIDs: vector of ID#s for a datasets that are listed in a dataset
    %   library
    %
    %InputParameters: a structure with fields name for any parameters
    %   you wish to modify from their standard values. See 
    %   setPreProcessing_and_MCMC_defaults for the default parameters. This
    %   format is used instead of making use of name-value pairs and the
    %   MATLAB input parser so that this function can be easily run from a
    %   script that has a list of parameters hard-coded in, which I find
    %   convenient for keeping track of what runs I have done. 
    %
    %optional_traceBounds: a cell array with one cell for each dataset ID#.
    %   If you wish to use a dataset subset instead of the entire subset,
    %   then the cell for that subset should include a 2x1 vector listing
    %   the starting and ending traces for the subset you wich to use. If
    %   you want to use an entire dataset, the cell for that dataset can
    %   just be blank (this is also the default). 
    %
    %output_folder: the location where plots and output data will be saved.
    %   Default is current folder. 
    
    
    %Set default inputs
    N = length(datasetIDs);
    if nargin < 2
        InputParameters = struct();
    end
    if nargin < 3
        optional_traceBounds = cell(N,1);
    end
    if nargin < 4
        output_folder = '.';
    end
  
    %Build library
    lib = build_library();    
    
    %Create arrays to hold info on each dataset
    names = cell(N,1);
    nTracesRemoved = zeros(N,1);   
    
    %Loop over each dataset
    for i = 1:N
        
        %Load dataset
        name = create_name_for_library_entry(lib,datasetIDs(i));     
        T = load_library_entry(lib,datasetIDs(i));
        
        %Run the MCMC and pre-processing on the dataset; saving will be
        %done within this function, we just the final name and # of traces
        %removed back
        [names{i},nTracesRemoved(i)] = standardMCMC_withPreProcess(T,...
            name,output_folder,optional_traceBounds{i},InputParameters);
    end

    %Save name and # of traces removed info about each dataset, as well as
    %the set of input parameters that were used for processing all of the
    %datasets
    save(fullfile(output_folder,'names.mat'),'names');
    save(fullfile(output_folder,'nTracesRemoved.mat'),'nTracesRemoved'); 
    save(fullfile(output_folder,'InputParameters.mat'),'InputParameters');

end