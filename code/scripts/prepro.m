%% PRE-PROCESSING
fprintf('\n### LOADING INPUTS ###\n')

%% Fill missing inputs
fill_inputs()

%% Compute useful quantities
% Radiometry
[pGeom, pNorm, pBond] = extrapolate_albedo(albedo, albedo_type, radiometry_model);
H = 5*(3.1236 - log10(2*Rbody) - 0.5*log10(pGeom)); % Absolute magnitude, https://cneos.jpl.nasa.gov/tools/ast_size_est.html

% Spectrum
spectrum = merge_spectra([QE_lambda_min; QE_lambda_max; QE_values], QE_sampling,...
                         [T_lambda_min; T_lambda_max; T_values], T_sampling);
lambda_min = spectrum(1,:);
lambda_max = spectrum(2,:);
QExT = spectrum(3,:);

% Camera
dpupil = f/fNum;
Apupil = pi*(dpupil/2)^2; % [m^2] area of the pupil
sensorSize = muPixel.*res_px; % [m] physical dimension of the CCD array
switch fov_type
    case 'cone'
        fov = 2*atan((res_px(1)*muPixel(1)/2)/f);
    case 'frustum'
        fov = 2*atan((res_px.*muPixel/2)/f); 
    otherwise
        error('FOV shape not supported')
end
G_DA = 1/G_AD;
dnr = 20*log10(fwc/noise_floor);   % [-] dynamic range, definition
K = [f./muPixel(1) 0                res_px(1)/2;...
     0             f./muPixel(2)    res_px(2)/2;...
     0             0                1]; % [-] projection matrix

% Camera-scene
ifov = 2*atan((muPixel/2)/f); % [rad] angular extension of a pixel at nadir
gsd = (d_body2cam - Rbody)*tan(ifov/2); % [m] ground sampling distance at nadir
[bodyTangencyAngle, bodyBearingAngle] = find_sphere_tangent_angle(d_body2cam, Rbody);
bodyAngSize = 2*bodyBearingAngle; % [rad] angular size of the body
bodyPxSize = 2*f./muPixel.*tan(bodyAngSize/2);
pxActive = pi*(max(bodyPxSize)/2).^2*(1+cos(phase_angle))/2;

% Scene
d_cam2body = d_body2cam;
d_star2body = d_body2star;
dir_body2cam_CSF = [cos(phase_angle); sin(phase_angle); 0];
dir_cam2body_CSF = -dir_body2cam_CSF;
pos_body2cam_CSF = d_body2cam*dir_body2cam_CSF; % [m] Camera position wrt Body in body frame
dir_body2star_CSF = [1;0;0];
dir_star2body_CSF = -dir_body2star_CSF;
pos_body2star_CSF = d_body2star*dir_body2star_CSF;  % [m] Sun position wrt Body in body frame
pos_cam2body_CSF = -pos_body2cam_CSF;
pos_star2body_CSF = -pos_body2star_CSF;
zCAMI_CSF = pos_cam2body_CSF/d_body2cam;
yCAMI_CSF = [0; 0; -1];
xCAMI_CSF = vecnormalize(cross(yCAMI_CSF, zCAMI_CSF));
dcm_CSF2CAMI = [xCAMI_CSF, yCAMI_CSF, zCAMI_CSF]';
dcm_CAMI2CAM = euler_to_dcm(rpy_CAMI2CAM);
dcm_CSF2IAU = euler_to_dcm(rpy_CSF2IAU);
dcm_CSF2CAM = dcm_CAMI2CAM*dcm_CSF2CAMI;
pos_cam2body_CAM = dcm_CSF2CAM*pos_cam2body_CSF;
los_CAM = [0; 0; 1];
ang_offpoint = acos(pos_cam2body_CAM'*los_CAM/norm(pos_cam2body_CAM));

%% Display inputs
display_inputs()