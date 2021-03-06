%Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
%licensed under the Creative Commons Attribution-NonCommercial 4.0 
%International License. To view a copy of this license, visit 
%http://creativecommons.org/licenses/by-nc/4.0/.  
%
%Class of a "TimingSave" object to flexibly store the amount of time that
%different clustering steps take
classdef TimingSave < handle
    
    properties (Access=private)
        section_names
        section_times
        elapsed_times   
        ntimes
    end
    
    methods
       
        function obj = TimingSave()
            tic;
            obj.section_names = {};
            obj.section_times = 0;
            obj.elapsed_times = 0; 
            obj.ntimes = 1;
        end
        
        function Save(obj, name)
            t = toc;
            obj.elapsed_times = [obj.elapsed_times t];
            section_t = t - obj.elapsed_times(obj.ntimes);
            obj.section_times = [obj.section_times section_t];
            obj.section_names{obj.ntimes} = name;
            obj.ntimes = obj.ntimes + 1;    
        end
        
        function TimeTable = CreateTable(obj)
            
            CumulativeTime = transpose(obj.elapsed_times(2:obj.ntimes));
            TaskTime = transpose(obj.section_times(2:obj.ntimes));
            
            TimeTable = table(CumulativeTime, TaskTime, 'RowNames',...
                obj.section_names);           
            
        end

    end
    
end