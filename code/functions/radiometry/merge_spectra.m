function [sp3, sampling3] = merge_spectra(sp1, sampling1, sp2, sampling2)
% Merge two spectra whose values are defined at different sampling points
% according to different sampling methods {'piecewise','midpoint'}. The
% spectra are 3xN1 and 3xN2 matrices where first row identifies the 
% lower wavelength, second row the upper wavelength and third row the values.
% If N1 and N2 are different, the third spectrum uses the lower between the
% two to create the new basis.

sp1 = reshape(sp1, 3, []);
sp2 = reshape(sp2, 3, []);
n1 = size(sp1, 2);
n2 = size(sp2, 2);

% Find common basis
x_min = min([sp1(1,:), sp2(1,:)]);
x_max = max([sp1(2,:), sp2(2,:)]);
n_min = min(n1, n2);
n_max = max(n1, n2);
basis = linspace(x_min, x_max, n_max + 1);
sp3(1,:) = basis(1:end-1);
sp3(2,:) = basis(2:end);

% Define a common grid based on the range of x1 and x2
n_grid = n_max * 10; % Define a dense grid
xg = linspace(x_min, x_max, n_grid);

% Set basis interpolation
switch sampling1
    case 'piecewise'
        sp1end(1) = sp1(2, end);
        sp1end(2) = x_max;
        sp1end(3) = 0;
        sp1 = [sp1, sp1end'];   % append zero-values element at the end
        n1 = n1 + 1;
        x1 = sp1(1,:);
        method1 = 'previous';
    case 'midpoint'
        x1 = 0.5*sp1(1,:) + 0.5*sp1(2,:);
        method1 = 'linear';
    otherwise
        error('Interpolation not supported')
end
switch sampling2
    case 'piecewise'
        sp2end(1) = sp2(2,end);
        sp2end(2) = x_max;
        sp2end(3) = 0;
        sp2 = [sp2, sp2end'];   % append zero-values element at the end
        n2 = n2 + 1;
        x2 = sp2(1,:);
        method2 = 'previous';
    case 'midpoint'
        x2 = 0.5*sp2(1,:) + 0.5*sp2(2,:);
        method2 = 'linear';
    otherwise
        error('Interpolation not supported')
end                

% Set output interpolation
if strcmp(sampling1, 'piecewise') && strcmp(sampling2, 'piecewise')
    x3 = sp3(1,:);
    method3 = 'next';
    sampling3 = 'piecewise';
elseif strcmp(sampling1, 'midpoint') && strcmp(sampling2, 'midpoint')
    x3 = 0.5*sp3(1,:) + 0.5*sp3(2,:);
    method3 = 'linear';
    sampling3 = 'midpoint';
else
    error('Different interpolation methods between the two spectrum are not supported')
end


% Interpolate both lines to the common grid
if n1 >= 2
    y1_interp = interp1(x1, sp1(3,:), xg, method1, 0); % Interpolate y1 to x_common
else
    y1_interp = sp1(3,:).*ones(1, n_grid);
end
if n2 >= 2
    y2_interp = interp1(x2, sp2(3,:), xg, method2, 0); % Interpolate y2 to x_common
else
    y2_interp = sp2(3,:).*ones(1, n_grid);
end

% Perform the product using the common grid
yg = y1_interp.*y2_interp;

% Interpolate back to the desired spectrum
sp3(3,:) = interp1(xg, yg, x3, method3, 0); 

end