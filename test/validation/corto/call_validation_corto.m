abram_install();

%% Choose scenario
flag_scenario = 1; % Scenario 1: start of trajectory, Scenario 2: mid of trajectory, , Scenario 3: end of trajectory
flag_albedo = true;
flag_displacement = true;
flag_normal = true;

%% Inputs
inputs_validation_corto();

%% Run Model
run_model();

%% Post-processing
if flag_displacement || flag_normal
    nodem_txt = '';
else
    nodem_txt = 'nodem_';
end
image_filepath_corto = ['data\starnav_reduced_lambertian_',nodem_txt,'0015ms_16bit\img\00000',num2str(flag_scenario),'.png'];

postpro_validation_corto();
%postpro_3d();