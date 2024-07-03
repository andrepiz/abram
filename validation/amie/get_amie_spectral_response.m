function T = get_amie_spectral_response(lambda_min, lambda_max)

data = readtable('amie_spectral_response.xlsx');

lambda = 1e-9*data(:,1).Variables;
resp_none = data(:,2).Variables*1e-3;

lambda_mid = (lambda_min + lambda_max)/2;
T = interp1(lambda, resp_none, lambda_mid);

figure()
grid on, hold on
plot(1e9*lambda, 1e2*resp_none,'--')
plot(1e9*lambda_mid, 1e2*T,'-o')
xlabel('\lambda [nm]')
ylabel('QE [%]')

end