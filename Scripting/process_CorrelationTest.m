save_folder = 'C:\Users\LabMonti\Desktop\Nathan Temperory Outputs\minpts_LengthperDup_Correlation';

ClustOut = importdata(fullfile(save_folder,'113-2 1uM OPV3-BT Dep2T1_ClustOut.mat'));

TracesUsed = ClustOut.TracesUsed;
minPtsList = ClustOut.minPtsList;
LenPerDupList = ClustOut.LenPerDupList;
OO_List = ClustOut.OO_List;

NminPts = length(minPtsList);
Nlenperdup = length(LenPerDupList);

cutoff_frac = 0.01;
minPts_ID_toPlot = 4;
LenPerDup_ID_toPlot = 5;

OOref = OO_List{minPts_ID_toPlot, LenPerDup_ID_toPlot};
soln_num = 4;
clust_num = 2;

%Create single 1D list
NewList = cell(NminPts*Nlenperdup,1);
counter = 0;
for i = 1:NminPts
    NewList(counter+1:counter+Nlenperdup) = OO_List(i,:);
    counter = counter + Nlenperdup;
end

%Get best-matching cluster solutions
epsilons = MatchSpecificClusterValley(NewList,35,soln_num,clust_num,cutoff_frac);

%Create a matrix of the epsilon values
EPS = zeros(NminPts, Nlenperdup);
counter = 0;
for i = 1:NminPts
    for j = 1:Nlenperdup
        counter = counter + 1;
        EPS(i,j) = epsilons(counter);        
    end
end

%Find the centroid of the reference cluster
[~,peaks] = FindReachabilityPeaks(OOref.RD,cutoff_frac);
peaks = unique(peaks);
RefCentroid = FindCluster_Centroids(OOref,peaks(soln_num),cutoff_frac);
RefCentroid = RefCentroid(clust_num,:);

CondPeaks = zeros(NminPts, Nlenperdup);
CondErrors = zeros(NminPts, Nlenperdup);
CondHalfWidths = zeros(NminPts, Nlenperdup);

for i = 1:NminPts
    disp([i NminPts]);
    for j = 1:Nlenperdup
        
        %Find centroids of all clusters in the closest matching clustering
        %solution
        centroids = FindCluster_Centroids(OO_List{i,j},EPS(i,j), cutoff_frac);
        
        %Find the particular cluster whose centroid is closest to that of
        %the reference cluster
        dists = pdist2(RefCentroid, centroids);
        [~,minIndex] = min(dists);
        
        OO = OO_List{i,j};
        OO.TracesUsed = TracesUsed;
        [CondPeaks(i,j),CondErrors(i,j),CondHalfWidths(i,j)] = SegmentCluster_to_1DHist(...
            OO,EPS(i,j),cutoff_frac,minIndex,false);
        
    end
end




%Calculate RAND similarity index for best-matching cluster solution in each
%output
RandSims = zeros(NminPts,Nlenperdup);

%We need to find the set of segments that is used in all outputs (outputs
%with larger LenPerDup values include fewer segments since it is also a
%minimum segment length).  
[~, OOid] = max(LenPerDupList);
included_segs = (OO_List{1,OOid}.Nduplicates > 0);

%Re-assign cluster numbers and put Y in the same order as the original
%points
[Yref,Tref] = ExtractClusterSolution(OOref.RD,OOref.CD,EPS(...
    minPts_ID_toPlot,LenPerDup_ID_toPlot),cutoff_frac);
Yref = reassign_cluster_labels(Yref,Tref);
[~,neworder] = sort(OOref.order);
Yref = Yref(neworder);

Ynew = zeros(length(Yref),1);
counter = 0;
for i = 1:length(Yref)
    if OOref.original_vs_duplicate(i) && included_segs(OOref.duplicateIDs(i))
        counter = counter + 1;
        Ynew(counter) = Yref(i);
    end
end
Ynew = Ynew(1:counter);
disp(length(Ynew));

for i = 1:NminPts
    disp([i NminPts]);
    for j = 1:Nlenperdup
        OO = OO_List{i,j};
        [Y,T] = ExtractClusterSolution(OO.RD,OO.CD,EPS(i,j),cutoff_frac);
        Y = reassign_cluster_labels(Y,T);       
        [~,neworder] = sort(OO.order);
        Y = Y(neworder);

        Yn = zeros(length(Y),1);
        counter = 0;
        for k = 1:length(Y)
            if OO.original_vs_duplicate(k) && included_segs(OO.duplicateIDs(k))
                counter = counter + 1;
                Yn(counter) = Y(k);
            end
        end
        Yn = Yn(1:counter);
        disp(length(Yn));        
        
        RandSims(i,j) = RandSimilarityIndex(Yn,Ynew);
    end
end
