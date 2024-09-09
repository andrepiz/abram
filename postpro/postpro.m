[x_pixel, y_pixel] = meshgrid([1:res_px(1)], [1:res_px(2)]);

% Maximum exposure time to avoid saturation
tSat_pixel = fwc./ECR_pixel;
tSat_pixel(tSat_pixel == inf) = nan;

% Digital image
figure()
grid on, hold on
imshow(DN_pixel)
colormap('gray')
colorbar
clim([0, 2^image_depth-1])
xlabel('u [px]')
ylabel('v [px]')
title([num2str(image_depth),'-bit Image [DN]']);
pbaspect([1, 1, 10])
xlim([0 res_px(1)]) 
ylim([0 res_px(2)])

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
xlim([0 res_px(1)]) 
ylim([0 res_px(2)])

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
xlim([0 res_px(1)]) 
ylim([0 res_px(2)])

% Exposure time before saturation
mask_pxActive = ECR_pixel ~= 0; % Active pixels mask
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

%% SAVE IMAGE
image_savename = [image_filename,'.',image_format];
image_label = 1;
while isfile(image_savename)
    image_savename = [image_filename, num2str(image_label),'.',image_format];
    if isempty(image_label)
        image_label = 1;
    end
    image_label = image_label + 1;
end
imwrite(IMG, image_savename)