%% INSTALL
abram_install();

%% INPUTS

% USE YML
filename_yml = 'example.yml';
%filename_yml = 'moon_front.yml'; % moon in front covering most of fov
%filename_yml = 'moon_limb.yml'; % limb of the moon at close distance
inputs_yml();

% % USE MATLAB
% inputs();

%% MODEL
run_model();

%% POSTPRO
postpro();
postpro_3d();