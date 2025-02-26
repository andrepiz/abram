function inputs_corto = inputs_matlab2corto(alpha, d_body2cam, d_body2sun, q_CSF2IAU, q_CAMI2CAM, scaling_blender)
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
%   z-axis cross vector between sun direction and camera direction
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

dir_body2cam_CSF = [cos(alpha); sin(alpha); 0];
pos_body2cam_CSF = d_body2cam*dir_body2cam_CSF; % [m] Camera position wrt Body in body frame
dir_body2sun_CSF = [1;0;0];
pos_body2sun_CSF = d_body2sun*dir_body2sun_CSF;  % [m] Sun position wrt Body in body frame
dcm_CAMI2CAM = quat_to_dcm(q_CAMI2CAM);
dcm_CSF2IAU = quat_to_dcm(q_CSF2IAU);

% IAU frame is set to coincide with BL frame
q_BL2IAU = [1; 0; 0; 0];
dcm_BL2IAU = quat_to_dcm(q_BL2IAU);
dcm_CSF2BL = dcm_BL2IAU'*dcm_CSF2IAU;
dir_body2cam_BL = vecnormalize(dcm_CSF2BL*pos_body2cam_CSF);
dir_body2sun_BL = vecnormalize(dcm_CSF2BL*pos_body2sun_CSF);

% zCSF
if abs(dot(dir_body2sun_BL, dir_body2cam_BL)) == 1
    % Singularity due to alignment of Sun
    % direction and Camera direction in CSF.
    zCSF_BL = [0; 0; 1];
else
    zCSF_BL = vecnormalize(cross(dir_body2sun_BL, dir_body2cam_BL));
    %zCSF_BL = sign(alpha).*vecnormalize(cross(dir_body2sun_BL, dir_body2cam_BL));
end

% CAMI
zCAMI_BL = -dir_body2cam_BL;
yCAMI_BL = -zCSF_BL;
xCAMI_BL = vecnormalize(cross(yCAMI_BL, zCAMI_BL));
dcm_BL2CAMI(1,1:3,:) = xCAMI_BL;
dcm_BL2CAMI(2,1:3,:) = yCAMI_BL;
dcm_BL2CAMI(3,1:3,:) = zCAMI_BL;

% BLCAM
xBLCAM_CAM = [1;0;0];
yBLCAM_CAM = [0;-1;0]; % Blender camera has y-axis opposite to y-axis of CAM
zBLCAM_CAM = [0;0;-1]; % Blender camera has z-axis opposite to z-axis of CAM
dcm_CAM2BLCAM(1,1:3,:) = xBLCAM_CAM;
dcm_CAM2BLCAM(2,1:3,:) = yBLCAM_CAM;
dcm_CAM2BLCAM(3,1:3,:) = zBLCAM_CAM;

dcm_BL2BLCAM = dcm_CAM2BLCAM*dcm_CAMI2CAM*dcm_BL2CAMI;
q_BL2BLCAM = dcm_to_quat(dcm_BL2BLCAM);

% Body position is set to origin
pos_blend2body_BL = [0; 0; 0];
pos_blend2cam_BL = pos_blend2body_BL + dcm_CSF2BL*pos_body2cam_CSF;
pos_blend2sun_BL = pos_blend2body_BL + dcm_CSF2BL*pos_body2sun_CSF;

% Output creation
inputs_corto(1) = 0;
inputs_corto(2:4) = 1/scaling_blender*pos_blend2body_BL;
inputs_corto(5:8) = q_BL2IAU;
inputs_corto(9:11)= 1/scaling_blender*pos_blend2cam_BL;
inputs_corto(12:15)= q_BL2BLCAM;
inputs_corto(16:18)= 1/scaling_blender*pos_blend2sun_BL;

end