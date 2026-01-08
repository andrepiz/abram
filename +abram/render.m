classdef render
    %RENDER Render class implementing user interface to use ABRAM. Object is constructed by parsin
    % input configuration from yaml file or directly from struct types.
    % Rendering is performed calling the rendering() method.
    % -------------------------------------------------------------------------------------------------------------
    %% CHANGELOG
    % 01-01-2026        Andrea Pizzetti        ABRAM v1.7 - Added footprint, coverage, geometric_albedo, magnitude
    % 30-07-2025        Andrea Pizzetti        ABRAM v1.6 - Added depth map. Added default initialization
    % 29-11-2024        Andrea Pizzetti        ABRAM v1.3 - Added smart calling of submethods to increase efficiency
    % 11-11-2024        Andrea Pizzetti        ABRAM v1.2 - OOP design prototype
    % -------------------------------------------------------------------------------------------------------------
    %% DEPENDENCIES
    % cvt       https://github.com/andrepiz/cvt
    % yaml      https://github.com/MartinKoch123/yaml
    % -------------------------------------------------------------------------------------------------------------

    properties
        light
        body
        camera
        scene
        setting
        cloud
        matrix
        ecr
        ec
        noise
        img        
        radiance
        depth
        smart_calling
        homepath
        mapspath
    end

    properties (Dependent)
        Feff
        spectrum
        gsd
        bodyAngSize
        bodyPxSize
        bodyPxCenter
        conicMat
        conicVec
    end

    properties (Hidden)
        update_parpool
        update_maps
        update_radiometry
        update_spectrum
        update_sectors
        update_methods   
        update_processing
        update_matrix
        time_loading
        time_sampling
        time_integrating
        time_gridding
        time_rendering
        time_processing
    end

    properties (Hidden, Dependent)
        update_render     
        update_image
    end

    methods (Access = public)

        function obj = render(input_args, flag_rendering)
            arguments
                input_args (1,:) = -1
                flag_rendering = false  % Default: do not render
            end
            %RENDER Construct a rendering agent by providing an inputs YML
            %file or a MATLAB struct

            if nargin == 0 || isempty(input_args) || islogical(input_args)
                % Missing inputs

                % Create corresponding classes (defaults)
                warning off
                obj.light   = abram.light  ();
                obj.body    = abram.body   ();
                obj.camera  = abram.camera ();
                obj.scene   = abram.scene  ();
                obj.setting = abram.setting();
                warning on

                % Automatic rendering
                if islogical(input_args)
                    flag_rendering = input_args;
                end
                if flag_rendering
                    warning('render:io','Default render object rendering...')
                else
                    warning('render:io','Default render object initialized...')
                end

            else
                
                flag_rendering = true;  % Default: render

                % Load inputs
                assert( isnumeric(input_args) || ( isa(input_args, 'string') || isa(input_args, 'char') || isa(input_args, 'struct') ), ...
                'Unsupported input type. Please provide a path to a YML input configuration file or a struct containing the objects data');

                % Check yaml package is available
                if isempty( which('yaml.ReadYaml') )
                    error('render:io','YAML toolbox not found. Please install yaml with git submodule or download it from https://github.com/ewiger/yamlmatlab and add it to the MATLAB path');
                end
    
                % Load inputs
                switch class(input_args)
                    case {'char', 'string'}
                        try
                            inputs = yaml.ReadYaml(char(input_args));
                        catch
                            error('render:io',['Errors found while reading ', char(input_args)])
                        end
                        if isempty(fields(inputs))
                            error('render:io',['YML input configuration file ', char(input_args), ' not found. Please check if the file name is correct and if the file folder has been added to the path'])
                        end
                    case {'struct'}
                        inputs = input_args;
                    otherwise 
                        error('render:io','Plase provide input as either a YML filepath or a MATLAB struct')
                end

                % Create corresponding classes
                obj.light   = abram.light  (inputs);
                obj.body    = abram.body   (inputs);
                obj.camera  = abram.camera (inputs);
                obj.scene   = abram.scene  (inputs);
                obj.setting = abram.setting(inputs);

            end

            % Default properties
            obj.smart_calling = true;
            obj.homepath = abram_home();
            obj.mapspath = fullfile(abram_home(),'inputs','maps');

            % Set to true the updates to prepare for first rendering
            obj.update_sectors = true;
            obj.update_spectrum = true;
            obj.update_maps = true;
            obj.update_radiometry = true;
            obj.update_parpool = true;
            obj.update_methods = true;
            obj.update_processing = true;

            % If smart calling is activated, perform a pre-rendering to
            % fill the render object
            if obj.smart_calling && flag_rendering
                obj = obj.rendering();
            end
        end

    end

    methods
        %% SETTERS
        function obj = setInputObj(obj, objInput)
            arguments
                obj
                objInput (1,1) {isa(objInput, 'CRenderInput')}
            end

            % Get subclass type and assign to corresponding field name
            type_split = split(class(objInput), '.');
            type = type_split{2};
            try
                assert(isprop(obj, type), 'ERROR: render class does not have %s property!', type)
                obj.(type) = objInput;
            catch ME
                warning('Input setter failed due to: %s', string(ME.message) );
            end
        end

        function obj = set.light(obj, objInput)
            if ~isempty(obj.light)
                obj.update_spectrum = update_flag_trigger(obj.light, objInput, obj.update_spectrum);
            end
            obj.light = objInput;
        end

        function obj = set.setting(obj, objInput)
            if ~isempty(obj.setting)
                obj.update_parpool = update_flag_trigger(obj.setting, objInput, obj.update_parpool, {'general'});
                obj.update_sectors = update_flag_trigger(obj.setting, objInput, obj.update_sectors, {'discretization','sampling'});
                obj.update_methods = update_flag_trigger(obj.setting, objInput, obj.update_methods, {'culling','integration'});
                obj.update_matrix = update_flag_trigger(obj.setting, objInput, obj.update_matrix, {'gridding','reconstruction'});
                obj.update_processing = update_flag_trigger(obj.setting, objInput, obj.update_processing, {'processing','saving'});
            end
            obj.setting = objInput;
        end

        function obj = set.body(obj, objInput)   
            if ~isempty(obj.body)
                obj.update_maps = update_flag_trigger(obj.body, objInput, obj.update_maps, {'maps'});
                obj.update_radiometry = update_flag_trigger(obj.body.radiometry, objInput, obj.update_radiometry) | ...
										(isempty(obj.body.maps) & (update_flag_trigger(obj.body, objInput, obj.update_radiometry, {'albedo'}) | update_flag_trigger(obj.body, objInput, obj.update_radiometry, {'albedo_type'})));
                obj.update_sectors = update_flag_trigger(obj.body, objInput, obj.update_sectors, {'radius','lon_lims','lat_lims'});
            end
            obj.body = objInput;
        end

        function obj = set.camera(obj, objInput)    
            if ~isempty(obj.camera)
                obj.update_spectrum = update_flag_trigger(obj.camera, objInput, obj.update_spectrum, {'QExT'});
                obj.update_sectors = update_flag_trigger(obj.camera, objInput, obj.update_sectors, {'fov'});
                obj.update_radiometry = update_flag_trigger(obj.camera, objInput, obj.update_radiometry, {'fNum','f'});
                obj.update_matrix = update_flag_trigger(obj.camera, objInput, obj.update_matrix,{'distortion'});
                obj.update_processing = update_flag_trigger(obj.camera, objInput, obj.update_processing, {'tExp','G_AD','noise','fwc','offset','amplification'}) | obj.update_spectrum;
            end
            obj.camera = objInput;
        end

        function obj = set.scene(obj, objInput)  
            if ~isempty(obj.scene)
                obj.update_sectors = update_flag_trigger(obj.scene, objInput, obj.update_sectors);
            end
            obj.scene = objInput;
        end

        %% GETTERS
        function res = get.update_render(obj)    
            res = obj.update_maps || obj.update_radiometry || obj.update_parpool || obj.update_sectors || obj.update_methods;
        end

        function res = get.update_image(obj)
            res = obj.update_render || obj.update_matrix || obj.update_processing;
        end
        
        function res = get.gsd(obj)
            % Ground sampling distance at nadir
            res = 2*obj.altitude*tan(obj.camera.ifov/2); 
        end

        function res = get.bodyAngSize(obj)
            % Angular size of the body 

            if isempty(obj.body.maps.displacement.F) || obj.scene.d_body2cam > max(obj.body.radius)
                % Using the body radius when there is no displacement map or
                % the camera distance is larger than the body radius
                Rbody = max(obj.body.radius);
            else
                % In close range we compute the real body radius at nadir
                Rbody = obj.bodyRadiusAtNadir;
            end
            [bodyTangencyAngle, bodyBearingAngle] = find_sphere_tangent_angle(obj.scene.d_body2cam, Rbody); 
            % Otherwise using the radius at the nadir point 
            res = 2*max(bodyBearingAngle); 
        end

        function res = get.bodyPxSize(obj)
            % Px size of the body
            res = 2*obj.camera.f./obj.camera.muPixel.*tan(obj.bodyAngSize/2);
        end

        function res = get.bodyPxCenter(obj)
            % Return the image coordinates of the body geometric center 
            res = obj.camera.K([1 2],:)*obj.scene.dir_cam2body_CAM./obj.scene.dir_cam2body_CAM(3);
        end

        function res = get.conicMat(obj)
            % Return the conic as a vector     
            res = sphere2conicMat([0;0;0], obj.scene.pos_body2cam_CSF, obj.scene.dcm_CSF2CAM, obj.camera.K, obj.body.radius);
        end

        function res = get.conicVec(obj)
            % Return the conic as a vector             
            res = conicMat2conicVec(obj.conicMat);
        end

        function res = get.Feff(obj)
            % Spectral Feff
            c = 299792458;      % m/s
            h = 6.62607015e-34; % J/Hz
            res = obj.ecr * (h*c)/(obj.camera.Apupil*obj.camera.etaNormalizationFactor);
        end

        function res = get.depth(obj)
            % Depth map from coordinates point cloud
            res = abram.render.depthImage(obj.cloud, obj.body, obj.camera, obj.setting);
        end

        function res = get.radiance(obj)
            % Radiance map from the raw collected power matrix,
            % dividing for the collecting area (pupil) and the solid angle
            % of each pixel
            omegaPixel = mean(obj.camera.muPixel(1)*obj.camera.muPixel(2) ./ obj.camera.f.^2);
            P = obj.matrix.values.*obj.matrix.adim.*reshape(obj.light.L.values, 1, 1, []);
            P(P == 0) = nan;
            res = P ./ (obj.camera.Apupil * omegaPixel);
        end

        %% RENDERING
        function obj = rendering(obj)
            %RENDERING Render the scene
            
            fprintf('\n### RENDERING STARTED ###')

            fprintf('\n+++ Loading data +++'), tic, 
            obj = obj.getParPool(); 
            obj = obj.loadMaps(); 
            obj.time_loading = toc;
            fprintf('\n...CPU time: %f sec', obj.time_loading)

            fprintf('\n+++ Sampling points +++'), tic, 
            obj = obj.setSpectrum();
            obj = obj.sampleSectors();
            obj.time_sampling = toc;
            fprintf('\n...CPU time: %f sec', obj.time_sampling)

            fprintf('\n+++ Integrating reflection +++'), tic, 
            obj = obj.coeffCloud(); 
            obj.time_integrating = toc;
            fprintf('\n...CPU time: %f sec', obj.time_integrating)

            fprintf('\n+++ Direct gridding +++'), tic, 
            obj = obj.directGridding(); 
            obj.time_gridding = toc;
            fprintf('\n...CPU time: %f sec', obj.time_gridding)

            fprintf('\n+++ Process image +++'), tic, 
            obj = obj.processImage();
            abram.render.saveImage(obj.img, obj.setting);
            obj.time_processing = toc;
            fprintf('\n...CPU time: %f sec', obj.time_processing)

            obj.time_rendering = obj.time_sampling + obj.time_integrating + obj.time_gridding;
            fprintf('\n### FINISHED IN %f SEC ###\n', obj.time_loading + obj.time_rendering + obj.time_processing)

            % Set to false the updates to prepare for next rendering
            obj.update_sectors = false;
            obj.update_spectrum = false;
            obj.update_maps = false;
            obj.update_radiometry = false;
            obj.update_parpool = false;
            obj.update_methods = false;
            obj.update_matrix = false;
            obj.update_processing = false;
        end

        function obj = getParPool(obj)
            if obj.update_parpool || ~obj.smart_calling
                obj.setting = abram.render.getParPool(obj.setting);
            else
                fprintf('\n   smart calling: no change detected, skipping parpool loading...') 
            end
        end

        function obj = loadMaps(obj)
            if obj.update_maps || ~obj.smart_calling
                obj.body = abram.body.loadMaps(obj.body);
            else
                fprintf('\n   smart calling: no change detected, skipping maps loading...') 
            end
        end

        function obj = setSpectrum(obj)
            if obj.update_spectrum || ~obj.smart_calling
                obj.light = obj.light.integrateRadiance(obj.camera.QExT);
            else
                fprintf('\n   smart calling: no change detected, skipping spectrum setting...') 
            end
        end

        function obj = sampleSectors(obj)
            if obj.update_sectors || ~obj.smart_calling
                obj.body = abram.body.sampleSectors(obj.body, obj.camera, obj.scene, obj.setting);
            else
                fprintf('\n   smart calling: no change detected, skipping sectors sampling...') 
            end
        end

        function obj = coeffCloud(obj)
            if obj.update_render || ~obj.smart_calling
                obj.cloud = abram.render.coeffCloud(obj.light, obj.body, obj.camera, obj.scene, obj.setting);
                obj.update_matrix = true;
            else
                fprintf('\n   smart calling: no change detected, skipping cloud generation...') 
            end
        end

        function obj = directGridding(obj)
            if obj.update_matrix || ~obj.smart_calling
                obj.matrix = abram.render.directGridding(obj.cloud, obj.body, obj.camera, obj.scene, obj.setting);
            else
                fprintf('\n   smart calling: no change detected, skipping direct gridding...') 
            end
        end

        function obj = processImage(obj)
            if obj.update_image || ~obj.smart_calling
                [obj.img, obj.noise, obj.ec, obj.ecr] = abram.render.processImage(obj.matrix, obj.light, obj.camera, obj.setting);
            else
                fprintf('\n   smart calling: no change detected, skipping image processing...') 
            end
        end

        %% UTILS
        function [lonMin, lonMax, latMin, latMax] = footprint(obj)
            % Compute the longitude/latitude boundaries in IAU frame

            % Extract data
            pos_cam2sec_CAM = obj.cloud.coords(:, obj.cloud.ixsInFov);
            if isempty(pos_cam2sec_CAM)
                pos_cam2sec_CAM = obj.cloud.coords(:, any(~isnan(obj.cloud.coords), 1));
            end
            pos_body2sec_IAU = obj.scene.dcm_CSF2IAU*obj.scene.pos_body2cam_CSF + obj.scene.dcm_CAM2IAU*pos_cam2sec_CAM;
            sph_body2sec = sph_coord_fast(pos_body2sec_IAU);
            lon_IAU = sph_body2sec(2, :);
            lat_IAU = sph_body2sec(3, :);

            % Convex hull
            hull_idx = convhull(pos_body2sec_IAU');
            hull_vertices = unique(hull_idx(:));
            lon_hull = lon_IAU(hull_vertices);
            lat_hull = lat_IAU(hull_vertices);
            
            % For longitude wrapping:
            lon_hull_wrapped = mod(lon_hull, 2*pi);
            lon_span = max(lon_hull_wrapped) - min(lon_hull_wrapped);
            if lon_span < pi
                lonMin = min(lon_hull_wrapped);
                lonMax = max(lon_hull_wrapped);
            else
                % Find largest gap and take complement interval for limiting longitudes
                sorted_lon = sort(lon_hull_wrapped);
                diff_lon = diff([sorted_lon, sorted_lon(1)+2*pi]);
                [~, idx_gap] = max(diff_lon);
                lonMin = mod(sorted_lon(idx_gap+1), 2*pi);
                lonMax = mod(sorted_lon(idx_gap), 2*pi);
            end
            latMin = min(lat_hull);
            latMax = max(lat_hull);
        end

        function img = coverage(obj)
            
            % Extract data
            pos_cam2sec_CAM = obj.cloud.coords(:, obj.cloud.ixsActive);
            if isempty(pos_cam2sec_CAM)
                pos_cam2sec_CAM = obj.cloud.coords(:, any(~isnan(obj.cloud.coords), 1));
            end
            pos_body2sec_IAU = obj.scene.dcm_CSF2IAU*obj.scene.pos_body2cam_CSF + obj.scene.dcm_CAM2IAU*pos_cam2sec_CAM;
            sph_body2sec = sph_coord_fast(pos_body2sec_IAU);
            lon_IAU = sph_body2sec(2, :);
            lat_IAU = sph_body2sec(3, :);

            % Use albedo map as underlayer
            if isempty(obj.body.maps.albedo.filename)

                gsd_cam = max(obj.gsd);
                gsd_sampling = 2*min(diff(obj.body.lon_lims)/obj.body.sampling.nlon, diff(obj.body.lat_lims)/obj.body.sampling.nlat)*max(obj.body.radius);

                res_lonlat = min(gsd_cam, gsd_sampling)/min(obj.body.radius);
                npx_map = round(pi/res_lonlat);
                img_texture = obj.body.albedo*ones(npx_map, 2*npx_map);
                lonMin = -pi;
                lonMax = pi;
                latMin = -pi/2;
                latMax = pi/2;
            else
                lonMin = obj.body.maps.albedo.limits(1,1);
                lonMax = obj.body.maps.albedo.limits(1,2);
                latMin = obj.body.maps.albedo.limits(2,1);
                latMax = obj.body.maps.albedo.limits(2,2);

                % Resize texture image such that one pixel is at least equal to
                % the minimum between the gsd of the camera or 2 times the gsd of the sampling
                gsd_texture = max(obj.body.maps.albedo.res_lonlat)*max(obj.body.radius);
                gsd_cam = max(obj.gsd);
                gsd_sampling = 2*min(diff(obj.body.lon_lims)/obj.body.sampling.nlon, diff(obj.body.lat_lims)/obj.body.sampling.nlat)*max(obj.body.radius);

                img_texture = imresize(flip(obj.body.maps.albedo.F.Values./obj.body.maps.albedo.max, 1), gsd_texture/min(gsd_cam, gsd_sampling));
            end
   
            img = overlayTextureMask(img_texture, lonMin, lonMax, latMin, latMax, lon_IAU, lat_IAU);
        end

        function R = bodyRadiusAtNadir(obj)
            % Compute the body radius at nadir, when the displacement map is
            % available, or the ellipsoidal radius when it is not 
            lon_IAU = obj.scene.sph_body2cam_IAU(2);
            lat_IAU = obj.scene.sph_body2cam_IAU(3);
            Rbody = find_triaxial_radius(lon_IAU, lat_IAU, obj.body.radius);
            if ~isempty(obj.body.maps.displacement.F)
                dh = obj.body.maps.displacement.adim*obj.body.maps.displacement.F(lat_IAU, lon_IAU);
                if isnan(dh)
                    warning('abram:render','The longitude and latitude of the camera is outside the displacement map boundaries. The body radius will be provided equal to the spherical/ellipsoidal radius.')
                    dh = 0;
                end
            else
                dh = 0;
            end
            R = Rbody + dh;
        end

        function h = altitude(obj)
            % Compute the altitude using the real body radius at nadir
            h = obj.scene.d_cam2body - obj.bodyRadiusAtNadir;
        end

        function [pGeom, pGeomMinMax] = geometric_albedo(obj)
            % Numerically compute the geometric albedo from the object by
            % rendering it at a very far range and with zero phase angle
            
            objCopy = obj;

            % Find reference radius
            Afrontal = ellipsoidFrontalArea(objCopy.body.radius, objCopy.scene.dcm_CSF2IAU*objCopy.scene.dir_body2cam_CSF);
            Rref = sqrt(Afrontal/pi);

            % Find distance such that the body spans 1 px
            range = max(opr2range(1, Rref, obj.camera.f, obj.camera.muPixel),[],'all');

            % Render object
            objCopy.scene.d_body2cam = range;
            objCopy.scene.phase_angle = 0;
            objCopy.scene.rpy_CAMI2CAM = [0; 0; 0];
            objCopy.setting.discretization.method = 'fixed';
            objCopy.setting.discretization.np = 5e5;    % to not undersampling too much
            objCopy.setting.saving.filename = [];    % to not undersampling too much
            objCopy = objCopy.rendering();

            % Geometric albedo definition: ratio of intensity scattered
            % back to the source by the sphere to the one that would
            % scatter back a lambertian lossless disk
            % Ilossless = psi(alpha)*R^2
            % Itrue = PL*L/omega
            PLobj = sum(objCopy.matrix.values, "all")*objCopy.matrix.adim;

            PLR2lossless = objCopy.camera.Apupil*cos(objCopy.scene.ang_offpoint)/(range^2)*pi*(objCopy.light.radius^2)/(objCopy.scene.d_body2light^2);
            if ~isempty(objCopy.body.maps.displacement.F)
                dhMax = objCopy.body.maps.displacement.max*objCopy.body.maps.displacement.adim;
                dhMin = objCopy.body.maps.displacement.min*objCopy.body.maps.displacement.adim;
                PLlosslessdiskmax = (Rref + dhMax)^2*PLR2lossless;
                PLlosslessdiskmin = (Rref + dhMin)^2*PLR2lossless;
            else
                PLlosslessdiskmax = (Rref)^2*PLR2lossless;
                PLlosslessdiskmin = (Rref)^2*PLR2lossless;
            end
            pGeom = PLobj/(0.5*PLlosslessdiskmax + 0.5*PLlosslessdiskmin);                
            pGeomMinMax = [PLobj/PLlosslessdiskmax, PLobj/PLlosslessdiskmin];
        end

        function [mag_pcr, mag_flux] = magnitude(obj)
            % Compute the apparent magnitude in the Vega system
            % from the photon flux considering as reference photon flux 
            % (zero magnitude point) the Vega photon flux in the same
            % weighted bandwidth

            % reference (Vega) spectrum-weighted signal
            [flux_density_mag0_all, pcr_density_mag0_all] = vega_flux(obj.camera.QExT.lambda_min, obj.camera.QExT.lambda_max, obj.camera.QExT.values);

            % rendered spectrum-weighted signal in photon count rate density
            pcr_density_abram = sum(obj.ecr(:))./obj.camera.Apupil;
            pcr_density_mag0 = sum(pcr_density_mag0_all);
            mag_pcr = -2.5*log10(pcr_density_abram./pcr_density_mag0);
            if ~isfinite(mag_pcr)
                mag_pcr = nan;
            end

            % rendered spectrum-weighted signal in flux density
            flux_density_abram = sum(obj.matrix.values(:)*obj.matrix.adim*sum(obj.light.L.values.*obj.camera.QExT.values))./obj.camera.Apupil;
            flux_density_mag0 = sum(flux_density_mag0_all);
            mag_flux = -2.5*log10(flux_density_abram./flux_density_mag0);
            if ~isfinite(mag_flux)
                mag_flux = nan;
            end
        end

        function to_yml(obj, filename_yml, format)
            % Create an inputs file in yml format using different
            % formats copying the current properties
            % of the object 
            if ~exist("filename_yml", "var")
                filename_yml = 'inputs.yml';
            end
            if ~exist("format", "var")
                format = 'abram';
            end
            
            fields_to_yml(filename_yml, format, obj.light, obj.body, obj.camera, obj.scene, obj.setting)
        end

    end

end
