function [L, LPCR] = black_body_radiance(temperature, lambda_min, lambda_max)
% BLACKBODYRADIANCE Compute the Radiance L [W/(m2*sr)] and Photon Count Rate Radiance 
% LPCR [(e-/s)/(m2*sr)] of a star across each band of a spectrum.

c = 299792458;      % m/s
h = 6.62607015e-34; % J/Hz
k = 1.380649e-23;   % J/K

% Black Body Spectral Radiance W/(m2*sr*m)
L_spectral = @(lambda) 2*h*c^2./(lambda.^5).*(1./(exp(h*c./(lambda*k*temperature)) - 1));
% Black Body Spectral Photon Count Rate e-/(s*m2*sr*m)
LPCR_spectral = @(lambda) 2*c./(lambda.^4).*(1./(exp( h*c./(lambda*k*temperature) ) - 1));

% Integrating over the wavelength for each BW
nbw = length(lambda_min);
L = zeros(1, nbw);
LPCR = zeros(1, nbw);
for ii = 1:nbw
    L(1, ii) = integral(L_spectral, lambda_min(ii), lambda_max(ii));
    LPCR(1, ii) = integral(LPCR_spectral, lambda_min(ii), lambda_max(ii));
end

end

