function [hwhm, lambda_eff] = findHWHM(lambda, val)
% Returns the Half-Width Half-Maximum (HWHM) waveband and effective wavelength of a
% spectrum given a vector of wavelengths and values at each wavelength. The
% The half-maximum of the spectrum is found at lambda_eff + hwhm and
% lambda_eff - hwhm by definition.

% Find the maximum value and its index
[val_max, idx_max] = max(val);
x_center = lambda(idx_max);

% Half maximum
half_max = val_max / 2;

% Find left side crossing
left_idx = find(val(1:idx_max) < half_max, 1, 'last');
if isempty(left_idx)
    error('No left crossing found.');
end
% Linear interpolation for more accurate crossing
lambda1 = interp1(val(left_idx:left_idx+1), lambda(left_idx:left_idx+1), half_max);

% Find right side crossing
right_idx = find(val(idx_max:end) < half_max, 1, 'first') + idx_max - 1;
if isempty(right_idx)
    error('No right crossing found.');
end
lambda2 = interp1(val(right_idx-1:right_idx), lambda(right_idx-1:right_idx), half_max);

% FWHM and HWHM
fwhm = lambda2 - lambda1;
hwhm = fwhm / 2;
lambda_eff = lambda1 + hwhm;
end