ecr = rend.ecr;
G_AD = rend.camera.G_AD;
tSat_pixel = rend.camera.fwc./rend.ecr;
tExp_vec = rend.camera.tExp*logspace(-1, 2, 40);

flag_create_gif = true;
gif_filename = 'gif_increasing_exposure.gif';

%%
[x_pixel, y_pixel] = meshgrid([1:res_px(1)], [1:res_px(2)]);
% Maximum exposure time to avoid saturation
tSat_pixel(tSat_pixel == inf) = nan;

%%
figure('units','normalized','Position',[0.1 0.2 0.7 0.7])
ax1 = subplot(1,2,1);
grid on, hold on
colormap('gray')
colorbar
clim([0, 2^rend.setting.saving.depth-1])
xlabel('u [px]')
ylabel('v [px]')
title([num2str(rend.setting.saving.depth),'-bit Image [DN]']);
pbaspect([1, 1, 10])
xlim([0 res_px(1)]) 
ylim([0 res_px(2)])

ax2 = subplot(1,2,2);
grid on, hold on
set(gca,'YDir','reverse')
colormap('parula')
col = colorbar;
col.Ticks = [-1 0 1];
col.TickLabels = {'Not Active','Correctly Exposed','Saturated'};
xlabel('u [px]')
ylabel('v [px]')
title('Pixel saturated Y/N [-]');
pbaspect([1, 1, 10])
xlim([0 res_px(1)])
ylim([0 res_px(2)])

if flag_create_gif
    gif(gif_filename)
end

for ix = 1:length(tExp_vec)

    tExp_plot = tExp_vec(ix);

    sgtitle(['Exposure time: ', num2str(round(tExp_plot*1e3, 7)),'ms'])
    ec_plot = ecr*tExp_plot;
    img_plot = analog2digital(ec_plot, G_AD, rend.setting.saving.depth, rend.setting.saving.depth);

    tSat_segmentation_mask = tSat_pixel;
    tSat_segmentation_mask(tExp_plot >= tSat_pixel) = 1;
    tSat_segmentation_mask(tExp_plot < tSat_pixel) = 0;
    tSat_segmentation_mask(isnan(tSat_pixel)) = -1;

    % Digital image
    subplot(ax1)
    i = imshow(img_plot);

    % Segmentation
    s = surf(ax2, x_pixel, y_pixel, tSat_segmentation_mask, 'EdgeColor','none');
    clim(ax2, [-1 1])

    pause(0.1)
    if flag_create_gif
        gif
    end

    if ix~=length(tExp_vec)
    delete(s)
    delete(i)
    end
end
