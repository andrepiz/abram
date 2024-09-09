% Body
switch case_body
    case 0
        % Lambertian sphere of 1m
        Rbody = 1; % [m] body radius
        albedo = 0.1; % [-] Bond albedo
        albedo_type = 'bond';
        albedo_filename = [];

    case 1        
        % Moon
        Rbody = 1.7374e6; % [m] body radius
        albedo = 0.18; % [-] Bond albedo
        albedo_type = 'geometric';
        albedo_filename = 'lroc_color_poles_2k.tif';
        albedo_depth = 8;
        albedo_mean = 0.12;                 % Rescale albedo map to return a mean albedo equal to the geometric albedo

    case 2
        % Mars
        Rbody = 3389.5e3; % [m] body radius
        albedo = 0.25; % [-] Bond albedo
        albedo_type = 'bond';
        albedo_filename = 'TES_Lambert_Albedo_mola.png';
        albedo_depth = 8;
        albedo_mean = 'albedo_geometric';                 % Rescale albedo map to return a mean albedo equal to the geometric albedo

    case 3
        % Bennu
        Rbody = 262.5; % [m] body radius
        albedo = 0.05; % [-] Bond albedo
        albedo_type = 'bond';
        albedo_filename = [];

    case 10
        % Moon w/o texture
        Rbody = 1.7374e6; % [m] body radius
        albedo = 0.18; % [-] Bond albedo
        albedo_type = 'bond';
        albedo_filename = [];

    case 20
        % Mars w/o texture
        Rbody = 3389.5e3; % [m] body radius
        albedo = 0.25; % [-] Bond albedo
        albedo_type = 'bond';
        albedo_filename = [];        
end

% Radiometry
radiometry_model = 'lambert';          % 'lambert'
                                        % 'lommel'
                                        % 'area'
                                        % 'oren': specify roughness
                                        % 'specular': specify shineness 
                                        % 'phong': specify shineness and lambert/specular weights
                                        % 'hapke': TBD
                                        radiometry_ro = 0.5;    % roughness in oren model (>> more rough)
                                        radiometry_sh = 1;      % shineness in specular model (>> more shine)
                                        radiometry_wl = 0.5; radiometry_ws = 2;   % weight of lambert and specular components in Phong model            