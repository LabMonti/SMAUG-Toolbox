function name = create_name_for_library_entry(dataset_library, id)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: creates a name containing key information for a
    %given entry from the dataset library
    %
    %~~~INPUTS~~~:
    %
    %dataset_library: a structure containing a dataset "library" created by
    %   build_library.m
    %
    %id: the ID# for the library entry that we wish to construct a name for
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %name: a string containing an identifying name for the specified
    %   dataset from the library

    sample = dataset_library.sample_name(id);

    if strcmp(dataset_library.section_type{id},'Tunneling')
        
        solv = dataset_library.solvent_name(id);
        name = strcat(sample,'_TunnSect_(Pure', solv,')_T',...
            num2str(dataset_library.trial_number{id}));
        
    elseif strcmp(dataset_library.section_type{id},'Molecular')
        
        conc = strcat(num2str(dataset_library.molecule_concentration_uM{id}),...
            'uM');
        mol = dataset_library.molecule_name{id};
        
        dep = strcat('Dep',num2str(dataset_library.deposition_number{id}));
        trial = strcat('T',num2str(dataset_library.trial_number{id}));
        
        name = strcat(sample, '_', conc, '_', mol, '_', dep, trial);
        
    elseif strcmp(dataset_library.section_type{id},'Molecular_Subset')
        
        conc = strcat(num2str(dataset_library.molecule_concentration_uM{id}),...
            'uM');
        mol = dataset_library.molecule_name{id};
        
        dep = strcat('Dep',num2str(dataset_library.deposition_number{id}));
        trial = strcat('T',num2str(dataset_library.trial_number{id}));
        
        name = strcat(sample, '_', conc, '_', mol, '_', dep, trial, '_SubSet');              
    elseif contains(dataset_library.section_type{id}, 'Molecular_Reset')
        
        conc = strcat(num2str(dataset_library.molecule_concentration_uM{id}),...
            'uM');
        mol = dataset_library.molecule_name{id};
        
        dep = strcat('Dep',num2str(dataset_library.deposition_number{id}));
        trial = strcat('T',num2str(dataset_library.trial_number{id}));
        
        pcs = split(dataset_library.section_type{id},'_');
        
        name = strcat(sample, '_', conc, '_', mol, '_', dep, trial, ...
            '_', pcs{2});   
        
    elseif contains(dataset_library.section_type{id},'Tunneling_Reset')
        
        pcs = split(dataset_library.section_type{id},'_');
        solv = dataset_library.solvent_name(id);
        name = strcat(sample,'_TunnSect_(Pure', '_', solv,')_T', ...
            num2str(dataset_library.trial_number{id}),'_',pcs{2});
        
    else
        error('not ready yet');
    end
    name = name{1};

end