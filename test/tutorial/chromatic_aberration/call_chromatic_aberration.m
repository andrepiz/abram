abram_install();

%% FLAGS

flag_planet = true;
flag_close_range = false;
flag_save = true;

%% INPUTS

if flag_planet
    filename_yml = 'chromatic_aberration.yml'; 
    rend = abram.render(filename_yml, false);
else
    filename_yml = 'sphere.yml'; 
    rend = abram.render(filename_yml, false);
end
rend.setting.saving.filename = [];

% Lower resolution to reduce computational burden
rend.camera.res_px = [500, 500];

% Reconstruction granularity must be set to 1 
rend.setting.reconstruction.granularity = 1;

%% LONGITUDINAL CHROMATIC ABERRATION

if flag_planet
    rend.scene.d_body2cam = 20*rend.body.radius;
    rend.scene.phase_angle = deg2rad(80);
    rend.scene.rpy_CAMI2CAM = [-0.005; 0; pi/2];
    rend.camera.tExp = 40e-4;
else
    rend.camera.tExp = 10e-3;
end

QEr.lambda_min = 581.5e-9;
QEr.lambda_max = 760e-9;
QEr.sampling = 'piecewise';
QEr.values = 0.7;
Tr = QEr;
Tr.values = 0.5*Tr.values;

QEg.lambda_min = 498.5e-9;
QEg.lambda_max = 581.5e-9;
QEg.sampling = 'piecewise';
QEg.values = 0.7;
Tg = QEg;
Tg.values = 1*Tg.values;

QEb.lambda_min = 380e-9;
QEb.lambda_max = 498.5e-9;
QEb.sampling = 'piecewise';
QEb.values = 0.7;
Tb = QEb;

% BLUE CHANNEL
rend.camera.QE = QEb;
rend.camera.T = Tb;
rend.setting.gridding.sigma = 2;
rend.setting.gridding.window = 4;
rend = rend.rendering();
imgb = rend.img;

% GREEN CHANNEL
rend.camera.QE = QEg;
rend.camera.T = Tg;
rend.setting.gridding.sigma = 1;
rend.setting.gridding.window = 2;
rend = rend.rendering();
imgg = rend.img;

% RED CHANNEL
rend.camera.QE = QEr;
rend.camera.T = Tr;
rend.setting.gridding.sigma = 3;
rend.setting.gridding.window = 6;
rend = rend.rendering();
imgr = rend.img;

bd = rend.setting.saving.depth;

imgrgb = uint8(255*cat(3, imgr./2^bd, imgg./2^bd, imgb./2^bd));
figure(), imshow(imgrgb)
if flag_save
    imwrite(imgrgb, 'chromatic_aberration_longitudinal.png')
end

%% LATERAL CHROMATIC ABERRATION

if flag_planet
    if flag_close_range
    rend.camera.tExp = 10e-4;
    rend.scene.phase_angle = -deg2rad(30);
    rend.scene.rpy_CAMI2CAM = [-0.015; -0.02; pi/5];
    rend.scene.d_body2cam = 30*rend.body.radius;
    % rend.scene.phase_angle = deg2rad(70);
    % rend.scene.rpy_CSF2IAU = [0; pi/2; -rend.scene.phase_angle];
    % rend.scene.rpy_CAMI2CAM = [0.005; -0.005; pi/6];
    % rend.scene.d_body2cam = 40*rend.body.radius;
    rend.setting.gridding.sigma = 1;
    rend.setting.gridding.window = 2;
    dist_max = 400;
    else
    rend.camera.tExp = 15e-4;
    rend.scene.phase_angle = deg2rad(95);
    rend.scene.rpy_CAMI2CAM = [-0.0005; 0.01; pi/2];
    rend.scene.rpy_CSF2IAU = [0.0; 0.00; 0];
    rend.scene.d_body2cam = 70*rend.body.radius;
    rend.setting.gridding.sigma = 1;
    rend.setting.gridding.window = 2;
    dist_max = 700;
    end
else
    rend.camera.tExp = 0.8e-4;
    rend.scene.phase_angle = deg2rad(120);
    rend.scene.rpy_CAMI2CAM = [0.004; -0.004; pi];
    rend.scene.d_body2cam = 70*rend.body.radius;
    rend.setting.gridding.sigma = 1;
    rend.setting.gridding.window = 2;
end

nl = 4;
lambdaB_vec = linspace(581.5e-9, 760e-9, nl+1);
lambdaG_vec = linspace(498.5e-9, 581e-9, nl+1);
lambdaR_vec = linspace(380e-9, 498.5e-9, nl+1);
kdist = 1;
dist_vec = 0 + dist_max*linspace(0, 1, 3*nl).^kdist;

c = 0;

imgb = 0;
for ix = 1:nl

    c = c + 1;

    QEtemp.sampling = 'piecewise';
    QEtemp.values = 1;
    QEtemp.lambda_min = lambdaB_vec(ix);
    QEtemp.lambda_max = lambdaB_vec(ix+1);
    Ttemp = QEtemp;

    rend.camera.QE = QEtemp;
    rend.camera.T = Ttemp;
    rend.camera.distortion.radial = dist_vec(c)
    rend = rend.rendering();
    imgb = imgb + rend.img;
