function [trace_segments,ErrorData] = SegmentTrace_SpecifyNSegs(trace, ...
    numSegsChosenRange, initial_pointsPerSeg, ToPlot)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: This function segments the input trace using 
    %the bottom-up segmentation algorithm.  numSegsChosenRange can either 
    %be a single number representing the target # of final segments, or a 
    %2-element vector containing a minimum and maximum targe # of final 
    %segments.  If the latter, the final trace_segments will be stored for
    %each value in that range.  The error gained at each merge step is 
    %stored for all merge steps.
    %
    %~~~INPUTS~~~:
    %
    %trace: a two-column array with distances in the first column and
    %   log(G/G_0) in the second column
    %
    %numSegsChosenRange: the target #(s) of segments in the final
    %   segmentation of trace.  Can either be a single number or a
    %   two-element vector specifying a range of segment #s
    %
    %initial_pointsPerSeg: the # of points in each of the initial segments
    %   at the start of the BUS algorithm (must be at least 2, #obvi)
    %
    %ToPlot: logical variable, whether or not to plot the final
    %   segmentation solution
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %trace_segments: a cell array with one row for each target # of
    %   segments specifyed by numSegsChosenRange. In the first column is an
    %   array holding the x- and y- endpoint values for each segment; in
    %   the second column is an array listing the starting and ending
    %   trace-point indices for each segment; in the 3rd column is the
    %   final total error; and in the 4th column is the error gained in the
    %   final merge step
    %
    %ErrorData: a three-column array with # of segments in the first
    %   column, error gained in the second, and total error in the third


    %Default initial # of points per trace is 2 (the minimum and most
    %accurate)
    if nargin < 3
        initial_pointsPerSeg = 2;
    end
    if nargin < 4
        ToPlot = false;
    end
    
    %Make cell array to store the output
    numToStore = max(numSegsChosenRange) - min(numSegsChosenRange) + 1;
    
    %First column contains the segment endpoints, second column contains
    %the segment bounds (as indices for the trace itself), third column
    %contains total error, fourth column contains error gain for last step
    trace_segments = cell(numToStore,4);
    output_counter = 0;

    %# of data points on trace
    N = size(trace, 1);
    
    %Initial # of segments (put each consecutive pair of points into a
    %segment)
    nSegs = floor(N/initial_pointsPerSeg);
    nSegsOG = nSegs;
    
    %The first column of SegBounds gives the starting index of each
    %segment, the second gives the ending index
    SegBounds = zeros(nSegs, 2);
    
    %ActiveSegs can be set to false for those rows of SegBounds that
    %are no longer used because segments have been merged
    ActiveSegs = true(nSegs,1);
    
    %Construct all the initial segments (each two points long) by
    %specifying their start and end point indices
    for i = 1:nSegs
        SegBounds(i,1) = 1 + (i-1)*initial_pointsPerSeg;
        SegBounds(i,2) = initial_pointsPerSeg + (i-1)*initial_pointsPerSeg;
    end
    
    %If there were an odd # of data points, make the last segment 3 points
    %long
    if SegBounds(nSegs,2) < N
        SegBounds(nSegs,2) = N;
    end
    
    %Make vector for the error of each segment, and calculate those errors
    %for the initial segments
    SegError = zeros(nSegs,1);
    for i = 1:nSegs
        SegError(i) = GetSegError(trace(SegBounds(i,1):SegBounds(i,2),:));
    end
    
    TotalError = sum(SegError);
    
    %Array to hold error data; first column is # of segments at that step,
    %second column is error gained in the previous merge step, third column
    %is the total error at that step
    ErrorData = zeros(nSegsOG,3);
    
    %Make a vector that stores the cost of merging each segment with the
    %next active segment to its right (currently, all segments are active)
    MergeCosts = zeros(nSegs - 1, 1);
    for i = 1:nSegs - 1
        mergedSeg = trace(SegBounds(i,1):SegBounds(i+1,2),:);
        MergeCosts(i) = GetSegError(mergedSeg) - SegError(i) - SegError(i+1);
    end
    
    %Get smallest merge cost as well as the ID# of 1st segment to merge
    SegsToMerge = [0 0];
    [minCost, SegsToMerge(1)] = min(MergeCosts);
    %The ID# of the 2nd segment to merge; because all segments are
    %currently active, it is just the next segment to the right
    SegsToMerge(2) = SegsToMerge(1) + 1; 
    
    %This is the loop where merging happens; keep merging as long as it
    %will not push the total error above the maximum allowable error
    nMergers = 0;
    while nSegs > min(numSegsChosenRange) && nSegs > 1
        
        nMergers = nMergers + 1;
