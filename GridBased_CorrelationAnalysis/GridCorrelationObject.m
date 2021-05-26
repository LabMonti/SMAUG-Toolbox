classdef GridCorrelationObject < handle
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Description: this object class is the centerpiece of the grid-based
    %correlation analysis component of the SMAUG Toolbox. It is designed to
    %convert a set of traces into "coarsened" traces, then store those
    %coarse traces as well as information about the nodes that make them up
    %and correlations between them. 
    
    properties (SetAccess = public, GetAccess = public)
        
        dataset_name = '';
        Multiple_Sections = true;
        
        %Distance between neighboring nodes on the x and y axes, in
        %whatever units are used for those axes in the original traces
        Xstep = 1/25;
        Ystep = 1/10;
        
        %x and y values for the bottom left of all the nodes, in whatever
        %units are used for x and y in the original traces
        Xstart = 0;
        Ystart = 0;
        
        Ntraces = 0;
        CoarseTraces = {};
        NumTotalNodes = 0;
        TotalNodePairCount = 0;  
        NUnique = 0; %# of unique nodes in the whole dataset
        UniqueNodes = []; %two-column matrix of node coordinates
        NodeFreqs = []; %vector of the # of traces passing through each node
        AllNodeIDs = [];
        CoarseTraceLengths = []; %vector with the # of nodes in each coarse trace
        
        %Vector containing the ID# of the original traces that each coarse
        %trace is taken from; neccessary when multiple_sections is true,
        %or if coarse traces have been removed
        OriginalTraceIDs = [];
        
        %nNodes x nTraces logical array showing whether each trace passes
        %through each node or not
        NodeOccupancy = [];   
        
        %Nx2 matrix, with one row per node and the two columns listing the
        %node IDs for the nodes immediately below and above a given node.
        %For any neighboring nodes that don't exist, the original node ID
        %is listed (and analogous for horizontal neighbors)
        VerticalNeighbors = [];
        HorizontalNeighbors = [];
        
        %Nx4 logical matrix, with one row per node and columsn for, in
        %order, southern neighbor, northern neighbor, western neighbor,
        %eastern neighbor. An element being true means that the node in
        %question does NOT have a direct neighbor in that direction. Having
        %this data stored speeds up checking whether MCMC steps are allowed
        %or not.
        MissingNeighbors = [];
              
        %Important note: the following properties are all square matrices
        %to hold information about each ordered node pair. However, their
        %size is actually NUnique+2 x NUnique+2. While the first NUnique
        %rows and columns correspond to the node ID #s of the unique nodes
        %in the dataset, the NUnique+1 ID refers to the "start node" and
        %the NUnique+2 ID refers to the "end node". As the names suggest,
        %we imagine that every traces begins at the start node, then goes
        %through all the actual spatial nodes it passed through, then ends
        %at the end node. Defining these start and end nodes makes it
        %easier, for example, to generate random traces. 
        
        %Matrix where M(i,j) gives the probability of DIRECTLY transfering
        %from node i to node j in a single step
        TransferProbs = [];
        
        %Cumulative transfer probs can be stored to speed up random walk
        %calculations
        CumulativeTransferProbs = [];
        
        %Matrix where M(i,j) gives the probability of passing through node
        %j given that a trace passed through node i, under the null
        %hypothesis of no correlations (i.e., random walk behavior)
        ExpectedNodePairProbs = [];     
        
        %Matrix where M(i,j) gives the number of traces passing through
        %node i and then node j
        ActualNodePairCounts = [];
        
        %Matrix where M(i,j) is 1 iff node i is directly connected to node
        %j by at least one trace
        NodeNeighbors = [];
        
        %Matrices where M(i,j) gives the p-value from a binomial hypothesis
        %test carried out for >= (above) or <= (below) the # of observed
        %traces passing from node i to node j, respectively
        PValues_above = [];
        PValues_below = [];      
        
        %Connection strength is a symmetric quantity calculated for each
        %node pair that is based on the natural logarithms of the two
        %different p-values
        ConnectionStrengths = [];       
    end
    
    methods
        
        function obj = GridCorrelationObject(TraceStruct, gridsper_x, ...
                gridsper_y, multiple_sections)
            
            %If no arguments are inputted, an empty GridCorrelationObject
            %object with the default properties will be created
            if nargin > 0
                if nargin < 4
                    multiple_sections = true;
                end

                %Overwrite defaults if inputs are included
                if nargin > 1
                    obj.Xstep = 1/gridsper_x;
                end
                if nargin > 2
                    obj.Ystep = 1/gridsper_y;
                end

                disp('Coarse-gridding all traces in Trace Structure...');
                initialize_GridCorrelationObj(obj, TraceStruct, ...
                    obj.Xstep, obj.Ystep, multiple_sections);
                index_nodes(obj);
                obj.Multiple_Sections = multiple_sections;
                obj.dataset_name = TraceStruct.name;
            end      
        end
        
        %Remove any node that has fewer than minTraceThruNode passing
        %through it; the way we do this is by removing all traces passing
        %through the node (otherwise we would have connectivity problems!)
        function nTracesRemoved = remove_lowtrace_nodes(obj,minTracesThruNode)
            
            if nargin < 2
                minTracesThruNode = 2;
            end
            
            %Make sure that all advanced information that will change when
            %nodes are removed is blanked out, so that we don't end up with
            %contradictory informaiton stored inside the same object
            obj.NodeOccupancy = [];      
            obj.TransferProbs = [];
            obj.CumulativeTransferProbs = []; 
            obj.ExpectedNodePairProbs = []; 
            obj.ActualNodePairCounts = [];
            obj.NodeNeighbors = [];
            obj.TotalNodePairCount = 0;
            obj.PValues_above = [];
            obj.PValues_below = [];
            obj.ConnectionStrengths = [];
            
            nTracesRemoved = removeTraces_through_LowNodes(obj,minTracesThruNode);          
        end
        
        %Remove any node that has neither a northern nor a southern
        %neighbor (since the MCMC can easily get stuck on such nodes); the
        %way we will do this will be to remove entire traces passing
        %through those node (otherwise we would have connectivity
        %problems!)
        function nTracesRemoved = remove_dangling_nodes(obj)
            %Make sure that all advanced information that will change when
            %nodes are removed is blanked out, so that we don't end up with
            %contradictory informaiton stored inside the same object
            obj.NodeOccupancy = [];      
            obj.TransferProbs = [];
            obj.CumulativeTransferProbs = []; 
            obj.ExpectedNodePairProbs = []; 
            obj.ActualNodePairCounts = [];
            obj.NodeNeighbors = [];
            obj.TotalNodePairCount = 0;
            obj.PValues_above = [];
            obj.PValues_below = [];
            obj.ConnectionStrengths = [];
            
            nTracesRemoved = removeDanglingNodes(obj);            
        end
        
        %Combination of the above two funcions; since either removal can
        %affect which nodes need to be removed for the other, we need to
        %iterate until no nodes need to be removed
        function nTracesRemoved = remove_LowOrDangling_nodes(obj,...
                minTracesThrough)
            
            if nargin < 2
                minTracesThrough = 2;
            end
            
            n1 = obj.remove_lowtrace_nodes(minTracesThrough);
            n2 = obj.remove_dangling_nodes();
            nTracesRemoved = n1 + n2;
            while n1 + n2 > 0
                n1 = obj.remove_lowtrace_nodes(minTracesThrough);
                n2 = obj.remove_dangling_nodes();
                nTracesRemoved = nTracesRemoved + n1 + n2;    
            end            
        end
        
        function calculate_NodeOccupancies(obj)
            add_NodeOccupancies(obj);
        end
        
        function calculate_VerticalNeighbors(obj)
            add_VerticalNeighbors(obj);
        end
        
        function calculate_HorizontalNeighbors(obj)
            add_HorizontalNeighbors(obj);
        end
        
        function calculate_MissingNeighbors(obj)
            add_MissingNeighbors(obj);
        end
        
        function calculate_NodeNeighbors(obj)
            disp('Calculating node neighbors...');
            if isempty(obj.TransferProbs)
                obj.calculate_TransferProbs();
            end
            
            obj.NodeNeighbors = false(obj.NUnique + 2);
            obj.NodeNeighbors(obj.TransferProbs > 0) = true;   
        end
        
        function calculate_TransferProbs(obj)
            disp('Calculating probability of transfering between each pair of ADJACENT nodes...');
            add_TransferProbs(obj);
        end
        
        function calculate_ExpectedNodePairProbs(obj,Parallelize)
            %Make sure transfer probabilities exist
            if isempty(obj.TransferProbs)
                obj.calculate_TransferProbs();
            end
            if nargin < 2
                Parallelize = false;
            end
            
            disp('Calculating expected probability of passing through each pair of nodes assuming null hypothesis..');
            add_ExpectedNodePairProbs(obj,Parallelize);
        end
        
        function calculate_ActualNodePairCounts(obj)
            disp('Calculating observed # of traces passing through each pair of nodes...');
            add_ActualNodePairCounts(obj);
        end
        
        function calculate_NodePair_PValues(obj)
            if isempty(obj.ExpectedNodePairProbs)
                obj.calculate_ExpectedNodePairProbs;
            end
            if isempty(obj.ActualNodePairCounts)
                obj.calculate_ActualNodePairCounts;
            end
            
            disp('Calculating p-values for number of traces betwen each pair of nodes...');
            add_NodePair_PValues(obj);
            
        end
        
        function calculate_CumulativeTransferProbs(obj)
            if isempty(obj.TransferProbs)
                obj.calculate_TransferProbs;
            end
            
            NNodes = obj.NUnique + 2;
            Cumulative_Probs = zeros(NNodes);
            for i = 1:NNodes
                Cumulative_Probs(i,1) = obj.TransferProbs(i,1);
                for j = 2:NNodes
                    Cumulative_Probs(i,j) = Cumulative_Probs(i,j-1) + ...
                        obj.TransferProbs(i,j);
                end
            end
            obj.CumulativeTransferProbs = Cumulative_Probs;
        end
        
        function calculate_ConnectionStrengths(obj)           
            if isempty(obj.PValues_above)
                obj.calculate_NodePair_PValues;
            end
            
            %NUnique+1 is for the "StartTrace" node, NUnique+2 is for the
            %"EndTrace" node
            obj.ConnectionStrengths = zeros(obj.NUnique+2);
            
            %Go through each unique pair of nodes and calculate "strength" of
            %the connection between them
            for i = 1:obj.NUnique+2
                for j = i:obj.NUnique+2
                    strength = get_connection_strength(obj,i,j);
                    obj.ConnectionStrengths(i,j) = strength;
                    obj.ConnectionStrengths(j,i) = strength;
                end
                if mod(i,512) == 0
                    disp([i obj.NUnique]);
                end
            end
            
        end
        
        %Given a node that could be EITHER the form of a single node id# OR
        %a pair of node coordinates, return the node id# for that node
        function nodeID = getNodeID(obj, node)
            if length(node) == 2
                nodeID = obj.AllNodeIDs(node(1),node(2));
            elseif length(node) == 1
                nodeID = node;
            else
                error('Unrecognized input format!');
            end
        end
        
        function AllObjectData = save_ObjectAsStruct_ToFile(obj, ...
                file_name, file_path)
            
            %Get list of all object properties
            props = properties(obj);
            n = length(props);
            
            %Save each property as a field of a structure array, and return
            %this to the user. This allows the information to be saved to a
            %file!
            AllObjectData = struct();
            for i = 1:n
                AllObjectData.(props{i}) = obj.(props{i});
            end
            
            %Prompt user to save to a file (note: structure will also be
            %returned as an output, so user can save it manually) IF a file
            %name and path were not passed in as variables
            if nargin < 3
                [file_name, file_path] = uiputfile('*.mat',...
                    'Save File Name', 'CoarseGridInfo.mat');
            end
            
            if file_name
                save(fullfile(file_path,file_name),'AllObjectData');
            end
            
        end
        
        function replaceAllProps_from_file(obj, file_name, file_path)
            %Get file from user IF not passed as input
            if nargin < 3
                [file_name, file_path, ~] = uigetfile('*.mat');
            end
            
            %Read in data from file
            if exist(fullfile(file_path,file_name),'file') == 2
                AllObjectData = importdata(fullfile(file_path,file_name));

                obj.replaceAllProps_from_struct(AllObjectData);
            else
                disp(strcat('No such file found: ',fullfile(...
                    file_path,file_name)));
            end
        end
        
        %Fill in all fields from data stored in a Matlab structure array
        function replaceAllProps_from_struct(obj, struct)
            %Get list of all fields of structure array
            props = fieldnames(struct);
            n = length(props);
            
            %Use fields of struture array to overwrite all properties of
            %object (this can be used to load in a saved object!)
            for i = 1:n
                obj.(props{i}) = struct.(props{i});
            end            
        end
        
    end 
    
end