% Define subject IDs to iterate over
subject_ids = [102715,103212,103414,106319,110613,114621,115219,118730,121618,123420,...
               204319,204521,211417,212116,213017,239944,274542,341834,352738,385450,...
               461743,481042,500222,519647,592455,635245,677766,723141,886674];

% Set your ROI mask path here
network_file = "D:\MATLAB\cleanedoutput500_resampled.nii.gz";

% Load the network-based ROI NIfTI file
network_image = nifti_load(char(network_file));  % Ensure it's a char for fopen
network_roi = network_image.vol > 0;             % Inside-network mask
outside_roi = ~network_roi;                      % Outside-network mask

% Initialize empty table for results (4 columns now)
results = table('Size', [0 4], ...
                'VariableTypes', {'double','double','double','double'}, ...
                'VariableNames', {'SubjectID','Montage','MeanEF_VperM','MeanEF_Outside_VperM'});

% Outer loop through subjects
for subj = 1:length(subject_ids)
    subject_id = subject_ids(subj);
    fprintf('\nSubject %d:\n', subject_id);

    % Inner loop through montages
    for montage_num = 8:9
        fprintf('  Processing montage %d...\n', montage_num);

        % Construct EF file path
        subject_file = fullfile("D:\MATLAB\scripts", ...
                                string(subject_id), ...
                                "montage" + string(montage_num), ...
                                "mni_volumes", ...
                                string(subject_id) + "_TDCS_1_scalar_MNI_magnE.nii.gz");

        % Check if file exists
        if ~isfile(subject_file)
            fprintf('    File not found: %s\n', subject_file);
            continue;
        end

        % Try to load EF NIfTI file
        try
            fprintf('    Loading file: %s\n', subject_file);
            EF_image = nifti_load(char(subject_file));  % Convert to char for fopen
        catch ME
            warning('    Failed to load file %s. Error:\n    %s', subject_file, ME.message);
            continue;
        end

        % Convert from mV/m to V/m
        EF_intensity = EF_image.vol / 1000;

        % Check dimension match
        if ~isequal(size(EF_intensity), size(network_roi))
            warning('    Dimension mismatch for subject %d, montage %d. Skipping.', subject_id, montage_num);
            continue;
        end

        % Inside network
        EF_in_network = EF_intensity(network_roi);
        mean_EF_network = mean(EF_in_network(:));

        % Outside network
        EF_outside_network = EF_intensity(outside_roi);
        mean_EF_outside = mean(EF_outside_network(:));

        fprintf('    Mean EF in network ROI: %.6f V/m\n', mean_EF_network);
        fprintf('    Mean EF outside network: %.6f V/m\n', mean_EF_outside);

        % Append result to table
        newRow = {subject_id, montage_num, mean_EF_network, mean_EF_outside};
        results = [results; newRow];
    end
end

% Save results to Excel with a distinct name
output_file = 'D:\MATLAB\Meshes+Scripts\scripts\EF_Results_inside_outside89.xlsx';
try
    writetable(results, output_file);
    fprintf('\n✔ EF data saved to Excel: %s\n', output_file);
catch ME
    warning('Failed to save Excel file. Error:\n%s', ME.message);
end
