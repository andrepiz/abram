function [swath, phi, err] = fov2swath(fov, distance, radius, offpoint, flag_cap_tangency, flag_debug)
%FOV2SWATH Find the swath covered by a FOV on a sphere of
%given radius at given distance with given off-pointing angle. phi is the
%angle between the sphere-observer direction and the sphere-intersection
%direction (= 0 for zero offpoint).
%NOTE:
% - there are always two solutions to the problem
% - in case of non-zero offpointing, the swath is not symmetric with
%   respect to phi

if ~exist('offpoint','var') 
   offpoint = 0;
end

if ~exist('flag_cap_tangency','var') 
   flag_cap_tangency = true;
end

if ~exist('flag_debug','var') 
   flag_debug = false;
end

nf = length(fov);
no = length(offpoint);
if no == 1  
    offpoint = offpoint*ones(1, nf);
    no = nf;
end
if nf == 1
    fov = fov*ones(1, nf);
    nf = no;
end
if no~=nf
    error('fov and offpointing vectors must have same number of elements')
end

funZeroSmall = @(hs, br, hs_max) atan(radius.*sin(min(hs_max, hs))./(distance - radius.*cos(min(hs_max, hs)))) - br;
funZeroLarge = @(hs, br, hs_min) atan(radius.*sin(max(hs_min, hs))./(distance - radius.*cos(max(hs_min, hs)))) - br;

if all(offpoint == 0)

    % Init
    hs = zeros(2, no); % Half Swath
    br = 0.5*fov;      % Bearing angle

    [hs_tangency, br_tangency] = find_sphere_tangent_angle(distance, radius);
    fov_tangency = 2*br_tangency;
    if flag_cap_tangency
        % Out-of-tangency points have a swath capped to two times the tangency
        % angle
        ixs_over_tangency = fov > fov_tangency;
        if any(ixs_over_tangency)
            hs(:, ixs_over_tangency) = hs_tangency;
        end    
    else
        ixs_over_tangency = false(1, no);
    end

    hs(1, ~ixs_over_tangency) = wrapTo2Pi(arrayfun(@(f) fzero(@(x) funZeroSmall(x, f, hs_tangency), 0), br(~ixs_over_tangency)));
    hs(2, ~ixs_over_tangency) = wrapTo2Pi(arrayfun(@(f) fzero(@(x) funZeroLarge(x, f, hs_tangency), pi), br(~ixs_over_tangency)));
    err = [funZeroSmall(hs(1,:), br, hs_tangency); ...
           funZeroLarge(hs(2,:), br, hs_tangency)];
    swath = 2*hs;
    phi = zeros(2, no);
    
    if flag_debug
        figure(), grid on, hold on
        swath_tangency = 2*hs_tangency;
        plot(rad2deg(fov), rad2deg(swath'),'o-')
        xline(rad2deg(fov_tangency))
        yline(rad2deg(swath_tangency))
        xlabel('FOV [deg]'), ylabel('Swath [deg]'), legend('Small','Large','Tangency FOV','Tangency Swath')
    end

else

    swath = zeros(2, no);

    brMin = offpoint - 0.5*fov; 
    brMax = offpoint + 0.5*fov;
    brMid = 0.5*brMin + 0.5*brMax; 
    swathBrMax = fov2swath(2*abs(brMax), distance, radius, 0, true, false);
    [doublePhi, ~, err] = fov2swath(2*abs(brMid), distance, radius, 0, true, false);
    swathBrMin = fov2swath(2*abs(brMin), distance, radius, 0, true, false);
    
    swath(1, :) = 0.5*abs(wrapTo2Pi(swathBrMax(1,:)) - wrapTo2Pi(swathBrMin(1, :)));
    swath(1, swathBrMin(1,:)==0) = 0.5*abs(wrapTo2Pi(swathBrMax(1, swathBrMin(1,:)==0)));
    swath(1, swathBrMax(1,:)==0) = 0.5*abs(wrapTo2Pi(swathBrMin(1, swathBrMax(1,:)==0)));
    swath(2, :) = 0.5*abs(wrapTo2Pi(swathBrMin(2,:)) - wrapTo2Pi(swathBrMax(2, :)));
    phi = sign(offpoint).*doublePhi/2;
    % fix zero offpoint cases
    [swath(:, offpoint == 0), phi(:, offpoint == 0)] = fov2swath(fov(offpoint == 0), distance, radius); 
    
    if flag_debug
        [hs_tangency, br_tangency] = find_sphere_tangent_angle(distance, radius);

        figure(), grid on, hold on
        plot(rad2deg(phi(1, :)), rad2deg(swath(1, :)),'o-'), 
        plot(rad2deg(phi(2, :)), rad2deg(swath(2, :)),'o-')
        xline(rad2deg(hs_tangency))
        xline(rad2deg(-hs_tangency))
        xlabel('\phi [deg]'), ylabel('Swath [deg]'), legend('Small','Large','Tangency \phi')

        figure(), grid on, hold on
        plot(rad2deg(offpoint), rad2deg(swath(1, :)),'o-'), 
        plot(rad2deg(offpoint), rad2deg(swath(2, :)),'o-')
        xline(rad2deg(br_tangency))
        xline(rad2deg(-br_tangency))
        xlabel('Offpoint [deg]'), ylabel('Swath [deg]'), legend('Small','Large','Tangency Offpoint')
    end

end


end

