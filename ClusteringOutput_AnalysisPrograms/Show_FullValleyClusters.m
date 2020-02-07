%NDB 29Jul19: Find all clusters corresponding to maximum valleys of at
%least a certain size, and plot the reachability plot showing those valleys
%as well as the clusters themselves
function [soln_nums, clust_nums] = Show_FullValleyClusters(OutputStruct, ...
    cutoff_frac, PlotStyle, save_name)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: 
    %
    %~~~INPUTS~~~:
    %
    %
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    
    
    if nargin < 4
        save_name = [];
    end
    if nargin < 3
        PlotStyle = 'LinearSegments';
    end
    if nargin < 2
        cutoff_frac = 0.01;
    end
    
    %Set plot style for non-segment clustering modes:
    if ~strcmp(OutputStruct.Format,'Segments') && ... 
        ~strcmp(OutputStruct.Format,'Segments_LengthWeighting')
        PlotStyle = OutputStruct.Format;
    end
    
    %Get valleys and make the plot showing them:
    RD = OutputStruct.RD;
    CD = OutputStruct.CD;
    [valley_bounds, valley_tops] = NestedFullValleyClusters(OutputStruct,...
        cutoff_frac,save_name);  
    
    Nclust = size(valley_bounds,1);
    clust_colors = distinguishable_colors(Nclust);
    
    %Find solution #s, cluster #s, and relative sizes of each valley
    [soln_nums, clust_nums] = assign_SolnNum_and_ClustNum_ToValleys(...
        valley_bounds, valley_tops, RD, CD, cutoff_frac);
    valley_sizes = valley_bounds(:,2) - valley_bounds(:,1);
    valley_sizes = valley_sizes ./ length(RD) * 100;

    %Get data to make background 2D histogram (only include bins in the top
    %60% of counts to make the main structure clear)
    if strcmp(PlotStyle,'LinearSegments') || strcmp(PlotStyle,'TraceSegments')
        PlotData = traces_to_histcolumns(OutputStruct.TracesUsed,100,40);
        prctile_bound = 40;
        threshold = prctile(PlotData(:,3),prctile_bound);
        PlotData = PlotData(PlotData(:,3) > threshold,:);
        PlotData(:,2) = 10.^PlotData(:,2);    
    end
 
    order = OutputStruct.order;
    
    if strcmp(PlotStyle,'LinearSegments')
        AllSegments = OutputStruct.AllSegments(order,:);
    elseif strcmp(PlotStyle,'TraceSegments') || ...
            strcmp(PlotStyle,'SegmentPoints')
        AllBounds = OutputStruct.AllBounds(order,:);
        SegmentTraceIDs = OutputStruct.SegmentTraceIDs(order);
    elseif strcmp(PlotStyle,'AverageTraceSegments')
        OutputStruct = GetResampledSegments(OutputStruct);
    elseif strcmp(PlotStyle,'Histogram')
        data = OutputStruct.Xraw(order,:);
    elseif strcmp(PlotStyle,'ExtendedTraces')
        Xdist = OutputStruct.Xdist;
        data = OutputStruct.Xraw(order, :);
    end

    %Make a separate plot for each full-valley cluster:
    for i = 1:Nclust
        disp([i Nclust]);
        
        %Make figure
        if isempty(save_name)
            figure();
        else
            %If the figure is getting saved, we won't visibly plot it (great
            %for running on a cluster)
            figure('visible','off');
        end
        hold on;
        
        %Remove duplicate segments if necessary
        if strcmp(OutputStruct.Format,'Segments_LengthWeighting')
            keep = OutputStruct.original_vs_duplicate;
            keep = keep(order);
            keep = keep(valley_bounds(i,1):valley_bounds(i,2));
        else
            keep = true(valley_bounds(i,2)-valley_bounds(i,1) + 1, 1);
        end       
        
        if strcmp(PlotStyle,'LinearSegments')
               
            %Plot 2D histogram shape in the background
            plot(PlotData(:,1),PlotData(:,2),'o','Color',[0.5 0.5 0.5],...
                'MarkerFaceColor',[0.5 0.5 0.5]); 

            valley_segments = AllSegments(valley_bounds(i,1):valley_bounds(i,2),:);
            valley_segments = valley_segments(keep,:);

            add_linearsegments_to_plot(valley_segments,clust_colors(i,:));                      
        
        elseif strcmp(PlotStyle,'TraceSegments')            
            bounds = AllBounds(valley_bounds(i,1):valley_bounds(i,2),:);
            bounds = bounds(keep,:);
            IDs = SegmentTraceIDs(valley_bounds(i,1):valley_bounds(i,2));
            IDs = IDs(keep);
            
            %Plot 2D histogram shape in the background
            plot(PlotData(:,1),PlotData(:,2),'o','Color',[0.5 0.5 0.5],...
                'MarkerFaceColor',[0.5 0.5 0.5]); 
            
            add_tracesegments_to_plot(OutputStruct.TracesUsed,IDs,bounds,...
                clust_colors(i,:));
        
        elseif strcmp(PlotStyle,'SegmentPoints')
            %Find bounds and trace IDs for segments in cluster
            bounds = AllBounds(valley_bounds(i,1):valley_bounds(i,2),:);
            bounds = bounds(keep,:);
            IDs = SegmentTraceIDs(valley_bounds(i,1):valley_bounds(i,2));
            IDs = IDs(keep);
            
            %Collect data points from all segments in specified cluster
            data = zeros(length(OutputStruct.TracesUsed)*10000,2);
            counter = 0;
            for j = 1:length(IDs)
                n = bounds(j,2) - bounds(j,1) + 1;
                data(counter+1:counter+n,:) = OutputStruct.TracesUsed{...
                    IDs(j)}(bounds(j,1):bounds(j,2),:);
                counter = counter + n;
            end
            data = data(1:counter,:);
            
            %Get histogram data and use it to make the color of each bin
            %proportional to its count (normalized to the highest count
            %bin)
            hist_columns = data2d_to_histcolumns(data,100,40);
            MaxCount = max(hist_columns(:,3));
            cols = repmat(clust_colors(i,:),size(hist_columns,1),1);
            for j = 1:size(hist_columns,1)
                cols(j,:) = cols(j,:) * hist_columns(j,3)/MaxCount + ...
                    [1 1 1] * (1 - hist_columns(j,3)/MaxCount);
            end
            
            add_histcolumndata_to_plot(hist_columns,cols);
        elseif strcmp(PlotStyle,'AverageTraceSegments')
            add_histcolumndata_to_plot(data,clust_colors(i,:));
        elseif strcmp(PlotStyle,'Histogram')
            bins = data(valley_bounds(i,1):valley_bounds(i,2),:);
            bins = bins(keep,:);
            add_histcolumndata_to_plot(bins,clust_colors(i,:));
        elseif strcmp(PlotStyle,'ExtendedTraces')
            traces = data(valley_bounds(i,1):valley_bounds(i,2),:);
            traces = traces(keep,:);
            
        else
            error(strcat('Unrecognized plotting style: ',PlotStyle));
        end       

        set(gca,'YScale','log');
        xlabel('Inter-Electrode Distance (nm)');
        ylabel('Conductance/G_0'); 
        
        %May want to take this out depending on your data!
        xlim([-0.2 2]);
        ylim([1E-6 10]); 
        
        title(strcat('Solution #',num2str(soln_nums(i)),', Cluster #',...
            num2str(clust_nums(i)), ' (', num2str(valley_sizes(i)),'%)'));
        
        if ~isempty(save_name)
            print(strcat(save_name,'_Soln',num2str(soln_nums(i)),...
                '_Clust',num2str(clust_nums(i))),'-dpng');
            close;
        end
    end  

end