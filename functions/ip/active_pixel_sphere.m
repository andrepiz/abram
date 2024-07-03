function [pxActive, pxActive_perc] = active_pixel_sphere(diameter_px, res_px, alpha)

% Active pixels
a = diameter_px/2;
b = a*cos(alpha);
pxCircle = pi*a^2;
pxEll = pi*a*b;
if diameter_px <= res_px
    pxActive = pxCircle/2 + pxEll/2;
        % pxActive/pxCircle = (1 + cos(phaseAngle))/2;
elseif diameter_px > res_px && diameter_px <= sqrt(2)*res_px
    pxSeg = 1/2*(diameter_px - res_px);
    pxCircSeg = a^2*acos(1-pxSeg/a) - (a-pxSeg)*sqrt(a^2 - (a-pxSeg)^2); % https://en.wikipedia.org/wiki/Circular_segment
    pxEllSeg = a*b*(acos(1-pxSeg/a) - (1-pxSeg/a)*sqrt(2*pxSeg/a - pxSeg^2/a^2)); % https://rechneronline.de/pi/elliptical-segment.php
    pxActive = pxCircle/2 - 2*pxCircSeg + pxEll/2 - pxEllSeg;
elseif diameter_px > sqrt(2)*res_px
    pxActive = res_px^2;
end
pxActive = max(1, min(pxActive, res_px^2));
pxActive_perc = pxActive/(res_px^2);

end