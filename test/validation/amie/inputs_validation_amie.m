%% BODY
if flag_hapke
    rend.body.radiometry.model = 'hapke'; 
    rend.body.radiometry.parameters = [0.25, 0.3, 0, 1, 2.2, 0.07, 0.4129, 0]; % Sato et al. Bandwidth: 450-1150 nm
    rend.body.albedo_type = 'normal';
    rend.body.maps.albedo.filename = 'moon\lroc_cgi\lroc_color_16bit_srgb_8k.tif';
    rend.body.maps.albedo.depth = 16;
    %rend.body.maps.albedo.mean = 0.51;    
    rend.body.maps.albedo.domain = [0.12 0.75];
else
    rend.body.radiometry.model = 'oren'; 
    rend.body.radiometry.roughness = 0.3;    % roughness in oren model (>> more rough)
    rend.body.maps.albedo.domain = [0.16 0.4];
end

if flag_displacement
    rend.body.maps.displacement.filename = 'moon\ldem_16.tif';
    rend.body.maps.displacement.depth = 1;
    rend.body.maps.displacement.scale = 1000;
else
    rend.body.maps.displacement.filename = [];
end

if flag_normal
    rend.body.maps.normal.filename = 'moon\Moon_LRO_LOLA_NBM_Global_16ppd_pizzetti2025.tif';
    rend.body.maps.normal.depth = 32;
    rend.body.maps.normal.frame = 'body';
else
    rend.body.maps.normal.filename = [];
end

if flag_horizon
    rend.body.maps.horizon.filename = 'moon\Moon_LRO_LOLA_HM_Global_16ppd_pizzetti2025.tif';
    rend.body.maps.horizon.depth = 1;
    rend.body.maps.horizon.scale = pi/2;
else
    rend.body.maps.horizon.filename = [];
end

%% SETTING
% Consider occlusions
rend.setting.culling.ignore_occluded = flag_occlusions;
% Use large number of points for increased accuracy
rend.setting.discretization.method = 'fixed';
rend.setting.discretization.np = 1e6;       
% Simulate PSF with a gaussian-weighted gridding                          
rend.setting.gridding.method = 'weightedsum';
rend.setting.gridding.algorithm = 'gaussian';
rend.setting.gridding.window = 2;
rend.setting.gridding.sigma = 1;
rend.setting.reconstruction.granularity = 2;