%         if mod(nMergers, 1024) == 0
%             disp(strcat('# of mergers:',{' '},num2str(nMergers),...
%                 ', # of Segs & Targe # of Segs:'));
%             disp([nSegs numSegsChosen]);
%         end

        %Decrease total # of segments by one
        nSegs = nSegs - 1;

        %Update total error:
        TotalError = TotalError + minCost;
        old_minCost = minCost;

        %Store error gained during this merger:
        ErrorData(nMergers,:) = [nSegs minCost TotalError];

        %De-activate the 2nd segment being merged:
        ActiveSegs(SegsToMerge(2)) = false;

        %Make the 1st segment being merged into the new merged segment
        %by changing its ending bound to that of the 2nd segment being
        %merged
        SegBounds(SegsToMerge(1),2) = SegBounds(SegsToMerge(2),2);

        %New error for the merged segment is the sum of the errors of
        %the two segments being merged PLUS the additional cost of the
        %merger
        SegError(SegsToMerge(1)) = SegError(SegsToMerge(1)) + ...
            SegError(SegsToMerge(2)) + minCost;

        %Since the 2nd segment is now deactivated, set its error to 0
        SegError(SegsToMerge(2)) = 0;
        
        %Since the 2nd segment is now deactivatived, it cannot be merged
        %again later and so we set its merge cost to Infinity
        MergeCosts(SegsToMerge(2)) = Inf;
        
        %Now we need to update the merge cost of the first active segment
        %to the left of the newly merged segment:
        updated = false;
        LeftSegID = SegsToMerge(1) - 1;
        %Step through segments to find the first active one to the left:
        while ~updated && LeftSegID > 0
            if ActiveSegs(LeftSegID)
                %Get result of merging first active segment to the left
                %with the newly merged segment, find cost of merger
                mergedSeg = trace(SegBounds(LeftSegID,1):SegBounds(SegsToMerge(1),2),:);
                MergeCosts(LeftSegID) = GetSegError(mergedSeg) - SegError(LeftSegID) - SegError(SegsToMerge(1));
                
                updated = true;
            else
                %Go to next segment to the left if current one was inactive
                LeftSegID = LeftSegID - 1;                
            end
        end
        
        %Similarly, now we need to update the merge cost of the newly
        %merged segment (the cost will be if it were to be merged with the
        %first active segment to its right)
        updated = false;
        RightSegID = SegsToMerge(1) + 1;
        while ~updated && RightSegID <= nSegsOG
            if ActiveSegs(RightSegID)

                mergedSeg = trace(SegBounds(SegsToMerge(1),1):SegBounds(RightSegID,2),:);
                MergeCosts(SegsToMerge(1)) = GetSegError(mergedSeg) - SegError(RightSegID) - SegError(SegsToMerge(1));
                
                updated = true;
            else
                %Go to next segment to the left if current one was inactive
                RightSegID = RightSegID + 1;                
            end
        end
        %If there was no active segment to the right, then this new segment
        %is unmergable so its merge cost should be infinity
        if ~updated
            MergeCosts(SegsToMerge(1)) = Inf;
        end
            
        %Get the new minimum merge cost and IDs of the 2 segments to merge next:
        [minCost, SegsToMerge(1)] = min(MergeCosts);
        
        %ID of 2nd segment to merge is next active segment to the right
        if nSegs > 1
            j = SegsToMerge(1) + 1;         
            found_active = false;
            while ~found_active
                if ActiveSegs(j)
                    found_active = true;
                else
                    j = j + 1;
                end
            end
            SegsToMerge(2) = j;
        end
        
        if nSegs <= max(numSegsChosenRange)
            output_counter = output_counter + 1;
            [curr_segs, curr_bounds] = GetSegments(ActiveSegs, SegBounds, trace, nSegs);
            trace_segments{output_counter,1} = curr_segs;
            trace_segments{output_counter,2} = curr_bounds;
            trace_segments{output_counter,3} = TotalError;
            trace_segments{output_counter,4} = old_minCost;
        end        

    end
    ErrorData = ErrorData(1:nMergers,:);
    
    if ToPlot
%         figure();
%         plot(ErrorGain(:,1),ErrorGain(:,2),'o');
%         xlabel('# of Segments');
%         ylabel('Error Gain');

        for_plotting = trace_segments{numToStore};
        nSegs = size(for_plotting,1);

        figure();
        hold on;
        plot(trace(:,1),trace(:,2),'.');
        for i = 1:nSegs
            line(for_plotting(i,1:2),for_plotting(i,3:4),'LineWidth',2,...
                'Color',[0 0 0]);
        end
        xlabel('Inter-Electrode Distance (nm)');
        ylabel('Log(Conductance/G_0)');
        hold off;
    end
    


end

function [trace_segments,trace_bounds] = GetSegments(ActiveSegs, SegBounds, trace, nSegs)

    %Now create each segment by specifying its starting and ending point:
    trace_segments = zeros(nSegs, 4);
    trace_bounds = zeros(nSegs,2);
    ActiveSegIndices = find(ActiveSegs);
    for i = 1:nSegs
        bounds = SegBounds(ActiveSegIndices(i),:);
        trace_bounds(i,:) = bounds;
        
        trace_segments(i,1) = trace(bounds(1),1);
        trace_segments(i,2) = trace(bounds(2),1);
        
        seg = trace(bounds(1):bounds(2),:);
        covariance = NathansCovariance(seg);
        
        if covariance(1,1) > 0
            slope = covariance(1,2)/covariance(1,1);
            intercept = mean(seg(:,2)) - slope*mean(seg(:,1));

            trace_segments(i,3) = trace_segments(i,1)*slope + intercept;
            trace_segments(i,4) = trace_segments(i,2)*slope + intercept;
        else
            %If the two x-endpoints are the same, just set the y-endpoints
            %to the first and last y-values (otherwise we would have a
            %problem because the slope would be infinite)
            trace_segments(i,3) = trace(bounds(1),2);
            trace_segments(i,4) = trace(bounds(2),2);
        end
    end

end
