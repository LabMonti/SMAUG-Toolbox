function [OutputInfo,BulkyInfo] = Run_MCMCFeatureFinder(GCO, ...
    sequenceLength, CriteriaType, criteriaParams, nSteps, nCopies, ...
    RelativeTemps, ShowPlots, varargin)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Runs our MCMC feature-finder on a dataset that
    %has already had its traces turned into coarse traces, and then
    %information on the different nodes has been stored in a grid
    %correlation object for that dataset. The major steps of the MCMC
    %feature finder are: running T = inf MCMC chains to determine
    %sigma_infinity, which we use to turn the relative temperatures input
    %by the user into absolute (effective) temperatures; running burn-in
    %steps on the parallel tempering MCMC super-chains; collecting the
    %actual steps on the parallel tempering MCMC super-chains; checking for
    %convergence of the parallel tempering MCMC super-chains, and, if
    %requested, collecting more steps until they converge; if requested,
    %plotting results. 
    %
    %~~~INPUTS~~~:
    %
    %GCO: a GridCorrelationObject containing the coarsened traces and
    %   calculated node information for a given dataset
    %
    %sequenceLength: the length, in # of nodes, of the sequences that the
    %   MCMC feature finder will be using
    %
    %CriteriaType: string variable; the type of additional criteria that 
    %   the user wishes to impose on the node sequences generated by the 
    %   MCMC. Can be set to "None" to use impose no additional criteria.
    %   For any criteria chosen here, there must exist a corresponding 
    %   criteria checker function.
    %
    %criteriaParams: a structure array containing whatever parameters the
    %   user-chosen additional criteria require (e.g., a maximum slope).
    %
    %nSteps: the total number of MCMC steps that will be collected and used
    %   for generating the final distributions. Does NOT include the # of
    %   burn-in steps. This # of steps will be evenly split across multiple
    %   independent copies of the parallel tempering super-chain (see next
    %   input). 
    %
    %nCopies: the # of independent copies of the parallel tempering
    %   super-chain that will be run in parallel, in order to evaluate
    %   convergence by comparing the within-chain and between-chain
    %   variances. Steps from all copies will be combined at the end to
    %   produce the final distributions. This same # of copies will also be
    %   used for the T = inf MCMC chains used to calculate sigma_infinity.
    %
    %RelativeTemps: a vector containing the relative effective temperatures
    %   to be used for the different sub-chains of each parallel tempering
    %   MCMC super-chain. These are called "relative" temperatures because
    %   they will each be multiplied by the sigma_infinity value calculated
    %   for this dataset in order to obtain the actual effective
    %   temperatures used during the MCMC. 
    %
    %ShowPlots: logical variable; whether or not to create all output plots
    %   at the end that have been requested by the default settings or the
    %   user.
    %
    %varargin: this is a stand in for several name-value pairs that can be
    %   specified by the user as additional inputs, if desired. See
    %   MCMC_inputparser.m for what these additional inputs are and what
    %   their default values are if unmodified here. 
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %OutputInfo: a structure array containing lots of different information
    %   on the results of the final MCMC simulation; most importantly, the
    %   final node occupancy distributions for each temperature. 
    %
    %BulkyInfo: a secondary structure array to hold the bulkiest
    %   (memory-wise) output info, most importantly the occupancy of each
    %   node at each step. This information is NOT neccessary for the final
    %   distribution, but it IS needed to evaluate convergence. It is split
    %   into a second output variable so that it doesn't need to be saved,
    %   and take up a lot of room, with the other output info. 
    
    
    %Default inputs
    if nargin < 8
        ShowPlots = true;
    end
    if nargin < 7
        RelativeTemps = [4/9 5/9 6/9 1 Inf];
    end
    if nargin < 6
        nCopies = 3;
    end
    if nargin < 5
        nSteps = 600000;
    end
    if nargin < 4
        criteriaParams = struct();
    end
    if nargin < 3
        CriteriaType = 'None';
    end
    if nargin < 2
        sequenceLength = 10;
    end
    
    TSaver = TimingSave;
    
    %Parse the name value pairs
    nTemps = length(RelativeTemps);
    p = MCMC_inputparser(nTemps);
    parse(p,varargin{:});
    OtherParams = p.Results;
    
    %Set the random seed; if requested, use the current time to generate
    %the random seed.
    if strcmp(OtherParams.RandomSeed,'UseTime')
        t = now();
        t = t * 1E5;
        t = 1E5 * (t - floor(t));
        random_seed = round(t);        
    else
        random_seed = OtherParams.RandomSeed;
    end
    rng(random_seed);
       
    %Make sure temperatures are in ascending order
    RelativeTemps = sort(RelativeTemps);
    
    %If requested, start up a parallel pool
    if OtherParams.Parallelize
        %Check if a pool already exists, and if so we can just use that
        pool = gcp('nocreate');
        if isempty(pool)
            pool = parpool(OtherParams.nParallelWorkers);
        end
        disp('Parallel pool created!');
        TSaver.Save('Parallel Pool Setup');
    else
        pool = [];
    end

    %Make sure required fields of the Coarse Grid Object have been
    %calculated!
    if isempty(GCO.VerticalNeighbors)
        GCO.calculate_VerticalNeighbors();
    end
    if isempty(GCO.HorizontalNeighbors)
        GCO.calculate_HorizontalNeighbors();
    end
    if isempty(GCO.MissingNeighbors)
        GCO.calculate_MissingNeighbors();
    end
    if isempty(GCO.CumulativeTransferProbs)
        GCO.calculate_CumulativeTransferProbs();
    end    
    
    %Figure out the value of sigma_infinity, which we will use as our
    %temperature scale (for converting from relative temperature to actual
    %temperature)
    disp('Running MCMC at T = inf. to determine appropriate temperature scale...');
    sig_inf = determine_sigma_infinity(GCO,sequenceLength,CriteriaType,...
        criteriaParams,OtherParams.SigInf_Rhat,OtherParams.MinSteps_SigInf,...
        nCopies,false);
    disp('Appropriate temperature scale found!');
    Temperatures = RelativeTemps*sig_inf;
    TSaver.Save('Finding sig_inf');
      
    %Get function handle for requested type of criteria to check
    criteriaChecker = get_criteriaChecker(CriteriaType);
    
    %First we need to generate starting sequences (and make sure that each
    %meets our criteria!)
    disp('Searching for valid starting sequence(s)...');
    [sequences, weights] = startingpoint_forMCMC_parallel(GCO, sequenceLength,...
        nCopies, nTemps, criteriaChecker, criteriaParams);
    disp('Valid starting sequence(s) found!');
    TSaver.Save('Generating Starting Sequences');

    %Perform burn-in if requested
    if OtherParams.BurnInSteps > 0
        disp('Performing Burn-In MCMC steps...');
        [~,sequences,weights,pool] = ...
            collect_paralleltempering_MCMCsteps_parallelcopies(GCO, ...
            criteriaChecker,criteriaParams,sequences,weights, ...
            ceil(OtherParams.BurnInSteps/nCopies),Temperatures,false,pool);
        TSaver.Save('Burn In');
    end   
    
    %Where we will be accumulating data
    MCMCData = [];
    
    %Create temperature legend info
    legend_names = cell(nTemps,1);
    for i = 1:nTemps
        legend_names{i} = strcat('Temperature = ',...
            num2str(Temperatures(i)),' (',num2str(RelativeTemps(i)),...
            ' Relative)');
    end  
    
    %Now, if requested, check for convergence and if it's not achieved then
    %run more MCMC steps
    repeat_loop = true;
    iterNum = 0;
    while repeat_loop && iterNum < OtherParams.MaxRepeats
        iterNum = iterNum + 1;
    
        %Now run the actual MCMC steps we will save
        disp('Collecting MCMC steps...');
        [IterationData, sequences, weights, pool] ...
            = collect_paralleltempering_MCMCsteps_parallelcopies(GCO, ...
            criteriaChecker, criteriaParams, sequences, weights, ceil(nSteps/nCopies), ...
            Temperatures, true, pool);
        
        %Combine data with that of previous iterations (if necessary)
        MCMCData = merge_MCMC_repeats(MCMCData, IterationData);
        
        TSaver.Save(strcat('Collecting MCMC Steps #',num2str(iterNum)));
  
        %If requested, check for convergence
        if OtherParams.RepeatUntilConvergence
            [NodeFreqs,OccupanciesByStep,~,~,~] = ...
                combine_MCMCoutputs_fromparallelcopies(MCMCData);
            [convergence_passed,ConvergenceTable,Rhats] = ...
                convergence_evaluation(OccupanciesByStep,nCopies,legend_names,...
                OtherParams.ConvergenceCriteria,NodeFreqs,...
                OtherParams.Parallelize,false);
            TSaver.Save(strcat('Convergence Check #',num2str(iterNum)));
            if all(convergence_passed)
                repeat_loop = false;
            else
                disp(strcat('Iteration #',num2str(iterNum), ' Convergence Failure:'));
                disp(ConvergenceTable);
            end
        else
            repeat_loop = false;
            ConvergenceTable = [];
            Rhats = [];
        end
    end
    
    %Combine the MCMC outputs from all the parallel copies that were run
    %(each copy has different temperatures within it; we are NOT combining
    %between temperature!)
    [NodeFreqs,OccupanciesByStep,AcceptedAndRejected,StepsAccepted,AllWeights] = ...
        combine_MCMCoutputs_fromparallelcopies(MCMCData);
    clear MCMCData;
    nSteps = nSteps*iterNum;
    TSaver.Save('Unpacking data');
    
    %Construct table of standard deviation of weights for each temperature
    StdTable = table(Temperatures(:),std(AllWeights)','VariableNames',{...
        'Temperature','Std. Dev. of Node-Sequence Weights'});
    
    %Plot the final distributions
    if ShowPlots         
        %Make plots of the 2D node frequency distribution at each
        %temperature
        for i = 1:OtherParams.Num2DPlotsToShow
            sequence_frequency_plot(GCO,NodeFreqs{i},nSteps,legend_names{i});
            if OtherParams.OverlayExampleSequence
                hold on;
                plot(GCO.UniqueNodes(sequences{1}(:,i),1),GCO.UniqueNodes(...
                   sequences{1}(:,i),2),'-o','Color',[1 0 0]);
            end
        end

        %Make plots to show a rolling average of the acceptance rate and of
        %the sequence weight over time
        SmoothWindow = round(nSteps/100);
        if OtherParams.PlotAcceptanceOverTime
            acceptanceRate_overTime_plot(StepsAccepted,SmoothWindow,legend_names);
        end
        if OtherParams.PlotWeightOverTime
            sequenceWeight_overTime_plot(AllWeights,SmoothWindow,legend_names);
        end

        %Display the standard deviation of weights for each temperature:
        disp(StdTable);

        %Make a bar chart to show the acceptance rate for each type of step for
        %each temperature
        if OtherParams.PlotFinalAcceptances
            finalAcceptanceRates_plot(AcceptedAndRejected,legend_names);
        end
        
        if OtherParams.PlotConvergenceResults
            %If not already computed in iteration loop above, compute
            %convergence results
            if isempty(ConvergenceTable)
                [~,ConvergenceTable,Rhats] = convergence_evaluation(...
                    OccupanciesByStep,nCopies,legend_names,OtherParams.ConvergenceCriteria,...
                    NodeFreqs,OtherParams.Parallelize,false);
            end
            %Make the plot of those results
            convergenceResults_plot(Rhats,ConvergenceTable,legend_names);
        end

        %Make 1D histograms of the final MCMC distributions projected onto
        %just the conductance and/or distance axes
        if OtherParams.NumCondHistsToInclude > 0
            NodeFreqs_to_Overlaid1DHist(NodeFreqs(1:...
                OtherParams.NumCondHistsToInclude),GCO,'cond',true);
            legend(legend_names(1:OtherParams.NumCondHistsToInclude));
        end
        if OtherParams.NumDistHistsToInclude > 0
            NodeFreqs_to_Overlaid1DHist(NodeFreqs(1:...
                OtherParams.NumDistHistsToInclude),GCO,'dist',true);
            legend(legend_names(1:OtherParams.NumDistHistsToInclude));
        end
        TSaver.Save('Making Plots');
    end
    
    if OtherParams.Parallelize
        delete(pool);
    end
    
    %Create table to show how long each step took
    TimeTable = TSaver.CreateTable;
    disp(TimeTable);
    
    %Holder of output information
    OutputInfo = struct();
    OutputInfo.NodeFreqs = NodeFreqs;
    OutputInfo.AcceptedAndRejected = AcceptedAndRejected;
    OutputInfo.Temperatures = Temperatures;
    OutputInfo.RelativeTemps = RelativeTemps;
    OutputInfo.sig_inf = sig_inf;
    OutputInfo.StdTable = StdTable;
    OutputInfo.ConvergenceCriteria = OtherParams.ConvergenceCriteria;
    OutputInfo.ConvergenceTable = ConvergenceTable;
    OutputInfo.nBurnInSteps = OtherParams.BurnInSteps;
    OutputInfo.nCopies = nCopies;
    OutputInfo.nSteps = nSteps;
    OutputInfo.CriteriaType = CriteriaType;
    OutputInfo.criteriaParams = criteriaParams;
    OutputInfo.TimeTable = TimeTable;
    OutputInfo.legend_names = legend_names;
    OutputInfo.Rhats = Rhats;
    OutputInfo.RandomSeed = random_seed;
    
    %Holder of extra information that takes up a lot of space:
    BulkyInfo = struct();
    BulkyInfo.StepsAccepted = StepsAccepted;
    BulkyInfo.AllWeights = AllWeights;
    BulkyInfo.OccupanciesByStep = OccupanciesByStep;

end