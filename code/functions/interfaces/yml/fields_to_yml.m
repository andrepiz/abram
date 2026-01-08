function fields_to_yml(filename_yml, format, light, body, camera, scene, setting)

switch format

    case 'abram'

        % STAR
        inputs.light = extract_fields(light, {'temperature','type'});
        inputs.light.radius = light.radius;

        % BODY
        inputs.body = extract_fields(body, {'radius', 'albedo', 'albedo_type','radiometry'});
        inputs.body.radius = body.radius;
        if isfield(body.maps,'albedo')
            if ~isempty(body.maps.albedo.filename)
            inputs.body.maps.albedo = extract_fields(body.maps.albedo, {'filename','dimension','depth','scale','gamma','shift','mean','domain','limits','lambda_min','lambda_max','bandwidth'});
            end
        end
        if isfield(body.maps,'displacement')
            if ~isempty(body.maps.displacement.filename)
            inputs.body.maps.displacement = extract_fields(body.maps.displacement, {'filename','dimension','depth','scale','gamma','shift','mean','domain','limits'});
            end
        end
        if isfield(body.maps,'normal')
            if ~isempty(body.maps.normal.filename)
            inputs.body.maps.normal = extract_fields(body.maps.normal, {'filename','dimension','depth','frame','limits'});
            end
        end
        if isfield(body.maps,'horizon')
            if ~isempty(body.maps.horizon.filename)
            inputs.body.maps.horizon = extract_fields(body.maps.horizon, {'filename','dimension','depth','limits'});
            end
        end
        if isfield(setting.sampling,'limits')
            if strcmp(setting.sampling.limits, 'fixed')
                inputs.body.lon_lims = body.lon_lims;
                inputs.body.lat_lims = body.lat_lims;
            end
        end

        % CAMERA
        inputs.camera.exposure_time = camera.tExp;
        inputs.camera.focal_length = camera.f;
        inputs.camera.f_number = camera.fNum;
        inputs.camera.pixel_width = camera.muPixel;        
        inputs.camera.resolution = camera.res_px;
        inputs.camera.full_well_capacity = camera.fwc;        
        inputs.camera.gain_analog2digital = camera.G_AD;
        inputs.camera.amplification = camera.amplification;     
        inputs.camera.offset = camera.offset;   
        inputs.camera.uv_upperLeftPixel = camera.uv_upperLeftPixel;
        inputs.camera.quantum_efficiency = extract_fields(camera.QE, {'lambda_min','lambda_max','values','sampling'});
        inputs.camera.transmittance = extract_fields(camera.T, {'lambda_min','lambda_max','values','sampling'});
        inputs.camera.distortion = camera.distortion;
        inputs.camera.noise = camera.noise;

        % SCENE
        inputs.scene.d_body2light = scene.d_body2light;
        inputs.scene.d_body2cam = scene.d_body2cam;
        inputs.scene.phase_angle = scene.phase_angle;
        inputs.scene.rpy_CAMI2CAM = scene.rpy_CAMI2CAM;
        inputs.scene.rpy_CSF2IAU = scene.rpy_CSF2IAU;

        % SETTING
        inputs.setting = extract_fields(setting, {'general','discretization','sampling','culling','integration','gridding','reconstruction','processing','saving'});

    case 'esa'

        error('Not supported yet')
end

yaml.WriteYaml(filename_yml, inputs, 0);

end

% Helper function to remove unwanted fields from a struct
function sOut = extract_fields(sIn, fields)
    for i = 1:numel(fields)
        fname = fields{i};
        if isstruct(sIn) && isfield(sIn, fname)
            if ~isempty(sIn.(fname))
                sOut.(fname) = sIn.(fname);
            end
        elseif isobject(sIn) && any(strcmp(fname, properties(sIn)))
            if ~isempty(sIn.(fname))
                sOut.(fname) = sIn.(fname);
            end
        end
    end
end

function s = remove_fields(s, fields)
    for i = 1:numel(fields)
        fname = fields{i};
        if isstruct(s) && isfield(s, fname)
            s = rmfield(s, fname);
        elseif isobject(s) && any(strcmp(fname, properties(s)))
            % For objects, set the property to empty or default value
            try
                s.(fname) = [];
            catch
                % If property is read-only, skip or handle accordingly
            end
        end
    end
end
