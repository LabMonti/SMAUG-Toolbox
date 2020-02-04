function [counts, centers] = make2DHistogram_fromArbitraryData(DataArray, ...
    NBins, LinLog, CountScalar)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: makes a 2D histogram give two-column 2D data, 
    %no matter what the data is for the most part
    %
    %~~~INPUTS~~~:
    %
    %DataArray: a two-column array containing the coordinates of a set of
    %   2D points
    %
    %NBins: a two-element vector containing the total # of bins to use in
    %   the x- and y-directions, respectively
    %
    %LinLog: a two-element cell array containing either "Lin" or "Log" in
    %   each element to specify whether x- and y- should be plotted on
    %   linear or logarithmic scales
    %
    %CountScalar: a scalar that will be applied to the count values (e.g.
    %   the number of traces contributing to the histogram)
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %counts: a 2D-array containing the number of points assigned to each
    %   bin
    %
    %centers: a 2-element cell array, with the centers of each bin in the
    %   x-dimension stored in a vector in the first element and the centers
    %   of each bin in the y-dimension stored in a vector in the second
    %   element
    
    
    if nargin < 4
        CountScalar = 1;
    end
    
    for i = 1:2
        if ~strcmp(LinLog{i},'Log') && ~strcmp(LinLog{i},'Lin')
            error('The parameter "LinLog" can only have the values "Lin" or "Log"');
        end
    end
    
    [counts, centers] = hist3(DataArray, NBins);
    counts = counts * CountScalar; %Scale the counts

    %Get X and Y-edges
    edges = cell(2,1);
    for i = 1:2
        edges{i} = zeros(length(centers{i})+1,1);
        step = (centers{i}(2) - centers{i}(1))/2;
        edges{i}(1) = centers{i}(1) - step;
        for j = 1:length(centers{i})
            edges{i}(j+1) = centers{i}(j) + step;
        end      
        
        if strcmp(LinLog{i},'Log')
            edges{i} = 10.^edges{i};
        end           
    end
    
    figure();
    histogram2('XBinEdges',edges{1},'YBinEdges',edges{2},'BinCounts',counts,...
        'DisplayStyle','tile','LineStyle','none');
    cmap = importdata('cmap.mat');
    colormap(cmap);
    colorbar();
    grid off;

    if strcmp(LinLog{1},'Log')
        set(gca,'XScale','log');
    end    
    if strcmp(LinLog{2},'Log')
        set(gca,'YScale','log');
    end    

end