function [alpha, d_body2sc, d_body2sun, q_CSF2IAU, q_CAMI2CAM] = inputs_corto2matlab(inputs_corto, scaling_blender, flag_debug)
% - [0]: ID or ephemeris time
% - [1,2,3]: Position of the body in BU (Blender units)
% - [4,5,6,7]: Quaternion orientation of the body (in Blender notation W-XYZ)
% - [8,9,10]: Position of the camera in BU
% - [11,12,13,14]: Quaternion orientation of the camera (in Blender notation W-XYZ)
% - [15,16,17]: Position of the Sun in BU

% BL
%   Blender Frame - XYZ frame of Blender
% BLCAM
%   Blender-Camera Frame - XYZ frame of Camera in Blender
%   z-axis opposite to optical axis
% IAU
%   Astronomical Reference Frame - Texture is defined wrt it
% CSF frame
%   centered at the planet COM
%   z-axis along normal to the sun-body-camera plane
%   x-axis along sun direction
%   y-axis completes the frame
% CAMI frame
%   centered at the S/C
%   z-axis along camera-to-body direction
%   y-axis opposite to z_CSF
%   x-axis completes the frame
% CAM frame
%   centered at the S/C
%   z-axis along optical axis
%   y-axis rotated accordingly to off-pointing
%   x-axis completes the frame

% Input extraction
pos_blend2body_BL = scaling_blender*inputs_corto(:, 2:4)';
q_BL2IAU = inputs_corto(:, 5:8)';
pos_blend2cam_BL = scaling_blender*inputs_corto(:, 9:11)';
q_BL2BLCAM = inputs_corto(:, 12:15)';
pos_blend2sun_BL = scaling_blender*inputs_corto(:, 16:18)';

% Positions
pos_body2cam_BL = - pos_blend2body_BL + pos_blend2cam_BL;
pos_body2sun_BL = - pos_blend2body_BL + pos_blend2sun_BL;

% Norms
d_body2sun = vecnorm(pos_body2sun_BL);
d_body2sc = vecnorm(pos_body2cam_BL);

% Directions
dir_body2sun_BL = pos_body2sun_BL./d_body2sun;
dir_body2sc_BL = pos_body2cam_BL./d_body2sc;

% Alpha angle
alpha = acos(dir_body2sun_BL'*dir_body2sc_BL);

% CSF Frame
xCSF_BL = dir_body2sun_BL;
zCSF_BL = vecnormalize(cross(dir_body2sun_BL, dir_body2sc_BL));
yCSF_BL = vecnormalize(cross(zCSF_BL, xCSF_BL));
dcm_BL2CSF(1,1:3,:) = xCSF_BL;
dcm_BL2CSF(2,1:3,:) = yCSF_BL;
dcm_BL2CSF(3,1:3,:) = zCSF_BL;
q_BL2CSF = dcm_to_quat(dcm_BL2CSF);

% CAMI Frame
yCAMI_BL = -zCSF_BL;
zCAMI_BL = -dir_body2sc_BL;
xCAMI_BL = vecnormalize(cross(yCAMI_BL, zCAMI_BL));
dcm_BL2CAMI(1,1:3,:) = xCAMI_BL;
dcm_BL2CAMI(2,1:3,:) = yCAMI_BL;
dcm_BL2CAMI(3,1:3,:) = zCAMI_BL;
q_BL2CAMI = dcm_to_quat(dcm_BL2CAMI);

% CAM Frame
dcm_BL2BLCAM = quat_to_dcm(q_BL2BLCAM);
xCAM_BL = -dcm_BL2BLCAM(1,1:3,:);  % Blender camera has x-axis opposite to x-axis of CAM
yCAM_BL =  dcm_BL2BLCAM(2,1:3,:);
zCAM_BL = -dcm_BL2BLCAM(3,1:3,:); % Blender camera has z-axis opposite to z-axis of CAM
dcm_BL2CAM(1,1:3,:) = xCAM_BL';
dcm_BL2CAM(2,1:3,:) = yCAM_BL';
dcm_BL2CAM(3,1:3,:) = zCAM_BL';
q_BL2CAM = dcm_to_quat(dcm_BL2CAM);

% Output
q_CAMI2CAM = quat_mult(quat_conj(q_BL2CAMI), q_BL2CAM);
q_CSF2IAU = quat_mult(quat_conj(q_BL2CSF), q_BL2IAU);

if flag_debug
    R_frames2ref(:,:,1) = dcm_BL2CSF';
    R_frames2ref(:,:,2) = dcm_BL2CAMI';
    R_frames2ref(:,:,3) = quat_to_dcm(q_BL2CAM)';
    R_frames2ref(:,:,4) = quat_to_dcm(q_BL2IAU);
    R_frames2ref(:,:,5) = quat_to_dcm(q_BL2BLCAM)';
    R_pos_ref = zeros(3, 5);
    v_ref = 2*[dir_body2sun_BL, dir_body2sc_BL];
    v_pos_ref = zeros(3, 2);
    fh  = figure(); grid on; hold on; axis equal
    plot_frames_and_vectors(R_frames2ref, R_pos_ref, v_ref, v_pos_ref,...
        fh,...
        {'CSF','CAMI','CAM','IAU','BLCAM'},{'Sun','SC'});
end

end