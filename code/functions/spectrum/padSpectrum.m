function [lambdaSpectral, dataSpectral] = padSpectrum(lambdaSpectral, dataSpectral, lambdaMin, lambdaMax, method_extrap)
% padSpectrum  Extend a spectrum to cover a reference wavelength range.
%
%   Pads lambdaSpectral and dataSpectral with boundary sentinel values so
%   that the spectral axis spans at least [min(lambdaRef), max(lambdaRef)].
%   This ensures that subsequent interpolation onto lambdaRef does not
%   require extrapolation beyond the available data.
%
%   The function sorts the spectrum in ascending wavelength order before
%   padding. The output is therefore always sorted ascending, regardless
%   of the input ordering.
%
%   INPUTS
%     lambdaSpectral  [Nwl x 1] or [1 x Nwl]  Wavelength vector (any order, any unit)
%     dataSpectral    [Nwl x Np]                Spectral data; each row corresponds
%                                               to one wavelength, each column to
%                                               one spatial point / spectrum
%     lambdaMin       [1]                     Minimum wavelength
%     lambdaMax       [1]                     Maximum wavelength
%     method_extrap   char or numeric           Extrapolation strategy:
%                                                 'nearest' – replicate the closest
%                                                             boundary sample
%                                                 <scalar>  – pad with this constant
%                                                             value (e.g. 0, NaN)
%
%   OUTPUTS
%     lambdaSpectral  [Nwl+k x 1]  Sorted, padded wavelength vector (k = 0, 1, or 2)
%     dataSpectral    [Nwl+k x Np] Corresponding padded spectral data
%
%   NOTES
%     - If lambdaSpectral already covers [min(lambdaRef), max(lambdaRef)],
%       the inputs are returned unchanged (no sorting is applied).
%     - dataSpectral must have exactly Nwl rows; an error is raised otherwise.
%
%   EXAMPLE
%     lambda  = [500 450 550 600];          % unsorted
%     data    = rand(4, 100);
%     lambdaMin = 400
%     lambdaMax = 700;
%     [lPad, dPad] = padSpectrum(lambda, data, lambdaMin, lambdaMax, 'nearest');
%     % lPad = [400, 450, 500, 550, 600, 700]  (sorted, 2 sentinels added)

lambdaSpectralMin = min(lambdaSpectral);
lambdaSpectralMax = max(lambdaSpectral);

if lambdaSpectralMin <= lambdaMin && lambdaSpectralMax >= lambdaMax
    % No need of padding
    return
end

if size(dataSpectral, 1) ~= numel(lambdaSpectral)
    error('Spectral data should be of size Nwl x Np where Nwl is the number of wavelength and Np is the number of points')
end

if ~issorted(lambdaSpectral)
    % Sort ascending
    [lambdaSpectral, ixs_sort] = sort(lambdaSpectral);
    dataSpectral = dataSpectral(ixs_sort, :);
end

% Pad lower boundary
if lambdaSpectral(1) > lambdaMin
    if isnumeric(method_extrap)
        paddingVal = method_extrap;
    elseif strcmp(method_extrap, 'nearest')
        paddingVal = dataSpectral(1, :);
    elseif strcmp(method_extrap, 'linear')
        paddingVal = interp1(lambdaSpectral, dataSpectral, lambdaMin, 'linear','extrap');
    else
        error("dataOutspectrum must be 'nearest','linear' or a numeric pad value.");
    end
    lambdaSpectral = cat(1, lambdaMin, lambdaSpectral);
    dataSpectral   = cat(1, paddingVal, dataSpectral);
end

% Pad upper boundary
if lambdaSpectral(end) < lambdaMax
    if isnumeric(method_extrap)
        paddingVal = method_extrap;
    elseif strcmp(method_extrap, 'nearest')
        paddingVal = dataSpectral(end, :);
    elseif strcmp(method_extrap, 'linear')
        paddingVal = interp1(lambdaSpectral, dataSpectral, lambdaMax, 'linear','extrap');
    else
        error("dataOutspectrum must be 'nearest','linear' or a numeric pad value.");
    end
    lambdaSpectral = cat(1, lambdaSpectral, lambdaMax);
    dataSpectral   = cat(1, dataSpectral, paddingVal);
end

end