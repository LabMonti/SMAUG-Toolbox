%Script to actually run the clustering; must be given a structure of
%clustering input parameters; can either be given a dataset structure, or
%one of the clustering input paramters can be a file name to read in said
%dataset.  
function OutputStruct = runClustering(ClusteringInputParameters,...
    optional_input_struct)

    %If requested, use the current time to generate the random seed.  It's
    %important to do this here at the top so that the generated random seed
    %gets saved out.  
    if strcmp(ClusteringInputParameters.random_seed,'use_time')
        t = now();
        t = t * 1E5;
        t = 1E5 * (t - floor(t));
        ClusteringInputParameters.random_seed = round(t);
    end

    %Start creating output structure, save all inputs to it
    OutputStruct = struct();
    OutputStruct.ClusteringInputParameters = ClusteringInputParameters;
    
    %Unpack all fields of the 'ClusteringInputParameters' structure into variables:
    fn = fieldnames(ClusteringInputParameters);
    disp('Clustering Input Parameters:');
    for i = 1:length(fn)
        eval([ fn{i} '=ClusteringInputParameters.' fn{i}]);
    end

    %Add path and import data set
    addpath(GetAbsolutePath('ClusteringPrograms'));
    if nargin == 1 || isempty(optional_input_struct)
        data = importdata(fullfile(GetAbsolutePath('DataSets'), input_file_name));
    else
        data = optional_input_struct;
    end
    
    %Look for data set name
    if isfield(data,'name')
        OutputStruct.dataset_name = data.name;
    else
        OutputStruct.dataset_name = 'NOT FOUND';
    end

    %Start Timing
    TSaver = TimingSave();

    %Start parallel pool if requested
    if nCores > 1
        %Start parallel pool
        pc = parcluster('local');
        pool = parpool(pc,nCores);
        pool.IdleTimeout = 600;
        TSaver.Save('Parallel Pool Setup');
        OutputStruct.nCores = nCores;
    else
        pool = [];
    end

    %Setting the random seed:
    rng(random_seed);

    %Do the clustering, depending on the mode chosen
    switch clustering_mode

        case 'Histogram'
            OutputStruct.Format = 'Histogram';

            %Process trace data into histogram data
            Xraw = MakeHistogramDataFile_FromTraceStructure(data, bins_per_x, ...
                bins_per_y, left_chop);        

            %Save histogram data
            OutputStruct.Xraw = Xraw; 

            %Standardize data
            Xraw = DataStandardization(Xraw, 'Histogram', w);

            metric_to_use = 'euclidean';

        case 'Points'
            %Save data
            OutputStruct.Xraw = data;
            Xraw = data;

            metric_to_use = 'euclidean';

        case 'PointsFromTraces'
            OutputStruct.Format = 'DataPoints';

            %Get raw data by unpacking traces
            Xraw = UnpackTracesIntoRawData(data, left_chop, CondCeiling);
            OutputStruct.Xraw = Xraw;

            %Standardize data:
            Xraw = DataStandardization(Xraw, 'PointsFromTraces');
            TSaver.Save('Data Unpacking');

            metric_to_use = 'euclidean';     

        case 'TraceHists'
            OutputStruct.Format = 'TraceHists';

            %Convert traces into matrix of 1D trace histograms
            [OG_Traces, Xraw, binCenters] = MakeTracesInto1DHists(data, ...
                tracehist_binsper, min(cond_limits), max(cond_limits), left_chop);

            %Save trace-histogram data, original traces, and bin centers
            OutputStruct.Xraw = Xraw;
            OutputStruct.OG_Traces = OG_Traces;
            OutputStruct.binCenters = binCenters;

            TSaver.Save('Data Preprocessing');

            %For traces, we use the cityblock (manhattan) distance metric
            metric_to_use = 'cityblock';             

        case 'ExtendedTraces'
            OutputStruct.Format = 'ExtendedTraces';

            %Determine noise floor to extend traces along:
            if isfield(data,'NoiseFloor')
                CondFloor = log10(data.NoiseFloor);
            else
                CondFloor = -6; %default value
            end
            OutputStruct.CondFloor = CondFloor;

            %Re-sample and extend traces:
            [Xdist, Xraw, og_tr_ends] = GetExtendedTraceMatrix(data, left_chop, CondFloor,...
                distStep, maxDist);

            %Save raw data (vectors of conductances) and the single vector of
            %distance values
            OutputStruct.Xraw = Xraw;
            OutputStruct.Xdist = Xdist;
            OutputStruct.OriginalTraceEnds = og_tr_ends;

            %Save # of traces used and # removed
            OutputStruct.Ntraces = size(Xraw, 1);
            OutputStruct.nTracesRemoved = data.Ntraces - size(Xraw,1);

            %Normalize data; this only matters if regular OPTICS is being
            %used, in which case it ensures that geneps is transferable between
            %different data sets
            if strcmp(clustering_algorithm, 'OPTICS')
                nVals = size(Xraw,1)*size(Xraw,2);
                Xraw = Xraw - mean(Xraw(1:nVals));
                Xraw = Xraw ./ std(Xraw(1:nVals));
            end

            TSaver.Save('Trace Resampling/Extending');

            %For traces, we use the cityblock (manhattan) distance metric
            metric_to_use = 'cityblock';

        case 'Hybrid'
            OutputStruct.Format = 'TraceEnhancedDataPoints';

            Xraw = getTraceEnhancedRawData(data, slope_window, left_chop, ...
                CondCeiling);

            %Store raw data
            OutputStruct.Xraw = Xraw;

            Xraw = DataStandardization(Xraw, 'Hybrid');
            OutputStruct.Normalization = 'Middle80%';

            TSaver.Save('Data PreProcessing');

            metric_to_use = 'euclidean';

        case 'Segments'
            OutputStruct.Format = 'Segments';

            disp('Begin trace segmentation...');
            [AllSegments,AllBounds,~,TraceIDs,TracesUsed] = ...
                SegmentAllTraces(data,'ErrorGain',left_chop,CondCeiling,...
                false,pool);

            %Get parameters for segments
            [Xraw, NormInfo] = ParametrizeSegments(AllSegments,AllBounds,TraceIDs,...
                TracesUsed,true);
            OutputStruct.NormInfo = NormInfo;

            %Extra work to do if we want to weight segments by duplicating them
            %in proportion to their lengths:
            if length_weighting

                %Over-write format
                OutputStruct.Format = 'Segments_LengthWeighting';

                %Store specific parameters:
                OutputStruct.length_per_duplicate = length_per_duplicate;

                %Duplicate segments in proportion to their lengths
                %(over-writing Xraw in the process)
                [Xraw, dupIDs, Ndups, OGvsDup] = ...
                    DuplicateSegments(AllSegments,Xraw,length_per_duplicate);

                %Lengthen these outputs to include duplicates:
                AllSegments = AllSegments(dupIDs,:);
                AllBounds = AllBounds(dupIDs,:);
                TraceIDs = TraceIDs(dupIDs);

                %Store extra outputs:
                OutputStruct.duplicateIDs = dupIDs;
                OutputStruct.Nduplicates = Ndups;
                OutputStruct.original_vs_duplicate = OGvsDup;
            end       

            OutputStruct.Xraw = Xraw;
            OutputStruct.AllSegments = AllSegments;
            OutputStruct.AllBounds = AllBounds;
            OutputStruct.SegmentTraceIDs = TraceIDs;
            OutputStruct.TracesUsed = TracesUsed;

            TSaver.Save('Trace Segmentation');
            clear AllSegments AllBounds TraceIDs;

            %metric_to_use = 'cityblock'; 
            metric_to_use = 'euclidean';   

        case 'Segments_PreSegmented'
            OutputStruct.Format = 'Segments';

            AllSegments = data.AllSegments;
            AllBounds = data.AllBounds;
            TraceIDs = data.TraceIDs;
            TracesUsed = data.TracesUsed;
            
            %Get parameters for segments
            [Xraw, NormInfo] = ParametrizeSegments(AllSegments,AllBounds,TraceIDs,...
                TracesUsed,true);   
            OutputStruct.NormInfo = NormInfo;
            
            %Extra work to do if we want to weight segments by duplicating them
            %in proportion to their lengths:
            if length_weighting

                %Over-write format
                OutputStruct.Format = 'Segments_LengthWeighting';

                %Store specific parameters:
                OutputStruct.length_per_duplicate = length_per_duplicate;

                %Duplicate segments in proportion to their lengths
                %(over-writing Xraw in the process)
                [Xraw, dupIDs, Ndups, OGvsDup] = ...
                    DuplicateSegments(AllSegments,Xraw,length_per_duplicate);

                %Lengthen these outputs to include duplicates:
                AllSegments = AllSegments(dupIDs,:);
                AllBounds = AllBounds(dupIDs,:);
                TraceIDs = TraceIDs(dupIDs);

                %Store extra outputs:
                OutputStruct.duplicateIDs = dupIDs;
                OutputStruct.Nduplicates = Ndups;
                OutputStruct.original_vs_duplicate = OGvsDup;
            end     
            
            OutputStruct.Xraw = Xraw;
            OutputStruct.AllSegments = AllSegments;
            OutputStruct.AllBounds = AllBounds;
            OutputStruct.SegmentTraceIDs = TraceIDs;
            OutputStruct.TracesUsed = TracesUsed;

            TSaver.Save('Data Unpacking');

            metric_to_use = 'euclidean';        

    %     %Clustering traces that have already been choppped so that they are all
    %     %the same length
    %     case 'Traces'
    %         OutputStruct.Xdist = data.Xdist;
    %         OutputStruct.dataset_name = data.name;
    %         OutputStruct.Ntraces = data.Ntraces;
    %         OutputStruct.StartChop = data.StartChop;
    %         OutputStruct.EndChop = data.EndChop;
    %         OutputStruct.OGTraceNum = data.OGTraceNum;
    %         
    %         %Unpack traces into single matrix with one row for each trace
    %         Ntraces = data.Ntraces;
    %         Npts = length(data.Trace1);
    %         Xraw = zeros(Ntraces, Npts);
    %         for i = 1:Ntraces
    %             Xraw(i,:) = data.(strcat('Trace',num2str(i)));
    %         end
    %         clear data;
    %         
    %         TSaver.Save('Data Unpacking');
    %         
    %         %For traces, we use the cityblock (manhattan) distance metric
    %         [RD,CD,order,TSaver] = MultiPartitionParallel_WhileLoop_NbhdList(Xraw,...
    %             minPts,minSize,cL,cP,TSaver,pool,'cityblock');
    %         
    %         %Save output
    %         OutputStruct.Xraw = Xraw;
    %         OutputStruct.Format = 'Traces';
    %         
    %     %Clustering of traces using the overlap method for distance (not great;
    %     %it's not a metric!)
    %     case 'TraceOverlap'
    %         OutputStruct.Xraw = data.TraceMatrix;
    %         OutputStruct.TraceBounds = data.TraceBounds;
    %         OutputStruct.dataset_name = data.name;
    %         OutputStruct.Xdist = data.Xdist;
    %         clear data;
    %         
    %         [RD,CD,order,TSaver] = ...
    %             MultiPartitionParallel_WhileLoop_NbhdList_TraceOnly(...
    %             OutputStruct.Xraw,OutputStruct.TraceBounds,minPts,...
    %             minSize,cL,cP,TSaver,pool);    
    % 
    %         %Save output
    %         OutputStruct.Format = 'TraceMatrix';

        otherwise
            disp('ERROR: UNRECOGNIZED CLUSTER MODE');
    end

    %Save metric being used:
    OutputStruct.ClusteringInputParameters.distance_metric = metric_to_use;

    %Randomly shuffle the raw data so that the order it happened to be in
    %cannot affect the OPTICS ordering in a systematic way:
    nRows = size(Xraw,1);
    shuffle_order = randperm(nRows)';
    Xraw = Xraw(shuffle_order, :);

    %Cluster data! Use either full SOPTICS algorithm (preferred) or just the 
    %'regular' OPTICS algorithm
    clear data;
    if strcmp(clustering_algorithm,'SOPTICS')
        %Because 'ExtendedTraces' needs a special distance calculation, it
        %needs to call a different version of the clustering program
        if strcmp(clustering_mode, 'ExtendedTraces')
            %Need to shuffle the trace ends
            og_tr_ends = og_tr_ends(shuffle_order);
            
            %Shift up all points so that the noise floor extensions occur
            %along zero and thus won't contribute to the projections
            Xraw = Xraw + CondFloor;
            
            [RD,CD,order,TSaver] = MultiPartitionParallel_WhileLoop_NbhdList_ExtTrOverlap(Xraw,...
                minPts,minSize,cL,cP,TSaver,pool,og_tr_ends);       
        else
            [RD,CD,order,TSaver] = MultiPartitionParallel_WhileLoop_NbhdList(Xraw,...
                minPts,minSize,cL,cP,TSaver,pool,metric_to_use);  
        end
    elseif strcmp(clustering_algorithm,'OPTICS')
        if strcmp(clustering_mode, 'ExtendedTraces')
            error('Not ready yet');
        end
        OutputStruct.geneps = geneps;
        [RD,CD,order] = OPTICS_StandAlone(Xraw,minPts,geneps,metric_to_use);
        TSaver.Save('Optics');
    else
        error('INVALID CLUSTERING ALGORITHM REQUESTED');
    end

    %The following code unshuffles Xraw, but is not necessary because Xraw
    %was saved out before being shuffled (but nice to have around in case!)
%     temp = [shuffle_order, (1:nRows)'];
%     temp = sortrows(temp,1);
%     unshuffle_order = temp(:,2);
%     Xraw = Xraw(unshuffle_order,:); %Xraw was already saved pre-shuffling

    %Undo the shuffling of the data by changing 'order' to align with the original
    %ordering of the data    
    order = shuffle_order(order);

    %Create time summary table
    TimeSummary = TSaver.CreateTable();

    %Finish creating output structure
    OutputStruct.RD = RD;
    OutputStruct.CD = CD;
    OutputStruct.order = order;
    OutputStruct.TimeSummary = TimeSummary;

    %Display time summary table
    disp('Summary of time used:');
    disp(TimeSummary);
    disp('Clustering Complete!');
end