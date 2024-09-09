function visibility = get_visibility_mask(latgrid, longrid, pos_c2t_TAR, dcm_TAR2CAM, Rbody, fov, flag_debug)
% Given grids of latitude and longitude points defined in the target frame
% TAR where X axis is 0°N 0°E, Y axis is 0°N 90°E and Z axis is 90°N, 0°E,
% generate a mask of true/false values if the longitude/latitude
% point is visible by a camera defined in a CAM frame oriented at dcm_TAR2CAM 
% with respect to TAR and placed at a camera-to-target position pos_c2t in
% TAR.
% Camera boresight is assumed to be the third axis. 
% If fov is a 2-element vector, these are assumed to be the horizontal and vertical
% angular extension of a square fov. 

if size(latgrid, 1) ~= size(longrid, 1) || size(latgrid, 2) ~= size(longrid, 2)
    error('Sizes of longitude and latitude grids are not consistent')
end

% init
[nlat, nlon] = size(latgrid);
visibility = zeros(size(latgrid));

% cycling through latitudes
for ii = 1:nlat

    pos_t2p_TAR = cart_coord([repmat(Rbody, 1, nlon); longrid(ii, :); latgrid(ii, :)]);
    dir_t2p_CAM = vecnormalize(dcm_TAR2CAM*pos_t2p_TAR);
    dir_c2p_CAM = vecnormalize(dcm_TAR2CAM*(pos_c2t_TAR + pos_t2p_TAR));
    obsangle_CAM = acos(dot(dir_t2p_CAM, -dir_c2p_CAM));
            
    switch length(fov)
        case 1
            bearangle_CAM = acos(dir_c2p_CAM(3,:));
            visibility(ii, :) = bearangle_CAM <= fov/2 & obsangle_CAM <= pi/2;
        case 2
            bearangle_CAM = abs(atan(dir_c2p_CAM([1 2],:)./dir_c2p_CAM(3,:)));
            visibility(ii, :) = all(bearangle_CAM <= reshape(fov, 2, 1)/2) & obsangle_CAM <= pi/2;
    end

end

if flag_debug

    % MAP
    fh = figure(); 
    grid on, hold on
    imagesc(rad2deg(longrid(1,:)), rad2deg(latgrid(:,1)'), visibility)
    xlabel('lon_{TAR}')
    ylabel('lat_{TAR}')
    fh.CurrentAxes.YDir = 'normal';
    cb = colorbar;
    cb.Ticks = [0, 1];
    cb.TickLabels = {'Invisible','Visible'};

    % 3D
    dir_t2c_TAR = -vecnormalize(pos_c2t_TAR);
    cover = uint8((visibility+1)/2*(2^8-1));
    k = 1/Rbody; % scaling factor

    R_frames2ref(:,:,1) = eye(3);
    R_frames2ref(:,:,2) = dcm_TAR2CAM';
    R_pos_ref = k*[zeros(3, 1), -pos_c2t_TAR];
    v_ref = k*dir_t2c_TAR;
    v_pos_ref = zeros(3, 1);
    fh  = figure(); grid on; hold on; axis equal
    plot_frames_and_vectors(R_frames2ref, R_pos_ref, v_ref, v_pos_ref,...
        fh,...
        {'TAR','CAM'},{'Observer'});

    kP = 1;
    [xS, yS, zS] = sphere(100);
    h = surf(kP*xS, kP*yS, kP*zS);
    set(h, 'FaceColor', 'texturemap', 'CData', cover, 'EdgeColor', 'none','FaceAlpha',0.5);
    
    if length(fov) == 1
        % FOV
        h = 5; % baffle height
        b = 0.0; % baffle base: set to zero to model it as a cone
        npc = 20+1;
        sh = 10;    %scale factor for fov length wrt baffle height
        % create cylnder
        B = tan(fov/2)*h + b; % baffle major base
        SB = (sh*(B-b)+b)/B; %scale factor for major base given sh
        r = linspace(b, SB*B, npc); %cone radius
        [X,Y,Z] = cylinder(r);
        % create patch
        OH_urf = surf2patch(X,Y,Z*h*sh);
        OH_vert_urf = OH_urf.vertices';
        OH_vert_rbf = (k*-pos_c2t_TAR*ones(1,size(OH_vert_urf,2)) + (dcm_TAR2CAM'*OH_vert_urf))';
        OH_rbf = OH_urf;
        OH_rbf.vertices = OH_vert_rbf;
        % PLOT
        patch(OH_rbf,'FaceAlpha', 0.1,'FaceColor','g');
    end

    cameratoolbar
    xlabel('x [R]') 
    ylabel('y [R]')
    zlabel('z [R]')
    view(160,10)
    camzoom(6)
end

end
