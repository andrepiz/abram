%% PARAMETERS
% Select parameters
reflectance_model = 'lambert';          % 'lambert'
                                        % 'lommel'
                                        % 'area'
                                        % 'oren': specify roughness
                                        % 'specular': specify shineness 
                                        % 'phong': specify shineness and lambert/specular weights
                                        % 'hapke': TBD
                                        roughness = 0.5;    % roughness in oren model (>> more rough)
                                        shineness = 1;      % shineness in specular model (>> more shine)
                                        wl = 0.5; ws = 2;   % weight of lambert and specular components in Phong model            
adaptive_discretization = false;        % adaptive selects a number of sectors depending on the maximum projected arc
                                        accuracy_discretization = 'low';
                                        nsec = 2e7; % number of total pixel sectors on sphere
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
AU = 149597870707; % [m]

% Lambertian sphere of 1m @1 AU
d_body2star = AU;
Rbody = 1; % [m] body radius
pBond = 0.1; % [-] Bond albedo
[pGeom, pNorm, pBond] = extrapolate_albedo(pBond, 'bond', reflectance_model);
albedo_map = [];

%% CAMERA
% Focal plane
f = 180e-3;
muPixel = 44.1e-6; % [m] pixel size
res_px = 1440; % [px] Resolution in pixel
fov = 2*atan((res_px*muPixel/2)/f);
dpupil = 33.9e-3;
fov_shape = 'square';
% Detector
lambda_min = (425:50:975)*1e-9;
lambda_max = (475:50:1025)*1e-9;
nbw = length(lambda_min); % number of bandwidths
% T = ones(1, nbw); % Lens transmittance per BW
% QE = ones(1, nbw); % Quantum Efficiency per BW
QE = [0.35, 0.43, 0.46, 0.45, 0.42, 0.37, 0.30, 0.23, 0.16, 0.09, 0.04, 0.02]; % Quantum Efficiency per BW
T = [0.410, 0.687, 0.915, 0.954, 0.967, 0.977, 0.979, 0.982, 0.984, 0.987, 0.989, 0.992]; % Lens transmittance per BW
% AD Converter
fwc = 100e3; % [e-] from https://upverter.com/datasheet/1dbf6474f4834c5ac73294b488ac44ae8ac1f8ca.pdf
G_DA_nbit = 16;
G_DA = fwc/(2^G_DA_nbit-1);
G_AD = 1/G_DA;
G_AD_nbit = G_DA_nbit;
noise_floor = G_DA; % assumed conservatively as equal to the DN difference
snr = log10(fwc/noise_floor);   % definition

%% SCENARIO
dcm_CAMI2CAM = eye(3);
dcm_CSF2IAU = eye(3);