%% Plot Comparison
[x_pixel, y_pixel] = meshgrid([1:res_px(1)], [1:res_px(2)]);

ix_bw = 1;
cmax = max(max(P_bw(:,:,ix_bw),[],'all'), max(P_bw_comp(:,:,ix_bw),[],'all'));

figure()
subplot(1,2,1)
grid on, hold on
surf(x_pixel, y_pixel, P_bw(:,:,ix_bw), 'EdgeColor','none')
set(gca,'YDir','reverse')
xlabel('u [px]')
ylabel('v [px]')
title('Power from rendering [W]');
pbaspect([1, 1, 10])
xlim([0 res_px(1)])
ylim([0 res_px(2)])
clim([0, cmax])
colorbar

subplot(1,2,2)
grid on, hold on
surf(x_pixel, y_pixel, P_bw_comp(:,:,ix_bw), 'EdgeColor','none')
set(gca,'YDir','reverse')
xlabel('u [px]')
ylabel('v [px]')
title('Power from model [W]');
pbaspect([1, 1, 10])
xlim([0 res_px(1)])
ylim([0 res_px(2)])
clim([0, cmax])
colorbar

% Radiant flux density
cmax = cmax./Apupil;

figure()
subplot(1,2,1)
grid on, hold on
surf(x_pixel, y_pixel, P_bw(:,:,ix_bw)./Apupil, 'EdgeColor','none')
set(gca,'YDir','reverse')
xlabel('u [px]')
ylabel('v [px]')
title('Radiant Flux Density from rendering [W/m2]');
pbaspect([1, 1, 10])
xlim([0 res_px(1)])
ylim([0 res_px(2)])
clim([0, cmax])
colorbar

subplot(1,2,2)
grid on, hold on
surf(x_pixel, y_pixel, P_bw_comp(:,:,ix_bw)./Apupil, 'EdgeColor','none')
set(gca,'YDir','reverse')
xlabel('u [px]')
ylabel('v [px]')
title('Radiant Flux Density from model [W/m2]');
pbaspect([1, 1, 10])
xlim([0 res_px(1)])
ylim([0 res_px(2)])
clim([0, cmax])
colorbar

%% Histogram
nh1 = 100;
nh2 = 100;

hdata_abram = P_bw(:,:,ix_bw);
hdata_analytical = P_bw_comp(:,:,ix_bw);

figure()
hold on, grid on
histogram(hdata_abram(:), nh1);
histogram(hdata_analytical(:), nh2);
legend('ABRAM','Analytical')
xlabel('[W]')
ylabel('count')

%% RELATIVE ERROR
figure()
grid on, hold on
surf(x_pixel, y_pixel, 1e2*abs(P_bw-P_bw_comp)./mean(P_bw_comp(:),'omitnan'), 'EdgeColor','none')
set(gca,'YDir','reverse')
xlabel('u [px]')
ylabel('v [px]')
title('Error Relative to Mean [%]');
pbaspect([1, 1, 10])
xlim([0 res_px(1)])
ylim([0 res_px(2)])
colorbar

P_bw_diff = sum(abs(P_bw-P_bw_comp),'all','omitnan');
relerr = sum(P_bw_diff(:),'omitnan')./sum(P_bw_comp(:),'omitnan');
disp(['Relative error: ', num2str(1e2*relerr), '%'])
