%NDB 07May19: Create a name containing the key information for a given
%entry from the library
function name = create_name_for_library_entry(dataset_library, id)

    sample = dataset_library.sample_name(id);

    if strcmp(dataset_library.section_type{id},'Tunneling')
        
        solv = dataset_library.solvent_name(id);
        name = strcat(sample,' Tunn. Sect. (Pure', {' '}, solv,')');
        
    elseif strcmp(dataset_library.section_type{id},'Molecular')
        
        conc = strcat(num2str(dataset_library.molecule_concentration_uM{id}),...
            'uM');
        mol = dataset_library.molecule_name{id};
        
        dep = strcat('Dep',num2str(dataset_library.deposition_number{id}));
        trial = strcat('T',num2str(dataset_library.trial_number{id}));
        
        name = strcat(sample, {' '}, conc, {' '}, mol, {' '}, dep, trial);
        
    elseif strcmp(dataset_library.section_type{id},'Molecular_Subset')
        
        conc = strcat(num2str(dataset_library.molecule_concentration_uM{id}),...
            'uM');
        mol = dataset_library.molecule_name{id};
        
        dep = strcat('Dep',num2str(dataset_library.deposition_number{id}));
        trial = strcat('T',num2str(dataset_library.trial_number{id}));
        
        name = strcat(sample, {' '}, conc, {' '}, mol, {' '}, dep, trial, '_SubSet');              
    elseif contains(dataset_library.section_type{id}, 'Molecular_Reset')
        
        conc = strcat(num2str(dataset_library.molecule_concentration_uM{id}),...
            'uM');
        mol = dataset_library.molecule_name{id};
        
        dep = strcat('Dep',num2str(dataset_library.deposition_number{id}));
        trial = strcat('T',num2str(dataset_library.trial_number{id}));
        
        pcs = split(dataset_library.section_type{id},'_');
        
        name = strcat(sample, {' '}, conc, {' '}, mol, {' '}, dep, trial, ...
            '_', pcs{2});          
    else
        error('not ready yet');
    end
    name = name{1};

end