%% BODY
if flag_albedo
    rend.body.maps.albedo.filename = 'moon\lroc_cgi\lroc_color_poles_2k.tif';
    rend.body.maps.albedo.depth = 8;
    rend.body.maps.albedo.mean = 0.18;
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
[rend.scene.phase_angle, rend.scene.d_body2cam, rend.scene.d_body2light, q_CSF2IAU, q_CAMI2CAM] = inputs_corto2matlab(inputs_corto, 1e6, false);
% post-process
rend.scene.rpy_CAMI2CAM = quat_to_euler(q_CAMI2CAM);
rend.scene.rpy_CSF2IAU = quat_to_euler(q_CSF2IAU);

%% SETTING
rend.setting.reconstruction.granularity = 1;
rend.setting.discretization.accuracy = 20;
