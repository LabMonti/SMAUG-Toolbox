function [counts, centers] = Make1D_DistanceHistogram(TraceStruct, ...
    linesper_y, binsper_dist, UpperCondChop, StartTrace, EndTrace, ...
    NormalizeCounts, varargin)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Makes a 1D "distance histogram" in which peaks 
    %correspond to cliffs in traces rather than plateaus. Obtained by 
    %resampling traces evenly along the y-axis instead of the x-axis. 
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a structure containing all traces in a data set along
    %   with relevant related information
    %
    %linesper_y: the # of horizontal resampling lines to use per unit on
    %   the y-axis
    %
    %binsper_dist: the # of bins per unit in the 1D distance histogram that
    %   will be created
    %
    %UpperCondChop: the portions of traces with conductances above this
    %   value will be removed prior to processing. Can be set to '[]' to
    %   not use any conductance chop.  In units of G_0, NOT logged!
    %
    %StartTrace/EndTrace: ID# of the first/last trace in the data set to
    %   use
    %
    %NormalizeCounts: if 0/false, leave raw counts; if 1/true, normalize
    %   to counts per trace; if 2, normalize to probability density
    %
    %~~~OPTIONAL INPUT PARAMETERS (NAME-VALUE PAIR)~~~
    %
    %PlotCondHist: logical variable; whether or not to also make a 1D
    %   histogram of the re-sampled conductance values 
    %
    %binsper_cond: the # of bins per unit in the 1D histogram that may be
    %   created from the re-sampled conductance values
    %
    %DisplayOff: logical variable that can be set to true to suppress the
    %   plot output
    %
    %LowerCondChop: Conductances below this value will be removed prior to
    %   processing.  In units of G_0, NOT logged!
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %counts: vector of counts for the distance 1D histogram
    %
    %centers: vector of bin centers for the distance 1D histogram
    
    
    %Parse optional name-value pair inputs:
    p = inputParser();
    addParameter(p, 'PlotCondHist', false);
    addParameter(p, 'binsper_cond', 40);
    addParameter(p, 'DisplayOff', false);
    addParameter(p, 'LowerCondChop', []);
    parse(p, varargin{:});
    PlotCondHist = p.Results.PlotCondHist;
    binsper_cond = p.Results.binsper_cond;
    DisplayOff = p.Results.DisplayOff;
    LowerCondChop = p.Results.LowerCondChop;
    
    %Load in trace structure, and make sure it is in the expected format
    %for this program (x in linear space, y in log space)
    TraceStruct = LoadTraceStruct(TraceStruct);
    TraceStruct.convertTraces('Lin','Log');
    
    Ntraces = TraceStruct.Ntraces;

    %Default inputs
    if nargin < 7
        NormalizeCounts = true;
    end
    if nargin < 6
        EndTrace = Ntraces;
    end
    if nargin < 5
        StartTrace = 1;
    end
    if nargin < 4
        UpperCondChop = [];
    end
    if nargin < 3
        binsper_dist = 50;
    end
    if nargin < 2
        linesper_y = 50;
    end
    
    %Allow user to just specify "max" for the ending trace #
    if strcmp(EndTrace,'max')
        EndTrace = Ntraces;
    end
    
    %Start and end trace must make sense
    if StartTrace > EndTrace || EndTrace > Ntraces || StartTrace < 1
        error('Start and end trace numbers are impossible');
    end

    yStep = 1/linesper_y;
    
    AllNewPoints = resampleAllPointsAlongY(TraceStruct,yStep,StartTrace,...
        EndTrace);
    
    %Chop traces at conductance ceiling if requested:
    if ~isempty(UpperCondChop)
        AllNewPoints = AllNewPoints(AllNewPoints(:,2) <= log10(UpperCondChop), :);
    end    
    %Chop traces at conductance floor if requested:
    if ~isempty(LowerCondChop)
        AllNewPoints = AllNewPoints(AllNewPoints(:,2) >= log10(LowerCondChop), :);
    end
    
    Ntraces_used = EndTrace - StartTrace + 1;
    
    %Make conductance histogram:
    if PlotCondHist && ~DisplayOff
        [counts, centers] = hist(AllNewPoints(:,2),round(binsper_cond * range(AllNewPoints(:,2))));
        if NormalizeCounts == 2
            %To get probability density, divide each count by the total
            %number of points and the width of a bin (which is the inverse
            %of how many bins there are per unit)
            counts = counts/(size(AllNewPoints,1)/binsper_cond);
        elseif NormalizeCounts == 1
            counts = counts/Ntraces_used;
        end
        figure();
        bar(centers, counts, 1);
        %plot(centers, counts);    
        xlabel('Log(Conductance G/G_0)');
        if NormalizeCounts == 2
            ylabel('Probability Density');
        elseif NormalizeCounts == 1
            ylabel('Counts per Trace');
        else
            ylabel('Counts');
        end
        title('Conductance Histogram of Resampled Points');
    end
    
    %Default # of bins based on "IQR rule"
    if strcmp(binsper_dist, 'algorithm')
        width = 2 * iqr(AllNewPoints(:,1)) * size(AllNewPoints,1)^(-1/3);
        binsper_dist = 1/width;
        disp(strcat('Using',{' '},num2str(binsper_dist),' bins per distance unit'));
    end
    
    %Make distance histogram:
    [counts, centers] = hist(AllNewPoints(:,1),round(binsper_dist * range(AllNewPoints(:,1))));
    if NormalizeCounts == 2
        %To get probability density, divide each count by the total
        %number of points and the width of a bin (which is the inverse
        %of how many bins there are per unit)
        counts = counts/(size(AllNewPoints,1)/binsper_dist);
    elseif NormalizeCounts == 1
        counts = counts/Ntraces_used;
    end
    counts = counts';
    centers = centers';
    
    if ~DisplayOff
        %Make the distance histogram:
        figure();
        bar(centers, counts, 1);

        %Choose appropriate label for x-axis
        if abs(TraceStruct.attenuation_ratio - 1) < 0.1
            distance_type = 'Piezo Distance';
        else
            distance_type = 'Inter-Electrode Distance';
        end
        xlabel(strcat(distance_type,' (', TraceStruct.x_units,')'),'FontSize',14);    

        %Label y-axis
        if NormalizeCounts == 2
            ylabel('Probability Density','FontSize',14);
        elseif NormalizeCounts == 1
            ylabel('Counts per Trace','FontSize',14);
        else
            ylabel('Counts','FontSize',14);
        end
        title(strcat('Dist. Hist. for',{' '},TraceStruct.name),'Interpreter','none');

        %Create title if subset of traces was used
        if StartTrace ~= 1 || EndTrace ~= Ntraces
            title(strcat('1D  Dist. Histogram Using Only Traces',{' '},num2str(StartTrace),...
                {' '},'to',{' '},num2str(EndTrace)));
        end
    end

end