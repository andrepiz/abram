function ssa = pnrf2ssa(pnrf, body, fitting, wl)

switch body
    case 'moon'

        if ~exist('fitting','var')
            fitting = 'linear';
        end

        switch fitting
            case 'linear_piecewise'
                % Sato et al. fig. 21, piecewise
                pnrfThreshold = 0.022;
                fun_pnrf2ssa_right = @(pnrf) (pnrf + 0.0169)/0.147;
                fun_pnrf2ssa_left = @(pnrf) (pnrf - 0.0027)/0.074;
                ssa = (pnrf<pnrfThreshold).*fun_pnrf2ssa_left(pnrf) + (pnrf>=pnrfThreshold).*fun_pnrf2ssa_right(pnrf); 

            case 'linear'
                % Look-up table. IMG raw (PNRF) fitting vs Hapke global parameters maps
                % [wavelength, scale, shift]
                lut_wl_p = [321e-9, 8.0733271, 0.018441480;
                            415e-9, 7.2432575, 0.043262750;
                            566e-9, 6.5623298, 0.085690878;
                            643e-9, 6.4437275, 0.11101329];
                p = interp1(lut_wl_p(:,1), lut_wl_p(:, 2:end), wl,'linear','extrap');
                ssa = polyval(p, pnrf);
        end

    otherwise
        error('Body not supported. Use "moon".')

end

ssa = max(min(ssa, 1), 0);

end
