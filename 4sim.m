% Add SimNIBS MATLAB tools to path
addpath('C:\Users\bostow26\SimNIBS-4.1\simnibs_env\Lib\site-packages\simnibs\matlab_tools');
savepath;

% Subject IDs
subject_ids = { ...
    '102715', '103212', '103414', '106319', '110613', ...
    '114621', '115219', '118730', '121618', '123420', ...
    '204319', '204521', '211417', '212116', '213017', ...
    '239944', '274542', '341834', '352738', '385450', ...
    '461743', '481042', '500222', '519647', '592455', ...
    '635245', '677766', '723141', '886674'};

% Base path to optimization folders
opt_base = 'D:\MATLAB\redoopt3';

% Base path to meshes
mesh_base = 'D:\MATLAB\Meshes+Scripts';

for i = 1:length(subject_ids)
    subj = subject_ids{i};
    fprintf('\nRunning simulation for subject %s...\n', subj);
    
    % Path to this subject's CSV (directly inside optimization_<subj> folder)
    csv_path = fullfile(opt_base, ['optimization_' subj], 'distributed.csv');
    
    if ~isfile(csv_path)
        warning('CSV not found for subject %s: %s', subj, csv_path);
        continue;
    end
    
    % Read CSV: first col = center coords, second col = current (A)
    T = readtable(csv_path, 'ReadVariableNames', false);
    electrodes_raw = table2cell(T(:,1));  % numeric [x y z]
    currents_raw = table2array(T(:,2));
    
    % Filter to non-zero current electrodes
    nonzero_idx = find(currents_raw ~= 0);
    electrodes = electrodes_raw(nonzero_idx);
    currents = currents_raw(nonzero_idx);
    
    % Ensure current balance
    if abs(sum(currents)) > 1e-6
        error('Sum of currents not zero for subject %s (sum = %.6f)', subj, sum(currents));
    end
    
    % Output path next to CSV
    output_dir = fullfile(opt_base, ['optimization_' subj], 'simulation_output');
    mkdir(output_dir);  % create folder if needed
    
    % Build SimNIBS session
    S = sim_struct('SESSION');
    S.map_to_fsavg = true;
    S.map_to_MNI = true;
    S.fields = 'eEjJ';
    
    % Correct path to the subject's mesh
    S.subpath = fullfile(mesh_base, ['m2m_' subj]);
    
    % Output folder
    S.pathfem = output_dir;

    % Define TDCS montage
    tdcs = sim_struct('TDCSLIST');
    tdcs.currents = currents';
    
    nElectrodes = length(electrodes);
    tdcs.electrode = repmat(struct(), 1, nElectrodes);
    
    for e = 1:nElectrodes
        tdcs.electrode(e).channelnr = e;
        tdcs.electrode(e).centre = electrodes{e};  % numeric [x y z]
        tdcs.electrode(e).shape = 'ellipse';
        tdcs.electrode(e).dimensions = [12, 12];
        tdcs.electrode(e).thickness = 2;
    end
    
    % Assign montage to session
    S.poslist{1} = tdcs;
    
    % Run SimNIBS simulation
    run_simnibs(S);
end
