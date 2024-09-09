cmap = 'jet'

%% Geometry
R_frames2ref(:,:,1) = eye(3);
R_frames2ref(:,:,2) = dcm_CSF2IAU';
R_frames2ref(:,:,3) = dcm_CSF2CAMI';
R_frames2ref(:,:,4) = dcm_CSF2CAM';
R_pos_ref = 3*[zeros(3, 2), dir_body2sc_CSF, dir_body2sc_CSF];
v_ref = 1.5*[dir_body2sun_CSF, dir_body2sc_CSF];
v_pos_ref = zeros(3, 2);
fh  = figure(); grid on; hold on; axis equal
plot_frames_and_vectors(R_frames2ref, R_pos_ref, v_ref, v_pos_ref,...
    fh,...
    {'CSF','IAU','CAMI','CAM'},{'Sun','SC'});
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
view([1,1,1])


%% PL
figure()
grid on, hold on
axis equal
scatter3(pos_body2sec_CSF(1,:), pos_body2sec_CSF(2,:), pos_body2sec_CSF(3,:), 10, PL_point, 'filled')
ampl = 2*Rbody;
quiver3(0,0,0,ampl*dir_body2sun_CSF(1),ampl*dir_body2sun_CSF(2),ampl*dir_body2sun_CSF(3),'LineWidth',2)
quiver3(0,0,0,ampl*dir_body2sc_CSF(1),ampl*dir_body2sc_CSF(2),ampl*dir_body2sc_CSF(3),'LineWidth',2)
colormap(cmap);
col = colorbar;
col.Label.String = 'PL [m^2 sr]';
legend('PL','Sun','Observer')
view([120, 10])
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')

%% Spherical angle
Om_sec = Apupil*cos(ang_offpoint)./(d_sc2sec.^2);

figure()
grid on, hold on
axis equal
scatter3(pos_body2sec_CSF(1,:), pos_body2sec_CSF(2,:), pos_body2sec_CSF(3,:), 10, Om_sec, 'filled')
ampl = 2*Rbody;
quiver3(0,0,0,ampl*dir_body2sun_CSF(1),ampl*dir_body2sun_CSF(2),ampl*dir_body2sun_CSF(3),'LineWidth',2)
quiver3(0,0,0,ampl*dir_body2sc_CSF(1),ampl*dir_body2sc_CSF(2),ampl*dir_body2sc_CSF(3),'LineWidth',2)
colormap(cmap);
col = colorbar;
col.Label.String = '\Omega [sr]';
%title('Projected spherical angle on pixel area [sr]');
legend('\Omega','Sun','Observer')
view([120, 10])
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')

%% PF
PF_point = PL_point ./ (pi * Rstar^2/(d_body2star^2));

figure()
grid on, hold on
axis equal
scatter3(pos_body2sec_CSF(1,:), pos_body2sec_CSF(2,:), pos_body2sec_CSF(3,:), 10, PF_point, 'filled')
ampl = 2*Rbody;
quiver3(0,0,0,ampl*dir_body2sun_CSF(1),ampl*dir_body2sun_CSF(2),ampl*dir_body2sun_CSF(3),'LineWidth',2)
quiver3(0,0,0,ampl*dir_body2sc_CSF(1),ampl*dir_body2sc_CSF(2),ampl*dir_body2sc_CSF(3),'LineWidth',2)
colormap(cmap);
col = colorbar;
col.Label.String = 'PF [m^2]';
legend('IF','Sun','Observer')
view([120, 10])
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')

%% PF projected
fh1 = figure();
grid on, hold on
grid minor
scatter(coords(2,:), coords(1,:), [], PF_point)
colormap(cmap);
axis equal
fh1.CurrentAxes.YDir = 'reverse';
colormap(cmap);
col = colorbar;
col.Label.String = 'PF [m^2]';
xlabel('u [px]')
ylabel('v [px]')
xlim([0, res_px])
ylim([0, res_px])
%title('Reflected Power PCR on image plane [W]');

a1 = axes();
a1.Units = 'normalized';
a1.Position = [200 700 200 200]/1024; % xlocation, ylocation, xsize, ysize
scatter(a1, coords(2,:), coords(1,:), [], PF_point)
%annotation('rectangle',[400 300 20 20]/1024)
%annotation('arrow',[.1 .2],[.1 .2])
axis tight equal
a1.YDir = 'reverse';
xlim([460, 470])
ylim([255, 265])

%% PF binned
L_bw_temp(1,:,:) = L_bw;
PL_pixel = sum(P_pixel_bw./L_bw_temp, 3);
PF_pixel = PL_pixel ./ (pi * Rstar^2/(d_body2star^2));
%PF_img = pagetranspose(PF_pixel);
PF_img = PF_pixel;

fh2 = figure();
grid on, hold on
imagesc(PF_img)
fh2.CurrentAxes.YDir = 'reverse';
colormap(cmap)
col = colorbar;
col.Label.String = 'PF [m^2]';
xlabel('u [px]')
ylabel('v [px]')
pbaspect([1, 1, 10])
xlim([0 res_px]) 
ylim([0 res_px])

a2 = axes(fh2);
a2.Units = 'normalized';
a2.Position = [200 700 200 200]/1024; % xlocation, ylocation, xsize, ysize
a2.YDir = 'reverse';
imagesc(PF_img)
%annotation('rectangle',[400 300 20 20]/1024)
%annotation('arrow',[.1 .2],[.1 .2])
pbaspect([1, 1, 10])
axis equal
xlim([460, 470])
ylim([255, 265])
