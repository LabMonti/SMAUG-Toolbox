function [yHat, peak_centers, peak_center_errors, hwhm] = fit_xyData_nGaussians(...
    xData, yData, n_Gaussians, ToPlot)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: given x- and y-data, fits the data with an
    %integer number of Gaussian peaks
    %
    %~~~INPUTS~~~:
    %
    %xData: a vector of the x-data
    %
    %yData: a vector of the y-data
    %
    %n_Gaussians: the # of Gaussians that should be fit to the data
    %
    %ToPlot: logical variable; if true, data and fit will be plotted
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %yHat: if mulitiple peaks were fit, yHat is an n+1 column matrix in
    %   which the first n columns contain the values of the fitted peaks at
    %   each value of xData and the last column contains the total fit; if
    %   only one peak was fit then yHat is just a single column containing
    %   the fit at each xData value.  
    %
    %peak_centers: the center of each fitted peak
    %
    %peak_center_errors: the error (from fitting) of each fitted peak
    %
    %hwhm: the half width at half maximum of each fitted peak
    
    
    if nargin < 4
        ToPlot = false;
    end
    if nargin < 3
        n_Gaussians = 1;
    end
    
    %Make sure xData and yData are in column vector form
    if size(xData,1) < size(xData,2)
        xData = xData';
    end
    if size(yData,1) < size(yData,2)
        yData = yData';
    end
    
    peak_centers = zeros(n_Gaussians, 1);
    peak_center_errors = zeros(n_Gaussians, 1);
    hwhm = zeros(n_Gaussians, 1);
    
    %Create fit
    fit_type = strcat('gauss', num2str(n_Gaussians));
    low_bound = zeros(1,3*n_Gaussians);
    counter = 0;
    for i = 1:n_Gaussians
        low_bound(counter+1:counter+3) = [0, -Inf, 0];
        counter = counter + 3;
    end
    peak_fit = fit(xData, yData, fit_type, 'Lower', low_bound);
    
    %Return the fits for each individual peak as well as the total fit
    %(unless only one Gaussian requested, in which case the total would be
    %redundant)
    if n_Gaussians > 1
        yHat = zeros(length(xData), n_Gaussians + 1);
    else
        yHat = zeros(length(xData), 1);
    end
    
    %Fill in fits:
    for i = 1:n_Gaussians
        a = peak_fit.(strcat('a',num2str(i)));
        b = peak_fit.(strcat('b',num2str(i)));
        c = peak_fit.(strcat('c',num2str(i)));      
        
        yHat(:,i) = a*exp(-((xData - b)./c).^2);
    end
    if n_Gaussians > 1
        yHat(:,n_Gaussians+1) = sum(yHat(:,1:n_Gaussians),2);
    end
    
    if ToPlot
        figure();
        [NewX, NewY] = convert_to_histogram_endpoints(xData, yData);
        plot(NewX, NewY);

        hold on;
        plot(peak_fit);
        legend({'Histogram Data', 'Total Fit'},'autoupdate', 'off');
        if n_Gaussians > 1
            for i = 1:n_Gaussians
                plot(xData, yHat(:,i), '--');
            end
        end
        hold off;
        ylim([0 max(yData)*1.1]);
    end
    
    %Print out peak centers with 95% confidence bound error:
    ci = confint(peak_fit);
    for i = 1:n_Gaussians
        b = peak_fit.(strcat('b',num2str(i)));
        c = peak_fit.(strcat('c',num2str(i)));
        
        %Bounds
        lb = ci(1,3*(i-1) + 2);
        ub = ci(2,3*(i-1) + 2);
        err = (ub - lb) / 2;
        
        if ToPlot
            disp(strcat('Peak position:', {' '}, num2str(b), ' +/-',{' '}, ...
                num2str(err)));
        end
        
        peak_centers(i) = b;
        peak_center_errors(i) = err;
        
        hwhm(i) = c*sqrt(log(2));
        
    end

end