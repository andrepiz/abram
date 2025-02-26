%% STAR
Tstar  = extract_struct(inputs.star, 'temperature', 5782, true);
Rstar = extract_struct(inputs.star, 'radius', 695000e3, true);
star_type = extract_struct(inputs.star, 'type', 'bb');

%% BODY
inputs.body = add_missing_field(inputs.body, 'maps');
inputs.body.maps = add_missing_field(inputs.body.maps, {'albedo','displacement','normal'});

Rbody = extract_struct(inputs.body, 'radius');
albedo = extract_struct(inputs.body, 'albedo');
albedo_type = extract_struct(inputs.body, 'albedo_type', 'geometric', true);
% maps
albedo_filename = extract_struct(inputs.body.maps.albedo, 'filename',[]);
albedo_depth = extract_struct(inputs.body.maps.albedo, 'depth', 1);
albedo_mean = extract_struct(inputs.body.maps.albedo, 'mean', []);
albedo_scale = extract_struct(inputs.body.maps.albedo, 'scale', []);
albedo_domain = extract_struct(inputs.body.maps.albedo, 'domain', []);
albedo_gamma = extract_struct(inputs.body.maps.albedo, 'gamma', []);
displacement_filename = extract_struct(inputs.body.maps.displacement, 'filename',[]);
displacement_depth = extract_struct(inputs.body.maps.displacement, 'depth', 1);
displacement_mean = extract_struct(inputs.body.maps.displacement, 'mean', []);
displacement_scale = extract_struct(inputs.body.maps.displacement, 'scale', []);
displacement_domain = extract_struct(inputs.body.maps.displacement, 'domain', []);
displacement_gamma = extract_struct(inputs.body.maps.displacement, 'gamma', []);
normal_filename = extract_struct(inputs.body.maps.normal, 'filename',[]);
normal_depth = extract_struct(inputs.body.maps.normal, 'depth', 1);
normal_mean = extract_struct(inputs.body.maps.normal, 'mean', []);
normal_scale = extract_struct(inputs.body.maps.normal, 'scale', []);
normal_domain = extract_struct(inputs.body.maps.normal, 'domain', []);
normal_gamma = extract_struct(inputs.body.maps.normal, 'gamma', []);
normal_frame = extract_struct(inputs.body.maps.normal, 'frame', 'local');
% Radiometry
radiometry_model = extract_struct(inputs.body.radiometry, 'model','lambert', true);
radiometry_roughness = extract_struct(inputs.body.radiometry, 'roughness', 0.5);
radiometry_shineness = extract_struct(inputs.body.radiometry, 'shineness', 1);
radiometry_weight_lambert = extract_struct(inputs.body.radiometry, 'weight_lambert', 0.5);
radiometry_weight_specular = extract_struct(inputs.body.radiometry, 'weight_specular', 0.5);
radiometry_parameters = extract_struct(inputs.body.radiometry, 'parameters', [0.25, 0.3, 0, 1, 2.2, 0.07, 0.4, 1]);

%% CAMERA
inputs.camera = add_missing_field(inputs.camera, {'quantum_efficiency','transmittance','distortion','noise'});

tExp = extract_struct(inputs.camera, 'exposure_time');
f = extract_struct(inputs.camera, 'focal_length');
fNum = extract_struct(inputs.camera, 'f_number');
muPixel = extract_struct(inputs.camera, 'pixel_width');
res_px = extract_struct(inputs.camera, 'resolution');
fwc = extract_struct(inputs.camera, 'full_well_capacity');
G_AD = extract_struct(inputs.camera, 'gain_analog2digital');            
amplification = extract_struct(inputs.camera,'amplification', 0);
offset = extract_struct(inputs.camera, 'offset',0);
QE_lambda_min = extract_struct(inputs.camera.quantum_efficiency, 'lambda_min', 450E-9);
QE_lambda_max = extract_struct(inputs.camera.quantum_efficiency, 'lambda_max', 820E-9);
QE_sampling = extract_struct(inputs.camera.quantum_efficiency, 'sampling', 'piecewise');
QE_values = extract_struct(inputs.camera.quantum_efficiency, 'values', ones(1, length(QE_lambda_min)));
T_lambda_min = extract_struct(inputs.camera.transmittance, 'lambda_min', 450E-9);
T_lambda_max = extract_struct(inputs.camera.transmittance, 'lambda_max', 820E-9);
T_sampling = extract_struct(inputs.camera.transmittance, 'sampling', 'piecewise');
T_values = extract_struct(inputs.camera.transmittance, 'values', ones(1, length(T_lambda_min)));
noise_floor = extract_struct(inputs.camera, 'noise_floor', 1/G_AD);
distortion.radial = extract_struct(inputs.camera.distortion,'radial',[0 0 0]);
distortion.decentering = extract_struct(inputs.camera.distortion,'decentering',[0 0]);
noise.shot = extract_struct(inputs.camera.noise, 'shot', struct('flag',false,'seed',0));
noise.prnu = extract_struct(inputs.camera.noise, 'prnu', struct('flag',false,'sigma',0,'seed',0));
noise.dark = extract_struct(inputs.camera.noise, 'dark', struct('flag',false,'sigma',0,'mean',0,'seed',0));
noise.readout = extract_struct(inputs.camera.noise, 'readout', struct('flag',false,'sigma',0,'seed',0));

