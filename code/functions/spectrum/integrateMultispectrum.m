function [integratedDataOut, spectralDataOut] = ...
            integrateMultispectrum(spectrumIn, spectralDataIn, spectrumOut,...
            method_interp, method_extrap, flag_resampling, flag_plot)
% integrateMultispectrum  Interpolate and integrate spectral data across a
%                         multispectral input/output channel description.
%
%   Each input and output channel is described by a spectral band struct
%   (with lambda_min, lambda_max, and optionally lambda_mid and values).
%   The function collapses each input band to an effective wavelength
%   (centroid of its HWHM), interpolates the provided per-band measurements
%   onto the output spectrum, and returns the response-weighted integral.
%
%   The spectral data is treated as constant within the interval centred on
%   the effective wavelength of each band, with a half-width defined by the
%   band's half-width at half-maximum (HWHM). Interpolation onto the output
%   grid is performed with method_interp; out-of-range values are handled
%   by method_extrap (see padSpectrum).
%
%   INPUTS
%     spectrumIn      [1 x N] struct array  Input spectral bands. Each element
%                                           must have fields:
%                                             lambda_min   scalar (m or nm, consistent)
%                                             lambda_max   scalar
%                                           Optional fields (computed if absent/empty):
%                                             lambda_mid   midpoint wavelength vector
%                                             values       band response/weight vector;
%                                                          defaults to all-ones if absent
%     spectralDataIn  [1 x N] or [N x Np]  Measured value for each input band
%                                           (N bands, Np spatial points)
%     spectrumOut     scalar struct         Output spectral band / sensor channel.
%                                           Same fields as spectrumIn elements.
%                                           If values has length > 1, it is used
%                                           as the response weighting function.
%     method_interp   char  (default: 'pchip')
%                           Interpolation method passed to interp1 and integrateSpectrum
%                           (e.g. 'linear', 'pchip', 'spline')
%     method_extrap   char or numeric  (default: 'nearest')
%                           Out-of-range padding strategy passed to padSpectrum:
%                             'nearest' – replicate the nearest boundary sample
%                             <scalar>  – constant pad value (e.g. 0, NaN)
%     flag_resampling logical  (default: true)
%                           If true, resample the output spectrum onto a finer
%                           uniform grid (nResample = 100 points) before integration,
%                           improving trapezoidal accuracy for coarsely sampled responses
%     flag_plot       logical  (default: false)
%                           If true, produce two diagnostic figures:
%                             Fig 1 – input band shapes, FWHM extents, and effective λ
%                             Fig 2 – input data, interpolated data, and integrated value
%
%   OUTPUTS
%     integratedDataOut  [1 x Np]     Response-weighted integral of spectralDataIn
%                                     over the output spectrum (one value per point)
%     spectralDataOut    [nout x Np]  spectralDataIn interpolated onto lambdaOut_resampled
%
%   DEPENDENCIES
%     integrateSpectrum  – interpolation and trapezoidal integration
%     padSpectrum        – boundary padding before interpolation
%     findHWHM           – half-width at half-maximum and effective wavelength
%     wl2rgb             – wavelength-to-RGB colour map (used in plots only)
%
%   NOTES
%     - All wavelength inputs must use consistent units (m or nm throughout).
%
%   EXAMPLE
%     % Build two input bands at 450 nm and 650 nm (values in metres)
%     sIn(1).lambda_min = 430e-9; sIn(1).lambda_max = 470e-9;
%     sIn(2).lambda_min = 630e-9; sIn(2).lambda_max = 670e-9;
%     sOut.lambda_min   = 400e-9; sOut.lambda_max   = 700e-9;
%     sOut.values       = 1;
%     [intData, spData] = integrateMultispectrum(sIn, [0.3 0.8], sOut, ...
%                                                'pchip', 'nearest', true, false);

if ~exist('method_interp','var')
    method_interp = 'pchip';
end
if ~exist('method_extrap','var')
    method_extrap = 'nearest';
end
if ~exist('flag_resampling','var')
    flag_resampling = true;
end
if ~exist('flag_plot','var')
    flag_plot = false;
end

