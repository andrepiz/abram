[x_pixel, y_pixel] = meshgrid([1:res_px], [1:res_px]);

flag_create_gif = false;

tExp_vec = 1e-3*logspace(-5, -1, 40);
ECR_img = mat2image(sum(ECR_pixel_bw, 3));
% Maximum exposure time to avoid saturation
ECR_img_temp = ECR_img;
ECR_img_temp(ECR_img_temp == 0) = nan;
tSat_img = fwc./ECR_img_temp;

figure('units','normalized','Position',[0.1 0.2 0.7 0.7])

ax1 = subplot(1,2,1);
grid on, hold on
colormap('gray')
colorbar
clim([0, 2^G_AD_nbit-1])
xlabel('u [px]')
ylabel('v [px]')
title([num2str(G_AD_nbit),'-bit Image [DN]']);
pbaspect([1, 1, 10])
xlim([0 res_px]) 
ylim([0 res_px])

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
xlim([0 res_px])
ylim([0 res_px])

if flag_create_gif
    gif('test.gif')
end

for ix = 1:length(tExp_vec)

    tExp = tExp_vec(ix);

    sgtitle(['Exposure time: ', num2str(round(tExp*1e3, 7)),'ms'])
    EC_img_plot = ECR_img*tExp;
    IMG_plot = analog2digital(EC_img_plot, G_AD, G_AD_nbit, G_AD_nbit);

    tSat_segmentation_mask = tSat_img;
    tSat_segmentation_mask(tExp >= tSat_img) = 1;
    tSat_segmentation_mask(tExp < tSat_img) = 0;
    tSat_segmentation_mask(isnan(tSat_img)) = -1;

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
