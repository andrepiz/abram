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
        amplification
        depth
        offset
        dnr
        QE
        T
        distortion
        noise
        fov_type
    end

    properties (Dependent)
        cu
        cv
        fu
        fv
        dpupil
        Apupil
        fov
        ifov
        sensorSize
        K
        G_DA
        QExT
        electronNoiseFloor
        dnNoiseFloor
        etaNormalizationFactor
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
            inputs.camera = add_missing_field(inputs.camera, {'quantum_efficiency','transmittance','distortion','noise'});
            inputs.camera.distortion = add_missing_field(inputs.camera.distortion, {'radial','decentering'});
            inputs.camera.noise = add_missing_field(inputs.camera.noise, {'dark','prnu','readout','shot'});

            % Fix resolution and size pixel sizes
            obj.res_px = extract_struct(inputs.camera,'resolution');
            obj.muPixel = extract_struct(inputs.camera,'pixel_width');

            % Assign properties
            obj.tExp = extract_struct(inputs.camera,'exposure_time');
            obj.f = extract_struct(inputs.camera,'focal_length');
            obj.fNum = extract_struct(inputs.camera,'f_number');
            obj.fwc = extract_struct(inputs.camera,'full_well_capacity');
            obj.G_AD = extract_struct(inputs.camera,'gain_analog2digital');
            obj.amplification = extract_struct(inputs.camera,'amplification',0);
            obj.offset = extract_struct(inputs.camera,'offset', 0);
            obj.dnr = extract_struct(inputs.camera,'dnr', 20*log10(obj.fwc/obj.G_DA));
            obj.distortion.radial = extract_struct(inputs.camera.distortion,'radial',[0, 0, 0]);
            obj.distortion.decentering = extract_struct(inputs.camera.distortion,'decentering',[0, 0]);
            obj.noise.shot.flag = extract_struct(inputs.camera.noise.shot, 'flag',false);
            obj.noise.prnu.flag = extract_struct(inputs.camera.noise.prnu, 'flag',false);
            obj.noise.dark.flag = extract_struct(inputs.camera.noise.dark, 'flag', false);
            obj.noise.readout.flag = extract_struct(inputs.camera.noise.readout, 'flag',false);
            obj.noise.prnu.sigma = extract_struct(inputs.camera.noise.prnu,'sigma',0);
            obj.noise.dark.sigma = extract_struct(inputs.camera.noise.dark,'sigma',0);
            obj.noise.readout.sigma = extract_struct(inputs.camera.noise.readout,'sigma',0);
            obj.noise.dark.mean = extract_struct(inputs.camera.noise.dark,'mean',0);
            obj.noise.shot.seed = extract_struct(inputs.camera.noise.shot, 'seed', 0);
            obj.noise.prnu.seed = extract_struct(inputs.camera.noise.prnu, 'seed',0);
            obj.noise.dark.seed = extract_struct(inputs.camera.noise.dark, 'seed', 0);
            obj.noise.readout.seed = extract_struct(inputs.camera.noise.readout, 'seed',0);
            obj.QE = abram.spectrum(inputs.camera.quantum_efficiency);
            obj.T = abram.spectrum(inputs.camera.transmittance);
        end

        %% GETTERS
        function val = get.dpupil(obj)
            val = obj.f/obj.fNum;
        end
        function val = get.Apupil(obj)
            % [m^2] area of the pupil
            val = pi*(obj.dpupil/2)^2; 
        end
        function val = get.fov(obj)
            % [rad] field of view
            switch obj.fov_type
                case 'cone'
                    val = 2*atan((obj.res_px(1)*obj.muPixel(1)/2)/obj.f);
                case 'frustum'
                    val = 2*atan((obj.res_px.*obj.muPixel/2)/obj.f); 
                otherwise
                    error('abram:camera','FOV shape not supported')
            end
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
        function val = get.ifov(obj)
            val = 2*atan((obj.muPixel/2)/obj.f);
        end
        function val = get.sensorSize(obj)
            val = obj.res_px.*obj.muPixel;
        end
        function val = get.electronNoiseFloor(obj)
            % DNR Is the ratio between the signal at saturation versus the minimum
            % signal the sensor can measure. EMVA1288 Standard.
            val = obj.fwc/(10^(obj.dnr/20));   
        end
        function val = get.dnNoiseFloor(obj)
            val = obj.G_AD*10^(obj.amplification/20)*obj.electronNoiseFloor;
        end
        function val = get.etaNormalizationFactor(obj)
            % Normalization factor used to retrieve effective radiant flux
            % density
            val = max(obj.QExT.values.*obj.QExT.lambda_mid);
        end
        %% SETTERS
        function obj = set.muPixel(obj, val)
            if length(obj.res_px) == 1 && length(val) == 1
                obj.muPixel = [val, val];
                obj.res_px = [obj.res_px, obj.res_px];
                obj.fov_type = 'cone';
            elseif length(obj.res_px) == 2 && length(val) == 1
                if obj.res_px(1) ~= obj.res_px(2)
                    warning('abram:camera','Non-uniform resolution, pixel set to square shape')
                end
                obj.muPixel = [val, val];
                obj.fov_type = 'frustum';
            elseif length(obj.res_px) == 1 && length(val) == 2
                if val(1) ~= val(2)
                    warning('abram:camera','Non-uniform pixel size, resolution set to square shape')
                end
                obj.muPixel = val;
                obj.res_px(2) = [obj.res_px, obj.res_px];
                obj.fov_type = 'frustum';
            else
                error('Please provide pixel size as a scalar or vector of two elements')
            end
        end

        function obj = set.QE(obj, sp)
            if isa(sp,'abram.spectrum')
                obj.QE = sp;
            else
                obj.QE = abram.spectrum(sp);
            end
        end

        function obj = set.T(obj, sp)
            if isa(sp,'abram.spectrum')
                obj.T = sp;
            else
                obj.T = abram.spectrum(sp); 
            end
        end
    end
end
