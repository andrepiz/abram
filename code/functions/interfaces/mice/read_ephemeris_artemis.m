function [t_UTC, pos_moon2sun_MOON, pos_moon2cam_MOON, q_MOON2CAM, ...
    pos_earth2sun_EARTH, pos_earth2cam_EARTH, q_EARTH2CAM, ...
    pos_moon2earth_MOON, pos_earth2moon_EARTH] = ...
        read_ephemeris_artemis(mission, filename_table, filename_metakernel, originSpiceID, rpy_CAMICAM, pointing, flag_plot)

% Check that mice is installed
if isempty(which('mice_home.m'))
    error('MICE not found. Please install MICE from https://github.com/andrepiz/mice')
else
    addpath(genpath(mice_home()))
end

switch mission
    case 'artemis2022'
        % CCSDS_OEM_VERS = 2.0
        % COMMENT Artemis I PostFlight As Flow (Orion/AsFlown)
        % CREATION_DATE = 2022-12-13T07:03:33
        % ORIGINATOR = NASA/JSC/FOD/FDO
        % COMMENT Orion/ICPS Separation to EI Filtered 60s
        tableraw = readtable(filename_table, 'FileType','delimitedtext', 'VariableNamingRule','preserve');
        ixs_valid = ~any(isnan(table2array(tableraw(:,2:end))), 2);
        t_UTC = datetime(tableraw(ixs_valid,1).Variables)';
        pos_km = tableraw(ixs_valid,2:4).Variables';
        vel_km = tableraw(ixs_valid,5:7).Variables';
        nt = length(t_UTC);

    case 'artemis2026'
        temp = readtable(filename_table);
        d = table2array(temp(:, 3));
        t = table2array(temp(:, 4));
        try
            t_UTC = datetime(string(d)+"T"+string(t),'InputFormat','dd-MMM-uuuu''T''HH:mm:ss');
        catch
            t_UTC = datetime(string(d)+"T"+string(t),'InputFormat','uuuu-MMM-dd''T''HH:mm:ss');
        end
        state = table2array(temp(:, [5 6 7 8 9 10]));
        pos_km = state(:,1:3)';
        vel_km = state(:,4:6)';
        nt = length(t_UTC);

end

%% Convert to Moon body-fixed frame

pos_origin2sun_ECI = extract_position_bodies_kernel(t_UTC, {'SUN'}, filename_metakernel, 'NONE',originSpiceID,'J2000');
pos_origin2moon_ECI = extract_position_bodies_kernel(t_UTC, {'MOON'}, filename_metakernel, 'NONE',originSpiceID,'J2000');
pos_origin2earth_ECI = extract_position_bodies_kernel(t_UTC, {'EARTH'}, filename_metakernel, 'NONE',originSpiceID,'J2000');
pos_origin2sc_ECI = pos_km*1e3;

pos_sc2earth_ECI = pos_origin2earth_ECI - pos_origin2sc_ECI;
dir_sc2earth_ECI = vecnormalize(pos_sc2earth_ECI);
pos_sc2moon_ECI = pos_origin2moon_ECI - pos_origin2sc_ECI;
dir_sc2moon_ECI = vecnormalize(pos_sc2moon_ECI);
pos_sc2sun_ECI = pos_origin2sun_ECI - pos_origin2sc_ECI;
dir_sc2sun_ECI = vecnormalize(pos_sc2sun_ECI);
pos_moon2sun_ECI = pos_sc2sun_ECI - pos_sc2moon_ECI;
pos_moon2earth_ECI = pos_sc2earth_ECI - pos_sc2moon_ECI;
pos_sun2earth_ECI = pos_sc2earth_ECI - pos_sc2sun_ECI;

%% ORIENTATION
q_ECI2MOON = extract_orientation_bodies_kernel(t_UTC, {'MOON_ME'}, filename_metakernel, 'J2000');
q_ECI2EARTH = extract_orientation_bodies_kernel(t_UTC, {'ITRF93'}, filename_metakernel, 'J2000');

%---Generate camera attitude
% Assuming to point z at the body and solar panels aligned to x 
% --> y must be perpendicular to both z and sun direction
switch pointing
    case 'moon'
        zCAMI_ECI = dir_sc2moon_ECI;
    case 'earth'
        zCAMI_ECI = dir_sc2earth_ECI;
end
yCAMI_ECI = -vecnormalize(cross(dir_sc2sun_ECI, zCAMI_ECI));
xCAMI_ECI = vecnormalize(cross(yCAMI_ECI, zCAMI_ECI));
dcm_CAMI2ECI = zeros(3,3,nt);
dcm_CAMI2ECI(:,1,:) = xCAMI_ECI;
dcm_CAMI2ECI(:,2,:) = yCAMI_ECI;
dcm_CAMI2ECI(:,3,:) = zCAMI_ECI;
q_CAMI2ECI = dcm_to_quat(dcm_CAMI2ECI);
q_CAM2CAMI = quat_conj(euler_to_quat(rpy_CAMICAM));
q_CAM2ECI = quat_mult(q_CAM2CAMI, q_CAMI2ECI);

%% ABRAM inputs
% MOON
q_CAM2MOON = quat_mult(q_CAM2ECI, q_ECI2MOON);
q_MOON2CAM = quat_conj(q_CAM2MOON);
pos_moon2sun_MOON = rotframe(pos_moon2sun_ECI, q_ECI2MOON);
pos_moon2cam_MOON = rotframe(-pos_sc2moon_ECI, q_ECI2MOON);
pos_moon2earth_MOON = rotframe(pos_moon2earth_ECI, q_ECI2MOON);

% EARTH
q_CAM2EARTH = quat_mult(q_CAM2ECI, q_ECI2EARTH);
q_EARTH2CAM = quat_conj(q_CAM2EARTH);
pos_earth2sun_EARTH = rotframe(-pos_sun2earth_ECI, q_ECI2EARTH);
pos_earth2cam_EARTH = rotframe(-pos_sc2earth_ECI, q_ECI2EARTH);
pos_earth2moon_EARTH = rotframe(-pos_moon2earth_ECI, q_ECI2EARTH);

%% POST-PRO
if flag_plot
    figure()
    grid on, hold on
    plot(t_UTC, 1e-3*vecnorm(pos_sc2moon_ECI))
    plot(t_UTC, 1e-3*vecnorm(pos_sc2earth_ECI))
    plot(t_UTC, 1e-3*vecnorm(pos_sc2sun_ECI))
    yline(6371, 'blue')
    yline(1737.4, 'black')
    legend('Distance to Moon','Distance to Earth','Distance to Sun','Earth Radius','Moon Radius')
    set(gca(),'YScale','log')
    ylabel('[km]')

    ixs_plot = 1:30:length(t_UTC);
    pos_plot = -pos_sc2earth_ECI/384400e3;
    vel_plot = 3*vel_km/max(vecnorm(vel_km));
    figure(), grid on, hold on, axis equal
    plot3(pos_plot(1,:), pos_plot(2,:), pos_plot(3,:),'LineWidth',2)
    quiver3(pos_plot(1,ixs_plot), pos_plot(2,ixs_plot), pos_plot(3,ixs_plot), vel_plot(1,ixs_plot), vel_plot(2,ixs_plot), vel_plot(3,ixs_plot),'LineWidth',1)
    xlabel('$X_{ECI}$ [Moon-Earth Distance]')
    ylabel('$Y_{ECI}$ [Moon-Earth Distance]')
    zlabel('$Z_{ECI}$ [Moon-Earth Distance]')
end

end

