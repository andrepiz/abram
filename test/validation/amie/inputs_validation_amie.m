%% STAR 
Tstar = 5782;     % [K]
Rstar = 695000e3; % [m]
star_type = 'bb';

%% BODY
% Moon w/o texture
Rbody = 1.7374e6; % [m] body radius
albedo = 0.20; 
albedo_type = 'bond';
if flag_hapke
    radiometry_model = 'hapke'; 
    % Found from Sato et al. Bandwidth: 450-1150 nm
    radiometry_parameters = [0.25, 0.25, 0, 1, 1.8, 0.07, 0.4084, 1];
else
    radiometry_model = 'oren'; 
    radiometry_roughness = 0.3;    % roughness in oren model (>> more rough)
end    

albedo_filename = 'moon\lroc_cgi\lroc_color_poles_2k.tif';
albedo_depth = 8;
albedo_mean = albedo;                 % Rescale albedo map to return a mean albedo equal to the geometric albedo
% albedo_domain = [0.16 0.4];
% albedo_gamma = 2.8;

% % USING LROC CGI MOON KIT
% %The red channel contains the 643 nm band, while green and blue were created from 
% % different linear combinations of the 566 and 415 nm bands to more nearly center
% % them on 532 nm (green) and 472 nm (blue). A gamma of 2.8 was applied (the LROC data is linear), 
% % and the channels were multiplied by (0.935, 1.005, 1.04) to balance the color. 
% % The intensity range (0.16, 0.4) was mapped into the full (0, 255) 8-bit range per channel
% albedo_filename = 'moon\lroc_cgi\lroc_color_poles_8k.tif';
% albedo_dimension = 'hyperspectral';
% albedo_lambda_min = [472 - ((472 + 532)/2 - 472), (472 + 532)/2, (532 + 643)/2]*1e-9;
% albedo_lambda_max = [(472 + 532)/2, (532 + 643)/2, 643 + ((532 + 643)/2 - 532)]*1e-9;
% albedo_bandwidth = [params.lambda_min(1), params.lambda_max(end)];
% albedo_limits = [-pi, pi; -pi/2 pi/2];
% albedo_gamma = 2.8;
% albedo_scale = 1./[0.935, 1.005, 1.04];
% albedo_domain = [0.08, 0.2; 0.12, 0.28; 0.24, 0.48];
% albedo_type = 'bond';

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
% From User Manual:
%Saturation 300 000 electrons
%Spectral response 650 nm, 50% at 500nm and 800nm
%Efficiency >15% at 640 nm
%Dynamic 80 dB

QE_lambda_min = params.lambda_min:100e-9:params.lambda_max-100e-9;
QE_lambda_max = params.lambda_min+100e-9:100e-9:params.lambda_max;
QE_sampling = 'midpoint';
QE_values = 0.15*ones(1, length(QE_lambda_max)); % as stated in the user manual
T_lambda_min = QE_lambda_min;
T_lambda_max = QE_lambda_max;
T_sampling = 'midpoint';
T_values = get_amie_spectral_response(QE_lambda_min, QE_lambda_max, T_sampling, false);

% distortion (assumed zero)
distortion.radial = [0, 0, 0];
distortion.decentering = [0, 0];

% noise (to evaluate)
noise.shot.flag = false;
noise.shot.sigma = 0;
noise.shot.seed = [];
noise.prnu.flag = false;
noise.prnu.sigma = 0;
noise.prnu.seed = [];
noise.dark.flag = false;    % dark current already corrected
noise.dark.sigma = 0;
noise.dark.mean = 0;
noise.dark.seed = [];
noise.readout.flag = false;
noise.readout.sigma = 0;
noise.readout.seed = [];

f = params.f;
fNum = params.fNum;
dpupil = f/fNum;
muPixel = params.muPixel; % [m] pixel size
res_px = [params.res_px params.res_px]; % [px] Resolution in pixel
fov_type = 'frustum';

fwc = 300e3; % as stated in the user manual
G_DA = params.G_DA;
G_AD = 1/G_DA;
offset = 0;     % already corrected in ground truth image

%% SCENARIO
tExp = params.tExp;
phase_angle = params.phase_angle;
d_body2star = params.d_body2sun;
d_body2cam = params.d_body2cam;
q_CSF2IAU = params.q_CSF2IAU;
q_CAMI2CAM = params.q_CAMI2CAM;
    % post-process
    rpy_CAMI2CAM = quat_to_euler(q_CAMI2CAM);
    rpy_CSF2IAU = quat_to_euler(q_CSF2IAU);

%% PARAMETERS
% Select parameters
general_environment = 'matlab';
general_parallelization = true;
general_workers = 4;
discretization_method = 'fixed';
discretization_np = 1e6;            % number of total pixel sectors on sphere
discretization_accuracy = 'high';
sampling_method = 'projecteduniform'; % 'projecteduniform' sampling of longitude and latitude points that are approximately spread uniformly on the projected sphere
sampling_ignore_unobservable = true;             % ignore sectors that fall outside the tangency circle
sampling_ignore_occluded = flag_occlusions;
sampling_occlusion_rays = 10;
sampling_occlusion_angle = 'auto';
integration_method = 'trapz';           
integration_np = 'auto';                % number of evaluation points for trapz
integration_correct_incidence = true;    % Correct incidence angle with true incidence angle
integration_correct_reflection = true;    % Correct reflection angle with true reflection angle
gridding_method = 'weightedsum';        % 'weightedsum' weighs each intensity value spreading it across the neighbouring pixels
gridding_algorithm = 'area';
gridding_scheme = 'linear'; 
gridding_window = 1;
gridding_shift = 1;
gridding_filter = 'gaussian';
gridding_sigma = 1;
reconstruction_granularity = 1;                        % Down-sampling of pixels
reconstruction_antialiasing = false;                        
reconstruction_filter = 'bilinear';                        
processing_diffraction = false;
processing_blooming = false;
saving_depth = 10;
saving_filename = 'validation_amie';
saving_format = 'png';

%% PRE-PROCESSING
prepro()