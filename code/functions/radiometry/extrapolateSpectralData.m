function [data_ref, data_spectral_ref] = extrapolateSpectralData(spectrum_ref, spectrum_interp, data_spectral_interp, data_outspectrum, method_interpolation, flag_plot)
%EXTRAPOLATESPECTRALDATA Given a reference spectrum and spectral data defined 
%at different spectra, returns the interpolated data on the reference spectrum
%and the integrated data. 
%The spectral data is considered constant in the interval centered in the
%effective wavelength for each spectrum with a width given by the
%half-width half-maximum.
%The interpolation is linear in the missing spectral regions, set to constant equal to nearest
%point or to zero depending on user's choice outside the boundaries of the spectrum list
%
% Inputs:
% spectrum_ref: struct with fields
%   lambda_min: 1xN vector
%   lambda_max: 1xN vector
%   values: 1xN vector (responsivity for each bin [lambda_min, lambda_max])
% spectrum_interp: array of structs, each like above (length M)
% data_spectral_interp: 1xM vector, measurement for each spectrum of spectrum_list
% data_outspectrum: data to fill the points outside the given spectra
% method_interpolation: 'linear' or 'pchip' (suggested)
% flag_plot: logical
% Outputs:
% data_ref: integral of data_spectral_ref
% data_spectral_ref: spectral data interpolated on the reference spectrum

if ~exist('data_outsider','var')
    data_outspectrum = 'nearest';
end
if ~exist('method_interpolation','var')
    method_interpolation = 'pchip';
end
if ~exist('flag_plot','var')
    flag_plot = false;
end

% Check if spectra are sorted
if ~issorted([spectrum_interp(:).lambda_min])
    error('Provide spectra sorted with ascending order of their lowest wavelength')
end

% Set reference spectrum where to interpolate
if ~isfield(spectrum_ref,'lambda_mid')
    spectrum_ref.lambda_mid = 0.5*spectrum_ref.lambda_min + 0.5*spectrum_ref.lambda_max;
elseif isempty(spectrum_ref.lambda_mid)
    spectrum_ref.lambda_mid = 0.5*spectrum_ref.lambda_min + 0.5*spectrum_ref.lambda_max;
end
% Create finer reference spectrum using midpoint
if length(spectrum_ref.values) == 1
    lambda_ref = linspace(spectrum_ref.lambda_min(1), spectrum_ref.lambda_max(end), 100);
    values_ref = spectrum_ref.values.*ones(1, 100);
else
    lambda_ref = linspace(spectrum_ref.lambda_mid(1), spectrum_ref.lambda_mid(end), 100);
    values_ref = interp1(spectrum_ref.lambda_mid, spectrum_ref.values, lambda_ref, 'linear');
end

% Find interpolating interval for each spectrum
for ix = 1:length(spectrum_interp)
    if ~isfield(spectrum_interp(ix),'lambda_mid')
        spectrum_interp(ix).lambda_mid = 0.5*spectrum_interp(ix).lambda_min + 0.5*spectrum_interp(ix).lambda_max;
    elseif isempty(spectrum_interp(ix).lambda_mid)
        spectrum_interp(ix).lambda_mid = 0.5*spectrum_interp(ix).lambda_min + 0.5*spectrum_interp(ix).lambda_max;
    end    
    if ~isfield(spectrum_interp(ix),'values')
        spectrum_interp(ix).values = ones(1, length(spectrum_interp(ix).lambda_mid));
    elseif isempty(spectrum_interp(ix).lambda_mid)
        spectrum_interp(ix).values = ones(1, length(spectrum_interp(ix).lambda_mid));
    end        
    if length(spectrum_interp(ix).values) == 1
        lambda_eff_vec(ix) = spectrum_interp(ix).lambda_mid;
        lambda_hwhm(1, ix) = spectrum_interp(ix).lambda_min;
        lambda_hwhm(2, ix) = spectrum_interp(ix).lambda_max;
    else
        % Find half-width half-maximum waveband for each spectrum
        [hwhm_vec(ix), lambda_eff_vec(ix)] = findHWHM(spectrum_interp(ix).lambda_mid, spectrum_interp(ix).values);
        % % Integrate each spectrum 
        % Sint(ix) = trapz(spectrum_list(ix).lambda_mid, spectrum_list(ix).values);
        lambda_hwhm(:, ix) = [lambda_eff_vec(ix) - hwhm_vec(ix), lambda_eff_vec(ix) + hwhm_vec(ix)];
        % data_hwhm(:, ix) = [data_spectral(ix), data_spectral(ix)];
    end
