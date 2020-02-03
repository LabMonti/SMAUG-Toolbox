%Creates a 2D histogram using a TraceStructure file as input
%Last Modified: 15Dec2017 NDB
function Make2DHist_FromTraceStructure(TraceStruct, binsPer_x, binsPer_y, ...
    StartTrace, EndTrace, LinLog_x, LinLog_y, NormalizeCounts)
    %~~~INPUTS~~~:
    %
    %TraceStruct: a structure containing all traces in a data set along
    %   with relevant related information
    %
    %binsPer_x: the # of bins per unit along the x-axis
    %
    %binsPer_y: the # of bins per unit along the y-axis
    %
    %StartTrace/EndTrace: ID# of the first/last trace in the data set to
    %   use
    %
    %LinLog_x/LinLog_y: string equal to 'Lin' or 'Log' depending on whether
    %   the x-axis/y-axis should be plotted linearly or logarithmically
    %
    %NormalizeCounts: if 0/false, leave raw counts; if 1/true, normalize
    %   to counts per trace; if 2, normalize to probability density
    
    
    %Load trace structure:
    TraceStruct = LoadTraceStruct(TraceStruct);
    %This program will assume x is in linear space and y is in logarithmic
    %space, so make sure that's true:
    TraceStruct.convertTraces('Lin','Log');
    
    Ntraces = TraceStruct.Ntraces;
    
    %Set default values for input variables
    if nargin < 8
        NormalizeCounts = true;
    end
    if nargin < 7
        LinLog_y = 'Log';
    end
    if nargin < 6
        LinLog_x = 'Lin';
    end
    if nargin < 5 || strcmp(EndTrace, 'max')
        EndTrace = Ntraces;
    end
    if nargin < 4
        StartTrace = 1;
    end
    if nargin < 3
        binsPer_y = 30;
    end
    if nargin < 2
        binsPer_x = 30;
    end
    if nargin < 1 || nargin > 8
        error('Invalid number of input variables!');
    end
    
    if ~strcmp(LinLog_x,'Log') && ~strcmp(LinLog_x,'Lin')
        error('The parameter "LinLog_x" can only have the values "Lin" or "Log"');
    end    
    if ~strcmp(LinLog_y,'Log') && ~strcmp(LinLog_y,'Lin')
        error('The parameter "LinLog_y" can only have the values "Lin" or "Log"');
    end   
       
    AllPoints = TraceStruct.getAllData('both',StartTrace,EndTrace);
    
    %Remove points below noise floor 
    nf = TraceStruct.NoiseFloor;
    AllPoints = AllPoints(AllPoints(:,2) > log10(nf), :);
  
    Ntraces_used = EndTrace - StartTrace + 1;
    if NormalizeCounts == 2
        scalar = 1/(size(AllPoints,1)*(1/binsPer_x)*(1/binsPer_y));
    elseif NormalizeCounts == 1
        scalar = 1/Ntraces_used;
    else
        scalar = 1;
    end
    
    %Make 2D Histogram from matrix of 2D points
    make2DHist_FromDataPoints(AllPoints, binsPer_x, binsPer_y, LinLog_x, ...
        LinLog_y, nf, scalar)
    
    %Create title if subset of traces was used
    if StartTrace ~= 1 || EndTrace ~= Ntraces
        title(strcat('2D Histogram Using Only Traces',{' '},num2str(StartTrace),...
            {' '},'to',{' '},num2str(EndTrace)));
    end
    
    %Put a title on the color bar!
    if NormalizeCounts == 2
        cb_label = 'Probability Density';
    elseif NormalizeCounts == 1
        cb_label = 'Count per Trace';
    else
        cb_label = 'Count';
    end
    a = gca;
    h = a.Colorbar;
    set(get(h,'label'),'string',cb_label,'Rotation',-90,'VerticalAlignment',...
        'bottom','FontSize',14);
    cm = importdata('cmap.mat');
    colormap(cm);
    
    %Make y-label
    ylabel(strcat('Conductance/',TraceStruct.y_units),'FontSize',14);    
    
    %Choose appropriate label for x-axis
    if abs(TraceStruct.attenuation_ratio - 1) < 0.01
        distance_type = 'Piezo Distance';
    else
        distance_type = 'Inter-Electrode Distance';
    end
    xlabel(strcat(distance_type,' (', TraceStruct.x_units,')'),'FontSize',14);  
    
end
