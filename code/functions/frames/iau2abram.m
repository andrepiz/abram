function [phase_angle, d_body2cam, d_body2star, eul_CSF2IAU, eul_CAMI2CAM] = iau2abram(pos_body2star_IAU, pos_body2cam_IAU, q_IAU2CAM, flag_debug)

% Norms
d_body2star = vecnorm(pos_body2star_IAU);
d_body2cam = vecnorm(pos_body2cam_IAU);
nd = length(d_body2cam);
if length(d_body2star) == 1
    d_body2star = repmat(d_body2star, 1, nd);
    pos_body2star_IAU = repmat(pos_body2star_IAU, 1, nd);
end

% Directions
dir_body2star_IAU = pos_body2star_IAU./d_body2star;
dir_body2cam_IAU = pos_body2cam_IAU./d_body2cam;

% Alpha angle
phase_angle = acos(dot(dir_body2star_IAU, dir_body2cam_IAU));
%ixs_sing = abs(dot(dir_body2star_IAU,dir_body2cam_IAU)-1) <= eps;

% CSF Frame
[q_IAU2CSF, dcm_IAU2CSF] = csf(dir_body2star_IAU, dir_body2cam_IAU);

% CAMI Frame
[q_IAU2CAMI, dcm_IAU2CAMI] = cami(dir_body2star_IAU, dir_body2cam_IAU);

% outputs
q_CSF2IAU = quat_conj(q_IAU2CSF);
eul_CSF2IAU = quat_to_euler(q_CSF2IAU);
q_CAMI2CAM = quat_mult(quat_conj(q_IAU2CAMI), q_IAU2CAM);
eul_CAMI2CAM = quat_to_euler(q_CAMI2CAM);

if flag_debug
    fh  = figure(); grid on; hold on; axis equal
    view([dir_body2cam_IAU(:, 1)])
    xlabel('X_{IAU}')
    ylabel('Y_{IAU}')
    zlabel('Z_{IAU}')
    ix = 0;
    while ix < nd
        ix = ix + 1;
        cla(gca)
        R_frames2ref(:,:,1) = dcm_IAU2CSF(:,:,ix)';
        R_frames2ref(:,:,2) = dcm_IAU2CAMI(:,:,ix)';
        R_frames2ref(:,:,3) = quat_to_dcm(q_IAU2CAM(:,ix))';
        R_pos_ref = 4*[zeros(3, 1), dir_body2cam_IAU(:,ix), dir_body2cam_IAU(:,ix)];
        v_ref = 2*[dir_body2star_IAU(:,ix), dir_body2cam_IAU(:,ix)];
        v_pos_ref = zeros(3, 2);
        plot_frames_and_vectors(R_frames2ref, R_pos_ref, v_ref, v_pos_ref,...
            fh,...
            {'CSF','CAMI','CAM'},{'Sun','SC'});
        pause(0.1)
    end
end

end