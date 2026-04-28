function [pos_body2sc_IAU, pos_body2origin_IAU, q_IAU2CAM, ...
            vel_sc_IAU, vel_origin_IAU] = inputs_ephemeris2abram(filename_metakernel, time_ET, ...
                                                idSpiceBody, idSpiceSc, ...
                                                idSpiceBodyFrame, idSpiceScFrame, idSpiceCamFrame, ...
                                                idSpiceOrigin, idSpiceOriginFrame, ltsCorrection)
%INPUTS_EPHEMERIS2ABRAM Compute body–SC states and attitudes from SPICE ephemerides.
%   [POS_BODY2SC_IAU, POS_BODY2ORIGIN_IAU, Q_IAU2CAM, ...
%    VEL_SC_IAU, VEL_ORIGIN_IAU] = INPUTS_EPHEMERIS2ABRAM( ...
%       FILENAME_METAKERNEL, TIME_ET, ...
%       IDSPICEBODY, IDSPICESC, ...
%       IDSPICEBODYFRAME, IDSPICESCFRAME, IDSPICECAMFRAME, ...
%       IDSPICEORIGIN, IDSPICEORIGINFRAME, LTSCORRECTION)
%   loads the SPICE meta-kernel FILENAME_METAKERNEL and, at each
%   ephemeris time in TIME_ET, computes:
%     - POS_BODY2SC_IAU: spacecraft position relative to each body,
%       expressed in the corresponding IAU body-fixed frame.
%     - POS_BODY2ORIGIN_IAU: origin position (e.g. SUN) relative to
%       each body, expressed in the corresponding IAU frame.
%     - Q_IAU2CAM: quaternion rotating vectors from each body IAU
%       frame to the camera frame.
%     - VEL_SC_IAU: spacecraft velocity in each body’s IAU frame.
%     - VEL_ORIGIN_IAU: origin velocity in each body’s IAU frame.
%
%   INPUTS:
%     FILENAME_METAKERNEL   SPICE meta-kernel including SPK/CK/FK, etc.
%     TIME_ET               1×NT vector of ephemeris times (TDB seconds past J2000).
%     IDSPICEBODY           1×NB cell array of body IDs/names (e.g. {'MOON','EARTH'}).
%     IDSPICESC             Spacecraft ID/name.
%     IDSPICEBODYFRAME      1×NB cell array of IAU body-fixed frame names.
%     IDSPICESCFRAME        Spacecraft attitude reference frame.
%     IDSPICECAMFRAME       Camera frame name.
%     IDSPICEORIGIN         (optional, default 'SUN') origin body ID/name.
%     IDSPICEORIGINFRAME    (optional, default 'J2000') inertial origin frame.
%     LTSCORRECTION         (optional, default 'NONE') SPICE light-time correction flag.

if ~exist('idSpiceOrigin','var')
    idSpiceOrigin = 'SUN';
end
if ~exist('idSpiceOriginFrame','var')
    idSpiceOriginFrame = 'J2000';
end
if ~exist('ltsCorrection','var')
    ltsCorrection = 'NONE';
end

if ~iscell(idSpiceBodyFrame)
    idSpiceBodyFrame = {idSpiceBodyFrame};
end

% Check that mice is installed
if isempty(which('mice_home.m'))
    error('MICE not found. Please install MICE from https://github.com/andrepiz/mice')
else
    addpath(genpath(mice_home()))
end

nt = length(time_ET);
nb = length(idSpiceBodyFrame);

pos_body2sc_IAU = zeros(3, nt, nb);
pos_body2origin_IAU = zeros(3, nt, nb);
q_IAU2CAM = zeros(4, nt, nb);
vel_sc_IAU = zeros(3, nt, nb);
vel_origin_IAU = zeros(3, nt, nb);

% SC
[pos_origin2sc, vel_sc] = extract_position_bodies_kernel(time_ET, idSpiceSc, filename_metakernel, ltsCorrection, idSpiceOrigin);
q_ECI2SC = extract_orientation_bodies_kernel(time_ET, idSpiceScFrame, filename_metakernel, idSpiceOriginFrame);
q_SC2CAM = extract_orientation_bodies_kernel(time_ET, idSpiceCamFrame, filename_metakernel, idSpiceScFrame);

for ix = 1:nb

% Position
idSpiceBodyTemp = idSpiceBody{ix};
[pos_origin2body, vel_body] = extract_position_bodies_kernel(time_ET, idSpiceBodyTemp, filename_metakernel, ltsCorrection, idSpiceOrigin);
pos_body2sc = pos_origin2sc - pos_origin2body;

% Orientation
idSpiceBodyFrameTemp = idSpiceBodyFrame{ix};
q_ECI2IAU = extract_orientation_bodies_kernel(time_ET, idSpiceBodyFrameTemp, filename_metakernel, idSpiceOriginFrame);
q_IAU2SC = quat_mult(quat_conj(q_ECI2IAU), q_ECI2SC);
q_IAU2CAM(:, :, ix) = quat_mult(q_IAU2SC, q_SC2CAM);

% Results
pos_body2sc_IAU(:, :, ix) = rotframe(pos_body2sc, q_ECI2IAU);
vel_sc_IAU(:, :, ix) = rotframe(vel_sc, q_ECI2IAU);

pos_body2origin_IAU(:, :, ix) = rotframe(-pos_origin2body, q_ECI2IAU);
vel_origin_IAU(:, :, ix) = rotframe(-vel_body, q_ECI2IAU);

end

end
