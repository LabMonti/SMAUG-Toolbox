function p = MCMC_inputparser(nTemps)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: parses any name-value pair inputs for the MCMC
    %   feature-finder, and assigns default values to any input parameters
    %   not specified through these name-value pair
    %
    %~~~INPUTS~~~:
    %
    %nTemps: the # of different temperatures used for parallel tempering
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %p: input parser containing the values assigned to each possible input
    %   for the MCMC feature-finder
    
    p = inputParser;
    
    %Total # of burn in steps to use. If multiple copies of the MCMC
    %super-chain are being run in paralle, this number of steps will be
    %split equally between them
    p.addParameter('BurnInSteps',600000,@isnumeric);
    
    %The convergence criteria used to determine if the MCMC super-chain has
    %suitably converged or not. The Rhat ratio for EVERY node will need to
    %be less than max_Rhat, and the weighted average Rhat ratio for each
    %temperature will need to be less than strict_Rhat, for us to consider
    %the chain converged. 
    valid_convergencecriteria = @(x) isstruct(x) && isfield(x,'max_Rhat') ...
        && isfield(x,'strict_Rhat');
    defaultcriteria = struct();
    defaultcriteria.max_Rhat = 1.1;
    defaultcriteria.strict_Rhat = 1.05;
    p.addParameter('ConvergenceCriteria',defaultcriteria,...
        valid_convergencecriteria);
    
    %The minimum number of steps used, for EACH copy, for the single
    %temperature T = inf MCMC chain used to determine sigma_infinity
    p.addParameter('MinSteps_SigInf',150000,@isnumeric);
    
    %The Rhat value for the single-temperature T = inf MCMC chain will need
    %to be less than this for us to consider that this simulation, used to
    %determine sigma_infinity, has converged
    p.addParameter('SigInf_Rhat',1.005,@isnumeric);
    
    %Whether or not to parallelize the MCMC calculations for speed. 
    p.addParameter('Parallelize',false,@islogical);
    
    %If parallelization is being used, how many workers to create in the
    %parallel pool; note that if a parallel pool already exists, that pool
    %will be re-used no matter how many workers it has; this input is only
    %relevant when a new pool must be created
    p.addParameter('nParallelWorkers',3,@isnumeric);
    
    %Lots of options about what plots to make or not
    valid_num = @(x) x <= nTemps && x >= 0;   
    p.addParameter('PlotWeightOverTime',true,@islogical);
    p.addParameter('PlotAcceptanceOverTime',true,@islogical);
    p.addParameter('PlotFinalAcceptances',true,@islogical);
    p.addParameter('Num2DPlotsToShow',nTemps,@isnumeric);
    p.addParameter('NumCondHistsToInclude',nTemps,valid_num);
    p.addParameter('NumDistHistsToInclude',0,valid_num);
    p.addParameter('PlotConvergenceResults',true,@islogical);
    p.addParameter('OverlayExampleSequence',false,@islogical);
    
    %If this is true, then if convergence is not initially reached, the
    %same number of MCMC steps will be collected again, then convergence
    %checked again with the combined outputs, and this will be repeated
    %until convergence is achieved or until the # of max repeats is met
    p.addParameter('RepeatUntilConvergence',true,@islogical);
    p.addParameter('MaxRepeats',3,@isnumeric);
    
    %The seed used for the random number generate. If set to 'UseTime', a
    %random seed will be created using the system time. 
    p.addParameter('RandomSeed','UseTime');

end