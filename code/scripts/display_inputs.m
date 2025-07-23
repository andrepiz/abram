%% DISPLAY INPUTS

xy_sep = '\';
disp('+++ BODY +++')
disp(['   Diameter: ', num2str(1e-3*2*Rbody),' km'])
disp(['   Albedo (geometric, normal, bond): ', num2str(pGeom),', ',num2str(pNorm),', ',num2str(pBond)])
disp(['   Absolute Magnitude: ', num2str(H)])
disp(['   Tangency angle: ', num2str(rad2deg(bodyTangencyAngle)),' deg'])

disp('+++ CAMERA +++')
disp(['   Focal: ', num2str(1e3*f),' mm'])
disp(['   F-number: ', num2str(fNum)])
disp(['   FOV: ', char(strjoin(string(rad2deg(fov)),xy_sep)),' deg, ', ...
    char(strjoin(string(res_px),xy_sep)),' px, ', ...
    char(strjoin(string(1e3*sensorSize),xy_sep)),' mm'])
disp(['   Dynamic Range: ', num2str(dnr),' dB'])

disp('+++ SCENARIO +++')
disp(['   Distance from star: ', num2str(1e-3*d_body2star),' km'])
disp(['   Distance from camera: ', num2str(1e-3*d_body2cam),' km'])
disp(['   Phase angle: ', num2str(rad2deg(phase_angle)),' deg'])
disp(['   Off-pointing angle: ', num2str(rad2deg(ang_offpoint)),' deg'])
disp(['   Body angular size: ', num2str(rad2deg(bodyAngSize)),' deg'])
disp(['   GSD: ', char(strjoin(string(1e-3*gsd),xy_sep)),' km'])
disp(['   Body dimension: ', char(strjoin(string(bodyPxSize),xy_sep)),' px, ', ...
    char(strjoin(string(1e2*bodyPxSize./res_px),xy_sep)),'% of resolution'])

disp('+++ PARAMS +++')
if general_parallelization
    disp(['   ', general_environment,' environment, parallelized with ', num2str(general_workers), ' workers'])
else
    disp(['   ', general_environment,' environment, single thread'])
end
disp(['   ', radiometry_model,' reflection model'])
switch gridding_method
    case 'sum'
        gridding_txt = ['sum'];
    case 'weightedsum'
        gridding_txt = ['sum weigthed on ',gridding_algorithm];
    case 'interpolation'
        gridding_txt = [gridding_interpolation ' interpolated'];
    case 'shiftedsum'
        gridding_txt = ['mean sum on ',num2str(gridding_shift),'-px shifted clouds'];
    case 'weightedshiftedsum'
        gridding_txt = ['weighted mean sum on ',num2str(gridding_shift),'-px shifted clouds with ',gridding_filter,' filter'];
end
switch reconstruction_granularity
    case 1
        reconstruction_txt = ['no grid upsampling, no reconstruction filter'];
    otherwise
        reconstruction_txt = [num2str(reconstruction_granularity),'-times grid upsampling, ', reconstruction_filter,' reconstruction filter'];
end
disp(['   ',discretization_method,' discretization, ', sampling_method,' sampling, ', integration_method,' integration, ', gridding_txt, ' gridding, ',reconstruction_txt])
%disp(['   diffraction: ', char(string(processing_diffraction)),...
%    ', blooming: ', char(string(processing_blooming))])