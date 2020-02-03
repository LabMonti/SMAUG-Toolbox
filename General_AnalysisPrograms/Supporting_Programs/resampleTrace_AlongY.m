%14Mar18 NDB: The purpose of this function is take in a normal trace and
%re-sample it "only along y", by which I mean overlaying horizontal lines
%on top of the trace and making new data points where they cross the trace.
%yStep is the distance between each of these lines.  yStart is the y-value
%of the first horizontal line (the lowest one). 
function newtrace = resampleTrace_AlongY(trace, yStep, yStart, ToPlot)
    %~~~INPUTS~~~:
    %
    %trace: a single trace as a 2-column array with distance in the 1st
    %   column and log(G/G_0) in the 2nd column
    %
    %yStep: the distance (in units of log(G/G_0)) between the different
    %   horizontal lines that are being used for resampling
    %
    %yStart: the location of the first horizonal line to use for
    %   re-sampling
    %
    %ToPlot: logical variable, whether or not to plot the original and
    %   re-sampled traces on top of each other
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %newtrace: the new trace after re-sampling, again as a 2-column array
    
    
    if nargin < 4
        ToPlot = false;
    end

    nPoints = length(trace);
    newtrace = zeros(10*nPoints, 2);
    
    maxCond = max(trace(:,2));
    
    nLines = ceil((maxCond - yStart)/yStep) + 1;
    yCuts = zeros(nLines, 1);
    
    %Make a vector of all the different horizontal lines to be used, in
    %increasing order
    yCuts(1) = yStart;
    for i = 2:nLines
        yCuts(i) = yCuts(i-1) + yStep;
    end
    
    counter = 0;
    intervalStart = 1;
    intervalEnd = 2;
    %Out loop walks through each x-interval in the trace, find all
    %horizontal lines passing between those two points
    while intervalEnd <= nPoints
        
        %Conductance values for two points in interval being considered
        condStart = trace(intervalStart, 2);
        condEnd = trace(intervalEnd, 2);
        
        %Find indices for first and last horizontal lines within this
        %interval:
        firstCut = FirstAfter(yCuts,min(condStart,condEnd));
        lastCut = LastBefore(yCuts,max(condStart,condEnd));
       
        %Inner loop takes each of those horizontal lines and finds where it
        %intersects the linear interpolation between the two original trace
        %data points
        for i = firstCut:lastCut
            
            counter = counter + 1;
            newtrace(counter, 2) = yCuts(i);
            newtrace(counter, 1) = SimpleLinearInterpolation(trace(intervalStart,1),...
                trace(intervalStart,2),trace(intervalEnd,1),trace(intervalEnd,2),yCuts(i));

        end
        
        %Move to next interval in original trace
        intervalStart = intervalStart + 1;
        intervalEnd = intervalEnd + 1;       
        
    end
    newtrace = newtrace(1:counter, :);
    
    if ToPlot
        figure();
        hold on;
        %Plot horizontal lines!
        xMin = min(trace(:,1));
        xMax = max(trace(:,1));
        for i = 1:nLines
            plot([xMin, xMax],[yCuts(i), yCuts(i)],'Color',[0.1,0.1,0.1]);
        end

        plot(trace(:,1),trace(:,2));
        plot(newtrace(:,1),newtrace(:,2),'.');

        hold off;
    end
    
end

%For linear interpolation between the points (x1,y1) and (x2,y2), find the x value
%corresponding to the input y value
function xvalue = SimpleLinearInterpolation(x1,y1,x2,y2,yvalue)

    if x1 == x2
        xvalue = x1;
    else
        m = (y2 - y1)/(x2 - x1);
        b = y1 - m*x1;
    
        xvalue = (yvalue - b) / m;
    end

end