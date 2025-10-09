% Subject IDs
subject_ids = { ...
    '102715', '103212', '103414', '106319', '110613', ...
    '114621', '115219', '118730', '121618', '123420', ...
    '204319', '204521', '211417', '212116', '213017', ...
    '239944', '274542', '341834', '352738', '385450', ...
    '461743', '481042', '500222', '519647', '592455', ...
    '635245', '677766', '723141', '886674'};

% Base path to simulation outputs
opt_base = 'D:\MATLAB\redoopt3';

% ROI mask
network_file = "D:\MATLAB\cleanedoutput500_resampled.nii.gz";
network_image = nifti_load(char(network_file));
network_roi = network_image.vol > 0;
outside_roi = ~network_roi;

% Initialize results table
results = table('Size', [0 3], ...
    'VariableTypes', {'double','double','double'}, ...
    'VariableNames', {'SubjectID','MeanEF_VperM','MeanEF_Outside_VperM'});

for i = 1:length(subject_ids)
    subj = subject_ids{i};
    fprintf('\nSubject %s:\n', subj);

    % Path to EF file inside simulation_output/mni_volumes
    ef_file = fullfile(opt_base, ['4optimization_' subj], ...
        'simulation_output', 'mni_volumes', ...
        [subj '_TDCS_1_scalar_MNI_magnE.nii.gz']);

    if ~isfile(ef_file)
        fprintf('    File not found: %s\n', ef_file);
        continue;
    end

    try
        fprintf('    Loading file: %s\n', ef_file);
        EF_image = nifti_load(char(ef_file));
    catch ME
        warning('Failed to load file %s. Error:\n    %s', ef_file, ME.message);
        continue;
    end

    EF_intensity = EF_image.vol;

    % Dimension check
    if ~isequal(size(EF_intensity), size(network_roi))
        warning('    Dimension mismatch for subject %s. Skipping.', subj);
        continue;
    end

    % Inside ROI
    EF_in_network = EF_intensity(network_roi);
    mean_EF_network = mean(EF_in_network(:));

    % Outside ROI
    EF_outside_network = EF_intensity(outside_roi);
    mean_EF_outside = mean(EF_outside_network(:));

    fprintf('    Mean EF in network ROI: %.6f V/m\n', mean_EF_network);
    fprintf('    Mean EF outside network: %.6f V/m\n', mean_EF_outside);

    % Append to results
    newRow = {str2double(subj), mean_EF_network, mean_EF_outside};
    results = [results; newRow];
end

% Save results directly inside redoopt3 folder
output_file = fullfile('D:\MATLAB\redoopt3', '4simulation_analysis.xlsx');
try
    writetable(results, output_file);
    fprintf('\n✔ EF data saved to Excel: %s\n', output_file);
catch ME
    warning('Failed to save Excel file. Error:\n%s', ME.message);
end
