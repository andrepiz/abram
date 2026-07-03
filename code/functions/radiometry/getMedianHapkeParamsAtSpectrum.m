function [hapkeParams, hapkeParamsSpectral] = getMedianHapkeParamsAtSpectrum(sp_or_wl, body, method_interp, method_extrap, flag_plot)
% getMedianHapkeParamsForSpectrum Interpolation of spatial-median Hapke 
% parameters across a wavelength vector or a camera spectrum.
% Hapke parameters returned: 
% [w, b_HG, c_HG, B0_CBOE, h_CBOE, B0_SHOE, h_SHOE, roughness, filling_factor]

if ~exist('body','var')
    warning('Used Moon as body')
    body = 'moon';
end
if ~exist('method_interp','var')
    method_interp = 'linear';
end
if ~exist('method_extrap','var')
    method_extrap = 'linear';
end
if ~exist('flag_plot','var')
    flag_plot = false;
end

if isa(sp_or_wl, 'abram.spectrum')
    lambdaOut = sp_or_wl.lambda_mid;
    responseOut = sp_or_wl.values;
elseif isstruct(sp_or_wl)
    if isfield(sp_or_wl, 'lambda_mid')
        lambdaOut = sp_or_wl.lambda_mid;
    elseif isfield(sp_or_wl, 'lambda_min') || isfield(sp_or_wl, 'lambda_max') 
        lambdaOut = 0.5*sp_or_wl.lambda_min + 0.5*sp_or_wl.lambda_max;
    else
        error('Missing lambda_mid or lambda_min/lambda_max in the input spectrum')
    end
    if isfield(sp_or_wl, 'values')
        responseOut = sp_or_wl.values;
    else
        error('Missing values in the input spectrum')
    end
elseif isnumeric(sp_or_wl)
    lambdaOut = sp_or_wl;
    responseOut = ones(1, length(sp_or_wl));
else
    error('Input must be a spectrum or a vector of wavelengths')
end

switch lower(body)
    case 'moon'
        % Resolved Hapke parameter maps of the Moon, Sato et al
        %Wavelength (nm),w,b,c,BS0​,hs
        spectralDataIn =   [0.159465581178665	0.237018197774887	0.329875886440277	0	1	2.45512771606445	0.0753467828035355	0.412885576445416	0
                            0.193308860063553	0.240820497274399	0.291353940963745	0	1	2.33942294120789	0.0704958438873291	0.412885576445416	0
                            0.229066357016563	0.243178546428680	0.267771482467651	0	1	2.07578420639038	0.0739350020885468	0.412885576445416	0
                            0.329407334327698	0.239332675933838	0.306355416774750	0	1	1.75480866432190	0.0719224363565445	0.412885576445416	0
                            0.358184188604355	0.237414643168449	0.325831174850464	0	1	1.73390841484070	0.0686235278844833	0.412885576445416	0
                            0.385419130325317	0.237467601895332	0.325291424989700	0	1	1.70597875118256	0.0671533048152924	0.412885576445416	0
                            0.415064156055450	0.240228787064552	0.297308802604675	0	1	1.64718866348267	0.0695649385452271	0.412885576445416	0];
        lambdaIn = [3.21e-07	3.60e-07	4.15e-07	5.66e-07	6.04e-07	6.43e-07	6.89e-07];
        [hapkeParams, hapkeParamsSpectral] = integrateSpectrum(lambdaIn, spectralDataIn, lambdaOut, responseOut, ...
                                        method_interp, method_extrap, flag_plot);
    otherwise
        error(fprintf('Median Hapke parameters not available for %d. Available bodies: moon', body))
end

end