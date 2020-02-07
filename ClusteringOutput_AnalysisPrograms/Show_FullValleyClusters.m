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
        ~strcmp(OutputStruct.Format,'Segments_LengthWeighted')
        PlotStyle = OutputStruct.Format;
    end
    
    %Get valleys and make the plot showing them:
    RD = OutputStruct.RD;
    CD = OutputStruct.CD;
    [valley_bounds, valley_tops] = NestedFullValleyClusters(RD,...
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
    PlotData = traces_to_histcolumns(OutputStruct.TracesUsed,100,40);
    prctile_bound = 40;
    threshold = prctile(PlotData(:,3),prctile_bound);
    PlotData = PlotData(PlotData(:,3) > threshold,:);
    PlotData(:,2) = 10.^PlotData(:,2);    
 
    order = OutputStruct.order;
    
    %Get all segments and put the list in the same order as the cluster
    %order
    AllSegments = OutputStruct.AllSegments;
    AllSegments = AllSegments(order,:);

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
        keep = true(length(order),1);
        if strcmp(OutputStruct.Format,'Segments_LengthWeighting')
            keep = OutputStruct.original_vs_duplicate;
            keep = keep(order);
            keep = keep(valley_bounds(i,1):valley_bounds(i,2));
        end
        
        
        if strcmp(PlotStyle,'LinearSegments')
               
            plot(PlotData(:,1),PlotData(:,2),'o','Color',[0.5 0.5 0.5],...
                'MarkerFaceColor',[0.5 0.5 0.5]); 

            valley_segments = AllSegments(valley_bounds(i,1):valley_bounds(i,2),:);
            valley_segments = valley_segments(keep,:);

            add_linearsegments_to_plot(valley_segments,clust_colors(i,:));       

            set(gca,'YScale','log');
            xlabel('Inter-Electrode Distance (nm)');
            ylabel('Conductance/G_0');

            xlim([-0.2 2]);
            ylim([1E-6 10]);                
        
        elseif strcmp(PlotStyle,'TraceSegments')
            
        else
            error(strcat('Unrecognized plotting style: ',PlotStyle));
        end       

        title(strcat('Solution #',num2str(soln_nums(i)),', Cluster #',...
            num2str(clust_nums(i)), ' (', num2str(valley_sizes(i)),'%)'));
        
        if ~isempty(save_name)
            print(strcat(save_name,'_Soln',num2str(soln_nums(i)),...
                '_Clust',num2str(clust_nums(i))),'-dpng');
            close;
        end
    end  

end