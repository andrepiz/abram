abram_install();

flag_displacement = true; % Use displacement map in ABRAM rendering
flag_normal = true;       % Use normal map in ABRAM rendering
flag_occlusions = true;   % Use occlusions
flag_horizon = true;      % Use horizon map
flag_hapke = true;        % Use hapke model
flag_plot = true;
flag_correct_camera_spice = 0;  % 0 - keep data as given
                                % 1 - correct focal length using res_px, muPixel and fov
                                % 2 - correct pixel pitch using res_px, f and fov
flag_use_state_metadata = 0;    % 0 - use SPICE state
                                % 1 - use metadata state

%% AMIE EXTRACTOR
init(); % Note: change path to yours in init.m

path_mfbias = 'mf\mfbias.mat';
path_mfdc = 'mf\mfdc.mat';

filename_img = 'AMI_EE3_040819_00208_00030.IMG'; noise_level = 57; % Working 
% filename_img = 'AMI_EE3_041111_00070_00018.IMG'; noise_level = 72; % Working
% filename_img = 'AMI_EE3_040819_00169_00010.IMG'; noise_level = 41; % Working
%filename_img = 'AMI_EE3_041028_00269_00005.IMG'; noise_level = 116; % Working
%filename_img = 'AMI_EE3_041111_00008_00040.IMG';
%filename_img = 'AMI_EE3_040504_00038_00020.IMG';
filepath_img = fullfile(path_img, filename_img); 

% Load master frames 
mfbias = load(path_mfbias).mfbias;
mfdc = load(path_mfdc).mfdc;

% Load SPICE Kernels
path_current = pwd;
cd(fileparts(filepath_metakernel))
cspice_furnsh(filepath_metakernel);
cd(path_current)

% Extract data
[params, bimg_real, img_real, img_real_corrected, EC_real, EC_real_corrected] = extract_and_correct_IMG(filepath_img, mfbias, mfdc, flag_plot, flag_correct_camera_spice, flag_use_state_metadata);

% Clear SPICE kernel pool
cspice_kclear;

%% ABRAM
inputs_validation_amie();
run_model();

%% POSTPRO
postpro_validation_amie();