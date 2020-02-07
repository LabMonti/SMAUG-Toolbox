function PlotClusterSolution_DataPoints(data, order, Y, T, eps, ...
    NormalizationStyle, PlotNoise)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: plot a cluster solution composed of individual
    %distance/conductance points
    %
    %~~~INPUTS~~~:
    %
    %data: two-column matrix containing all distance/conductance points
    %
    %order: vector explaining the cluster order.  If order(5) = 2, that
    %   means that the 5th point in the cluster order is the 2nd original
    %   data point
    %
    %Y: vector containing the cluster number assigned to each point
    %
    %T: table containing size information about each cluster
    %
    %eps: the value of epsilon at which extraction takes place; clusters
    %   will be valleys that exist below this cut-off value in the
    %   reachability plot
    %
    %NormalizationStyle: how the intensities of different clusters should
    %   be normalized; set to 'ColorMix' for relative normalizatoin,
    %   'MixedHeatMaps' for aboslute (see below for details)  


    %Find "optimal" bin widths in each dimension using the "IQR rule"
    nbins = zeros(2,1);
    for i = 1:2
        width = 2 * iqr(data(:,i)) * size(data,1)^(-1/4);
        nbins(i) = round(range(data(:,i)) / width);
    end

    %The color of each grid square will be determined by the RELATIVE
    %number of points belonging to each cluster that fall inside it
    %(even if noise is not being plotted, it will be factored in to all 
    %grid square colors as white; if it is being plotted, it will be 
    %factored in as gray).  
    if strcmp(NormalizationStyle,'ColorMix')
        
        PlotClusterSolution_DataPoints_ColorMix(data, order, Y, T, eps,...
            nbins(1), nbins(2), PlotNoise)
        
    %The color of each grid square will be determined by the ABSOLUTE
    %number of points belonging to each cluster that fall inside it.  Each
    %cluster is normalized individually such that its square with the most
    %points corresponds to fully saturated cluster color, then the
    %different clusters are mixed together.  Noise is completely ignored if
    %not being plotted).  
    elseif strcmp(NormalizationStyle,'MixedHeatMaps')
        
        PlotClusterSolution_DataPoints_MixedHeatMaps(data, order, Y, T, eps,...
            nbins(1), nbins(2), PlotNoise)   
        
    else
        error('INVALID NORMALIZATION STYLE; options are "ColorMix" or "MixedHeatMaps"');
    end

end