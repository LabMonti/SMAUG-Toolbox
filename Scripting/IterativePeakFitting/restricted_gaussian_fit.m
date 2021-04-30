function [peak,xdata,yhat] = restricted_gaussian_fit(xdata, ydata, lower_bound, ...
    upper_bound, ToPlot)

    if nargin < 5
        ToPlot = false;
    end

    %Only keep data in given range:
    ydata = ydata(xdata > lower_bound);
    xdata = xdata(xdata > lower_bound);
    ydata = ydata(xdata < upper_bound);
    xdata = xdata(xdata < upper_bound);

    %Perform the single-gaussian fit, requiring the gaussina peak to fall
    %within the data range
    min_params = [0, lower_bound, 0];
    max_params = [Inf, upper_bound, Inf];
    peak_fit = fit(xdata, ydata, 'gauss1', 'Lower', min_params, 'Upper', max_params);

    %Extract best fit parameters
    a = peak_fit.a1;
    b = peak_fit.b1;
    c = peak_fit.c1;  

    %Get peak and fitted curve
    peak = b;      
    yhat = a*exp(-((xdata - b)./c).^2);
    
    if ToPlot
        figure();
        hold on;
        [x,y] = convert_to_histogram_endpoints(xdata,ydata);
        plot(x,y);
        plot(xdata,yhat);
    end
    
end