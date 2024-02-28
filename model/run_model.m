%% ABRAM %% 
% Astronomical Bodies Radiometric Model

%-- INIT
% BRDF functions
get_brdf();
% Process inputs and compute useful data
prepro();

%-- Power P [W] to Radiance L [W/(m2 sr)] ratio
% Compute the coefficient relating the emitted Radiance with the reflected
% Power for each sampled point
get_power_on_radiance_per_point();
% Compute the pixel mask of the projected point cloud of coefficients
get_power_on_radiance_per_pixel();

%-- Radiance L [W/(m2 sr)] per bandwidth
% Compute the emitted star radiance for each bandwidth defined by lower and
% upper wavelength vectors
get_radiance_per_bw();

%-- Power P [W] per pixel per bandwidth
% Compute the power collected by each pixel at each bandwidth in W
% Compute the photon count rate, the electron count rate per pixel per bandwidth in e-/s
% Generate the digital image in DN
get_power_per_pixel_per_bw();