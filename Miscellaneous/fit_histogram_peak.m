%27Sep18 NDB: Given a vector of data, make a 1D histogram from it and fit a
%given number of gaussians to the peak(s) of that histogram
function [peak_centers, peak_center_errors, hwhm] = fit_histogram_peak(...
    DataVector, n_Gaussians, binsper, ToPlot)
    
    if nargin < 4
        ToPlot = true;
    end
    if nargin < 3
        binsper = 'algorithm';
    end
    if nargin < 2
        n_Gaussians = 1;
    end
    
    peak_centers = zeros(n_Gaussians, 1);
    peak_center_errors = zeros(n_Gaussians, 1);
    hwhm = zeros(n_Gaussians, 1);
    
    %Find # of bins to use from IQR rule
    if strcmp(binsper, 'algorithm')
        width = 2 * iqr(DataVector) * length(DataVector)^(-1/3);
        binsper = 1/width;
        if ToPlot
            disp(strcat('Using',{' '},num2str(binsper),' bins per unit'));     
        end
    end
    
    [counts, centers] = hist(DataVector, round(range(DataVector)*binsper));
    counts = counts';
    centers = centers';
    
    %Create fit
    fit_type = strcat('gauss', num2str(n_Gaussians));
    low_bound = zeros(1,3*n_Gaussians);
    counter = 0;
    for i = 1:n_Gaussians
        low_bound(counter+1:counter+3) = [0, -Inf, 0];
        counter = counter + 3;
    end
    peak_fit = fit(centers, counts, fit_type, 'Lower', low_bound);
    
    if ToPlot
        figure();
        [NewX, NewY] = convert_to_histogram_endpoints(centers, counts);
        plot(NewX, NewY);

        hold on;
        plot(peak_fit);
        legend({'Histogram Data', 'Total Fit'},'autoupdate', 'off');
        if n_Gaussians > 1
            for i = 1:n_Gaussians
                a = peak_fit.(strcat('a',num2str(i)));
                b = peak_fit.(strcat('b',num2str(i)));
                c = peak_fit.(strcat('c',num2str(i)));

                yhat = a*exp(-((centers - b)./c).^2);
                plot(centers, yhat, '--');
            end
        end
        hold off;
        ylim([0 max(counts)*1.1]);
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