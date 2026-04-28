%% INSTALL
abram_install();

%% INPUTS
filename_yml = 'noise.yml';

%% CALL
rend = abram.render(filename_yml);

%% APPLICATION OF NOISES

% Aberrations
% Zernike coefficients as RMS of diffraction wave (OSA/ANSI). 
% [tiltX, tiltY, defocus, astig45, astig0, comaY, comaX, trefoilY, trefoilX]. 
% Set polychromatic to compute a different PSF for each waveband of the camera.
% Pass [] for diffraction-limited (all zeros). 
% Pass [Wx9] where W is the number of camera wavebands for chromatic aberrations.
rend.camera.noise.aberration.flag = true;
rend.camera.noise.aberration.coefficients = [0, 0, 5];    % blurring only (3rd coeff)
%rend.camera.noise.aberration.coefficients = rand(length(rend.camera.QExT.lambda_mid), 9);    % polychromatic, random
rend.camera.noise.polychromatic = true; 

% Blooming
% Blooming occurs at saturation and cause photon leakage of saturated pixels 
% to neighboring pixels. Alpha controls the percentage of excess to distribute 
% and beta the offset wrt fwc after which where leakage start.
rend.camera.tExp = 10e-3; % increase tExp to reach saturation
rend.camera.noise.blooming.flag = true;
rend.camera.noise.blooming.alpha = 0.05;    % to be tuned in HIL experiments
rend.camera.noise.blooming.beta = 0.02;     % to be tuned in HIL experiments

% Shot
% Poisson random noise due to random fluctuations of the signal
rend.camera.noise.shot.flag = true;

% PRNU
% Each pixel response with a different multiplicative factor with a given
% standard deviation
rend.camera.noise.prnu.flag = true;
rend.camera.noise.sigma = 0.03; % 3% non-uniformity

% Dark
% Linked to detector temperature, generation of thermoelectrons. A mean
% signal in electron-per-second with a given non-uniformity
rend.camera.noise.dark.flag = true;
rend.camera.noise.dark.mean = 391; % [e-/s]
rend.camera.noise.dark.sigma = 0.625; % 62.5% 1-sigma deviation on dark current signal

% Readout
% Random electron gaussian noise at readout
rend.camera.noise.readout.flag = true;
rend.camera.noise.readout.sigma = 82.06; % [e]

% Smearing
% Only in CCD. At readout each row shifts over one another before reaching
% the end of the array for reading. During the shift, it accumulates the
% signal depending on the time to read out the array.
rend.camera.noise.smearing.flag = true;
rend.camera.noise.smearing.readout_time = 1e-6; %[s]    % typical is 1e-6. exaggerate to see it.
rend.camera.noise.smearing.direction = 'up';

%% RENDERING & VISUALIZATION
rend = rend.rendering(); 

postpro()

% Visualize in small colorspace
postpro()
clms = [0 800];
clim(clms)
colormap('turbo')
title('Modified Colorscale')