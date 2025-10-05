% Add SimNIBS to the MATLAB path
addpath('C:\Users\bostow26\SimNIBS-4.1\simnibs_env\Lib\site-packages\simnibs\matlab_tools');

% Optional: Save the path for future sessions
savepath;

% Set the subjects
subjects = {'461743','481042','500222','519647','592455','635245','677766','723141','886674'};

% Define the montages (electrode setups)
montages = [ 
    struct('electrode1', struct('centre', [-59.45, 49.58, 34.91], 'dimensions', [50, 70],'shape','rect','thickness',[4,1,4]), ...
           'electrode2', struct('centre', 'Fp2', 'dimensions', [100, 100],'shape','rect','thickness',[4,1,4]), ...
           'currents', [1, -1]),  

    struct('electrode1', struct('centre', [-55.90, 75.02, 33.94], 'dimensions', [50, 70],'shape','rect','thickness',[4,1,4]), ...
           'electrode2', struct('centre', 'Fp2', 'dimensions', [100, 100],'shape','rect','thickness',[4,1,4]), ...
           'currents', [1, -1]),  
];


S = sim_struct('SESSION');
S.map_to_fsavg = true;
S.map_to_MNI = true;
S.fields = 'eEjJ';

% Set up the TDCSLIST with the simulation setup
S.poslist{1} = sim_struct('TDCSLIST');

% Create main results folder
if ~exist('scripts', 'dir')
    mkdir('scripts');
end

% Run the simulation for each subject
for i = 1:length(subjects)
    sub = subjects{i};
  S.subpath = fullfile('D:\MATLAB\Meshes+Scripts', ['m2m_' sub]);


    % Iterate over different montages
    for j = 1:length(montages)
        % Define the output directory
        output_dir = fullfile('scripts', sub, sprintf('montage%d', j+7));

        % Ensure the directory exists before running SimNIBS
        if ~exist(output_dir, 'dir')
            mkdir(output_dir);
        end

        % Set the output directory for the montage
        S.pathfem = output_dir; 

        % Set up electrodes for the current montage
        S.poslist{1}.currents = montages(j).currents;
        
        % Ensure electrode struct arrays exist
        S.poslist{1}.electrode = repmat(struct(), 1, 2);

        % Electrode 1 setup
        S.poslist{1}.electrode(1).channelnr = 1;
        S.poslist{1}.electrode(1).centre = montages(j).electrode1.centre;
        S.poslist{1}.electrode(1).shape = 'rect';
        S.poslist{1}.electrode(1).dimensions = montages(j).electrode1.dimensions;
        S.poslist{1}.electrode(1).thickness = 4;

        % Electrode 2 setup
        S.poslist{1}.electrode(2).channelnr = 2;
        S.poslist{1}.electrode(2).centre = montages(j).electrode2.centre;
        S.poslist{1}.electrode(2).shape = 'rect';
        S.poslist{1}.electrode(2).dimensions = montages(j).electrode2.dimensions;
        S.poslist{1}.electrode(2).thickness = 4;

        % Run the simulation for the current subject and montage
        run_simnibs(S);
    end
end
