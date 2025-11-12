%% RADIOMETRIC CALIBRATION OF RENDER ENGINES
% Render a 1m-radius, 0.01 albedo, Lambertian sphere placed at 1 AU of distance from the 
% Sun and different phase angles and at a common exposure time such to
% avoid saturation.
% Then perform the calibration comparing the electron count of
% ABRAM vs the one expected by the image.
% Note that the calibration has to be performed every time the camera changes
% in terms of parameters that the render engine does not model (e.g. the
% pupil diameter or the quantum efficiency in Blender)

%% ABRAM
abram_install();

%% GROUND TRUTH
% USE YML
filename_yml = 'sphere001_8m_02ms_8bit.yml';
filename_yml = 'bfs001_8m_5ms_8bit.yml';

inputs_yml();

run_model();

%% POST-PRO
image_filepath_render_engine = 'data\sphere001_8m_02ms_8bit\img\000001.png';
image_filepath_render_engine = 'data\bfs001_8m_5ms_8bit\img\000000.png';

postpro_render_engine_calibration();