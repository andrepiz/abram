%% FILL INPUTS

if length(res_px) == 1 && length(muPixel) == 1
    res_px(2) = res_px(1);
    muPixel(2) = muPixel(1);
end
if length(res_px) == 2 && length(muPixel) == 1
    if res_px(1) ~= res_px(2)
        warning('Non-uniform resolution, pixel set to square shape')
    end
    muPixel(2) = muPixel(1)*res_px(2)/res_px(1);
end
if length(res_px) == 1 && length(muPixel) == 2
    if muPixel(1) ~= muPixel(2)
        warning('Non-uniform pixel size, resolution set to square shape')
    end
    res_px(2) = res_px(1);
end
if ~exist('image_depth','var')
    warning('Assumed Image depth equal to 8 bits')
    image_depth = 8;
end
if ~exist('G_AD','var')
    warning('Assumed A/D Gain equal to (2^image_depth-1)/FWC')
    G_AD = (2^image_depth-1)/fwc;
end
if ~exist('noise_floor','var')
    warning('Assumed Noise Floor equal to D/A Gain')
    noise_floor = G_DA;
end
if ~exist('dcm_CAMI2CAM','var')
    dcm_CAMI2CAM = euler_to_dcm(eul_CAMI2CAM);
end
if ~exist('dcm_CSF2IAU','var')
    dcm_CSF2IAU = euler_to_dcm(eul_CSF2IAU);
end
if ~exist('radiometry_ro','var')
    radiometry_ro = 1;
    if strcmp(radiometry_model,'oren')
        warning('Missing roughness in Oren-Nayar model. Assuming 1')
    end
end
if ~exist('radiometry_sh','var')
    radiometry_sh = 1;
    if strcmp(radiometry_model,'specular')
        warning('Missing shineness in Specular model. Assuming 1')
    end
    if strcmp(radiometry_model,'phong')
        warning('Missing shineness in Phong model. Assuming 1')
    end
end
if ~exist('radiometry_wl','var')
    radiometry_wl = 0.5;
    if strcmp(radiometry_model,'phong')
        warning('Missing weight of Lambert in Phong model. Assuming 0.5')
    end
end
if ~exist('radiometry_ws','var')
    radiometry_ws = 0.5;
    if strcmp(radiometry_model,'phong')
        warning('Missing weight of Specular in Phong model. Assuming 0.5')
    end
end