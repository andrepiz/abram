function QExT = responsivity2QExT(responsivity, wl, G_AD, calibCoeff, flag_spectral)
% Convert responsivity for a given wavelength 
% to Quantum Efficiency per Transmittance profile QExT in [e-/ph]. 
% Responsivity must be given in [DN/s / W] == [DN / J] or in [DN/s / W / m]
% if flag_spectral is true.
% Responsivity measured in laboratory may be corrected after in-flight
% calibration. In this case, filter-dependant calibration coefficients can
% be provided such that QExT are extracted from responsivity values
% divided by these coefficients.

if ~exist('calibCoeff','var')
    calibCoeff = 1;
end

if ~exist('flag_spectral','var')
    flag_spectral = false;
end

% power [W]
% E = hc/lambda [J]
% pcr = power/E [#/s]

c = 299792458;      % m/s
h = 6.62607015e-34; % J/Hz
hc = h*c;
E_wl = hc./wl;      % J

% ecr = QE*T*pcr [#/s]
% DN/s = G_AD * ecr = G_AD * QExT * power/E 

if flag_spectral
    % DN/s / wl = R * power
    % --> QExT = R * wl * power / (G_AD * power/E) = R * wl * E / G_AD = R * h*c / G_AD
    QExT = responsivity./calibCoeff .* hc ./ G_AD;
else
    % DN/s = R * power
    % --> QExT = R * power / (G_AD * power/E) = R * E / G_AD
    QExT = responsivity./calibCoeff .* E_wl ./ G_AD;
end

end