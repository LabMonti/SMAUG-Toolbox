%21May18 NDB: resamples each trace along evenly spaced horizontal lines (in
%contrast to the original data, which is evenly spaced along the x-axis,
%i.e. along evenly spaced vertical lines).  The placement of the horizontal
%lines is different for each trace (randomly chosen) to avoid strange
%sampling effects.  
function AllNewPoints = resampleAllPointsAlongY(TraceStruct, yStep, ...
    StartTrace, EndTrace)
    %~~~INPUTS~~~:
    %
    %TraceStruct: a structure containing all traces in a data set along
    %   with relevant related information
    %
    %yStep: the distance (in units of log(G/G_0)) between the different
    %   horizontal lines that are being used for resampling
    %
    %StartTrace/EndTrace: ID# of the first/last trace in the data set to
    %   use
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %AllNewPoints: 2-column array containing re-sampled points from all
    %   included traces; first column is distance, 2nd column is log(G/G_0)

    
    %Load in trace structure:
    TraceStruct = LoadTraceStruct(TraceStruct);
    
    disp('Resampling traces...');
    Ntraces = TraceStruct.Ntraces;
    
    %Default values
    if nargin < 4
        EndTrace = Ntraces;
    end
    if nargin < 3
        StartTrace = 1;
    end
    if nargin < 2
        yStep = 0.1;
    end
    if nargin < 1 || nargin > 4
        error('Incorrect # of input parameters given');
    end

    ResampledTraces = cell(Ntraces,1);
    
    %Get noise floor
    nf = log10(TraceStruct.NoiseFloor);

    %Resample each trace 
    NumNewPoints = 0;
    for i = StartTrace:EndTrace
        %%%trace = TraceStruct.(strcat('Trace',num2str(i)));
        trace = TraceStruct.Traces{i};
        
        %Subtrace a random amount from nf to change the starting point for
        %the horizontal grid lines for each trace:
        starting_line = nf - rand()*yStep;
        
        newtrace = resampleTrace_AlongY(trace,yStep,starting_line,0);
        NumNewPoints = NumNewPoints + length(newtrace);
        
        ResampledTraces{i} = newtrace;   
        if mod(i,128) == 0
            disp([i EndTrace]);
        end
    end
    
    %Collect new traces all together:
    AllNewPoints = zeros(NumNewPoints, 2);
    counter = 0;
    for i = StartTrace:EndTrace
        newtrace = ResampledTraces{i};
        n = length(newtrace);
        AllNewPoints(counter+1:counter+n,:) = newtrace;
        counter = counter + n;
    end
    
end