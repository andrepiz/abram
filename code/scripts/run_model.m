%% ABRAM %% 
% Astronomical Bodies Radiometric Model

fprintf('\n### RENDERING STARTED ###\n')

%-- Preparation
% Load BRDF functions
get_brdf();
% Discretization and sampling
get_sectors();
% Interpolant maps
get_maps();

%-- Power P [W] to Radiance L [W/(m2 sr)] ratio
% Compute the coefficient relating the emitted Radiance with the reflected
% Power for each sampled point
get_pointCloud();
% Compute the pixel mask of the projected point cloud of coefficients
get_pointMatrix();

%-- Radiance L [W/(m2 sr)] per bandwidth
% Compute the emitted star radiance for each bandwidth defined by lower and
% upper wavelength vectors
get_light();

%-- Power P [W] per pixel per bandwidth and image [DN]
% Compute the power collected by each pixel at each bandwidth in W
% Compute the photon count rate, the electron count rate per pixel per bandwidth in e-/s
% Generate the digital image in DN
get_image();

fprintf('\n### RENDERING FINISHED ###\n')