function [phase_angle, d_body2cam, d_body2sun, eul_CSF2IAU, eul_CAMI2CAM] = iau2abram(pos_body2sun_IAU, pos_body2cam_IAU, q_IAU2CAM, flag_debug)

% Norms
d_body2sun = vecnorm(pos_body2sun_IAU);
d_body2cam = vecnorm(pos_body2cam_IAU);

% Directions
dir_body2sun_IAU = pos_body2sun_IAU./d_body2sun;
dir_body2cam_IAU = pos_body2cam_IAU./d_body2cam;

% Alpha angle
phase_angle = acos(dot(dir_body2sun_IAU,dir_body2cam_IAU));
ixs_sing = abs(dot(dir_body2sun_IAU,dir_body2cam_IAU)-1) <= eps;

% CSF Frame
xCSF_IAU = dir_body2sun_IAU;
zCSF_IAU = vecnormalize(cross(dir_body2sun_IAU, dir_body2cam_IAU));
if any(ixs_sing)
    zCSF_IAU(:, ixs_sing) = [0; 0; 1];
end
yCSF_IAU = vecnormalize(cross(zCSF_IAU, xCSF_IAU));
dcm_IAU2CSF(1,1:3,:) = xCSF_IAU;
dcm_IAU2CSF(2,1:3,:) = yCSF_IAU;
dcm_IAU2CSF(3,1:3,:) = zCSF_IAU;
q_IAU2CSF = dcm_to_quat(dcm_IAU2CSF);
q_CSF2IAU = quat_conj(q_IAU2CSF);
eul_CSF2IAU = quat_to_euler(q_CSF2IAU);

% CAMI Frame
yCAMI_IAU = -zCSF_IAU;
zCAMI_IAU = -dir_body2cam_IAU;
xCAMI_IAU = vecnormalize(cross(yCAMI_IAU, zCAMI_IAU));
dcm_IAU2CAMI(1,1:3,:) = xCAMI_IAU;
dcm_IAU2CAMI(2,1:3,:) = yCAMI_IAU;
dcm_IAU2CAMI(3,1:3,:) = zCAMI_IAU;
q_IAU2CAMI = dcm_to_quat(dcm_IAU2CAMI);
q_CAMI2CAM = quat_mult(quat_conj(q_IAU2CAMI), q_IAU2CAM);
eul_CAMI2CAM = quat_to_euler(q_CAMI2CAM);

if flag_debug
    fh  = figure(); grid on; hold on; axis equal, view(dir_body2cam_IAU)
    xlabel('X_{IAU}')
    ylabel('Y_{IAU}')
    zlabel('Z_{IAU}')
    ix = 0;
    while ix < length(d_body2cam)
        cla(gca)
        ix = ix + 1;
        R_frames2ref(:,:,1) = dcm_IAU2CSF(:,:,ix)';
        R_frames2ref(:,:,2) = dcm_IAU2CAMI(:,:,ix)';
        R_frames2ref(:,:,3) = quat_to_dcm(q_IAU2CAM(:,ix))';
        R_pos_ref = 4*[zeros(3, 1), dir_body2cam_IAU, dir_body2cam_IAU];
        v_ref = 2*[dir_body2sun_IAU(:,ix), dir_body2cam_IAU(:,ix)];
        v_pos_ref = zeros(3, 2);
        plot_frames_and_vectors(R_frames2ref, R_pos_ref, v_ref, v_pos_ref,...
            fh,...
            {'CSF','CAMI','CAM'},{'Sun','SC'});
        pause(0.1)
    end
end

end