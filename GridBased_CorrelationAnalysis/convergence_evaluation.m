function [convergenceTest_passed,ConvergenceTestTable,Rhats] = ...
    convergence_evaluation(OccupanciesByStep,nChunks,legend_names,...
    convergence_criteria,NodeFreqs,Parallelize,ToPlot)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: computes a version of the Gelman-Rubin
    %diagnostic to evaluate whether a parallel-tempering MCMC run is
    %suitably converged or not. This diagnostic requires multiple
    %independent parallel copies of the MCMC super-chain to have been run.
    %It then compares the within-chain variances to the between-chain
    %variance, and when this ratio is low enough we consider convergence to
    %have been achieved. This step is computationally intenstive, so it can
    %be parallelized (across temperatures) to help with time. 
    %
    %~~~INPUTS~~~:
    %
    %OccupanciesByStep: an nTemps x nNodes x nSteps logical array. Each
    %   element indicates whether or not that node was part of the
    %   node-sequence at that temperature and that step during the MCMC
    %   simulation. This information is needed to compute variances for
    %   convergence testing. 
    %
    %nChunks: the # of different chunks that the data will be split into to
    %   compute the within-chain variances. Usually this is the same as the
    %   number of parallel copies that were run, but if desired it could
    %   also, e.g., be set to twice that in order to also split each
    %   indpendent copy of the MCMC super-chain into two halves. 
    %
    %legend_names: an nTemps x 1 cell array containing a name to be used
    %   for each temperture, for use in plotting and in making the output
    %   table
    %
    %convergence_criteria: a structure array containing two fields:
    %   "max_Rhat" is the cut-off value that the Rhat ratio has to be below
    %   for each node from each temperaturein order to achieve convergence;
    %   "strict_Rhat" is the cut-off that the weighted average Rhat for
    %   each temperature (weighted by how often the node was occupied
    %   during the MCMC) must be below in order to achieve convergence.
    %   Both criteria must be met at the same time. 
    %
    %NodeFreqs: a cell array with one cell per temperature used during
    %   parallel tempering. Within each cell is a vector the length of the
    %   # of different nodes in the dataset, indicating how often each node
    %   was included in a node-sequence in that temperature's MCMC
    %   sub-chain. 
    %
    %Parallelize: logical variable; whether or not to run the Rhat
    %   calculations in parallel to save time. Paralleization is done
    %   across the different temperatures. Designed to make use of an
    %   already-created parallel pool, but MATLAB will also make one by
    %   default if none exists. 
    %
    %ToPlot: logical variable; whether or not to make a plot showing
    %   histograms of Rhat values for all the nodes at each temperature. In
    %   addition to the plot, a table stating whether convergence was
    %   passed or not for each temperature will be printed to the screen. 
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %convergenceTest_passed: a logical vector with one element per
    %   temperature, indicating whether or not the convergence criteria
    %   were met at that temperature. 
    %
    %ConvergenceTestTable: a table showing detailed convergence results for
    %   each temperature
    %
    %Rhats: a cell array with one cell per temprature. Within each cell is
    %   an array with one row per node (only nodes occupied by the MCMC
    %   node-sequence at least 0.1% of the time at the given temperature
    %   are included) and four columns: the Rhat ratio; how often the node
    %   was occupied; the average within-chain variance; and the
    %   between-chain variance. 
    

    [nTemps,nNodes,nSteps] = size(OccupanciesByStep);
    nStepsPerChunk = floor(nSteps/nChunks);
    
    if nargin < 2
        nChunks = 3;
    end
    if nargin < 3
        legend_names = cell(nTemps,1);
        for i = 1:nTemps
            legend_names{i} = strcat('Temperature #',num2str(i));
        end
    end
    if nargin < 4
        convergence_criteria = struct();
        convergence_criteria.max_Rhat = 1.1;
        convergence_criteria.strict_Rhat = 1.025;
    end
    if nargin < 5
        NodeFreqs = [];
    end  
    if nargin < 6
        Parallelize = false;
    end
    if nargin < 7
        ToPlot = false;
    end
    
    %It's not neccessary to include NodeFreqs as an input, as all the info
    %is alread included in AllMCMCData. However, if it IS included it can
    %save us time having to compute sums.
    if isempty(NodeFreqs)
        NodeFreqs = cell(nTemps,1);
        for i = 1:nTemps
            NodeFreqs{i} = sum(OccupanciesByStep(i,:,:),3);
        end    
    end
    
    %Make vectors to hold Rhat ratios from different nodes at each
    %temperature
    Rhats = cell(nTemps,1);    
    for i = 1:nTemps
        Rhats{i} = zeros(nNodes,4);
    end
    
    %Set the threshhold for what fraction of the time a node had to be
    %occupied for us to check its convergence
    node_occupancy_threshhold = 0.001; % 0.1% for now!
    sum_threshhold = node_occupancy_threshhold*nSteps;
    
    %Loop over each temperature, treating them independently, and collect
    %Rhat ratios for each node
    disp('Begin between-chains convergence evaluation...');
    counters = zeros(nTemps,1);
    
    %Option to run in parallel or not
    if Parallelize
        parfor i = 1:nTemps
            disp([i nTemps]);
            %Loop over each node; we only care about nodes that were occupied
            %at least SOME of the time (indicated by non-zero variance)
            for j = 1:nNodes
                if NodeFreqs{i}(j) > sum_threshhold    
                    %Compute total variance of this node
                    node_data = OccupanciesByStep(i,j,:); %Needs to be split off like this to allow slicing during parfor loop
                    %%%fullvar = var(node_data);

                    %Now we can compute the within-chain variances for each
                    %chunk
                    withinChain_vars = zeros(nChunks,1);
                    for k = 1:nChunks
                        withinChain_vars(k) = var(node_data(...
                            (k-1)*nStepsPerChunk+1:k*nStepsPerChunk));                    
                    end

                    %Finally we can compute the Rhat ratio for this particular
                    %node and add it to the appropriate vector. We can only
                    %compute Rhat if the denominator is nonzero!
                    W = mean(withinChain_vars); %within-chains (average) variance
                    if W > 0
                        counters(i) = counters(i) + 1;
                        
                        %Between-chains variance
                        B = var(withinChain_vars);
                        
                        %Calculate Rhat ratio accordint to formula in
                        %Bayesian Data Analysis by Andrew Gelman et al,
                        %2013, page 284
                        Rhats{i}(counters(i),1) = sqrt((nStepsPerChunk-1)/nStepsPerChunk + B/W);
                        Rhats{i}(counters(i),2) = NodeFreqs{i}(j);
                        
                        %Also store B and W separately, just to understand
                        %what is going on during convergence
                        Rhats{i}(counters(i),3) = W;
                        Rhats{i}(counters(i),4) = B;
                    end
                end
            end      
        end   
    else
        for i = 1:nTemps
            disp([i nTemps]);
            %Loop over each node; we only care about nodes that were occupied
            %at least SOME of the time (indicated by non-zero variance)
            for j = 1:nNodes
                if NodeFreqs{i}(j) > sum_threshhold    
                    %Compute total variance of this node
                    node_data = OccupanciesByStep(i,j,:);
                    %%%fullvar = var(node_data);

                    %Now we can compute the within-chain variances for each
                    %chunk
                    withinChain_vars = zeros(nChunks,1);
                    for k = 1:nChunks
                        withinChain_vars(k) = var(node_data(...
                            (k-1)*nStepsPerChunk+1:k*nStepsPerChunk));                    
                    end

                    %Finally we can compute the Rhat ratio for this particular
                    %node and add it to the appropriate vector. We can only
                    %compute Rhat if the denominator is nonzero!
                    W = mean(withinChain_vars);
                    if W > 0
                        counters(i) = counters(i) + 1;
                        
                        %Between-chains variance
                        B = var(withinChain_vars);
                        
                        %Calculate Rhat ratio accordint to formula in
                        %Bayesian Data Analysis by Andrew Gelman et al,
                        %2013, page 284
                        Rhats{i}(counters(i),1) = sqrt((nStepsPerChunk-1)/nStepsPerChunk + B/W);
                        Rhats{i}(counters(i),2) = NodeFreqs{i}(j);
                        
                        %Also store B and W separately, just to understand
                        %what is going on during convergence
                        Rhats{i}(counters(i),3) = W;
                        Rhats{i}(counters(i),4) = B;
                    end
                end
            end        
        end         
    end
 
    %Trim Rhat vectors
    for i = 1:nTemps
        Rhats{i} = Rhats{i}(1:counters(i),:);
        Rhats{i}(:,2) = Rhats{i}(:,2)/nSteps; %normalize second column
    end
    disp('Convergence calculations completed');
    
    %Now let's make a table to report some summary information on the Rhat
    %values
    Rhat_medians = zeros(nTemps,1);
    Rhat_maximums = zeros(nTemps,1);
    Rhat_wavgs = zeros(nTemps,1); %Weighted averages
    passfail = cell(nTemps,1);
    convergenceTest_passed = false(nTemps,1);
    for i = 1:nTemps
        Rhat_medians(i) = median(Rhats{i}(:,1));
        Rhat_maximums(i) = max(Rhats{i}(:,1));
        Rhat_wavgs(i) = sum(Rhats{i}(:,1).*Rhats{i}(:,2))/sum(Rhats{i}(:,2));
        if Rhat_maximums(i) < convergence_criteria.max_Rhat && ...
                Rhat_wavgs(i) < convergence_criteria.strict_Rhat
            passfail{i} = 'Pass';
            convergenceTest_passed(i) = true;
        else
            passfail{i} = 'Fail';
        end
    end
    ConvergenceTestTable = table(legend_names,Rhat_medians,Rhat_maximums,...
        Rhat_wavgs,passfail,'VariableNames',{'Temperature','Median R_{hat}',...
        'Maximum R_{hat}','R_{hat} Weighted Average','Passes Convergence Criteria?'});
    
    %If requested, create a plot of the results (and display the table)
    if ToPlot
        convergenceResults_plot(Rhats,ConvergenceTestTable,legend_names);
    end
    
end