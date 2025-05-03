function [d_body2star, d_body2cam, phase_angle, q_CAMI2CAM, q_CSF2IAU] = ...
            inputs_eci2matlab(time_UTC, posCamera_ECI, q_ECI2CAM, metakernel_filepath, spice_body_identifier)

%---Get SPICE data
posSpice_ECI = extract_position_bodies_kernel(time_UTC, {'SUN',spice_body_identifier}, metakernel_filepath);
q_ECI2IAU = extract_orientation_bodies_kernel(time_UTC, {spice_body_identifier}, metakernel_filepath);

% Extract directions
posStar_ECI = posSpice_ECI(1:3, :);
posBody_ECI = posSpice_ECI(4:6, :); 
pos_body2star_ECI = posStar_ECI - posBody_ECI;
pos_body2cam_ECI = posCamera_ECI - posBody_ECI;
dir_body2star_ECI = vecnormalize(pos_body2star_ECI);
dir_body2cam_ECI = vecnormalize(pos_body2cam_ECI);

% CSF Frame
% xCSF_ECI = dir_body2star_ECI;
% if abs(dot(dir_body2star_ECI, dir_body2cam_ECI)) == 1
%     % Singularity due to alignment of Sun
%     % direction and Camera direction in CSF.
%     zCSF_ECI = [0; 0; 1];
% else
%     zCSF_ECI = vecnormalize(cross(dir_body2star_ECI, dir_body2cam_ECI));
% end
% yCSF_ECI = vecnormalize(cross(zCSF_ECI, xCSF_ECI));
% dcm_ECI2CSF(1,1:3,:) = xCSF_ECI;
% dcm_ECI2CSF(2,1:3,:) = yCSF_ECI;
% dcm_ECI2CSF(3,1:3,:) = zCSF_ECI;
% q_ECI2CSF = dcm_to_quat(dcm_ECI2CSF);
q_ECI2CSF = csf(dir_body2star_ECI, dir_body2cam_ECI);

% CAMI Frame
% yCAMI_ECI = -zCSF_ECI;
% zCAMI_ECI = -dir_body2cam_ECI;
% xCAMI_ECI = vecnormalize(cross(yCAMI_ECI, zCAMI_ECI));
% dcm_ECI2CAMI(1,1:3,:) = xCAMI_ECI;
% dcm_ECI2CAMI(2,1:3,:) = yCAMI_ECI;
% dcm_ECI2CAMI(3,1:3,:) = zCAMI_ECI;
% q_ECI2CAMI = dcm_to_quat(dcm_ECI2CAMI);
q_ECI2CAMI = cami(dir_body2star_ECI, dir_body2cam_ECI);

%---Assign data
d_body2star = vecnorm(pos_body2star_ECI);     
d_body2cam = vecnorm(pos_body2cam_ECI);            
phase_angle = acos(dot(dir_body2cam_ECI, dir_body2star_ECI));  
q_CAMI2CAM = quat_mult(quat_conj(q_ECI2CAMI), q_ECI2CAM);
q_CSF2IAU = quat_mult(quat_conj(q_ECI2CSF), q_ECI2IAU);

end