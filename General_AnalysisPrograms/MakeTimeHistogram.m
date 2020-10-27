function MakeTimeHistogram(TraceStruct, tracesperbin, binsper_y, LinLog,...
    PlotMotorPosition)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Creates a "Time Histogram" showing how the 1D
    %conductance histograms for traces vary over time.  
    %
    %ATTRIBUTION NOTE: The idea of using time histograms to analyze
    %breaking traces in this way was introduced and developed by Solomon et
    %al. in doi.org/10.1063/1.4975180.  
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all the traces in a dataset
    %   and associated information
    %
    %tracesperbin: the # of traces that are combined into each bin along
    %   the x-axis
    %
    %binsper_y: how many bins to user per unit on the y-axis
    %
    %LinLog: Whether the y-axis (Conductance) should be on a linear or
    %   logarithmic scale; acceptable values are "Lin" and "Log"
    %
    %PlotMotorPosition: logical parameter specifying whether or not the
    %   motor position at the beginning of each trace should be plotted on
    %   top of the time histogram

    
    %Load trace structure
    TraceStruct = LoadTraceStruct(TraceStruct);
    
    %Default inputs
    if nargin < 5
        PlotMotorPosition = false;
    end
    if nargin < 4
        LinLog = 'Log';
    end
    if nargin < 3
        binsper_y = 30;
    end
    if nargin < 2
        tracesperbin = 5;
    end
    if nargin < 1 || nargin > 5
        error('Incorrect number of input parameters!');
    end

    if ~strcmp(LinLog,'Log') && ~strcmp(LinLog,'Lin')
        error('The parameter "LinLog" can only have the values "Lin" or "Log"');
    end
    
    NTraces = TraceStruct.Ntraces;
    
    %Convert Traces into appropriate space (linear or logarithmic); space
    %for x-data doesn't matter, so set it to linear arbitrarily
    TraceStruct.convertTraces('Lin',LinLog);
    
    %Put data into a single matrix, first column trace number, second is
    %conductance
    ColumnData = zeros(TraceStruct.NumTotalPoints, 2);
    counter = 0;
    for i = 1:NTraces
        tr = TraceStruct.Traces{i};
        n = size(tr,1);
        ColumnData(counter+1:counter+n, 1) = i;
        ColumnData(counter+1:counter+n, 2) = tr(:,2);
        counter = counter + n;
    end
    
    NBins_x = round(NTraces/tracesperbin);
    NBins_y = round(binsper_y * range(ColumnData(:,2)));
    
    %Make the 2D histogram and get the counts back (the x scale is always
    %plotted in linear space)
    counts = make2DHistogram_fromArbitraryData(ColumnData,[NBins_x NBins_y], {'Lin' LinLog});
           
    top_of_color_scale = prctile(counts(1:NBins_x*NBins_y), 95);
    caxis([0 top_of_color_scale]);    
    
    %Get noise floor:
    nf = TraceStruct.NoiseFloor;
    
    %Get maximum conductance to plot:
    max_cond_4plot = prctile(ColumnData(:,2),97);
    
    cmap = importdata('cmap.mat');
    colormap(cmap);
    colorbar();
    xlabel('Trace #');
    if strcmp(LinLog, 'Log')
        ymin = nf;
        ymax = 10^max_cond_4plot;
    elseif strcmp(LinLog, 'Lin')
        ymin = 0;
        ymax = max_cond_4plot;
    end
    ylim([ymin ymax]);
    ylabel(strcat('Conductance/',TraceStruct.y_units));
    
    %Plot lines showing where program was paused:
    if ~isempty(TraceStruct.PauseNumbers)
        pn = TraceStruct.PauseNumbers;
        hold on;
        for i = 1:length(pn)
            plot([pn(i) pn(i)], [ymin ymax], 'Color',[0 0 0],...
                'LineWidth',2,'LineStyle','--');
        end
        hold off;
    end
    
    %If the input structure is a combo file, add lines showing where data
    %sets have been combined!
    if strcmp(TraceStruct.combo,'yes')
        hold on
        nLines = TraceStruct.Ncombo - 1;
        sum = 0;
        %Find partial sums of number of traces in each component, at each
        %value make a vertical line on top of the plot
        for i = 1:nLines
            sum = sum + TraceStruct.Ntraces_components(i);
            p = plot([sum, sum], [ymin ymax], 'k');
            p.LineWidth = 2;
        end
        hold off
    end
    
    %Add label to color bar
    f = gcf;
    f.Children(1).Label.String = 'Bin Count';
    f.Children(1).Label.Rotation = 270;
    f.Children(1).Label.VerticalAlignment = 'bottom';
    
    %Plot the motor position on top of the time histogram
    if PlotMotorPosition && ~isempty(TraceStruct.MotorPositions)
        
        %Move colorbar to top:
        cb = get(ancestor(gca,'axes'),'ColorBar');
        cb.Location = 'northoutside';
        cb.Label.Rotation = 0;
        
        motor_pos = TraceStruct.MotorPositions;
        hold on;
        yyaxis('right');
        plot(motor_pos,'-','LineWidth',2,'Color',[0 0 0]);
        hold off;
        ylabel('Motor Position (mm)');
    end    
    
    %Add title if TraceStruct comes with its own name
    title(strcat(TraceStruct.name, {' '}, 'Time Histogram'),'Interpreter','none');

end
