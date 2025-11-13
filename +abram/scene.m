classdef scene < abram.CRenderInput
    %SCENE Geometry of the scene. Container for the location and orientation
    %of the light, body and camera.

    properties
        phase_angle
        d_body2cam
        d_body2light
    end

    properties
        rpy_CAMI2CAM
        rpy_CSF2IAU
        pos_body2cam_IAU
        pos_body2light_IAU
        q_IAU2CAM
    end
    
    properties (Dependent)
        pos_body2cam_CSF
        pos_body2light_CSF
        dcm_CSF2CAM
        dcm_CSF2IAU
        dcm_CAM2IAU
    end

    properties (Dependent, Hidden)
        d_cam2body
        d_light2body
        pos_cam2body_CSF
        dir_body2cam_CSF
        dir_cam2body_CSF
        dir_cam2body_CAM
        pos_light2body_CSF
        dir_body2light_CSF
        dir_light2body_CSF
        dir_light2body_CAM
        dcm_CAMI2CAM
        dcm_CSF2CAMI
        ang_offpoint
        dir_body2light_IAU
        dir_body2cam_IAU
        sph_body2cam_IAU
    end

    properties (Constant, Hidden)
        dir_boresight_CAM = [0; 0; 1];
        dir_light_CSF = [1; 0; 0];
    end

    methods
        function obj = scene(in)
            %SCENE Construct a scene object by providing an inputs YML
            %file or a MATLAB struct. The default scene is the object at
            %1 km and the light at 150 million km.

            if nargin == 0
                % Missing inputs                
                warning('scene:io','Initializing object at 1 km and light at 150 million km as default scene')
                inputs.scene.phase_angle = 0;
                inputs.scene.d_body2cam = 1e3; 
                inputs.scene.d_body2light = 150e9;
            else
                % Load inputs
                switch class(in)
                    case {'char','string'}
                        if isfile(in)
                            inputs = yaml.ReadYaml(in);
                        else
                            error('scene:io','YML input file not found')
                        end
                    case {'struct'}
                        inputs = in;
                        if ~isfield(in, 'scene')
                            warning('scene:io','Initializing object at 1 km and light at 150 million km as default scene')
                            inputs.scene.phase_angle = 0;
                            inputs.scene.d_body2cam = 1e3; 
                            inputs.scene.d_body2light = 150e9;
                        end
                    otherwise 
                        error('scene:io','Plase provide input as either a YML filepath or a MATLAB struct')
                end
            end

            % Assign properties
            if isfield(inputs.scene,'phase_angle') && (isfield(inputs.scene,'d_body2cam') || isfield(inputs.scene,'distance_body2cam')) && (isfield(inputs.scene,'d_body2light') || isfield(inputs.scene,'distance_body2star'))
                % Classical ABRAM inputs
                obj.phase_angle = extract_struct(inputs.scene,'phase_angle');
                obj.d_body2cam = extract_struct(inputs.scene,{'d_body2cam','distance_body2cam'}); % portability from ABRAM v1.7
                obj.d_body2light = extract_struct(inputs.scene,{'d_body2light','distance_body2star'}); % portability from ABRAM v1.7
                obj.rpy_CSF2IAU = reshape(extract_struct(inputs.scene,{'rpy_CSF2IAU','rollpitchyaw_csf2iau'}, zeros(1, 3), true), 3, 1); % portability from ABRAM v1.7
                obj.rpy_CAMI2CAM = reshape(extract_struct(inputs.scene,{'rpy_CAMI2CAM','rollpitchyaw_cami2cam'}, zeros(1, 3), true), 3, 1); % portability from ABRAM v1.7

            elseif (isfield(inputs.scene,'pos_body2light_IAU') && isfield(inputs.scene,'pos_body2cam_IAU') && isfield(inputs.scene,'q_IAU2CAM')) || ...
                (isfield(inputs.scene,'position_body2star_iau') && isfield(inputs.scene,'position_body2cam_iau') && isfield(inputs.scene,'quaternion_iau2cam'))
                % IAU body-fixed inputs
                obj.pos_body2light_IAU = reshape(extract_struct(inputs.scene,{'pos_body2light_IAU','position_body2star_iau'}), 3, 1);  % portability from ABRAM v1.7
                obj.pos_body2cam_IAU = reshape(extract_struct(inputs.scene,{'pos_body2cam_IAU','position_body2cam_iau'}), 3, 1);  % portability from ABRAM v1.7
                obj.q_IAU2CAM = reshape(extract_struct(inputs.scene,{'q_IAU2CAM','quaternion_iau2cam'}), 4, 1);  % portability from ABRAM v1.7
                % [obj.phase_angle, obj.d_body2cam, obj.d_body2light, obj.rpy_CSF2IAU, obj.rpy_CAMI2CAM] = ...
                %     iau2abram(obj.pos_body2light_IAU, obj.pos_body2cam_IAU, obj.q_IAU2CAM, false);
            else
                error('abram:io','Please input the geometry as set A: phase_angle + d_body2cam + d_body2light (+ rpy_CSF2IAU + rpy_CAMI2CAM) or set B: pos_body2light_IAU + pos_body2cam_IAU + q_IAU2CAM')
            end

        end

        %% GETTERS
        function val = get.d_light2body(obj)
            val = obj.d_body2light;
        end
        
        function val = get.d_cam2body(obj)
            val = obj.d_body2cam;
        end
        
        function val = get.dir_body2cam_CSF(obj)
            val = [cos(obj.phase_angle); sin(obj.phase_angle); 0];
        end

        function val = get.dir_body2light_CSF(obj)
            val = obj.dir_light_CSF;
        end

        function val = get.pos_body2light_CSF(obj)
            val = obj.d_body2light*obj.dir_body2light_CSF;
        end

        function val = get.pos_body2cam_CSF(obj)
            val = obj.d_body2cam*obj.dir_body2cam_CSF;
        end

        function val = get.pos_light2body_CSF(obj)
            val = -obj.pos_body2light_CSF;
        end

        function val = get.pos_cam2body_CSF(obj)
            val = -obj.pos_body2cam_CSF;
        end

        function val = get.dir_light2body_CSF(obj)
            val = -obj.dir_body2light_CSF;
        end

        function val = get.dir_cam2body_CSF(obj)
            val = -obj.dir_body2cam_CSF;
        end

        function val = get.dir_cam2body_CAM(obj)
            val = obj.dcm_CSF2CAM*obj.dir_cam2body_CSF;
        end

        function val = get.dir_light2body_CAM(obj)
            val = obj.dcm_CSF2CAM*obj.dir_light2body_CSF;
        end

        function val = get.dcm_CSF2IAU(obj)
            val = euler_to_dcm(obj.rpy_CSF2IAU);
        end

        function val = get.dcm_CAMI2CAM(obj)
            val = euler_to_dcm(obj.rpy_CAMI2CAM);
        end
        
        function val = get.dcm_CSF2CAMI(obj)
            zCAMI_CSF = obj.dir_cam2body_CSF;
            yCAMI_CSF = [0; 0; -1];
            xCAMI_CSF = vecnormalize(cross(yCAMI_CSF, zCAMI_CSF));
            val = [xCAMI_CSF, yCAMI_CSF, zCAMI_CSF]';
        end

        function val = get.dcm_CSF2CAM(obj)
            val = obj.dcm_CAMI2CAM*obj.dcm_CSF2CAMI;
        end

        function val = get.dcm_CAM2IAU(obj)
            val = obj.dcm_CSF2IAU*obj.dcm_CSF2CAM';
        end

        function val = get.ang_offpoint(obj)
            % Angle of body direction with respect to boresight
            val = acos(dot(obj.dir_boresight_CAM, obj.dir_cam2body_CAM));
        end

        function obj = set.pos_body2light_IAU(obj, val)
            obj.pos_body2light_IAU = val;
            obj.d_body2light = norm(val);
            if ~isempty(obj.dir_body2cam_IAU)
                obj.phase_angle = acos(dot(obj.dir_body2light_IAU, obj.dir_body2cam_IAU));
                obj.rpy_CSF2IAU = quat_to_euler(quat_conj(csf(obj.dir_body2light_IAU, obj.dir_body2cam_IAU)));
            end
        end

        function obj = set.pos_body2cam_IAU(obj, val)
            obj.pos_body2cam_IAU = val;
            obj.d_body2cam = norm(val);
            if ~isempty(obj.dir_body2light_IAU)
                obj.phase_angle = acos(dot(obj.dir_body2light_IAU, obj.dir_body2cam_IAU));
                obj.rpy_CSF2IAU = quat_to_euler(quat_conj(csf(obj.dir_body2light_IAU, obj.dir_body2cam_IAU)));
            end
        end

        function obj = set.q_IAU2CAM(obj, val)
            if abs(norm(val) - 1) > 1e-6
                warning('abram:scene','The provided quaternion will be normalized as its norm is different from 1.')
                obj.q_IAU2CAM = val./norm(val);
            else
                obj.q_IAU2CAM = val;
            end
            dcm_CAMI2IAU = obj.dcm_CSF2IAU*obj.dcm_CSF2CAMI';
            obj.rpy_CAMI2CAM = dcm_to_euler(quat_to_dcm(val)*dcm_CAMI2IAU);
        end

        function val = get.dir_body2light_IAU(obj)
            val = obj.pos_body2light_IAU./obj.d_body2light;
        end

        function val = get.dir_body2cam_IAU(obj)
            val = obj.pos_body2cam_IAU./obj.d_body2cam;
        end

        function val = get.sph_body2cam_IAU(obj)
            val = sph_coord(obj.dcm_CSF2IAU*obj.pos_body2cam_CSF);
        end
    end
end
