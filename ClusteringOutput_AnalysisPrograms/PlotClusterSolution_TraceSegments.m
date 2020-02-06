%10May2018 NDB: Plot a specific clustering solution based on the "Segment"
%format of clustering, but for the actual plotting, get the original trace
%segments that each segment was fit to and plot those trace segments
function PlotClusterSolution_TraceSegments(OutputStruct, Y, T, eps, PlotNoise)
    %~~~INPUTS~~~:
    %
    %OutputStruct: structure containing clustering output
    %
    %Y: vector of cluster assignments for each point (in order of cluster
    %   order)
    %
    %T: array of cluster sizes (1st column: cluster ID, 2nd column: #
    %   points in cluster, 3rd column: fraction of points in cluster)
    %
    %eps: the value of epsilon at which extraction takes place; clusters
    %   will be valleys that exist below this cut-off value in the
    %   reachability plot
    %
    %PlotNoise: logical variable, whether to visibly plot the noise cluster
    %   or not
    
    
    if nargin < 5
        PlotNoise = false;
    end
    
    disp('Finding true trace segments...');

    order = OutputStruct.order;
    AllBounds = OutputStruct.AllBounds;
    SegmentTraceIDs = OutputStruct.SegmentTraceIDs;
    
    %Re-order data arrays to correspond to ordering of points in Y
    AllBounds = AllBounds(order,:);
    SegmentTraceIDs = SegmentTraceIDs(order,:);
    nSegs = size(AllBounds,1); 
    
    %Make cell array to hold all trace segments
    TraceSegments = cell(nSegs, 1);
    
    for i = 1:nSegs
        %Find the trace that the current segment belongs to
        TraceID = SegmentTraceIDs(i);
        %%%trace = OutputStruct.TracesUsed.(strcat('Trace',num2str(TraceID)));
        trace = OutputStruct.TracesUsed{TraceID};
        
        %Get all points in region this segment was fit to
        segment = trace(AllBounds(i,1):AllBounds(i,2),:);
        TraceSegments{i} = segment;
    end

    disp('Plotting cluster solution...');
    
    %get colors for each non-noise cluster
    nClust = size(T,1);
    nNonNoiseClusts = nClust - 1;
    cluster_colors = distinguishable_colors(nNonNoiseClusts);

    if PlotNoise
        cluster_colors = [0.5 0.5 0.5; cluster_colors];
        offset = 1;
    else
        TraceSegments = TraceSegments(Y > 0);
        Y = Y(Y > 0);
        offset = 0;
    end
    N = length(Y);
       
    %Assign a color to each trace segment representing its cluster
    %assignment
    TrCols = zeros(N, 3);
    for i = 1:N
        TrCols(i, :) = cluster_colors(Y(i)+offset, :);
    end
    
    figure();
    set(gca, 'ColorOrder', TrCols, 'NextPlot', 'replacechildren');
    
    hold on;
    for i = 1:length(TraceSegments)
        trace = TraceSegments{i};
        xdata = trace(:,1);
        ydata = trace(:,2);
        
        p = plot(xdata, 10.^ydata,'LineWidth',0.1);
        p.Color(4) = 0.1;
    end
    hold off;
    
    set(gca,'yscale','log');
    
    %If noise is not being plotted, add a white section on the color bar to
    %represent the noise (Needs to happend AFTER the plotting of segments
    %so that we don't screw up cluster_colors's indexing)
    if ~PlotNoise
        cluster_colors = [1 1 1; cluster_colors];
    end
    
    %Append cluster percentages to each cluster:
    newlabels = cell(1,nClust);
    for i = 1:nClust
        percentage = T(i,3)*100;
        newlabels(i) = strcat(num2str(T(i,1)),{', '}, num2str(percentage,2),'%');
    end
    
    %plot(Xdist, data, 'LineWidth', 0.1);
    colormap(cluster_colors);
    lcolorbar(newlabels);
    title(strcat('For eps =',{' '},num2str(eps)));
    ylim([10^(-6) 10]);
    xlabel('Interelectrode Distance (nm)');
    ylabel('Conductance/G0');

end