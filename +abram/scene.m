classdef scene < abram.CRenderInput
    %SCENE Geometry of the scene. Container for the location and orientation
    %of the light, body and camera.

    properties
        alpha
        d_body2cam
        d_body2star
    end

    properties
        rpy_CAMI2CAM
        rpy_CSF2IAU
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
        pos_star2body_CSF
        dir_body2star_CSF
        dir_star2body_CSF
        dcm_CAMI2CAM
        dcm_CSF2CAMI
        ang_offpoint
    end

    properties (Constant, Hidden)
        dir_boresight_CAM = [0; 0; 1];
    end

    methods
        function obj = scene(in)
            %SCENE Construct a scene object by providing an inputs YML
            %file or a MATLAB struct

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

            % Assign properties
            obj.alpha = extract_struct(inputs.scene,'phase_angle');
            obj.d_body2cam = extract_struct(inputs.scene,'distance_body2cam');
            obj.d_body2star = extract_struct(inputs.scene,'distance_body2star');
            obj.rpy_CSF2IAU = reshape(extract_struct(inputs.scene,'rollpitchyaw_csf2iau', zeros(1, 3), true), 3, 1);
            obj.rpy_CAMI2CAM = reshape(extract_struct(inputs.scene,'rollpitchyaw_cami2cam', zeros(1, 3), true), 3, 1);
        end

        %% GETTERS
        function val = get.d_star2body(obj)
            val = -obj.d_body2star;
        end
        
        function val = get.d_cam2body(obj)
            val = -obj.d_body2cam;
        end
        
        function val = get.dir_body2cam_CSF(obj)
            val = [cos(obj.alpha); sin(obj.alpha); 0];
        end

        function val = get.dir_cam2body_CSF(obj)
            val = -obj.dir_body2cam_CSF;
        end

        function val = get.pos_body2cam_CSF(obj)
            val = obj.d_body2cam*obj.dir_body2cam_CSF;
        end

        function val = get.pos_cam2body_CSF(obj)
            val = -obj.pos_body2cam_CSF;
        end

        function val = get.dir_body2star_CSF(obj)
            val = [1; 0; 0];
        end

        function val = get.dir_star2body_CSF(obj)
            val = -obj.dir_body2star_CSF;
        end

        function val = get.pos_body2star_CSF(obj)
            val = obj.d_body2star*obj.dir_body2star_CSF;
        end

        function val = get.pos_star2body_CSF(obj)
            val = -obj.pos_body2star_CSF;
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
            val = acos(pos_cam2body_CAM(3,:)./norm(pos_cam2body_CAM(3,:)));
        end

    end
end
