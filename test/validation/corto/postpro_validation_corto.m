[x_pixel, y_pixel] = meshgrid([1:res_px], [1:res_px]);

img_corto = imread(image_filepath_corto);
img_abram = digital2digital(img, saving_depth, saving_depth);

%% Plot
figure(), 
subplot(1,2,1)
imshow(img_abram)
title('ABRAM')

subplot(1,2,2)
imshow(img_corto)
title('CORTO')

%%
figure(), grid on, hold on, 
histogram(img_abram(:)), 
histogram(img_corto(:))
legend('Model','Real')

%%
[img_diff_normalized_corto_analytical, img_diff_corto_analytical, ...
err_diff_normalized_corto_analytical, err_diff_corto_analytical] = ...
    diff_images(img_corto, img_abram);

cmap = colormap('gray');
cmap(1,:) = [0, 1, 0];

figure()
imshow(img_diff_corto_analytical, [0, max(img_diff_corto_analytical,[],'all')])
colormap(cmap)
cb = colorbar;
title('Diff Images Corto-Analytical')
ylabel(cb, '[DN]')

figure()
grid on, hold on
scatter(reshape(img_corto,[],res_px(1)*res_px(2)), ...
    reshape(img_abram,[],res_px(1)*res_px(2)))
plot([1:2^saving_depth],[1:2^saving_depth],'r--')
title('Scatter plot intensity')
xlabel('Corto')
ylabel('Analytical')

% Histogram
nh2 = 2^saving_depth;

figure()
hold on, grid on
histogram(img_diff_corto_analytical(:), nh2,'EdgeColor','none');
title('Diff Images Corto-Analytical')
xlabel('[DN]')
set(gca,'YScale','log')
xlim([0, 2^saving_depth])
ylabel('count')