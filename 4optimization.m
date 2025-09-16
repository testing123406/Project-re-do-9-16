% Example of SimNIBS tDCS optimization with a distributed target in MATLAB
% Looping through 29 subjects on Windows

% List of subject IDs
subject_ids = { ...
    '102715', '103212', '103414', '106319', '110613', ...
    '114621', '115219', '118730', '121618', '123420', ...
    '204319', '204521', '211417', '212116', '213017', ...
    '239944', '274542', '341834', '352738', '385450', ...
    '461743', '481042', '500222', '519647', '592455', ...
    '635245', '677766', '723141', '886674'};

for i = 1:length(subject_ids)
    
    subj = subject_ids{i};
    fprintf('Running optimization for subject %s...\n', subj);
    
    % Initialize structure
    opt = opt_struct('TDCSDistributedOptimize');
    
    % Leadfield file (e.g. D:\MATLAB\leadfield_204521\204521_leadfield_EEG10-10_UI_Jurak_2007.hdf5)
    opt.leadfield_hdf = fullfile('D:\MATLAB\Meshes+Scripts', ['leadfield_' subj], ...
        [subj '_leadfield_EEG10-10_UI_Jurak_2007.hdf5']);
    
    % Subject path (e.g. D:\MATLAB\m2m_204521\)
    opt.subpath = fullfile('D:\MATLAB\Meshes+Scripts', ['m2m_' subj]);
    
    % Optimization output directory (e.g. D:\MATLAB\optimization_204521\distributed)
    opt.name = fullfile('D:\MATLAB\redoopt3', ['4optimization_' subj], 'distributed');
    
    % Current settings
    opt.max_total_current = 2e-3;
    opt.max_individual_current = 2e-3;
    opt.max_active_electrodes = 4;
    
    % Target image (in MNI space)
    opt.target_image = 'D:\MATLAB\cleanedoutput500.nii.gz';
    opt.mni_space = true;
    
    % Desired field strength
    opt.intensity = 0.6;
    
    % Run the optimization
    run_simnibs(opt);
end
