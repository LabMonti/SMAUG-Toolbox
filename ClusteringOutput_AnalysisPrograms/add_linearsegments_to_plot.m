function add_linearsegments_to_plot(segment_endpoints, color_vector)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: adds linear segment approximations to an already
    %existing figure
    %
    %~~~INPUTS~~~:
    %
    %segment_endpoints: four-column matrix with the first two columns
    %   containing the starting and ending x-values for each segment and 
    %   the second two columns containing the starting and ending y-values
    %
    %color_vector: three-column matrix containing the color that each
    %   segment should be plotted in (can also be a just a single color
    %   triple if all segments should be the same color)

    
    if size(color_vector,1) == 1
        color_vector = repmat(color_vector,size(segment_endpoints,1),1);
    end        
    
    for i = 1:size(segment_endpoints,1)
        line(segment_endpoints(i,1:2),10.^segment_endpoints(i,3:4),'Color',...
            color_vector(i,:));
    end

end