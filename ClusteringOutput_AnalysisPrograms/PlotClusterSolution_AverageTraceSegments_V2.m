%10May2018 NDB: Plot a specific clustering solution based on the "Segment"
%format of clustering, but for the actual plotting, get the original trace
%segments that each segment was fit to and plot those trace segments
function PlotClusterSolution_AverageTraceSegments_V2(OutputStruct, Y, ...
    T, eps, PlotNoise, CentralPercents)
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
    
    if nargin < 6
        CentralPercents = [50 75 90];
    end
    CentralPercents = sort(CentralPercents, 'descend');
    if nargin < 5
        PlotNoise = false;
    end
    
    disp('Averaging Segments...');
    
    order = OutputStruct.order;   
    AlignedSegments = OutputStruct.AlignedSegments;
    ActiveRegions = OutputStruct.ActiveRegions;
    AllBounds = OutputStruct.AllBounds;
    Xdist = OutputStruct.Xdist;
    nSegs = size(AlignedSegments,1);
    nXvals = size(AlignedSegments,2);
    nPercentiles = length(CentralPercents);
    
    %Re-sort aligned segments to have same order as Y
    AlignedSegments = AlignedSegments(order,:);
    ActiveRegions = ActiveRegions(order,:);
    AllBounds = AllBounds(order,:);
    
    %Account for the possiblity that the noise cluster is empty
    if T(1,2) == 0
        offset = 0;
    else
        offset = 1;
    end
    
    %Sort the aligned segments to group segments from the same cluster
    [sortedY, sortI] = sort(Y);
    AlignedSegments = AlignedSegments(sortI,:);
    ActiveRegions = ActiveRegions(sortI,:);
    
    %Get # of clusters
    nClust = length(unique(Y));
    
    %Find # of segments at each xDist for each cluster:
    SegmentCounts = zeros(nXvals, nClust);

    %The ActivityMatrix says which segments exist at which x-values in
    %which clusters
    ActivityMatrix = false(nSegs, nXvals, nClust);
    AverageRegions = zeros(nClust, 2, nPercentiles);
    AverageRegions(:,1,1) = Inf;
    AverageRegions(:,2,1) = -Inf;
    
    %Find sum of conductance and # of conductance points in each cluster at
    %each x-distance.  Also get maximum extent of conductance points for
    %each cluster
    for i = 1:nSegs
        cluster_index = sortedY(i) + offset;
        ActivityMatrix(i,ActiveRegions(i,1):ActiveRegions(i,2),cluster_index) = true;
        
        SegmentCounts(ActiveRegions(i,1):ActiveRegions(i,2),cluster_index) = ...
            SegmentCounts(ActiveRegions(i,1):ActiveRegions(i,2),cluster_index) + 1;
        
        for j = ActiveRegions(i,1):ActiveRegions(i,2)

            %Get maximum extent of all active regions in the same cluster
            if ActiveRegions(i,1) < AverageRegions(cluster_index,1,1)
                AverageRegions(cluster_index,1,1) = ActiveRegions(i,1);
            end
            if ActiveRegions(i,2) > AverageRegions(cluster_index,2,1)
                AverageRegions(cluster_index,2,1) = ActiveRegions(i,2);
            end

        end
    end
    
    %Make an array to hold the median segment for each region, and an array
    %to hold the percentile bounds for the different regions
    MedianSegments = Inf(nXvals, nClust);
    PercentileRegions = Inf(nXvals, nClust, nPercentiles, 2);
    
    %The index bounds for each percentile region plus the median, for each
    %cluster
    ActiveBounds = zeros(nPercentiles + 1, nClust, 2);
    
    %Calculate median segment in each cluster at each x-value
    for j = 1:nClust  
        first_flag = true;
        last_flag = false;
        
        for i = 1:nXvals         
            if SegmentCounts(i,j) > 1
                %Get the conductances at the ith x-value for all segments
                %in the jth cluster, and take their median
                MedianSegments(i,j) = median(...
                    AlignedSegments(ActivityMatrix(:,i,j), i));
                
                %The first x-value for which we calculated a median
                if first_flag
                    ActiveBounds(1,j,1) = i;
                    first_flag = false;
                    last_flag = true;
                end
            else
                %The last x-value for which we calculated a median
                if last_flag
                    ActiveBounds(1,j,2) = i - 1;
                    last_flag = false;
                end
            end
        end
    end
    
    %Calculate bounds of central region for each percentile
    for k = 1:nPercentiles
        minNumPts = 100/(100 - CentralPercents(k)) * 4;

        low_prctile = (100 - CentralPercents(k))/2;
        high_prctile = 100 - low_prctile;        
        for j = 1:nClust
            first_flag = true;
            last_flag = false;
            
            for i = 1:nXvals
            
                
                if SegmentCounts(i,j) >= minNumPts
                    
                    data = AlignedSegments(ActivityMatrix(:,i,j), i);
                    
                    %Get lower bound:
                    PercentileRegions(i,j,k,1) = prctile(data,low_prctile);
                    
                    %Get upper bound:
                    PercentileRegions(i,j,k,2) = prctile(data,high_prctile);
                    
                    %The first x-value for which we calculated this region
                    if first_flag
                        ActiveBounds(k+1,j,1) = i;
                        first_flag = false;
                        last_flag = true;
                    end
                    
                else
                    %The last x-value for which we calculated a median
                    if last_flag
                        ActiveBounds(k+1,j,2) = i - 1;
                        last_flag = false;
                    end                    
                end
                
            end              
        end
    end    
       
    disp('Plotting cluster solution...');
    
    nNonNoiseClust = size(T,1) - 1;    
    cluster_colors = distinguishable_colors(nNonNoiseClust);
    if PlotNoise && T(1,2) > 0
        cluster_colors = [0.5 0.5 0.5; cluster_colors];
    end
    if T(1,2) > 0 && ~PlotNoise
        ActiveBounds = ActiveBounds(:,2:nClust,:);
        MedianSegments = MedianSegments(:,2:nClust);
        PercentileRegions = PercentileRegions(:,2:nClust,:,:);
        nClust = nClust - 1;
    end
    
    figure();
    hold on;
    for i = 1:nClust        
        add_averagesegment_to_plot(Xdist,MedianSegments(:,i),...
            PercentileRegions(:,i,:,:),squeeze(ActiveBounds(:,i,:)),...
            cluster_colors(i,:));
    end    
