classdef light < abram.CRenderInput
    %LIGHT Source of illumination. Container for the properties of the
    %light and its integrated spectrum

    properties
        temperature
        radius
        shape
        type
        L
        LPCR 
    end

    methods
        function obj = light(in)
            %LIGHT Construct a light by providing an inputs YML
            %file or a MATLAB struct. The default light is the Sun.

            if nargin == 0
                % Missing inputs
                warning('light:io','Initializing Sun as default light')
                inputs.light = [];
            else
                % Load inputs
                switch class(in)
                    case {'char','string'}
                        if isfile(in)
                            inputs = yaml.ReadYaml(in);
                        else
                            error('light:io','YML input file not found')
                        end
                    case {'struct'}
                        inputs = in;
                        if isfield(inputs, 'star')
                            % portability from ABRAM v1.7
                            inputs.light = inputs.star;
                        end
                        if ~isfield(inputs, 'light')
                            warning('light:io','Initializing Sun as default light')
                            inputs.light = [];
                        end
                    otherwise 
                        error('light:io','Plase provide input as either a YML filepath or a MATLAB struct')
                end
            end

            obj.shape = extract_struct(inputs.light, 'shape', 'sphere', false);
            switch obj.shape
                case 'sphere'            
                    obj.radius = extract_struct(inputs.light, 'radius', 695000e3, false);
                    obj.temperature  = extract_struct(inputs.light, 'temperature', 5782, false);
                    obj.type = extract_struct(inputs.light, 'type', 'bb');
                    if strcmp(obj.type, 'spectrum')
                        if isfield(inputs.light, 'radiance')
                            L = extract_struct(inputs.light, 'radiance');
                            obj.L = abram.spectrum(L);
                        else
                            error('When light type is spectrum, a radiance spectrum has to be defined.')
                        end
                    else
                        if isfield(inputs.light, 'radiance')
                            warning('Specify light type as "spectrum" if you want to provide a radiance spectrum.')
                        end
                    end
                otherwise
                    error('light:io','Light sources with a different shape than "sphere" are not supported yet.')
            end
        end

        function obj = integrateRadiance(obj, spectrum)
            %INTEGRATERADIANCE Integrate the radiance of the light using a
            %given spectrum

            switch obj.type
                case 'bb'
                    spectrum.sampling = 'integral';
                    obj.L = spectrum;
                    obj.LPCR = spectrum;
                    [obj.L.values, obj.LPCR.values] = black_body_radiance(obj.temperature, spectrum.lambda_min, spectrum.lambda_max);

                case 'sun'
                    spectrum.sampling = 'integral';
                    obj.L = spectrum;
                    obj.LPCR = spectrum;
                    [obj.L.values, obj.LPCR.values] = sun_radiance(spectrum.lambda_min, spectrum.lambda_max);  

                case 'spectrum'
                    
                    if isa(obj.L,'struct')
                        obj.L = abram.spectrum(obj.L);
                    end
                    obj.LPCR = obj.L;
                    c = 299792458;      % m/s
                    h = 6.62607015e-34; % J/Hz
                    obj.LPCR.values = obj.L.lambda_mid/(h*c).*obj.L.values;

                otherwise
                    error('light:io','Light type not supported')
            end

        end

    end
end
