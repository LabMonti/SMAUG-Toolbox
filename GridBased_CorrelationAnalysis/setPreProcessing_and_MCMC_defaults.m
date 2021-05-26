function InputParams = setPreProcessing_and_MCMC_defaults(InputParams)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Given a structure array containing MCMC
    %parameters and pre-processing parameters, this function fills in any
    %parameters NOT included in the input with their default values. 
    %
    %~~~INPUTS~~~:
    %
    %InputParams: structure array potentially containing fields whose names
    %   correspond to MCMC or pre-processing parameters, and whose values
    %   correspond to the setting for those parameters. Can be completely
    %   empty to use all default values. 
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %InputParams: structure array in which all required MCMC and
    %   pre-processing parameters now have corresponding fields and values;
    %   any parameters not passed in as inputs have been set to their
    %   default values. 
    

    %Pre-processing parameters:
    
    %Grids per nm to use in x dimension
    if ~isfield(InputParams,'gridsX')
        InputParams.gridsX = 25;
    end
    
    %Grids per decade to use in y dimension
    if ~isfield(InputParams,'gridsY')
        InputParams.gridsY = 10;
    end
    
    %What distance, in nm, to chop all traces at so that they have a common
    %starting point
    if ~isfield(InputParams,'left_chop')
        InputParams.left_chop = -0.05;
    end   
    
    %Whether or not to remove all nodes that only one trace passes through
    if ~isfield(InputParams,'remove_lowtracenodes')
        InputParams.remove_lowtracenodes = false;
    end
    
    %Whether or not to remove all dangling nodes
    if ~isfield(InputParams,'remove_danglingnodes')
        InputParams.remove_danglingnodes = true;
    end
    
    %MCMC parameters:
    
    %Length node-sequences
    if ~isfield(InputParams,'sequence_length')
        InputParams.sequence_length = 12;
    end
    
    %# of MCMC steps to run
    if ~isfield(InputParams,'nSteps')
        InputParams.nSteps = 600000;
    end
    
    %# of Burn in steps to run
    if ~isfield(InputParams,'BurnInSteps')
        InputParams.BurnInSteps = 600000;
    end  
    
    %# of independent copies of MCMC super-chain to split of steps between
    if ~isfield(InputParams,'nCopies')
        InputParams.nCopies = 3;
    end
    
    %Maximum # of times to collect additional MCMC steps in an attempt to
    %reach convergence criteria
    if ~isfield(InputParams,'MaxRepeats')
        InputParams.MaxRepeats = 10;
    end
    
    %Temperatures, relative to sigma_infinity, to use for parallel
    %tempering
    if ~isfield(InputParams,'RelativeTemps')
        InputParams.RelativeTemps = [4/9 5/9 6/9 1 Inf];
    end
    
    %Type of criteria to impose on node sequences
    if ~isfield(InputParams,'criteriaType')
        InputParams.criteriaType = 'RangeSlope';
    end
    
    %Parameters associated with chosen criteria
    if ~isfield(InputParams,'CriteriaParams')
        InputParams.CriteriaParams = struct();
        InputParams.CriteriaParams.minSlope = -1;
        InputParams.CriteriaParams.maxSlope = 1;
    end
    
    %Criteria we need to meet for the MCMC to be considered converged
    if ~isfield(InputParams,'ConvergenceCriteria')
        InputParams.ConvergenceCriteria = struct();
        InputParams.ConvergenceCriteria.max_Rhat = 1.1;
        InputParams.ConvergenceCriteria.strict_Rhat = 1.05;
    end  
    
    %Number of cores to use; if >1, parallel pool will be set up
    if ~isfield(InputParams,'nCores')
        InputParams.nCores = 1;
    end
    
    %Whether to also save the so-called "bulky" MCMC info to a separate
    %.mat file
    if ~isfield(InputParams,'SaveBulkyInfo')
        InputParams.SaveBulkyInfo = false;
    end

end