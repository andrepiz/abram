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