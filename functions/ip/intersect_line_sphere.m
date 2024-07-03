function [P, u] = intersect_line_sphere(P1, P2, PC, R)

P1 = reshape(P1, 3, []);
P2 = reshape(P2, 3, []);
PC = reshape(PC, 3, []);

a = vecnorm(P2 - P1).^2;
b = 2*((P2(1) - P1(1)).*(P1(1) - PC(1)) + ...
       (P2(2) - P1(2)).*(P1(2) - PC(2)) + ...
       (P2(3) - P1(3)).*(P1(3) - PC(3)));
c = norm(PC).^2 + norm(P1).^2 - ...
    2*(PC(1).*P1(1) + PC(2).*P1(2) + PC(3).*P1(3)) - ...
    R^2;

k = b.^2 - 4*a*c;

if k < 0
    u = nan;
elseif k == 0
    u = -b/(2*a);
else
    % the closest
    u = max((-b + sqrt(k))/(2*a), (-b - sqrt(k))/(2*a));
end

P = P1 + u*(P2-P1);

end