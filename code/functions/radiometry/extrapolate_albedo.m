function [pGeom, pNorm, pBond] = extrapolate_albedo(albedo_in, albedo_type, reflectance_model)

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

    otherwise
        error('Use lambert, lommel, area or oren reflection models')
end

end