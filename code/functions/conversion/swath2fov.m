function [fov, phi, err] = swath2fov(swath, distance, radius, offpoint, flag_cap_tangency, flag_debug)
%SWATH2FOV Find the required FOV to image a certain swath on a sphere of
%given radius at given distance and off-pointing angle. phi is the
%angle between the sphere-observer direction and the sphere-intersection
%direction (= 0 for zero offpoint).
%NOTE:
% - when swath is outside the tangency limit, the fov is capped to the
%   tangency limit

if ~exist('offpoint','var') 
   offpoint = 0;
end

if ~exist('flag_cap_tangency','var') 
   flag_cap_tangency = true;
end

if ~exist('flag_debug','var') 
   flag_debug = false;
end

ns = length(swath);
no = length(offpoint);
if no == 1  
    offpoint = offpoint*ones(1, ns);
    no = ns;
end
if ns == 1
    swath = swath*ones(1, ns);
    ns = no;
end
if no~=ns
    error('swath and offpointing vectors must have same number of elements')
end

% Init
halfFovFun = @(hs, br) atan(radius*sin(hs)./(distance - radius*cos(hs))) - br;

if all(offpoint == 0)

    % Solve explicit equation
    fov = 2*halfFovFun(swath/2, 0);
    phi = zeros(1, no);
    err = zeros(1, no);

    [hs_tangency, br_tangency] = find_sphere_tangent_angle(distance, radius);
    swath_tangency = 2*hs_tangency;
    fov_tangency = 2*br_tangency;
    if flag_cap_tangency
        % Cap the FOV to two times the tangency angle for swath larger than limits
        ixs_over_tangency = swath > swath_tangency;
        if any(ixs_over_tangency)
            fov(ixs_over_tangency) = fov_tangency;
        end    
    end

    if flag_debug
        figure(), grid on, hold on
        plot(rad2deg(swath), rad2deg(fov),'o-')
        xline(rad2deg(swath_tangency))
        yline(rad2deg(fov_tangency))
        xlabel('Swath [deg]'), ylabel('FOV [deg]'), legend('FOV','Tangency Swath','Tangency FOV')
    end

else

    % Use absolute offpoint
    sign_offpoint = sign(offpoint);
    offpoint = abs(offpoint);

    % If there is any offpointing, we first need to find the phi angle
    % associated. This is equal to half the swath associated to 
    % a fov equal to double the off-pointing
    [doublePhi, ~, err] = fov2swath(2*offpoint, distance, radius, 0, true, false);
    phi = doublePhi(1,:)/2;

    % Then we can solve the explicit equation
    fov = 2*halfFovFun(phi + swath/2, offpoint);

    % Change the sign to be consistent with offpoint
    phi = sign_offpoint.*phi;

    if flag_debug
        [hs_tangency, br_tangency] = find_sphere_tangent_angle(distance, radius);
        fov_tangency = 2*br_tangency;
        figure(), grid on, hold on
        plot(rad2deg(phi(1, :)), rad2deg(fov(1, :)),'o-'), 
        xline(rad2deg(hs_tangency))
        xline(rad2deg(-hs_tangency))
        xlabel('\phi [deg]'), ylabel('FOV [deg]'), legend('FOV','Tangency Angle')

        figure(), grid on, hold on
        plot(rad2deg(offpoint), rad2deg(fov),'o-'), 
        yline(rad2deg(fov_tangency))
        xlabel('offpoint [deg]'), ylabel('FOV [deg]'), legend('FOV','Tangency FOV')
    end

end

end

