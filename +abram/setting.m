classdef setting
    %SETTINGS Render engine settings
    %   Container for the render engine parameters

    properties
        general                                
        discretization                                
        sampling                            
        integration           
        gridding                                          
        reconstruction                  
        processing      
        saving  
    end

    properties (Hidden)
        change
    end
    
    methods
        function obj = setting(in)
            %SETTING Construct a setting object by providing an inputs YML
            %file or a MATLAB struct

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
                otherwise 
                    error('setting:io','Plase provide input as either a YML filepath or a MATLAB struct')
            end

            % Add missing fields
            inputs.setting = add_missing_field(inputs.setting, {'general','discretization','sampling','integration','gridding','reconstruction','saving'});

            % General
            general.environment = extract_struct(inputs.setting.general, 'environment','matlab');
            general.parallelization = extract_struct(inputs.setting.general, 'parallelization', false);
            general.workers = extract_struct(inputs.setting.general, 'workers', 4);
            % Discretization
            discretization.method = extract_struct(inputs.setting.discretization, 'method','adaptive');
            discretization.np = extract_struct(inputs.setting.discretization, 'number_points', 1e5);
            discretization.accuracy = extract_struct(inputs.setting.discretization, 'accuracy','medium');
            % Sampling
            sampling.method = extract_struct(inputs.setting.sampling, 'method', 'projecteduniform');
            sampling.ignore_unobservable = extract_struct(inputs.setting.sampling, 'ignore_unobservable', true);
            % Integration
            integration.method = extract_struct(inputs.setting.integration, 'method','trapz');
            integration.np = extract_struct(inputs.setting.integration, 'number_points', 10);
            integration.correct_incidence = extract_struct(inputs.setting.integration, 'correct_incidence', true);
            integration.correct_reflection = extract_struct(inputs.setting.integration, 'correct_reflection', true);
            % Gridding
            gridding.method = extract_struct(inputs.setting.gridding, 'method', 'weightedsum');
            gridding.algorithm = extract_struct(inputs.setting.gridding, 'algorithm', 'area');
            gridding.scheme = extract_struct(inputs.setting.gridding, 'scheme', 'linear');
            gridding.shift = extract_struct(inputs.setting.gridding, 'shift', 1);
            gridding.filter = extract_struct(inputs.setting.gridding, 'filter', 'gaussian');
            % Reconstruction
            reconstruction.granularity = extract_struct(inputs.setting.reconstruction, 'granularity', 1);
            if ~strcmp(reconstruction.granularity,'auto')
                if mod(reconstruction.granularity, 1) ~= 0
                    error('Reconstruction granularity must be an integer equal or larger than 1')
                end
            end
            reconstruction.filter = extract_struct(inputs.setting.reconstruction, 'filter', 'bilinear');
            reconstruction.antialiasing = extract_struct(inputs.setting.reconstruction, 'antialiasing', 'true');
            % Processing
            processing.distortion = extract_struct(inputs.setting.processing, 'distortion', false);
            processing.diffraction = extract_struct(inputs.setting.processing, 'diffraction', false);
            processing.blooming = extract_struct(inputs.setting.processing, 'blooming', false);
            processing.noise = extract_struct(inputs.setting.processing, 'noise', false);
            % Saving
            saving.depth = extract_struct(inputs.setting.saving, 'depth', 8);
            saving.filename = extract_struct(inputs.setting.saving, 'filename','000000');
            saving.format = extract_struct(inputs.setting.saving, 'format', 'png');

            obj.general = general;                    
            obj.discretization = discretization;                             
            obj.sampling = sampling;                         
            obj.integration = integration;
            obj.gridding = gridding;                         
            obj.reconstruction = reconstruction;            
            obj.processing = processing;
            obj.saving = saving;

            obj.change = true;
        end
        
    end
end