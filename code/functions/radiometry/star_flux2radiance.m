function L = star_flux2radiance(F, d_star, R_star)
% Compute the original emitted radiance from a far star given its flux at a
% certain distance

L = F / (pi * R_star^2 / d_star ^2);

end

