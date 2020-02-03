%NDB 29Jul19: Find all clusters corresponding to maximum valleys of at
%least a certain size, and plot the reachability plot showing those valleys
%as well as the clusters themselves
function [soln_nums, clust_nums] = Show_FullValleyClusters(OutputStruct, ...
    cutoff_frac, save_name)

    if nargin < 3
        save_name = [];
    end

    %Find all the valleys
    RD = OutputStruct.RD;
    CD = OutputStruct.CD;
    [valley_bounds, valley_tops] = Find_ReachabilityValleys(RD, ...
        cutoff_frac);    
    
%     %Figure out how many times each valley is nested (i.e., how many larger
%     %valleys it belongs to)
%     nVal = length(valley_tops);
%     nested = zeros(nVal,1);
%     for i = 1:nVal
%         for j = 1:nVal
%             %If valley i is contained within valley j
%             if valley_bounds(i,1) > valley_bounds(j,1) && ...
%                     valley_bounds(i,2) < valley_bounds(j,2)
%                 nested(i) = nested(i) + 1;
%             end
%         end
%     end
%     adjustment = max(valley_tops) * 0.01;
    
    Nclust = size(valley_bounds,1);
    clust_colors = distinguishable_colors(Nclust);
    
    %Sort valleys in decreasing order of their tops
    [valley_tops, sortI] = sort(valley_tops,'descend');
    valley_bounds = valley_bounds(sortI,:);
    
    %Find solution #s, cluster #s, and relative sizes of each valley
    [soln_nums, clust_nums] = assign_SolnNum_and_ClustNum_ToValleys(...
        valley_bounds, valley_tops, RD, CD, cutoff_frac);
    valley_sizes = valley_bounds(:,2) - valley_bounds(:,1);
    valley_sizes = valley_sizes ./ length(RD) * 100;
    
    %Make the reachability plot figure
    if isempty(save_name)
        figure();
    else
        %If the figure is getting saved, we won't visibly plot it (great
        %for running on a cluster)
        figure('visible','off');
    end
    plot(RD,'Color',[0 0 0]);
    ylim([0 max(valley_tops)*1.5]);
    xlabel('Cluster Order');
    ylabel('Reachability Distance');
    
    %Add each valley to the reachability plot figure
    hold on;
    for i = 1:Nclust
        xdata = (valley_bounds(i,1):valley_bounds(i,2))';
        ydata = RD(valley_bounds(i,1):valley_bounds(i,2));%% + nested(i) * adjustment;
        
        ydata = min(ydata, valley_tops(i));
        
        n = length(ydata);
        ydata(1) = valley_tops(i);
        ydata(n) = valley_tops(i);
        
        fill(xdata,ydata,clust_colors(i,:),'LineStyle','none');
    end
    hold off;
    
    %Save the figure and close it, if requested
    if ~isempty(save_name)
        print(strcat(save_name,'_ReachabilityPlot'),'-dpng');
        close;
    end
        
    %Get all segments and put the list in the same order as the cluster
    %order
    AllSegments = OutputStruct.AllSegments;
    order = OutputStruct.order;
    AllSegments = AllSegments(order,:);

%     %Plot the segments of each cluster
%     figure();
%     hold on;
%     for i = 1:Nclust
%         
%         valley_segments = AllSegments(valley_bounds(i,1):valley_bounds(i,2),:);
%         
%         %Remove duplicate segments if necessary
%         if strcmp(OutputStruct.Format,'Segments_LengthWeighting')
%             keep = OutputStruct.original_vs_duplicate;
%             keep = keep(order);
%             keep = keep(valley_bounds(i,1):valley_bounds(i,2));
%             valley_segments = valley_segments(keep,:);
%         end
%         
%         valley_segments = valley_segments';
%         valley_segments(3:4,:) = 10.^valley_segments(3:4,:);
%         line(valley_segments(1:2,:),valley_segments(3:4,:),'Color',clust_colors(i,:));
% 
%     end
%     set(gca,'YScale','log');
%     hold off;

    %Get data to make 2D histogram of data:
    nT = length(OutputStruct.TracesUsed);
    ColumnData = zeros(nT*10000,2);
    counter = 0;
    for i = 1:nT
        tr = OutputStruct.TracesUsed{i};
        n = size(tr,1);

        ColumnData(counter+1:counter+n,:) = tr;
        counter = counter + n;
    end
    ColumnData = ColumnData(1:counter,:);

    %Get 2D histogram counts and centers
    Nbins = [round(range(ColumnData(:,1))*100),round(range(ColumnData(:,2))*40)];
    [counts, centers] = hist3(ColumnData, Nbins);

    %Get data to plot; only keep bins above the 40th percentile in counts
    all_counts = counts(:);
    all_counts = all_counts(all_counts > 0);
    threshold = prctile(all_counts, 40);
    %%top_threshold = max(all_counts);
    nX = length(centers{1});
    nY = length(centers{2});
    PlotData = zeros(nX*nY,3);
    counter = 0;
    for i = 1:nX
        for j = 1:nY
            if counts(i,j) > threshold
                counter = counter + 1;
                PlotData(counter,1) = centers{1}(i);
                PlotData(counter,2) = centers{2}(j);
                PlotData(counter,3) = counts(i,j);
            end
        end
    end
    PlotData = PlotData(1:counter,:);
    PlotData(:,2) = 10.^PlotData(:,2);

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

        plot(PlotData(:,1),PlotData(:,2),'o','Color',[0.5 0.5 0.5],...
            'MarkerFaceColor',[0.5 0.5 0.5]);        

%         for j = 1:counter
%             plot(PlotData(j,1),PlotData(j,2),'o','Color',PlotData(j,3)/...
%                 top_threshold*[0.5 0.5 0.5],'MarkerFaceColor',PlotData(j,3)/...
%                 top_threshold*[0.5 0.5 0.5]);
%         end

        valley_segments = AllSegments(valley_bounds(i,1):valley_bounds(i,2),:);

        %Remove duplicate segments if necessary
        if strcmp(OutputStruct.Format,'Segments_LengthWeighting')
            keep = OutputStruct.original_vs_duplicate;
            keep = keep(order);
            keep = keep(valley_bounds(i,1):valley_bounds(i,2));
            valley_segments = valley_segments(keep,:);
        end

        valley_segments = valley_segments';
        valley_segments(3:4,:) = 10.^valley_segments(3:4,:);
        line(valley_segments(1:2,:),valley_segments(3:4,:),'Color',clust_colors(i,:));        

        set(gca,'YScale','log');
        xlabel('Inter-Electrode Distance (nm)');
        ylabel('Conductance/G_0');
        
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