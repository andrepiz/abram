abram_install();

%% SPICE/MICE
% Install MICE from https://github.com/andrepiz/mice and download kernels.
mice_install()
filepath_metakernel = fullfile(mice_home, 'kernels\default.tm');

%% FLAGS
flag_plot_trajectory = true;

%% REAL IMAGE
% From https://images.nasa.gov/details/art001e000403
filepath_img_true = 'art001e000403.jpg';

%% REND OBJECT
filename_yml = 'artemis_flyby.yml';
rend = abram.render(filename_yml, false);

%% SCENE GEOMETRY
filename_artemis_kernel = 'Post_TLI_Orion_AsFlown_20221213_EPH_OEM.asc';

%---Get ARTEMIS trajectory data
[t_UTC, pos_earth2sc_ECI] = read_artemis_kernel(filename_artemis_kernel, flag_plot_trajectory);
np = length(t_UTC);
ixs_picture = 2100; % 22 november 2022
pos_earth2sc_ECI = pos_earth2sc_ECI(:, ixs_picture);

%---Get Moon and Sun geometry data from standard kernels
pos_earth2bodies_ECI = extract_position_bodies_kernel(t_UTC(ixs_picture), {'SUN','MOON'}, filepath_metakernel, 'NONE','EARTH','J2000');
q_ECI2IAU = extract_orientation_bodies_kernel(t_UTC(ixs_picture), {'MOON'}, filepath_metakernel, 'J2000');

pos_earth2sun_ECI = pos_earth2bodies_ECI(1:3, :);
pos_earth2moon_ECI = pos_earth2bodies_ECI(4:6, :); 
pos_moon2sun_ECI = pos_earth2sun_ECI - pos_earth2moon_ECI;
dir_moon2sun_ECI = vecnormalize(pos_moon2sun_ECI);
dir_earth2sun_ECI = vecnormalize(pos_earth2sun_ECI);
pos_sc2moon_ECI = pos_earth2moon_ECI - pos_earth2sc_ECI;
dir_sc2moon_ECI = vecnormalize(pos_sc2moon_ECI);
pos_sc2sun_ECI = pos_earth2sun_ECI - pos_earth2sc_ECI;
dir_sc2sun_ECI = vecnormalize(pos_sc2sun_ECI);

%---Generate camera attitude
% Assuming to point z at the Moon and solar panels aligned to x 
% --> y must be perpendicular to both z and sun direction
zCAMI_ECI = dir_sc2moon_ECI;
yCAMI_ECI = -vecnormalize(cross(dir_sc2sun_ECI, zCAMI_ECI));
xCAMI_ECI = vecnormalize(cross(yCAMI_ECI, zCAMI_ECI));
bias_angle = deg2rad(-20);   
dcm_CAMI2ECI = zeros(3,3);
dcm_CAMI2ECI(:,1,:) = xCAMI_ECI;
dcm_CAMI2ECI(:,2,:) = yCAMI_ECI;
dcm_CAMI2ECI(:,3,:) = zCAMI_ECI;
q_CAMI2ECI = dcm_to_quat(dcm_CAMI2ECI);
q_CAM2CAMI = euler_to_quat([0; 0; bias_angle]);
q_CAM2ECI = quat_mult(q_CAM2CAMI, q_CAMI2ECI);

%---ABRAM inputs
q_CAM2IAU = quat_mult(q_CAM2ECI, q_ECI2IAU);
q_IAU2CAM = quat_conj(q_CAM2IAU);
pos_body2light_IAU = rotframe(pos_moon2sun_ECI, q_ECI2IAU);
pos_body2cam_IAU = rotframe(-pos_sc2moon_ECI, q_ECI2IAU);

%% RENDER

rend.scene.pos_body2light_IAU = pos_body2light_IAU;
rend.scene.pos_body2cam_IAU = pos_body2cam_IAU;
rend.scene.q_IAU2CAM = q_IAU2CAM;

rend = rend.rendering();

%% Simple side-by-side comparison
figure()
subplot(1,2,1)
imshow(imread(filepath_img_true))
title(filepath_img_true)
subplot(1,2,2)
imshow(digital2digital(rend.img, rend.setting.saving.depth, 8));
title('ABRAM Rendering')