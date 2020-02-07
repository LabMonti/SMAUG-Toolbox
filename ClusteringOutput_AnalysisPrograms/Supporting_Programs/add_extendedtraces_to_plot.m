function add_extendedtraces_to_plot(Xdist, TraceMatrix, color_vector)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: adds extended traces to an already
    %existing figure
    %
    %~~~INPUTS~~~:
    %
    %Xdist: vector containing x-data for each trace in the trace matrix
    %
    %TraceMatrix: matrix in which each row corresponds to a all of the
    %   y-values from a trace
    %
    %color_vector: three-column matrix containing the color that each
    %   segment should be plotted in (can also be a just a single color
    %   triple if all segments should be the same color)

    
    if size(color_vector,1) == 1
        color_vector = repmat(color_vector,size(TraceMatrix,1),1);
    end        
    
    for i = 1:size(TraceMatrix,1)
        p = plot(Xdist, 10.^TraceMatrix(i,:),'LineWidth',0.1,'Color',color_vector(i,:));
        p.Color(4) = 0.1;
    end

end