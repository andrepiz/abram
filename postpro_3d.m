cmap = 'jet'

%% PL
figure()
grid on, hold on
axis equal
scatter3(pos_body2ij_CSF(1,:), pos_body2ij_CSF(2,:), pos_body2ij_CSF(3,:), 10, PL_point, 'filled')
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
Om_ij = Apupil*cos(ang_offpoint)./(d_sc2ij.^2);

figure()
grid on, hold on
axis equal
scatter3(pos_body2ij_CSF(1,:), pos_body2ij_CSF(2,:), pos_body2ij_CSF(3,:), 10, Om_ij, 'filled')
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
scatter3(pos_body2ij_CSF(1,:), pos_body2ij_CSF(2,:), pos_body2ij_CSF(3,:), 10, PF_point, 'filled')
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
figure()
grid on, hold on
grid minor
scatter(uv_scaled(1,:), uv_scaled(2,:), [], PF_point)
colormap(cmap);
axis equal
colormap(cmap);
col = colorbar;
col.Label.String = 'PF [m^2]';
xlabel('u [px]')
ylabel('v [px]')
xlim([0, res_px])
ylim([0, res_px])
%title('Reflected Power PCR on image plane [W]');

a2 = axes();
a2.Units = 'normalized';
a2.Position = [200 700 200 200]/1024; % xlocation, ylocation, xsize, ysize
scatter(a2, uv_scaled(1,:), uv_scaled(2,:), [], PF_point)
%annotation('rectangle',[400 300 20 20]/1024)
%annotation('arrow',[.1 .2],[.1 .2])
axis tight equal
xlim([460, 470])
ylim([255, 265])

%% PF binned
L_bw_temp(1,:,:) = L_bw;
PL_pixel = sum(P_pixel_bw./L_bw_temp, 3);
PF_pixel = PL_pixel ./ (pi * Rstar^2/(d_body2star^2));

figure()
grid on, hold on
imagesc(PF_pixel')
%set(gca,'YDir','reverse')
colormap(cmap)
col = colorbar;
col.Label.String = 'PF [m^2]';
xlabel('u [px]')
ylabel('v [px]')
pbaspect([1, 1, 10])
xlim([0 res_px]) 
ylim([0 res_px])

a2 = axes();
a2.Units = 'normalized';
a2.Position = [200 700 200 200]/1024; % xlocation, ylocation, xsize, ysize
imagesc(PF_pixel')
set(a2,'YDir','normal')
%annotation('rectangle',[400 300 20 20]/1024)
%annotation('arrow',[.1 .2],[.1 .2])
pbaspect([1, 1, 10])
axis equal
xlim([460, 470])
ylim([255, 265])
