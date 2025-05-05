function [phase_angle, d_body2cam, d_body2star, rpy_CSF2IAU, rpy_CAMI2CAM] = eci2abram(pos_origin2star_ECI, pos_origin2cam_ECI, q_ECI2CAM, pos_origin2body_ECI, q_ECI2IAU, flag_debug)


pos_body2star_ECI = pos_origin2star_ECI - pos_origin2body_ECI;
pos_body2cam_ECI = pos_origin2cam_ECI - pos_origin2body_ECI;
dcm_ECI2IAU = quat_to_dcm(q_ECI2IAU);
pos_body2star_IAU = reshape(pagemtimes(dcm_ECI2IAU, reshape(pos_body2star_ECI, 3, 1, [])), 3, []);
pos_body2cam_IAU = reshape(pagemtimes(dcm_ECI2IAU, reshape(pos_body2cam_ECI, 3, 1, [])), 3, []);
q_IAU2CAM = quat_mult(quat_conj(q_ECI2IAU), q_ECI2CAM);

[phase_angle, d_body2cam, d_body2star, rpy_CSF2IAU, rpy_CAMI2CAM] = iau2abram(pos_body2star_IAU, pos_body2cam_IAU, q_IAU2CAM, flag_debug);

end