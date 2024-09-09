function [normal, debug] = height2normal(longrid, latgrid, height, params)
% Convert a height/displacement map to a normal map using either a plane
% fitting algorithm or a mean normal algorithm
%
% INPUTS:
% longrid [u, v]                        Grid of longitude values 
% latgrid [u, v]                        Grid of latitude values 
% height [u, v]                         2D matrix of height values at each
%                                       longitude and latitude point 
% params.flag_debug [true/false]        Plot points and normals
% params.fitting_error_threshold [1]    If plane fitting error is larger than 
%                                       this threshold, the normal is computed as the mean of the normals of the
%                                       neighbouring triangles
% OUTPUTS:
% normal [u, v, 3]                      Map of 3d normals at each longitude and
%                                       latitude
% debug

if ~exist('params.flag_debug','var')
    params.flag_debug = false;
end
if ~exist('params.fitting_error_threshold','var')
    params.fitting_error_threshold = 0.002; 
end

if params.flag_debug
    fh = figure();
    ax = axes(fh);
    grid on, hold on, axis equal
end

% init
[nlat, nlon] = size(height);
normal = zeros(nlat, nlon, 3);

for ii = 1:nlon

    disp([num2str(1e2*(ii)/(nlon)),'%'])

    for jj = 1:nlat

        ix_lon = ii-1:ii+1;
        ix_lon(ix_lon == 0 | ix_lon == nlon + 1) = [];
        ix_lat = jj-1:jj+1;
        ix_lat(ix_lat == 0 | ix_lat == nlat + 1) = [];

        rKern = height(ix_lat, ix_lon);
        rMid = height(jj, ii);
        
        azKern = longrid(ix_lat, ix_lon);
        azMid = longrid(jj, ii);
        elKern = latgrid(ix_lat, ix_lon);
        elMid = latgrid(jj, ii);

        sphKern(1,:,:) = rKern;
        sphKern(2,:,:) = azKern;
        sphKern(3,:,:) = elKern;
        cartKern = cart_coord(sphKern);
        cartMid = cart_coord([rMid; azMid; elMid]);

        x = reshape(cartKern(1, :, :), 1, []);
        y = reshape(cartKern(2, :, :), 1, []);
        z = reshape(cartKern(3, :, :), 1, []);

        % Construct the matrix A and vector b for Ax = b
        A = [x', y', ones(length(x), 1)];
        b = z';
        
        % Solve the least squares problem to find the plane coefficients
        coeffs = A \ b;

        % % Check singularity
        % while cond(A) > threshold_cond
        %     A = A(1:end-1,:);
        %     b = b(1:end-1);
        % end
        debug.cond(jj, ii) = cond(A);
        debug.err(jj, ii) = mean(abs(A*coeffs-b))./norm(cartMid);

        if debug.err(jj, ii) < params.fitting_error_threshold
            % The plane equation is: z = Ax + By + C
            % Rearrange to Ax + By - z + C = 0
            % A vector normal to the plane is [A, B, -1]
            vec_norm = [coeffs(1); coeffs(2); -1];
            % disp(['Plane fitting ', num2str(1e2*(ii)/(Nlon)),'%'])
            debug.algo(jj, ii) = 1;
        else
            % Compute the normal as the mean of the normals of each
            % triangle
            pts = [x; y; z];
            vec = pts - repmat(cartMid, 1, size(A, 1));
            
            % figure(), hold on, for ix = 1:size(A,1), quiver3(pts(1,ix), pts(2,ix), pts(3,ix), vec(1,ix), vec(2,ix), vec(3,ix)), text(pts(1,ix), pts(2,ix), pts(3,ix), num2str(ix)), end

            switch size(A, 1)
                case 9
                    vec_cross = cross(vec(:, [3 6 9 8 7 4 1 2]), vec(:, [6 9 8 7 4 1 2 3]));
                case 6
                    if abs(sum(vec(:, 2))) < eps
                        vec_cross = cross(vec(:, [3 6 5 4]), vec(:, [6 5 4 1]));
                    elseif abs(sum(vec(:, 5))) < eps
                        vec_cross = cross(vec(:, [4 1 2 3]), vec(:, [1 2 3 6]));
                    else
                        error(['Singularity detected at point (', num2str(ii), ',',num2str(jj),')'])
                    end
                case 4
                    if abs(sum(vec(:, 1))) < eps
                        vec_cross = cross(vec(:, [2 4]), vec(:, [4 3]));
                    elseif abs(sum(vec(:, 2))) < eps
                        vec_cross = cross(vec(:, [4 3]), vec(:, [3 1]));
                    elseif abs(sum(vec(:, 3))) < eps
                        vec_cross = cross(vec(:, [1 2]), vec(:, [2 4]));
                    elseif abs(sum(vec(:, 4))) < eps                   
                        vec_cross = cross(vec(:, [3 1]), vec(:, [1 2]));
                    else
                        error(['Singularity detected at point (', num2str(ii), ',',num2str(jj),')'])
                    end
                otherwise
                    error('Kernel size not allowed')
            end
            norms = vecnormalize(vec_cross);
            vec_norm = mean(norms, 2);
            % disp(['Mean normal ', num2str(1e2*(ii)/(Nlon)),'%'])
            debug.algo(jj, ii) = 2;

            % % drop point
            % ix_drop = randi([1, length(b)]);
            % A(ix_drop,:) = [];
            % b(ix_drop) = [];
            % coeffs = A \ b;
            % err(ii,jj) = sum(abs(A*coeffs-b));
            % ix_drop
        end

        % Final normalization
        vec_normalized = vecnormalize(vec_norm);

        % Invert to make it outward
        if dot(vec_normalized, vecnormalize(cartMid)) < 0
            vec_normalized = -vec_normalized;
        end

        normal(jj, ii, 1:3) = vec_normalized;

        clear sphKern

        if params.flag_debug
            scatter3(ax, x, y, z, 'o');
            quiver3(ax, cartMid(1), cartMid(2), cartMid(3), vec_normalized(1), vec_normalized(2), vec_normalized(3))
        end
    end
end

end