%     for i = 1:nClust
%         
%         %Plot the median as a single black line:
%         xdata = Xdist(ActiveBounds(1,i,1):ActiveBounds(1,i,2));
%         ydata = MedianSegments(ActiveBounds(1,i,1):ActiveBounds(1,i,2),i);
%         line(xdata,ydata,'Color',[0 0 0],'LineWidth',1.5);
%         
%         for j = 1:length(CentralPercents)
%             %If there were never enough points, ActiveBounds will be empty
%             %for given percentile, in which case don't plot
%             if ActiveBounds(j+1,i,1) > 0 && ActiveBounds(j+1,i,2) > 0
% 
%                 xdata = Xdist(ActiveBounds(j+1,i,1):ActiveBounds(j+1,i,2));
% 
%                 y_top = PercentileRegions(ActiveBounds(j+1,i,1):ActiveBounds(j+1,i,2),i,j,2);
%                 y_bottom = PercentileRegions(ActiveBounds(j+1,i,1):ActiveBounds(j+1,i,2),i,j,1);
% 
%                 Xperim = [xdata; flipud(xdata)];
%                 Yperim = [y_top; flipud(y_bottom)];
% 
%                 fill(Xperim,Yperim,cluster_colors(i,:),'FaceAlpha',0.4,'LineStyle','none');
% 
%     %             if j == 1
%     %                 fill(Xperim,Yperim,cluster_colors(i,:),'FaceAlpha',0.4,'LineStyle','none');
%     %             else
%     %                 fill(Xperim,Yperim,cluster_colors(i,:),'FaceColor','none','EdgeColor',cluster_colors(i,:));
%     %             end
%             end
%         end
%     end
    hold off;
    
    %Account for the fact that the noise cluster may be empty
    if PlotNoise && T(1,2) == 0
        nClust = nClust + 1;
        cluster_colors = [0.5 0.5 0.5; cluster_colors];
    end
    
    %If noise is not being PLOTTED, still include it in the color bar (as
    %white)
    if ~PlotNoise
        cluster_colors = [1 1 1; cluster_colors];
        nClust = nClust + 1;
    end
    
    %Append cluster percentages to each cluster:
    newlabels = cell(1,nClust);
    for i = 1:nClust
        percentage = T(i,3)*100;
        newlabels(i) = strcat(num2str(T(i,1)),{', '}, num2str(percentage,2),'%');
    end
    
    colormap(cluster_colors);
    lcolorbar(newlabels);

    title(strcat('For eps =',{' '},num2str(eps)));
    ylim([-6 1.5]);
    xlabel('Interelectrode Distance (nm)');
    ylabel('Log(Conductance/G0)');

end