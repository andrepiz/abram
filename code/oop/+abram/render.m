classdef render
    %RENDER Rendering agent
    %   Detailed explanation goes here

    properties
        star
        body
        camera
        scene
        setting
        matrix
        img
    end

    properties (Dependent)
        spectrum
    end

    properties (Constant)
        homepath = abram_home();
        mapspath = fullfile(abram_home(),'inputs','maps');
    end

    methods

        function obj = render(in)
            %RENDER Construct a rendering agent by providing an inputs YML
            %file or a MATLAB struct

            % Load inputs
            switch class(in)
                case {'char','string'}
                    try
                        inputs = yaml.ReadYaml(in);
                    catch
                        error('render:io','YML input file not found or not recognized')
                    end
                case {'struct'}
                    inputs = in;
                otherwise 
                    error('render:io','Plase provide input as either a YML filepath or a MATLAB struct')
            end

            % Create corresponding classes
            obj.star = abram.star(inputs);
            obj.body = abram.body(inputs);
            obj.camera = abram.camera(inputs);
            obj.scene = abram.scene(inputs);
            obj.setting = abram.setting(inputs);
        end

        %% RENDERING %%
        function obj = rendering(obj)
            %RENDERING Render the object
            
            fprintf('\n### RENDERING STARTED ###')

            fprintf('\nLoading data...'), tic, 
            obj = obj.getParPool(); 
            obj = obj.loadMaps(); 
            fprintf(['\n...CPU time: ', num2str(toc)])

            fprintf('\nRendering...'), tic, 
            obj = obj.setSpectrum();
            obj = obj.sampleSector();
            obj = obj.renderScene(); 
            fprintf(['\n...CPU time: ', num2str(toc)])

            obj = obj.generateImage();

            fprintf('\n### RENDERING FINISHED ###\n')
        end

        function obj = setSpectrum(obj)
            obj.star = obj.star.integrateRadiance(obj.camera.QExT);
        end

        function obj = sampleSector(obj)
            obj.setting = abram.render.setDiscretization(obj.body, obj.camera, obj.scene, obj.setting);
            obj.body = abram.body.sampleSectors(obj.body, obj.camera, obj.scene, obj.setting);
            obj.body.change = false;
            obj.camera.change = false;
            obj.scene.change = false;
            obj.setting.change = false;
        end
        
        function obj = renderScene(obj)
            obj.matrix = abram.render.renderScene(obj.star, obj.body, obj.camera, obj.scene, obj.setting);
        end

        function obj = generateImage(obj)
            obj.img = abram.render.processImage(obj.matrix, obj.star, obj.camera, obj.setting);
            abram.render.saveImage(obj.img, obj.setting);
        end

        function obj = getParPool(obj)
            obj.setting = abram.render.getParPool(obj.setting);
        end

        function obj = loadMaps(obj)

            % Albedo
            if isempty(obj.body.maps.albedo.filename)
                obj.body.maps.albedo.F = [];
            else
                obj.body.maps.albedo.type = 'single';
                obj.body.maps.albedo = abram.body.interpolateMap(obj.body.maps.albedo);
            end
            % Displacement
            if isempty(obj.body.maps.displacement.filename)
                obj.body.maps.displacement.F = [];
            else
                obj.body.maps.displacement.type = 'single';
                obj.body.maps.displacement = abram.body.interpolateMap(obj.body.maps.displacement);
            end
            % Normal
            if isempty(obj.body.maps.normal.filename)
                obj.body.maps.normal.F = [];
            else
                obj.body.maps.normal.type = 'rgb';
                obj.body.maps.normal = abram.body.interpolateMap(obj.body.maps.normal);
            end

        end

    end
end