function peak = restricted_gaussian_fit(xdata, ydata, lower_bound, ...
    upper_bound, ToPlot)

    if nargin < 5
        ToPlot = false;
    end

    %Only keep data in given range:
    ydata = ydata(xdata > lower_bound);
    xdata = xdata(xdata > lower_bound);
    ydata = ydata(xdata < upper_bound);
    xdata = xdata(xdata < upper_bound);
    
    [~,peak] = fit_xyData_nGaussians(xdata,ydata,1,ToPlot);

end