%% ABRAM %% 
% Astronomical Bodies Radiometric Model
abram_install()

yml = 'example.yml';
yml = 'inputs\yml\moon_front.yml';

%% ---- Step-by-step

inputs = yaml.ReadYaml(yml);

%-- SETTING
% Create setting
setting = abram.setting(yml);
setting = abram.render.getParPool(setting);

%-- SCENE
% Create scene
scene = abram.scene(yml);

%-- STAR
% Create star
star = abram.star(yml);

%-- CAMERA
% Create camera
camera = abram.camera(yml);
% Create spectrum
spectrum_vec = [camera.QE, camera.T];
spectrum = spectrum_vec.merge();
% Integrate light on spectrum
star = star.integrateRadiance(spectrum);

%-- BODY
% Create body
body = abram.body(yml);
% Load maps
body = abram.body.loadMaps(body);
% Discretize and sample
setting = abram.render.setDiscretization(body, camera, scene, setting);
body = abram.body.sampleSectors(body, camera, scene, setting);

%-- RENDER
matrix = abram.render.renderScene(star, body, camera, scene, setting);

%--IMAGE
image = abram.render.processImage(matrix, star, camera, setting);
abram.render.saveImage(image, setting);

%% ---- All-in-one

% Single command
rend = abram.render(yml);