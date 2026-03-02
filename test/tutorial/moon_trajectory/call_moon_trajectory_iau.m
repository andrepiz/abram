%% INSTALL
abram_install();

%% INPUTS
filename_yml = 'moon_trajectory.yml';

%% RENDER OBJECT
% Perform a first rendering and save the render object
rend = abram.render(filename_yml, false);

%% GEOMETRY

% Define pose of the camera and of the Sun in the IAU Moon-fixed frame
np = 10;
pos_body2light_IAU = 2e11*[linspace(0, 0.5, np); linspace(-0.5, 0, np); 0.5*ones(1, np)];
pos_body2cam_IAU = [linspace(500e6, 50e6, np); zeros(1, np); zeros(1, np)];
q_IAU2CAM = euler_to_quat([linspace(pi/2, pi/2+0.01, np); linspace(pi/5-0.03, pi/5+0.05, np); -pi/2*ones(1, np)]);

%% MULTI-IMAGE CALLING
% Following renderings can be called with the rendering method
% on the render object

fh1 = figure();
axIm = gca();
im = imshow(digital2digital(rend.img, rend.setting.saving.depth, 8),'Parent',axIm);

% Loop
for ix = 1:np

    delete(im)

    rend.scene.pos_body2light_IAU = pos_body2light_IAU(:, ix);
    rend.scene.pos_body2cam_IAU = pos_body2cam_IAU(:, ix);
    rend.scene.q_IAU2CAM = q_IAU2CAM(:, ix);

    rend = rend.rendering();

    im = imshow(digital2digital(rend.img, rend.setting.saving.depth, 8),'Parent',axIm);
    drawnow
end