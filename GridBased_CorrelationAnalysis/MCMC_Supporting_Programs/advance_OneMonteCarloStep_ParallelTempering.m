function [sequences, sequenceWeights, TrialStepsAccepted, StepTypes] = ...
    advance_OneMonteCarloStep_ParallelTempering(sequences, ...
    sequenceWeights, GCO, n, criteriaChecker, criteriaParams, Temps, ...
    nTemps, SwapTempProb)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Advance the MCMC super-chain--i.e., the set of
    %linked MCMC simulations being run at different temperatures with the
    %possibilty for swapping--by one step, and return the new sequences at
    %each temperature (which may be just a repetition of the old sequences
    %of course!). For keeping track of acceptance rates, also return
    %whether the trial step at each temperature was accepted or not and
    %which type of step it was. 
    %
    %~~~INPUTS~~~:
    %
    %sequences: a sequence_length x nTemps matrix holding the node ID #s for
    %   the nodes in each node-sequence at each temperature
    %
    %sequenceWeights: nTemps x 1 vector containing the "weight" (i.e. average
    %   self-to-self connection strength) for the node-sequences at each
    %   temperature
    %
    %GCO: the GridCorrelationObject containing all of the node information
    %   for the dataset that the MCMC is being run on
    %
    %n: the length of the node-sequence being simulated at each temperature
    %   (they all have the same length of course)
    %
    %criteriaChecker: function handle for a function that will check
    %   whether a given node-sequence meets whatever criteria the user has
    %   specified (if not the step will automatically be rejected)
    %
    %criteriaParams: structure array containing whatever criteria are
    %   needed for the criteria checker specified by the user
    %
    %Temps: vector listing the temperatures being used for each MCMC chain
    %   within the overall super-chain
    %
    %nTemps: the # of different temperatures being run in parallel. Yes,
    %   this can be just one and it will still work!
    %
    %SwapTempProb: the probability that a swap between adjacent chains will
    %   be attempted as the trial step, as opposed attempting an
    %   independent movement step within each temperature's sub-chain
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %sequences: just like the input variable sequences, but updated by the
    %   result of advancing one step in the super-chain
    %
    %sequenceWeights: just like the input variable sequenceWeights, but for
    %   the updated sequences
    %
    %TrialStepsAccepted: nTemps x 1 logical vector listing whether or not
    %   the trial step was accpeted within each sub-chain
    %
    %StepTypes: nTemps x 1 vector listing an integer for each sub-chain
    %   that tells us what type of step was attempted for that sub-chain; 1
    %   means a single shift step, 2 means a rigid shift step, 3 means a
    %   split shift step, 4 means a scramble shift step, 5 means a rigid
    %   translate step, 6 means a "snake" translate step, and 6 means a
    %   swap step.
    
    
    %Initialize acceptance flag vector
    TrialStepsAccepted = false(nTemps,1);
    
    %Initialize step type vector
    StepTypes = zeros(nTemps,1);
    
    %Defined cumulative probabilities for each type of non-swap step;
    %Order is SingleShift, RigidShift, SplitShift, ScrambleShift,
    %RigidTranslate, and SnakeTranslate (so these probabilities are 
    %conditional upon having NOT already chosen a swap step)
    cumulativeStepProbs = [0.2 0.33 0.46 0.60 0.65 1];
    
    %Generate our random number to choose a type of step
    a = rand();    
    
    %First we deal with the non-swap case; here we need to loop through
    %each chain and treat it independently:
    if a > SwapTempProb
        
        %Now loop over each replica of the MC chain
        for i = 1:nTemps
            
            %Choose the type of non-swap trial step (and store the function we will
            %used to carry out that type of trial step)
            x = rand();
            if x <= cumulativeStepProbs(1)     
                gen_TrialStep = @step_SingleShift;
                StepTypes(i) = 1;   
            elseif x <= cumulativeStepProbs(2)  
                gen_TrialStep = @step_RigidShift;
                StepTypes(i) = 2;        
            elseif x <= cumulativeStepProbs(3)   
                gen_TrialStep = @step_SplitShift;
                StepTypes(i) = 3;        
            elseif x <= cumulativeStepProbs(4) 
                gen_TrialStep = @step_ScrambleShift;
                StepTypes(i) = 4;        
            elseif x <= cumulativeStepProbs(5)
                gen_TrialStep = @step_RigidTranslate;
                StepTypes(i) = 5; 
            else
                gen_TrialStep = @step_SnakeTranslate;
                StepTypes(i) = 6;                 
            end
            
            %Generate trial step
            trialSequence = gen_TrialStep(sequences(:,i),GCO);

            %Now we need to run initial checks to see if the trial step should be
            %automatically rejected out of hand
            if isnan(trialSequence)
                Rejected = true;
            else
                %Check if the trial sequence passes the selected criteria
                %function or not; if it doesn't pass, then it is rejected
                Rejected = ~criteriaChecker(GCO, trialSequence, criteriaParams);
            end

            %If the step has not already been rejected, we need to actually
            %calculate the trial sequence "energy", calculate the relative
            %probability, and apply the Metropolis-Hastings criteria
            if ~Rejected
                trial_sequenceWeight = avg_self2self_Connectionstrength(...
                    trialSequence,n,GCO);
                RelativeProb = exp((trial_sequenceWeight - ...
                    sequenceWeights(i))/Temps(i));

                %Metropolis-Hastings criteria
                x = rand();
                if x > RelativeProb
                    Rejected = true;
                end
            end

            %If the trial step is accepted, replace the current sequence and
            %weight with it; if it's rejected, no work needs to be done
            %(current sequence and weight will be returned as repeats, which
            %is what we want!)
            if ~Rejected
                %Replace sequence and weight with trial sequence and weight
                sequences(:,i) = trialSequence;
                sequenceWeights(i) = trial_sequenceWeight;
                TrialStepsAccepted(i) = true;        
            end
        end
      
    %Now we can deal with the case that a swap of adjacent chains is
    %attempted. In this case 
    else
        StepTypes = 7*ones(nTemps,1);
        
        %Randomly decide if we will check for swaps moving up or down in
        %temperature; I think it is important to allow for both
        %possibilities to maintain detailed balance (but I'm not 100% sure)
        a = rand();
        if a > 0.5
            start = nTemps - 1;
            stop = 1;
        else
            start = 1;
            stop = nTemps - 1;
        end
        
        %Go through the different chains and attempt to swap each one in
        %turn
        for C = start:stop
            %C is the ID# for the current "cold" chain, and H is the ID#
            %for the current "hot" chain just above it
            H = C + 1;
        
            %Check Metropolis-Hastings criteria for the swapping of the two
            %chains
            RelativeProb = exp((sequenceWeights(H)-sequenceWeights(C))*...
                (1/Temps(C) - 1/Temps(H)));
        
            %Check if swap is accepted, and if so perform it!
            x = rand();
            if x <= RelativeProb
                %Copy out hot sequence & weight
                hot_sequence = sequences(:,H);
                hot_weight = sequenceWeights(H);

                %Replace hot chain with info from cold chain
                sequences(:,H) = sequences(:,C);
                sequenceWeights(H) = sequenceWeights(C);

                %Copy saved hot sequence and weight into cold chain
                sequences(:,C) = hot_sequence;
                sequenceWeights(C) = hot_weight;

                %Update acceptance flags
                TrialStepsAccepted(C) = true;
                TrialStepsAccepted(H) = true;            
            end
        end

    end

end