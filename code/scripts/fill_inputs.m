%% COMPLETE INPUTS
fov_type = 'frustum';
if length(res_px) == 1 && length(muPixel) == 1
    res_px(2) = res_px(1);
    muPixel(2) = muPixel(1);
    fov_type = 'cone';
end
if length(res_px) == 2 && length(muPixel) == 1
    if res_px(1) ~= res_px(2)
        warning('Non-uniform resolution, pixel set to square shape')
    end
    muPixel(2) = muPixel(1);
end
if length(res_px) == 1 && length(muPixel) == 2
    if muPixel(1) ~= muPixel(2)
        warning('Non-uniform pixel size, resolution set to square shape')
    end
    res_px(2) = res_px(1);
end
if ~exist('saving_depth','var')
    warning('Assumed saving depth equal to 8 bits')
    saving_depth = 8;
end
if ~exist('G_AD','var')
    warning('Assumed A/D Gain equal to (2^image_depth-1)/FWC')
    G_AD = (2^saving_depth-1)/fwc;
end
if ~exist('noise_floor','var')
    warning('Assumed Noise Floor equal to 1 DN')
    noise_floor = 1/G_AD;
end
if ~exist('radiometry_roughness','var')
    radiometry_roughness = 1;
    if strcmp(radiometry_model,'oren')
        warning('Missing roughness in Oren-Nayar model. Assuming 1')
    end
end
if ~exist('radiometry_shineness','var')
    radiometry_shineness = 1;
    if strcmp(radiometry_model,'specular')
        warning('Missing shineness in Specular model. Assuming 1')
    end
    if strcmp(radiometry_model,'phong')
        warning('Missing shineness in Phong model. Assuming 1')
    end
end
if ~exist('radiometry_weight_lambert','var')
    radiometry_weight_lambert = 0.5;
    if strcmp(radiometry_model,'phong')
        warning('Missing weight of Lambert in Phong model. Assuming 0.5')
    end
end
if ~exist('radiometry_weight_specular','var')
    radiometry_weight_specular = 0.5;
    if strcmp(radiometry_model,'phong')
        warning('Missing weight of Specular in Phong model. Assuming 0.5')
    end
end
if ~exist('radiometry_parameters','var')
    radiometry_parameters = [0.25, 0.3, 0, 1, 2.2, 0.07, 0.4, 1];
    if strcmp(radiometry_model,'phong')
        warning('Missing parameters of Hapke model. Assuming Moon mean values')
    end
end

%% FILL MISSING INPUTS
if ~exist('albedo_dimension','var'); albedo_dimension = []; end
if ~exist('albedo_scale','var'); albedo_scale = []; end
if ~exist('albedo_shift','var'); albedo_shift = []; end
if ~exist('albedo_gamma','var'); albedo_gamma = []; end
if ~exist('albedo_mean','var'); albedo_mean = []; end
if ~exist('albedo_domain','var'); albedo_domain = []; end
if ~exist('albedo_lambda_min','var'); albedo_lambda_min = []; end
if ~exist('albedo_lambda_max','var'); albedo_lambda_max = []; end
if ~exist('albedo_bandwidth','var'); albedo_bandwidth = []; end
if ~exist('albedo_limits','var'); albedo_limits = [-pi pi; -pi/2 pi/2]; end
if ~exist('displacement_limits','var'); displacement_limits = [-pi pi; -pi/2 pi/2]; end
if ~exist('displacement_scale','var'); displacement_scale = []; end
if ~exist('displacement_shift','var'); displacement_shift = []; end
if ~exist('normal_scale','var'); normal_scale = []; end
if ~exist('normal_frame','var'); normal_frame = 'body'; end
if ~exist('normal_limits','var'); normal_limits = [-pi pi; -pi/2 pi/2]; end
if ~exist('sampling_limits','var'); sampling_limits = 'auto'; end
if ~exist('amplification','var'); amplification = 0; end
if ~exist('offset','var'); offset = 0; end
if ~exist('distortion','var')
    distortion.radial = [0, 0, 0];
    distortion.decentering = [0, 0];
end
if ~exist('noise','var')
    noise.shot.flag = false;
    noise.shot.sigma = 0;
    noise.shot.seed = [];
    noise.prnu.flag = false;
    noise.prnu.sigma = 0;
    noise.prnu.seed = [];
    noise.dark.flag = false;
    noise.dark.sigma = 0;
    noise.dark.mean = 0;
    noise.dark.seed = [];
    noise.readout.flag = false;
    noise.readout.sigma = 0;
    noise.readout.seed = [];
end
