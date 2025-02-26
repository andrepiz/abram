%% Plot Comparison
[x_pixel, y_pixel] = meshgrid([1:res_px(1)], [1:res_px(2)]);

%%
figure('Name','validation_phase_law_geometry_term')
subplot(1,2,1)
hold on, grid on
plot(d_body2cam_vec, Gcomp./Gref,'go-')
plot(d_body2cam_vec, G./Gref,'ro-')
set(gca,'XScale','log')
set(gca,'YScale','log')
title('Comparison')
xlabel('Distance from target [m]')
ylabel('G_{adim} [-]')
legend('Phase law model','Rendering')

subplot(1,2,2)
hold on, grid on
plot(d_body2cam_vec, 1e2*abs(G-Gcomp)./Gref,'bo-')
set(gca,'XScale','log')
set(gca,'YScale','log')
ylabel('Relative Error [%]')
xlabel('Distance from target [m]')

figure('Name','validation_phase_law_distance_error')
subplot(1,2,1)
hold on, grid on
plot(d_body2cam_vec, 1e-3*abs(d_body2cam_vec-d_body2cam_inv),'bo-')
set(gca,'XScale','log')
set(gca,'YScale','log')
ylabel('Absolute Error [km]')
xlabel('Distance from target [m]')

subplot(1,2,2)
hold on, grid on
plot(d_body2cam_vec, 1e2*abs(d_body2cam_vec-d_body2cam_inv)./d_body2cam_vec,'bo-')
set(gca,'XScale','log')
set(gca,'YScale','log')
ylabel('Relative error [%]')
xlabel('Distance from target [m]')