end

% lambda_hwhm_full = lambda_hwhm(:)';
% data_hwhm_full = data_hwhm(:)';
lambda_hwhm_full = lambda_eff_vec;
data_hwhm_full = data_spectral_interp;

% Padding
if min(lambda_hwhm_full) > min(lambda_ref)
    if isnumeric(data_outspectrum)
        data_hwhm_full = [data_outspectrum, data_hwhm_full];
    elseif strcmp(data_outspectrum, 'nearest')
        [~, ixs_nearest] = min(abs(lambda_hwhm_full - min(lambda_ref)));
        data_hwhm_full = [data_hwhm_full(ixs_nearest), data_hwhm_full];
    else
        error("Set data_outsider to 'nearest' or directly use the value you want to pad for the interpolation outside the spectrum list limits")
    end
    lambda_hwhm_full = [min(lambda_ref), lambda_hwhm_full];
end
if max(lambda_hwhm_full) < max(lambda_ref)
    if isnumeric(data_outspectrum)
        data_hwhm_full = [data_hwhm_full, data_outspectrum];
    elseif strcmp(data_outspectrum, 'nearest')
        [~, ixs_nearest] = min(abs(lambda_hwhm_full - max(lambda_ref)));
        data_hwhm_full = [data_hwhm_full, data_hwhm_full(ixs_nearest)];
    else
        error("Set data_outsider to 'nearest' or directly use the value you want to pad for the interpolation outside the spectrum list limits")
    end
    lambda_hwhm_full = [lambda_hwhm_full, max(lambda_ref)];
end

% Interpolate each spectral value scaled by that spectrum integral on the
% new reference spectrum and multiply it for the reference value

% Interpolation
data_spectral_ref = interp1(lambda_hwhm_full, data_hwhm_full, lambda_ref, method_interpolation, 'extrap');

% Weighted Integral
data_ref = trapz(lambda_ref, data_spectral_ref.*values_ref)./trapz(lambda_ref, values_ref);

if flag_plot
    figure()
    subplot(1,2,1)
    grid on, hold on
    for ix = 1:length(spectrum_interp)
        col = wl2rgb(lambda_eff_vec(ix)*1e9, 1);
%        plot(spectrum_list(ix).lambda_mid, spectrum_list(ix).values, 'DisplayName',[num2str(1e9*lambda_eff_vec(ix)),'nm'], 'Color',cols(ix,:));       
        plot(spectrum_interp(ix).lambda_mid, spectrum_interp(ix).values, 'HandleVisibility','off', 'Color', col);       
%        plot([lambda_hwhm(1, ix); lambda_hwhm(2, ix)], [0.5 0.5]*max(spectrum_list(ix).values), 'DisplayName','FWHM', 'Color',cols(ix,:),'LineWidth',2)
        plot([lambda_hwhm(1, ix); lambda_hwhm(2, ix)], [0.5 0.5]*max(spectrum_interp(ix).values), 'HandleVisibility','off', 'Color', col,'LineWidth',1,'LineStyle','--')
        xline(lambda_eff_vec(ix), 'DisplayName',['$\lambda_{eff} = ',num2str(round(1e9*lambda_eff_vec(ix))),'$nm'], 'Color', col,'LineWidth',2,'LineStyle','-')
    end
    legend show
    subplot(1,2,2)
    grid on, hold on
    plot(1e9*lambda_eff_vec, data_spectral_interp, 'o-','LineWidth',2,'DisplayName','Provided Data')
    plot(1e9*lambda_hwhm_full, data_hwhm_full, 'o-','LineWidth',2,'DisplayName','Processed Data')
    plot(1e9*lambda_ref, data_spectral_ref, 's-','LineWidth',2,'DisplayName','Interpolated Data')
    plot(1e9*[lambda_ref(1) lambda_ref(end)], data_ref*[1 1], 'k','LineWidth',2,'DisplayName','Integrated Data')
    legend show
    xlabel('Wavelength [nm]')
    ylabel('Data [-]')
end


end

