classdef star < abram.CRenderInput
    %STAR Source of light. Container for the properties of the star and the
    %integrated spectrum of light.

    properties
        temperature
        Rstar
        type
        L
        LPCR 
    end

    methods
        function obj = star(in)
            %STAR Construct a star by providing an inputs YML
            %file or a MATLAB struct

            % Load inputs
            switch class(in)
                case {'char','string'}
                    if isfile(in)
                        inputs = yaml.ReadYaml(in);
                    else
                        error('star:io','YML input file not found')
                    end
                case {'struct'}
                    inputs = in;
                otherwise 
                    error('star:io','Plase provide input as either a YML filepath or a MATLAB struct')
            end
                    
            obj.temperature  = extract_struct(inputs.star, 'temperature', 5782, true);
            obj.Rstar = extract_struct(inputs.star, 'radius', 695000e3, true);
            obj.type = extract_struct(inputs.star, 'type', 'bb');
        end

        function obj = integrateRadiance(obj, spectrum)
            %INTEGRATERADIANCE Integrate the radiance of the star using a
            %given spectrum

            spectrum.sampling = 'integral';
            obj.L = spectrum;
            obj.LPCR = spectrum;
            switch obj.type
                case 'bb'
                    [obj.L.values, obj.LPCR.values] = black_body_radiance(obj.temperature, spectrum.min, spectrum.max);
                otherwise
                    error('star:io','Star type not supported')
            end

        end

    end
end
