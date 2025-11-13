img = rend.img;
res_px = rend.camera.res_px;

% Digital image
figure()
grid on, hold on
imshow(img)
colormap('gray')
colorbar
clim([0, 2^rend.setting.saving.depth-1])
xlabel('u [px]')
ylabel('v [px]')
title([num2str(rend.setting.saving.depth),'-bit Image [DN]']);
pbaspect([1, 1, 10])
xlim([0 res_px(1)]) 
ylim([0 res_px(2)])