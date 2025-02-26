%% 
inputs_filename = 'example2.yml';

%% STAR
star.temperature = Tstar;     % [K]
star.radius = Rstar; % [m]
star.type = star_type;

%% BODY
body.radius = Rbody; % [m] body radius
body.albedo = albedo;
body.albedo_type = albedo_type;
body.maps.albedo.filename = albedo_filename;
body.maps.albedo.depth = albedo_depth;
body.maps.albedo.mean = albedo_mean; 
body.maps.displacement.filename = displacement_filename;
body.maps.displacement.scale = displacement_scale;
body.maps.normal.filename = normal_filename;
body.maps.normal.depth = normal_depth;
body.radiometry.model = radiometry_model;
body.radiometry.roughness = 0.5;
body.radiometry.shineness = 1;
body.radiometry.weight_lambert = 0.5;
body.radiometry.weight_specular = 2;

%% CAMERA
camera.exposure_time = 0.2e-3;
camera.focal_length = 105e-3; % [m] focal length 
camera.f_number = 4; % [-] F-number (focal length over diameter)
camera.pixel_width = 5.5e-6; % [m] pixel size (single value: circle fov, two values: square fov)
camera.resolution = [1024 1024]; % [px] Resolution in pixel (single value: circle fov, two values: square fov)
camera.full_well_capacity = 100e3; % [e-] from https://upverter.com/datasheet/1dbf6474f4834c5ac73294b488ac44ae8ac1f8ca.pdf
camera.gain_analog2digital = (2^8-1)/100e3;
camera.quantum_efficiency.lambda_min = (425:50:975)*1e-9;
camera.quantum_efficiency.lambda_max = (475:50:1025)*1e-9;
camera.quantum_efficiency.values = [0.35, 0.43, 0.46, 0.45, 0.42, 0.37, 0.30, 0.23, 0.16, 0.09, 0.04, 0.02]; % Quantum Efficiency per BW
camera.quantum_efficiency.sampling = 'piecewise'; % Quantume efficiency sampling method
camera.transmittance.lambda_min = (425:50:975)*1e-9;
camera.transmittance.lambda_max = (475:50:1025)*1e-9;
camera.transmittance.values = [0.410, 0.687, 0.915, 0.954, 0.967, 0.977, 0.979, 0.982, 0.984, 0.987, 0.989, 0.992]; % Lens transmittance per BW
camera.transmittance.sampling = 'piecewise'; % Transmittance sampling method

%% SCENARIO
scene.distance_body2star = 149597870707;
scene.distance_body2cam = 366953.14e3;
scene.phase_angle = acos(2*0.82 - 1); %percAreaIlluminated = 0.82; % https://www.moongiant.com/it/fase-lunare/23/11/2023/
scene.rollpitchyaw_cami2cam = [0; 0; 0]; % [rad] Camera euler angles off-pointing (rpy). Note that yaw is optical axis
scene.rollpitchyaw_csf2iau = [0; 0; 0];  % [rad] Body euler angles rotation of Camera-Sun-Target frame wrt IAU frame

%% setting
setting.discretization.method = 'adaptive';
setting.discretization.accuracy = 'low';
setting.discretization.number_points = 5e5;

setting.sampling.method = 'projective';
setting.sampling.ignore_unobservable = true;
setting.sampling.ignore_occluded = true;
setting.sampling.occlusion_rays = 10;
setting.sampling.occlusion_angle = 'auto';

setting.integration.method = 'trapz';   
setting.integration.number_points = 10;
setting.integration.correct_incidence = true;
setting.integration.correct_reflection = true;

setting.gridding.method = 'weightedsum'; 
setting.gridding.algorithm = 'area';
setting.gridding.scheme = 'linear';
setting.gridding.window = 1;
setting.gridding.shift = 1;
setting.gridding.filter = 'gaussian';

setting.reconstruction.granularity = 1;
setting.reconstruction.filter = 'bilinear';
setting.reconstruction.antialiasing = true;

setting.processing.distortion = false;
setting.processing.diffraction = false;
setting.processing.blooming = false;
setting.processing.noise = false;

setting.saving.depth = 8;
setting.saving.format = 'png';
setting.saving.filename = 'rendering';

%% YML
inputs.star = star;
inputs.body = body;
inputs.camera = camera;
inputs.scene = scene;
inputs.setting = setting;
yaml.WriteYaml(inputs_filename, inputs, 0);
