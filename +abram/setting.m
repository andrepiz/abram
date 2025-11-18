classdef setting < abram.CRenderInput
    %SETTINGS Render engine settings. Container for the render engine
    %functioning parameters

    properties
        general                                
        discretization                                
        sampling             
        culling                            
        integration           
        gridding                                          
        reconstruction                  
        processing      
        saving  
    end
    
    methods
        function obj = setting(in)
            %SETTING Construct a setting object by providing an inputs YML
            %file or a MATLAB struct. 

            if nargin == 0
                % Missing inputs
                warning('setting:io','Initializing default settings')
                inputs.setting = [];
            else
                % Load inputs
                switch class(in)
                    case {'char','string'}
                        if isfile(in)
                            inputs = yaml.ReadYaml(in);
                        else
                            error('setting:io','YML input file not found')
                        end
                    case {'struct'}
                        inputs = in;
                        if ~isfield(in, 'setting')
                            warning('setting:io','Initializing default settings')
                            inputs.setting = [];
                        end
                    otherwise 
                        error('setting:io','Plase provide input as either a YML filepath or a MATLAB struct')
                end
            end

            % Add missing fields
            inputs.setting = add_missing_field(inputs.setting, {'general','discretization','sampling','culling','integration','gridding','reconstruction','processing','saving'});

            % General
            general.environment = extract_struct(inputs.setting.general, 'environment','matlab');
            general.parallelization = extract_struct(inputs.setting.general, 'parallelization', true);
            general.workers = extract_struct(inputs.setting.general, 'workers', 'auto');
            general.profile = extract_struct(inputs.setting.general, 'profile', 'threads');
            general.nmax = extract_struct(inputs.setting.general, 'nmax', 10e3*10e3);
            % Discretization
            discretization.method = extract_struct(inputs.setting.discretization, 'method','adaptive');
            discretization.np = extract_struct(inputs.setting.discretization, 'number_points', 1e5);
            discretization.accuracy = extract_struct(inputs.setting.discretization, 'accuracy','medium');
            % Sampling
            sampling.method = extract_struct(inputs.setting.sampling, 'method', 'auto');
            sampling.limits = extract_struct(inputs.setting.sampling, 'limits', 'auto');
            sampling.intersect_fov = extract_struct(inputs.setting.sampling, 'intersect_fov', true);
            % Culling
            culling.ignore_outfov = extract_struct(inputs.setting.culling, 'ignore_outfov', true);
            culling.ignore_unobservable = extract_struct(inputs.setting.culling, 'ignore_unobservable', true);
            culling.ignore_occluded = extract_struct(inputs.setting.culling, 'ignore_occluded', true);
            culling.ignore_outrange = extract_struct(inputs.setting.culling, 'ignore_outrange', 'auto');
            culling.occlusion_method = extract_struct(inputs.setting.culling, 'occlusion_method', 'raytracing');
            culling.occlusion_algorithm = extract_struct(inputs.setting.culling, 'occlusion_algorithm', 'iterative');
            culling.occlusion_rays = extract_struct(inputs.setting.culling, 'occlusion_rays', 'auto');
            culling.occlusion_angle = extract_struct(inputs.setting.culling, 'occlusion_angle', 'auto');
            culling.occlusion_accuracy = extract_struct(inputs.setting.culling, 'occlusion_accuracy', 'auto');
            culling.outrange_threshold = extract_struct(inputs.setting.culling, 'outrange_threshold', 100); % If my closest point is at 1 meter, I do not render points over 100 meters
            culling.impact_threshold = extract_struct(inputs.setting.culling, 'impact_threshold', 5/1737.4e3);  % If my closest point on the Moon is at 5 meters, the impact is detected
            % Integration
            integration.method = extract_struct(inputs.setting.integration, 'method','constant');
            integration.np = extract_struct(inputs.setting.integration, 'number_points', 'auto');
            integration.correct_incidence = extract_struct(inputs.setting.integration, 'correct_incidence', true);
            integration.correct_reflection = extract_struct(inputs.setting.integration, 'correct_reflection', true);
            integration.soft_shadows = extract_struct(inputs.setting.integration, 'soft_shadows', 0);
            % Gridding
            gridding.method = extract_struct(inputs.setting.gridding, 'method', 'weightedsum');
            gridding.window = extract_struct(inputs.setting.gridding, 'window', 1);
            gridding.algorithm = extract_struct(inputs.setting.gridding, 'algorithm', 'gaussian');
            gridding.scheme = extract_struct(inputs.setting.gridding, 'scheme', 'linear');
            gridding.shift = extract_struct(inputs.setting.gridding, 'shift', 1);
            gridding.filter = extract_struct(inputs.setting.gridding, 'filter', 'gaussian');
            gridding.sigma = extract_struct(inputs.setting.gridding, 'sigma', 1/2);
            % Reconstruction
            reconstruction.granularity = extract_struct(inputs.setting.reconstruction, 'granularity', 'auto');
            if ~strcmp(reconstruction.granularity,'auto')
                if mod(reconstruction.granularity, 1) ~= 0
                    error('Reconstruction granularity must be an integer equal or larger than 1')
                end
            end
            reconstruction.filter = extract_struct(inputs.setting.reconstruction, 'filter', 'bilinear');
            reconstruction.antialiasing = extract_struct(inputs.setting.reconstruction, 'antialiasing', true);
            % Processing
            processing.distortion = extract_struct(inputs.setting.processing, 'distortion', false);
            processing.diffraction = extract_struct(inputs.setting.processing, 'diffraction', false);
            processing.blooming = extract_struct(inputs.setting.processing, 'blooming', false);
            processing.noise = extract_struct(inputs.setting.processing, 'noise', false);
            % Saving
            saving.depth = extract_struct(inputs.setting.saving, 'depth', 8);
            saving.filename = extract_struct(inputs.setting.saving, 'filename', []);
            saving.format = extract_struct(inputs.setting.saving, 'format', 'png');

            obj.general = general;                    
            obj.discretization = discretization;                             
            obj.sampling = sampling;                                   
            obj.culling = culling;                            
            obj.integration = integration;
            obj.gridding = gridding;                         
            obj.reconstruction = reconstruction;            
            obj.processing = processing;
            obj.saving = saving;
        end
        
    end
end
