abram_install()

flag_show_footprint = false;

%% SET OBJECT
rend = abram.render('moon_landing.yml');

%% LANDING SCENARIO [1500 km - 50 m]
h0 = rend.altitude;
d0 = rend.scene.d_body2cam;
R0 = rend.bodyRadiusAtNadir;

rend.setting.saving.filename = 'results\moon_landing';
rend.setting.saving.filename = [];
rend.setting.discretization.accuracy = 'medium';
rend.setting.discretization.accuracy = 1; % debug to test a new trajectory

nPlot = 30; 
d_body2cam_waypts = R0 + 1e3*[1500 800 400 200 100 60 30 10 1 0.1 0.015];
rpy_CAMI2CAM_waypts = [0.1 0.2   0.4  0.65  0.95 1.1  1.2 1.35 1.48 1.55 1.6; ...
                       0   0.05  0.1  0.15  0.2  0.25 0.3 0.35 0.4 0.45 0.5; ...
                       0   0.05  0.1  0.15  0.2  0.25 0.3 0.35 0.4 0.45 0.5];
d_body2cam_vec = interp1(linspace(0, 1, length(d_body2cam_waypts)), d_body2cam_waypts, linspace(0, 1, nPlot));
rpy_CAMI2CAM_vec = interp1(linspace(0, 1, length(d_body2cam_waypts)), rpy_CAMI2CAM_waypts', linspace(0, 1, nPlot))';

% rend.camera.res_px = [1366 768]; % cinematic

idxPlot = 1:nPlot;

lonMin = nan;
lonMax = nan;
latMin = nan;
latMax = nan;

fh1 = figure();
axIm = gca();
im = imshow(digital2digital(rend.img, rend.setting.saving.depth, 8),'Parent',axIm);

for ix = idxPlot

rend.scene.d_body2cam = d_body2cam_vec(ix);
rend.scene.rpy_CAMI2CAM = rpy_CAMI2CAM_vec(:, ix);

fprintf(['\nALTITUDE: ', num2str(rend.altitude), ' METERS'])

rend = rend.rendering();

im = imshow(digital2digital(rend.img, rend.setting.saving.depth, 8),'Parent',axIm);
drawnow

if flag_show_footprint
[lonMin_temp, lonMax_temp, latMin_temp, latMax_temp] = rend.footprint();
lonMin = min(lonMin_temp, lonMin);
lonMax = max(lonMax_temp, lonMax);
latMin = min(latMin_temp, latMin);
latMax = max(latMax_temp, latMax);

fprintf(['\nCURRENT IMAGE FOOTPRINT: ', num2str(rad2deg(lonMin_temp)),'/',num2str(rad2deg(lonMax_temp)),' LON, ', num2str(rad2deg(latMin_temp)),'/',num2str(rad2deg(latMax_temp)),' LAT'])
fprintf(['\nFULL TRAJECTORY FOOTPRINT: ', num2str(rad2deg(lonMin)),'/',num2str(rad2deg(lonMax)),' LON, ', num2str(rad2deg(latMin)),'/',num2str(rad2deg(latMax)),' LAT'])
end

end

