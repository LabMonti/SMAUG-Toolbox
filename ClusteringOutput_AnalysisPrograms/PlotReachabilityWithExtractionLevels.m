function PlotReachabilityWithExtractionLevels(OutputStruct, cutoff_fraction)

    RD = OutputStruct.RD;
    
    [~, peak_values] = FindReachabilityPeaks(RD, cutoff_fraction);
    
    figure();
    plot(RD);
    hold on;
    for i = 1:length(peak_values)
        plot([0 length(RD)], [peak_values(i) peak_values(i)]);
    end    
    disp(length(peak_values));
    hold off;
    xlabel('Cluster Order');
    ylabel('Reachability Distance');

end