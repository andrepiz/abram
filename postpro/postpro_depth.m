img_depth = rend.depth.values;
res_px = rend.camera.res_px;

% Digital image
figure()
grid on, hold on
imagesc(img_depth)
colormap('jet')
colorbar();
xlabel('u [px]')
ylabel('v [px]')
title('Depth Image [Body Radii]');
pbaspect([1, 1, 10])
xlim([0 res_px(1)]) 
ylim([0 res_px(2)])