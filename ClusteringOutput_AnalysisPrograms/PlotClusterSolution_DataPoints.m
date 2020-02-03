function PlotClusterSolution_DataPoints(data, order, Y, T, eps, ...
    NormalizationStyle, PlotNoise)


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