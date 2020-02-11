function ClustOutput = EasySegmentClustering(TraceStruct, output_name, ...
    vary_minPts)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: the fastest and easiest way to run segment
    %clustering on a single dataset, either with a single set of clustering
    %parameters, or with 12 different values of the minPts parameter in
    %order to obtain error bars (as in Bamberger et al. 2020).  
    %
    %~~~INPUTS~~~:
    %
    %TraceStruct: a trace structure for the dataset to be clustered (or the
    %   name of a file containing that structure, or the ID# of the library
    %   entry for that structure)
    %
    %output_name: character string that will be associated with the saved
    %   output; if blank/empty, output will not be saved automatically
    %
    %vary_minPts: logical variable; if false, clustering is performed once
    %   with minPts = 85; if true, clustering is performed for 12 different
    %   values of minPts
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %   
    %ClustOutput: structure containing the output from clustering. If
    %   clustering was run at a single point, this is simply a standard
    %   "clustering output struture".  If clustering was run at 12 values
    %   of minPts, this is a structure containing two fields: OO_List, a
    %   cell array of clustering output structures for each clustering, and
    %   TracesUsed, the TracesUsed field for each output (only stored once
    %   to save space).  


    if nargin < 3
        vary_minPts = false;
    end
    if nargin < 2
        output_name = '';
    end
    onHPC = false;
    
    %Load in trace structure
    TraceStruct = LoadTraceStruct(TraceStruct);
    
    %Obtain standard clustering parameters
    [ClustParams, minPtsList] = generateClusteringInput_Bamberger2020(...
        output_name,onHPC);
    
    %Perform clustering
    ClustOutput = struct();
    if ~vary_minPts
        OutputStruct = runClustering(ClustParams,TraceStruct);
        ClustOutput = OutputStruct;
    else
        %Cluster at each value of minPts
        [OO_List,TracesUsed] = StartClustering_Range_minPoints(TraceStruct,...
            ClustParams,minPtsList);
        ClustOutput.OO_List = OO_List;
        ClustOutput.TracesUsed = TracesUsed;
    end
    
    %Save output to new folder, if requested
    if ~isempty(output_name)
        [output_location, ~] = SetUpOutputDirectory(output_name);
        SaveClusteringOutput(ClustOutput,output_location,output_name);
    end

end