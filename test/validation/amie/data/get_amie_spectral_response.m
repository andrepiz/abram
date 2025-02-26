function T = get_amie_spectral_response(lambda_min, lambda_max, sampling, flag_plot)

data = readtable('amie_spectral_response.xlsx');

lambda = 1e-9*data(:,1).Variables;
resp_none = data(:,2).Variables*1e-3;

switch sampling
    case 'midpoint'

        % simply evaluate new value at midpoint of waveband
        lambda_mid = (lambda_min + lambda_max)/2;
        T = interp1(lambda, resp_none, lambda_mid);
        if flag_plot
            figure()
            grid on, hold on
            plot(1e9*lambda, 1e2*resp_none,'--')
            stairs(1e9*lambda_min, 1e2*T,'-o')
            xlabel('$\lambda$ [nm]')
            ylabel('T [\%]')
            legend('Measurement','Fit')
        end

    case 'piecewise'
        % use mid trapezoidal value
        T = 0.5*interp1(lambda, resp_none, lambda_min, "linear", resp_none(1)) + 0.5*interp1(lambda, resp_none, lambda_max, "linear", resp_none(end));
        if flag_plot
            figure()
            grid on, hold on
            plot(1e9*lambda, 1e2*resp_none,'--')
            stairs(1e9*lambda_min, 1e2*T,'-o')
            xlabel('$\lambda$ [nm]')
            ylabel('T [\%]')
            legend('Measurement','Fit')
        end

end