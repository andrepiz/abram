function [L, LPCR] = sun_radiance(lambda_min, lambda_max)
% SUN_RADIANCE Compute solar spectral radiance L [W/sr/m²] and photon radiance LPCR [ph/s/sr/m²]
% by converting the solar flux density and photon flux into radiance over specified wavelength bands.
%
% Inputs:
%   lambda_min   [1×N] Lower wavelength limits of integration bands [m]
%   lambda_max   [1×N] Upper wavelength limits of integration bands [m]
%
% Outputs:
%   L            [1×N] Spectral radiance per band [W/sr/m²]
%   LPCR         [1×N] Photon spectral radiance per band [ph/s/sr/m²]
%
% NOTE:
%   This function uses:
%     - sun_flux(): to compute solar flux and photon flux above atmosphere
%     - star_flux2radiance(): to convert flux densities into radiance assuming a uniform source
%   Requires solar spectrum file: 'e490_00a_amo.xls' from NREL
%   Download from: https://rredc.nrel.gov/solar/spectra/am0/

AU = 149597870700;
RSun = 695700000;

% Use uniform weighting across each band
weight = ones(1, length(lambda_min));

% Compute solar flux and photon flux per band
[F, FPCR] = sun_flux(lambda_min, lambda_max, weight);

% Convert flux to radiance (assumes isotropic projection or angular model inside star_flux2radiance)
L = star_flux2radiance(F, AU, RSun);
LPCR = star_flux2radiance(FPCR, AU, RSun);

end
