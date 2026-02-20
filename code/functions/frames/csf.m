function [q_REF2CSF, dcm_REF2CSF] = csf(dir_body2star_REF, dir_body2cam_REF)
% Find the orientation of the Camera-Star Frame (CSF) given the star and
% camera direction with respect to body in a reference frame (REF).

xCSF_REF = dir_body2star_REF;
zCSF_REF = cross(xCSF_REF, dir_body2cam_REF);
ixs_sing = vecnorm(zCSF_REF) <= eps;
if any(ixs_sing)
    zCSF_REF(:, ixs_sing) = cross(xCSF_REF, repmat([0; 1; 0], 1, size(xCSF_REF, 2)));
    ixs_sing = vecnorm(zCSF_REF) <= eps;
    if any(ixs_sing)
        zCSF_REF(:, ixs_sing) = cross(xCSF_REF, repmat([-1; 0; 0], 1, size(xCSF_REF, 2)));
    end
end
zCSF_REF = vecnormalize(zCSF_REF);
yCSF_REF = vecnormalize(cross(zCSF_REF, xCSF_REF));
dcm_REF2CSF(1,1:3,:) = xCSF_REF;
dcm_REF2CSF(2,1:3,:) = yCSF_REF;
dcm_REF2CSF(3,1:3,:) = zCSF_REF;
q_REF2CSF = dcm_to_quat(dcm_REF2CSF);

end