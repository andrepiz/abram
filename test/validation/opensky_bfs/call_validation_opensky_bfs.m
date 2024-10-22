abram_install()

%% Choose camera
flag_camera = 1; % Camera 1: 50 mm, Camera 2: 25 mm

%% Atmosphere reduction
flag_account_for_atmosphere = true;

%% Inputs
inputs_validation_opensky_bfs();     

%% Run Model
run_model();

%% Post-processing
if flag_camera == 1
    image_filepath_real = fullfile('data','50mm.png');
elseif flag_camera == 2
    image_filepath_real = fullfile('data','25mm.png');
end
postpro_validation_opensky_bfs();
postpro_3d();