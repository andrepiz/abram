%% INSTALL
abram_install();

%% INPUTS
%filename_yml = 'example.yml';
filename_yml = 'example_parallelized.yml'; % fast version with parallellization

%% RENDER OBJECT
% Perform a first rendering and save the render object
rend = abram.render(filename_yml);

%% MULTI-IMAGE CALLING
% Following renderings can be called with the rendering method
% on the render object

% Assume a trajectory
nt = 3;
d_body2cam_original = rend.scene.d_body2cam;
d_body2cam_vec = d_body2cam_original*linspace(1, 3, nt);
% Loop
for ix = 1:nt
    rend.scene.d_body2cam = d_body2cam_vec(ix);
    rend.rendering();
end

%% ABRAM SMART CALLING
% ABRAM will understand which submethods to skip to increase the frame
% rate. If you want, de-activate this behaviour from the abram.render class.
% For example, if we change only the exposure time, only the image is
% re-processed.
nt = 3;
tExp_original = rend.camera.tExp;
tExp_vec = tExp_original*linspace(1, 3, nt);
for ix = 1:nt
    rend.camera.tExp = tExp_vec(ix);
    rend.rendering();
end