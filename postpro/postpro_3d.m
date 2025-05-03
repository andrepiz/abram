cmap = 'jet';

% Extract 3D cloud
pos_cam2sec_CAM = cloud.coords(:, cloud.ixsValid);
coordsUV = camera.K(1:2,:)*(pos_cam2sec_CAM./pos_cam2sec_CAM(3,:));
coordsRC = [coordsUV(2,:); coordsUV(1,:)]; 
PL_point = cloud.values(cloud.ixsValid)*cloud.adim;
PL_pixel = matrix.values*matrix.adim;

% Additional quantities
d_cam2sec = vecnorm(pos_cam2sec_CAM);
dir_cam2sec_CAM = pos_cam2sec_CAM./d_cam2sec;
epsilon = acos(dir_cam2sec_CAM(3,:));  
OmProj = camera.Apupil*cos(scene.ang_offpoint)./(d_cam2sec.^2);
pos_body2sec_CSF = scene.pos_body2cam_CSF + scene.dcm_CSF2CAM'*pos_cam2sec_CAM;
dir_body2star_CSF = scene.dir_body2star_CSF;
dir_body2cam_CSF = scene.dir_body2cam_CSF;
[~, dcm_CSF2CAMI] = cami(dir_body2star_CSF, dir_body2cam_CSF);
dcm_CSF2IAU = scene.dcm_CSF2IAU;
dcm_CSF2CAM = scene.dcm_CSF2CAM;

Rbody = body.Rbody;
res_px = camera.res_px;

%% Frames & Vectors
R_frames2ref(:,:,1) = eye(3);
R_frames2ref(:,:,2) = dcm_CSF2IAU';
R_frames2ref(:,:,3) = dcm_CSF2CAMI';
R_frames2ref(:,:,4) = dcm_CSF2CAM';
R_pos_ref = 3*[zeros(3, 2), dir_body2cam_CSF, dir_body2cam_CSF];
v_ref = 1.5*[dir_body2star_CSF, dir_body2cam_CSF];
v_pos_ref = zeros(3, 2);
fh  = figure(); grid on; hold on; axis equal
plot_frames_and_vectors(R_frames2ref, R_pos_ref, v_ref, v_pos_ref,...
    fh,...
    {'CSF','IAU','CAMI','CAM'},{'star','cam'});
try
    k = 0.3;
    [xS, yS, zS] = sphere(100);
    cover = flip(imread(albedo_filename),1);
    h = surf(k*xS, k*yS, k*zS);
    set(h, 'FaceColor', 'texturemap', 'CData', cover, 'EdgeColor', 'none');
catch
end
cameratoolbar
xlabel('x')
ylabel('y')
zlabel('z')
view([10,30])

%% RANGE
figure()
grid on, hold on
axis equal

scatter3(pos_body2sec_CSF(1,:), pos_body2sec_CSF(2,:), pos_body2sec_CSF(3,:), 10, d_cam2sec, 'filled')
ampl = 2*Rbody(1);
quiver3(0,0,0,ampl*dir_body2star_CSF(1),ampl*dir_body2star_CSF(2),ampl*dir_body2star_CSF(3),'LineWidth',2)
quiver3(0,0,0,ampl*dir_body2cam_CSF(1),ampl*dir_body2cam_CSF(2),ampl*dir_body2cam_CSF(3),'LineWidth',2)
colormap(cmap);
col = colorbar;
col.Label.String = 'd [m]';
legend('d','star','cam')
view([120, 10])
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')

%% OFFPOINTING ANGLE
figure()
grid on, hold on
axis equal

