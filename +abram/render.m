classdef render
    %RENDER Render class implementing user interface to use ABRAM. Object is constructed by parsin
    % input configuration from yaml file or directly from struct types.
    % Rendering is performed calling the rendering() method.
    % -------------------------------------------------------------------------------------------------------------
    %% CHANGELOG
    % 29-11-2024        Andrea Pizzetti        ABRAM v1.3 - Added smart calling of submethods to increase efficiency
    % 11-11-2024        Andrea Pizzetti        ABRAM v1.2 - OOP design prototype
    % -------------------------------------------------------------------------------------------------------------
    %% DEPENDENCIES
    % cvt       https://github.com/andrepiz/cvt
    % yaml      https://github.com/MartinKoch123/yaml
    % -------------------------------------------------------------------------------------------------------------

    properties
        star
        body
        camera
        scene
        setting
        matrix
        img
        smart_calling
        homepath
        mapspath
    end

    properties (Dependent)
        spectrum
    end

    properties (Hidden)
        update_parpool
        update_maps
        update_spectrum
        update_sectors
        update_methods   
        update_processing
    end

    properties (Hidden, Dependent)
        update_render     
        update_image
    end

    methods (Access = public)

        function obj = render(input_args, kwargs)
            arguments
                input_args (1,:) = -1
            end
            arguments
                kwargs.objStar    (1,1) {isa(kwargs.objStar   , 'star')} 
                kwargs.objBody    (1,1) {isa(kwargs.objBody   , 'body')}
                kwargs.objCamera  (1,1) {isa(kwargs.objCamera , 'camera')}
                kwargs.objScene   (1,1) {isa(kwargs.objScene  , 'scene')}
                kwargs.objSetting (1,1) {isa(kwargs.objSetting, 'setting')}
            end
            %RENDER Construct a rendering agent by providing an inputs YML
            %file or a MATLAB struct
            assert( isnumeric(input_args) || ( isa(input_args, 'string') || isa(input_args, 'char') || isa(input_args, 'struct') ), ...
                'Unsupported input type. Please provide a path to yaml config. or a data struct containing data.');

            % Load inputs
            switch class(input_args)
                case {'char', 'string'}
                    try
                        inputs = yaml.ReadYaml(input_args);
                    catch
                        error('render:io','YML input file not found or not recognized')
                    end
                case {'struct'}
                    inputs = input_args;
                otherwise 
                    error('render:io','Plase provide input as either a YML filepath or a MATLAB struct')
            end

            % Create corresponding classes (defaults)
            obj.star    = abram.star   (inputs);
            obj.body    = abram.body   (inputs);
            obj.camera  = abram.camera (inputs);
            obj.scene   = abram.scene  (inputs);
            obj.setting = abram.setting(inputs);

            % Get fieldnames and set input objects directly if specified
            kwargs_fields = fieldnames(kwargs);

            for field = [kwargs_fields{:}]
                obj = obj.setInputObj(kwargs.(field));
            end
        
            % Default properties
            obj.smart_calling = true;
            obj.homepath = abram_home();
            obj.mapspath = fullfile(abram_home(),'inputs','maps');

            % Set to true the updates to prepare for first rendering
            obj.update_sectors = true;
            obj.update_spectrum = true;
            obj.update_maps = true;
            obj.update_parpool = true;
            obj.update_methods = true;
            obj.update_processing = true;

            % If smart calling is activated, perform a pre-rendering to
            % fill the render object
            if obj.smart_calling
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

        function obj = set.star(obj, objInput)
            % Change update flags only outside of rendering call
            st = dbstack;
            if ~any(strcmp({st.name}, 'render.rendering'))
                obj.update_spectrum = true;
                if ~isempty(obj.star)
                    if check_equivalence(obj.star, objInput)
                        obj.update_spectrum = false;
                    end
                end           
            end
            obj.star = objInput;
        end

        function obj = set.setting(obj, objInput)
            % Change update flags only outside of rendering call
            st = dbstack;
            if ~any(strcmp({st.name}, 'render.rendering'))
                obj.update_parpool = true;
                obj.update_sectors = true;
                obj.update_methods = true;
                obj.update_processing = true;
                if ~isempty(obj.setting)
                    if check_equivalence(obj.setting.general, objInput.general)
                        obj.update_parpool = false;
                    end
                    if check_equivalence(obj.setting.discretization, objInput.discretization) && ...
                            check_equivalence(obj.setting.sampling, objInput.sampling)
                        obj.update_sectors = false;
                    end
                    if check_equivalence(obj.setting.integration, objInput.integration) && ...
                            check_equivalence(obj.setting.gridding, objInput.gridding) && ...
                            check_equivalence(obj.setting.reconstruction, objInput.reconstruction)
                        obj.update_methods = false;
                    end
                    if check_equivalence(obj.setting.processing, objInput.processing) && ...
                            check_equivalence(obj.setting.saving, objInput.saving)
                        obj.update_processing = false;
                    end
                end
            end
            obj.setting = objInput;
        end

        function obj = set.body(obj, objInput)   
            % Change update flags only outside of rendering call
            st = dbstack;
            if ~any(strcmp({st.name}, 'render.rendering'))
                obj.update_maps = true;
                obj.update_sectors = true;
                if ~isempty(obj.body)
                    if check_equivalence(obj.body.maps,  objInput.maps)
                        obj.update_maps = false;
                    end
                    if check_equivalence(obj.body.Rbody,  objInput.Rbody)
                        obj.update_sectors = false;
                    end
                end
            end
            obj.body = objInput;
        end

        function obj = set.camera(obj, objInput)    
            % Change update flags only outside of rendering call
            st = dbstack;
            if ~any(strcmp({st.name}, 'render.rendering'))
                obj.update_spectrum = true;
                obj.update_sectors = true;
                obj.update_processing = true;
                if ~isempty(obj.camera)
                    if check_equivalence(obj.camera.QExT,  objInput.QExT)
                        obj.update_spectrum = false;
                    end
                    if check_equivalence(obj.camera.fov,  objInput.fov)
                        obj.update_sectors = false;
                    end
                    if check_equivalence(obj.camera.tExp,  objInput.tExp) && ...
                            check_equivalence(obj.camera.G_AD,  objInput.G_AD) && ...
                            ~obj.update_spectrum
                        obj.update_processing = false;
                    end
                end
            end
            obj.camera = objInput;
        end

        function obj = set.scene(obj, objInput)  
            % Change update flags only outside of rendering call
            st = dbstack;
            if ~any(strcmp({st.name}, 'render.rendering'))
                obj.update_sectors = true;
                if ~isempty(obj.scene)
                    if check_equivalence(obj.scene,  objInput)
                        obj.update_sectors = false;
                    end
                end
            end
            obj.scene = objInput;
        end

        %% GETTERS
        function res = get.update_render(obj)    
            res = obj.update_maps || obj.update_parpool || obj.update_sectors || obj.update_methods;
        end

        function res = get.update_image(obj)
            res = obj.update_render || obj.update_processing;
        end
        
        %% RENDERING
        function obj = rendering(obj)
            %RENDERING Render the scene
            
            fprintf('\n### RENDERING STARTED ###')

            fprintf('\n+++ Loading data ...'), tic, 
            obj = obj.getParPool(); 
            obj = obj.loadMaps(); 
            fprintf(['\n... CPU time: ', num2str(toc)])

            fprintf('\n+++ Process scene ...'), tic, 
            obj = obj.setSpectrum();
            obj = obj.setDiscretization();
            obj = obj.sampleSectors();
            fprintf(['\n... CPU time: ', num2str(toc)])

            fprintf('\n+++ Render scene ...'), tic, 
            obj = obj.renderScene(); 
            fprintf(['\n... CPU time: ', num2str(toc)])

            fprintf('\n+++ Process image ...'), tic, 
            obj = obj.processImage();
            abram.render.saveImage(obj.img, obj.setting);
            fprintf(['\n... CPU time: ', num2str(toc)])

            fprintf('\n### RENDERING FINISHED ###\n')

            % Set to false the updates to prepare for next rendering
            obj.update_sectors = false;
            obj.update_spectrum = false;
            obj.update_maps = false;
            obj.update_parpool = false;
            obj.update_methods = false;
            obj.update_processing = false;
        end

        function obj = getParPool(obj)
            if obj.update_parpool || ~obj.smart_calling
                obj.setting = abram.render.getParPool(obj.setting);
            else
                fprintf('\n')
                warning('No change detected, skipping parpool loading...') 
            end
        end

        function obj = loadMaps(obj)
            if obj.update_maps || ~obj.smart_calling
                obj.body = abram.body.loadMaps(obj.body);
            else
                fprintf('\n')
                warning('No change detected, skipping maps loading...') 
            end
        end

        function obj = setSpectrum(obj)
            if obj.update_spectrum || ~obj.smart_calling
                obj.star = obj.star.integrateRadiance(obj.camera.QExT);
            else
                fprintf('\n')
                warning('No change detected, skipping spectrum setting...') 
            end
        end

        function obj = setDiscretization(obj)
            obj.setting = abram.render.setDiscretization(obj.body, obj.camera, obj.scene, obj.setting);
        end
        
        function obj = sampleSectors(obj)
            if obj.update_sectors || ~obj.smart_calling
                obj.body = abram.body.sampleSectors(obj.body, obj.camera, obj.scene, obj.setting);
            else
                fprintf('\n')
                warning('No change detected, skipping sectors sampling...') 
            end
        end

        function obj = renderScene(obj)
            if obj.update_render || ~obj.smart_calling
                obj.matrix = abram.render.renderScene(obj.star, obj.body, obj.camera, obj.scene, obj.setting);
            else
                fprintf('\n')
                warning('No change detected, skipping scene rendering...') 
            end
        end

        function obj = processImage(obj)
            if obj.update_image || ~obj.smart_calling
                obj.img = abram.render.processImage(obj.matrix, obj.star, obj.camera, obj.setting);
            else
                fprintf('\n')
                warning('No change detected, skipping image processing...') 
            end
        end

    end
end
