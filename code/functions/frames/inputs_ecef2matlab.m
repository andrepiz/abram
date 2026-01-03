function [d_body2light, d_body2cam, phase_angle, q_CAMI2CAM, q_CSF2IAU] = ...
            inputs_ecef2matlab(time_UTC, altlonlatCam, q_ENU2CAM, metakernel_filepath, spice_body_identifier)

% Convert data to ECI using SPICE
alt = altlonlatCam(1,:);
lon = altlonlatCam(2,:);
lat = altlonlatCam(3,:);
posCamera_ECEF = altlonlat2ecef(alt, lon, lat);
[posCamera_ECI, q_ECEF2ECI] = convert_position_kernel(time_UTC, 'ITRF93', 'J2000', posCamera_ECEF, metakernel_filepath);

% ENU Frame
xENU_ECEF = [-sin(lon); cos(lon); zeros(1, length(lon))];
yENU_ECEF = [-sin(lat) * cos(lon); -sin(lat) * sin(lon); cos(lat)];
zENU_ECEF = [cos(lat) * cos(lon); cos(lat) * sin(lon); sin(lat)];
dcm_ECEF2ENU(1,1:3,:) = xENU_ECEF;
dcm_ECEF2ENU(2,1:3,:) = yENU_ECEF;
dcm_ECEF2ENU(3,1:3,:) = zENU_ECEF;
q_ECEF2ENU = dcm_to_quat(dcm_ECEF2ENU);
q_ECI2ENU = quat_mult(quat_conj(q_ECEF2ECI), q_ECEF2ENU);

%---Get SPICE data
posSpice_ECI = extract_position_bodies_kernel(time_UTC, {'SUN',spice_body_identifier}, metakernel_filepath);
q_ECI2IAU = extract_orientation_bodies_kernel(time_UTC, {spice_body_identifier}, metakernel_filepath);

% Extract directions
posLight_ECI = posSpice_ECI(1:3, :);
posBody_ECI = posSpice_ECI(4:6, :); 
pos_body2light_ECI = posLight_ECI - posBody_ECI;
pos_body2cam_ECI = posCamera_ECI - posBody_ECI;
dir_body2light_ECI = vecnormalize(pos_body2light_ECI);
dir_body2cam_ECI = vecnormalize(pos_body2cam_ECI);

% CSF Frame
q_ECI2CSF = csf(dir_body2light_ECI, dir_body2cam_ECI);

% CAMI Frame
q_ECI2CAMI = cami(dir_body2light_ECI, dir_body2cam_ECI);

%---Assign data
d_body2light = vecnorm(pos_body2light_ECI);     
d_body2cam = vecnorm(pos_body2cam_ECI);            
phase_angle = acos(dot(dir_body2cam_ECI, dir_body2light_ECI));  
q_ECI2CAM = quat_mult(q_ECI2ENU, q_ENU2CAM);
q_CAMI2CAM = quat_mult(quat_conj(q_ECI2CAMI), q_ECI2CAM);
q_CSF2IAU = quat_mult(quat_conj(q_ECI2CSF), q_ECI2IAU);

end