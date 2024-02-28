%% COORDINATES
% delta: coelevation
% az: azimuth
% phi: longitude
% th: latitude

%% CORRECTION FACTORS
% ki = cos(delta_i_new)/cos(delta_i_old) 
% kr = cos(delta_r_new)/cos(delta_r_old) 

%% LAMBERT
%   BRDF = 1
%   cos(delta_i) = ki*sin(th)*cos(phi)
%   cos(delta_r) = kr*sin(th)*cos(alpha - phi)
% INTEGRAND: 
%   BRDF*cos(delta_i)*cos(delta_r)*sin(th) = ki*kr*sin(th)^3*cos(phi)*cos(alpha-phi)

brdf_lambert = @(alpha, th, phi, ki, kr) 1;
integrand_lambert = @(alpha, th, phi, ki, kr) ki*kr*sin(th)^3*cos(phi)*cos(alpha-phi);
integral_lambert_undefined = @(alpha, th1, th2, phi, ki, kr) -1/48*ki*kr*(cos(3*th2) - 9*cos(th2) - cos(3*th1) + 9*cos(th1))*(sin(alpha - 2*phi) - 2*phi.*cos(alpha));
integral_lambert = @(alpha, th1, th2, phi1, phi2, ki, kr) integral_lambert_undefined(alpha, th1, th2, phi2, ki, kr) - integral_lambert_undefined(alpha, th1, th2, phi1, ki, kr);
phase_law_lambert = @(alpha) ((pi-alpha).*cos(alpha) + sin(alpha))./pi;


%% LOMMEL - SEELIGER
%   BRDF = 1/(ki*cos(delta_i) + kr*cos(delta_r))
%   cos(delta_i) = ki*sin(th)*cos(phi)
%   cos(delta_r) = kr*sin(th)*cos(alpha - phi)
% INTEGRAND: 
%   BRDF*cos(delta_i)*cos(delta_r)*sin(th) = ki*kr*sin(th)^2*cos(phi)*cos(alpha-phi)./(ki*cos(phi) + kr*cos(alpha-phi))

brdf_lommel = @(alpha, th, phi, ki, kr) 1./(sin(th).*cos(phi) + sin(th).*cos(alpha-phi));
integrand_lommel = @(alpha, th, phi, ki, kr) (ki*kr*sin(th).^2.*cos(phi).*cos(alpha-phi))./(ki*cos(phi) + kr*cos(alpha-phi));
integral_lommel = @(alpha, th1, th2, phi1, phi2, ki, kr) integral2(@(th, phi) integrand_lommel(alpha, th, phi, ki, kr), th1, th2, phi1, phi2);
phase_law_lommel = @(alpha) (1 + sin(alpha/2).*tan(alpha/2).*log(tan(alpha/4))).*(abs(alpha - 0) > eps & abs(alpha - pi) > eps) + 1*(abs(alpha - 0) <= eps) + 0*(abs(alpha - pi) <= eps);


%% AREA
%   BRDF = sec(delta_i)/ki = 1/(ki*cos(delta_i))
%   cos(delta_i) = ki*sin(th)*cos(phi)
%   cos(delta_r) = kr*sin(th)*cos(alpha-phi)
% INTEGRAND: 
%   BRDF*cos(delta_i)*cos(delta_r)*sin(th) = kr*sin(th).^2.*cos(alpha-phi)

brdf_area = @(alpha, th, phi, ki, kr) 1/(ki*sin(th)*cos(phi));
integrand_area = @(alpha, th, phi, ki, kr) kr*sin(th).^2.*cos(alpha-phi);
integral_area_undefined = @(alpha, th1, th2, phi, ki, kr) 1/2*kr*(th2 - sin(th2).*cos(th2) - (th1 - sin(th1).*cos(th1))).*(sin(phi - alpha));
integral_area = @(alpha, th1, th2, phi1, phi2, ki, kr) integral_area_undefined(alpha, th1, th2, phi2, ki, kr) - integral_area_undefined(alpha, th1, th2, phi1, ki, kr);
phase_law_area = @(alpha) 1/2*(1 + cos(alpha));

%% OREN - MAYAR
%   BRDF = BRDF_direct + BRDF_inter
%       BRDF_direct = (C1 + ...
%                      C2.*cdaz.*tan(beta) + ...
%                      C3.*(1 - abs(cdaz)).*tan((alpha + beta)/2));
%       BRDF_inter = 0.17*albedo.*roughness^2/(roughness^2 + 0.13).*(1 - cdaz.*(2*beta/pi).^2);
%           c1 = 1 - 0.5*roughness^2/(roughness^2 + 0.33);
%           c2 = 0.45*roughness^2/(roughness^2 + 0.09)*(sin(alpha) - (cdaz < 0) * (2*beta/pi).^3)
%           c3 = 0.125*roughness^2/(roughness^2 + 0.09)*(4*alpha.*beta/(pi^2)).^2;
%               alpha = max(delta_i, delta_r)
%               beta = min(delta_i, delta_r)
%               cdaz = cos(az_r - az_i)
%   cos(delta_i) = ki*sin(th)*cos(phi)
%   cos(delta_r) = kr*sin(th)*cos(alpha-phi)
%   cot(az_i) = -cos(th)*cot(phi)
%   cot(az_r) = cos(th)*cot(alpha-phi)
% INTEGRAND: 
%   BRDF*cos(delta_i)*cos(delta_r)*sin(th) = ...

