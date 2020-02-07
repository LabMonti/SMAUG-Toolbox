function add_histcolumndata_to_plot(ColumnData, ColorData)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: add histogram data to an already existing plot
    %
    %~~~INPUTS~~~:
    %
    %ColumnData: two-column matrix containing x- and y-values of each bin
    %   center in the two columns
    %
    %ColorData: three-column matrix containing the color triplets for each
    %   histogram bin
    

    scatter(ColumnData(:,1), 10.^ColumnData(:,2), 100, ColorData,...
        'filled', 's');
    
end