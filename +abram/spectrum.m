classdef spectrum
    %SPECTRUM Spectral quantity
    %   Container for the definition of values and bands of a
    %   spectral-dependant quantity

    properties
        min
        max
        values
        sampling
    end

    properties (Dependent)
        mid
    end

    methods
        function obj = spectrum(in)
            %SPECTRUM Construct an instance of this class
            
            obj.min = extract_struct(in, 'lambda_min', 450E-9, true);
            obj.max = extract_struct(in, 'lambda_max', 820E-9, true);
            obj.values = extract_struct(in, 'values', ones(1, length(obj.min)), true);
            obj.sampling = extract_struct(in, 'sampling', 'piecewise');
        end

        function spectrum_merged = merge(spectrum_vec)
            %MERGE Merge spectrums defined at different wavelengths
            %into a new spectrum defined at the basis of the first one

            % Init 
            spectrum_merged = spectrum_vec(1);

            % Merge spectrum
            [sp_temp, sampling_temp] = merge_spectra([spectrum_vec(1).min; spectrum_vec(1).max; spectrum_vec(1).values], spectrum_vec(1).sampling,...
                                            [spectrum_vec(2).min; spectrum_vec(2).max; spectrum_vec(2).values], spectrum_vec(2).sampling);

            spectrum_merged.min = sp_temp(1,:);
            spectrum_merged.max = sp_temp(2,:);
            spectrum_merged.values = sp_temp(3,:);
            spectrum_merged.sampling = sampling_temp;
        end        

        %% GET METHODS %%
        function res = get.mid(obj)
            res = 0.5*obj.min + 0.5*obj.max;
        end
    end
end