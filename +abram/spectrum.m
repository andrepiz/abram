classdef spectrum
    %SPECTRUM Spectral quantity. Container for the definition of values and
    %bands of a spectral-dependant quantity

    properties
        lambda_min
        lambda_max
        values
        sampling
    end

    properties (Dependent)
        lambda_mid
    end

    methods
        function obj = spectrum(in)
            %SPECTRUM Construct an instance of this class
        
            hasMin = isfield(in,'lambda_min');
            hasMid = isfield(in,'lambda_mid');
            hasMax = isfield(in,'lambda_max');

            if (hasMin && ~hasMax) || (hasMax && ~hasMin)
                error('abram:io', 'Specify both lambda_min and lambda_max, or specify lambda_mid only.');
            end

            if (hasMid && (hasMin || hasMax))
                error('abram:io', 'Specify either lambda_mid or lambda_min/lambda_max, not both.');
            end
            
            if hasMid
                lambda_mid = extract_struct(in, 'lambda_mid', 635e-9, true); 
                if ~isvector(lambda_mid) || isempty(lambda_mid)
                    error('abram:io','lambda_mid must be a non-empty vector.');
                end
                lambda_mid = lambda_mid(:).';  % force row vector       
                if numel(lambda_mid) == 1
                    % Assuming a narrow-band filter of 50 nm
                    lambda_min = lambda_mid - 25e-9;
                    lambda_max = lambda_mid + 25e-9;
                else
                    edges = zeros(1, numel(lambda_mid) + 1);
                    edges(2:end-1) = 0.5 * (lambda_mid(1:end-1) + lambda_mid(2:end)); % Internal edges: halfway between adjacent lambda_mid values
                    % Extrapolate first/last edges using half-band spacing
                    edges(1)   = lambda_mid(1)   - 0.5 * (lambda_mid(2)   - lambda_mid(1));
                    edges(end) = lambda_mid(end) + 0.5 * (lambda_mid(end) - lambda_mid(end-1));
                    lambda_min = edges(1:end-1);
                    lambda_max = edges(2:end);
                end
                obj.lambda_min = lambda_min;
                obj.lambda_max = lambda_max;            
                obj.sampling = extract_struct(in, 'sampling', 'midpoint');
            else
                obj.lambda_min = extract_struct(in, 'lambda_min', 450E-9, true);
                obj.lambda_max = extract_struct(in, 'lambda_max', 820E-9, true);
                obj.sampling = extract_struct(in, 'sampling', 'piecewise');
            end
        
            obj.values = extract_struct(in, 'values', ones(1, length(obj.lambda_min)), true);
        
            if ~isequal(size(obj.lambda_min), size(obj.lambda_max), size(obj.values))
                error('abram:io', ...
                    'The size of lambda_min, lambda_max and values vectors of the spectrum must be the same.')
            end
        end

        function spectrum_merged = merge(spectrum_vec)
            %MERGE Merge spectrums defined at different wavelengths
            %into a new spectrum defined at the basis of the first one

            % Init 
            spectrum_merged = spectrum_vec(1);

            if length(spectrum_vec(1).lambda_mid) == length(spectrum_vec(2).lambda_mid)
                if all(spectrum_vec(1).lambda_mid == spectrum_vec(2).lambda_mid) && strcmp(spectrum_vec(1).sampling, spectrum_vec(2).sampling)
                    % Multiply spectrum
                    spectrum_merged.values = spectrum_vec(1).values.*spectrum_vec(2).values;
                    return
                end
            end

            % Merge spectrum
            warning('The provided spectra will be merged as they are defined at different wavelengths and/or they have different sampling methods.')
            [sp_temp, sampling_temp] = mergeSpectrum([spectrum_vec(1).lambda_min; spectrum_vec(1).lambda_max; spectrum_vec(1).values], spectrum_vec(1).sampling,...
                                            [spectrum_vec(2).lambda_min; spectrum_vec(2).lambda_max; spectrum_vec(2).values], spectrum_vec(2).sampling);
            spectrum_merged.lambda_min = sp_temp(1,:);
            spectrum_merged.lambda_max = sp_temp(2,:);
            spectrum_merged.values = sp_temp(3,:);
            spectrum_merged.sampling = sampling_temp;          

        end        

        %% GET METHODS %%
        function res = get.lambda_mid(obj)
            res = 0.5*obj.lambda_min + 0.5*obj.lambda_max;
        end
    end
end