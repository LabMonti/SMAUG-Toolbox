function [name,nTracesRemoved] = standardMCMC_withPreProcess(TraceStruct,...
    name,output_folder,trace_bounds,AnyModifiedParameters)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: The purpose of this function is to run the MCMC
    %feature finder when you want to run, for instance, on a computing
    %cluster, and thus you want all of the outputs to be saved rather than
    %displayed. It also performs pre-processing of the dataset in question,
    %so that it can be run directly on a trace structure. It will assume a
    %set of default parameters for both pre-processing and MCMC, but these
    %can be modified by passing in a structure with fields equal to the
    %parameters you want to modify. 
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all breaking traces for the
    %   dataset in question
    %
    %name: a name for the dataset, which will be used to label output plots
    %   and data
    %
    %output_folder: location in which output data and plots should be
    %   saved (within newly created subfolders); defaults to current folder
    %
    %trace_bounds: optional; a two-element vector containing the starting
    %   and ending trace numbers if you only want to use a subset of the
    %   dataset for the MCMC feature-finder. In this case, the name will be
    %   appended to include this subset info. 
    %
    %AnyModifiedParameters: a structure with fields name for any parameters
    %   you wish to modify from their standard values. See 
    %   setPreProcessing_and_MCMC_defaults for the default parameters. This
    %   format is used instead of making use of name-value pairs and the
    %   MATLAB input parser so that this function can be easily run from a
    %   script that has a list of parameters hard-coded in, which I find
    %   convenient for keeping track of what runs I have done. 
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %  
    %name: the name for the dataset or dataset subset that the MCMC
    %   feature-finder was run on. In the latter case, this name will have
    %   been modified from the input name in order to include information
    %   on what subset of traces was used. 
    %
    %nTracesRemoved: the # of traces removed in order to remove any
    %   low-trace or dangling nodes, as requested
    
    
    if nargin < 3
        output_folder = '.';
    end
    if nargin < 4
        trace_bounds = [];
    end
    if nargin < 5
        AnyModifiedParameters = struct();
    end
       
    %Fill in any parameters as their default values if they aren't
    %specified in the AnyModifiedParameters input. IP stands for input
    %parameters. 
    IP = setPreProcessing_and_MCMC_defaults(AnyModifiedParameters);

    %If requested, pull a subset of this dataset
    if ~isempty(trace_bounds)
        startTrace = trace_bounds(1);
        endTrace = trace_bounds(2);
        TraceStruct = GetTraceStructSubsections(TraceStruct,[startTrace endTrace]);
        
        %Update dataset name to include subset of traces used
        name = strcat(name,'_tr',num2str(startTrace),'-',num2str(endTrace));
    end    
    
    %Calcualte # of temperatures
    nTemps = length(IP.RelativeTemps);   
    
    %Creating output folders for saved data (may already exist, which is
    %fine)
    [~,~] = mkdir(fullfile(output_folder,'GridCorrelationObjects'));
    [~,~] = mkdir(fullfile(output_folder,'MCMCData'));
    [~,~] = mkdir(fullfile(output_folder,'ConvergencePlots'));
    [~,~] = mkdir(fullfile(output_folder,'FinalAcceptancePlots'));
    [~,~] = mkdir(fullfile(output_folder,'WeightAndAcceptanceOverTimePlots'));
    [~,~] = mkdir(fullfile(output_folder,'Cond1DHists'));
    for i = 1:nTemps
        [~,~] = mkdir(fullfile(output_folder,strcat('NodeFreqs_Temp',num2str(i))));
    end    
    
    %Load in in the trace structure and apply the left chop
    TraceStruct = LoadTraceStruct(TraceStruct);
    TraceStruct.apply_LeftChop(IP.left_chop);

    %Create parallel pool, if needed
    if IP.nCores > 1
        parpool(IP.nCores);
    end

    %Make the coarse gridded object
    CT = GridCorrelationObject(TraceStruct,IP.gridsX,IP.gridsY,true);

    %Remove nodes, if requested
    if IP.remove_lowtracenodes
        if IP.remove_danglingnodes
            nTracesRemoved = CT.remove_LowOrDangling_nodes();
        else
            nTracesRemoved = CT.remove_lowtrace_nodes();
        end
    elseif IP.remove_danglingnodes
        nTracesRemoved = CT.remove_dangling_nodes();
    end     

    %Fill in correlation info
    if IP.nCores > 1
        parallelize = true;
    else
        parallelize = false;
    end
    CT.calculate_ExpectedNodePairProbs(parallelize);
    CT.calculate_ConnectionStrengths();

    %Save the coarse gridded object
    CT.save_ObjectAsStruct_ToFile(strcat(name,'_GCO.mat'),fullfile(...
        output_folder,'GridCorrelationObjects'));

    %Run the MCMC
    [MCMCInfo,BulkyInfo] = Run_MCMCFeatureFinder(CT,IP.sequence_length,...
        IP.criteriaType,IP.CriteriaParams,IP.nSteps,IP.nCopies,IP.RelativeTemps,...
        false,'BurnInSteps',IP.BurnInSteps,'RepeatUntilConvergence',...
        true,'MaxRepeats',IP.MaxRepeats,'Parallelize',parallelize,...
        'ConvergenceCriteria',IP.ConvergenceCriteria);

    %Save MCMC output data
    save(fullfile(output_folder,'MCMCData',strcat(name,'_MCMCinfo.mat')),'MCMCInfo');
    if IP.SaveBulkyInfo
        save(fullfile(output_folder,'MCMCData',strcat(name,'_Bulkyinfo.mat')),'BulkyInfo');
    end

    %Make and save different plots
    SmoothWindow = round(MCMCInfo.nSteps/100);
    acceptanceRate_overTime_plot(BulkyInfo.StepsAccepted,SmoothWindow,MCMCInfo.legend_names);
    print(fullfile(output_folder,'WeightAndAcceptanceOverTimePlots',strcat(name,...
        '_AcceptanceOverTime.png')),'-dpng');
    close(gcf);
    sequenceWeight_overTime_plot(BulkyInfo.AllWeights,SmoothWindow,MCMCInfo.legend_names);    
    print(fullfile(output_folder,'WeightAndAcceptanceOverTimePlots',strcat(name,...
        '_WeightOverTime.png')),'-dpng');
    close(gcf);

    %If the time-consuming Rhat calculations were already done, we JUST
    %need to make the plot!
    if isempty(MCMCInfo.Rhats)
        convergence_evaluation(BulkyInfo.OccupanciesByStep,IP.nCopies,MCMCInfo.legend_names,...
            ConvergenceCriteria,MCMCInfo.NodeFreqs,parallelize,true);
    else
        convergenceResults_plot(MCMCInfo.Rhats,MCMCInfo.ConvergenceTable,...
            MCMCInfo.legend_names);
    end
    print(fullfile(output_folder,'ConvergencePlots',strcat(name,'_ConvergencePlot.png')),'-dpng');
    close(gcf);
    clear BulkyInfo;

    %Make sequence frequency plots
    for j = 1:nTemps
        sequence_frequency_plot(CT,MCMCInfo.NodeFreqs{j},MCMCInfo.nSteps,...
            MCMCInfo.legend_names{j});
        print(fullfile(output_folder,strcat('NodeFreqs_Temp',num2str(j)),...
            strcat(name,'_NodeFreqs.png')),'-dpng');
        close(gcf);
    end

    %Make final acceptance rates plot
    finalAcceptanceRates_plot(MCMCInfo.AcceptedAndRejected,MCMCInfo.legend_names);
    print(fullfile(output_folder,'FinalAcceptancePlots',strcat(name,'_FinalAcceptances.png')),'-dpng');
    close(gcf);

    %Make 1D histograms
    NodeFreqs_to_Overlaid1DHist(MCMCInfo.NodeFreqs,CT,'cond',true);
    legend(MCMCInfo.legend_names);    
    print(fullfile(output_folder,'Cond1DHists',strcat(name,'_1Dcondhist.png')),'-dpng');
    close(gcf);
    clear MCMCInfo;
        
end