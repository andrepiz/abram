if flag_scenario == 1       % 50 mm
    ampl_DB = 15; % metadata
    fNum = 4; % metadata
    tExp = 114e-6; % metadata
    f = 50e-3;  % data
    image_filepath_real = fullfile('2023-12-22_21_29_53_moon50','imgFLIR_20231222212953_115.png');
    time_UTC = "2023/12/22 21:29:53";
    if flag_use_spice
        posCam_altlonlat = [455; deg2rad(8.381019); deg2rad(45.848510)]; % Coordinates of Fabio's house @Nonio
        % fine-tuned:
        rpy_ENU2CAM = [-0.596337616129912;
                        0.154874137157433;
                        2.629864326084645]; % X+: increase vertical Y+: decrease horizontal Z+: rotate hourly
    else
        AU = 149597870707; % [m]
        d_body2star = 1*AU;
        % taken from https://www.mooncalc.org/
        percAreaIlluminated = 0.819; % 
        phase_angle = acos(2*percAreaIlluminated - 1);
        d_body2cam = 378396e3;
        % to fine-tune:
        rpy_CAMI2CAM = [deg2rad(0.44);deg2rad(-0.48);deg2rad(145)];                     % [rad] Camera euler angles off-pointing (rpy). Note that yaw is optical axis
        rpy_CSF2IAU = [deg2rad(-179.7006);deg2rad(2.0779);deg2rad(54.5703)];                     % [rad] 
     end

elseif flag_scenario == 2   % 25 mm
    ampl_DB = 15; % metadata
    fNum = 4; % metadata
    tExp = 80e-6; % metadata
    f = 25e-3;  % data
    image_filepath_real = fullfile('2023-12-22_19_21_24_moon','imgFLIR_20231222192125_025.png');
    time_UTC = "2023/12/22 19:21:25";
    if flag_use_spice
        posCam_altlonlat = [455; deg2rad(8.381019); deg2rad(45.848510)];
        % fine-tuned:
        rpy_ENU2CAM = [-0.530056493830678
                        0.147131255943122
                       -2.679080401811296]; % X+: increase vertical Y+: decrease horizontal Z+: rotate hourly
        % % to fine-tune:
        % q_ENU2CAM = euler_to_quat(deg2rad([-30.37; 8.42; -153.5]));    % X+: increase vertical Y+: decrease horizontal Z+: rotate hourly
    else
        % to fine-tune
        AU = 149597870707; % [m]
        percAreaIlluminated = 0.819; % https://www.mooncalc.org/
        phase_angle = acos(2*percAreaIlluminated - 1);
        d_body2star = 1*AU;
        d_body2cam = 378396e3;
        rpy_CAMI2CAM = [deg2rad(-0.97);deg2rad(0.42);deg2rad(184)];                     % [rad] Camera euler angles off-pointing (rpy). Note that yaw is optical axis
        rpy_CSF2IAU = [deg2rad(-179.7006);deg2rad(2.0779);deg2rad(54.5703)];                     % [rad] 
     end
end

%% STAR 
% Select star
Tstar = 5782;     % [K]
Rstar = 695000e3; % [m]
star_type = 'bb';

%% BODY
Rbody = 1.7374e6; % [m]
albedo_type = 'bond';
if flag_hapke
    albedo = 0.20; %0.18;
    radiometry_model = 'hapke'; 
    radiometry_parameters = [0.25, 0.25, 0, 1, 1.8, 0.07, 0.4084, 1];     % Found from Sato et al. Bandwidth: 450-1150 nm
else
    albedo = 0.20; %0.18
    radiometry_model = 'oren'; 
    radiometry_roughness = 0.3;                                           % roughness in oren model (>> more rough)
end    
albedo_filename = 'moon\lroc_cgi\lroc_color_poles_2k.tif';
albedo_depth = 8;
albedo_mean = albedo;          
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

% BFS-PGE-31S4M-C Sony IMX265
dpupil = f/fNum;
muPixel = 3.45e-6; % [m] pixel size  
res_px = [2048 1536]; % [px] Resolution in pixel 
fov = 2*atan((res_px*muPixel/2)/f); % focal length
fov_shape = 'frustum';

