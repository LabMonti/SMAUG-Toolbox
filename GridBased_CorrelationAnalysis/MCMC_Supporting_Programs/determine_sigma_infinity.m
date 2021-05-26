function [sig_inf,counter] = determine_sigma_infinity(GCO, ...
    sequenceLength, CriteriaType, criteriaParams, Rhat_Threshold, ...
    minSteps,n_MCMC_chains,ToPlot)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: this function runs my a single-temperature MCMC
    %chain at an effective temperature of infinity--meaning all possible
    %node sequences have equal probability--in order to determien the value
    %of sigma_infinity, which is the standard deviation of the weights
    %(average self-to-self connection strengths) from all node sequences in
    %the MCMC simulation. We use sigma_infinity to set an appropriate
    %relative scale for effective temperatures to use during the parallel
    %tempering MCMC. To make sure that sigma_infinity has converged, I run
    %multiple independent chains in parallel and hten use a version of the
    %Gelman-Rubin diagnostic to check that the ratio beteween the within-
    %chain and between-chain variance of the sequence weights is
    %sufficiently close to 1. 
    %
    %~~~INPUTS~~~:
    %
    %GCO: grid correlation object for the given dataset, containing the
    %   coarse traces and information on all of the nodes
    %
    %sequenceLength: the length, in # of nodes, of the sequences being
    %   simulated by the MCMC
    %
    %CriteriaType: string variable; the name of the type of criteria the
    %   user wishes to impose on the node sequences. There must exist an
    %   associated checker function to implement this criteria.
    %
    %criteriaParams: structure array with fields for each of the parameters
    %   required by whatever type of criteria has been chosen
    %
    %Rhat_Threshhold: in order for convergence to be achieved, the Rhat
    %   ratio for sequence weights must be below this value
    %
    %minSteps: the minimum number of MCMC steps that will be run for each
    %   copy of the single-temperature MCMC chain
    %
    %n_MCMC_chains: the number of independent single-temperature MCMC
    %   chains that will be run in parallel, to help evaluate convergence.
    %
    %ToPlot: logical variable; whether or not to make a plot showing
    %   changes in Rhat as more and more steps are collected
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %sig_inf: the value for sigma_infinity obtained using the sequence
    %   weights from all copies of the MCMC chain combined
    %
    %counter: the number of MCMC steps that ended up being run for each
    %   copy of the single-temperature MCMC chain
    

    %Default values
    if nargin < 8
        ToPlot = false;
    end
    if nargin < 7
        n_MCMC_chains = 3;
    end
    if nargin < 6
        minSteps = 150000;
    end
    if nargin < 5
        Rhat_Threshold = 1.005;
    end
    if nargin < 4
        criteriaParams = struct();
        criteriaParams.minSlope = -Inf;
        criteriaParams.maxSlope = Inf;
    end
    if nargin < 3
        CriteriaType = 'RangeSlope';
    end
    if nargin < 2
        sequenceLength = 10;
    end   
    
    if n_MCMC_chains < 2
        warning('Cannot test for convergence with fewer than 2 chains; re-setting to 3');
        n_MCMC_chains = 3;
    end
    
    %Get function handle for requested type of criteria to check
    criteriaChecker = get_criteriaChecker(CriteriaType);  
    
    %Make sure required fields of the Coarse Grid Object have been
    %calculated!
    if isempty(GCO.VerticalNeighbors)
        GCO.calculate_VerticalNeighbors();
    end
    if isempty(GCO.HorizontalNeighbors)
        GCO.calculate_HorizontalNeighbors();
    end
    if isempty(GCO.CumulativeTransferProbs)
        GCO.calculate_CumulativeTransferProbs();
    end

    %First we need to generate starting sequences (and make sure that each
    %meets our criteria!)
    disp('        (Searching for valid starting sequence(s)...)');
    [sequences, weights] = startingpoint_forMCMC_parallel(GCO, sequenceLength,...
        n_MCMC_chains, 1, criteriaChecker, criteriaParams);
    disp('        (Valid starting sequence(s) found!)');
    
    maxSteps = 5000000;
    check_every = 1000;
    AllWeights = zeros(n_MCMC_chains,maxSteps);
    convergence = false;
    
    %Fill in the first step as the initial point
    counter = 1;
    AllWeights(:,1) = weights;
    Rhat_info = NaN(round(maxSteps/check_every),2);
    rhi_counter = 0;
    
    %Start collecting MCMC steps!
    while ~convergence && counter < maxSteps
        
        if mod(counter,50000) == 0
            disp(counter);
        end
        
        %Take one MCMC step in each chain and store the results
        counter = counter + 1;
        for j = 1:n_MCMC_chains
            [sequences{j},weights(j,:),~,~] = ...
                advance_OneMonteCarloStep_ParallelTempering(sequences{j},...
                weights(j,:),GCO,sequenceLength,criteriaChecker,...
                criteriaParams,Inf,1,0);
        end
        AllWeights(:,counter) = weights;
        
        %Only check for convergence if we have at least minSteps collected
        %(and only check every few steps, to save time calculating standard
        %deviations)
        if counter >= minSteps && mod(counter,check_every) == 0
            
            rhi_counter = rhi_counter + 1;
            Rhat_info(rhi_counter,1) = counter;
            
            %Find the variations within each chain
            chain_vars = zeros(n_MCMC_chains,1);
            for j = 1:n_MCMC_chains
                chain_vars(j) = var(AllWeights(j,1:counter));
            end
            
            %Now we compute the between-chains variance
            BetweenVar = var(chain_vars);

            %Compute Rhat for comparing between chains
            Rhat = sqrt((counter-1)/counter + BetweenVar/mean(chain_vars));
            Rhat_info(rhi_counter,2) = Rhat;

            if Rhat < Rhat_Threshold
                convergence = true;
            end                 
        end
    end
    
    %Print warning if max # of steps exceeded
    if ~convergence
        warning('Max # of steps exceeded, convergence criteria not reached!');
    end

    sig_inf = std(AllWeights(1:counter*n_MCMC_chains));

    if ToPlot
        figure();
        hold on;
        
        %Plot the Rhat ratios
        plot(Rhat_info(:,1),Rhat_info(:,2),'.');
        xlabel('# of MCMC Steps so Far');
        ylabel('R_{hat} Ratio');
        
        plot([min(Rhat_info(:,1)),max(Rhat_info(:,1))],...
            [Rhat_Threshold,Rhat_Threshold],'--','Color',[0.5 0.5 0.5]);
    end
end