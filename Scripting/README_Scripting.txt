Single Molecule Analysis Unified Graphical (SMAUG) Toolbox

Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 Iternational License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/4.0/.  

Most of the scripts & functions in this folder were used to perform specific clustering tasks for the results presented in Bamberger et al. 2020 (for example, minSize_Test.m performed the robustness test of the minSize parameter discussed in Appendix B.2 and Analyze_MinSizeTest.m was used to analyze those outputs).  They are included here for documentation purposes, and so that curious readers can understand every detail of how these tests were performed.  However, because they refer to specific LabMonti datasets not included in the public version of the SMAUG toolbox, they cannot be run as-is for other users.  

This folder also includes a couple of example scripts demonstrating how to conveniently run the MCMC feature-finder described in Bamberger et al. 2021 on a computational cluster (either on a single dataset, or on a batch of datasets).