%Create a "2D cross correlation histogram" as described in Makk et al. 2012
%(DOI:10.1021/nn300440f)
function CreateCorrelationHistogram(TraceStruct, binsper, LinLog, ...
    condData, StartTrace, EndTrace)
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure containing all the traces in a dataset
    %   and associated information
    %
    %binsper: the number of bins to use per unit on the conductance axis
    %
    %LinLog: Whether conductance should be on a linear or logarithmic 
    %   scale; acceptable values are "Lin" and "Log"
    %
    %condData: optional input that is a 1D vector containing all the
    %   conductance data from all the traces in the data set on a LINEAR
    %   scale
    %
    %StartTrace/EndTrace: the ID #s of the first and last traces to be
    %   included in processing
    
    
    %Load in trace structure, and make sure it is in the expected format
    %for this program (x doesn't matter, y in log space)
    TraceStruct = LoadTraceStruct(TraceStruct);
    TraceStruct.convertTraces('Lin','Log');
    
    Ntraces = TraceStruct.Ntraces;

    if nargin < 6 
        EndTrace = Ntraces;
    end
    if nargin < 5
        StartTrace = 1;
    end
    if nargin < 4
        condData = [];
    end
    if nargin < 3
        LinLog = 'Log';
    end
    if nargin < 2
        binsper = 20;
    end
    if nargin < 1 || nargin > 6
        error('Incorrect number of input parameters!');
    end
    
    if ~isempty(condData) && (StartTrace > 1 || EndTrace < Ntraces)
        error('Cannot use subset of traces when raw conductances are supplied instead of traces!');
    end
    
    %If the conductance data is not conveniently supplied as a single
    %vector, extract it from the traces
    if isempty(condData)
        
        %Get total # of data points
        condData = zeros(TraceStruct.NumTotalPoints, 1);
        
        counter = 0;
        for i = StartTrace:EndTrace
            %%%trace = TraceStruct.(strcat('Trace',num2str(i)));
            trace = TraceStruct.Traces{i};
            
            n = size(trace,1);
            condData(counter+1:counter+n) = trace(:,2);
            counter = counter + n;
        end
        condData = condData(1:counter);

    else
        %If condData is supplied, it is in linear space, but it is expected
        %in logarithmic space below
        condData = log10(condData);
    end

    %Chop conductance at noise floor and rearrange if required
    noise_floor = TraceStruct.NoiseFloor;
    condData = condData(condData > log10(noise_floor));
    if strcmp(LinLog,'Lin')
        condData = 10.^condData;
    end
    
    cond_min = min(condData);
    cond_range = range(condData);

    %Find total number of bins
    nbins = round(binsper * cond_range);
    
    %Find mid-point of each conductance bin
    bin_mids = zeros(nbins,1);
    bin_mids(1) = cond_min + cond_range/nbins;
    for i = 2:nbins
        bin_mids(i) = bin_mids(i-1) + cond_range/nbins;
    end
    
    Ntraces_used = EndTrace - StartTrace + 1;
    
    %First make a matrix of counts for each bin in each trace:
    TraceBinCounts = zeros(Ntraces_used, nbins);
    
    %Now fill up that matrix
    for i = StartTrace:EndTrace
        %%%tr = TraceStruct.(strcat('Trace',num2str(i)));
        tr = TraceStruct.Traces{i};
        
        cond = tr(:,2); %specific trace
        %Change to linear space if so required
        if strcmp(LinLog,'Lin')
            cond = 10.^cond;
        end
        %For each conductance value in trace, assign it to a bin
        for j = 1:length(cond)
            val = cond(j);
            
            %Find index of bin that this value belongs to
            bin_index = ceil((val - cond_min)/cond_range * nbins);
            bin_index = min(bin_index,nbins); %In case of rounding error before ceiling function
            bin_index = max(bin_index,1); %In case of rounding error before ceiling function
            
            TraceBinCounts(i-StartTrace+1,bin_index) = ...
                TraceBinCounts(i-StartTrace+1,bin_index) + 1;
        
        end
    end

    %Find average value of each bin across all traces
    BinAverages = mean(TraceBinCounts);
    
    %Turn matrix of bin averages into matrix of bin deviations
    for i = 1:Ntraces_used
        TraceBinCounts(i,:) = TraceBinCounts(i,:) - BinAverages;
    end

    %Find vector of average squared deviations:
    AverageSquareDeviations = mean(TraceBinCounts.^2);

    %Find matrix of average cross terms:
    AverageCrossTerms = zeros(nbins);
    for i = 1:Ntraces_used
        %For each trace, adding up product of all pairs of bins (upper
        %triangle only)
        for j = 1:nbins
            for k = j:nbins
                AverageCrossTerms(j,k) = AverageCrossTerms(j,k) + ...
                    TraceBinCounts(i,j)*TraceBinCounts(i,k);
            end
        end
    end
    AverageCrossTerms = AverageCrossTerms/Ntraces_used;

    %Create actual correlation matrix
    CorrMatrix = zeros(nbins);
    for i = 1:nbins
        for j = i:nbins
            CorrMatrix(i,j) = AverageCrossTerms(i,j)/...
                sqrt(AverageSquareDeviations(i)*AverageSquareDeviations(j));
        end
    end

    %Re-arrange correlation matrix into format for scatter plotting:
    CorrDataMatrix = zeros(nbins^2, 3);
    counter = 0;
    for i = 1:nbins
        for j = i:nbins
            counter = counter + 1;
            CorrDataMatrix(counter, :) = [bin_mids(i),bin_mids(j),CorrMatrix(i,j)];
            %Take advantage of symmetry of correlation matrix
            counter = counter + 1;
            CorrDataMatrix(counter, :) = [bin_mids(j),bin_mids(i),CorrMatrix(i,j)];    
        end
    end
    CorrDataMatrix = CorrDataMatrix(1:counter,:);
    
    %Plot the figure!
    figure();
    scatter(CorrDataMatrix(:,1),CorrDataMatrix(:,2),30,CorrDataMatrix(:,3),'fill','o');
    if strcmp(LinLog,'Log') == 1
        xlabel('Log(Conductance)')
        ylabel('Log(Conductance)') % y-axis label
        xymin = prctile(CorrDataMatrix(:,1),1);
        xymax = prctile(CorrDataMatrix(:,1),99);
    elseif strcmp(LinLog,'Lin') == 1
        xlabel('Conductance (G_0)')
        ylabel('Conductance (G_0)') % y-axis label
        xymin = prctile(CorrDataMatrix(:,1),2);
        xymax = prctile(CorrDataMatrix(:,1),98);        
    end 

%     %Define special color map with green around zero, warm colors for
%     %positive and cool colors for negative (based on Latha 2012
%     %10.1021/nn300440f)
%     cmap = zeros(64,3);
%     cmap(1:30,1) = linspace(1,0,30);
%     cmap(1:30,2) = linspace(0,1,30);
%     cmap(1:30,3) = ones(30,1);
%     cmap(31,:) = [0,1,0];
%     cmap(32,:) = [0,1,0];
%     cmap(33,:) = [0,1,0];
%     cmap(34,:) = [0,1,0];
%     cmap(35:64,1) = ones(30,1);
%     cmap(35:64,2) = linspace(1,0,30);

    xlim([xymin xymax]);
    ylim([xymin xymax]);
    cmap = importdata('correlation_cmap.mat');
    colormap(cmap);
    colorbar;
    caxis([-1 1]);

end