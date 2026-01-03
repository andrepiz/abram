%% BODY
rend.body.maps.albedo.filename = 'moon\lroc_cgi\lroc_color_16bit_srgb_8k.tif';
rend.body.maps.albedo.depth = 16;
if flag_hapke
    rend.body.albedo = 0.51; %0.18;
    rend.body.radiometry.model = 'hapke'; 
    rend.body.radiometry.parameters = [0.25, 0.3, 0, 1, 2.2, 0.07, 0.4129, 0];     % Found from Sato et al. Bandwidth: 450-1150 nm
    rend.body.maps.albedo.domain = [0.12 0.75];% + 0.3;
else
    rend.body.albedo = 0.20; %0.18
    rend.body.radiometry.model = 'oren'; 
    rend.body.radiometry.roughness = 0.3;     
    rend.body.maps.albedo.mean = rend.body.albedo;    
end          
if flag_displacement
    rend.body.maps.displacement.filename = 'moon\ldem_4.tif';
    rend.body.maps.displacement.depth = 1;
    rend.body.maps.displacement.scale = 1000;
end
if flag_normal
    rend.body.maps.normal.filename = 'moon\Moon_LRO_LOLA_NBM_Global_4ppd_pizzetti2025.tif';
    rend.body.maps.normal.depth = 32;
    rend.body.maps.normal.frame = 'body';
end

%% SCENE

if flag_scenario == 1       % 50 mm
    rend.camera.amplification = 15; % metadata
    rend.camera.fNum = 4; % metadata
    rend.camera.tExp = 114e-6; % metadata
    rend.camera.f = 50e-3;  % data
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
        rend.scene.d_body2light = 1*AU;
        % taken from https://www.mooncalc.org/
        percAreaIlluminated = 0.819; % 
        rend.scene.phase_angle = acos(2*percAreaIlluminated - 1);
        rend.scene.d_body2cam = 378396e3;
        % to fine-tune:
        rend.scene.rpy_CAMI2CAM = [deg2rad(0.44);deg2rad(-0.48);deg2rad(145)];                     % [rad] Camera euler angles off-pointing (rpy). Note that yaw is optical axis
        rend.scene.rpy_CSF2IAU = [deg2rad(-179.7006);deg2rad(2.0779);deg2rad(54.5703)];                     % [rad] 
     end

elseif flag_scenario == 2   % 25 mm
    rend.camera.amplification = 15; % metadata
    rend.camera.fNum = 4; % metadata
    rend.camera.tExp = 80e-6; % metadata
    rend.camera.f = 25e-3;  % data
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
        rend.scene.phase_angle = acos(2*percAreaIlluminated - 1);
        rend.scene.d_body2light = 1*AU;
        rend.scene.d_body2cam = 378396e3;
        rend.scene.rpy_CAMI2CAM = [deg2rad(-0.97);deg2rad(0.42);deg2rad(184)];                     % [rad] Camera euler angles off-pointing (rpy). Note that yaw is optical axis
        rend.scene.rpy_CSF2IAU = [deg2rad(-179.7006);deg2rad(2.0779);deg2rad(54.5703)];                     % [rad] 
     end
end


%% CAMERA

if flag_scenario == 1
    rend.camera.T.values = 0.6*rend.camera.T.values;    
else
    rend.camera.T.values = 0.95*rend.camera.T.values; % transmittance of 25 mm is 1.5 times the 50 mm. Estimated through visual check of pattern using same fNum and exposure time.
end

% BFS-PGE-31S4M-C Sony IMX265
gain_electron2adu = 5.88;       % 16 bit DN over electrons 
adc_depth = 12;
if flag_account_for_atmosphere
    atm_red_factor = 0.85; % assumed a reduction factor caused by the atmosphere on the gain. From "On the radiometric calibration of optical Hardware-In-the-Loop stimulators", Ornati et al.
else
    atm_red_factor = 1;
end
rend.camera.G_AD  = atm_red_factor*gain_electron2adu/(2^16-1)*(2^adc_depth-1);
rend.camera.offset = 0;

%% SCENARIO
if flag_use_spice
    q_ENU2CAM = euler_to_quat(rpy_ENU2CAM);    
    [rend.scene.d_body2light, rend.scene.d_body2cam, rend.scene.phase_angle, q_CAMI2CAM, q_CSF2IAU] = ...
                inputs_ecef2matlab(time_UTC, posCam_altlonlat, q_ENU2CAM, filename_metakernel, 'MOON');
    rend.scene.rpy_CSF2IAU = quat_to_euler(q_CSF2IAU);
    rend.scene.rpy_CAMI2CAM = quat_to_euler(q_CAMI2CAM);
end

%% SETTING
rend.setting.saving.depth = adc_depth;
rend.setting.discretization.method = 'fixed';
rend.setting.discretization.np = 1e6;
%rend.setting.integration.method = 'trapz';
rend.setting.gridding.window = 2;
rend.setting.gridding.sigma = 1;