end

imgg = 0;
for ix = 1:nl

    c = c + 1;

    QEtemp.sampling = 'piecewise';
    QEtemp.values = 1;
    QEtemp.lambda_min = lambdaG_vec(ix);
    QEtemp.lambda_max = lambdaG_vec(ix+1);
    Ttemp = QEtemp;

    rend.camera.QE = QEtemp;
    rend.camera.T = Ttemp;
    rend.camera.distortion.radial = dist_vec(c)
    rend = rend.rendering();
    imgg = imgg + rend.img;
end

imgr = 0;
for ix = 1:nl

    c = c + 1;

    QEtemp.sampling = 'piecewise';
    QEtemp.values = 1;
    QEtemp.lambda_min = lambdaR_vec(ix);
    QEtemp.lambda_max = lambdaR_vec(ix+1);
    Ttemp = QEtemp;

    rend.camera.QE = QEtemp;
    rend.camera.T = Ttemp;
    rend.camera.distortion.radial = dist_vec(c)
    rend = rend.rendering();
    imgr = imgr + rend.img;
end

%
bd = rend.setting.saving.depth;

figure(), 
subplot(1,3,1)
imshow(digital2digital(imgr,  bd, 8))
title('Red channel')
subplot(1,3,2)
imshow(digital2digital(imgg,  bd, 8))
title('Green channel')
subplot(1,3,3)
imshow(digital2digital(imgb,  bd, 8));
title('Blue channel')

imgrgb = uint8(255*cat(3, imgr./max(imgr(:)), imgg./max(imgg(:)), imgb./max(imgb(:))));
figure(), imshow(imgrgb)

if flag_save
    imwrite(imgrgb, 'chromatic_aberration_lateral.png')
end

%% LONGITUDINAL & LATERAL

beta = 3*pi/2;
rend.camera.tExp = 100e-4;
rend.scene.phase_angle = deg2rad(85);
rend.scene.rpy_CAMI2CAM = [0.00; 0.00; -pi/2+beta];
rend.scene.rpy_CSF2IAU = [rend.scene.phase_angle; -beta; 0];
rend.scene.d_body2cam = 62*rend.body.radius;
dist_max = 700;

nl = 4;
lambdaB_vec = linspace(581.5e-9, 760e-9, nl+1);
lambdaG_vec = linspace(498.5e-9, 581e-9, nl+1);
lambdaR_vec = linspace(380e-9, 498.5e-9, nl+1);
kdist = 1;
dist_vec = 0 + dist_max*linspace(0, 1, 3*nl).^kdist;

c = 0;

imgb = 0;
for ix = 1:nl

    c = c + 1;

    QEtemp.sampling = 'piecewise';
    QEtemp.values = 0.55;
    QEtemp.lambda_min = lambdaB_vec(ix);
    QEtemp.lambda_max = lambdaB_vec(ix+1);
    Ttemp = QEtemp;

    rend.setting.gridding.sigma = 2;
    rend.setting.gridding.window = 4;

    rend.camera.QE = QEtemp;
    rend.camera.T = Ttemp;
    rend.camera.distortion.radial = dist_vec(c)
    rend = rend.rendering();
    imgb = imgb + rend.img;
end

imgg = 0;
for ix = 1:nl

    c = c + 1;

    QEtemp.sampling = 'piecewise';
    QEtemp.values = 0.75;
    QEtemp.lambda_min = lambdaG_vec(ix);
    QEtemp.lambda_max = lambdaG_vec(ix+1);
    Ttemp = QEtemp;

    rend.setting.gridding.sigma = 1;
    rend.setting.gridding.window = 2;

    rend.camera.QE = QEtemp;
    rend.camera.T = Ttemp;
    rend.camera.distortion.radial = dist_vec(c)
    rend = rend.rendering();
    imgg = imgg + rend.img;
end

imgr = 0;
for ix = 1:nl

    c = c + 1;

    QEtemp.sampling = 'piecewise';
    QEtemp.values = 0.8;
    QEtemp.lambda_min = lambdaR_vec(ix);
    QEtemp.lambda_max = lambdaR_vec(ix+1);
    Ttemp = QEtemp;

    rend.setting.gridding.sigma = 3;
    rend.setting.gridding.window = 6;

    rend.camera.QE = QEtemp;
    rend.camera.T = Ttemp;
    rend.camera.distortion.radial = dist_vec(c)
    rend = rend.rendering();
    imgr = imgr + rend.img;
end

%
bd = rend.setting.saving.depth;

figure(), 
subplot(1,3,1)
imshow(digital2digital(imgr,  bd, 8))
title('Red channel')
subplot(1,3,2)
imshow(digital2digital(imgg,  bd, 8))
title('Green channel')
subplot(1,3,3)
imshow(digital2digital(imgb,  bd, 8));
title('Blue channel')

imgrgb = uint8(255*cat(3, imgr./2^bd, imgg./2^bd, imgb./2^bd));
figure(), imshow(imgrgb)

if flag_save
    imwrite(imgrgb, 'chromatic_aberration_longitudinal_and_lateral.png')
end
