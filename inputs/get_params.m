% Discretization
discretization_method = 'fixed';        % {'fixed','adaptive'}. 'fixed' uses a user-defined number of points, 'adaptive' selects the number of points depending on an accuracy measure
                                        discretization_np = 5e5; % [1 Inf] Only for 'fixed discretization', it is the number of total points sampled on the sphere
                                        discretization_accuracy = 'low'; % {'low', 'medium', 'high'} Only for 'adapative' discretization, it is related to the number of points falling into the maximum projected pixel arc 

% Sampling
sampling_method = 'projective';  % 'uniform' sampling of longitude and latitude points uniformly on the sphere
                                        % 'projective' sampling of longitude and latitude points that are approximately spread uniformly on the projected sphere
sampling_ignore_unobservable = true;             % ignore sectors that fall outside the tangency circle

% Integration
integration_method = 'trapz';           % 'integral': integral2 is used
                                        % 'trapz':    trapz is used. much faster with less than 1% of error
                                        integration_np = 10;  % number of evaluation points for trapz
integration_correct_incidence = true;    % Correct incidence angle with true incidence angle with low distance-to-radius ratios

% Binning
binning_method = 'weightedsum';         % 'sum' sums all the intensity values falling within the same pixel
                                        % 'weightedsum' weighs each intensity value spreading it across the neighbouring pixels
                                        binning_algorithm = 'area';            % 'invsquared' Inverse squared distance with each vertex
                                                                                % 'diff' 1 minus distance normalized over maximum distance
                                                                                % 'area' use [1x1] boxes for computing the weights
                                        % 'interpolation' interpolate the intensity value at the sector midpoints (NOTE: Not physically consistent!)
                                        binning_interpolation = 'linear';        % 'nearest' 
                                                                                % 'linear' 
                                                                                % 'cubic'
binning_granularity = 1;                     % Down-sampling of pixels

% Processing
processing_distortion = false;               % Apply distortion to the output image 
processing_diffraction = false;              % Apply a point-spread function to the output image
processing_blooming = false;                 % Apply blooming effect (saturation)
processing_noise = false;                    % Apply detector-level noises (DC, PRNU, SN, DSNU, RN)
