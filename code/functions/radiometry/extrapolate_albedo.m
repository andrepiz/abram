function [pGeom, pNorm, pBond] = extrapolate_albedo(albedo_in, albedo_type, reflectance_model, varargin)

switch reflectance_model

    case {'lambert','oren','specular','phong','hapke'}

        switch albedo_type

            case 'geometric'
                pGeom = albedo_in;
                pNorm = pGeom/(2/3); 
                pBond = pNorm;

            case 'normal'
                pNorm = albedo_in;
                pBond = pNorm;
                pGeom = 2/3*pNorm; 

            case 'bond' 
                pBond = albedo_in;
                pNorm = pBond;
                pGeom = 2/3*pNorm;
                
            otherwise
                error('Use geometric, normal or bond albedo types')
        end

    case 'lommel'

        switch albedo_type

            case 'geometric'
                pGeom = albedo_in;
                pNorm = pGeom; 
                pBond = 16*pGeom*(1-log(2))/3;

            case 'normal'
                pNorm = albedo_in;
                pGeom = pNorm; 
                pBond = 16*pGeom*(1-log(2))/3;

            case 'bond'
                pBond = albedo_in;
                pNorm = 1/2*pBond/(8*(1-log(2))/3);
                pGeom = pNorm;

            otherwise
                error('Use geometric, normal or bond albedo types')
        end

    case 'area'

        switch albedo_type

            case 'geometric'
                pGeom = albedo_in;
                pNorm = pGeom;
                pBond = 2*pGeom; 

            case 'normal'
                pNorm = albedo_in;
                pGeom = pNorm;
                pBond = 2*pGeom; 

            case 'bond'
                pBond = albedo_in;
                pNorm = 1/2*pBond;
                pGeom = pNorm;
                
            otherwise
                error('Use geometric, normal or bond albedo types')
        end

    case 'hapke1981'

        switch albedo_type 

            case 'singlescattering'

                b = varargin{1};
                c = varargin{2};
                SSA = albedo_in;
                if length(varargin) == 2
                    B0 = exp(-SSA.^2); % approx in Hapke 1981 but rejected in later articles, not use it!
                    warning('B0 approximated as exp(-albedo^2) as per [Hapke 1981] but this approximation was rejected later on')
                else
                    B0 = varargin{3};
                end
                pGeom = abram.brdf.hapkeGeometricAlbedo(SSA, b, c, ...
                                                    0, 1, ...
                                                    B0, 1, ...
                                                    0, 0);
                    
                % b2 = b.^2;
                % P0 = (1 + c)/2 .* (1 - b2)./((1 - 2*b + b2).^1.5) + ...
                %     (1 - c)/2 .* (1 - b2)./((1 + 2*b + b2).^1.5);
                % 
                % SSPF0 = abram.brdf.hapkeSSPF(0, b, c);
                % gamma = sqrt(1 - SSA);
                % r0 = (1 - gamma)./(1 + gamma);


            otherwise
                error('When using hapke1981 reflection model, the input albedo type must be "singlescattering"')
        end

    otherwise
        error('Use lambert, lommel, area, oren, phon, hapke or hapke1981 reflection models')
end

end