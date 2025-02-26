%%
cmap = 'turbo';

img_render_engine = imread(image_filepath_render_engine);
image_depth_render_engine = imfinfo(image_filepath_render_engine).BitDepth;
img_render_engine = double(img_render_engine)*(2^saving_depth-1)/(2^image_depth_render_engine-1);
imdiff = imabsdiff(img_render_engine, img);

%% POSTPRO
figure()
subplot(2,2,1)
imshow(img_render_engine)
clim([0, 2^saving_depth-1])
title('Render Engine')

subplot(2,2,2)
imshow(img)
clim([0, 2^saving_depth-1])
title('Ground Truth')

subplot(2,2,3)
grid on, hold on
scatter(reshape(img_render_engine,1,[]), reshape(img,1,[]));
plot([1:2^saving_depth],[1:2^saving_depth],'r--','LineWidth',2)
title('Pixel Intensity')
xlabel('Render Engine')
ylabel('Ground Truth')

subplot(2,2,4)
hold on, grid on
histogram(imdiff(:), [0:2^saving_depth-1], 'EdgeColor','none');
title('Absolute Image Difference')
xlabel('[DN]')
set(gca,'YScale','log')
xlim([0, 2^saving_depth-1])
ylabel('count')

figure()
imshow(imdiff)
colormap(cmap)
clim([0, 2^saving_depth-1])
cb = colorbar;
title('Absolute Image Difference')
ylabel(cb, '[DN]')

%% CALIBRATION COEFFICIENT
ec_render_engine = G_DA*img_render_engine;
scaling_coeff = sum(ec,'all')/sum(ec_render_engine,'all');
disp(['The total number of electrons expected is ', num2str(scaling_coeff), ' times the one rendered.'])
disp(['Please scale a parameter of the render engine accordingly (e.g. Sun strength in Blender).'])