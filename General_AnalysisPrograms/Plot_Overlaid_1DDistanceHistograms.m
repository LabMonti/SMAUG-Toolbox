%14Sep2018 NDB: A single function to find the 1D distance histograms for
%multiple data sets and plot them overlaid on top of each other
function Plot_Overlaid_1DDistanceHistograms(TraceStructList,linesper_y,...
    binsper_x, UpperCondChop, NormalizeCounts, LegendOverride)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: finds the 1D distance histograms for
    %multiple data sets and plot them overlaid on top of each other
    %
    %~~~INPUTS~~~:
    %
    %TraceStructList: a 1D cell array containing a TraceStruct in each cell
    %   (the data sets to be plotted together)
    %
    %linesper_y: the # of horizontal resampling lines to use per unit on
    %   the y-axis
    %
    %binsper_x: the # of bins per unit in the 1D distance histogram that
    %   will be created
    %
    %UpperCondChop: the portions of traces with conductances above this
    %   value will be removed prior to processing. Can be set to '[]' to
    %   not use any conductance chop.  In units of G_0, NOT logged!
    %
    %NormalizeCounts: if 0/false, leave raw counts; if 1/true, normalize
    %   to counts per trace; if 2, normalize to probability density
    %
    %LegendOverride: a cell array with the same length as TraceStructList,
    %   containing the names the user wants to use for each data set in the
    %   plot's legend


    %Default inputs
    if nargin < 6
        LegendOverride = [];
    end
    if nargin < 5
        NormalizeCounts = true;
    end
    if nargin < 4
        UpperCondChop = [];
    end
    if nargin < 3
        binsper_x = 40;
    end
    if nargin < 2
        linesper_y = 50;
    end
    if strcmp(binsper_x,'algorithm') && NormalizeCounts ~= 2
        disp('Do not use algorithm for bin widths if counts are not properly normalized!  Re-setting binsper_x to 40.');
        binsper_x = 40;
    end
    
    N_datasets = length(TraceStructList);
    
    if ~isempty(LegendOverride) && N_datasets ~= length(LegendOverride)
        error('Number of legend entries does not match number of data sets');
    end
    
   %Get gradient of colors from blue to red:
    plot_colors = zeros(N_datasets, 3);
    plot_colors(:,1) = linspace(0, 1, N_datasets);
    plot_colors(:,3) = linspace(1, 0, N_datasets); 
    
    figure();
    hold on;
    for i = 1:N_datasets
        TS = TraceStructList{i};
        [counts, centers] = Make1D_DistanceHistogram(TS,linesper_y,...
            binsper_x,UpperCondChop,1,'max',NormalizeCounts,'DisplayOff', true);       
        
        [centers, counts] = convert_to_histogram_endpoints(centers,counts);
        plot(centers, counts, 'Color', plot_colors(i,:));   
    end
    hold off;
    
    %In order to label the axes and set the plot limits, we will assume 
    %that the information in the first trace structure applies to all of 
    %them:
    TS = LoadTraceStruct(TraceStructList{1});
    
    %Label x-axis
    if abs(TS.attenuation_ratio - 1) < 0.1
        distance_type = 'Piezo Distance';
    else
        distance_type = 'Inter-Electrode Distance';
    end
    xlabel(strcat(distance_type,' (', TS.x_units,')'),'FontSize',14);  
    
    %Label y-axis
    if NormalizeCounts == 2
        ylabel('Probability Density','FontSize',14);
    elseif NormalizeCounts == 1
        ylabel('Counts per Trace','FontSize',14);
    else
        ylabel('Counts','FontSize',14);
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