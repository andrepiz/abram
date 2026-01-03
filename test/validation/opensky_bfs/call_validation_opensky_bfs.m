abram_install()
mice_install()

filename_metakernel = 'default.tm';

%% Choose scenario
flag_scenario = 1; % Scenario 1: 50mm
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

%% ABRAM rendering
rend = abram.render('validation_opensky_bfs.yml', false);
inputs_validation_opensky_bfs();
rend = rend.rendering();
img = rend.img;

%% Post-processing
postpro_validation_opensky_bfs();