%% SCENE
d_body2star = extract_struct(inputs.scene, 'distance_body2star');
d_body2cam = extract_struct(inputs.scene, 'distance_body2cam');
phase_angle = extract_struct(inputs.scene, 'phase_angle');
rpy_CAMI2CAM = reshape(extract_struct(inputs.scene, 'rollpitchyaw_cami2cam', zeros(1,3), true), 3, 1);
rpy_CSF2IAU = reshape(extract_struct(inputs.scene, 'rollpitchyaw_csf2iau', zeros(1,3), true), 3, 1);

%% SETTING
inputs.setting = add_missing_field(inputs.setting, {'general','discretization','sampling','integration','gridding','reconstruction','saving'});

% General
general_environment = extract_struct(inputs.setting.general, 'environment','matlab');
general_parallelization = extract_struct(inputs.setting.general, 'parallelization', false);
general_workers = extract_struct(inputs.setting.general, 'workers', 'auto');
% Discretization
discretization_method = extract_struct(inputs.setting.discretization, 'method','adaptive');
discretization_np = extract_struct(inputs.setting.discretization, 'number_points', 1e5);
discretization_accuracy = extract_struct(inputs.setting.discretization, 'accuracy','medium');
% Sampling
sampling_method = extract_struct(inputs.setting.sampling, 'method', 'projecteduniform');
sampling_ignore_unobservable = extract_struct(inputs.setting.sampling, 'ignore_unobservable', true);
sampling_ignore_occluded = extract_struct(inputs.setting.sampling, 'ignore_occluded', true);
sampling_occlusion_rays = extract_struct(inputs.setting.sampling, 'occlusion_rays', 10);
sampling_occlusion_angle = extract_struct(inputs.setting.sampling, 'occlusion_angle', 'auto');
% Integration
integration_method = extract_struct(inputs.setting.integration, 'method','trapz');
integration_np = extract_struct(inputs.setting.integration, 'number_points', 'auto');
integration_correct_incidence = extract_struct(inputs.setting.integration, 'correct_incidence', true);
integration_correct_reflection = extract_struct(inputs.setting.integration, 'correct_reflection', true);
% Gridding
gridding_method = extract_struct(inputs.setting.gridding, 'method', 'weightedsum');
gridding_window = extract_struct(inputs.setting.gridding, 'window', 1);
gridding_algorithm = extract_struct(inputs.setting.gridding, 'algorithm', 'area');
gridding_scheme = extract_struct(inputs.setting.gridding, 'scheme', 'linear');
gridding_shift = extract_struct(inputs.setting.gridding, 'shift', 1);
gridding_filter = extract_struct(inputs.setting.gridding, 'filter', 'gaussian');
% Reconstruction
reconstruction_granularity = extract_struct(inputs.setting.reconstruction, 'granularity', 1);
if ~strcmp(reconstruction_granularity,'auto')
    if mod(reconstruction_granularity, 1) ~= 0
        error('Reconstruction granularity must be an integer equal or larger than 1')
    end
end
reconstruction_filter = extract_struct(inputs.setting.reconstruction, 'filter', 'bilinear');
reconstruction_antialiasing = extract_struct(inputs.setting.reconstruction, 'antialiasing', true);
% Processing
processing_distortion = extract_struct(inputs.setting.processing, 'distortion', false);
processing_diffraction = extract_struct(inputs.setting.processing, 'diffraction', false);
processing_blooming = extract_struct(inputs.setting.processing, 'blooming', false);
processing_noise = extract_struct(inputs.setting.processing, 'noise', false);
% Saving
saving_depth = extract_struct(inputs.setting.saving, 'depth', 8);
saving_filename = extract_struct(inputs.setting.saving, 'filename', []);
saving_format = extract_struct(inputs.setting.saving, 'format', 'png');