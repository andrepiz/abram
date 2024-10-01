function [dcm_CSF2CAM, pos_body2sun_CSF, pos_body2sc_CSF, alpha, theta] ...
            = extract_corto_trajectory(filepath)

% Objects
% sun
% body
% sc

% Frames
% BLEND: main axes of Blender
% BCAM: Blender camera frame (orientation as given by the input quaternion)
% CAM: camera frame (x_CAM = x_BCAM, y_CAM = -y_BCAM, z_CAM = -z_BCAM)
% CSF: camera-sun frame (x_CSF = Sun, y_CSF = follows, z_CSF = normal to cam-sun plane)

tabBlender = readtable(filepath);
tabBlender = table2array(tabBlender);

q_BLEND2BCAM = tabBlender(:, 12:15)';
dcm_BCAM2CAM = diag([1, -1, -1]); % x optical axis preserved, y and z switched
pos_body2sc_BLEND = 1e3*tabBlender(:, 9:11)';
pos_body2sun_BLEND = 1e3*tabBlender(:, 5:7)';

n = size(tabBlender, 1);
dcm_CSF2CAM = zeros(3, 3, n);
pos_body2sc_CSF = zeros(3, n);
pos_body2sun_CSF = zeros(3, n);
alpha = zeros(1, n);
theta = zeros(1, n);

for ix = 1:n
    dcm_BLEND2CAM = dcm_BCAM2CAM*cp_quat_to_dcm(q_BLEND2BCAM(:, ix));
    xCSF_BLEND = cp_normalize(pos_body2sun_BLEND(:, ix));
    zCSF_BLEND = cross(xCSF_BLEND, cp_normalize(pos_body2sc_BLEND(:, ix)));
    yCSF_BLEND = cross(zCSF_BLEND, xCSF_BLEND);
    dcm_CSF2BLEND = [xCSF_BLEND, yCSF_BLEND, zCSF_BLEND];
    dcm_CSF2CAM(:, :, ix) = dcm_BLEND2CAM*dcm_CSF2BLEND;

    pos_sc2body_CAM = -dcm_BLEND2CAM*pos_body2sc_BLEND(:, ix);
    pos_body2sun_CAM = dcm_BLEND2CAM*pos_body2sun_BLEND(:, ix);
    alpha(ix) = acos(pos_sc2body_CAM'*pos_body2sun_CAM/norm(pos_sc2body_CAM)/norm(pos_body2sun_CAM));
    
    pos_body2sc_CSF(:, ix) =  dcm_CSF2BLEND'*pos_body2sc_BLEND(:, ix);
    pos_body2sun_CSF(:, ix) = dcm_CSF2BLEND'*pos_body2sun_BLEND(:, ix);

    los_CAM = [0;0;1];
    theta(ix) = acos(pos_sc2body_CAM'*los_CAM/norm(pos_sc2body_CAM));
end

end