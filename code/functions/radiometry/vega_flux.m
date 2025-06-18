function [F, FPCR] = vega_flux(lambda_min, lambda_max, weight, np_integration)
% VEGA_FLUX Compute integrated flux density F [W/m²] and photon count rate density FPCR [ph/s/m²]
% for Vega across specified wavelength bands using CALSPEC FITS data.
%
% Inputs:
%   lambda_min       [1×N] Lower wavelength limits of integration bands [m]
%   lambda_max       [1×N] Upper wavelength limits of integration bands [m]
%   weight           [1×N] Weighting factors per band (e.g., filter transmission integrals)
%   np_integration   (optional) Number of points for numerical integration (default: 100)
%
% Outputs:
%   F                [1×N] Integrated flux density per band [W/m²]
%   FPCR             [1×N] Integrated photon count rate per band [ph/s/m²]
%
% NOTE:
%   Requires: 'alpha_lyr_stis_011.fits' from CALSPEC (https://www.stsci.edu/hst/instrumentation/reference-data-for-calibration-and-tools/astronomical-catalogs/calspec)

% Default value for np_integration
if nargin < 4
    np_integration = 100;
end

% --- Constants ---
c = 299792458;          % Speed of light [m/s]
h = 6.62607015e-34;     % Planck's constant [J·s]

% --- Load Vega CALSPEC FITS Data ---
filename_fits = 'alpha_lyr_stis_011.fits';
if exist(filename_fits, "file")
    data_vega = fitsread(filename_fits, 'BinaryTable', 1);
else
    error('Missing FITS file. Please download "alpha_lyr_stis_011.fits" from CALSPEC website.');
end

% --- Extract and Convert Spectrum ---
lambda_tab = 1e-10 * data_vega{1}';        % Wavelengths [m] (convert from Å)
F_tab = data_vega{2}' * 1e-7 / (1e-4 * 1e-10); % Convert from erg/s/cm²/Å → W/m²/m
Eph = h * c ./ lambda_tab;                % Photon energy [J]
FPCR_tab = F_tab ./ Eph;                  % Photon count rate density [ph/s/m²/m]

% --- Check Input Sizes ---
nbw = length(lambda_min);
assert(isequal(size(lambda_min), size(lambda_max), size(weight)), ...
    'lambda_min, lambda_max, and weight must have the same dimensions.');

% --- Initialize Outputs ---
F = zeros(1, nbw);
FPCR = zeros(1, nbw);

% --- Integration Loop ---
for ii = 1:nbw
    % Interpolation points
    lambda_vec_temp = linspace(lambda_min(ii), lambda_max(ii), np_integration);

    % Interpolate flux and photon rate over this band
    F_interp = interp1(lambda_tab, F_tab, lambda_vec_temp, 'linear', 0);
    FPCR_interp = interp1(lambda_tab, FPCR_tab, lambda_vec_temp, 'linear', 0);

    % Integrate and apply weighting
    F(ii) = trapz(lambda_vec_temp, F_interp) * weight(ii);
    FPCR(ii) = trapz(lambda_vec_temp, FPCR_interp) * weight(ii);
end

end
