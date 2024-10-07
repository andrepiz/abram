%%
cmap = 'turbo';

IMG_render_engine = imread(image_filepath_render_engine);
image_depth_render_engine = imfinfo(image_filepath_render_engine).BitDepth;
IMG_render_engine = double(IMG_render_engine)*(2^image_depth-1)/(2^image_depth_render_engine-1);
IMG_abram = double(DN_pixel);
imdiff = imabsdiff(IMG_render_engine, IMG_abram);

%% POSTPRO
figure()
subplot(2,2,1)
imshow(IMG_render_engine)
clim([0, 2^image_depth-1])
title('Render Engine')

subplot(2,2,2)
imshow(IMG_abram)
clim([0, 2^image_depth-1])
title('Ground Truth')

subplot(2,2,3)
grid on, hold on
scatter(reshape(IMG_render_engine,1,[]), reshape(IMG_abram,1,[]));
plot([1:2^image_depth],[1:2^image_depth],'r--','LineWidth',2)
title('Pixel Intensity')
xlabel('Render Engine')
ylabel('Ground Truth')

subplot(2,2,4)
hold on, grid on
histogram(imdiff(:), [0:2^image_depth-1], 'EdgeColor','none');
title('Absolute Image Difference')
xlabel('[DN]')
set(gca,'YScale','log')
xlim([0, 2^image_depth-1])
ylabel('count')

figure()
imshow(imdiff)
colormap(cmap)
clim([0, 2^image_depth-1])
cb = colorbar;
title('Absolute Image Difference')
ylabel(cb, '[DN]')

%% CALIBRATION COEFFICIENT
EC_render_engine = G_DA*IMG_render_engine;
scaling_coeff = sum(EC_pixel,'all')/sum(EC_render_engine,'all');
disp(['The total number of electrons expected is ', num2str(scaling_coeff), ' times the one rendered.'])
disp(['Please scale a parameter of the render engine accordingly (e.g. Sun strength in Blender).'])