%Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
%licensed under the Creative Commons Attribution-NonCommercial 4.0 
%International License. To view a copy of this license, visit 
%http://creativecommons.org/licenses/by-nc/4.0/.  
%
%This is an example of a script that can be used to run the MCMC
%feature-finder on a single dataset so that the outputs are saved instead 
%of returned to the workspace. Using a script like this is the best way to
%run the standardMCMC_withPreProcess function on a computing cluster. 

%First we need to load in the dataset we are going to be using; this could
%be done using the dataset library feature in SMAUG, but it doesn't have to
%be. We should also provide this dataset with a name. 
TraceStruct = importdata('~/SMAUG-Toolbox/DataSets/Simulated_1p25%feature.mat');
name = 'SimulatedData_1p25%feature';

%Where we want to save the output data to
output_location = '.';

%If we want to only use a subset of traces, we can specify that range of
%traces we want to use in this traceBounds vector. In this example,
%however, we will leave traceBounds as an empty vector, indicating that we
%want to use the entire dataset. 
traceBounds = [];

%Here we set parameter values we want to use for processing the dataset.
%Any parameters we don't define here will be set to their default values.
%We find that setting parameters explicitly in a script like this is the
%best way to keep track of which parameters were used. 
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

%Run the MCMC feature finder, and save the modified input parameters
standardMCMC_withPreProcess(TraceStruct,name,output_location,...
    traceBounds,InputParams);
save(fullfile(output_location,'InputParameters.mat'),'InputParams');
