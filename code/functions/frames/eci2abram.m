function [phase_angle, d_body2cam, d_body2light, rpy_CSF2IAU, rpy_CAMI2CAM] = eci2abram(pos_origin2light_ECI, pos_origin2cam_ECI, q_ECI2CAM, pos_origin2body_ECI, q_ECI2IAU, flag_debug)

[pos_body2light_IAU, pos_body2cam_IAU, q_IAU2CAM] = eci2iau(pos_origin2light_ECI, pos_origin2cam_ECI, q_ECI2CAM, pos_origin2body_ECI, q_ECI2IAU);

[phase_angle, d_body2cam, d_body2light, rpy_CSF2IAU, rpy_CAMI2CAM] = iau2abram(pos_body2light_IAU, pos_body2cam_IAU, q_IAU2CAM, flag_debug);

end