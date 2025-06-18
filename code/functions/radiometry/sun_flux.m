function [F, FPCR] = sun_flux(lambda_min, lambda_max, weight, np_integration)
% SUN_FLUX Compute integrated solar flux density F [W/m²] and photon count rate density FPCR [ph/s/m²]
% across specified wavelength bands using ASTM E-490 (AM0) solar spectrum data.
%
% Inputs:
%   lambda_min       [1×N] Lower wavelength limits of integration bands [m]
%   lambda_max       [1×N] Upper wavelength limits of integration bands [m]
%   weight           [1×N] Weighting factors per band (e.g., filter transmission integrals)
%   np_integration   (optional) Number of points for numerical integration (default: 100)
%
% Outputs:
%   F                [1×N] Integrated solar flux per band [W/m²]
%   FPCR             [1×N] Integrated photon count rate per band [photons/s/m²]
%
% NOTE:
%   Requires: 'e490_00a_amo.xls' from NREL
%   Download from: https://rredc.nrel.gov/solar/spectra/am0/

% --- Set default integration resolution ---
if nargin < 4
    np_integration = 100;
end

% --- Physical constants ---
c = 299792458;          % Speed of light [m/s]
h = 6.62607015e-34;     % Planck's constant [J·s]

% --- Load solar spectrum from NREL XLS file ---
filename_xls = 'e490_00a_amo.xls';
if exist(filename_xls, "file")
    data_sun = readtable(filename_xls,'VariableNamingRule','preserve');
else
    error('Missing XLS file. Please download "e490_00a_amo.xls" from NREL website.');
end

% --- Extract and convert spectrum data ---
lambda_tab = 1e-6 * data_sun{:,1};       % Wavelength [m] (from µm)
F_tab = data_sun{:,2} / 1e-6;            % Flux [W/m²/µm] → [W/m²/m]
Eph = h * c ./ lambda_tab;              % Photon energy [J]
FPCR_tab = F_tab ./ Eph;                % Photon flux [photons/s/m²/m]

% --- Check dimensions of inputs ---
nbw = length(lambda_min);
assert(isequal(size(lambda_min), size(lambda_max), size(weight)), ...
    'lambda_min, lambda_max, and weight must have the same dimensions.');

% --- Initialize output arrays ---
F = zeros(1, nbw);
FPCR = zeros(1, nbw);

% --- Perform integration for each band ---
for ii = 1:nbw
    % Define interpolation grid
    lambda_vec_temp = linspace(lambda_min(ii), lambda_max(ii), np_integration);

    % Interpolate spectral values over grid
    F_interp = interp1(lambda_tab, F_tab, lambda_vec_temp, 'linear', 0);
    FPCR_interp = interp1(lambda_tab, FPCR_tab, lambda_vec_temp, 'linear', 0);

    % Integrate using trapezoidal rule and apply band weight
    F(ii) = trapz(lambda_vec_temp, F_interp) * weight(ii);
    FPCR(ii) = trapz(lambda_vec_temp, FPCR_interp) * weight(ii);
end

end
