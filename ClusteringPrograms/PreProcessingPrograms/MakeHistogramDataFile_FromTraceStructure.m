%21Feb18 NDB: This program turns a trace structure file into a data file
%with format appropriate for input into Ben's clustering algorithm (i.e.
%first column is interelectrode distance, 2nd column is log(conductance),
%and third column is counts for each nonzero bin in the 2d histogram).  
%The noise floor will be assumed from the input data file
%All data left of 'left_chop_nm' on the x-axis will be excluded
function DataMatrix = MakeHistogramDataFile_FromTraceStructure(TraceStruct, ...
    binsper_x, binsper_y, left_chop_nm, ToPlot)

    %~~~INPUTS~~~:
    %
    %TraceStruct: a matlab structure containing log(G/G_0) vs. distance
    %   traces and associated information
    %
    %binsper_x: the # of bins to use per unit in the x-dimension (distance)
    %
    %binsper_y: the # of bins to use per unit in the y-dimension (logG)
    %
    %left_chop_nm: the minimum distance value to use; traces will be
    %   chopped at this value and any distance points less than it will be
    %   discarded
    %
    %ToPlot: logical variable, if true the histogram will be plotted
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %DataMatrix: a 3-column array containing the histogram data, with one
    %row per non-zero bin; the first column is the center x-value, the 2nd
    %column is the center y-value, and the third column is the bin's count

    %Default inputs
    if nargin < 5
        ToPlot = false;
    end
    if nargin < 4
        left_chop_nm = -0.1;
    end
    if nargin < 3
        binsper_y = 30;
    end
    if nargin < 2
        binsper_x = 30;
    end

    Ntraces = TraceStruct.Ntraces;
    TotalPoints = TraceStruct.NumTotalPoints;
    
    points = zeros(TotalPoints, 2);
    
    %Accumulate all points together
    counter = 0;
    for i = 1:Ntraces
        %%%trace = TraceStruct.(strcat('Trace',num2str(i)));
        trace = TraceStruct.Traces{i};
        n = length(trace);
        
        points(counter+1:counter+n,:) = trace;
        counter = counter + n;
    end
    
    %Chop at noise floor
    if isfield(TraceStruct,'NoiseFloor')
        nf = log10(TraceStruct.NoiseFloor);
        points = points(points(:,2) > nf, :);
    end
    
    %Chop at left bound
    points = points(points(:,1) > left_chop_nm, :);
    
    %Get total # of bins
    Xbins = round(range(points(:,1)) * binsper_x);
    Ybins = round(range(points(:,2)) * binsper_y);
    
    %Bin data using built-in MatLab function
    [counts, centers] = hist3(points, [Xbins, Ybins]);
    
    DataMatrix = zeros(Xbins*Ybins, 3);
    counter = 0;
    
    %Create the three column output format
    for i = 1:Xbins
        for j = 1:Ybins
            if counts(i,j) > 0
                counter = counter + 1;
                DataMatrix(counter, 1) = centers{1}(i);
                DataMatrix(counter, 2) = centers{2}(j);
                DataMatrix(counter, 3) = counts(i,j);
            end
        end
    end
    DataMatrix = DataMatrix(1:counter, :);
    
    %Display figure so user can see what they made!
    if ToPlot
        figure();
        scatter(DataMatrix(:,1),DataMatrix(:,2),30,DataMatrix(:,3),'o','Filled');
        cmap = importdata('cmap.mat');
        colormap(cmap);
        colorbar;
    end
            
end
