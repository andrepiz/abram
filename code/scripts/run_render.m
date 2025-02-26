%% ABRAM %% 
% Astronomical Bodies Radiometric Model
abram_install()

filename_yml = 'example.yml';

%% ---- Step-by-step

inputs = yaml.ReadYaml(filename_yml);

%-- SETTING
% Create setting
setting = abram.setting(filename_yml);
setting = abram.render.getParPool(setting);

%-- SCENE
% Create scene
scene = abram.scene(filename_yml);

%-- STAR
% Create star
star = abram.star(filename_yml);

%-- CAMERA
% Create camera
camera = abram.camera(filename_yml);
% Create spectrum
spectrum_vec = [camera.QE, camera.T];
spectrum = spectrum_vec.merge();
% Integrate light on spectrum
star = star.integrateRadiance(spectrum);

%-- BODY
% Create body
body = abram.body(filename_yml);
% Load maps
body = abram.body.loadMaps(body);
% Discretize and sample
body = abram.body.sampleSectors(body, camera, scene, setting);

%-- RENDER
cloud = abram.render.pointCloud(star, body, camera, scene, setting);
matrix = abram.render.directGridding(cloud, body, camera, setting);

%--IMAGE
image = abram.render.processImage(matrix, star, camera, setting);
abram.render.saveImage(image, setting);

%% ---- All-in-one

% Single command
rend = abram.render(filename_yml);