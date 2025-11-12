body = rend.body; camera = rend.camera; scene = rend.scene; cloud = rend.cloud; matrix = rend.matrix; 

lonMid_CSF = rend.body.sampling.lonMid_CSF;
latMid_CSF = rend.body.sampling.latMid_CSF;

% Extract 3D cloud
coordsXYZ = cloud.coords(:, cloud.ixsValid);
coordsUV = camera.K(1:2,:)*(coordsXYZ./coordsXYZ(3,:));
coordsRC = [coordsUV(2,:); coordsUV(1,:)]; 
PL_point = cloud.values(cloud.ixsValid)*cloud.adim;
PL_pixel = matrix.values*matrix.adim;

%%
fh = figure();
scatter(coordsRC(2,:), coordsRC(1,:), [], PL_point);
axis tight equal
ax = gca();
ax.YDir = 'reverse';
xlim([260, 280])
ylim([720, 740])

figure()
imagesc(PL_pixel)
axis equal
xlim([260, 280])
ylim([720, 740])

figure()
grid on, hold on
plot(rad2deg(lonMid_CSF), linspace(0, 100, length(lonMid_CSF)))
plot(rad2deg(latMid_CSF), linspace(0, 100, length(latMid_CSF)))
legend('Longitude','Latitude')
xlabel('Angle [deg]')
ylabel('Cumulative number of points [%]')
