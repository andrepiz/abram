%% INSTALL
abram_install();

%% INPUTS
filename_yml = 'example_moon.yml';

%% CALL
rend = abram.render(filename_yml);

%% POST-PROCESSING (OPTIONAL)

postpro() % image visualization
%postpro_depth() % image depth visualization
%postpro_3d() % point cloud visualization
%postpro_culling_3d() % culling visualization
%postpro_sampling() % sampling visualization
%postpro_saturation() % time before saturation 
%postpro_exposure() % segmentation with increasing exposure
