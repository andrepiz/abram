%% PARAMETERS
% Select parameters
reflectance_model = 'oren';          % 'lambert'
                                        % 'lommel'
                                        % 'area'
                                        % 'oren': specify roughness
                                        % 'specular': specify shineness 
                                        % 'phong': specify shineness and lambert/specular weights
                                        % 'hapke': TBD
                                        roughness = 0.3;    % roughness in oren model (>> more rough)
                                        shineness = 1;      % shineness in specular model (>> more shine)
                                        wl = 0.5; ws = 2;   % weight of lambert and specular components in Phong model            
adaptive_discretization = false;        % adaptive selects a number of sectors depending on the maximum projected arc
                                        accuracy_discretization = 'low';
                                        nsec = 2e6; % number of total pixel sectors on sphere
integration_method = 'trapz';           % 'integral': integral2 is used
                                        % 'trapz':    trapz is used. much faster with less than 1% of error
                                        nint = 10;  % number of evaluation points for trapz
ignore_unobservable = true;             % ignore sectors that fall outside the tangency circle
method_sphere_sampling = 'projective';  % 'uniform' sampling of longitude and latitude points uniformly on the sphere
                                        % 'projective' sampling of longitude and latitude points that are approximately spread uniformly on the projected sphere
method_binning = 'weightedsum';         % 'sum' sums all the intensity values falling within the same pixel
                                        % 'weightedsum' weighs each intensity value spreading it across the neighbouring pixels
                                        % 'interpolation' interpolate the intensity value at the sector midpoints (NOTE: Not physically consistent!)
                                        method_weightedsum = 'area';            % 'invsquared' Inverse squared distance with each vertex
                                                                                % 'diff' 1 minus distance normalized over maximum distance
                                                                                % 'area' use [1x1] boxes for computing the weights
                                        method_interpolation = 'linear';        % 'nearest' 
                                                                                % 'linear' 
                                                                                % 'cubic'
granularity = 1;                        % Down-sampling of pixels
apply_observation_correction = true;    % Correct incidence angle with true incidence angle with low distance-to-radius ratios

%% STAR 
Tstar = 5782;     % [K]
Rstar = 695000e3; % [m]

%% BODY
% Moon w/o texture
d_body2star = params.d_body2sun;
Rbody = 1.7374e6; % [m] body radius
pGeom = 0.10; 
[pGeom, pNorm, pBond] = extrapolate_albedo(pGeom, 'geometric', reflectance_model);
%albedo_map = [];
        albedo_map = 'lroc_color_poles_2k.tif';
        albedo_nbit = 8;
        rescale_albedo = true;                 % Rescale albedo map to return a mean albedo equal to the geometric albedo

%% CAMERA
% From User Manual:
%Saturation 300 000 electrons
%Spectral response 650 nm, 50% at 500nm and 800nm
%Efficiency >15% at 640 nm
%Dynamic 80 dB

lambda_min = params.lambda_min:100e-9:params.lambda_max-100e-9;
lambda_max = params.lambda_min+100e-9:100e-9:params.lambda_max;
nbw = length(lambda_min);
T = get_amie_spectral_response(lambda_min, lambda_max);
QE = 0.15; % as stated in the user manual

f = params.f;
fNum = params.fNum;
dpupil = f/fNum;
muPixel = params.muPixel; % [m] pixel size
res_px = params.res_px; % [px] Resolution in pixel
fov = params.fov;
fov_shape = 'square';

fwc = 300e3; % as stated in the user manual
G_DA_nbit = 10;
G_DA = params.G_DA;
G_AD = 1/G_DA;
G_AD_nbit = G_DA_nbit;

%% SCENARIO
tExp = params.tExp;
alpha = params.alpha;
d_body2sc = params.d_body2cam;
q_CSF2IAU = params.q_CSF2IAU;
q_CAMI2CAM = params.q_CAMI2CAM;
    % post-process
    dcm_CAMI2CAM = quat_to_dcm(q_CAMI2CAM);
    dcm_CSF2IAU = quat_to_dcm(q_CSF2IAU);