% Digital image
figure()
grid on, hold on
imshow(IMG)
colormap('gray')
colorbar
clim([0, 2^saving_depth-1])
xlabel('u [px]')
ylabel('v [px]')
title([num2str(saving_depth),'-bit Image [DN]']);
pbaspect([1, 1, 10])
xlim([0 res_px(1)]) 
ylim([0 res_px(2)])