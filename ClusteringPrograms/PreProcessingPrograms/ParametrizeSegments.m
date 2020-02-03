%11May18 NDB: Given a bunch of traces and the segments they have been split
%into, describe each segment with a handful of parameters (center_x,
%center_y, slope, length, and R^2, at least currently)
function [SegmentParameters, NormInfo] = ParametrizeSegments(AllSegments,AllBounds,...
    TraceIDs,TracesUsed,Normalize,w)
    %~~~INPUTS~~~:
    %
    %AllSegments: an array holding the x- and y- endpoint values for all
    %   segments
    %
    %AllBounds: an array listing the starting and ending trace-point 
    %   indices for all segments
    %
    %TraceIDs: a vector with one element per segment, with that element
    %   listing the ID# of the trace to which the segment belongs
    %
    %TracesUsed: a structure containing the traces that were used during 
    %   trace segmentation
    %
    %Normalize: logical variable, whether or not to normalize the values of
    %   each parameter across all traces to put the different parameters on
    %   an equivalent scale as each other
    %
    %w: weighting factor for the conductance dimension
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %SegmentParameters: an array with one column per parameter and one row
    %   per segment, containing all of the segment parameters
    %
    %NormInfo: a 3x2 array containing the midpoints and denominators used
    %   to normalize the x- and y-data in the first two rows and the
    %   Log(length) data in the third row
    
    
    if nargin < 6
        w = 1;
    end
    if nargin < 5
        Normalize = true;
    end

    %Note: Each row of AllSegments is x1, x2, y1, y2;
    NSegments = size(AllSegments,1);
    
    %center_x, center_y, length, slope, r^2
    SegmentParameters = zeros(NSegments, 5);

    for i = 1:NSegments
        
        %Center x and center y
        SegmentParameters(i,1) = (AllSegments(i,1) + AllSegments(i,2))/2;
        SegmentParameters(i,2) = (AllSegments(i,3) + AllSegments(i,4))/2;

        %Length
        SegmentParameters(i,3) = (AllSegments(i,2) - AllSegments(i,1));      
        
        %Slope will be calculated afterwards, because endpoints need to be
        %normzalized using ranges of centers first
        
        %Find R^2:
        trace_ID = TraceIDs(i);
        %%%trace = TracesUsed.(strcat('Trace',num2str(trace_ID)));
        trace = TracesUsed{trace_ID};
        segment = trace(AllBounds(i,1):AllBounds(i,2),:);
        c = NathansCovariance(segment);
        if c(1,1) == 0 || c(2,2) == 0
            %In this case r^2 must be 1:
            SegmentParameters(i,5) = 1;
        else
            SegmentParameters(i,5) = c(1,2)^2/(c(1,1)*c(2,2));
            %disp(SegmentParameters(i,5));
        end
        
%         %Get root mean square error instead of R^2
%         if c(1,1) == 0 || c(2,2) == 0
%             %In this case SSE must be zero
%             SSE = 0;
%         else
%             SSE = c(2,2)*(1 - c(1,2)^2/(c(1,1)*c(2,2)));
%         end  
%         %Account for rounding errors (SSE cannot be negative)
%         if SSE < 0
%             SSE = 0;
%         end
%         n = size(segment,1);
%         SegmentParameters(i,5) = sqrt(SSE/n);
        
    end
    
    %Log base 2 of lengths:
    SegmentParameters(:,3) = log2(SegmentParameters(:,3));
    
    %Find normalization parameters for x- and y-dimensions from the
    %distributions of segment centers (using 90th percentile minus 10th
    %instead of standard deviation to exclude outliers)
    mid_x = median(SegmentParameters(:,1));
    mid_y = median(SegmentParameters(:,2));
    denom_x = prctile(SegmentParameters(:,1),90) - prctile(SegmentParameters(:,1),10);
    denom_y = prctile(SegmentParameters(:,2),90) - prctile(SegmentParameters(:,2),10);
    NormInfo = [mid_x, denom_x; mid_y, denom_y; 0, 1];
    
    %Go through and calculate slope angle for each segment, normalizing end
    %points first:
    for i = 1:NSegments
        %Normalize endpoints using parameters derived from distributions of
        %segment centers in x and y:
        endpoints_norm = AllSegments(i,:);
        endpoints_norm(1:2) = (endpoints_norm(1:2) - mid_x) / denom_x;
        endpoints_norm(3:4) = (endpoints_norm(3:4) - mid_y) / denom_y;
        
        %Find slope:
        slope = (endpoints_norm(4) - endpoints_norm(3))/...
            (endpoints_norm(2) - endpoints_norm(1));
        
        %Find slope angle:
        SegmentParameters(i,4) = atan(slope)*180/pi;        
    end
    
    if Normalize
        
        %Normalize center_x and center_y using 90th percentile minus 10th:
        SegmentParameters(:,1) = (SegmentParameters(:,1) - mid_x)./denom_x;
        SegmentParameters(:,2) = (SegmentParameters(:,2) - mid_y)./denom_y;
        
        %Normalize log2(Length) using 90th percentile minus 10th:
        mid = median(SegmentParameters(:,3));
        denom = prctile(SegmentParameters(:,3),90) - prctile(SegmentParameters(:,3),10);
        SegmentParameters(:,3) = (SegmentParameters(:,3) - mid)./denom; 
        NormInfo(3,:) = [mid, denom];
    
        %Normalize the R^2 dimension differently: since R^2 is restricted to
        %the range 0 to 1 and we used the 10th to 90th percentile range above,
        %simply divide R^2 by 0.8
        SegmentParameters(:,5) = SegmentParameters(:,5)./0.8;

        %Normalize slope angle dimension differently; since possible range is
        %-90 to +90 and we used the 10th to 90th percentile range above, 
        %just divide by 0.8*180
        SegmentParameters(:,4) = SegmentParameters(:,4)./(0.8*180);
    end
    
    %Weigth the conductance axis:
    SegmentParameters(:,2) = w * SegmentParameters(:,2);    

end
