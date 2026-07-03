function [integratedDataOut, spectralDataOut] = integrateSpectrum(lambdaIn, spectralDataIn, lambdaOut, responseOut, method_interp, method_extrap, flag_plot)
% integrateSpectrum  Spectrally integrate data weighted by a sensor response.
%
%   Interpolates spectralDataIn onto a reference wavelength grid lambdaOut,
%   then computes the response-weighted integral (e.g. to simulate a
%   broadband sensor, a photometric band, or a colour channel):
%
%             integratedDataOut = trapz(lambdaOut, spectralDataOut .* responseOut)
%                                 ─────────────────────────────────────────────────
%                                        trapz(lambdaOut, responseOu
%
%   Out-of-range wavelengths are handled by padSpectrum before interpolation,
%   so no silent extrapolation occurs.
%
%   INPUTS
%     lambdaIn        [nc x 1] or [1 x nc]   Input wavelength vector (any order, any unit)
%     spectralDataIn  [nc x Np], [Np x nc],   Spectral data to integrate.
%                     [1 x Np x nc], or        Nwl dimension is matched automatically
%                     [1 x nc x Np]            to lambdaIn (nc wavelengths, Np points).
%     lambdaOut       [nout x 1] or [1 x nout] Reference wavelength grid for the
%                                              sensor response (defines integration domain)
%     responseOut     [nout x 1] or [1 x nout] Spectral response / weighting function
%                                              (e.g. QE curve, colour-matching function).
%                                              Must be positive and non-zero over lambdaOut.
%     method_interp   char   Interpolation method passed to interp1
%                            (e.g. 'linear', 'pchip', 'spline')
%     method_extrap   char or numeric   Out-of-range padding strategy passed to padSpectrum:
%                                         'nearest' – replicate the nearest boundary sample
%                                         <scalar>  – constant pad value (e.g. 0, NaN)
%     flag_plot       logical   If true, plot the input spectrum, interpolated spectrum,
%                               sensor response, and integrated value for the first point
%
%   OUTPUTS
%     integratedDataOut  [1 x Np]    Response-weighted integral for each spatial point.
%                                    If nout == 1, equals spectralDataOut directly
%                                    (trapezoidal rule undefined for a single point).
%     spectralDataOut    [nout x Np] spectralDataIn interpolated onto lambdaOut
%
%   DEPENDENCIES
%     padSpectrum   – pads and sorts spectralDataIn to cover lambdaOut range
%
%   EXAMPLE
%     lambda   = 400:50:700;
%     spectra  = rand(numel(lambda), 500);   % 500 spatial points
%     lambdaR  = 400:1:700;
%     response = gausswin(numel(lambdaR));
%     [img, sp] = integrateSpectrum(lambda, spectra, lambdaR, response, ...
%                                   'pchip', 'nearest', false);
 
nin  = numel(lambdaIn);
nout = numel(lambdaOut);

if ndims(spectralDataIn) == 3
    sz = size(spectralDataIn);
    if sz(1) == 1 && sz(3) == nin          % [1 x N x nc]
        spectralDataIn = permute(spectralDataIn, [3 2 1]);
    elseif sz(1) == 1 && sz(2) == nin      % [1 x nc x N]
        spectralDataIn = permute(spectralDataIn, [2 3 1]);
    else
        spectralDataIn = reshape(spectralDataIn, sz(1), []);
    end
end
if size(spectralDataIn, 1) ~= nin
    if size(spectralDataIn, 2) == nin
        spectralDataIn = spectralDataIn.';
    else
        error('integrateSpectrum:dimensionMismatch', ...
              'Cannot match spectral dimension (nc=%d) to spectralDataIn of size [%s].', ...
              nin, num2str(size(spectralDataIn)));
    end
end

% Sorting of lambda out
flag_sorting = ~issorted(lambdaOut);
if flag_sorting
    [lambdaOut, ixs_sort] = sort(lambdaOut(:));
    responseOut = responseOut(ixs_sort);
end

np = size(spectralDataIn, 2);
spectralDataOut = nan(nout, np);
ixsNotNan = all(~isnan(spectralDataIn));    

% Padding and sorting of data in
[lambdaIn_padded, spectralDataIn_padded] = padSpectrum(lambdaIn(:), double(spectralDataIn(:, ixsNotNan)), lambdaOut(1), lambdaOut(end), method_extrap);

% Interpolate each spectral value on the new reference spectrum 
spectralDataOut_temp = interp1(lambdaIn_padded, spectralDataIn_padded, lambdaOut(:), method_interp, 'extrap'); % [nout x np]

spectralDataOut(:, ixsNotNan) = spectralDataOut_temp;

% Weighted Integral
if nout == 1
    % Trapezoidal rule is undefined for a single point
    integratedDataOut = spectralDataOut;   % [1 x np]
else
    % Precompute trapezoidal weights (1 x nout) — fixed for given lambdaOut
    dl = diff(lambdaOut(:)).';
    trapWeights = [dl(1), dl(1:end-1)+dl(2:end), dl(end)] / 2;  % [1 x nout]
    denom = trapWeights * responseOut(:); 
    assert(denom > 0, 'integrateSpectrum:zeroDenominator', ...
        'Response integral is zero: check responseOut and lambdaOut inputs.');
    % Absorb response and normalisation into weight vector, then single multiply
    w = (trapWeights .* responseOut(:).') / denom;    % [1 x nout]
    integratedDataOut = w * spectralDataOut;           % [1 x np]
end

if nargout > 1 && flag_sorting
    spectralDataOut = spectralDataOut(ixs_sort, :); 
end

if flag_plot    
    nvis = 1;
    if numel(integratedDataOut) < nvis
        nvis = numel(integratedDataOut);
    end
    figure()
    grid on, hold on
    plot(lambdaIn, spectralDataIn(:, 1:nvis), '*','MarkerSize',20,'LineWidth',2)
    plot(lambdaIn_padded, spectralDataIn_padded(:, 1:nvis), 'ko-','LineWidth',2)
    plot(lambdaOut, responseOut, 'cs-','LineWidth',2)
    yline(integratedDataOut(1:nvis),'g-','LineWidth',3)
    legend('Spectral','Interpolated','Sensor Response','Bolometric')
end

end