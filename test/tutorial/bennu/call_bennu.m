abram_install()

filename_yml = 'bennu.yml';
rend = abram.render(filename_yml, false); 

%% ---BENNU
rend.setting.discretization.accuracy = 'medium';
rend.setting.saving.filename = 'bennu';

rend.setting.sampling.limits = 'fixed';
rend.body.lon_lims = [-pi, pi];
rend.body.lat_lims = [-pi/2, pi/2];

rend.scene.phase_angle = -0.5;
yaw_vec = 0:2*pi/60:2*pi-2*pi/60;

fh1 = figure();
axIm = gca();
% Loop
for ix = 1:length(yaw_vec)

    rend.scene.rpy_CSF2IAU(3) = yaw_vec(ix);
    rend = rend.rendering();

    im = imshow(digital2digital(rend.img, rend.setting.saving.depth, 8),'Parent',axIm);
    drawnow
end