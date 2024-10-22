% General
general_environment = 'matlab';         % which environment to use. Only matlab supported as for now
general_parallelization = false;        % Apply parallelization with specified number of workers
general_workers = 4;                    % Number of workers for parallel operations

% Discretization
discretization_method = 'fixed';        % {'fixed','adaptive'}. 'fixed' uses a user-defined number of points, 'adaptive' selects the number of points depending on an accuracy measure
                                        discretization_np = 5e5; % [1 Inf] Only for 'fixed discretization', it is the number of total points sampled on the sphere
                                        discretization_accuracy = 'low'; % {'low', 'medium', 'high'} Only for 'adapative' discretization, it is related to the number of points falling into the maximum projected pixel arc 

% Sampling
sampling_method = 'projecteduniform';   % 'uniform' sampling of longitude and latitude points uniformly on the sphere
                                        % 'projecteduniform' sampling of longitude and latitude points that are approximately spread uniformly on the projected sphere
sampling_ignore_unobservable = true;             % ignore sectors that fall outside the tangency circle

% Integration
integration_method = 'trapz';           % 'integral': integral2 is used
                                        % 'trapz':    trapz is used. much faster with less than 1% of error
                                        integration_np = 10;  % number of evaluation points for trapz
integration_correct_reflection = true;   % Correct reflection angle with true reflection angle (big difference at low distance-to-radius ratios or when using normal map)
integration_correct_incidence = true;    % Correct incidence angle with true incidence angle (big difference at low distance-to-radius ratios or when using normal map)

% Gridding
gridding_method = 'weightedsum';        % 'sum' Sum of the point values falling into the same pixel.
                                        % 'weightedsum' Weighted sum of the point values falling into the same pixel with an ['area','diff','invsquared'] weighting algorithm
                                        gridding_algorithm = 'area';             % 'invsquared' Inverse squared distance with each vertex
                                                                                % 'diff' 1 minus distance normalized over maximum distance
                                                                                % 'area' use [1x1] boxes for computing the weights
                                        % 'interpolation' Interpolation of the point values at each pixel with a ['nearest','linear','natural','cubic'] interpolation scheme
                                        gridding_scheme = 'linear';              % 'nearest' 
                                                                                % 'linear' 
                                                                                % 'cubic'
                                        % 'shiftedsum' Sum of the point values falling into the same pixel, doing a mean on point sets that are shifted on all directions of a specified quantity
                                        gridding_shift = 1;              
                                        % 'weightedshiftedsum' Sum of the point values falling into the same pixel, doing a weighted mean on point sets that are shifted on all directions of a specified quantity with a ['gaussian'] weighting filter
                                        gridding_filter = 'gaussian';

% Reconstruction
reconstruction_granularity = 1;                     % Grid upsampled up to the specified granularity, then resized to nominal size with a ['nearest','bilinear','bicubic','lanczos2','lanczos3','gaussian','osculatory'] reconstruction filter
reconstruction_filter = 'bilinear';

% Processing
processing_distortion = false;               % Apply distortion to the output image 
processing_diffraction = false;              % Apply a point-spread function to the output image
processing_blooming = false;                 % Apply blooming effect (saturation)
processing_noise = false;                    % Apply detector-level noises (DC, PRNU, SN, DSNU, RN)

% Saving
image_filename = 'example';                  % Filename of the saved image. Leave empty to not save it.
image_format = 'png';                        % Format of the saved image 