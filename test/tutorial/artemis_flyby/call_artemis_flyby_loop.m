abram_install();

%% SPICE/MICE
% Install MICE from https://github.com/andrepiz/mice and download kernels.
mice_install()
filepath_metakernel = fullfile(mice_home, 'kernels\default.tm');

%% FLAGS
flag_plot_trajectory = true;

%% INPUTS
filename_yml = 'artemis_flyby.yml';
filename_artemis_kernel = 'Post_TLI_Orion_AsFlown_20221213_EPH_OEM.asc';
ixs_picture = [1, 101, 1001, 2001, 3001, 4001];
ixs_picture = [1:50:4001];

%% REND OBJECT
rend = abram.render(filename_yml, false);

%% SCENE GEOMETRY
%---Get ARTEMIS trajectory data
[t_UTC, pos_earth2sc_ECI] = read_artemis_kernel(filename_artemis_kernel, flag_plot_trajectory);
np = length(t_UTC);

%---Get Moon and Sun geometry data from standard kernels
pos_earth2bodies_ECI = extract_position_bodies_kernel(t_UTC, {'SUN','MOON'}, filepath_metakernel, 'NONE','EARTH','J2000');
q_ECI2IAU = extract_orientation_bodies_kernel(t_UTC, {'MOON'}, filepath_metakernel, 'J2000');

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
dcm_CAMI2ECI = zeros(3,3,np);
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

%% Loop

IMG_vec = uint16(zeros(rend.camera.res_px(2), rend.camera.res_px(1), length(ixs_picture)));
c = 0;

fh1 = figure();
axIm = gca();
im = imshow(digital2digital(rend.img, rend.setting.saving.depth, 8),'Parent',axIm);

for ix = ixs_picture
    c = c + 1;
    rend.scene.pos_body2light_IAU = pos_body2light_IAU(:, ix);
    rend.scene.pos_body2cam_IAU = pos_body2cam_IAU(:, ix);
    rend.scene.q_IAU2CAM = q_IAU2CAM(:, ix);

    rend = rend.rendering();
    
    IMG_vec(:,:,c) = rend.img;

    im = imshow(digital2digital(rend.img, rend.setting.saving.depth, 8),'Parent',axIm);
    drawnow
end

%% Video
posOrion_plot = pos_earth2sc_ECI/384400e3;
posMoon_plot = pos_earth2moon_ECI/384400e3;
dirMoon2Sun_plot = dir_moon2sun_ECI;
kstep = 20;
tp = 0.05;
axlims = 1.1;

f1 = figure('Units','normalized','Position',[0.02 0.1 0.5 0.8]);
f2 = figure('Units','normalized','Position',[0.4 0.1 0.6 0.8]);
camzoom(axlims)
grid on, hold on, axis equal
plot3(0,0,0,'bo','MarkerFaceColor',[0.2 0.2 0.8],'MarkerSize',40)
plot3(posOrion_plot(1,:), posOrion_plot(2,:), posOrion_plot(3,:),'LineWidth',2,'Color',[0.2 0.6 0.2 0.5])
plot3(posMoon_plot(1,:), posMoon_plot(2,:), posMoon_plot(3,:),'LineWidth',2,'Color',[0.5 0.5 0.5 0.2])
xlabel('X_{ECI} [Moon Distance]')
ylabel('Y_{ECI} [Moon Distance]')
zlabel('Z_{ECI} [Moon Distance]')
xlim([-1 1]*axlims)
ylim([-1 1]*axlims)
zlim([-1 1]*axlims)
view([1,1,1])
for ix = 1:kstep:length(t_UTC)
    figure(f2)
    fo = plot3(posOrion_plot(1,ix), posOrion_plot(2,ix), posOrion_plot(3,ix),...
        'go','MarkerFaceColor',[0.2 0.6 0.2]);
    fm = plot3(posMoon_plot(1,ix), posMoon_plot(2,ix), posMoon_plot(3,ix),'o','MarkerSize',10,'MarkerFaceColor',[0.2 0.2 0.2]);
    fs = quiver3(posMoon_plot(1,ix), posMoon_plot(2,ix), posMoon_plot(3,ix), dirMoon2Sun_plot(1,ix), dirMoon2Sun_plot(2,ix), dirMoon2Sun_plot(3,ix),...
        'r','LineWidth',2,'MarkerEdgeColor',[0.2 0.2 0.2]);
    if any((ixs_picture - ix) == 0)
        figure(f1)
        ix_picture_temp = find((ixs_picture - ix) == 0);
        fim = imshow(digital2digital(IMG_vec(:,:,ix_picture_temp), rend.setting.saving.depth, 8));
        title(string(t_UTC(ix)))
        pause(1)
    end
    drawnow
    pause(tp)
    delete([fo, fm, fs])
end