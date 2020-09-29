function [slopes, intercepts, r2s, nPoints, trace_IDs] = fit_tunneling_sections(...
    TraceStruct, min_cond, max_cond, StartTrace, EndTrace)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Fit the tunneling section of each trace, and 
    %return the slope, intercept, r^2 values, # of points in each tunneling
    %region, and which tunneling regions could be fit at all
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all the traces in a dataset
    %   and associated information
    %
    %min_cond/max_cond: the conductance limits that define the "tunneling
    %   region" where we will be calculating trace slopes (in log space!!!)
    %
    %StartTrace: the trace # of the first trace to be considered for the
    %   calculation
    %
    %EndTrace: the trace # of the last trace to be considered for the
    %   calculation
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %slopes: a vector containing the slope (in um^-1) of the tunneling 
    %   region of each trace that was fit
    %
    %intercepts: a vector containing the y-intercept (in Log(G/G_0) of the
    %   tunneling region of each trace that was fit
    %
    %r2s: a vector containing the R^2 values for the tunneling region of 
    %   each trace that was fit
    %
    %nPoints: a vector containing the number of points in the tunneling 
    %   region of each trace that was fit
    %
    %trace_IDs: a vector containing the trace ID of each trace which had
    %   its tunneling region fit
    

    Ntraces = TraceStruct.Ntraces;

    %Default inputs
    if nargin < 5 || strcmp(EndTrace, 'max')
        EndTrace = Ntraces;
    end
    if nargin < 4
        StartTrace = 1;
    end
    if nargin < 3
        max_cond = log10(2E-4);
    end
    if nargin < 2
        min_cond = log10(2E-5);
    end
    if nargin < 1 || nargin > 6
        error('Incorrect # of input parameters');
    end
    
    Ntraces_used = EndTrace - StartTrace + 1;
    
    %Load in trace structure:
    TraceStruct = LoadTraceStruct(TraceStruct);   
    
    if ~isfinite(TraceStruct.attenuation_ratio) || TraceStruct.attenuation_ratio == 0
        error('Cannot change attenuation because current attenuation is undefined');
    end    

    %Convert back to piezo space, and into micron
    TraceStruct = ChangeTraceStruct_Attenuation(TraceStruct, 0.001);
    
    %Go through each trace and find the first point below the min and the
    %last point above the max; the indices of these points will define the
    %regions to be fit    
    counter = 0;
    slopes = zeros(Ntraces_used, 1);
    intercepts = zeros(Ntraces_used, 1);
    r2s = zeros(Ntraces_used, 1);
    nPoints = zeros(Ntraces_used, 1);
    trace_IDs = zeros(Ntraces_used, 1);
    disp('Fitting tunneling sections...');
    for i = StartTrace:EndTrace
        
        tr = TraceStruct.Traces{i};
        cond = tr(:,2);
        dist = tr(:,1);
        
        %Make sure trace has passed completely through tunneling region
        if any(cond < min_cond) && any(cond > max_cond)
                   
            [low_index,~] = find(cond < min_cond, 1, 'first');
            [high_index,~] = find(cond > max_cond, 1, 'last');

            %We need at least two points to fit a line!
            if low_index - high_index + 1 > 1

                ydata = cond(high_index:low_index);
                xdata = dist(high_index:low_index); 
                c = NathansCovariance([xdata,ydata]);
                
                counter = counter + 1;
                slopes(counter) = c(1,2)/c(1,1);
                intercepts(counter) = mean(ydata) - slopes(counter)*mean(xdata);
                
                %Calculate R^2 using covariance matrix
                if c(1,1) == 0 || c(2,2) == 0
                    r2s(counter) = 1;
                else
                    r2s(counter) = c(1,2)^2/(c(1,1)*c(2,2));
                end
                
                nPoints(counter) = low_index - high_index + 1;
                trace_IDs(counter) = i;

            end
                    
        end
        if mod(i,1024) == 0
            disp([i EndTrace]);
        end              
    end
    slopes = slopes(1:counter); 
    intercepts = intercepts(1:counter);
    r2s = r2s(1:counter);
    nPoints = nPoints(1:counter);
    trace_IDs = trace_IDs(1:counter);

end