scatter3(pos_body2sec_CSF(1,:), pos_body2sec_CSF(2,:), pos_body2sec_CSF(3,:), 10, epsilon, 'filled')
ampl = 2*Rbody(1);
quiver3(0,0,0,ampl*dir_body2star_CSF(1),ampl*dir_body2star_CSF(2),ampl*dir_body2star_CSF(3),'LineWidth',2)
quiver3(0,0,0,ampl*dir_body2cam_CSF(1),ampl*dir_body2cam_CSF(2),ampl*dir_body2cam_CSF(3),'LineWidth',2)
colormap(cmap);
col = colorbar;
col.Label.String = '\epsilon [m]';
legend('\epsilon','star','cam')
view([120, 10])
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')

%% SPHERICAL ANGLE
figure()
grid on, hold on
axis equal
scatter3(pos_body2sec_CSF(1,:), pos_body2sec_CSF(2,:), pos_body2sec_CSF(3,:), 10, OmProj, 'filled')
ampl = 2*body.Rbody(1);
quiver3(0,0,0,ampl*dir_body2star_CSF(1),ampl*dir_body2star_CSF(2),ampl*dir_body2star_CSF(3),'LineWidth',2)
quiver3(0,0,0,ampl*dir_body2cam_CSF(1),ampl*dir_body2cam_CSF(2),ampl*dir_body2cam_CSF(3),'LineWidth',2)
colormap(cmap);
col = colorbar;
col.Label.String = '\Omega [sr]';
legend('\Omega','star','cam')
view([120, 10])
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')

%% POINT CLOUD
figure()
grid on, hold on
axis equal
scatter3(pos_body2sec_CSF(1,:), pos_body2sec_CSF(2,:), pos_body2sec_CSF(3,:), 10, PL_point, 'filled')
ampl = 2*Rbody(1);
quiver3(0,0,0,ampl*dir_body2star_CSF(1),ampl*dir_body2star_CSF(2),ampl*dir_body2star_CSF(3),'LineWidth',2)
quiver3(0,0,0,ampl*dir_body2cam_CSF(1),ampl*dir_body2cam_CSF(2),ampl*dir_body2cam_CSF(3),'LineWidth',2)
colormap(cmap);
col = colorbar;
col.Label.String = 'P/L [m^2 sr]';
legend('P/L','star','cam')
view([120, 10])
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')

%% PROJECTION
fh1 = figure();
grid on, hold on
grid minor
scatter(gca(), coordsRC(2,:), coordsRC(1,:), [], PL_point)
colormap(cmap);
axis equal
fh1.CurrentAxes.YDir = 'reverse';
col = colorbar;
col.Label.String = 'P/L [m^2 sr]';
xlabel('u [px]')
ylabel('v [px]')
xlim([0, res_px(1)])
ylim([0, res_px(2)])

a1 = axes();
a1.Units = 'normalized';
a1.Position = [200 200 200 200]/1024; % xlocation, ylocation, xsize, ysize
scatter(a1, coordsRC(2,:), coordsRC(1,:), [], PL_point)
%annotation('rectangle',[400 300 20 20]/1024)
%annotation('arrow',[.1 .2],[.1 .2])
axis tight equal
a1.YDir = 'reverse';
% xlim([515, 530])
% ylim([350, 365])
xlim([460, 465])
ylim([465, 470])

%% DIRECT GRIDDING
fh2 = figure();
grid on, hold on
imagesc(PL_pixel)
fh2.CurrentAxes.YDir = 'reverse';
colormap(cmap)
col = colorbar;
col.Label.String = 'P/L [m^2 sr]';
xlabel('u [px]')
ylabel('v [px]')
pbaspect([1, 1, 10])
xlim([0 res_px(1)]) 
ylim([0 res_px(2)])

a2 = axes(fh2);
a2.Units = 'normalized';
a2.Position = [200 200 200 200]/1024; % xlocation, ylocation, xsize, ysize
a2.YDir = 'reverse';
imagesc(PL_pixel)
%annotation('rectangle',[400 300 20 20]/1024)
%annotation('arrow',[.1 .2],[.1 .2])
pbaspect([1, 1, 10])
axis equal
% xlim([515, 530])
% ylim([350, 365])
xlim([460, 465])
ylim([465, 470])

