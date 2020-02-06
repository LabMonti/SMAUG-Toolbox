function add_tracesegments_to_plot(traces_used, seg_trace_IDs, ...
    segment_bounds, color_vector)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: adds trace segments (the real section of the
    %original trace, not its linear approximation) to an already existing
    %figure
    %
    %~~~INPUTS~~~:
    %
    %traces_used: cell array containing the original traces used for
    %   segmentation
    %
    %seg_trace_IDs: vector indicating the ID# of the trace that each
    %   segment belongs to
    %
    %segment_bounds: a two-column matrix indicating the starting and ending
    %   points for each segment within the trace it comes from
    %
    %color_vector: a 3-column matrix indicating what color each trace
    %   segment should be plotted in

    
    hold on;
    Nsegs = length(seg_trace_IDs);
    for i = 1:Nsegs
        %Find the trace this segment belongs to
        TraceID = seg_trace_IDs(i);
        trace = traces_used{TraceID};
        
        %Get all points in region this segment was fit to
        segment = trace(segment_bounds(i,1):segment_bounds(i,2),:);
        
        %Plot the segment of the trace
        p = plot(segment(:,1), 10.^segment(:,2),'LineWidth',0.1,'Color',...
            color_vector(i,:));
        p.Color(4) = 0.1;
    end

end