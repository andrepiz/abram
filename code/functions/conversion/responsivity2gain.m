function gain = responsivity2gain(responsivity, wl, muPixel, QExT, flag_per_area)
% Convert responsivity for a given wavelength 
% to Analog-to-Digital gain in [DN/e-]. If QExT is not specified, the
% gain returned will be the product of gain and QExT in that bandwidth.
% Responsivity must be given in [DN/s / W] == [DN / J] if
% flag_per_area is set to false or in [DN/s / W / m2] == [DN / J/m2] if
% flag_per_area is set to true (default).

if ~exist('QExT','var')
    QExT = 1;
end
if ~exist('flag_per_area','var')
    flag_per_area = true;
end

% power [W]
% E = hc/lambda [J]
% pcr = power/E [#/s]

c = 299792458;      % m/s
h = 6.62607015e-34; % J/Hz
E_wl = h*c./wl;      % J

% ecr = QE*T*pcr [#/s]
% DN/s = G_AD * ecr = G_AD * QExT * power/E 

if flag_per_area
    % DN/s = R * power/Apx
    % --> G_AD = R * (power/Apx) / (QExT * power/E) = R * E / Apx / QExT

    Apx = muPixel.^2;   % m^2

    gain = responsivity .* E_wl ./Apx ./ QExT;

else
    % DN/s = R * power
    % --> G_AD = R * signal / (QExT * signal/E) = R * E / QExT

    gain = responsivity .* E_wl ./ QExT;

end

end