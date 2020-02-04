function [Counts, centers] = ...
    Make1DHist_FromTraceStructure(TraceStruct, binsper_x, StartTrace, ...
    EndTrace, LinLog, NormalizeCounts, DisplayOff)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Makes a 1D conductance histogram from a dataset.
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all the traces in a dataset
    %   and associated information
    %
    %binsper_x: how many bins to user per unit on the x-axis (Conductance)
    %
    %StartTrace: the # of the first trace in the data set to use, if the
    %   user wants to only use a subset of the data
    %
    %EndTrace: the # of the last trace in the data set to use, if the
    %   user wants to only use a subset of the data
    %
    %LinLog: Whether the x-axis (Conductance) should be on a linear or
    %   logarithmic scale; acceptable values are "Lin" and "Log"
    %
    %NormalizeCounts: if 0/false, leave raw counts; if 1/true, normalize
    %   to counts per trace; if 2, normalize to probability density
    %
    %DisplayOff: logical variable that can be set to true to suppress the
    %   plot output
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %Counts: vector of counts for each bin
    %
    %centers: vector of center-conductance of each bin (in log space if
    %   histogram is being plotted in log space)

    
    %Load in trace structure;
    TraceStruct = LoadTraceStruct(TraceStruct);
    
    Ntraces = TraceStruct.Ntraces;

    %Default inputs
    if nargin < 7
        DisplayOff = false;
    end
    if nargin < 6
        NormalizeCounts = true;
    end
    if nargin < 5
        LinLog = 'Log';
    end
    if nargin < 4
        EndTrace = Ntraces;
    end
    if nargin < 3
        StartTrace = 1;
    end
    if nargin < 2
        binsper_x = 'algorithm';
    end
    if nargin < 1 || nargin > 7
        error('Incorrect # of Input Parameters');
    end
    
    if ~strcmp(LinLog,'Log') && ~strcmp(LinLog,'Lin')
        error('The parameter "LinLog" can only have the values "Lin" or "Log"');
    end
    
    %Allow user to just specify "max" for the ending trace #
    if strcmp(EndTrace,'max')
        EndTrace = Ntraces;
    end
    
    
    %Convert conductances into appropriate space (x-values don't matter, so
    %put them in linear space):
    TraceStruct.convertTraces('Lin',LinLog);
    
    %Accumulate all conductance values:
    conductances = TraceStruct.getAllData('cond',StartTrace,EndTrace);
    
    %Default # of bins based on "IQR rule"
    if strcmp(binsper_x, 'algorithm')
        width = 2 * iqr(conductances) * size(conductances,1)^(-1/3);
        binsper_x = 1/width;
        disp(strcat('Using',{' '},num2str(binsper_x),' bins per x-unit'));
    end

    %Get total number of bins
    Nbins = round(binsper_x * range(conductances));
    if Nbins == 0
        error('Zero bins requested!');
    end
    
    %Make vectors of bin edges and bin centers
    edges = zeros(Nbins + 1, 1);
    centers = zeros(Nbins, 1);
    edges(1) = min(conductances);
    step = range(conductances)/Nbins;
    for i = 2:Nbins+1
        edges(i) = edges(i-1) + step;
        centers(i-1) = edges(i-1) + step/2;
    end

    [Counts, ~] = histcounts(conductances, edges);
    
    Ntraces_used = EndTrace - StartTrace + 1;
    if NormalizeCounts == 2
        Counts = Counts/(length(conductances)*step);
    elseif NormalizeCounts == 1
        Counts = Counts/Ntraces_used;
    end

    %Make figure
    if ~DisplayOff
        figure();
        %plot(centers, Counts);
        bar(centers, Counts, 1);
        if strcmp(LinLog, 'Lin')
            xlabel(strcat('Conductance/',TraceStruct.y_units));
            xlim([0 1.5]);
        elseif strcmp(LinLog, 'Log')
            xlabel(strcat('Log(Conductance/',TraceStruct.y_units,')'));
            xlim([log10(TraceStruct.NoiseFloor) 1.5]);
        end

        if NormalizeCounts == 2
            ylabel('Probability Density');
        elseif NormalizeCounts == 1
            ylabel('Count per Trace');
        else
            ylabel('Counts');
        end

        %Create title if subset of traces was used
        if StartTrace ~= 1 || EndTrace ~= Ntraces
            title(strcat('1D Histogram Using Only Traces',{' '},num2str(StartTrace),...
                {' '},'to',{' '},num2str(EndTrace)));
        end
    end


end