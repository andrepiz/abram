function [t, pos, vel] = read_artemis_kernel(kernel_file, flag_plot)
% CCSDS_OEM_VERS = 2.0
% COMMENT Artemis I PostFlight As Flow (Orion/AsFlown)
% CREATION_DATE = 2022-12-13T07:03:33
% ORIGINATOR = NASA/JSC/FOD/FDO
% COMMENT Orion/ICPS Separation to EI Filtered 60s
% META_START
% OBJECT_NAME = EM1
% OBJECT_ID = 23
% CENTER_NAME = EARTH
% REF_FRAME = EME2000
% TIME_SYSTEM = UTC
% START_TIME = 2022-11-16T08:44:51.150
% STOP_TIME = 2022-12-11T17:20:44.316

tableraw = readtable(kernel_file, 'FileType','delimitedtext', 'VariableNamingRule','preserve');
ixs_valid = ~any(isnan(table2array(tableraw(:,2:end))), 2);

t = datetime(tableraw(ixs_valid,1).Variables)';
pos = 1e3*tableraw(ixs_valid,2:4).Variables';
vel = 1e3*tableraw(ixs_valid,5:7).Variables';

if flag_plot
    ixs_plot = 1:30:length(t);
    pos_plot = pos/384400e3;
    vel_plot = 3*vel/max(vecnorm(vel));
    figure(), grid on, hold on, axis equal
    plot3(pos_plot(1,:), pos_plot(2,:), pos_plot(3,:),'LineWidth',2)
    quiver3(pos_plot(1,ixs_plot), pos_plot(2,ixs_plot), pos_plot(3,ixs_plot), vel_plot(1,ixs_plot), vel_plot(2,ixs_plot), vel_plot(3,ixs_plot),'LineWidth',1)
    xlabel('X_{ECI} [Moon Distance]')
    ylabel('Y_{ECI} [Moon Distance]')
    zlabel('Z_{ECI} [Moon Distance]')
end

end

