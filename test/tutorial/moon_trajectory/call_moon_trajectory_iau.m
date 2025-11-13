%% INSTALL
abram_install();

%% INPUTS
filename_yml = 'moon_trajectory.yml';

%% RENDER OBJECT
% Perform a first rendering and save the render object
rend = abram.render(filename_yml);

%% GEOMETRY

% Define pose of the camera and of the Sun in the IAU Moon-fixed frame
np = 10;
pos_body2star_IAU = 2e11*[linspace(0, 0.5, np); linspace(-0.5, 0, np); 0.5*ones(1, np)];
pos_body2cam_IAU = [linspace(500e6, 50e6, np); zeros(1, np); zeros(1, np)];
q_IAU2CAM = euler_to_quat([linspace(pi/2, pi/2+0.01, np); linspace(pi/5-0.03, pi/5+0.05, np); -pi/2*ones(1, np)]);

% FRAME CONVERSION
% IAU Frame is body-fixed with the target. X-axis is along the prime
% meridian, Z-axis is along north pole and Y-axis completes the frame.
[phase_angle_vec, d_body2cam_vec, d_body2star_vec, rpy_CSF2IAU_vec, rpy_CAMI2CAM_vec] = iau2abram(pos_body2star_IAU, pos_body2cam_IAU, q_IAU2CAM, false);

%% MULTI-IMAGE CALLING
% Following renderings can be called with the rendering method
% on the render object

fh1 = figure();
axIm = gca();
im = imshow(digital2digital(rend.img, rend.setting.saving.depth, 8),'Parent',axIm);

% Loop
for ix = 1:length(phase_angle_vec)

    delete(im)

    rend.scene.rpy_CAMI2CAM = rpy_CAMI2CAM_vec(:, ix);
    rend.scene.rpy_CSF2IAU = rpy_CSF2IAU_vec(:, ix);
    rend.scene.d_body2light = d_body2star_vec(ix);
    rend.scene.d_body2cam = d_body2cam_vec(ix);
    rend.scene.phase_angle = phase_angle_vec(ix);
    rend = rend.rendering();

    im = imshow(digital2digital(rend.img, rend.setting.saving.depth, 8),'Parent',axIm);
    drawnow
end