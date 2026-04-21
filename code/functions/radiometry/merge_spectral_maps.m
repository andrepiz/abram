function [map, w_maps] = merge_spectral_maps(bandwidth, maps, lambda_min, lambda_max)
% MERGE_SPECTRAL_MAPS  Merge multiple spectral maps into a single
%                      bandwidth-weighted map.
%
% Each input map covers a spectral band [lambda_min(i), lambda_max(i)].
% The function computes a weighted average of all maps whose bands
% intersect the camera bandwidth, where weights are proportional to the
% fraction of each band that falls within the bandwidth.
%
% INPUTS:
%   bandwidth   [1x2] Camera sensitivity bandwidth [lambda_lo, lambda_hi]
%   maps        [RxCxN] Stack of N spectral maps (one per spectral band)
%   lambda_min  [Nx1] Lower wavelength bound of each band [nm]
%   lambda_max  [Nx1] Upper wavelength bound of each band [nm]
%
% OUTPUTS:
%   map         [RxC] Merged map (weighted average over intersecting bands)
%   w_maps      [1xN] Normalized weights in original input order

% --- Input validation ---
if numel(lambda_min) ~= numel(lambda_max)
    error('merge_spectral_maps:dimMismatch', ...
          'lambda_min and lambda_max must have the same number of elements.');
end
if size(maps, 3) ~= numel(lambda_min)
    error('merge_spectral_maps:dimMismatch', ...
          'maps 3rd dimension (%d) must match the number of spectral bands (%d).', ...
          size(maps, 3), numel(lambda_min));
end

% Find mid wavelength for each map
lambda_mid = (lambda_min + lambda_max)/2;

% Order maps by increasing wavelength
[lambda_mid, ixs_sorted] = sort(lambda_mid);
maps = maps(:, :, ixs_sorted);
lambda_min = lambda_min(ixs_sorted);
lambda_max = lambda_max(ixs_sorted);

% Check band contiguity (after sorting)
if ~all(abs(lambda_max(1:end-1) - lambda_min(2:end)) < 1e-9)
    error('merge_spectral_maps:nonContiguous', ...
          'Spectral bands must be contiguous (lambda_max(i) == lambda_min(i+1)).');
end

% Find bands intersecting the bandwidth
ix_left  = find(lambda_max >= bandwidth(1), 1, 'first');  % first band crossing left edge
ix_right = find(lambda_min <= bandwidth(2), 1, 'last');   % last band crossing right edge

band_widths = lambda_max - lambda_min;
w_maps = zeros(1, numel(lambda_mid));
dbw = bandwidth(2) - bandwidth(1);

if ix_left == ix_right
    % Bandwidth falls entirely within one band
    w_maps(ix_left) = dbw / band_widths(ix_left);
else
    % Partial left edge band
    w_maps(ix_left) = (lambda_max(ix_left) - bandwidth(1)) / band_widths(ix_left);
    % Partial right edge band
    w_maps(ix_right) = (bandwidth(2) - lambda_min(ix_right)) / band_widths(ix_right);
    % Full interior bands
    for i = ix_left+1 : ix_right-1
        w_maps(i) = band_widths(i) / band_widths(i);  % = 1, fully inside
    end
    w_maps(ix_left+1 : ix_right-1) = 1;
end

% Clip negatives (safety, should not occur with correct indices)
w_maps(w_maps < 0) = 0;

% Normalize weights
w_maps = w_maps/sum(w_maps);

% Merge the albedos
map = sum(reshape(maps, size(maps, 1), size(maps,2), []).*reshape(w_maps, 1, 1, []), 3);
w_maps(ixs_sorted) = w_maps;

end