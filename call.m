%% INSTALL
abram_install();

%% INPUTS
%filename_yml = 'example.yml';
filename_yml = 'example_parallelized.yml'; % fast version with parallellization

%% OOP CALL
% Use this syntax to call the rendering functions using the
% object-oriented architecture

rend = abram.render(filename_yml);
rend.rendering();

% %% SCRIPTS CALL
% % Use this syntax to call the rendering scripts and make available the
% % entire workspace
% 
% inputs_yml();
% run_model();
% 
% % Post-processing scripts
% postpro();
% %postpro_3d();