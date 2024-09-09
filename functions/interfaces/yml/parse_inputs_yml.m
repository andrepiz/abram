%% STAR
Tstar  = extract_struct(inputs.star, 'temperature', 5782);
Rstar = extract_struct(inputs.star, 'radius', 695000e3);

%% BODY
Rbody = extract_struct(inputs.body, 'radius', 1.7374e6);
albedo = extract_struct(inputs.body, 'albedo', 0.12);
albedo_type = extract_struct(inputs.body, 'albedo_type', 'geometric');
% MAPS
% Albedo
if isfield(inputs.body.map, 'albedo')
    albedo_filename = extract_struct(inputs.body.map.albedo, 'filename', 'lroc_color_poles_2k.tif');
    if ~isempty(albedo_filename)
        albedo_depth = extract_struct(inputs.body.map.albedo, 'depth', 8);
        if isempty(albedo_depth)
            albedo_depth = 1;
        end
        albedo_mean = extract_struct(inputs.body.map.albedo, 'mean', 0.12);
        albedo_scale = extract_struct(inputs.body.map.albedo, 'scale', []);
        albedo_domain = extract_struct(inputs.body.map.albedo, 'domain', []);
        albedo_gamma = extract_struct(inputs.body.map.albedo, 'gamma', []);
    end
else
    albedo_filename = [];
end
% Displacement
if isfield(inputs.body.map, 'displacement')
    displacement_filename = extract_struct(inputs.body.map.displacement, 'filename', 'ldem_4.tif');
    if ~isempty(displacement_filename)
        displacement_depth = extract_struct(inputs.body.map.displacement, 'depth', 1);
        if isempty(displacement_depth)
            displacement_depth = 1;
        end
        displacement_mean = extract_struct(inputs.body.map.displacement, 'mean', []);
        displacement_scale = extract_struct(inputs.body.map.displacement, 'scale', 1e3);
        displacement_domain = extract_struct(inputs.body.map.displacement, 'domain', []);
        displacement_gamma = extract_struct(inputs.body.map.displacement, 'gamma', []);
    end
else
    displacement_filename = [];
end
% Normal
if isfield(inputs.body.map, 'normal')
    normal_filename = extract_struct(inputs.body.map.normal, 'filename', 'ldem_4_normal.png');
    if ~isempty(normal_filename)
        normal_depth = extract_struct(inputs.body.map.normal, 'depth', 16);
        if isempty(normal_depth)
            normal_depth = 1;
        end
        normal_mean = extract_struct(inputs.body.map.normal, 'mean', []);
        normal_scale = extract_struct(inputs.body.map.normal, 'scale', []);
        normal_domain = extract_struct(inputs.body.map.normal, 'domain', []);
        normal_gamma = extract_struct(inputs.body.map.normal, 'gamma', []);
    end
else
    normal_filename = [];
end
% Radiometry
radiometry_model = extract_struct(inputs.body.radiometry, 'model','lambert');
switch radiometry_model
    case 'oren'
        radiometry_ro = extract_struct(inputs.body.radiometry, 'roughness',0.5);
    case 'specular'
        radiometry_sh = extract_struct(inputs.body.radiometry, 'shineness',1);
    case 'phong'
        radiometry_wl = extract_struct(inputs.body.radiometry, 'weight_lambert',0.5);
        radiometry_ws = extract_struct(inputs.body.radiometry, 'weight_specular',0.5);
end

%% CAMERA
tExp = extract_struct(inputs.camera, 'exposure_time', 200e-3);
f = extract_struct(inputs.camera, 'focal_length', 105e-3);
fNum = extract_struct(inputs.camera, 'f_number', 4);
muPixel = extract_struct(inputs.camera, 'pixel_width', 5.5e-6);
res_px = extract_struct(inputs.camera, 'resolution', [1024 1024]);
fwc = extract_struct(inputs.camera, 'full_well_capacity', 100e3);
image_depth = extract_struct(inputs.camera,'image_depth', 8);
G_AD = extract_struct(inputs.camera, 'gain_analog2digital', (2^image_depth-1)/fwc);
lambda_min = extract_struct(inputs.camera, 'lambda_min', (425:50:975)*1e-9);
lambda_max = extract_struct(inputs.camera, 'lambda_max', (475:50:1025)*1e-9);
QE = extract_struct(inputs.camera, 'quantum_efficiency', ones(1, length(lambda_min)));
T = extract_struct(inputs.camera, 'transmittivity', ones(1, length(lambda_min)));
lambda_interpolation = extract_struct(inputs.camera, 'lambda_interpolation', 'constant');
noise_floor = extract_struct(inputs.camera, 'noise_floor', 1/G_AD);

%% SCENE
d_body2star = extract_struct(inputs.scenario, 'distance_body2star', 149597870707);
d_body2sc = extract_struct(inputs.scenario, 'distance_body2cam', 366953.14e3);
alpha = extract_struct(inputs.scenario, 'phase_angle', rad2deg(50));
eul_CAMI2CAM = reshape(extract_struct(inputs.scenario, 'rollpitchyaw_cami2cam', [0;0;0]), 3, 1);
eul_CSF2IAU = reshape(extract_struct(inputs.scenario, 'rollpitchyaw_csf2iau', [0;0;0]), 3, 1);

%% PARAMS
% Discretization
discretization_method = extract_struct(inputs.params.discretization, 'method','adaptive');
switch discretization_method
    case 'fixed'
        discretization_np = extract_struct(inputs.params.discretization, 'number_points', 1e5);
    case 'adaptive'
        discretization_accuracy = extract_struct(inputs.params.discretization, 'accuracy','medium');
end
% Sampling
sampling_method = extract_struct(inputs.params.sampling, 'method', 'projective');
sampling_ignore_unobservable = extract_struct(inputs.params.sampling, 'ignore_unobservable', true);
% Integration
integration_method = extract_struct(inputs.params.integration, 'method','trapz');
switch integration_method
    case 'trapz'
        integration_np = extract_struct(inputs.params.integration, 'number_points', 10);
end
integration_correct_incidence = extract_struct(inputs.params.integration, 'correct_incidence', true);
% Binning
binning_method = extract_struct(inputs.params.binning, 'method', 'weightedsum');
binning_algorithm = extract_struct(inputs.params.binning, 'algorithm', 'area');
binning_interpolation = extract_struct(inputs.params.binning, 'interpolation', 'linear');
binning_granularity = extract_struct(inputs.params.binning, 'granularity', 1);
% Processing
processing_distortion = extract_struct(inputs.params.processing, 'distortion', false);
processing_diffraction = extract_struct(inputs.params.processing, 'diffraction', false);
processing_blooming = extract_struct(inputs.params.processing, 'blooming', false);
processing_noise = extract_struct(inputs.params.processing, 'noise', false);
% Saving
image_depth = extract_struct(inputs.params.saving, 'image_depth', 8);
image_format = extract_struct(inputs.params.saving, 'image_format', 'png');
image_filename = extract_struct(inputs.params.saving, 'image_filename', 'rendering');
