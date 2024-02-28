% Geometry
dir_body2sc_CSF = [cos(alpha);sin(alpha);0];
pos_body2sc_CSF = d_body2sc*dir_body2sc_CSF; % [m] Camera position wrt Body in body frame

dir_body2sun_CSF = [1;0;0];
pos_body2sun_CSF = d_body2star*dir_body2sun_CSF;  % [m] Sun position wrt Body in body frame

pos_sc2body_CSF = -pos_body2sc_CSF;

zCAMI_CSF = pos_sc2body_CSF/d_body2sc;
yCAMI_CSF = [0; 0; -1];
xCAMI_CSF = vecnormalize(cross(yCAMI_CSF, zCAMI_CSF));
dcm_CSF2CAMI = [xCAMI_CSF, yCAMI_CSF, zCAMI_CSF]';

dcm_CSF2CAM = dcm_CAMI2CAM*dcm_CSF2CAMI;
pos_sc2body_CAM = dcm_CSF2CAM*pos_sc2body_CSF;
los_CAM = [0; 0; 1];
ang_offpoint = acos(pos_sc2body_CAM'*los_CAM/norm(pos_sc2body_CAM));

% Pupil Area
Apupil = pi*(dpupil/2)^2; % [m^2] area of the pupil

% IFOV
ifov = fov/res_px; % [rad] angular extension of a pixel

% Projection Matrix
K = [f/muPixel 0 res_px/2; 0 f/muPixel res_px/2; 0 0 1];
