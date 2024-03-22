%% extract useful parameters for post-processing 
label_temp = extractBetween(label, 'FOCAL_PLANE_TEMPERATURE        = ',' <K>');
Temp = str2double(label_temp{:});

label_temp = extractBetween(label, 'EXPOSURE_DURATION              = ',' <MS>');
tExp = 1e-3*str2double(label_temp{:});

label_temp = extractBetween(label, 'GAIN_NUMBER                    = ',' <E/DN>');
G_DA_real = str2double(label_temp{:});

%% correction of image with master frames
load(fullfile(amiextractor_path,'mf\mfbias.mat'))
load(fullfile(amiextractor_path,'mf\mfdc.mat'))

nfilter = 3;

img_corr = mf2imgcorr(nfilter, mfbias, mfdc, tExp, Temp);
img_real_corrected = img_real - img_corr;
img_real_corrected(img_real_corrected < 0) = 0;

%% EC computation
EC_real = img_real*G_DA_real;
EC_real_corrected = img_real_corrected*G_DA_real;

%% Plot

[x_pixel, y_pixel] = meshgrid([1:res_px], [1:res_px]);

fh = figure('Units','normalized','Position',[0.1 0.1 0.8 0.7]); 

clims = [min(EC_real,[],'all'), max(EC_real,[],'all')];


subplot(1,3,1)
grid on, hold on
surf(x_pixel, y_pixel, EC_real, 'EdgeColor','none')
set(gca,'YDir','reverse')
colormap('parula')
colorbar
clim(clims)
xlabel('u [px]')
ylabel('v [px]')
xlim([0, res_px])
ylim([0, res_px])
pbaspect([1, 1, 10])
title(['AMIE Electron Count, t_{exp} = ', num2str(1e3*tExp),' ms'])

subplot(1,3,2)
grid on, hold on
surf(x_pixel, y_pixel, EC_img, 'EdgeColor','none')
set(gca,'YDir','reverse')
colormap('parula')
colorbar
clim(clims)
xlabel('u [px]')
ylabel('v [px]')
xlim([0, res_px])
ylim([0, res_px])
pbaspect([1, 1, 10])
title(['ABRAM Electron Count, t_{exp} = ', num2str(1e3*tExp),' ms'])

subplot(1,3,3)
grid on, hold on
surf(x_pixel, y_pixel, EC_real_corrected, 'EdgeColor','none')
set(gca,'YDir','reverse')
colormap('parula')
colorbar
clim(clims)
xlabel('u [px]')
ylabel('v [px]')
xlim([0, res_px])
ylim([0, res_px])
pbaspect([1, 1, 10])
title(['Dark-corrected AMIE Electron Count, t_{exp} = ', num2str(1e3*tExp),' ms'])

%% Actual Images Comparison and diff
figure(), 
subplot(1,2,1)
imshow(IMG/(2^10-1))
title('ABRAM')

subplot(1,2,2)
imshow(img_real_corrected/(2^10-1))
title('AMIE')
