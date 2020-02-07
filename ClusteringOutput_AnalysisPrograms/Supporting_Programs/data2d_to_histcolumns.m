function HistColumns = data2d_to_histcolumns(data, bins_per_x, ...
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
    %data: a two-column matrix with distance in the first column and 
    %   conductance (or Log(conductance)) in the second column
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


    %Get 2D histogram counts and centers
    Nbins = [round(range(data(:,1))*bins_per_x),round(range(...
        data(:,2))*bins_per_y)];
    [counts, centers] = hist3(data, Nbins);

    %Put data into a 3-column matrix for easy plotting with scatter
    nX = length(centers{1});
    nY = length(centers{2});
    HistColumns = zeros(nX*nY,3);
    counter = 0;
    for i = 1:nX
        for j = 1:nY
            if counts(i,j) > 0
                counter = counter + 1;
                HistColumns(counter,1) = centers{1}(i);
                HistColumns(counter,2) = centers{2}(j);
                HistColumns(counter,3) = counts(i,j);
            end
        end
    end
    HistColumns = HistColumns(1:counter,:);
    
end