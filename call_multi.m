%% INSTALL
abram_install();

%% INPUTS
filename_yml = 'example_moon.yml';

%% RENDER OBJECT
% Perform a first rendering and save the render object
rend = abram.render(filename_yml);

%% MULTI-IMAGE CALLING
% Following renderings can be called with the rendering method
% on the render object

% Assume a trajectory
phase_angle_vec = rend.scene.phase_angle + pi/180*[10:10:60];
rend.scene.rpy_CAMI2CAM = [0;0;0];
rend.scene.rpy_CSF2IAU = [0;0;0];

fh1 = figure();
axIm = gca();
im = imshow(digital2digital(rend.img, rend.setting.saving.depth, 8),'Parent',axIm);

% Loop
for ix = 1:length(phase_angle_vec)
    rend.scene.rpy_CSF2IAU(3) = phase_angle_vec(ix);
    rend.scene.d_body2cam = 0.95*rend.scene.d_body2cam;
    rend.scene.phase_angle = phase_angle_vec(ix);
    rend = rend.rendering();

    im = imshow(digital2digital(rend.img, rend.setting.saving.depth, 8),'Parent',axIm);
    drawnow
end

%% ABRAM SMART CALLING
% ABRAM will understand which submethods to skip to increase the frame
% rate. If you want, de-activate this behaviour from the abram.render class.
% For example, if we change only the exposure time, only the image is
% re-processed.
nt = 10;
tExp_original = rend.camera.tExp;
tExp_vec = tExp_original*linspace(0.05, 1, nt);
for ix = 1:nt
    rend.camera.tExp = tExp_vec(ix);
    rend.rendering();
end