abram_install()

%% SPICE/MICE
% Install MICE from https://github.com/andrepiz/mice and download kernels.
mice_install()
filepath_metakernel = fullfile(mice_home, 'kernels\default.tm');

%% INPUTS
filename_yml = 'moon_trajectory.yml';

%% RENDER OBJECT
% Perform a first rendering and save the render object
rend = abram.render(filename_yml);

%% GEOMETRY

% Trajectory data in ECI
filename_csv = 'OpTraj_t300_f12_earth_nominal.csv';
traj_data = readtable(filename_csv).Variables;

% FRAME CONVERSION using SPICE/MICE
[d_body2star_vec, d_body2cam_vec, phase_angle_vec, q_CAMI2CAM_vec, q_CSF2IAU_vec] = ...
            inputs_eci2matlab(traj_data(1,:), traj_data([2:4],:), traj_data([5:8],:), filepath_metakernel, 'MOON');

%% MULTI-IMAGE CALLING
fh1 = figure();
axIm = gca();
im = imshow(digital2digital(rend.img, rend.setting.saving.depth, 8),'Parent',axIm);

nix = size(traj_data, 2);

ix_min = 1;
ix_max = 30;
% Loop
for ix = max(1, ix_min):min(ix_max, length(phase_angle_vec))
    % set new data
    rend.scene.d_body2star = d_body2star_vec(ix);
    rend.scene.d_body2cam = d_body2cam_vec(ix);
    rend.scene.phase_angle = phase_angle_vec(ix);
    rend.scene.rpy_CAMI2CAM = quat_to_euler(q_CAMI2CAM_vec(:, ix));
    rend.scene.rpy_CSF2IAU = quat_to_euler(q_CSF2IAU_vec(:, ix));

    rend = rend.rendering();

    im = imshow(digital2digital(rend.img, rend.setting.saving.depth, 8),'Parent',axIm);
    drawnow
end