%--- INPUT SPECTRUM
% Find interpolating interval for each spectrum
for ix = 1:length(spectrumIn)
    if ~(isfield(spectrumIn(ix),'lambda_mid') || isprop(spectrumIn(ix),'lambda_mid'))
        spectrumIn(ix).lambda_mid = 0.5*spectrumIn(ix).lambda_min + 0.5*spectrumIn(ix).lambda_max;
    elseif isempty(spectrumIn(ix).lambda_mid)
        spectrumIn(ix).lambda_mid = 0.5*spectrumIn(ix).lambda_min + 0.5*spectrumIn(ix).lambda_max;
    end    
    if ~(isfield(spectrumIn(ix),'values') || isprop(spectrumIn(ix),'values'))
        spectrumIn(ix).values = ones(1, length(spectrumIn(ix).lambda_mid));
    elseif isempty(spectrumIn(ix).lambda_mid)
        spectrumIn(ix).values = ones(1, length(spectrumIn(ix).lambda_mid));
    end        
    if length(spectrumIn(ix).values) == 1
        lambdaIn_eff(ix) = spectrumIn(ix).lambda_mid;
        lambdaIn_HWHM(1, ix) = spectrumIn(ix).lambda_min;
        lambdaIn_HWHM(2, ix) = spectrumIn(ix).lambda_max;
    else
        % Find half-width half-maximum waveband for each spectrum
        [HWHMIn(ix), lambdaIn_eff(ix)] = findHWHM(spectrumIn(ix).lambda_mid, spectrumIn(ix).values);
        % Integrate each spectrum 
        lambdaIn_HWHM(:, ix) = [lambdaIn_eff(ix) - HWHMIn(ix), lambdaIn_eff(ix) + HWHMIn(ix)];
    end
end

%--- OUTPUT SPECTRUM
% Set midpoint interpolation points for output spectrum
if ~(isfield(spectrumOut,'lambda_mid') || isprop(spectrumOut,'lambda_mid'))
    spectrumOut.lambda_mid = 0.5*spectrumOut.lambda_min + 0.5*spectrumOut.lambda_max;
elseif isempty(spectrumOut.lambda_mid)
    spectrumOut.lambda_mid = 0.5*spectrumOut.lambda_min + 0.5*spectrumOut.lambda_max;
end
if flag_resampling
    % Create finer output spectrum midpoint interpolation vector
    nResample = 100;
    if length(spectrumOut.values) == 1
        lambdaOut_resampled = linspace(spectrumOut.lambda_min(1), spectrumOut.lambda_max(end), nResample);
        valuesOut_resampled = spectrumOut.values.*ones(1, nResample);
    else
        lambdaOut_resampled = linspace(spectrumOut.lambda_mid(1), spectrumOut.lambda_mid(end), nResample);
        valuesOut_resampled = interp1(spectrumOut.lambda_mid, spectrumOut.values, lambdaOut_resampled, 'linear');
    end
else
    % Use original output spectrum midpoint
    lambdaOut_resampled = spectrumOut.lambda_mid;
    valuesOut_resampled = spectrumOut.values;
end

%--- INTERPOLATION & INTEGRATION
[integratedDataOut, spectralDataOut] = integrateSpectrum(lambdaIn_eff, spectralDataIn, lambdaOut_resampled, valuesOut_resampled, method_interp, method_extrap, flag_plot);

if flag_plot
    figure()
    subplot(1,2,1)
    grid on, hold on
    for ix = 1:length(spectrumIn)
        col = wl2rgb(lambdaIn_eff(ix)*1e9, 1);
        %plot(spectrumIn(ix).lambda_mid, spectrumIn(ix).values, 'DisplayName',[num2str(1e9*lambdaIn_eff(ix)),'nm'], 'Color',col);       
        plot(spectrumIn(ix).lambda_mid, spectrumIn(ix).values, 'HandleVisibility','off', 'Color', col);       
        plot([lambdaIn_HWHM(1, ix); lambdaIn_HWHM(2, ix)], [0.5 0.5]*max(spectrumIn(ix).values), 'DisplayName','FWHM', 'Color',col,'LineWidth',2)
        %plot([lambdaIn_HWHM(1, ix); lambdaIn_HWHM(2, ix)], [0.5 0.5]*max(spectrumIn(ix).values), 'HandleVisibility','off', 'Color', col,'LineWidth',1,'LineStyle','--')
        xline(lambdaIn_eff(ix), 'DisplayName',['$\lambda_{eff} = ',num2str(round(1e9*lambdaIn_eff(ix))),'$nm'], 'Color', col,'LineWidth',2,'LineStyle','-')
    end
    legend show
    subplot(1,2,2)
    grid on, hold on
    plot(1e9*lambdaIn_eff, spectralDataIn, 'o-','LineWidth',2,'DisplayName','Provided Data')
    plot(1e9*lambdaOut_resampled, spectralDataOut, 's-','LineWidth',2,'DisplayName','Interpolated Data')
    plot(1e9*[lambdaOut_resampled(1) lambdaOut_resampled(end)], integratedDataOut*[1 1], 'k','LineWidth',2,'DisplayName','Integrated Data')
    legend show
    xlabel('Wavelength [nm]')
    ylabel('Data [-]')
end

end

