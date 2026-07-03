%% INSTALL
abram_install();

%% INPUTS
filename_yml = 'hyperspectral_texture.yml';
                        
%% RENDER OBJECT
% Perform a first rendering and save the render object
rend = abram.render(filename_yml, false);

%% SET SPECTRAL DATA

% Using WAC RGB bands (R=689 nm, G=415 nm, and B=321 nm) median mosaic, IMG format
% MAXIMUM_LATITUDE              = 70.0131579 <DEG>
% MINIMUM_LATITUDE              = -0.0 <DEG>
% EASTERNMOST_LONGITUDE         = 90.0131579 <DEG>
% WESTERNMOST_ LONGITUDE         = 0.0 <DEG>
rend.body.maps.albedo.filename = {'WAC_HAPKE_689NM_E350N0450.IMG',...
                                   'WAC_HAPKE_415NM_E350N0450.IMG',...
                                   'WAC_HAPKE_321NM_E350N0450.IMG'};
rend.body.maps.albedo.limits = deg2rad([0, 90.0131579; 0, 70.0131579]);
rend.body.maps.albedo.dimension = 'hyperspectral';
rend.body.maps.albedo.depth = 1;
rend.body.maps.albedo.encoding = 'linear';
rend.body.maps.albedo.lambda_mid = [689, 415, 321]*1e-9;
rend.body.maps.albedo.scale = [6.4437275, 7.2432575, 8.0733271]; % check pnrf2ssa
rend.body.maps.albedo.shift = [0.11101329, 0.043262750, 0.018441480]; % check pnrf2ssa

% Set scene so to look only at the region of the provided map
rend.scene.d_body2cam = 15e6;
rend.scene.rpy_CAMI2CAM = [0.08; -0.04; 0];
rend.scene.phase_angle = 1.3;

% Frame
rend = rend.rendering();
postpro();