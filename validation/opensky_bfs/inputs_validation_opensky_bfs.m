%% STAR 
% Select star
get_star()

%% BODY
Rbody = 1.7374e6; % [m]
albedo = 0.18; 
albedo_type = 'bond';
albedo_filename = 'lroc_color_poles_2k.tif';
albedo_depth = 8;
albedo_mean = 0.18;                 
radiometry_model = 'lambert';

%% CAMERA

if flag_camera == 1
    f = 50e-3;
elseif flag_camera == 2
    f = 25e-3;
end
dpupil = f/4;
fNum = f/dpupil;
muPixel = 3.45e-6; % [m] pixel size  % BFS-PGE-31S4M-C Sony IMX265
res_px = 1536; % [px] Resolution in pixel  % BFS-PGE-31S4M-C Sony IMX265
fov = 2*atan((res_px*muPixel/2)/f); % focal length
fov_shape = 'square';
%lambda_0=[290,300,350,400,450,500,525,550,600,700,800,900,1000,1100];
lambda_min=1e-9*([290,300,350,400,450,500,525,550,600,700,800,900,1000,1100]-30);
lambda_max=1e-9*([300,350,400,450,500,525,550,600,700,800,900,1000,1100,1110]);
nbw = length(lambda_min);
QE = [0,2,20,45,60,63,64,65,60,45,25,10,3,0]*1e-2;
T = 0.9*ones(1, nbw);

fwc = 10760;  % BFS-PGE-31S4M-C Sony IMX265
dnr_bits = 11.91; % BFS-PGE-31S4M-C Sony IMX265
ampl_DB = 15; % BFS-PGE-31S4M-C Sony IMX265
ampl_lin = (ampl_DB/10)^10;
G_AD = (2^dnr_bits)/fwc*ampl_lin;
atm_red_factor = 0.7; % assumed a reduction factor caused by the atmosphere on the gain
G_AD = atm_red_factor*G_AD;
image_depth = 16;

%% SCENARIO
AU = 149597870707; % [m]
d_body2star = 1*AU;
tExp = 80e-6;
percAreaIlluminated = 0.819; % https://www.mooncalc.org/#/43.8256,11.1334,13/2022.04.11/22:00/1/3
alpha = acos(2*percAreaIlluminated - 1);
d_body2sc = 378396e3;
if flag_camera == 1
    %eul_CAMI2CAM = [deg2rad(-0.44);deg2rad(0.48);deg2rad(-35)];                     % [rad] Camera euler angles off-pointing (rpy). Note that yaw is optical axis
    eul_CAMI2CAM = [deg2rad(0.44);deg2rad(-0.48);deg2rad(145)];                     % [rad] Camera euler angles off-pointing (rpy). Note that yaw is optical axis
elseif flag_camera == 2
    eul_CAMI2CAM = [deg2rad(-0.97);deg2rad(0.42);deg2rad(184)];                     % [rad] Camera euler angles off-pointing (rpy). Note that yaw is optical axis
end
eul_CSF2IAU = [deg2rad(175);deg2rad(10);deg2rad(53)];                     % [rad] 
%eul_CSF2IAU = [deg2rad(-5);deg2rad(10);deg2rad(53)];                     % [rad] 
% alpha = deg2rad(30);
% d_body2sc = 80000e3;
% eul_CAMI2CAM = [deg2rad(0.4);deg2rad(0.4);deg2rad(0)];                     % [rad] Camera euler angles off-pointing (rpy). Note that yaw is optical axis
% eul_CSF2IAU = [deg2rad(0);deg2rad(0);deg2rad(0)];                     % [rad] 
%post-process
dcm_CAMI2CAM = euler_to_dcm(eul_CAMI2CAM);
dcm_CSF2IAU = euler_to_dcm(eul_CSF2IAU);

%% PARAMETERS
% Select parameters
discretization_method = 'fixed';
discretization_np = 5e5;            % number of total pixel sectors on sphere
sampling_method = 'projective'; % 'projective' sampling of longitude and latitude points that are approximately spread uniformly on the projected sphere
sampling_ignore_unobservable = true;             % ignore sectors that fall outside the tangency circle
integration_method = 'trapz';           
integration_np = 10;                % number of evaluation points for trapz
integration_correct_incidence = true;    % Correct incidence angle with true incidence angle with low distance-to-radius ratios
binning_method = 'weightedsum';        % 'weightedsum' weighs each intensity value spreading it across the neighbouring pixels
binning_algorithm = 'area';
binning_interpolation = 'linear'; 
binning_granularity = 1;                        % Down-sampling of pixels
processing_distortion = false;
processing_diffraction = false;
processing_noise = false;
processing_blooming = false;

%% PRE-PROCESSING
prepro()
