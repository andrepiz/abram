function [pos_body2light_IAU, pos_body2cam_IAU, q_IAU2CAM] = eci2iau(pos_origin2light_ECI, pos_origin2cam_ECI, q_ECI2CAM, pos_origin2body_ECI, q_ECI2IAU)

pos_body2light_ECI = pos_origin2light_ECI - pos_origin2body_ECI;
pos_body2cam_ECI = pos_origin2cam_ECI - pos_origin2body_ECI;
dcm_ECI2IAU = quat_to_dcm(q_ECI2IAU);
pos_body2light_IAU = reshape(pagemtimes(dcm_ECI2IAU, reshape(pos_body2light_ECI, 3, 1, [])), 3, []);
pos_body2cam_IAU = reshape(pagemtimes(dcm_ECI2IAU, reshape(pos_body2cam_ECI, 3, 1, [])), 3, []);
q_IAU2CAM = quat_mult(quat_conj(q_ECI2IAU), q_ECI2CAM);

end