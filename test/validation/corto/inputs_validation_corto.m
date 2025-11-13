%% STAR 
Tstar = 5782;     % [K]
Rstar = 695000e3; % [m]
star_type = 'bb';

%% BODY
radiometry_model = 'lambert';
Rbody = 1.7374e6; % [m] body radius
albedo = 0.18; % [-] albedo
albedo_type = 'bond';
if flag_albedo
    albedo_filename = 'moon\lroc_cgi\lroc_color_poles_2k.tif';
    albedo_depth = 8;
    albedo_mean = 0.18;
end
if flag_displacement
    displacement_filename = 'moon\ldem_4.tif';
    displacement_depth = 1;
    displacement_scale = 1000;
end
if flag_normal
    normal_filename = 'moon\Moon_LRO_LOLA_NBM_Global_4ppd_pizzetti2025.tif';
    normal_depth = 32;
    normal_frame = 'body';
end

%% CAMERA  
tExp = 0.015e-3;
QE_lambda_min = (425:50:975)*1e-9;
QE_lambda_max = (475:50:1025)*1e-9;
QE_values = [0.35, 0.43, 0.46, 0.45, 0.42, 0.37, 0.30, 0.23, 0.16, 0.09, 0.04, 0.02]; % Quantum Efficiency per BW
QE_sampling = 'piecewise';
T_lambda_min = QE_lambda_min;
T_lambda_max = QE_lambda_max;
T_values = [0.410, 0.687, 0.915, 0.954, 0.967, 0.977, 0.979, 0.982, 0.984, 0.987, 0.989, 0.992]; % Lens transmittance per BW
T_sampling = 'piecewise';
fwc = 100e3; % [e-] from https://upverter.com/datasheet/1dbf6474f4834c5ac73294b488ac44ae8ac1f8ca.pdf 
f = 50.7e-3;
dpupil = 33.9e-3;
fNum = f/dpupil;
muPixel = 18e-6; % [m] pixel size
res_px = 1024; % [px] Resolution in pixel
fov = 2*atan((res_px*muPixel/2)/f); % focal length
fov_shape = 'circle';
saving_depth = 16;
G_AD = (2^saving_depth-1)/fwc;

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
[phase_angle, d_body2cam, d_body2star, q_CSF2IAU, q_CAMI2CAM] = inputs_corto2matlab(inputs_corto, 1e6, false);
% post-process
rpy_CAMI2CAM = quat_to_euler(q_CAMI2CAM);
rpy_CSF2IAU = quat_to_euler(q_CSF2IAU);

%% PARAMETERS
% Select parameters
general_environment = 'matlab';
general_parallelization = false;
general_workers = 6;
discretization_method = 'fixed';
discretization_np = 1e6;            % number of total pixel sectors on sphere
discretization_accuracy = 'medium';            % number of total pixel sectors on sphere
sampling_method = 'projecteduniform'; % 'projective' sampling of longitude and latitude points that are approximately spread uniformly on the projected sphere
sampling_ignore_unobservable = true; 
sampling_ignore_occluded = true;
sampling_occlusion_rays = 10;
sampling_occlusion_angle = 'auto';
integration_method = 'constant';%'trapz';           
integration_np = 10;                % number of evaluation points for trapz
integration_correct_incidence = true;    % Correct incidence angle with true incidence angle with low distance-to-radius ratios
integration_correct_reflection = true;    % Correct reflection angle with true reflection angle with low distance-to-radius ratios
gridding_method = 'weightedsum';        % 'weightedsum' weighs each intensity value spreading it across the neighbouring pixels
gridding_algorithm = 'area';
gridding_scheme = 'linear'; 
gridding_window = 1;
gridding_shift = 1;
gridding_filter = 'gaussian';
gridding_sigma = 0.5;
reconstruction_granularity = 1;                        % Down-sampling of pixels
reconstruction_antialiasing = true;                        
reconstruction_filter = 'bilinear';                        
processing_distortion = false;
processing_diffraction = false;
processing_noise = false;
processing_blooming = false;
saving_filename = 'validation_corto';
saving_format = 'png';
saving_depth = 16;

%% 
prepro();