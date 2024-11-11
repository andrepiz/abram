classdef body
    %BODY Illuminated body
    %   Container for the properties, location and orientation of the body

    properties
        Rbody
        albedo
        albedo_type
        maps       
        radiometry
        sampling
    end

    properties (Dependent)
        pGeom
        pBond
        pNorm
        H
    end

    properties (Hidden)
        change
    end

    methods
        function obj = body(in)
            %BODY Construct a celestial body by providing an inputs YML
            %file or a MATLAB struct

            % Load inputs
            switch class(in)
                case {'char','string'}
                    if isfile(in)
                        inputs = yaml.ReadYaml(in);
                    else
                        error('render:io','YML input file not found')
                    end
                case {'struct'}
                    inputs = in;
                otherwise 
                    error('render:io','Plase provide input as either a YML filepath or a MATLAB struct')
            end

            % Add missing fields
            inputs.body = add_missing_field(inputs.body, 'maps');
            inputs.body.maps = add_missing_field(inputs.body.maps, {'albedo','displacement','normal'});

            % Assign properties
            obj.Rbody = extract_struct(inputs.body, 'radius');
            obj.albedo = extract_struct(inputs.body, 'albedo');
            obj.albedo_type = extract_struct(inputs.body, 'albedo_type', 'geometric', true);
            obj.maps = extract_struct(inputs.body, 'maps', []);
            obj.radiometry = extract_struct(inputs.body, 'radiometry');

            obj.change = true;
        end

        %% GET %%
        function val = get.H(obj)
            % Absolute magnitude, https://cneos.jpl.nasa.gov/tools/ast_size_est.html        
            val = 5*(3.1236 - log10(2*obj.Rbody) - 0.5*log10(obj.pGeom));
        end
        function val = get.pGeom(obj)
            [val, ~, ~] = extrapolate_albedo(obj.albedo, obj.albedo_type, obj.radiometry.model);
        end
        function val = get.pNorm(obj)
            [~, val, ~] = extrapolate_albedo(obj.albedo, obj.albedo_type, obj.radiometry.model);
        end
        function val = get.pBond(obj)
            [~, ~, val] = extrapolate_albedo(obj.albedo, obj.albedo_type, obj.radiometry.model);
        end

        %% SET %%
        function obj = set.radiometry(obj, in)
            obj.radiometry.model = extract_struct(in, 'model','lambert',true);
            obj.radiometry.ro = extract_struct(in, 'roughness', []);
            obj.radiometry.sh = extract_struct(in, 'shineness', []);
            obj.radiometry.wl = extract_struct(in, 'weight_lambert', []);
            obj.radiometry.ws = extract_struct(in, 'weight_specular', []);
        end

        function obj = set.maps(obj, in)
            f = fields(in);
            for ix = 1:length(f)
                obj.maps.(f{ix}).filename = extract_struct(in.(f{ix}), 'filename',[]);
                obj.maps.(f{ix}).F = extract_struct(in.(f{ix}), 'F',[]);
                obj.maps.(f{ix}).type = extract_struct(in.(f{ix}), 'type',[]);
                obj.maps.(f{ix}).depth = extract_struct(in.(f{ix}), 'depth',1);
                obj.maps.(f{ix}).scale = extract_struct(in.(f{ix}), 'scale',[]);
                obj.maps.(f{ix}).gamma = extract_struct(in.(f{ix}), 'gamma',[]);
                obj.maps.(f{ix}).domain = extract_struct(in.(f{ix}), 'domain',[]);
                obj.maps.(f{ix}).mean = extract_struct(in.(f{ix}), 'mean',[]);
            end
        end
    end

end