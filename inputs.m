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
                                        nsec = 5e5; % number of total pixel sectors on sphere
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
% Select star
get_star()

%% BODY
% Select body
% 0. 1m sphere @1 AU
% 1. Moon
% 2. Mars
% 3. Bennu
% 10. Moon w/o texture
% 20. Mars w/o texture
case_body = 1;

get_body()

%% CAMERA
% Select camera
% 1. LUMIO CAM - VIS
% 2. LUMIO CAM - NIR
% 3. LEONARDO AA-STR        
% 4. MARS COLOR CAMERA (ISRU)
% 5. TINYV3ERSE
% 6. IDEAL
case_camera = 6;

get_camera();

%% SCENARIO
% Select scenario
% 1. Leonardo STR imaging @23/11/2023
% 2. Mars imaging by ISRU
% 3. Extraction from Corto inputs
% 4. Lumio
case_scenario = 4; 

get_scenario();

% % % Overwrite if needed
% fov_shape = 'square';
%tExp = 0.04e-3; alpha = deg2rad(120); d_body2sc = 25e6; eul_CAMI2CAM = [deg2rad(0.5);deg2rad(3);deg2rad(130)]; % Moon 2
%tExp = 0.04e-3; alpha = deg2rad(0); d_body2sc = 120e6; eul_CSF2IAU = [pi + deg2rad(45); deg2rad(-12); deg2rad(25)];  % Mars 1
%tExp = 0.04e-3; alpha = deg2rad(40); d_body2sc = 80e6; eul_CAMI2CAM = [deg2rad(-1);deg2rad(-1);deg2rad(40)]; % Mars 2

% eul_CAMI2CAM = [deg2rad(0);deg2rad(0);deg2rad(0)];                     % [rad] Camera euler angles off-pointing (rpy). Note that yaw is optical axis
% eul_CSF2IAU = [0; deg2rad(0); deg2rad(0)];  % [rad] Body-fixed frame rotation wrt CSF frame
%    % post-process
%    dcm_CAMI2CAM = euler_to_dcm(eul_CAMI2CAM);
%    dcm_CSF2IAU = euler_to_dcm(eul_CSF2IAU);