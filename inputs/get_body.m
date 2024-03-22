% Physical constants
AU = 149597870707; % [m]

% Body
switch case_body
    case 0
        % Lambertian sphere of 1m @1 AU
        d_body2star = AU;
        Rbody = 1; % [m] body radius
        pBond = 0.10; % [-] Bond albedo
        [pGeom, pNorm, pBond] = extrapolate_albedo(pBond, 'bond', reflectance_model);
        albedo_map = [];

    case 1        
        % Moon
        d_body2star = AU;
        Rbody = 1.7374e6; % [m] body radius
        pGeom = 0.10; 
        [pGeom, pNorm, pBond] = extrapolate_albedo(pGeom, 'geometric', reflectance_model);
        albedo_map = 'lroc_color_poles_2k.tif';
        albedo_nbit = 8;
        rescale_albedo = true;                 % Rescale albedo map to return a mean albedo equal to the geometric albedo

    case 2
        % Mars
        d_body2star = 1.52*AU;
        Rbody = 3389.5e3; % [m] body radius
        pGeom = 0.25; % [-] Bond albedo
        [pGeom, pNorm, pBond] = extrapolate_albedo(pGeom, 'geometric', reflectance_model);
        albedo_map = 'TES_Lambert_Albedo_mola.png';
        albedo_nbit = 8;
        rescale_albedo = true;                 % Rescale albedo map to return a mean albedo equal to the geometric albedo

    case 3
        % Bennu
        d_body2star = 1.1264*AU;
        Rbody = 262.5; % [m] body radius
        pBond = 0.05;  
        [pGeom, pNorm, pBond] = extrapolate_albedo(pBond, 'bond', reflectance_model);
        albedo_map = [];

    case 10
        % Moon w/o texture
        d_body2star = AU;
        Rbody = 1.7374e6; % [m] body radius
        pBond = 0.12; 
        [pGeom, pNorm, pBond] = extrapolate_albedo(pBond, 'bond', reflectance_model);
        albedo_map = [];

    case 20
        % Mars w/o texture
        d_body2star = 1.52*AU;
        Rbody = 3389.5e3; % [m] body radius
        pBond = 0.25; % [-] Bond albedo
        [pGeom, pNorm, pBond] = extrapolate_albedo(pBond, 'bond', reflectance_model);
        albedo_map = [];        
end