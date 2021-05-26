function New_MCMCData = merge_MCMC_repeats(MCMCData_1, MCMCData_2)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: When we have two separate cell arrays of
    %"MCMC_Info" objects--each of which holds all of the MCMC data from an
    %independent parallel tempering MCMC super-chain--this function merges
    %the data from cells 1 and 1, 2 and 2, etc., to form a single cell
    %array of MCMC data. This is used when we are collecting MCMC data from
    %multiple super-chains in parallel for convergence testing, but then we
    %want to collect additional steps for each parallel copy of the chain.
    %These additional steps are a continuation of each original
    %super-chain, but they have been saved out in a separate cell array for
    %convenience. This function stitches the two pieces of each parallel
    %copy back toether.  Should not be confused with
    %combine_MCMCoutputs_fromparallelcopies, which is used when we want to
    %combine the data from the super chains run in parallel into a SINGLE
    %set of outputs, to be analyzed as one. 
    %
    %~~~INPUTS~~~:
    %
    %MCMCData_1/2: the two different cell arrays, of the same length, each
    %   of which contains a set of MCMC_Info objects, one for each parallel
    %   copy of the MCMC super-chain. 
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %New_MCMCData: a new cell array in which the first cell contains the
    %   combined outputs from the first cells of MCMCData_1 and MCMCData_2,
    %   etc.
    
    
    %If the first set of data is empty, just return the second set of data.
    %This simplifies things in the first loop iteration, where there is no
    %previous data to add on to!
    if isempty(MCMCData_1)
        New_MCMCData = MCMCData_2;
        return
    end

    %Number of parallel copies MCMC copies run within each MCMC run
    nParallel = length(MCMCData_1);
    
    %Get # of temperatures and # of nodes for each chain
    nTemps = length(MCMCData_1{1}.NodeFreqs);
    nNodes = length(MCMCData_1{1}.NodeFreqs{1});
    
    %Get the total number of steps from BOTH runs combined
    nSteps1 = length(MCMCData_1{1}.StepsAccepted{1});
    nSteps2 = length(MCMCData_2{1}.StepsAccepted{1});
    nStepsTot = nSteps1 + nSteps2;
    
    %See if KeepAllData was on (assume same setting for both runs)
    KeepStepOccupancy = MCMCData_1{1}.KeepStepOccupancy;
    
    %Create new cell array of objects to hold combined data
    New_MCMCData = cell(nParallel,1);
    for i = 1:nParallel
        New_MCMCData{i} = MCMC_Info(nTemps,nNodes,nStepsTot,KeepStepOccupancy);
    end
    
    %Now we can fill in the info from both runs in the new combined object
    for i = 1:nParallel
        for j = 1:nTemps
            %Add together # of steps accepted and rejected
            New_MCMCData{i}.AcceptedAndRejected{j} = ...
                MCMCData_1{i}.AcceptedAndRejected{j} + ...
                MCMCData_2{i}.AcceptedAndRejected{j};
            
            %Add together node freqs
            New_MCMCData{i}.NodeFreqs{j} = MCMCData_1{i}.NodeFreqs{j} + ...
                MCMCData_2{i}.NodeFreqs{j};   
            
            %Concatenate each step acceptance
            New_MCMCData{i}.StepsAccepted{j}(1:nSteps1) = ...
                MCMCData_1{i}.StepsAccepted{j};
            New_MCMCData{i}.StepsAccepted{j}(nSteps1+1:nSteps1+nSteps2) = ...
                MCMCData_2{i}.StepsAccepted{j};   
        end
        
        %Fill in node occupancy data, if it exists
        if KeepStepOccupancy
            New_MCMCData{i}.OccupanciesByStep(:,:,1:nSteps1) = ...
                MCMCData_1{i}.OccupanciesByStep;
            New_MCMCData{i}.OccupanciesByStep(:,:,1+nSteps1:nSteps1+nSteps2) = ...
                MCMCData_2{i}.OccupanciesByStep;
        end
        
        %Concatenate AllWeights data
        New_MCMCData{i}.AllWeights(1:nSteps1,:) = MCMCData_1{i}.AllWeights;
        New_MCMCData{i}.AllWeights(1+nSteps1:nSteps1+nSteps2,:) = ...
            MCMCData_2{i}.AllWeights;
    end

end