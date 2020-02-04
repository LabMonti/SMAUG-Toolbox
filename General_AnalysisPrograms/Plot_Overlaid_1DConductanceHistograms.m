function Plot_Overlaid_1DConductanceHistograms(TraceStructList,...
    binsper_x, LinLog, NormalizeCounts, LegendOverride)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: finds the 1D conductance histograms for
    %multiple data sets and plot them overlaid on top of each other
    %
    %~~~INPUTS~~~:
    %
    %TraceStructList: a 1D cell array containing a TraceStruct in each cell
    %   (the data sets to be plotted together)
    %
    %binsper_x: how many bins to user per unit on the x-axis (Conductance)
    %
    %LinLog: Whether the x-axis (Conductance) should be on a linear or
    %   logarithmic scale; acceptable values are "Lin" and "Log"
    %
    %NormalizeCounts: if 0/false, leave raw counts; if 1/true, normalize
    %   to counts per trace; if 2, normalize to probability density
    %
    %LegendOverride: a cell array with the same length as TraceStructList,
    %   containing the names the user wants to use for each data set in the
    %   plot's legend


    %Default inputs
    if nargin < 5
        LegendOverride = [];
    end
    if nargin < 4
        NormalizeCounts = true;
    end
    if nargin < 3
        LinLog = 'Log';
    end
    if nargin < 2
        binsper_x = 40;
    end
    if strcmp(binsper_x,'algorithm') && NormalizeCounts ~= 2
        disp('Do not use algorithm for bin widths if counts are not properly normalized!  Re-setting binsper_x to 40.');
        binsper_x = 40;
    end
    
    N_datasets = length(TraceStructList);
    
    if ~isempty(LegendOverride) && N_datasets ~= length(LegendOverride)
        error('Number of legend entries does not match number of data sets');
    end
    if ~strcmp(LinLog,'Log') && ~strcmp(LinLog,'Lin')
        error('The parameter "LinLog" can only have the values "Lin" or "Log"');
    end
    
%     %Get gradient of colors from blue to red:
%     plot_colors = zeros(N_datasets, 3);
%     plot_colors(:,1) = linspace(0, 1, N_datasets);
%     plot_colors(:,3) = linspace(1, 0, N_datasets);  
    plot_colors = distinguishable_colors(N_datasets);
    
    figure();
    hold on;
    for i = 1:N_datasets
        TS = TraceStructList{i};
        [counts, centers] = Make1DHist_FromTraceStructure(TS, binsper_x,...
            1, 'max', LinLog, NormalizeCounts, true);
        
        [centers, counts] = convert_to_histogram_endpoints(centers,counts);
        plot(centers, counts, 'Color', plot_colors(i,:));        
    end
    hold off;
    
    %In order to label the axes and set the plot limits, we will assume 
    %that the information in the first trace structure applies to all of 
    %them:
    TS = LoadTraceStruct(TraceStructList{1});
    
    %Label x-axis and set x limits:
    if strcmp(LinLog, 'Lin')
        xlabel(strcat('Conductance/',TS.y_units));
        xlim([0 1.5]);
    elseif strcmp(LinLog, 'Log')
        xlabel(strcat('Log(Conductance/',TS.y_units,')'));
        xlim([log10(TS.NoiseFloor) 1.5]);
    end
    
    %Label y-axis
    if NormalizeCounts == 2
        ylabel('Probability Density');
    elseif NormalizeCounts == 1
        ylabel('Counts per Trace');
    else
        ylabel('Counts');
    end
    
    %Make a legend
    if isempty(LegendOverride)
        label_list = cell(N_datasets, 1);
        for i = 1:N_datasets
            label_list{i} = TraceStructList{i}.name;
        end
    else
        label_list = LegendOverride;
    end
    legend(label_list, 'Interpreter', 'none');
    
end