brdf_oren_alpha = @(alpha, th, phi, ki, kr) max(acos(ki*sin(th).*cos(phi)), acos(kr*sin(th).*cos(alpha-phi)));
brdf_oren_beta = @(alpha, th, phi, ki, kr) min(acos(ki*sin(th).*cos(phi)), acos(kr*sin(th).*cos(alpha-phi))); 
brdf_oren_cdaz = @(alpha, th, phi) cos(acot(cos(th).*cot(alpha-phi)) - acot(-cos(th).*cot(phi))); 
brdf_oren_direct_c1 = @(roughness) 1 - 0.5*roughness^2./(roughness^2 + 0.33);
brdf_oren_direct_c2 = @(alpha, th, phi, roughness, ki, kr) 0.45*roughness^2./(roughness^2 + 0.09).*(sin(brdf_oren_alpha(alpha, th, phi, ki, kr)) - (brdf_oren_cdaz(alpha, th, phi) < 0) .* (2*brdf_oren_beta(alpha, th, phi, ki, kr)/pi).^3);
brdf_oren_direct_c3 = @(alpha, th, phi, roughness, ki, kr) 0.125*roughness^2./(roughness^2 + 0.09).*(4*brdf_oren_alpha(alpha, th, phi, ki, kr).*brdf_oren_beta(alpha, th, phi, ki, kr)/(pi^2)).^2;
brdf_oren_direct = @(alpha, th, phi, roughness, ki, kr) ...
                   (brdf_oren_direct_c1(roughness) + ...
                    brdf_oren_direct_c2(alpha, th, phi, roughness, ki, kr).*brdf_oren_cdaz(alpha, th, phi).*tan(brdf_oren_beta(alpha, th, phi, ki, kr)) + ...
                    brdf_oren_direct_c3(alpha, th, phi, roughness, ki, kr).*(1 - abs(brdf_oren_cdaz(alpha, th, phi))).*tan((brdf_oren_alpha(alpha, th, phi, ki, kr) + brdf_oren_beta(alpha, th, phi, ki, kr))/2));
brdf_oren_inter = @(alpha, th, phi, roughness, albedo, ki, kr) ...
                    0.17*albedo.*roughness^2/(roughness^2 + 0.13).*(1 - brdf_oren_cdaz(alpha, th, phi).*(2*brdf_oren_beta(alpha, th, phi, ki, kr)/pi).^2);
brdf_oren = @(alpha, th, phi, roughness, albedo, ki, kr) ...
            brdf_oren_direct(alpha, th, phi, roughness, ki, kr) + ...
            brdf_oren_inter(alpha, th, phi, roughness, albedo, ki, kr);
integrand_oren = @(alpha, th, phi, roughness, albedo, ki, kr) brdf_oren(alpha, th, phi, roughness, albedo, ki, kr).*(ki*kr*sin(th).^3.*cos(phi).*cos(alpha - phi));
integral_oren = @(alpha, th1, th2, phi1, phi2, roughness, albedo, ki, kr) ...
        integral2(@(th_span, phi_span) integrand_oren(alpha, th_span, phi_span, roughness, albedo, ki, kr),...
            th1, th2, phi1, phi2, 'method','iterated');
trapz_oren = @(alpha, thv, phiv, roughness, albedo, ki, kr)...
        trapz(thv, trapz(phiv, integrand_oren(alpha, thv, phiv', roughness, albedo, ki, kr), 1), 2);


%% SPECULAR
%   BRDF = (2*cos(delta_i)*cos(delta_r) - cos(delta_i))^shineness
%   cos(delta_i) = ki*sin(theta)*cos(phi)
%   cos(delta_r) = kr*sin(theta)*cos(alpha-phi)
% INTEGRAND: 
%   BRDF*cos(delta_i)*cos(delta_r)*sin(th) = ...

brdf_specular = @(alpha, th, phi, shineness, ki, kr) ...
    (max(0, 2*ki*kr*sin(th).^2.*cos(phi).*cos(alpha - phi) - ki*sin(th).*cos(phi))).^shineness;
integrand_specular = @(alpha, th, phi, shineness, ki, kr) brdf_specular(alpha, th, phi, shineness, ki, kr).*(sin(th).^3.*cos(phi).*cos(alpha - phi));
integral_specular = @(alpha, th1, th2, phi1, phi2, shineness, ki, kr) ...
        integral2(@(th_span, phi_span) integrand_specular(alpha, th_span, phi_span, shineness, ki, kr),...
            th1, th2, phi1, phi2, 'method','iterated');
trapz_specular = @(alpha, thv, phiv, shineness, ki, kr)...
        trapz(thv, trapz(phiv, integrand_specular(alpha, thv, phiv', shineness, ki, kr), 1), 2);

%% PHONG
%   BRDF = wl*BRDFlambert + ws*BRDFspecular

integral_phong = ....
    @(alpha, th1, th2, phi1, phi2, shineness, wl, ws, ki, kr) ...
        wl*integral_lambert(alpha, th1, th2, phi1, phi2, ki, kr) + ...
        ws*integral_specular(alpha, th1, th2, phi1, phi2, shineness, ki, kr);
trapz_phong = ....
    @(alpha, thv, phiv, shineness, wl, ws, ki, kr) ...
        wl*integral_lambert(alpha, thv(1), thv(end), phiv(1), phiv(end), ki, kr) + ...
        ws*trapz_specular(alpha, thv, phiv, shineness, ki, kr);