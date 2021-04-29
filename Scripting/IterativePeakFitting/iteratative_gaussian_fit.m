function peaks = iteratative_gaussian_fit(TraceStruct, initial_lb, ...
    initial_ub,ToPlot)

    if nargin < 4
        ToPlot = false;
    end
    if nargin < 3
        initial_ub = -2.5;
    end
    if nargin < 2
        initial_lb = -5.5;
    end
    
    %Get all conductance data
    TraceStruct = LoadTraceStruct(TraceStruct);
    %TraceStruct.convertTraces('Lin','Log');
    cond = TraceStruct.getAllData('c');

    %Trim conductance data:
    cond = cond(cond > initial_lb);
    cond = cond(cond < initial_ub);
    
    %Determine optimal # of bins, and do binning
    width = 2 * iqr(cond) * size(cond,1)^(-1/3);
    Nbins = round(range(cond)/width);
    [counts, centers] = hist(cond, Nbins);
    counts = counts';
    centers = centers';
    [x,y] = convert_to_histogram_endpoints(centers,counts);
    
    nIter = 10;
    peaks = zeros(nIter + 1,1);
    
    %Perform initial fit:
    [peaks(1),~,~] = restricted_gaussian_fit(centers, counts, initial_lb, initial_ub);
    
    %Perform iterative fits:
    halfrange = [1, 1, 0.75, 0.75, 0.75, 0.75, 0.5, 0.5, 0.5, 0.5];
    for i = 2:nIter+1
        [peaks(i),~,~] = restricted_gaussian_fit(centers, counts, peaks(i-1) - halfrange(i-1), ...
            peaks(i-1) + halfrange(i-1));
    end
    
    if ToPlot
        [~,xfit,yfit] = restricted_gaussian_fit(centers, counts, peaks(nIter+1) - 0.5, ...
                peaks(nIter+1) + 0.5, false);
            
        figure();
        hold on;
        plot(x,y);
        plot(xfit,yfit);
        legend({'Raw Data', 'Iterative Fit Result'});
    end
    
end