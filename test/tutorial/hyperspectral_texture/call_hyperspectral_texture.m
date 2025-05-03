%% INSTALL
abram_install();

%% INPUTS
filename_yml = 'hyperspectral_texture.yml';

map_hyperspectral = 1;  % Case 1: using WAC_HAPKE_3BAND_E350N0450 hyperspectral tile
                        % Case 2: using LROC CGI MOON KIT as hyperspectral map
                        % Case 3: using LROC CGI MOON KIT as monochromatic map
                        
%% RENDER OBJECT
% Perform a first rendering and save the render object
rend = abram.render(filename_yml);

%% SET SPECTRAL DATA

% Set RGB filter
QE.lambda_min = [400 500 600]*1e-9;
QE.lambda_max = [500 600 700]*1e-9;
QE.values = interp1(rend.camera.QE.lambda_mid, rend.camera.QE.values, (QE.lambda_min + QE.lambda_max)/2);
T.lambda_min = [400 500 600]*1e-9;
T.lambda_max = [500 600 700]*1e-9;
T.values = interp1(rend.camera.T.lambda_mid, rend.camera.T.values, (T.lambda_min + T.lambda_max)/2);
rend.camera.QE = QE;
rend.camera.T = T;

% Create hyperspectral albedo map
switch map_hyperspectral

    case 1
    % Using WAC 3-band 8-bit per band RGB (R=689 nm, G=415 nm, and B=321 nm) median mosaic
    % MAXIMUM_LATITUDE              = 70.0131579 <DEG>
    % MINIMUM_LATITUDE              = -0.0 <DEG>
    % EASTERNMOST_LONGITUDE         = 90.0131579 <DEG>
    % WESTERNMOST_LONGITUDE         = 0.0 <DEG>
    rend.body.maps.albedo.filename = 'moon\lroc_rgb\WAC_HAPKE_3BAND_E350N0450.tiff';
    rend.body.maps.albedo.limits = deg2rad([0, 90.0131579; 0, 70.0131579]);
    rend.body.maps.albedo.dimension = 'hyperspectral';
    rend.body.maps.albedo.lambda_min = [321 + ((321 + 415)/2 - 415), (321 + 415)/2, (689 + 415)/2]*1e-9;
    rend.body.maps.albedo.lambda_max = [(321 + 415)/2, (689 + 415)/2, 689 + ((689 + 415)/2 - 415)]*1e-9;
    rend.body.maps.albedo.bandwidth = [rend.camera.QExT.lambda_min(1), rend.camera.QExT.lambda_max(end)];
    rend.body.maps.albedo.domain = [0.08, 0.2; 0.12, 0.28; 0.24, 0.48];% taken from Sato et al.
    rend.body.maps.albedo.mean = [];
    rend.body.maps.albedo.gamma = [];
    rend.body.maps.albedo.scale = [];
    rend.setting.saving.filename = 'wac_hapke_3band_hyperspectral';

    case 2
    % USING LROC CGI MOON KIT
    % The red channel contains the 643 nm band, while green and blue were created from 
    % different linear combinations of the 566 and 415 nm bands to more nearly center
    % them on 532 nm (green) and 472 nm (blue). A gamma of 2.8 was applied (the LROC data is linear), 
    % and the channels were multiplied by (0.935, 1.005, 1.04) to balance the color. 
    % The intensity range (0.16, 0.4) was mapped into the full (0, 255) 8-bit range per channel
    rend.body.maps.albedo.filename = 'moon\lroc_cgi\lroc_color_poles_8k.tif';
    rend.body.maps.albedo.dimension = 'hyperspectral';
    rend.body.maps.albedo.lambda_min = [472 - ((472 + 532)/2 - 472), (472 + 532)/2, (532 + 643)/2]*1e-9;
    rend.body.maps.albedo.lambda_max = [(472 + 532)/2, (532 + 643)/2, 643 + ((532 + 643)/2 - 532)]*1e-9;
    rend.body.maps.albedo.bandwidth = [rend.camera.QExT.lambda_min(1), rend.camera.QExT.lambda_max(end)];
    rend.body.maps.albedo.limits = [-pi, pi; -pi/2 pi/2];
    rend.body.maps.albedo.mean = [];
    rend.body.maps.albedo.gamma = 2.8;
    rend.body.maps.albedo.scale = 1./[0.935, 1.005, 1.04];
    rend.body.maps.albedo.domain = [0.08, 0.2; 0.12, 0.28; 0.24, 0.48];
    rend.setting.saving.filename = 'lroc_color_poles_hyperspectral';

    case 3
    % USING LROC CGI MOON KIT 
    % Raw version doing the mean of the channels
    rend.body.maps.albedo.filename = 'moon\lroc_cgi\lroc_color_poles_8k.tif';
    rend.body.maps.albedo.dimension = 'single';
    rend.body.maps.albedo.gamma = 2.8;
    rend.body.maps.albedo.scale = 1;
    rend.body.maps.albedo.domain = [0.16, 0.4];
    rend.body.maps.albedo.limits = [-pi, pi; -pi/2 pi/2];
    rend.body.maps.albedo.mean = [];
    rend.setting.saving.filename = 'lroc_color_poles_monochromatic';
end

% Set scene so to look only at the region of the provided map
rend.scene.d_body2cam = 15e6;
rend.scene.rpy_CAMI2CAM = [0.08; -0.04; 0];
rend.scene.phase_angle = 1.3;

% Frame
rend = rend.rendering();
