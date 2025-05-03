function [q_REF2CAMI, dcm_REF2CAMI] = cami(dir_body2star_REF, dir_body2cam_REF)
% Find the orientation of the Camera Ideal frame (CAMI) given the star and
% camera direction with respect to body in a reference frame (REF).

zCAMI_REF = vecnormalize(-dir_body2cam_REF);
yCAMI_REF = vecnormalize(-cross(dir_body2star_REF, dir_body2cam_REF));
ixs_sing = abs(dot(dir_body2star_REF, dir_body2cam_REF) - 1) <= eps;
if any(ixs_sing)
    yCAMI_REF(:, ixs_sing) = [0; 0; -1];
end
xCAMI_REF = vecnormalize(cross(yCAMI_REF, zCAMI_REF));
dcm_REF2CAMI(1,1:3,:) = xCAMI_REF;
dcm_REF2CAMI(2,1:3,:) = yCAMI_REF;
dcm_REF2CAMI(3,1:3,:) = zCAMI_REF;
q_REF2CAMI = dcm_to_quat(dcm_REF2CAMI);

end