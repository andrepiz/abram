function spectrum = getInstrumentFilter(name_instrument, id_filter)


switch name_instrument

    case 'mdis'
        % From MESSENGER Mercury Dual Imaging System (MDIS) Experiment Data Record (EDR) Software Interface Specification (SIS)
        % Table 5. WAC filters specifications; wavelength and width measured at -26 C, focal lengths
        % and scale changes based on instrument design.
        % Filter Filter Wavelength Width Total Focal Scale
        % Number Filename (Flight) (Flight) Thickness length change
        % letter (nm) (nm) (mm) (mm) (%)
        % 1 A 698.8 5.3 6.00 78.218 -0.104
        % 2 B 700 600.0 6.00 78.163 -0.104
        % 3 C 479.9 10.1 6.30 77.987 -0.329
        % 4 D 558.9 5.8 6.30 78.023 -0.283
        % 5 E 628.8 5.5 6.20 78.109 -0.173
        % 6 F 433.2 18.1 6.00 78.075 -0.216
        % 7 G 748.7 5.1 5.90 78.218 -0.033
        % 8 H 947.0 6.2 5.20 78.449 0.262
        % 9 I 996.2 14.3 5.00 78.510 0.340
        % 10 J 898.8 5.1 5.35 78.390 0.186
        % 11 K 1012.6 33.3 4.93 78.535 0.372
        % 12 L 828.4 5.2 5.60 78.308 0.082
        data = [698.8 5.3 6.00 78.218 -0.104
                700 600.0 6.00 78.163 -0.104
                479.9 10.1 6.30 77.987 -0.329
                558.9 5.8 6.30 78.023 -0.283
                628.8 5.5 6.20 78.109 -0.173
                433.2 18.1 6.00 78.075 -0.216
                748.7 5.1 5.90 78.218 -0.033
                947.0 6.2 5.20 78.449 0.262
                996.2 14.3 5.00 78.510 0.340
                898.8 5.1 5.35 78.390 0.186
                1012.6 33.3 4.93 78.535 0.372
                828.4 5.2 5.60 78.308 0.082];
        wavelength_eff = 1e-9*data(id_filter, 1)';
        bandwidth = 1e-9*data(id_filter, 2)';
        spectrum.lambda_min = wavelength_eff - bandwidth/2;
        spectrum.lambda_max = wavelength_eff + bandwidth/2;
        spectrum.values = ones(1, length(bandwidth));    % not available, assumed constant as it is a narrow-band filter.

    case 'fc'
        % Dawn Framing Camera

        data = [438-30, 438+10; 
                 555-28, 555+15; 
                 653-24, 653+18; 
                 749-22, 749+22; 
                 829-18, 829+18; 
                 917-21, 917+24; 
                 965-29, 965+56];
        lambda_min = 1e-9*data(id_filter, 1)';
        lambda_max = 1e-9*data(id_filter, 2)';
        spectrum.lambda_min = lambda_min;
        spectrum.lambda_max = lambda_max;
        spectrum.values = ones(1, length(lambda_min));    % not available, assumed constant as it is a narrow-band filter.


    otherwise
        error('Instrument not supported')
end

end