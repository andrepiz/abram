%% INSTALL
abram_install();

%% INPUTS

% USE YML
filename_yml = 'example.yml';
%filename_yml = 'example_parallelized.yml'; 
inputs_yml();

% % USE MATLAB
% inputs();

%% MODEL
run_model();

%% POSTPRO
postpro();
% postpro_3d();