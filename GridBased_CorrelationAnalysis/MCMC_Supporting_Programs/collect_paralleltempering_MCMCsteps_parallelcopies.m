function [StepData, sequences, weights, pool] = ...
    collect_paralleltempering_MCMCsteps_parallelcopies(GCO, ...
    criteriaChecker, criteriaParams, sequences, weights, nStepsPerCopy, ...
    Temperatures, KeepStepOccupancy, pool)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: runs an MCMC simulation, with parallel
    %tempering, for a given number of steps. Moreover, this function
    %actually runs multiple independent copies of that same parallel
    %tempering MCMC simulation so that convergence can later be evaluated
    %by comparing the results of the different independent simulations.
    %
    %~~~INPUTS~~~:
    %
    %GCO: the GridCorrelationObject containing all of the node information
    %   for the dataset that the MCMC simulation is being run on
    %
    %criteriaChecker: function handle for a function that will check
    %   whether a given node-sequence meets whatever criteria the user has
    %   specified (if not the step will automatically be rejected)
    %
    %criteriaParams: structure array containing whatever criteria are
    %   needed for the criteria checker specified by the user
    %
    %sequences: cell array with one cell per independent copy of the entire
    %   MCMC simulation. Within that cell is a sequence_length x nTemps
    %   matrix holding the node ID #s for the nodes in each node-sequence at
    %   each temperature at the MCMC starting point
    %
    %weights: an nCopies x nTemps matrix with each element holding the
    %   weight (i.e. the average self-to-self pair strength) assigned to
    %   the starting point node-sequence at each temperature in each copy of 
    %   the entire MCMC simulation.
    %
    %nStepsPerCopy: the number of MCMC steps that will be taken for each
    %   temperature for each copy of the MCMC simulation
    %
    %Temperatures: vector listing the temperatures being used for each copy
    %   of the overall parallel-tempered MCMC simulation
    %
    %KeepStepOccupancy: logical variable; whether or not to save the 
    %   occupancy of each node at each step, insetad of just the
    %   final node frequencies. Such step occupancy data takes up a lot of 
    %   space, but is necessary for convergence testing. 
    %
    %pool: a MATLAB parallel pool to use for parallelization of the
    %   independent copies of the MCMC simulation. Can be set to [] or
    %   something else empty to not employ parallelization (default).
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %StepData: a cell array with one cell for each independent copy of the
    %   entire parallel-tempered MCMC simulation. That cell contains the
    %   handle to an object which stores all important data about that MCMC
    %   simulation.
    %
    %sequences: same as the "sequences" input variable, but for the MCMC
    %   ending point
    %
    %weights: same as the "weights" input variable, but for the MCMC ending
    %   point
    %
    %pool: the same parallel pool object that was passed in as an input
    
    
    if nargin < 8
        KeepStepOccupancy = false;
    end
    if nargin < 9
        pool = [];
    end

    n = size(sequences{1},1);
    nTemps = length(Temperatures);
    nParallel = length(sequences);
    %%%AllWeights = zeros(nParallel,nStepsPerCopy,nTemps);
    
    %Set default probability for attempting swap steps:
    if nTemps == 1
        SwapTempProb = 0;
    else
        SwapTempProb = 0.2;
    end

    %Set up objects to store the information (weights, acceptances of each
    %step, occupancy at each step, etc.) for each parallel copy of the MCMC
    %chain
    StepData = cell(nParallel,1);
    for i = 1:nParallel
        StepData{i} = MCMC_Info(nTemps,GCO.NUnique,nStepsPerCopy,KeepStepOccupancy);
    end
    
    %Now we will set-up and run the actual MonteCarlo, and keep track of
    %both the distribution and the acceptance rates
    nSteps = nParallel * nStepsPerCopy;
    
    %Unfortunately I have to duplicate the same code twice, to allow it to
    %work with or without a parfor
    if isempty(pool)
        counter = 0;
        for i = 1:nParallel
            for stepnum = 1:nStepsPerCopy
                counter = counter + 1;
                if mod(counter,8192) == 0
                    disp([counter nSteps]);
                end

                %Advance one step
                [sequences{i},weights(i,:),TrialStepsAccepted,StepTypeIDs] = ...
                    advance_OneMonteCarloStep_ParallelTempering(sequences{i},...
                    weights(i,:),GCO,n,criteriaChecker,criteriaParams,...
                    Temperatures,nTemps,SwapTempProb);

                %Update all stored final data; this is done in a subfunction to
                %save on duplicated lines of code. The final data is stored in a handle
                %object to reduce duplication of data. The handle object must
                %be explicitly redefined at the end in order to behave
                %correctly with parallization. 
                ThisCopyData = StepData{i};
                UpdateMCMCData(ThisCopyData,TrialStepsAccepted,StepTypeIDs,...
                    sequences{i},weights(i,:),stepnum,nTemps,KeepStepOccupancy);
                StepData{i} = ThisCopyData;

            end
        end
    else
        parfor i = 1:nParallel
            for stepnum = 1:nStepsPerCopy 
                if mod(stepnum,8192) == 0
                    disp([stepnum nSteps]);
                end

                %Advance one step
                [sequences{i},weights(i,:),TrialStepsAccepted,StepTypeIDs] = ...
                    advance_OneMonteCarloStep_ParallelTempering(sequences{i},...
                    weights(i,:),GCO,n,criteriaChecker,criteriaParams,...
                    Temperatures,nTemps,SwapTempProb);

                %Update all stored final data; this is done in a subfunction to
                %save on duplicated lines. The final data is stored in a handle
                %object to reduce duplication of data. The handle object must
                %be explicitly redefined at the end in order to behave
                %correctly with parallization. 
                ThisCopyData = StepData{i};
                UpdateMCMCData(ThisCopyData,TrialStepsAccepted,StepTypeIDs,...
                    sequences{i},weights(i,:),stepnum,nTemps,KeepStepOccupancy);
                StepData{i} = ThisCopyData;

            end
        end        
    end
    
end

function UpdateMCMCData(DataObj,TrialStepsAccepted,StepTypeIDs,sequences,...
    weights,stepnum,nTemps,KeepStepOccupancy)

    %Update list of weights
    DataObj.AllWeights(stepnum,:) = weights;

    for j = 1:nTemps     
        %Update acceptance statistics
        DataObj.AcceptedAndRejected{j}(StepTypeIDs(j),TrialStepsAccepted(j)+1) = ...
            DataObj.AcceptedAndRejected{j}(StepTypeIDs(j),TrialStepsAccepted(j)+1) + 1;

        %Update total acceptance rate over time
        DataObj.StepsAccepted{j}(stepnum) = TrialStepsAccepted(j);

        %Update the final distribution!
        DataObj.NodeFreqs{j}(sequences(:,j)) = DataObj.NodeFreqs{j}(sequences(:,j)) + 1;

        %Update the all-data array if requested
        if KeepStepOccupancy
            DataObj.OccupanciesByStep(j,sequences(:,j),stepnum) = true;
        end        
    end

end