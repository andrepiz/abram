function gain = responsivity2gain(responsivity, wl, muPixel)
% Convert responsivity in DN/(J/m2) for a specified wavelength 
% to Analog-to-Digital gain in DN/e-

% J/m to photon
% signal [J]
% E = hc/lambda [J]
% ph = signal/E [#]
% e- = QE*T*ph
% DN = G_AD*e- = G_AD*QE*T*signal/E

c = 299792458;      % m/s
h = 6.62607015e-34; % J/Hz
E_wl = h*c/wl;      % J
Apx = muPixel.^2;   % m^2

gain = responsivity.*E_wl./Apx;

end