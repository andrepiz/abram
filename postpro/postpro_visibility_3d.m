%% 3D
% Check visibility of the scenario in terms of FOV, geometry observability
% and illumination from the sun

pos_cam2sec_CAM = cloud.coords;
posObscured_cam2sec_CAM = cloud.coords(:, ~cloud.ixsLit);
posInvisible_cam2sec_CAM = cloud.coords(:, ~cloud.ixsVisible);
posNonradiating_cam2sec_CAM = cloud.coords(:, ~cloud.ixsRadiating);
posOccluded_cam2sec_CAM = cloud.coords(:, ~cloud.ixsUnoccluded);

% Additional quantities
pos_body2sec_CSF = scene.pos_body2cam_CSF + scene.dcm_CSF2CAM'*pos_cam2sec_CAM;
posObscured_body2sec_CSF = scene.pos_body2cam_CSF + scene.dcm_CSF2CAM'*posObscured_cam2sec_CAM;
posInvisible_body2sec_CSF = scene.pos_body2cam_CSF + scene.dcm_CSF2CAM'*posInvisible_cam2sec_CAM;
posNonradiating_body2sec_CSF = scene.pos_body2cam_CSF + scene.dcm_CSF2CAM'*posNonradiating_cam2sec_CAM;
posOccluded_body2sec_CSF = scene.pos_body2cam_CSF + scene.dcm_CSF2CAM'*posOccluded_cam2sec_CAM;
dir_body2star_CSF = scene.dir_body2star_CSF;
dir_body2cam_CSF = scene.dir_body2cam_CSF;
Rbody = body.Rbody;

%%
customMap2 = [0.2, 0.8, 0.4;
            0.2, 0.4, 0.8;
            0.8, 0.2, 0.4];
ampl = 2*Rbody(1);

figure()
subplot(1,2,1)
grid on, hold on
axis equal
quiver3(0,0,0,ampl*dir_body2star_CSF(1),ampl*dir_body2star_CSF(2),ampl*dir_body2star_CSF(3),'LineWidth',2)
quiver3(0,0,0,ampl*dir_body2cam_CSF(1),ampl*dir_body2cam_CSF(2),ampl*dir_body2cam_CSF(3),'LineWidth',2)
scatter3(pos_body2sec_CSF(1,:), pos_body2sec_CSF(2,:), pos_body2sec_CSF(3,:), 10, customMap2(1,:), 'filled')
scatter3(posObscured_body2sec_CSF(1,:), posObscured_body2sec_CSF(2,:), posObscured_body2sec_CSF(3,:), 10, customMap2(2,:), 'filled')
scatter3(posInvisible_body2sec_CSF(1,:), posInvisible_body2sec_CSF(2,:), posInvisible_body2sec_CSF(3,:), 10, customMap2(3,:), 'filled')

col = colorbar;
colormap(customMap2)
col.Ticks = [0.2 0.5 0.8];
col.TickLabels = {'Sampled','Obscured','Invisible'};
col.Label.String = 'condition';
legend('star','cam')
view([120, 10])
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')

%
subplot(1,2,2)
grid on, hold on
axis equal
quiver3(0,0,0,ampl*dir_body2star_CSF(1),ampl*dir_body2star_CSF(2),ampl*dir_body2star_CSF(3),'LineWidth',2)
quiver3(0,0,0,ampl*dir_body2cam_CSF(1),ampl*dir_body2cam_CSF(2),ampl*dir_body2cam_CSF(3),'LineWidth',2)
scatter3(pos_body2sec_CSF(1,:), pos_body2sec_CSF(2,:), pos_body2sec_CSF(3,:), 10, customMap2(1,:), 'filled')
scatter3(posNonradiating_body2sec_CSF(1,:), posNonradiating_body2sec_CSF(2,:), posNonradiating_body2sec_CSF(3,:), 10, customMap2(2,:), 'filled')
scatter3(posOccluded_body2sec_CSF(1,:), posOccluded_body2sec_CSF(2,:), posOccluded_body2sec_CSF(3,:), 10, customMap2(3,:), 'filled')

col = colorbar;
colormap(customMap2)
col.Ticks = [0.2 0.5 0.8];
col.TickLabels = {'Sampled','Non-radiating','Occluded'};
col.Label.String = 'condition';
legend('star','cam')
view([120, 10])
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')

