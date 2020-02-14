function [peak_centers, peak_center_errors, hwhm] = fit_histogram_peak(...
    DataVector, n_Gaussians, binsper, ToPlot)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Given a vector of data, make a 1D histogram from
    %it and fit a given number of gaussians to the peak(s) of that 
    %histogram
    %
    %~~~INPUTS~~~:
    %
    %DataVector: a vector containing the data points that we will construct
    %   and fit a histogram of
    %
    %n_Guassians: the number of Gaussians that will be fit to the histogram
    %
    %binsper: the number of bins to use per unit in order to create the
    %   histogram.  Can be set to 'algorithm' to use the Freedman-Diaconis
    %   rule (this is also the default if this input is not passed in)
    %
    %ToPlot: logical variable; whether or not to display a plot and print
    %   out information about fitted peaks
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    % 
    %peak_centers: a vector containing the peak of each fitted Gaussian
    %
    %peak_center_errors: a vector containing the errors for each fitted
    %   Gaussian peak (from the 95% confidence invervals for those peak
    %   fits)
    %
    %hwhm: a vector containing the half width at half maximum of each
    %   fitted Gaussian
    
    
    %Default inputs
    if nargin < 4
        ToPlot = true;
    end
    if nargin < 3
        binsper = 'algorithm';
    end
    if nargin < 2
        n_Gaussians = 1;
    end
    
    %Find # of bins to use from IQR rule
    if strcmp(binsper, 'algorithm')
        width = 2 * iqr(DataVector) * length(DataVector)^(-1/3);
        binsper = 1/width;
        if ToPlot
            disp(strcat('Using',{' '},num2str(binsper),' bins per unit'));     
        end
    end
    
    %Get histogram data
    [counts, centers] = hist(DataVector, round(range(DataVector)*binsper));
    counts = counts';
    centers = centers';
    
    %Perform fit
    [~,peak_centers, peak_center_errors, hwhm] = fit_xyData_nGaussians(...
        centers,counts,n_Gaussians,ToPlot);

end