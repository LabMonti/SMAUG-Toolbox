classdef MCMC_Info < handle
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Object Description: each MCMC_Info object holds output data from a
    %parallel-tempering MCMC simulation. An object is used here because
    %this data can take up a lot of space, so this allows us to just pass
    %the object handle between functions rather than duplicating all of
    %this data and taking up a lot of memory. 
  
    properties (SetAccess = public, GetAccess = public)

        AcceptedAndRejected;
        %   a cell array with one cell per temperature used
        %   during parallel tempering. Within each cell is a 7x2 array, with one
        %   row per type of trial step. The first column contains the # of that
        %   type of trial step that were rejected, and the second column
        %   contains the # that were accepted. 
    
        NodeFreqs;
        %   a cell array with one cell per temperature used during
        %   parallel tempering. Within each cell is a vector the length of the
        %   # of different nodes in the dataset, indicating how often each node
        %   was included in a node-sequence in that temperature's MCMC
        %   sub-chain. 
    
        StepsAccepted;
        %   a cell array with one cell per temperature used during
        %   parallel tempering. Within each cell is a logical vector nSteps
        %   long, listing whether or not the trial step (whatever type it
        %   happened to be) was accepted or not at each step of that MCMC
        %   sub-chain.         
        
        OccupanciesByStep;
        %   an nTemps x nNodes x nSteps logical array. Each
        %   element indicates whether or not that node was part of the
        %   node-sequence at that temperature and that step during the MCMC
        %   simulation. This information is needed to compute variances for
        %   convergence testing. 
    
        AllWeights;
        %   an nSteps x nTemps array holding the weigth (also called
        %   the "significance") of the node-sequence at each step for each
        %   temperature
        
        KeepStepOccupancy = false;
        %   whether or not there is data in the OccupanciesByStep field
        %   (needed for convergence testing, but takes up a lot of room, so
        %   can be left out, e.g., for burn-in steps). 
    end
    
    methods
        function obj = MCMC_Info(nTemps, nNodes, nSteps, KeepStepOccupancy)
            
            obj.AcceptedAndRejected = cell(nTemps,1);
            obj.NodeFreqs = cell(nTemps,1);
            obj.StepsAccepted = cell(nTemps,1);           
            for i = 1:nTemps
                obj.AcceptedAndRejected{i} = zeros(7,2);
                obj.NodeFreqs{i} = zeros(nNodes,1);
                obj.StepsAccepted{i} = false(nSteps,1);               
            end
            
            obj.AllWeights = zeros(nSteps,nTemps);
            if KeepStepOccupancy
                obj.KeepStepOccupancy = true;
                obj.OccupanciesByStep = false(nTemps,nNodes,nSteps);
            end           
        end        
    end
end
        