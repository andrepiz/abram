function [q_REF2CSF, dcm_REF2CSF] = csf(dir_body2star_REF, dir_body2cam_REF)
% Find the orientation of the Camera-Star Frame (CSF) given the star and
% camera direction with respect to body in a reference frame (REF).

xCSF_REF = dir_body2star_REF;
zCSF_REF = vecnormalize(cross(dir_body2star_REF, dir_body2cam_REF));
ixs_sing = abs(dot(dir_body2star_REF, dir_body2cam_REF) - 1) <= eps;
if any(ixs_sing)
    zCSF_REF(:, ixs_sing) = [0; 0; 1];
end
yCSF_REF = vecnormalize(cross(zCSF_REF, xCSF_REF));
dcm_REF2CSF(1,1:3,:) = xCSF_REF;
dcm_REF2CSF(2,1:3,:) = yCSF_REF;
dcm_REF2CSF(3,1:3,:) = zCSF_REF;
q_REF2CSF = dcm_to_quat(dcm_REF2CSF);

end