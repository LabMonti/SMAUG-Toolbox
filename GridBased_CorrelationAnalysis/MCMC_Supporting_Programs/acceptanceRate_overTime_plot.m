function acceptanceRate_overTime_plot(AcceptanceRates,SmoothWindow,...
    legend_names)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: creates a plot showing how the acceptance rate,
    %as a moving average, of MCMC steps at each temperature varied over the
    %course of the MCMC simulation.
    %
    %~~~INPUTS~~~:
    %
    %AcceptanceRates: an nTemp-long cell aray, with each cell containing 
    %   a logical vector listing whether each MCMC step for that
    %   temperature's sub-chain was accepted or not
    %
    %SmoothWindow: the length of the window that will be used to compute
    %   the moving-average acceptance rates
    %
    %legend_names: cell array containing names for each MCMC sub-chain,
    %   which will be used as labels in the plot's legend
    
    
    if nargin < 2
        SmoothWindow = 1000;
    end
    if nargin < 3
        legend_names = cell(nTemps,1);
        for i = 1:nTemps
            legend_names{i} = strcat('Temperature #',num2str(i));
        end
    end

    nTemps = length(AcceptanceRates);

    %Make a plot to show the acceptance rate for each temperature over time
    figure();
    hold on;
    for i = 1:nTemps
        plot(movmean(AcceptanceRates{i},SmoothWindow));
    end
    xlabel('Step #');
    ylabel('Rolling Average Acceptance Rate');
    legend(legend_names);
    
end