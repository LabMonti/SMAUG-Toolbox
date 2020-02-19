function CreateDistanceCorrelationHistogram(TraceStruct, binsper_x, ...
    StartTrace, EndTrace, SignedCorr, PlotNumTraces)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Creates a "distance correlation histogram" by
    %calculating the correlation coefficient between the conductances of
    %all traces at each pair of distances.  Those conductances are
    %determined by linear interpolation.  
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a structure containing all the traces from a data set
    %   along with relevant associated information
    %
    %binsper_x: the number of distance cuts to use per unit along the x
    %   (distance) axis
    %
    %StartTrace/EndTrace: # of the first/last trace to include in analysis
    %
    %SignedCorr: logical variable; if true, Pearson's correlation
    %   coefficient is calculated (r); if false, r^2 is calculated
    %
    %PlotNumTraces: logical variable; if true, a second plot is created to
    %   show the number of traces used to calculate correlation in
    %   each bin
    
    
    %Load trace structure and make sure distance is in linear space:
    TraceStruct = LoadTraceStruct(TraceStruct);
    TraceStruct.convertTraces('Lin','Log');
    
    Ntraces = TraceStruct.Ntraces;
    
    %Default values
    if nargin < 2
        binsper_x = 40;
    end
    if nargin < 3
        StartTrace = 1;
    end
    if nargin < 4
        EndTrace = Ntraces;
    end
    if nargin < 5
        SignedCorr = true;
    end
    if nargin < 6
        PlotNumTraces = false;
    end
    if strcmp(EndTrace,'max')
        EndTrace = Ntraces;
    end
    if StartTrace < 1 || EndTrace > Ntraces || StartTrace > EndTrace
        error('Requested trace bounds are impossible');
    end
    
    %Get noise floor so as to exclude data below it
    NoiseFloor = log10(TraceStruct.NoiseFloor);
    
    %Get vectors of all distances and all conductances
    AllData = zeros(TraceStruct.NumTotalPoints,2);
    counter = 0;
    for i = StartTrace:EndTrace
        %%%trace = TraceStruct.(strcat('Trace',num2str(i)));
        trace = TraceStruct.Traces{i};
        
        trace = trace(trace(:,2) >= NoiseFloor,:);
        n = size(trace,1);
        
        AllData(counter+1:counter+n,:) = trace;
        counter = counter + n;        
    end
    AllData = AllData(1:counter,:);
    
    %Make grid of x-lattice points; only extend to where most of data lies
    xStart = prctile(AllData(:,1),1);%2.5);
    xEnd = prctile(AllData(:,1),99);%7.5);
    xStep = 1/binsper_x;
    xDist = (xStart:xStep:xEnd);
    nX = length(xDist);
    
    %Make big matrix to hold conductance of each trace at each x-lattice
    %line
    Ntraces_used = EndTrace - StartTrace + 1;
    BigMatrix = Inf(Ntraces_used,nX);
    ActiveRegions = false(Ntraces_used,nX);
    for i = 1:Ntraces_used
        trace_id = i + StartTrace - 1; %Adjust relative to start trace
        
        %%%trace = TraceStruct.(strcat('Trace',num2str(i)));
        trace = TraceStruct.Traces{trace_id};
        
        trace = trace(trace(:,2) >= NoiseFloor,:);
        n = size(trace,1);
        for j = 1:nX
            if xDist(j) > trace(1,1) && xDist(j) < trace(n,1)
                ActiveRegions(i,j) = true;
                BigMatrix(i,j) = LinearInterpolation(trace,xDist(j));
            end
        end
    end
    
    %Make the correlation matrix:
    CorrelationMatrix = zeros(nX^2,4);
    counter = 0;
    for i = 1:nX
        for j = i:nX
            choose = and(ActiveRegions(:,i),ActiveRegions(:,j));
            
            data1 = BigMatrix(choose,i);
            data2 = BigMatrix(choose,j);
            
            %Make sure there exist points to be correlated!
            if size(data1,1) > 0
                cov = NathansCovariance([data1,data2]);
                if cov(1,1) == 0 || cov(2,2) == 0
                    r = 1;
                else
                    r = cov(1,2)/sqrt(cov(1,1)*cov(2,2));
                end
                counter = counter + 1;
                CorrelationMatrix(counter,1) = xDist(i);
                CorrelationMatrix(counter,2) = xDist(j);
                CorrelationMatrix(counter,3) = r;
                CorrelationMatrix(counter,4) = size(data1,1); %Store # of point used to determine r
            end

        end
        if mod(i,32) == 0
            disp([i nX]);
        end
    end
    CorrelationMatrix = CorrelationMatrix(1:counter,:);
    %CorrelationMatrix = CorrelationMatrix(isfinite(CorrelationMatrix(:,3)),:);
    
    %Get r^2 if requested
    if ~SignedCorr
        CorrelationMatrix(:,3) = CorrelationMatrix(:,3).^2;
    end
    
    figure();
    scatter(CorrelationMatrix(:,1),CorrelationMatrix(:,2),20,CorrelationMatrix(:,3),'filled','sq');
    if SignedCorr
        cmap = importdata('correlation_cmap.mat');
        colormap(cmap);
        colorbar();
        caxis([-1 1]);
    else
        colormap('autumn');
        colorbar();
        caxis([0 1]);        
    end
    
    %Label the plot axes and title
    if abs(TraceStruct.attenuation_ratio - 1) < 0.1
        distance_type = 'Piezo Distance';
    else
        distance_type = 'Inter-Electrode Distance';
    end
    xlabel(strcat(distance_type,' (', TraceStruct.x_units,')'),'FontSize',14);  
    ylabel(strcat(distance_type,' (', TraceStruct.x_units,')'),'FontSize',14);  
    title(strcat(TraceStruct.name,':',{' '},'Distance Correlation Plot')...
        ,'Interpreter','none');
    
    %Make 2D histogram showing how many traces were used for each
    %correlation calculation
    if PlotNumTraces
        figure();
        scatter(CorrelationMatrix(:,1),CorrelationMatrix(:,2),20,CorrelationMatrix(:,4),'filled');
        cmap = importdata('cmap.mat');
        colormap(cmap);
        colorbar();
        caxis([0 max(CorrelationMatrix(:,4))]);
        title('# of Traces Used for Each Correlation Calculation');
        xlabel(strcat(distance_type,' (', TraceStruct.x_units,')'),'FontSize',14);  
        ylabel(strcat(distance_type,' (', TraceStruct.x_units,')'),'FontSize',14); 
    end
    
    disp('Distance Correlation Plot Made for:');
    disp(strcat('Data set name:',{' '},TraceStruct.name));

    if StartTrace ~= 1 || EndTrace ~= Ntraces
        disp(strcat('Using only traces',{' '},num2str(StartTrace),' to',...
            {' '},num2str(EndTrace)));
    end
    
end
