function sequenceWeight_overTime_plot(AllWeights,SmoothWindow,...
    legend_names)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: creates a plot showing how the sequence weight,
    %as a moving average, of MCMC steps at each temperature varied over the
    %course of the MCMC simulation.
    %
    %~~~INPUTS~~~:
    %
    %AllWeights: an nSteps x nTemps matrix containing the weight (that is,
    %   the average self-to-self pair strength) assigned to each
    %   node-sequence at each temperature at each MCMC step.
    %
    %SmoothWindow: the length of the window that will be used to compute
    %   the moving-average weights
    %
    %legend_names: cell array containing names for each MCMC sub-chain,
    %   which will be used as labels in the plot's legend
    
    
    if nargin < 2
        SmoothWindow = 1000;
    end
    if nargin < 3
        legend_names = {''};
    end

    nTemps = size(AllWeights,2);

    %Make a plot showing the rolling average sequence weight over time
    figure();
    hold on;
    for i = 1:nTemps
        plot(movmean(AllWeights(:,i),SmoothWindow));
    end
    legend(legend_names);
    xlabel('Step #');
    ylabel('Sequence Weight Rolling Average');
    
end