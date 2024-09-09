function fh = plot_frames_and_vectors(R_frames2ref, R_pos_ref, v_ref, v_pos_ref, fh, R_lg, v_lg)
    
if ~exist('fh','var')
    fh = figure();
    grid on
    hold on
    axis equal
    view([1 1 1])
end

[a,b,n] = size(R_frames2ref);
[c,m] = size(v_ref);

if ~exist('R_lg','var')
    R_lg = cellstr(num2str([1:n]'));
end

if ~exist('v_lg','var')
    v_lg = cellstr(num2str([1:m]'));
end

if a~=3 || b~=3 && n~=0
    error('Provide R as [3x3xN]')
end

if c~=3 && m~=0
    error('Provide v as [3xM]')
end

% random colors
%col = rand(m+n, 3);
col = get(gca, 'ColorOrder');

for i = 1:n
    c = col(i,:);
    R = R_frames2ref(:,:,i);
    pos = R_pos_ref(:,i);
    x = R*[1;0;0];
    y = R*[0;1;0];
    z = R*[0;0;1];
    quiver3(pos(1),pos(2),pos(3),x(1),x(2),x(3),'Color',c)
    quiver3(pos(1),pos(2),pos(3),y(1),y(2),y(3),'Color',c)
    quiver3(pos(1),pos(2),pos(3),z(1),z(2),z(3),'Color',c)
    x = x + pos;
    y = y + pos;
    z = z + pos;
    text(x(1),x(2),x(3),['x',R_lg{i}],'Color',c)
    text(y(1),y(2),y(3),['y',R_lg{i}],'Color',c)
    text(z(1),z(2),z(3),['z',R_lg{i}],'Color',c)
end

for j = 1:m
    c = col(j+i,:);
    v = v_ref(:,j);
    pos = v_pos_ref(:,j);
    quiver3(pos(1),pos(2),pos(3),v(1),v(2),v(3),'Color',c,'LineWidth',2)
    v = v + pos;
    text(v(1),v(2),v(3),['V',v_lg{j}],'Color',c)
end


end