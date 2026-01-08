%% Coverage

img_coverage = rend.coverage();

[h, w] = size(img_coverage);
lims = rend.body.maps.albedo.limits;

figure()
hold on
axis equal
imagesc(rad2deg(linspace(lims(1, 1), lims(1, 2), w)), rad2deg(linspace(lims(2, 2), lims(2, 1), h)), img_coverage)
scatter(rad2deg(rend.scene.sph_body2cam_IAU(2)), rad2deg(rend.scene.sph_body2cam_IAU(3)), 200, 'g+','LineWidth',2)
scatter(rad2deg(rend.scene.sph_body2light_IAU(2)), rad2deg(rend.scene.sph_body2light_IAU(3)), 200, 'b*','LineWidth',2)
set(gca(),'YDir','normal')
xlabel('Lon [deg]')
ylabel('Lat [deg]')
xlim(rad2deg([lims(1,1), lims(1,2)]))
ylim(rad2deg([lims(2,1), lims(2,2)]))