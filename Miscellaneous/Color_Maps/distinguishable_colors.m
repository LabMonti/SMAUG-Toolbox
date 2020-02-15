function RGB_list = distinguishable_colors(num_colors)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: produces a list of the requested number of
    %distinguishable colors (list will simply repeat if more than 50 colors
    %are requested).  Inspired by work from 2010-2011 by Timothy E. Holy.  
    %
    %~~~INPUTS~~~:
    %
    %num_colors: the number of different colors requested
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %RGB_list: 3-column matrix with num_colors different rows containing
    %   the RGB values for each of the different colors requested
    
    
    color_list = importdata('distinguishable_color_list.mat');
    n = size(color_list,1);
    
    if num_colors > n
        color_list = repmat(color_list, [ceil(num_colors/n),1]);
    end
    
    RGB_list = color_list(1:num_colors,:);

end