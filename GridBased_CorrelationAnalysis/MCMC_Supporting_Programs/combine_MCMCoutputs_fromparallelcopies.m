function [NodeFreqs, OccupanciesByStep, AcceptedAndRejected, StepsAccepted, ...
    AllWeights] = combine_MCMCoutputs_fromparallelcopies(MCMCData)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: When we have run multiple parallel MCMC super-
    %chains, with parallel tempering used with each super-chain, this
    %function takes the outputs from those parallel super-chains and
    %combines them into a single set of outputs to allow them to be
    %analyzed together. This should not be confused with
    %merge_MCMC_repeats, which merges together TWO separate sets of
    %parallel super-chain results into a single set of STILL PARALLEL
    %super-chain results. 
    %
    %~~~INPUTS~~~:
    %
    %MCMCData: a cell array with one cell per parallel copy of the MCMC
    %   super-chain. Within each cell is an "MCMC_Info" object containing
    %   the data collected by that super-chain. 
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %NodeFreqs: a cell array with one cell per temperature used during
    %   parallel tempering. Within each cell is a vector the length of the
    %   # of different nodes in the dataset, indicating how often each node
    %   was included in a node-sequence in that temperature's MCMC
    %   sub-chain. 
    %
    %OccupanciesByStep: an nTemps x nNodes x nSteps logical array. Each
    %   element indicates whether or not that node was part of the
    %   node-sequence at that temperature and that step during the MCMC
    %   simulation. This information is needed to compute variances for
    %   convergence testing. 
    %
    %AcceptedAndRejected: a cell array with one cell per temperature used
    %   during parallel tempering. Within each cell is a 7x2 array, with one
    %   row per type of trial step. The first column contains the # of that
    %   type of trial step that were rejected, and the second column
    %   contains the # that were accepted. 
    %
    %StepsAccepted: a cell array with one cell per temperature used during
    %   parallel tempering. Within each cell is a logical vector nSteps
    %   long, listing whether or not the trial step (whatever type it
    %   happened to be) was accepted or not at each step of that MCMC
    %   sub-chain. 
    %
    %AllWeigths: an nSteps x nTemps array holding the weigth (also called
    %   the "significance") of the node-sequence at each step for each
    %   temperature
    
    
    %Find the number of parallel chains, and the number of temperatures
    %used within each chain
    nParallel = length(MCMCData);
    nTemps = length(MCMCData{1}.NodeFreqs);
    nStepsPerCopy = size(MCMCData{1}.AllWeights,1);
    nNodes = length(MCMCData{1}.NodeFreqs{1});
    
    %Total # of steps
    nSteps = nStepsPerCopy*nParallel;
    
    %Combine NodeFreqs by adding into the first copy's data
    NodeFreqs = MCMCData{1}.NodeFreqs;
    for i = 2:nParallel
        for j = 1:nTemps
            NodeFreqs{j} = NodeFreqs{j} + MCMCData{i}.NodeFreqs{j}; 
        end
    end
    
    %Combine OccupanciesByStep (if they exist)
    if MCMCData{1}.KeepStepOccupancy %(assume all copies have the same value for KeepStepOccupancy)
        OccupanciesByStep = false(nTemps,nNodes,nSteps);
        for i = 1:nParallel
            OccupanciesByStep(:,:,(i-1)*nStepsPerCopy+1:i*nStepsPerCopy) = ...
                MCMCData{i}.OccupanciesByStep(:,:,:);
        end
    else
        OccupanciesByStep = [];
    end
    
    %Combine AcceptedAndRejected by adding into the first copy's data
    AcceptedAndRejected = MCMCData{1}.AcceptedAndRejected;
    for i = 2:nParallel
        for j = 1:nTemps
            AcceptedAndRejected{j} = AcceptedAndRejected{j} + ...
                MCMCData{i}.AcceptedAndRejected{j}; 
        end
    end  
    
    %Combine steps accepted
    StepsAccepted = cell(nTemps,1);
    for j = 1:nTemps
        StepsAccepted{j} = false(nSteps,1);
        for i = 1:nParallel
            StepsAccepted{j}((i-1)*nStepsPerCopy+1:i*nStepsPerCopy) = ...
                MCMCData{i}.StepsAccepted{j};
        end
    end
    clear StepsAcceptanced_in;
    
    %Combine AllWeights
    AllWeights = zeros(nSteps,nTemps);
    for i = 1:nParallel
        AllWeights((i-1)*nStepsPerCopy+1:i*nStepsPerCopy,:) = ...
            MCMCData{i}.AllWeights(:,:);
    end
    clear AllWeights_in;

end