classdef scene < abram.CRenderInput
    %SCENE Geometry of the scene. Container for the location and orientation
    %of the light, body and camera.

    properties
        phase_angle
        d_body2cam
        d_body2star
    end

    properties
        rpy_CAMI2CAM
        rpy_CSF2IAU
        pos_body2cam_IAU
        pos_body2star_IAU
        q_IAU2CAM
    end
    
    properties (Dependent)
        pos_body2cam_CSF
        pos_body2star_CSF
        dcm_CSF2CAM
        dcm_CSF2IAU
    end

    properties (Dependent, Hidden)
        d_cam2body
        d_star2body
        pos_cam2body_CSF
        dir_body2cam_CSF
        dir_cam2body_CSF
        dir_cam2body_CAM
        pos_star2body_CSF
        dir_body2star_CSF
        dir_star2body_CSF
        dir_star2body_CAM
        dcm_CAMI2CAM
        dcm_CSF2CAMI
        ang_offpoint
        dir_body2star_IAU
        dir_body2cam_IAU
    end

    properties (Constant, Hidden)
        dir_boresight_CAM = [0; 0; 1];
    end

    methods
        function obj = scene(in)
            %SCENE Construct a scene object by providing an inputs YML
            %file or a MATLAB struct. The default scene is the object at
            %1 km and the star at 150 million km.

            if nargin == 0
                % Missing inputs                
                warning('scene:io','Initializing object at 1 km and star at 150 million km as default scene')
                inputs.scene.phase_angle = 0;
                inputs.scene.distance_body2cam = 1e3; 
                inputs.scene.distance_body2star = 150e9;
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
                    otherwise 
                        error('scene:io','Plase provide input as either a YML filepath or a MATLAB struct')
                end
            end

            % Assign properties
            if isfield(inputs.scene,'phase_angle') && isfield(inputs.scene,'distance_body2cam') && isfield(inputs.scene,'distance_body2star')
                % Classical ABRAM inputs
                obj.phase_angle = extract_struct(inputs.scene,'phase_angle');
                obj.d_body2cam = extract_struct(inputs.scene,'distance_body2cam');
                obj.d_body2star = extract_struct(inputs.scene,'distance_body2star');
                obj.rpy_CSF2IAU = reshape(extract_struct(inputs.scene,'rollpitchyaw_csf2iau', zeros(1, 3), true), 3, 1);
                obj.rpy_CAMI2CAM = reshape(extract_struct(inputs.scene,'rollpitchyaw_cami2cam', zeros(1, 3), true), 3, 1);

            elseif isfield(inputs.scene,'position_body2star_iau') && isfield(inputs.scene,'position_body2cam_iau') && isfield(inputs.scene,'quaternion_iau2cam')
                % IAU body-fixed inputs
                obj.pos_body2star_IAU = extract_struct(inputs.scene,'position_body2star_iau');
                obj.pos_body2cam_IAU = extract_struct(inputs.scene,'position_body2cam_iau');
                obj.q_IAU2CAM = extract_struct(inputs.scene,'quaternion_iau2cam');
                % [obj.phase_angle, obj.d_body2cam, obj.d_body2star, obj.rpy_CSF2IAU, obj.rpy_CAMI2CAM] = ...
                %     iau2abram(obj.pos_body2star_IAU, obj.pos_body2cam_IAU, obj.q_IAU2CAM, false);
            else
                error('abram:io','Please input the geometry as set A: phase_angle + distance_body2cam + distance_body2star (+ rollpitchyaw_csf2iau + rollpitchyaw_cami2cam) or set B: position_body2star_iau + position_body2cam_iau + quaternion_iau2cam')
            end

        end

        %% GETTERS
        function val = get.d_star2body(obj)
            val = obj.d_body2star;
        end
        
        function val = get.d_cam2body(obj)
            val = obj.d_body2cam;
        end
        
        function val = get.dir_body2cam_CSF(obj)
            val = [cos(obj.phase_angle); sin(obj.phase_angle); 0];
        end

        function val = get.dir_body2star_CSF(obj)
            val = [1; 0; 0];
        end

        function val = get.pos_body2star_CSF(obj)
            val = obj.d_body2star*obj.dir_body2star_CSF;
        end

        function val = get.pos_body2cam_CSF(obj)
            val = obj.d_body2cam*obj.dir_body2cam_CSF;
        end

        function val = get.pos_star2body_CSF(obj)
            val = -obj.pos_body2star_CSF;
        end

        function val = get.pos_cam2body_CSF(obj)
            val = -obj.pos_body2cam_CSF;
        end

        function val = get.dir_star2body_CSF(obj)
            val = -obj.dir_body2star_CSF;
        end

        function val = get.dir_cam2body_CSF(obj)
            val = -obj.dir_body2cam_CSF;
        end

        function val = get.dir_cam2body_CAM(obj)
            val = obj.dcm_CSF2CAM*obj.dir_cam2body_CSF;
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

        function val = get.ang_offpoint(obj)
            pos_cam2body_CAM = obj.dcm_CSF2CAM*obj.pos_cam2body_CSF;
            val = acos(pos_cam2body_CAM(3,:)./norm(pos_cam2body_CAM));
        end

        function obj = set.pos_body2star_IAU(obj, val)
            obj.pos_body2star_IAU = val;
            obj.d_body2star = norm(val);
            if ~isempty(obj.dir_body2cam_IAU)
                obj.phase_angle = acos(dot(obj.dir_body2star_IAU, obj.dir_body2cam_IAU));
                obj.rpy_CSF2IAU = quat_to_euler(quat_conj(csf(obj.dir_body2star_IAU, obj.dir_body2cam_IAU)));
            end
        end

        function obj = set.pos_body2cam_IAU(obj, val)
            obj.pos_body2cam_IAU = val;
            obj.d_body2cam = norm(val);
            if ~isempty(obj.dir_body2star_IAU)
                obj.phase_angle = acos(dot(obj.dir_body2star_IAU, obj.dir_body2cam_IAU));
                obj.rpy_CSF2IAU = quat_to_euler(quat_conj(csf(obj.dir_body2star_IAU, obj.dir_body2cam_IAU)));
            end
        end

        function obj = set.q_IAU2CAM(obj, val)
            obj.q_IAU2CAM = val;
            dcm_CAMI2IAU = obj.dcm_CSF2IAU*obj.dcm_CSF2CAMI';
            obj.rpy_CAMI2CAM = dcm_to_euler(quat_to_dcm(val)*dcm_CAMI2IAU);
        end

        function val = get.dir_body2star_IAU(obj)
            val = obj.pos_body2star_IAU./obj.d_body2star;
        end

        function val = get.dir_body2cam_IAU(obj)
            val = obj.pos_body2cam_IAU./obj.d_body2cam;
        end
    end
end
