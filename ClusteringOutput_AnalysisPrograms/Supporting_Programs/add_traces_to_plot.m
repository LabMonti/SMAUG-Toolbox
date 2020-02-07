function add_traces_to_plot(TraceCellArray, color_vector)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: adds traces to an already existing figure
    %
    %~~~INPUTS~~~:
    %
    %TraceCellArray: cell array containing one 2-column matrix representing
    %   a trace in each cell
    %
    %color_vector: three-column matrix containing the color that each
    %   segment should be plotted in (can also be a just a single color
    %   triple if all segments should be the same color)

    
    if size(color_vector,1) == 1
        color_vector = repmat(color_vector,length(TraceCellArray),1);
    end        
    
    for i = 1:length(TraceCellArray)
        trace = TraceCellArray{i};
        xdata = trace(:,1);
        ydata = trace(:,2);
        
        p = plot(xdata, 10.^ydata,'LineWidth',0.1,'Color',color_vector(i,:));
        p.Color(4) = 0.1;
    end

end