QE_lambda_min = [2.72e-07,3.22e-07,3.72e-07,4.22e-07,4.72e-07,5.22e-07,5.72e-07,6.22e-07,6.72e-07,7.22e-07,7.72e-07,8.22e-07,8.72e-07,9.22e-07,9.72e-07,1.022e-06,1.072e-06];
QE_lambda_max = [3.22e-07,3.72e-07,4.22e-07,4.72e-07,5.22e-07,5.72e-07,6.22e-07,6.72e-07,7.22e-07,7.72e-07,8.22e-07,8.72e-07,9.22e-07,9.72e-07,1.022e-06,1.072e-06,1.122e-06];
QE_values = [0.046335,0.21472,0.46362,0.63806,0.66967,0.68317,0.62862,0.56362,0.46565,0.35428,0.26281,0.16923,0.10733,0.057816,0.028469,0.011971,0];
QE_sampling = 'piecewise';

nbw = length(QE_lambda_min);
T_lambda_min = QE_lambda_min;
T_lambda_max = QE_lambda_max;
if flag_scenario == 1
    T_values = 0.6*ones(1, nbw);    
else
    T_values = 0.95*ones(1, nbw); % transmittance of 25 mm is 1.5 times the 50 mm. Estimated through visual check of pattern using same fNum and exposure time.
end
T_sampling = 'piecewise';

% BFS-PGE-31S4M-C Sony IMX265
gain_electron2adu = 5.88;       % 16 bit DN over electrons 
adc_depth = 12;
fwc = 10760;  
G_AD = gain_electron2adu/(2^16-1)*(2^adc_depth-1);
amplification = ampl_DB;
if flag_account_for_atmosphere
    atm_red_factor = 0.85; % assumed a reduction factor caused by the atmosphere on the gain. From "On the radiometric calibration of optical Hardware-In-the-Loop stimulators", Ornati et al.
else
    atm_red_factor = 1;
end
G_AD = atm_red_factor*G_AD;
offset = 0;
% snr_DB = 40.32;
% snr_bits = 6.7;
% dnr_DB = 71.69;
% dnr_bits = 11.91;
%G_AD = (2^dnr_bits)/fwc*ampl_lin;

noise.shot.flag = false;
noise.shot.sigma = 0;
noise.shot.seed = [];
noise.prnu.flag = false;
noise.prnu.sigma = 0;
noise.prnu.seed = [];
noise.dark.flag = false;    
noise.dark.sigma = 0;
noise.dark.mean = 0;
noise.dark.seed = [];
noise.readout.flag = false;
noise.readout.sigma = 0;
noise.readout.seed = [];

distortion.radial = [];
distortion.decentering = [];

%% SCENARIO
if flag_use_spice
    q_ENU2CAM = euler_to_quat(rpy_ENU2CAM);    
    [d_body2star, d_body2cam, phase_angle, q_CAMI2CAM, q_CSF2IAU] = ...
                inputs_ecef2matlab(time_UTC, posCam_altlonlat, q_ENU2CAM, filename_metakernel, 'MOON');
    rpy_CSF2IAU = quat_to_euler(q_CSF2IAU);
    rpy_CAMI2CAM = quat_to_euler(q_CAMI2CAM);
end

%% PARAMETERS
% Select parameters
general_environment = 'matlab';
general_workers = 4;
general_parallelization = true;
discretization_method = 'adaptive';
discretization_accuracy = 10;
discretization_np = 5e5;            % number of total pixel sectors on sphere
sampling_method = 'projecteduniform'; % 'projective' sampling of longitude and latitude points that are approximately spread uniformly on the projected sphere
sampling_ignore_unobservable = true;             % ignore sectors that fall outside the tangency circle
sampling_ignore_occluded = true;             % ignore sectors that fall outside the tangency circle
sampling_occlusion_rays = 10;
sampling_occlusion_angle = 'auto';
integration_method = 'trapz';           
integration_np = 10;                % number of evaluation points for trapz
integration_correct_incidence = true;    % Correct incidence angle with true incidence angle with low distance-to-radius ratios
integration_correct_reflection = true;    % Correct incidence angle with true incidence angle with low distance-to-radius ratios
gridding_method = 'weightedsum';        % 'weightedsum' weighs each intensity value spreading it across the neighbouring pixels
gridding_algorithm = 'gaussian';
gridding_scheme = 'linear'; 
gridding_window = 1;
gridding_shift = 1;
gridding_filter = 'gaussian';
reconstruction_granularity = 'auto';                        % Down-sampling of pixels
reconstruction_antialiasing = true;                        
reconstruction_filter = 'bilinear';                        
processing_distortion = false;
processing_diffraction = false;
processing_noise = false;
processing_blooming = false;
saving_filename = 'validation_opensky_bfs';
saving_format = 'png';
saving_depth = adc_depth;

%% PRE-PROCESSING
prepro()