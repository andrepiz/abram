%% BODY

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

% Use large number of points for increased accuracy
rend.setting.discretization.method = 'fixed';
rend.setting.discretization.np = 1e6;       

% Simulate PSF with a gaussian-weighted gridding          
rend.setting.gridding.window = 2;
rend.setting.gridding.sigma = 1;
rend.setting.reconstruction.granularity = 2;