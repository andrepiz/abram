function [fig_x, fig_y] = axesToFigureCoords(ax, x, y)
    % Convert (x, y) from data coordinates in ax to normalized figure coordinates

    % Get axes and figure properties
    ax_pos = ax.Position;  % Axes position in normalized figure units
    x_lim = ax.XLim;
    y_lim = ax.YLim;

    % Convert X coordinate to normalized figure units
    fig_x = ax_pos(1) + ((x - x_lim(1)) / (x_lim(2) - x_lim(1))) * ax_pos(3);

    % Convert Y coordinate to normalized figure units
    fig_y = ax_pos(2) + ((y - y_lim(1)) / (y_lim(2) - y_lim(1))) * ax_pos(4);
end