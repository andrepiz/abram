%% IMAGE loading
IMG_real = imread(image_filepath_real);
nbit_real = 8;
IMG_real_cropped = IMG_real(1:res_px, size(IMG_real, 2)/2-res_px/2+1:size(IMG_real, 2)/2+res_px/2);
IMG_real_modified = IMG_real_cropped;

%% IMAGES
[x_pixel, y_pixel] = meshgrid([1:res_px], [1:res_px]);

figure(), grid on, hold on

subplot(1,2,1)
imshow(IMG_real_modified)
c1 = colorbar;
clim([0, 2^nbit_real-1])
xlabel('u [px]')
ylabel('v [px]')
c1.Label.String = 'DN';
title([num2str(nbit_real),'-bit Image [DN]']);
title('Image Real [DN]');

subplot(1,2,2)
imshow(IMG)
c2 = colorbar;
clim([0, 2^image_depth-1])
xlabel('u [px]')
ylabel('v [px]')
c2.Label.String = 'DN';
title([num2str(image_depth),'-bit Image [DN]']);
title('Image ABRAM [DN]');

%% Superimposed
% figure(), grid on, hold on
% 
% imshow(IMG_real_modified)
% hold on
% c = colorbar;
% clim([0, 2^nbit_real-1])
% xlabel('u [px]')
% ylabel('v [px]')
% c.Label.String = 'DN';
% 
% IMG_binarized = IMG;
% IMG_binarized(IMG_binarized > 1) = 255;
% IMG_binarized_rgb = cat(3, IMG_binarized, IMG_binarized*0, IMG_binarized*0);
% im_temp = imshow(IMG_binarized_rgb);
% im_temp.AlphaData = 0.3;
% title([num2str(image_depth),'-bit Image [DN]']);
% title('Mask of ABRAM image superimposed on real image [DN]');
IMG_uint8 = digital2digital(IMG, 16, 8);
noise_level = 10;
ssim_comparison(IMG_real_modified, IMG_uint8, noise_level, true, true)
