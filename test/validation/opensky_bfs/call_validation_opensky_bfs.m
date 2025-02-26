abram_install()
mice_install()

filename_metakernel = 'default.tm';

%% Choose scenario
flag_scenario = 2; % Scenario 1: 50mm
                   % Scenario 2: 25mm

% Flags
flag_account_for_atmosphere = true; % about 15% reduction of brightness
flag_use_spice = true; % retrieve camera orientation and location from epoch
flag_displacement = true;
flag_normal = true;
flag_hapke = true;
flag_ssim = true;
flag_apply_ncc = true;

% Arbitrary values
noise_level = 3;   

%% Inputs
inputs_validation_opensky_bfs();     

%% Run Model
run_model();

%% Post-processing
postpro_validation_opensky_bfs();
%postpro_3d();