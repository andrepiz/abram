function [F, Fph] = getVegaFlux(color)
% from http://spiff.rit.edu/classes/phys440/lectures/filters/filters.html
  %  Passband      Energy Flux       Photon "flux"
  %              (erg/sq.cm/sec)   (photons/sq.cm/sec)
  % ---------------------------------------------------
  %     U          2.96e-06            550,000
  %     B          5.27e-06          1,170,000
  %     V          3.16e-06            866,000
  %     R          3.39e-06          1,100,000
  %     I          1.68e-06            675,000
  % ---------------------------------------------------


switch color
    case 'U'
        F = 2.96e-6; 
        Fph = 550e3;

    case 'B'
        F = 5.27e-6;
        Fph = 1170e3;

    case 'V'
        F = 3.16e-6;
        Fph = 866e3;

    case 'R'
        F = 3.39e-6;
        Fph = 1100e3;

    case 'I'
        F = 1.68e-6;
        Fph = 675e3;

    otherwise
        error('Plase input U, B, V, R or I color')
end

erg = 1e-7; % joule
F = F*erg/(0.01^2); %[W/m2]
Fph = Fph/(0.01^2); %[ph/s/m2]

end