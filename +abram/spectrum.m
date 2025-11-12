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
            
            obj.lambda_min = extract_struct(in, 'lambda_min', 450E-9, true);
            obj.lambda_max = extract_struct(in, 'lambda_max', 820E-9, true);
            obj.values = extract_struct(in, 'values', ones(1, length(obj.lambda_min)), true);
            obj.sampling = extract_struct(in, 'sampling', 'piecewise');
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
            warning('The provided spectra will be merged as they are defined at different wavelengths and/or they have different sampling methods')
            [sp_temp, sampling_temp] = merge_spectra([spectrum_vec(1).lambda_min; spectrum_vec(1).lambda_max; spectrum_vec(1).values], spectrum_vec(1).sampling,...
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