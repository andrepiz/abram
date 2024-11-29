classdef camera < abram.CRenderInput
    %CAMERA Sensor observing the target body. Container for the properties 
    %of the camera.

    properties
        tExp
        f
        fNum
        muPixel
        res_px       
        fwc
        G_AD
        QE
        T
    end

    properties (Dependent)
        cu
        cv
        fu
        fv
        dpupil
        Apupil
        fov
        sensorSize
        K
        G_DA
        QExT
    end

    properties (Hidden)
        change
    end
    
    methods
        function obj = camera(in)
            %CAMERA Construct a camera by providing an inputs YML
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
            inputs.camera = add_missing_field(inputs.camera, {'quantum_efficiency','transmittance'});

            % Fix resolution and size pixel sizes
            res_px = extract_struct(inputs.camera,'resolution');
            muPixel = extract_struct(inputs.camera,'pixel_width');
            if length(res_px) == 1 && length(muPixel) == 1
                res_px(2) = res_px(1);
                muPixel(2) = muPixel(1);
            end
            if length(res_px) == 2 && length(muPixel) == 1
                if res_px(1) ~= res_px(2)
                    warning('abram:camera','Non-uniform resolution, pixel set to square shape')
                end
                muPixel(2) = muPixel(1)*res_px(2)/res_px(1);
            end
            if length(res_px) == 1 && length(muPixel) == 2
                if muPixel(1) ~= muPixel(2)
                    warning('abram:camera','Non-uniform pixel size, resolution set to square shape')
                end
                res_px(2) = res_px(1);
            end

            % Assign properties
            obj.tExp = extract_struct(inputs.camera,'exposure_time');
            obj.f = extract_struct(inputs.camera,'focal_length');
            obj.fNum = extract_struct(inputs.camera,'f_number');
            obj.res_px = res_px;
            obj.muPixel = muPixel;
            obj.fwc = extract_struct(inputs.camera,'full_well_capacity');
            obj.G_AD = extract_struct(inputs.camera,'gain_analog2digital');
            obj.QE = abram.spectrum(inputs.camera.quantum_efficiency);
            obj.T = abram.spectrum(inputs.camera.transmittance);
        end

        %% GETTERS
        function val = get.dpupil(obj)
            val = obj.f/obj.fNum;
        end
        function val = get.Apupil(obj)
            val = pi*(obj.dpupil/2)^2; % [m^2] area of the pupil
        end
        function val = get.fov(obj)
            val = 2*atan((obj.res_px.*obj.muPixel/2)/obj.f); % [rad] field of view
        end
        function val = get.cu(obj)
            val = obj.res_px(1)/2; % [px] horizontal optical center
        end
        function val = get.cv(obj)
            val = obj.res_px(2)/2; % [px] vertical optical center
        end
        function val = get.fu(obj)
            val = obj.f./obj.muPixel(1); % [px] horizontal focal length in pixel
        end
        function val = get.fv(obj)
            val = obj.f./obj.muPixel(2); % [px] vertical focal length in pixel
        end
        function val = get.K(obj)
            val = [obj.fu    0           obj.cu;...
                   0         obj.fv      obj.cv;...
                   0         0           1]; % [-] projection matrix
        end
        function val = get.G_DA(obj)
            val = 1/obj.G_AD;
        end
        function val = get.QExT(obj)
            spectrum_vec = [obj.QE, obj.T];
            val = spectrum_vec.merge();   
        end
        % function val = get.dnr(obj)
        %     val = 20*log10(obj.fwc/obj.noise_floor);   % [-] dynamic range, definition
        % end

    end
end
