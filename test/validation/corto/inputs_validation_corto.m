%% STAR 
Tstar = 5782;     % [K]
Rstar = 695000e3; % [m]

%% BODY
radiometry_model = 'lambert';
Rbody = 1.7374e6; % [m] body radius
albedo = 0.18; % [-] albedo
albedo_type = 'bond';
albedo_filename = 'lroc_color_poles_2k.tif';
albedo_depth = 8;
albedo_mean = 0.18;
if flag_displacement
    displacement_filename = 'ldem_4.tif';
    displacement_depth = 1;
    displacement_scale = 1000;
end
if flag_normal
    normal_filename = 'lnormal_4.png';
    normal_depth = 16;
end

%% CAMERA  
tExp = 0.015e-3;
lambda_min = (425:50:975)*1e-9;
lambda_max = (475:50:1025)*1e-9;
nbw = length(lambda_min); % number of bandwidths
T = [0.410, 0.687, 0.915, 0.954, 0.967, 0.977, 0.979, 0.982, 0.984, 0.987, 0.989, 0.992]; % Lens transmittance per BW
QE = [0.35, 0.43, 0.46, 0.45, 0.42, 0.37, 0.30, 0.23, 0.16, 0.09, 0.04, 0.02]; % Quantum Efficiency per BW
fwc = 100e3; % [e-] from https://upverter.com/datasheet/1dbf6474f4834c5ac73294b488ac44ae8ac1f8ca.pdf 
f = 50.7e-3;
dpupil = 33.9e-3;
fNum = f/dpupil;
muPixel = 18e-6; % [m] pixel size
res_px = 1024; % [px] Resolution in pixel
fov = 2*atan((res_px*muPixel/2)/f); % focal length
fov_shape = 'circle';
image_depth = 16;
G_AD = (2^image_depth-1)/fwc;

%% SCENARIO
% Lumio trajectory from Corto inputs 
switch flag_scenario
    case 1
        inputs_corto = [0 0 0 0 1 0 0 0 -32.264191721 -17.750344807 24.851316611 0.671986 0.409186 -0.15516 -0.597434 73851.064541941 -129877.91788227 3112.940542782];
    case 2
        inputs_corto = [99000 0 0 0 1 0 0 0 -33.468792237 -41.159669801 11.866820706 -0.180603 -0.485102 -0.382835 0.765177 40346.992979572 -143820.646844016 3155.862765357];
    case 3
        inputs_corto = [259200 0 0 0 1 0 0 0 -45.174965796 -52.774718132 -17.3767064 0.506134 0.761711 -0.049207 -0.401502 -18003.387576574 -148222.629718458 3212.749117793];
end
[alpha, d_body2cam, d_body2star, q_CSF2IAU, q_CAMI2CAM] = inputs_corto2matlab(inputs_corto, 1e6, false);
    % post-process
    dcm_CAMI2CAM = quat_to_dcm(q_CAMI2CAM);
    dcm_CSF2IAU = quat_to_dcm(q_CSF2IAU);

%% PARAMETERS
% Select parameters
general_environment = 'matlab';
general_parallelization = true;
general_workers = 6;
discretization_method = 'constant';
discretization_np = 4e5;            % number of total pixel sectors on sphere
sampling_method = 'projecteduniform'; % 'projective' sampling of longitude and latitude points that are approximately spread uniformly on the projected sphere
sampling_ignore_unobservable = true;             
integration_method = 'trapz';           
integration_np = 10;                % number of evaluation points for trapz
integration_correct_incidence = true;    % Correct incidence angle with true incidence angle with low distance-to-radius ratios
integration_correct_reflection = true;    % Correct reflection angle with true reflection angle with low distance-to-radius ratios
gridding_method = 'weightedsum';        % 'weightedsum' weighs each intensity value spreading it across the neighbouring pixels
gridding_algorithm = 'area';
reconstruction_granularity = 1;                        % Down-sampling of pixels
processing_distortion = false;
processing_diffraction = false;
processing_noise = false;
processing_blooming = false;
image_filename = 'validation_corto';
image_format = 'png';
image_depth = 16;

%% 
prepro();