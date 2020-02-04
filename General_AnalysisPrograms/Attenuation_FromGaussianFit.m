function [atten_peak, atten_width, atten_error, FormPeakInfo] = ...
    Attenuation_FromGaussianFit(TraceStruct, StartTrace, EndTrace, ...
    min_cond, max_cond, ToPlot, IncludeForming)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Determine attenuation for a dataset by first 
    %finding the implied attenuation from each trace's slope in the defined
    %tunneling region, then fitting the distribution of attenuations with 
    %a single gaussian function.
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all the traces in a dataset
    %   and associated information
    %
    %StartTrace: the trace # of the first trace to be considered for the
    %   calculation
    %
    %EndTrace: the trace # of the last trace to be considered for the
    %   calculation
    %
    %min_cond/max_cond: the boundaries of the conductance window that will
    %   be used for fitting (in units of G0, not logged!)   
    %
    %ToPlot: logical variable; whether or not to plot a histogram of
    %   tunneling slopes
    %
    %IncludeForming: logical variable; whether or not to also plot the
    %   attenuations implied by the tunneling slopes of the forming traces
    %   (assuming that they exist in the trace structure)
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %atten_peak: attenuation at the peak value of the fit gaussian
    %
    %atten_width: half width at half maximum of the gaussian fit to the
    %   attenuation distribution
    %
    %atten_error: standard error in the gaussian peak from the fitting
    %   routine
    %
    %FormPeakInfo: structure containing information about the fit to the
    %   forming trace attenuations, if they exist

    
    TraceStruct = LoadTraceStruct(TraceStruct);
    Ntraces = TraceStruct.Ntraces;

    %Default inputs:
    if nargin < 7
        IncludeForming = true;
    end
    if nargin < 6
        ToPlot = true;
    end
    if nargin < 5
        max_cond = 2E-4;
    end
    if nargin < 4
        min_cond = 1E-5;
    end
    if nargin < 3 || strcmp(EndTrace, 'max')
        EndTrace = Ntraces;
    end
    if nargin < 2
        StartTrace = 1;
    end
    if nargin < 1 || nargin > 7
        error('Incorrect # of input parameters');
    end
        
    %Convert conductance boundaries to log space:
    max_cond = log10(max_cond);
    min_cond = log10(min_cond);
    
    %Get slope of each trace in decades/um of piezo distance:
    [trace_slopes, ~] = fit_tunneling_sections(TraceStruct, min_cond, ...
        max_cond, StartTrace, EndTrace);
    
    %Convert slopes to attenuations by assuming correct slope in
    %inter-electrode distance is 6 decades/nm
    correct_slope = -6.00;
    trace_attenuations = trace_slopes ./ (1000 * correct_slope);
        
    %Get histogram:
    bin_width = 2 * iqr(trace_attenuations) * length(trace_attenuations)^(-1/3);
    nbins = round(range(trace_attenuations) / bin_width);
    [counts, centers] = hist(trace_attenuations, nbins);
    counts = counts';
    centers = centers'; 
    
    %Fit Gaussian to attenuation from each trace
    [~, atten_peak, atten_error, atten_width] = ...
        fit_xyData_nGaussians(centers, counts, 1, ToPlot);
    
    FormPeakInfo = [];
    if ToPlot
        xlabel('Trace Attenuation');
        ylabel('# of Traces');
        legend({'Raw Histogram Data','Best Fit'});
        if ~isempty(TraceStruct.FormingTunnelingSlopes) && IncludeForming
            forming_attenuations = TraceStruct.FormingTunnelingSlopes(StartTrace:EndTrace) ...
                ./ (correct_slope);
            forming_attenuations = forming_attenuations(~isnan(forming_attenuations));
            bin_width = 2 * iqr(forming_attenuations) * length(forming_attenuations)^(-1/3);
            nbins = round(range(forming_attenuations) / bin_width);
            [counts, centers] = hist(forming_attenuations, nbins);
            
            FormPeakInfo = struct();
            [yhat, FormPeakInfo.peak, FormPeakInfo.error, FormPeakInfo.haflwidth] = ...
                fit_xyData_nGaussians(centers', counts', 1, false);
            
            [x,y] = convert_to_histogram_endpoints(centers',counts');
            hold on;
            plot(x,y,'Color',[0 1 0]);
            plot(centers',yhat);
            
            ylim('auto');
            legend({'From Breaking Traces','Fit to Breaking Traces', ...
                'From Forming Traces','Fit to Forming Traces'});
        end
        xlim([prctile(trace_attenuations,0.1),prctile(trace_attenuations,95)]);
    end
    
end