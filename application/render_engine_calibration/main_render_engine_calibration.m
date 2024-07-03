%% RADIOMETRIC CALIBRATION OF RENDER ENGINES
% Render a 1m-radius, 0.1 albedo, Lambertian sphere placed at 1 AU of distance from the 
% Sun and 8 m of distance from the camera at different phase angles.
% Then perform the calibration comparing the electron count of
% ABRAM vs the one expected by the image.
% Note that the calibration has to be performed every time the camera changes
% in terms of parameters that the render engine does not model (e.g. the
% pupil diameter or the quantum efficiency in Blender)

% Install tools
abram_install()

%% RENDER ENGINE

render_engine_imgpath = 'starnav_HIL_sphere_008ms_16bit\img\000001.png';
IMG_render_engine = imread(render_engine_imgpath);

tExp = 0.08e-3;
alpha = 0;
d_body2sc = 8;

%% ABRAM
inputs_render_engine_calibration();
run_model();

%% POSTPRO
figure()
subplot(2,3,1)
imshow(IMG_render_engine)
title('Render Engine')

subplot(2,3,2)
imshow(IMG)
title('ABRAM')

subplot(2,3,4)
grid on, hold on
scatter(reshape(IMG_render_engine,[],res_px^2), ...
    reshape(IMG,[],res_px^2))
plot([1:2^G_DA_nbit],[1:2^G_DA_nbit],'r--')
title('Scatter plot intensity')
xlabel('Render Engine')
ylabel('ABRAM')

imdiff = imabsdiff(IMG_render_engine, IMG);

subplot(2,3,5)
imshow(imdiff)
colormap('parula')
clim([0, 2^G_DA_nbit-1])
cb = colorbar;
title('ImAbsDiff')
ylabel(cb, '[DN]')

nh1 = 4;
nh2 = 100;
subplot(2,3,[3 6])
hold on, grid on
histogram(imdiff(:), 2^G_DA_nbit-1);
title('ImAbsDiff')
xlabel('[DN]')
set(gca,'YScale','log')
xlim([0, 2^G_DA_nbit-1])
ylabel('count')

%% CALIBRATION COEFFICIENT
EC_img_render_engine = G_DA*IMG_render_engine;
scaling_coeff = sum(EC_img,'all')/sum(EC_img_render_engine,'all');
disp(['The total number of electrons expected is ', num2str(scaling_coeff), ' times the one rendered.'])
disp(['Please scale a parameter of the render engine accordingly (e.g. Sun strength in Blender).'])