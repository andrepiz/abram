nbit_real = 8;
IMG_real = imread(image_filepath_real);
IMG_render = digital2digital(img, saving_depth, nbit_real);

%% SSIM
if flag_ssim
    ssim_comparison(IMG_real, IMG_render, noise_level, flag_apply_ncc, true, 2^8-1, flip(colormap('sky'),1))
end

%% IMAGES
[x_pixel, y_pixel] = meshgrid([1:res_px], [1:res_px]);

f1 = figure(); grid on, hold on

subplot(1,2,1)
imshow(IMG_real);
hold on
colormap(f1, 'gray')
c1 = colorbar();
clim([0, 2^nbit_real-1])
xlabel('u [px]')
ylabel('v [px]')
c1.Label.String = 'DN';
title([num2str(nbit_real),'-bit Image [DN]']);
title('Image Real [DN]');
hold off

subplot(1,2,2)
imshow(IMG_render);
hold on
colormap(f1, 'gray')
c1 = colorbar();
clim([0, 2^nbit_real-1])
xlabel('u [px]')
ylabel('v [px]')
c2.Label.String = 'DN';
title([num2str(saving_depth),'-bit Image [DN]']);
title('Image ABRAM [DN]');
hold off 

