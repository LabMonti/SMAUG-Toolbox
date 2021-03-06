function [sequences, weights] = startingpoint_forMCMC_parallel(GCO, ...
    sequenceLength, nParallel, nTemps, criteriaChecker, criteriaParams)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Generate a randomly sampled starting point for
    %the MCMC feature-finder, with parallel tempering. In addition, find 
    %nParallel DIFFERENT starting points for each temperature, so that the
    %overall parallel-tempered MCMC can be run in parallel to evaluate
    %convergence. Within each parallel copy, the different temperatures are
    %also assigned different starting points. To generate a starting node
    %sequence, we first randomly pick a node in proportion to how many
    %traces passed through it. We then randomly generate a node sequence
    %centered on that node according to the transfer probabilities between
    %nodes (i.e., the null hypothesis that traces, and node sequences,
    %proceed like weighted random walks). If the generated node sequence is
    %not of the desired length, or does not meet user-specified criteria, a
    %new one will be generated instead. 
    %
    %~~~INPUTS~~~:
    %
    %GCO: grid correlation object for the given dataset, containing the
    %   coarsened traces and node information
    %
    %sequenceLength: the length, in  nodes, of the sequences that will be
    %   created for the MCMC
    %
    %nParallel: the number of parallel copies of the entire parallel
    %   tempering super MCMC chain that will be run, and that hence each
    %   need their own separate starting point at each temperature
    %
    %nTemps: the number of different temperatures used for each parallel
    %   tempering MCMC chain; each temperature will need its own starting
    %   point
    %
    %criteriaChecker: function handle to the function that will check
    %   whether or not a given node sequence meets the user-specified
    %   critiera or not. We will keep generating random starting
    %   node-sequenes until they all meet these criteria. 
    %
    %criteriaParams: struture array containing whatver parameters are
    %   required for the specific type of criteria chosen by the user
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %sequences: a cell array containing all of the starting-point node
    %   sequences generated by this function for use in the MCMC. Each cell
    %   contains the starting sequences for one of the nParallel copies of
    %   the MCMC super-chain. With each cell is a sequenceLength x nTemps
    %   array containing the node ID#s for the nodes in the starting
    %   sequence for each temperature. 
    

    if isempty(GCO.CumulativeTransferProbs)
        GCO.calculate_CumulativeTransferProbs();
    end
    CumulativeTransferTo = GCO.CumulativeTransferProbs;
    CumulativeTransferFrom = getCumulativeTransferFromProbs(GCO);

    %Loop over nParallel copies of MCMC super-chain
    sequences = cell(nParallel,1);
    weights = zeros(nParallel,nTemps);
    for i = 1:nParallel
        sequences{i} = zeros(sequenceLength,nTemps);
        
        %Create a different starting point for each temperature
        for j = 1:nTemps
            n = Inf;
            pass = false;
            
            %Keep creating different node sequences until we find one that
            %meets our desired length and any user-specified criteria
            while n ~= sequenceLength || ~pass
                startID = randperm(GCO.NUnique,1);

                sequence = generate_randomtracesection_throughnode(...
                    CumulativeTransferTo, CumulativeTransferFrom, startID, ...
                    sequenceLength, false);

                n = length(sequence);

                %Check if node sequence passes the selected criteria function
                if n == sequenceLength
                    pass = criteriaChecker(GCO, sequence, criteriaParams);
                end
            end

            sequences{i}(:,j) = sequence;
            weights(i,j) = avg_self2self_Connectionstrength(sequence,n,GCO);

        end
    end

end