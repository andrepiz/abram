PF_point = PL_point ./ (pi * Rstar^2/(d_body2star^2));
L_bw_temp(1,:,:) = L_bw;
PL_pixel = sum(P_pixel_bw./L_bw_temp, 3);
PF_pixel = PL_pixel ./ (pi * Rstar^2/(d_body2star^2));

fh = figure();
scatter(coords(2,:), coords(1,:), [], PF_point);
axis tight equal
ax = gca();
ax.YDir = 'reverse';
xlim([300, 305])
ylim([720, 725])

figure()
imagesc(PF_img)
axis equal
xlim([300, 305])
ylim([720, 725])

figure()
grid on, hold on
plot(rad2deg(lonMid_CSF), linspace(0, 100, length(lonMid_CSF)))
plot(rad2deg(latMid_CSF), linspace(0, 100, length(latMid_CSF)))
legend('Longitude','Latitude')
xlabel('Angle [deg]')
ylabel('Cumulative number of points [%]')
