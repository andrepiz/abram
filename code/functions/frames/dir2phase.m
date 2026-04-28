function [phase_angle, q_IAU2CSF, dcm_IAU2CSF] = dir2phase(dir_body2light_IAU, dir_body2cam_IAU)
% Univocally define the phase angle from light and camera
% directions in body-fixed frame.

numTol = 1e-11; 

if abs(dot(dir_body2light_IAU, dir_body2cam_IAU) - 1) < numTol
    phase_angle = 0;
    q_IAU2CSF = csf(dir_body2light_IAU, dir_body2cam_IAU);
elseif abs(dot(dir_body2light_IAU, dir_body2cam_IAU) + 1) < numTol
    phase_angle = pi;
    q_IAU2CSF = csf(dir_body2light_IAU, dir_body2cam_IAU);
else
    [q_IAU2CSF, dcm_IAU2CSF, ixs_flip] = csf(dir_body2light_IAU, dir_body2cam_IAU);
    dir_body2cam_CSF = rotframe(dir_body2cam_IAU, q_IAU2CSF);
    phase_angle = abs(atan2(dir_body2cam_CSF(2), dir_body2cam_CSF(1)));
    phase_angle(ixs_flip) = -phase_angle;
end

end