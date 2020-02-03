%30May18 NDB: Split off from the version used in SOPTICS, minor changes
%made so that this runs the 'regular' optics algorithm
function [RD, CD, order] = OPTICS_StandAlone(points, minpts, geneps, metric)

    disp('Begin OPTICS stand-alone ordering...');

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
            dist = pdist2(points(ii,:),points,metric);
            nbhd = find(dist < geneps);

            order(k) = ii; % object processed is true
            OP(ii) = true;

            %Find Core distance
            if length(nbhd) < minpts
                CD(k) = 0;
            else
                dist = dist(nbhd);
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
                    if mod(k,128) == 0
                        disp([k M length(nbhd)]);
                    end    

                    %Get point from top of queue
                    [RD(k), currentp] = seeds.pop();

                    %Get neighbors of current point
                    dist = pdist2(points(currentp,:),points,metric);
                    nbhd = find(dist < geneps);

                    if length(nbhd) < minpts
                        CD(k) = 0;
                    else
                        dist = dist(nbhd);
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
            if mod(k,128) == 0
                disp([k M length(nbhd)]);
            end            

        end    
    end

end
