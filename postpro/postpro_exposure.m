tExp_vec = tExp*logspace(-1, 2, 40);
flag_create_gif = true;
gif_filename = 'saturation.gif';

%%
image_depth = round(log2(G_AD*fwc + 1));
[x_pixel, y_pixel] = meshgrid([1:res_px], [1:res_px]);
% Maximum exposure time to avoid saturation
tSat_pixel = fwc./ECR_pixel;
tSat_pixel(tSat_pixel == inf) = nan;

%%
figure('units','normalized','Position',[0.1 0.2 0.7 0.7])
ax1 = subplot(1,2,1);
grid on, hold on
colormap('gray')
colorbar
clim([0, 2^image_depth-1])
xlabel('u [px]')
ylabel('v [px]')
title([num2str(image_depth),'-bit Image [DN]']);
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
    EC_img_plot = ECR_pixel*tExp_plot;
    IMG_plot = analog2digital(EC_img_plot, G_AD, image_depth, image_depth);

    tSat_segmentation_mask = tSat_pixel;
    tSat_segmentation_mask(tExp_plot >= tSat_pixel) = 1;
    tSat_segmentation_mask(tExp_plot < tSat_pixel) = 0;
    tSat_segmentation_mask(isnan(tSat_pixel)) = -1;

    % Digital image
    subplot(ax1)
    i = imshow(IMG_plot);

    % Segmentation
    s = surf(ax2, x_pixel, y_pixel, tSat_segmentation_mask, 'EdgeColor','none');
    
    pause(0.1)
    if flag_create_gif
        gif
    end

    if ix~=length(tExp_vec)
    delete(s)
    delete(i)
    end
end
