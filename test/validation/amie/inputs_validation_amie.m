%% STAR 
Tstar = 5782;     % [K]
Rstar = 695000e3; % [m]

%% BODY
% Moon w/o texture
Rbody = 1.7374e6; % [m] body radius
radiometry_model = 'oren'; 
radiometry_ro = 0.3;    % roughness in oren model (>> more rough)
albedo = 0.10; 
albedo_type = 'geometric';
albedo_filename = 'lroc_color_poles_2k.tif';
albedo_depth = 8;
albedo_mean = 0.10;                 % Rescale albedo map to return a mean albedo equal to the geometric albedo
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
% From User Manual:
%Saturation 300 000 electrons
%Spectral response 650 nm, 50% at 500nm and 800nm
%Efficiency >15% at 640 nm
%Dynamic 80 dB

lambda_min = params.lambda_min:100e-9:params.lambda_max-100e-9;
lambda_max = params.lambda_min+100e-9:100e-9:params.lambda_max;
nbw = length(lambda_min);
T = get_amie_spectral_response(lambda_min, lambda_max);
QE = 0.15; % as stated in the user manual

f = params.f;
fNum = params.fNum;
dpupil = f/fNum;
muPixel = params.muPixel; % [m] pixel size
res_px = [params.res_px params.res_px]; % [px] Resolution in pixel

fwc = 300e3; % as stated in the user manual
G_DA = params.G_DA;
G_AD = 1/G_DA;

%% SCENARIO
tExp = params.tExp;
alpha = params.alpha;
d_body2star = params.d_body2sun;
d_body2sc = params.d_body2cam;
q_CSF2IAU = params.q_CSF2IAU;
q_CAMI2CAM = params.q_CAMI2CAM;
    % post-process
    dcm_CAMI2CAM = quat_to_dcm(q_CAMI2CAM);
    dcm_CSF2IAU = quat_to_dcm(q_CSF2IAU);

%% PARAMETERS
% Select parameters
discretization_method = 'fixed';
discretization_np = 1e6;            % number of total pixel sectors on sphere
sampling_method = 'projective'; % 'projective' sampling of longitude and latitude points that are approximately spread uniformly on the projected sphere
sampling_ignore_unobservable = true;             % ignore sectors that fall outside the tangency circle
integration_method = 'trapz';           
integration_np = 10;                % number of evaluation points for trapz
integration_correct_incidence = true;    % Correct incidence angle with true incidence angle with low distance-to-radius ratios
gridding_method = 'weightedsum';        % 'weightedsum' weighs each intensity value spreading it across the neighbouring pixels
gridding_algorithm = 'area';
gridding_interpolation = 'linear'; 
reconstruction_granularity = 1;                        % Down-sampling of pixels
processing_distortion = false;
processing_diffraction = false;
processing_noise = false;
processing_blooming = false;
image_depth = 10;
image_filename = 'validation_amie';
image_format = 'png';

%% PRE-PROCESSING
prepro()