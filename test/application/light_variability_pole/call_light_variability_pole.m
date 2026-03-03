%% INSTALL
abram_install();

%% INPUTS
filename_yml = 'light_variability_pole.yml'; % fast version with parallellization

% %
% swath_angle = deg2rad(20);  % swath of south pole region
% altitude = 12500e3;         % altitude
% altitude = 15358e3;         % altitude
% altitude = 40967e3;         % altitude
% altitude = 83648e3;         % altitude
% Rbody = 1737.4e3;           % target body radius
% 
% % assumed
% res_px = 1024;
% muPixel = 6e-3*tan(deg2rad(61)/2)/(1024/2);   % using LRO data;
% 
% distance = altitude + Rbody
% fov = swath2fov(swath_angle, distance, Rbody)
% f = (res_px*muPixel/2)/(tan(fov/2))

%% RENDER OBJECT
% Perform a first rendering and save the render object
rend = abram.render(filename_yml, false);

%% MULTI-IMAGE CALLING
% Following renderings can be called with the rendering method
% on the render object

rend.setting.discretization.np = 1e7;
rend.setting.gridding.window = 1;
rend.setting.reconstruction.granularity = 1;
rend.setting.sampling.ignore_occluded = true;
%rend.scene.d_body2cam = distance;
rend.scene.d_body2cam = 76.5e6;

beta_vec = pi/180*[0:2:358];
%beta_vec = 0;
% Assume a landing trajectory at the south pole
rend.scene.phase_angle = pi/2;                    % the phase angle is fixed at 90 deg. We are looking at terminator.
rend.scene.rpy_CSF2IAU = [pi/2;0;0];       % IAU must yaw to account for Sun rotation
% Loop
% figure(), hold on
% I = imshow(uint8(rend.img));
for ix = 1:length(beta_vec)
    rend.scene.rpy_CSF2IAU(2) = -beta_vec(ix);
    rend.scene.rpy_CAMI2CAM(3) = -pi/2+beta_vec(ix);
    rend.rendering();
    % delete(I);
    % I = imshow(uint8(rend.img));
end

%% Create video
video = VideoWriter('test/application/light_variability_pole/results/test.mp4','MPEG-4'); %create the video object
video.FrameRate = 12;
%video.Quality = 66;
open(video); %open the file for writing
% I = imread(['test/application/landing_pole/results/test2/moon_south_pole.png']); %read the next image
% writeVideo(video, I); %write the image to file
for ii = 1:length(beta_vec)-2
  I = imread(['test/application/light_variability_pole/results/test/light_variability_pole',num2str(ii),'.png']); %read the next image
  writeVideo(video, I); %write the image to file
end
close(video); %close the file
