% Physical constants

% Camera
switch case_camera
    case 1

        %% LUMIO CAM - VIS

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
        muPixel = 13.3e-6; % [m] pixel size
        res_px = 1024; % [px] Resolution in pixel
        fov = 2*atan((res_px*muPixel/2)/f); % focal length
        fov_shape = 'square';

        % Detector
        QE = 0.8709;
        fwc = 80e3; 
        
        % AD Converter
        G_DA_nbit = 8;
        G_DA = fwc/(2^G_DA_nbit-1);
        G_AD = 1/G_DA;
        G_AD_nbit = G_DA_nbit;
        noise_floor = G_DA; % assumed conservatively as equal to the DN difference
        snr = log10(fwc/noise_floor);   % definition

    case 2

        %% LUMIO CAM - NIR

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
        muPixel = 13.3e-6; % [m] pixel size
        res_px = 1024; % [px] Resolution in pixel
        fov = 2*atan((res_px*muPixel/2)/f); % focal length
        fov_shape = 'square';

        % Detector
        QE = 0.4063;
        fwc = 80e3; 
        
        % AD Converter
        G_DA_nbit = 8;
        G_DA = fwc/(2^G_DA_nbit-1);
        G_AD = 1/G_DA;
        G_AD_nbit = G_DA_nbit;
        noise_floor = G_DA; % assumed conservatively as equal to the DN difference
        snr = log10(fwc/noise_floor);   % definition

    case 3
                
        %% LEONARDO AA-STR
        
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
        muPixel = 18e-6; % [m] pixel size
        res_px = 1024; % [px] Resolution in pixel
        % to change in requirements
        fov = 2*atan((res_px*muPixel/2)/f); % focal length
        fov_shape = 'circle';

        % Detector
        QE = [0.35, 0.43, 0.46, 0.45, 0.42, 0.37, 0.30, 0.23, 0.16, 0.09, 0.04, 0.02]; % Quantum Efficiency per BW
        fwc = 100e3; % [e-] from https://upverter.com/datasheet/1dbf6474f4834c5ac73294b488ac44ae8ac1f8ca.pdf
        
        % AD Converter
        G_DA_nbit = 8;
        %G_DA_nbit = 16;
        G_DA = fwc/(2^G_DA_nbit-1);
        G_AD = 1/G_DA;
        G_AD_nbit = G_DA_nbit;
        noise_floor = G_DA; % assumed conservatively as equal to the DN difference
        snr = log10(fwc/noise_floor);   % definition

    case 4
        %% MARS COLOR CAMERA (ISRU)

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
        fov_shape = 'square';

        % Detector
        QE = [0.35, 0.43, 0.46, 0.45, 0.42, 0.37, 0.30, 0.23, 0.16, 0.09, 0.04, 0.02]; % Quantum Efficiency per BW
        fwc = 100e3; % [e-] from https://upverter.com/datasheet/1dbf6474f4834c5ac73294b488ac44ae8ac1f8ca.pdf
        
        % AD Converter
        G_DA_nbit = 8;
        G_DA = fwc/(2^G_DA_nbit-1);
        G_AD = 1/G_DA;
        G_AD_nbit = 8;
        noise_floor = G_DA; % assumed conservatively as equal to the DN difference
        snr = log10(fwc/noise_floor);   % definition

    case 5
                
        %% TINYV3RSE
        
        % Lens Assembly
        lambda_min = (425:50:975)*1e-9;
        lambda_max = (475:50:1025)*1e-9;
        nbw = length(lambda_min); % number of bandwidths
        T = ones(1, nbw); % Lens transmittance per BW
        QE = ones(1, nbw); % Quantum Efficiency per BW
        % T = [0.410, 0.687, 0.915, 0.954, 0.967, 0.977, 0.979, 0.982, 0.984, 0.987, 0.989, 0.992]; % Lens transmittance per BW
        % QE = [0.35, 0.43, 0.46, 0.45, 0.42, 0.37, 0.30, 0.23, 0.16, 0.09, 0.04, 0.02]; % Quantum Efficiency per BW

        % Focal plane
        % FOV and f# as before
        fov = 2*atan((1024*18e-6/2)/50.7e-3);
        fNum = 50.7e-3/33.9e-3;
        muPixel = 44.1e-6; % [m] pixel size
        res_px = 1440; % [px] Resolution in pixel
        % to change in requirements
        f = res_px*muPixel/2/tan(fov/2); % focal length
        dpupil = f/fNum;
        fov_shape = 'square';

        % Detector
        fwc = 100e3; % [e-] from https://upverter.com/datasheet/1dbf6474f4834c5ac73294b488ac44ae8ac1f8ca.pdf
        
        % AD Converter
        G_DA_nbit = 8;
        G_DA = fwc/(2^G_DA_nbit-1);
        G_AD = 1/G_DA;
        G_AD_nbit = G_DA_nbit;
        noise_floor = G_DA; % assumed conservatively as equal to the DN difference
        snr = log10(fwc/noise_floor);   % definition
end