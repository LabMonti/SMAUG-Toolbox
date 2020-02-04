function [RD,CD,order,TSaver] = ...
    MultiPartitionParallel_WhileLoop_NbhdList(points,minPts,minSize,cL,...
    cP,TSaver,pool,metric)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: The guts of the SOPTICS program!  Performs
    %random projections, performs multipartition to determine neighborhoods
    %for each point, and then performs the OPTICS algorithm to put points
    %in a cluster order.  In order to reduce memory usage, sub-functions
    %are defined within this file so that large arrays do not have to be
    %duplicated for transport.  
    %
    %~~~INPUTS~~~:
    %
    %points: and N by d array in which each row contains the coordinates of
    %   a points in d dimenions.  This is the set of points that will be
    %   clustered.  
    %
    %minPts: the minPts parameter used in the OPTICS algorithm
    %
    %minSize: the minSize parameter used in multiparition
    %
    %cL: the cL parameter used for projections
    %
    %cP: the cP parameter used for projections
    %
    %TSaver: a TSaver object used to record how long each step takes
    %
    %pool: a parallel pool to speed up the projection step; can be set to
    %   an empty vector if parallelization is not being used
    %
    %metric: the name of the distance metrix to be used for calculation
    %   distances between different points
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %RD: a vector containing the reachability distance for each point, 
    %   listed in the order of the cluster order
    %
    %CD: a vector containing the core distance for each point, 
    %   listed in the order of the cluster order
    %
    %order: a vector containing the cluster order.  So, if order(i) = j,
    %   that means that the jth point in the original data matrix appears
    %   in the ith position in the cluster order (and so RD(i) and CD(i)
    %   are the reachability and core distances, respectively, for the jth
    %   point in the original data matrix).  
    %
    %TSaver: the same TSaver object that was passed in, now updated with
    %   the times for the steps carried out by this function
    

    %Data dimension, number of points
    d = length(points(1, :));
    N = length(points(:, 1));
    
    %Compute number of lines and partitions
    nLines = ceil(cL * log2(N*d));
    npartitions = ceil(cP * log2(N*d));      
        
    %Create function handles
    partS_fnc = @PartitionSOPTICS;
    
    %Create random vectors
    vectors = zeros(d, nLines);
    for i = 1:nLines
        for j = 1:d
            vectors(j, i) = rand()*2 - 1;
        end
    end
    
    TSaver.Save('Create Random Vectors');
    disp('---BEGIN PROJECTIONS---');
    
    %Project points onto each of the random vectors
    projections = zeros(N, nLines);
    if isempty(pool)
        for j = 1:nLines
            for i = 1:N
                projections(i,j) = points(i, :) * vectors(:, j);
            end
            if mod(j, 64) == 0
                disp([j nLines]);
            end
        end
    else       
        parfor j = 1:nLines
            for i = 1:N
                projections(i,j) = points(i, :) * vectors(:, j);
            end
            if mod(j, 64) == 0
                disp([j nLines]);
            end
        end
        delete(pool);
    end
    
    TSaver.Save('Project');
    disp('---BEGIN PARTITIONING---');
    
    %Run each partition to get list of neighbors
    neighbor_list1 = zeros(npartitions, ceil(N - N/minSize),'uint32');
    neighbor_list2 = zeros(npartitions, ceil(N - N/minSize),'uint32');
    list_sizes = zeros(npartitions,1);
    nbhd_sizes = zeros(N+1,1); %do NOT use 32-bit here!!!
    for i = 1:npartitions
        LineOrder = randperm(nLines); %Random order to use lines in
        [neighbor_list1(i,:), neighbor_list2(i, :), list_sizes(i)] = ...
            feval(partS_fnc, LineOrder, minSize,N);
        if mod(i, 64) == 0
            disp([i npartitions]);
        end           
    end
    clear projections;
    TSaver.Save('Partition');

    disp('---BEGIN UNPACKING NEIGHBORHOODS---');
    %Turn nbhd_sizes into list of starting indices for each
    %neighborhood's section
    prev = nbhd_sizes(1);
    nbhd_sizes(1) = 1;
    for i = 2:N+1
        curr = nbhd_sizes(i);
        nbhd_sizes(i) = prev + nbhd_sizes(i-1);
        prev = curr;
    end

    %Create a single vector for the nbhds and fill it up!
    nbhds = zeros(2*npartitions*ceil(N - N/minSize),1,'uint32');
    fill_counts = zeros(N,1); %do NOT use 32-bit here!!!
    for i = 1:npartitions
        for j = 1:list_sizes(i)
            val1 = neighbor_list1(i,j);
            val2 = neighbor_list2(i,j);

            %val1 is a neighbor of val2
            start_index = nbhd_sizes(val1);
            nbhds(start_index + fill_counts(val1)) = val2;
            fill_counts(val1) = fill_counts(val1)+1;

            %val2 is a neighbor of val1
            start_index = nbhd_sizes(val2);
            nbhds(start_index + fill_counts(val2)) = val1;
            fill_counts(val2) = fill_counts(val2)+1;            
        end
        if mod(i, 64) == 0
            disp([i npartitions]);
        end
    end
    clear neighbor_list1;
    clear neighbor_list2;
    clear fill_counts;
    clear list_sizes;
    TSaver.Save('Apportion Neighbors');

    disp('---BEGIN OPTICS ORDERING---');
    %Run optics algorithm to order points now that all neighborhoods have
    %been pre-calculated
    [RD,CD,order] = Sopticsv2_NbhdList(minPts,metric);
    TSaver.Save('Optics');
        

    function [nb_pair_list1, nb_pair_list2, nb_counter] = ...
        PartitionSOPTICS(LineOrder,minSize,BigN)

        nb_pair_list1 = zeros(1, ceil(BigN - BigN/minSize),'uint32');
        nb_pair_list2 = zeros(1, ceil(BigN - BigN/minSize),'uint32');
        nb_counter = 0;
        
        %Factor of 2 chosen to make cell array big enough with some room to
        %spare
        max_tree_height = 2*ceil(log2(BigN));

        point_sets_queue = cell(max_tree_height, 1);
        level_index_queue = zeros(max_tree_height, 1, 'uint32');

        %Initialize queue with set of all point IDs
        point_sets_queue{1} = linspace(1,BigN,BigN);
        level_index_queue(1) = 1;

        last_spot = 1;

        while last_spot > 0

            %Get next set of point IDs from the queue
            pointIDs = point_sets_queue{last_spot};
            LevelIndex = level_index_queue(last_spot);
            last_spot = last_spot - 1;

            currN = length(pointIDs);

            %Projections of current points onto current line (use same line for all
            %splitting on the same level down the tree)
            current_projections = projections(pointIDs, LineOrder(LevelIndex));

            %Choose one projection randomly (no point in choosing largest
            %projection because then we'd be left with an empty partition)
            r_ind = randi(length(current_projections));
            r = current_projections(r_ind);

            %Create arrays to hold two new partitions
            new_pointIDs1 = zeros(currN, 1);
            new_pointIDs2 = zeros(currN, 1);

            %Divide up points into two partitions and keep track of each partitions
            %size, which line values go into each partition, and which point IDs
            %go into each partitions
            s1 = 0;
            s2 = 0;
            for k = 1:currN
                if current_projections(k) < r
                    s1 = s1 + 1;
                    new_pointIDs1(s1) = pointIDs(k);
                elseif current_projections(k) > r
                    s2 = s2 + 1;
                    new_pointIDs2(s2) = pointIDs(k);
                else
                    %In the case of ties, randomly assign (avoids problem
                    %of getting all points repeatedly stuck in one
                    %partition)
                    if rand() > 0.5
                        s1 = s1 + 1;
                        new_pointIDs1(s1) = pointIDs(k);
                    else
                        s2 = s2 + 1;
                        new_pointIDs2(s2) = pointIDs(k);        
                    end                    
                end
            end
            %Remove empty portions of each array (important!)
            new_pointIDs1 = new_pointIDs1(1:s1);
            new_pointIDs2 = new_pointIDs2(1:s2); 

            %Check if new right partition is small enough:
            if s2 <= minSize
                if s2 > 0

                    %Choose a random point Pcenter
                    Pcenter_index = randi(s2);
                    ID_P = new_pointIDs2(Pcenter_index);   
                    
                    %Go through points before Pcenter, add each one with
                    %Pcenter as a neighbor pair
                    for k = 1:Pcenter_index - 1
                        ID_k = new_pointIDs2(k);
                        
                        nb_counter = nb_counter + 1;
                        
                        nb_pair_list1(nb_counter) = ID_P;
                        nb_pair_list2(nb_counter) = ID_k;
                        
                        %Update neighborhood sizes
                        nbhd_sizes(ID_k) = nbhd_sizes(ID_k) + 1;
                    end

                    %Same for points after Pcenter
                    for k = Pcenter_index + 1:s2
                        ID_k = new_pointIDs2(k);
                        
                        nb_counter = nb_counter + 1;
                        
                        nb_pair_list1(nb_counter) = ID_P;
                        nb_pair_list2(nb_counter) = ID_k;
                        
                        %Update neighborhood sizes
                        nbhd_sizes(ID_k) = nbhd_sizes(ID_k) + 1;                        
                    end            
                    
                    %Update neighborhood sizes
                    nbhd_sizes(ID_P) = nbhd_sizes(ID_P) + (s2 - 1);

                end

            else

                %Add set of points to queue
                last_spot = last_spot + 1;
                point_sets_queue{last_spot} = new_pointIDs2;
                level_index_queue(last_spot) = LevelIndex + 1;

            end        

            %Check if new left partition is small enough:
            if s1 <= minSize
                if s1 > 0

                    %Choose a random point Pcenter
                    Pcenter_index = randi(s1);
                    ID_P = new_pointIDs1(Pcenter_index);   
                    
                    %Go through points before Pcenter, add each one with
                    %Pcenter as a neighbor pair
                    for k = 1:Pcenter_index - 1
                        ID_k = new_pointIDs1(k);
                        
                        nb_counter = nb_counter + 1;
                        
                        nb_pair_list1(nb_counter) = ID_P;
                        nb_pair_list2(nb_counter) = ID_k;
                        
                        %Update neighborhood sizes
                        nbhd_sizes(ID_k) = nbhd_sizes(ID_k) + 1;
                    end

                    %Same for points after Pcenter
                    for k = Pcenter_index + 1:s1
                        ID_k = new_pointIDs1(k);
                        
                        nb_counter = nb_counter + 1;
                        
                        nb_pair_list1(nb_counter) = ID_P;
                        nb_pair_list2(nb_counter) = ID_k;
                        
                        %Update neighborhood sizes
                        nbhd_sizes(ID_k) = nbhd_sizes(ID_k) + 1;
                    end       
                    
                    %Update neighborhood sizes
                    nbhd_sizes(ID_P) = nbhd_sizes(ID_P) + (s1 - 1);

                end

            else
                %Add set of points to queue
                last_spot = last_spot + 1;
                point_sets_queue{last_spot} = new_pointIDs1;
                level_index_queue(last_spot) = LevelIndex + 1;

            end       
        end
        
        clear point_sets_queue;
        clear level_index_queue;

    end

    function [RD,CD,order]=Sopticsv2_NbhdList(minpts,metric)

        M = size(points,1);
        % tells us whether an object has been processed
        OP = false(M,1);
        % the order variable will tell us in which order the data is processed 
        order = zeros(M,1);
        % CD will store all the core distances
        CD = zeros(M,1);
        % RD will store all of the reachability distances
        RD = zeros(M,1);
        % Objects which are directly density-reach-able from a current core object 
        % are inserted into the seed-list for further expansion
        seeds = UpdateablePriorityQueue(M);
        k = 1; % order index

        % This is the main loop of the program. It checks to see if an object has
        % been processed. If it has not been processed, we expand the cluster order
        % around that object
        for ii = 1:M
            if ~OP(ii)

            %Get neighbors
            nbhd = nbhds(nbhd_sizes(ii):nbhd_sizes(ii+1)-1,1);
            nbhd = unique(nbhd);

            order(k) = ii; % object processed is true
            OP(ii) = true;

            %Find Core distance
            if length(nbhd) < minpts
                CD(k) = 0;
            else
                dist = pdist2(points(ii,:),points(nbhd,:),metric);
                sortd = sort(dist);  
                CD(k) = sortd(minpts);
            end

            % Establishing reachability distance
            RD(k) = Inf;

            if CD(k) > 0 %if core distance is not undefined

                %Add neighbors to seeds queue
                for jj = 1:length(dist)
                    %Only add if not already processed
                    if ~OP(nbhd(jj))
                        newrdist = max(dist(jj),CD(k));
                        seeds.AddOrUpdate(newrdist, nbhd(jj));
                    end
                end

                while seeds.last_element > 0
                    % increment the order index
                    k = k + 1;
                    if mod(k,1024) == 0
                        disp([k M length(nbhd)]);
                    end    

                    %Get point from top of queue
                    [RD(k), currentp] = seeds.pop();

                    %Get neighbors of current point
                    nbhd = nbhds(nbhd_sizes(currentp):nbhd_sizes(currentp+1)-1,1);
                    nbhd = unique(nbhd);

                    if length(nbhd) < minpts
                        CD(k) = 0;
                    else
                        dist = pdist2(points(currentp,:),points(nbhd,:),metric);
                        sortd = sort(dist);
                        CD(k) = sortd(minpts);
                    end

                    OP(currentp) = true; % current object is processed
                    order(k) = currentp; % storing order in which we process the points        

                    if CD(k) > 0 %if core distance is not undefined

                        %Add neighbors to seeds queue
                        for jj = 1:length(dist)
                            %Only add if not already processed
                            if ~OP(nbhd(jj))
                                newrdist = max(dist(jj),CD(k));
                                seeds.AddOrUpdate(newrdist, nbhd(jj));
                            end
                        end
                    end

                end
            end

            k = k + 1;
            if mod(k,1024) == 0
                disp([k M length(nbhd)]);
            end            

            end    
        end

    end

end
