abram_install()

rend = abram.render('moon_landing.yml');

%% LANDING SCENARIO [50 km - 10 m]
h0 = rend.altitude;
d0 = rend.scene.d_body2cam;
R0 = rend.bodyRadiusAtNadir;

rend.setting.discretization.accuracy = 'medium';
%rend.setting.discretization.accuracy = 0.1; % debug

nPlot = 30; 
d_body2cam_vec = interp1(linspace(0, 1, 6), R0 + 1e3*[60 30 10 1 0.1 0.01], linspace(0, 1, nPlot));
rpy_CAMI2CAM_vec = interp1(linspace(0, 1, 6), [0.7 1.1 1.3 1.5 1.55 1.6; 0.2 0.4 0.6 0.8 0.8 0.8; 0.1 0.3 0.4 0.6 0.6 0.6]', linspace(0, 1, nPlot))';

%rend.camera.res_px = [1366 768]; % cinematic

idxPlot = 1:nPlot;
%idxPlot = 18:nPlot;

lonMin = nan;
lonMax = nan;
latMin = nan;
latMax = nan;

% rend.scene.rpy_CSF2IAU = [0; 0; 0.9-1.3265+0.1047];
rend.update_sectors = true;

for ix = idxPlot

rend.scene.d_body2cam = d_body2cam_vec(ix);
rend.scene.rpy_CAMI2CAM = rpy_CAMI2CAM_vec(:, ix);

fprintf(['\nALTITUDE: ', num2str(rend.altitude), ' METERS'])

rend = rend.rendering();

[lonMin_temp, lonMax_temp, latMin_temp, latMax_temp] = rend.footprint();
lonMin = min(lonMin_temp, lonMin);
lonMax = max(lonMax_temp, lonMax);
latMin = min(latMin_temp, latMin);
latMax = max(latMax_temp, latMax);

fprintf(['\nFOOTPRINT: ', num2str(rad2deg(lonMin_temp)),'/',num2str(rad2deg(lonMax_temp)),' LON, ', num2str(rad2deg(latMin_temp)),'/',num2str(rad2deg(latMax_temp)),' LAT'])
fprintf(['\nTRAJECTORY FOOTPRINT: ', num2str(rad2deg(lonMin)),'/',num2str(rad2deg(lonMax)),' LON, ', num2str(rad2deg(latMin)),'/',num2str(rad2deg(latMax)),' LAT'])

end

