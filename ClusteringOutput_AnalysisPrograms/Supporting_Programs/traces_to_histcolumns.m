function HistColumns = traces_to_histcolumns(Traces, bins_per_x, ...
    bins_per_y)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: given a cell array of traces, this function
    %creates a 2D histogram of all the data points and transforms that data
    %into a convenient column form for use in the "scatter" function
    %
    %~~~INPUTS~~~:
    %
    %Traces: a cell array of traces, with each trace represented as a
    %   two-column matrix with distance in the first column and conductance
    %   (or Log(conductance)) in the second column
    %
    %bins_per_x/bins_per_y: number of bins to use per unit on the x- and y-
    %   axes, respectively
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %HistColumns: a three-column matrix with the x- and y- centers of each
    %   histogram bin in the first two columns and the bin count in the
    %   third column

    %Get data to make 2D histogram of data:
    nT = length(Traces);
    ColumnData = zeros(nT*10000,2);
    counter = 0;
    for i = 1:nT
        tr = Traces{i};
        n = size(tr,1);

        ColumnData(counter+1:counter+n,:) = tr;
        counter = counter + n;
    end
    ColumnData = ColumnData(1:counter,:);

    HistColumns = data2d_to_histcolumns(ColumnData,bins_per_x,bins_per_y);
    
end