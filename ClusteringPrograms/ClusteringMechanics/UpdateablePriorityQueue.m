%This version (05Jun17) validated as working correctly

%Updated in July2017 to fix rare bug that occurs when an object tries to
%sink beyond the end of the array

classdef UpdateablePriorityQueue < handle
    
    properties (Access=private)
        point_index
        queue_data   
    end
    
    %Make last element public to easily see size of seeds list
    properties (SetAccess = private, GetAccess = public)
      last_element
    end   
    
    
    methods
        
        function obj = UpdateablePriorityQueue(npoints)
            
            obj.point_index = zeros(npoints, 1);
            obj.queue_data = Inf(npoints,2);
            obj.last_element = 0;            
            
        end
        
        function push(obj, priority, value)
            
            %Update length of heap, get index for bottom of heap
            new_index = obj.last_element + 1;
            obj.last_element = new_index;
            
            %Add new data point to bottom of heap (and add its index as
            %well)
            obj.queue_data(new_index, 1) = priority;
            obj.queue_data(new_index, 2) = value;
            obj.point_index(value) = new_index;
            
            %The Dark Knight Rises
            obj.Rise(new_index)
        
        end
        
        function [priority, value] = pop(obj)
            
            %Output root of heap
            priority = obj.queue_data(1,1);
            value = obj.queue_data(1,2);
            
            %Replace root with last element
            last_index = obj.last_element;
            obj.SwapNodes(1, last_index);

            %Clear out removed value
            obj.queue_data(last_index, :) = [Inf, Inf];
            obj.point_index(value) = 0;            
            obj.last_element = last_index - 1;
            
            %Sink to the bottom of the Sea
            obj.Sink(1);
            
        end
        
        function update(obj, new_priority, value)
            
            %Find where data point is in heap
            data_index = obj.point_index(value);
            
            %Get current priority
            current_priority = obj.queue_data(data_index, 1);
            
            %If the priority has decreased, update and rise!
            if new_priority < current_priority
                obj.queue_data(data_index, 1) = new_priority;
                obj.Rise(data_index);
            end
            
        end
        
        function AddOrUpdate(obj, priority, value)
            
            if obj.point_index(value) == 0
                obj.push(priority,value);
            else
                obj.update(priority,value);
            end
            
        end
        
    end
    
    methods (Access=private)
        
        function Rise(obj, index)
            
            %Don't even both if object is already the root!
            if index > 1
                p_index = floor(index*0.5);
                parent = obj.queue_data(p_index,1);
                current = obj.queue_data(index, 1);
                if parent > current
                    obj.SwapNodes(index,p_index);
                    obj.Rise(p_index);
                end
            end
            
        end
        
        function Sink(obj, index)
            
            lc_index = 2*index;
            rc_index = 2*index + 1;
            
            %Don't try to sink if it's in a bottom level!!! Easy way to
            %check is to compare to last element.  Sinking only happens
            %when a point was removed, so can never sink below number of
            %elements
            if rc_index <= obj.last_element
                lc = obj.queue_data(lc_index, 1);
                rc = obj.queue_data(rc_index, 1);
                current = obj.queue_data(index, 1);
                if lc < current || rc < current
                    if lc < rc
                        obj.SwapNodes(index,lc_index);
                        obj.Sink(lc_index);
                    else
                        obj.SwapNodes(index,rc_index);
                        obj.Sink(rc_index);                    
                    end
                end
            end

        end
        
        function SwapNodes(obj, node_idx1, node_idx2)
             
            %Get each element
            el1 = obj.queue_data(node_idx1,:);
            el2 = obj.queue_data(node_idx2,:);
            
            %Get pointIDs
            p1 = el1(2);
            p2 = el2(2);
            
            %Swap elements
            obj.queue_data(node_idx1,:) = el2;
            obj.queue_data(node_idx2,:) = el1;

            %Swap point indexes
            obj.point_index(p1) = node_idx2;
            obj.point_index(p2) = node_idx1;
            
        end

    end
    
end
