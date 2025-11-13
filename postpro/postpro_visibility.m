%% Maps
% Check visibility of the scenario in terms of FOV, geometry observability
% and illumination from the sun
[latMidGrid_CSF, lonMidGrid_CSF] = meshgrid(latMid_CSF, lonMid_CSF);
[active, infov, observable, lit] = get_sphere_visibility_masks(latMidGrid_CSF, lonMidGrid_CSF, ...
        pos_cam2body_CSF, pos_star2body_CSF, dcm_CSF2CAM, ...
        Rbody, fov, nworkers, true);   
