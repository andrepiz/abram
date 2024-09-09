%% Plot
[x_pixel, y_pixel] = meshgrid([1:res_px], [1:res_px]);
clims = [min(EC_real,[],'all'), max(EC_real,[],'all')];

fh = figure('Units','normalized','Position',[0.1 0.1 0.8 0.7]); 
subplot(1,2,1)
grid on, hold on
surf(x_pixel, y_pixel, EC_real_corrected, 'EdgeColor','none')
set(gca,'YDir','reverse')
colormap('parula')
colorbar
clim(clims)
xlabel('u [px]')
ylabel('v [px]')
xlim([0, res_px(1)])
ylim([0, res_px(2)])
pbaspect([1, 1, 10])
title(['Dark-corrected AMIE Electron Count, t_{exp} = ', num2str(1e3*tExp),' ms'])

subplot(1,2,2)
grid on, hold on
surf(x_pixel, y_pixel, EC_pixel, 'EdgeColor','none')
set(gca,'YDir','reverse')
colormap('parula')
colorbar
clim(clims)
xlabel('u [px]')
ylabel('v [px]')
xlim([0, res_px(1)])
ylim([0, res_px(2)])
pbaspect([1, 1, 10])
title(['ABRAM Electron Count, t_{exp} = ', num2str(1e3*tExp),' ms'])

%% Actual Images Comparison and diff
figure(), 
subplot(1,2,1)
imshow(double(DN_pixel)/(2^image_depth-1))
title('ABRAM')

subplot(1,2,2)
imshow(img_real_corrected/(2^10-1))
title('AMIE')

figure()
imshow(bimg_real/(2^8-1))

figure(), grid on, hold on, 
histogram(DN_pixel(DN_pixel>0), 2^image_depth-1,'normalization','pdf', 'EdgeColor','none'), 
histogram(img_real_corrected(DN_pixel>0), 2^10-1,'normalization','pdf', 'EdgeColor','none')
legend('Model','Real')
title('PDF of illuminated pixels')

figure(), grid on, hold on, 
histogram(EC_pixel(DN_pixel>0), 200, 'normalization','cdf', 'EdgeColor','none'), 
histogram(EC_real_corrected(DN_pixel>0), 200, 'normalization','cdf', 'EdgeColor','none')
legend('ABRAM','Real')
title('CDF of illuminated pixels')

%% SSIM
noise_level = 57;
ssim_comparison(img_real_corrected, DN_pixel, noise_level, true, true);