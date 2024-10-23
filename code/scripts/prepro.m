fprintf('\n### LOADING INPUTS ###\n')

[pGeom, pNorm, pBond] = extrapolate_albedo(albedo, albedo_type, radiometry_model);
H = 5*(3.1236 - log10(2*Rbody) - 0.5*log10(pGeom)); % Absolute magnitude, https://cneos.jpl.nasa.gov/tools/ast_size_est.html
dpupil = f/fNum;
Apupil = pi*(dpupil/2)^2; % [m^2] area of the pupil
fov = 2*atan((res_px.*muPixel/2)/f); % [rad] field of view
if length(res_px) == 1 && length(muPixel) == 1
    res_px(2) = res_px(1);
    muPixel(2) = muPixel(1);
end
if length(res_px) == 2 && length(muPixel) == 1
    if res_px(1) ~= res_px(2)
        warning('Non-uniform resolution, pixel set to square shape')
    end
    muPixel(2) = muPixel(1)*res_px(2)/res_px(1);
end
if length(res_px) == 1 && length(muPixel) == 2
    if muPixel(1) ~= muPixel(2)
        warning('Non-uniform pixel size, resolution set to square shape')
    end
    res_px(2) = res_px(1);
end
sensorSize = muPixel.*res_px; % [m] physical dimension of the CCD array
K = [f./muPixel(1) 0                res_px(1)/2 + 0.5;...
     0             f./muPixel(2)    res_px(2)/2 + 0.5;...
     0             0                1]; % [-] projection matrix
ifov = fov./res_px; % [rad] angular extension of a pixel
gsd = d_body2cam*muPixel/f; % [m] ground sampling distance
bodyAngSize = atan(2*Rbody/d_body2cam); % [rad] angular size of the body
bodyPxSize = 2*Rbody./gsd;
pxActive = pi*(max(bodyPxSize)/2).^2*(1+cos(alpha))/2;
[bodyTangencyAngle, bodyBearingAngle] = find_sphere_tangent_angle(d_body2cam, Rbody);

if ~exist('image_depth','var')
    warning('Assumed Image depth equal to 8 bits')
    image_depth = 8;
end
if ~exist('G_AD','var')
    warning('Assumed A/D Gain equal to (2^image_depth-1)/FWC')
    G_AD = (2^image_depth-1)/fwc;
end
G_DA = 1/G_AD;
if ~exist('noise_floor','var')
    warning('Assumed Noise Floor equal to D/A Gain')
    noise_floor = G_DA;
end
dnr = 20*log10(fwc/noise_floor);   % [-] dynamic range, definition

% Scene
if ~exist('dcm_CAMI2CAM','var')
    dcm_CAMI2CAM = euler_to_dcm(eul_CAMI2CAM);
end
if ~exist('dcm_CSF2IAU','var')
    dcm_CSF2IAU = euler_to_dcm(eul_CSF2IAU);
end
d_cam2body = d_body2cam;
d_star2body = d_body2star;
dir_body2cam_CSF = [cos(alpha); sin(alpha); 0];
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

dcm_CSF2CAM = dcm_CAMI2CAM*dcm_CSF2CAMI;
pos_cam2body_CAM = dcm_CSF2CAM*pos_cam2body_CSF;
los_CAM = [0; 0; 1];
ang_offpoint = acos(pos_cam2body_CAM'*los_CAM/norm(pos_cam2body_CAM));

% Display ancillary data
xy_sep = '\';
disp('+++ BODY +++')
disp(['   Diameter: ', num2str(1e-3*2*Rbody),' km'])
disp(['   Albedo (geometric, normal, bond): ', num2str(pGeom),', ',num2str(pNorm),', ',num2str(pBond)])
disp(['   Absolute Magnitude: ', num2str(H)])
disp(['   Tangency angle: ', num2str(rad2deg(bodyTangencyAngle)),' deg'])

disp('+++ CAMERA +++')
disp(['   Focal: ', num2str(1e3*f),' mm'])
disp(['   F-number: ', num2str(fNum)])
disp(['   FOV: ', char(strjoin(string(rad2deg(fov)),xy_sep)),' deg, ', ...
    char(strjoin(string(res_px),xy_sep)),' px, ', ...
    char(strjoin(string(1e3*sensorSize),xy_sep)),' mm'])
disp(['   Dynamic Range: ', num2str(dnr),' dB'])

disp('+++ SCENARIO +++')
disp(['   Distance from star: ', num2str(1e-3*d_body2star),' km'])
disp(['   Distance from camera: ', num2str(1e-3*d_body2cam),' km'])
disp(['   Phase angle: ', num2str(rad2deg(alpha)),' deg'])
disp(['   Off-pointing angle: ', num2str(rad2deg(ang_offpoint)),' deg'])
disp(['   Body angular size: ', num2str(rad2deg(bodyAngSize)),' deg'])
disp(['   GSD: ', char(strjoin(string(1e-3*gsd),xy_sep)),' km'])
disp(['   Body dimension: ', char(strjoin(string(bodyPxSize),xy_sep)),' px, ', ...
    char(strjoin(string(1e2*bodyPxSize./res_px),xy_sep)),'% of resolution'])

disp('+++ PARAMS +++')
if general_parallelization
    disp(['   ', general_environment,' environment, parallelized with ', num2str(general_workers), ' workers'])
else
    disp(['   ', general_environment,' environment, single thread'])
end
disp(['   ', radiometry_model,' reflection model'])
switch gridding_method
    case 'sum'
        gridding_txt = ['sum'];
    case 'weightedsum'
        gridding_txt = ['sum weigthed on ',gridding_algorithm];
    case 'interpolation'
        gridding_txt = [gridding_interpolation ' interpolated'];
    case 'shiftedsum'
        gridding_txt = ['mean sum on ',num2str(gridding_shift),'-px shifted clouds'];
    case 'weightedshiftedsum'
        gridding_txt = ['weighted mean sum on ',num2str(gridding_shift),'-px shifted clouds with ',gridding_filter,' filter'];
end
switch reconstruction_granularity
    case 1
        reconstruction_txt = ['no grid upsampling, no reconstruction filter'];
    otherwise
        reconstruction_txt = [num2str(reconstruction_granularity),'-times grid upsampling, ', reconstruction_filter,' reconstruction filter'];
end
disp(['   ',discretization_method,' discretization, ', sampling_method,' sampling, ', integration_method,' integration, ', gridding_txt, ' gridding, ',reconstruction_txt])
disp(['   distortion: ', char(string(processing_distortion)),...
    ', diffraction: ', char(string(processing_diffraction)),...
    ', blooming: ', char(string(processing_blooming)),...
    ', noise: ', char(string(processing_noise))])