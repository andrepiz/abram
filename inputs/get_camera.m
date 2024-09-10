% Physical constants

% Camera
switch case_camera
    case 1

        %% LUMIO CAM - VIS

        tExp = 0.04e-3;

        % Lens Assembly
        lambda_min = 450e-9;
        lambda_max = 820e-9;
        nbw = 1;
        D = 0.9; % Dicroico
        T = 0.8635*D;
        
        % Focal plane
        f = 127e-3;
        fNum = 2.5;
        dpupil = f/fNum;
        muPixel = 13.3e-6; % [m] pixel size (u,v)
        res_px = [1024 1024]; % [px] Resolution (u,v)
        fov = 2*atan((res_px.*muPixel/2)/f); % [rad] Field of view (u,v)

        % Detector
        QE = 0.8709;
        fwc = 80e3; 
        
        % AD Converter
        image_depth = 8;
        G_AD = (2^image_depth-1)/fwc;

    case 2

        %% LUMIO CAM - NIR

        tExp = 0.04e-3;

        % Lens Assembly
        lambda_min = 820e-9;
        lambda_max = 950e-9;
        nbw = 1;
        D = 0.9; % Dicroico
        T = 0.9313*D;
        
        % Focal plane
        f = 127e-3;
        fNum = 2.5;
        dpupil = f/fNum;
        muPixel = 13.3e-6; % [m] pixel size (u,v)
        res_px = [1024 1024]; % [px] Resolution (u,v)
        fov = 2*atan((res_px.*muPixel/2)/f); % [rad] Field of view (u,v)

        % Detector
        QE = 0.4063;
        fwc = 80e3; 
        
        % AD Converter
        image_depth = 8;
        G_AD = (2^image_depth-1)/fwc;

    case 3
                
        %% LEONARDO AA-STR
        
        tExp = 200e-3; % open-sky test

        % Lens Assembly
        lambda_min = (425:50:975)*1e-9;
        lambda_max = (475:50:1025)*1e-9;
        nbw = length(lambda_min); % number of bandwidths
        T = [0.410, 0.687, 0.915, 0.954, 0.967, 0.977, 0.979, 0.982, 0.984, 0.987, 0.989, 0.992]; % Lens transmittance per BW
        
        % Focal plane
        % taken from requirements, but actual FOV is different because the one in
        % the requirement refers to the baffle
        f = 50.7e-3;
        dpupil = 33.9e-3;
        muPixel = 18e-6; % [m] pixel size (u,v)
        res_px = [1024 1024]; % [px] Resolution (u,v)
        fov = 2*atan((res_px.*muPixel/2)/f); % [rad] Field of view (u,v)

        % Detector
        QE = [0.35, 0.43, 0.46, 0.45, 0.42, 0.37, 0.30, 0.23, 0.16, 0.09, 0.04, 0.02]; % Quantum Efficiency per BW
        fwc = 100e3; % [e-] from https://upverter.com/datasheet/1dbf6474f4834c5ac73294b488ac44ae8ac1f8ca.pdf
        
        % AD Converter
        image_depth = 12;
        G_AD = (2^image_depth-1)/fwc;

    case 4
        %% MARS COLOR CAMERA (ISRU)

        % ISRU Mars imaging
        tExp = 2e-3; % from 0.034e-3 to 490e-3

        % Lens Assembly
        lambda_min = (425:50:975)*1e-9;
        lambda_max = (475:50:1025)*1e-9;
        nbw = length(lambda_min); % number of bandwidths
        T = [0.410, 0.687, 0.915, 0.954, 0.967, 0.977, 0.979, 0.982, 0.984, 0.987, 0.989, 0.992]; % Lens transmittance per BW

        f = 105e-3; % [m] focal length 
        fNum = 4;
        fov = deg2rad(8.8);
        dpupil = f/fNum; % [-] F-number (focal length over diameter)
        muPixel = 5.5e-6; % [m] pixel size
        res_px = round(2*f/muPixel*tan(fov/2));

        % Detector
        QE = [0.35, 0.43, 0.46, 0.45, 0.42, 0.37, 0.30, 0.23, 0.16, 0.09, 0.04, 0.02]; % Quantum Efficiency per BW
        fwc = 100e3; % [e-] from https://upverter.com/datasheet/1dbf6474f4834c5ac73294b488ac44ae8ac1f8ca.pdf
        
        % AD Converter
        image_depth = 8;
        G_AD = (2^image_depth-1)/fwc;

    case 5
                
        %% TINYV3RSE
        
        tExp = 0.015e-3;

        % Lens Assembly
        lambda_min = (425:50:975)*1e-9;
        lambda_max = (475:50:1025)*1e-9;
        nbw = length(lambda_min); % number of bandwidths
        T = ones(1, nbw); % Lens transmittance per BW
        QE = ones(1, nbw); % Quantum Efficiency per BW

        % Focal plane
        f = 180e-3;
        muPixel = 44.1e-6; % [m] pixel size (u,v)
        res_px = [1440 1440]; % [px] Resolution (u,v)
        fov = 2*atan((res_px.*muPixel/2)/f); % [rad] Field of view (u,v)
        fNum = f/33.9e-3; % same pupil diameter of the aastr
        dpupil = f/fNum;

        % Detector
        fwc = 100e3; % [e-] from https://upverter.com/datasheet/1dbf6474f4834c5ac73294b488ac44ae8ac1f8ca.pdf
        
        % AD Converter
        image_depth = 8;
        G_AD = (2^image_depth-1)/fwc;

    case 6
                
        %% IDEAL
        
        tExp = 0.015e-3;
        
        % Lens Assembly
        lambda_min = 450e-9;
        lambda_max = 820e-9;
        nbw = 1;
        T = 1;
        QE = 1;
        
        % Focal plane
        f = 127e-3;
        fNum = 2.5;
        dpupil = f/fNum;
        muPixel = 13.3e-6; % [m] pixel size (u,v)
        res_px = [1024 1024]; % [px] Resolution (u,v)
        fov = 2*atan((res_px.*muPixel/2)/f); % [rad] Field of view (u,v)

        % Detector
        fwc = 100e3; % [e-] from https://upverter.com/datasheet/1dbf6474f4834c5ac73294b488ac44ae8ac1f8ca.pdf
        
        % AD Converter
        image_depth = 8;
        G_AD = (2^image_depth-1)/fwc;
end

