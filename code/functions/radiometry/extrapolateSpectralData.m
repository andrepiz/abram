function [data_bolometric, data_ref] = extrapolateSpectralData(spectrum_ref, spectrum_list, data_spectral, data_outsider, method_interpolation, flag_plot)
%INTERPOLATESPECTRUM Given a reference spectrum and spectral data defined 
%at other spectra, returns the interpolated data on the reference spectrum
%and the bolometric integral. 
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
% spectrum_list: array of structs, each like above (length M)
% data_spectral: 1xM vector, measurement for each spectrum of spectrum_list
% data_outsider: data to fill the points outside the interpolating domain
% method_interpolation: 'linear' or 'pchip' suggested
% flag_plot: logical
% Outputs:
% data_bolometric: bolometric integral of data_ref
% data_ref: spectral data interpolated on the reference spectrum

if ~exist('data_outsider','var')
    data_outsider = 'nearest';
end
if ~exist('method_interpolation','var')
    method_interpolation = 'pchip';
end
if ~exist('flag_plot','var')
    flag_plot = false;
end

% Set reference spectrum where to interpolate
if ~isfield(spectrum_ref,'lambda_mid')
    spectrum_ref.lambda_mid = 0.5*spectrum_ref.lambda_min + 0.5*spectrum_ref.lambda_max;
elseif isempty(spectrum_ref.lambda_mid)
    spectrum_ref.lambda_mid = 0.5*spectrum_ref.lambda_min + 0.5*spectrum_ref.lambda_max;
end
% Create finer reference spectrum using midpoint
lambda_ref = linspace(spectrum_ref.lambda_mid(1), spectrum_ref.lambda_mid(end), 100);
values_ref = interp1(spectrum_ref.lambda_mid, spectrum_ref.values, lambda_ref, 'linear');

% Find interpolating interval for each spectrum
for ix = 1:length(spectrum_list)
    if ~isfield(spectrum_list(ix),'lambda_mid')
        spectrum_list(ix).lambda_mid = 0.5*spectrum_list(ix).lambda_min + 0.5*spectrum_list(ix).lambda_max;
    elseif isempty(spectrum_list(ix).lambda_mid)
        spectrum_list(ix).lambda_mid = 0.5*spectrum_list(ix).lambda_min + 0.5*spectrum_list(ix).lambda_max;
    end    
    if ~isfield(spectrum_list(ix),'values')
        spectrum_list(ix).values = ones(1, length(spectrum_list(ix).lambda_mid));
    elseif isempty(spectrum_list(ix).lambda_mid)
        spectrum_list(ix).values = ones(1, length(spectrum_list(ix).lambda_mid));
    end        
    % Find half-width half-maximum waveband for each spectrum
    [hwhm_vec(ix), lambda_eff_vec(ix)] = findHWHM(spectrum_list(ix).lambda_mid, spectrum_list(ix).values);
    % % Integrate each spectrum 
    % Sint(ix) = trapz(spectrum_list(ix).lambda_mid, spectrum_list(ix).values);
    lambda_hwhm(:, ix) = [lambda_eff_vec(ix) - hwhm_vec(ix), lambda_eff_vec(ix) + hwhm_vec(ix)];
    % data_hwhm(:, ix) = [data_spectral(ix), data_spectral(ix)];
end

% lambda_hwhm_full = lambda_hwhm(:)';
% data_hwhm_full = data_hwhm(:)';
lambda_hwhm_full = lambda_eff_vec;
data_hwhm_full = data_spectral;

% Padding
if min(lambda_hwhm_full) > min(lambda_ref)
    if isnumeric(data_outsider)
        data_hwhm_full = [data_outsider, data_hwhm_full];
    elseif strcmp(data_outsider, 'nearest')
        [~, ixs_nearest] = min(abs(lambda_hwhm_full - min(lambda_ref)));
        data_hwhm_full = [data_hwhm_full(ixs_nearest), data_hwhm_full];
    else
        error("Set data_outsider to 'nearest' or directly use the value you want to pad for the interpolation outside the spectrum list limits")
    end
    lambda_hwhm_full = [min(lambda_ref), lambda_hwhm_full];
end
if max(lambda_hwhm_full) < max(lambda_ref)
    if isnumeric(data_outsider)
        data_hwhm_full = [data_hwhm_full, data_outsider];
    elseif strcmp(data_outsider, 'nearest')
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
data_ref = interp1(lambda_hwhm_full, data_hwhm_full, lambda_ref, method_interpolation, 'extrap');

% Bolometric integral
data_bolometric = trapz(lambda_ref, data_ref.*values_ref)./trapz(lambda_ref, values_ref);

if flag_plot
    figure()
    subplot(1,2,1)
    grid on, hold on
    for ix = 1:length(spectrum_list)
        col = wl2rgb(lambda_eff_vec(ix)*1e9, 1);
%        plot(spectrum_list(ix).lambda_mid, spectrum_list(ix).values, 'DisplayName',[num2str(1e9*lambda_eff_vec(ix)),'nm'], 'Color',cols(ix,:));       
        plot(spectrum_list(ix).lambda_mid, spectrum_list(ix).values, 'HandleVisibility','off', 'Color', col);       
%        plot([lambda_hwhm(1, ix); lambda_hwhm(2, ix)], [0.5 0.5]*max(spectrum_list(ix).values), 'DisplayName','FWHM', 'Color',cols(ix,:),'LineWidth',2)
        plot([lambda_hwhm(1, ix); lambda_hwhm(2, ix)], [0.5 0.5]*max(spectrum_list(ix).values), 'HandleVisibility','off', 'Color', col,'LineWidth',1,'LineStyle','--')
        xline(lambda_eff_vec(ix), 'DisplayName',['$\lambda_{eff} = ',num2str(round(1e9*lambda_eff_vec(ix))),'$nm'], 'Color', col,'LineWidth',2,'LineStyle','-')
    end
    legend show
    subplot(1,2,2)
    grid on, hold on
    plot(1e9*lambda_eff_vec, data_spectral, 'o-','LineWidth',2,'DisplayName','Provided Data')
    plot(1e9*lambda_hwhm_full, data_hwhm_full, 'o-','LineWidth',2,'DisplayName','Processed Data')
    plot(1e9*lambda_ref, data_ref, 's-','LineWidth',2,'DisplayName','Interpolated Data')
    legend show
    xlabel('Wavelength [nm]')
    ylabel('Data [-]')
end


end

