% Physical constants

% Scenario 
% International Astronomical Union (IAU) frame: 
%   centered at the planet COM
%   body-fixed frame, SPICE-consistent
% Camera-Sun-Frame (CSF) frame: 
%   centered at the planet COM
%   z-axis along normal to the camera-body-sun plane
%   x-axis along sun direction
%   y-axis completes the frame
% CAMI frame:
%   centered at the S/C
%   z-axis along camera-to-body direction
%   y-axis opposite to z_CSF
%   x-axis completes the frame
% CAM frame
%   centered at the S/C
%   z-axis along optical axis
%   y-axis rotated accordingly to off-pointing
%   x-axis completes the frame

switch case_scenario

    case 1
        % Leonardo open test
        tExp = 200e-3;
        percAreaIlluminated = 0.82; % https://www.moongiant.com/it/fase-lunare/23/11/2023/
        alpha = acos(2*percAreaIlluminated - 1);
        d_body2sc = 366953.14e3;
        eul_CAMI2CAM = [0;0;0];                     % [rad] Camera euler angles off-pointing (rpy). Note that yaw is optical axis
            % post-process
            dcm_CAMI2CAM = euler_to_dcm(eul_CAMI2CAM);
            dcm_CSF2IAU = eye(3);
            
    case 2
        % ISRU Mars imaging
        tExp = 2e-3; % from 0.034e-3 to 490e-3
        alpha = deg2rad(30);
        d_body2sc = 74500e3;
        eul_CAMI2CAM = [0;0;0];                     % [rad] Camera euler angles off-pointing (rpy). Note that yaw is optical axis
        eul_CSF2IAU = [pi + deg2rad(45); deg2rad(-12); deg2rad(25)];  % [rad] Body-fixed frame rotation wrt CSF frame
            % post-process
            dcm_CAMI2CAM = euler_to_dcm(eul_CAMI2CAM);
            dcm_CSF2IAU = euler_to_dcm(eul_CSF2IAU);

     case 3
        % Lumio trajectory from Corto inputs 
        tExp = 0.02e-3;
        % tExp_scenario = 0.02e-3;
        inputs_corto = [0 0 0 0 1 0 0 0 -32.264191721 -17.750344807 24.851316611 0.671986 0.409186 -0.15516 -0.597434 73851.064541941 -129877.91788227 3112.940542782];
        %inputs_corto = [99000 0 0 0 1 0 0 0 -33.468792237 -41.159669801 11.866820706 -0.180603 -0.485102 -0.382835 0.765177 40346.992979572 -143820.646844016 3155.862765357];
        %inputs_corto = [259200 0 0 0 1 0 0 0 -45.174965796 -52.774718132 -17.3767064 0.506134 0.761711 -0.049207 -0.401502 -18003.387576574 -148222.629718458 3212.749117793];
        inputs_corto = [0 0 0 0 1 0 0 0 -16 -9 12 0.671986 0.409186 -0.15516 -0.597434 73851.064541941 -129877.91788227 3112.940542782];
        [alpha, d_body2sc, d_body2star, q_CSF2IAU, q_CAMI2CAM] = inputs_corto2matlab(inputs_corto, 1e6, false);
            % post-process
            dcm_CAMI2CAM = quat_to_dcm(q_CAMI2CAM);
            dcm_CSF2IAU = quat_to_dcm(q_CSF2IAU);
        
end