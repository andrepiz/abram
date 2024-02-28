[x_pixel, y_pixel] = meshgrid([1:res_px], [1:res_px]);

% Active pixels mask
mask_pxActive = EC_img ~= 0;
% Maximum exposure time to avoid saturation
EC_img_temp = EC_img;
EC_img_temp(EC_img == 0) = nan;
tSat_pixel = fwc./EC_img_temp;

% Get exposure time from user
disp(['--- Total count rate of electrons [millions per second]: ', num2str(1e-6*sum(EC_img,"all"))])
tExp_default = tExp;
tExp = 1e-3*input(['input exposure time [ms] (press any key for default value of ',num2str(1e3*tExp_default),' ms) : ']);
if isempty(tExp)
    tExp = tExp_default;
end
disp(['--> Total count of electrons [millions]: ', num2str(1e-6*tExp*sum(EC_img,"all"))])

EC_img_plot = mat2image(sum(ECR_pixel_bw*tExp, 3));
IMG_plot = analog2digital(EC_img_plot, G_AD, G_AD_nbit, G_AD_nbit);

% Exposure time before saturation
tSat_pixel_max = max(tSat_pixel(mask_pxActive), [],'all');
tSat_pixel_mean = mean(tSat_pixel(mask_pxActive), 'all');
tSat_pixel_median = median(tSat_pixel(mask_pxActive), 'all');
[tSat_ecdf, tSat_t] = ecdf(tSat_pixel(mask_pxActive));
figure()
grid on, hold on
plot(1e3*tSat_t, 1e2*tSat_ecdf,'LineWidth',2)
set(gca, 'XScale','Log')
xline(1e3*tExp,'k--','LineWidth',2)
xlabel('Time [ms]')
ylabel('Cumulative Active Saturated Pixels [%]')
legend('Exposure time before saturation','Exposure time used')

% Saturation time per pixel
figure()
grid on, hold on
surf(x_pixel, y_pixel, tSat_pixel*1e3, 'EdgeColor','none')
set(gca,'ColorScale','log')
set(gca,'YDir','reverse')
timeSatMin = min(tSat_pixel(tSat_pixel~=0),[],'all');
timeSatMax = max(tSat_pixel,[],'all');
colormap('parula')
col = colorbar;
col.Ticks = 1e3*logspace(log10(timeSatMin), log10(timeSatMax),10);
clim(1e3*[timeSatMin, timeSatMax])
xlabel('u [px]')
ylabel('v [px]')
title('Saturation time per pixel [ms]');
pbaspect([1, 1, 10])
xlim([0 res_px])
ylim([0 res_px])

% Segmentation
figure()
grid on, hold on
tSat_segmentation_mask = tSat_pixel;
tSat_segmentation_mask(tExp < tSat_segmentation_mask) = 1;
tSat_segmentation_mask(tExp >= tSat_segmentation_mask) = 2;
tSat_segmentation_mask(isnan(tSat_pixel)) = 0;
surf(x_pixel, y_pixel, tSat_segmentation_mask, 'EdgeColor','none')
set(gca,'YDir','reverse')
colormap('parula')
col = colorbar;
col.Ticks = [0 1 2];
col.TickLabels = {'Not Active','Not Saturated','Saturated'};
xlabel('u [px]')
ylabel('v [px]')
title('Pixel saturated Y/N [-]');
pbaspect([1, 1, 10])
xlim([0 res_px])
ylim([0 res_px])


% Digital image
figure()
grid on, hold on
imshow(IMG_plot)
colormap('gray')
colorbar
clim([0, 2^G_AD_nbit-1])
xlabel('u [px]')
ylabel('v [px]')
title([num2str(G_AD_nbit),'-bit Image [DN]']);
pbaspect([1, 1, 10])
xlim([0 res_px]) 
ylim([0 res_px])
