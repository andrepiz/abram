function [map, w_maps] = merge_spectral_maps(bandwidth, maps, lambda_min, lambda_max)
% Merge multiple spectral maps defined between minimum and maximum
% wavelengths into a single map defined in a single bandwidth

if size(lambda_min, 1) ~= size(lambda_max, 1)
    error('Minimum and maximum wavelength vectors should have the same dimension')
end

% Find mid wavelength for each map
lambda_mid = (lambda_min + lambda_max)/2;

if size(maps, 3) ~= length(lambda_mid)
    error('Maps 3rd dimension should be equal to the dimension of the minimum and maximum wavelengths')
end

% Order maps by increasing wavelength
[lambda_mid, ixs_sorted] = sort(lambda_mid);
maps = maps(:, :, ixs_sorted);
lambda_min = lambda_min(ixs_sorted);
lambda_max = lambda_max(ixs_sorted);

% Cap bandwidth between the albedos bandwidth
lambdaCam_min = max(bandwidth(1), min(lambda_min));
lambdaCam_max = min(bandwidth(2), max(lambda_max));

% Init weight vector
w_maps = zeros(1, length(lambda_mid));

% Find the map points that intersect the bandwidth
ix_left = find(lambda_min - lambdaCam_min <= 0);
ix_right = find(lambda_max - lambdaCam_max >= 0);

% Find corresponding weights for those points
w_left = (lambda_max(ix_left) - lambdaCam_min)/(lambda_max(ix_left) - lambda_min(ix_left));
w_right = (lambdaCam_max - lambda_min(ix_right))/(lambda_max(ix_right) - lambda_min(ix_right));

% Assign weights
w_maps(ix_left) = w_left;
w_maps(ix_right) = w_right;
w_maps(ix_left + 1:ix_right - 1) = 1;
w_maps = w_maps/sum(w_maps);

% Merge the albedos
map = sum(reshape(maps, size(maps, 1), size(maps,2), []).*reshape(w_maps, 1, 1, []), 3);
w_maps(ixs_sorted) = w_maps;

end