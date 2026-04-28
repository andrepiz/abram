abram_install()

filename_yml = 'phobos.yml';
rend = abram.render(filename_yml, false); 

%% ---PHOBOS
%https://astrogeology.usgs.gov/search/map/phobos_mars_express_hrsc_dem_global_100m
%a= 13.00 km, b= 11.39 km and c= 9.07 km

rend.setting.discretization.accuracy = 'medium';
%rend.setting.discretization.accuracy = 0.1; % debug

rend.setting.sampling.limits = 'auto';
% rend.setting.sampling.limits = 'fixed';
% rend.body.lon_lims = [-pi, pi];
% rend.body.lat_lims = [-pi/2, pi/2];

% scenario of photo 1
% rend.scene.d_body2star = 1.52*AU;
% rend.scene.d_body2cam = 1590.4e3;
% rend.scene.phase_angle = -0.6*pi/2;
% rend.scene.rpy_CAMI2CAM = [0.00; 0.0; 0.7];
% rend.scene.rpy_CSF2IAU = [0.1309; -1.2567; 2.199] + [-0.4; 0.4; 0.3];

rend = rend.rendering();

postpro()