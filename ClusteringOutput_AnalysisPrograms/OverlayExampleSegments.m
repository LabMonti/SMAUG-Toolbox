function OverlayExampleSegments(Y, T, PlotNoise, AllBounds, ...
    SegmentTraceIDs, TracesUsed,ExSegs2Plot)
        
    nClust = max(Y);

    %Sort bounds and segment trace IDs by cluster ID
    [~, sortI] = sort(Y);
    AllBounds = AllBounds(sortI,:);
    SegmentTraceIDs = SegmentTraceIDs(sortI);

    %Get cluster colors:
    clust_colors = distinguishable_colors(nClust);

    hold on;
    counter = T(1,2); %Skip the noise cluster for now
    for i = 1:nClust

        nSegs_in_Cluster = T(i+1,2);
        n = min(nSegs_in_Cluster, ExSegs2Plot); %Make sure we don't try to pull more segments than exist in the cluster!

        %Get index #s for segments we want to plot, and for the traces
        %they belong to
        segIDs = randperm(nSegs_in_Cluster, n) + counter;
        traceIDs = SegmentTraceIDs(segIDs);

        for j = 1:length(segIDs)
            %Get the trace the segment belongs to
            %%%tr = TracesUsed.(strcat('Trace',num2str(traceIDs(j))));
            tr = TracesUsed{traceIDs(j)};

            %Get the segment from the trace
            seg = tr(AllBounds(segIDs(j),1):AllBounds(segIDs(j),2),:);

            %Plot the segment in the correct cluster color (mixed with
            %15 percent black to make it show up better)
            plot(seg(:,1),10.^seg(:,2),'Color',0.80*clust_colors(i,:));

        end

        counter = counter + nSegs_in_Cluster;

    end

    %Plot example segments from the noise, if it's being plotted:
    if PlotNoise
        nSegs_in_Cluster = T(1,2);
        n = min(nSegs_in_Cluster, ExSegs2Plot);

        segIDs = randperm(nSegs_in_Cluster, n);
        traceIDs = SegmentTraceIDs(segIDs);

        for j = 1:length(segIDs)
            %Get the trace the segment belongs to
            %%%tr = TracesUsed.(strcat('Trace',num2str(traceIDs(j))));
            tr = TracesUsed{traceIDs(j)};

            %Get the segment from the trace
            seg = tr(AllBounds(segIDs(j),1):AllBounds(segIDs(j),2),:);

            %Plot the segment in dark gray
            plot(seg(:,1),10.^seg(:,2),'Color',[0.425 0.425 0.425]);
        end

    end
    hold off;
        
    
end