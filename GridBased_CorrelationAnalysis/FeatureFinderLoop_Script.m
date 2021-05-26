%Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
%licensed under the Creative Commons Attribution-NonCommercial 4.0 
%International License. To view a copy of this license, visit 
%http://creativecommons.org/licenses/by-nc/4.0/.  
%
%This is an example of a script that can be used to run the MCMC
%feature-finder on multiple datasets with the same parameters for each.
%Using a script like this is the best way to run the
%batchMCMC_ProcessAndSave function on a computing cluster. 

%List of datasets to run; these ID#s refer to the dataset library included
%in SMAUG
datasetIDs = [1,2,2];

%Where we want to save the output data to
output_location = '.';

%If we want to only use a subset of traces from each dataset (or multiple
%subsets from the same dataset), we can specify that with this traceBounds
%cell array. Leave a cell empty to use that entire dataset. In this example
%we are using the entire dataset from dataset ID#1, and two different
%subsets from dataset ID#2 (notice that 2 is listed twice in the datasetIDs
%vector)
traceBounds = cell(length(datasetIDs),1);
traceBounds{2} = [1 1000];
traceBounds{3} = [1001 2000];

%Here we set parameter values we want to use for processing the datasets.
%Any parameters we don't define here will be set to their default values.
%We find that setting parameters explicitly in a script like this is the
%best way to keep track of which parameters were used to process which
%datasets. 
InputParams.gridsX = 25;
InputParams.gridsY = 10;
InputParams.left_chop = -0.05;
InputParams.sequence_length = 12;
InputParams.criteriaType = 'RangeSlope';
InputParams.CriteriaParams = struct();
InputParams.CriteriaParams.minSlope = -1;
InputParams.CriteriaParams.maxSlope = 1;
InputParams.ConvergenceCriteria = struct();
InputParams.ConvergenceCriteria.max_Rhat = 1.1;
InputParams.ConvergenceCriteria.strict_Rhat = 1.05;
InputParams.nCopies = 3;
InputParams.BurnInSteps = 600000;
InputParams.nSteps = 600000;
InputParams.MaxRepeats = 10;
InputParams.RelativeTemps = [4/9 5/9 6/9 1 Inf];
InputParams.nCores = 28;
InputParams.remove_lownodetraces = false;
InputParams.remove_danglingnodes = true;

%Run the MCMC feature-finder on each dataset
batchMCMC_ProcessAndSave(datasetIDs,InputParams,traceBounds,output_location);