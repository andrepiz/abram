function [pGeom, pNorm, pBond, pSSA] = convertAlbedo(albedo_in, albedo_type, reflection_model, reflection_model_params)

switch reflection_model

    case {'lambert','oren','specular','phong'}
        pSSA = [];

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
                error(['Use geometric, normal or bond albedo types for ', char(reflection_model), ' reflection model.'])
        end

    case 'lommel'
        pSSA = [];

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
                error(['Use geometric, normal or bond albedo types for ', char(reflection_model), ' reflection model.'])
        end

    case 'area'
        pSSA = [];

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
                error(['Use geometric, normal or bond albedo types for ', char(reflection_model), ' reflection model.'])
        end

    case 'hapke1981'

        nparams = length(reflection_model_params);
        if nparams < 2 | nparams > 3
            error('Model parameters for hapke1981 model should be at least 2 and maximum 3, in this order: [b, c, B0]. Use hapke model for full 8-parameters formulation.')
        end
        b = reflection_model_params(1);
        c = reflection_model_params(2);
        if length(reflection_model_params) == 2
            B0 = exp(-pSSA.^2); % approx in Hapke 1981 but rejected in later articles, not use it!
            warning('B0 approximated as exp(-albedo^2) as per [Hapke 1981] but this approximation was rejected later on')
        elseif length(reflection_model_params) == 3
            B0 = reflection_model_params(3);
        end
        
        switch albedo_type
            case {'singlescattering','ssa'}
                pSSA = albedo_in;
            case {'geometric', 'normal','bond'}
                % Implicit retrieval of pSSA
                [pSSA, res] = fzero(@(x) residual_hapke_albedo(x, [b, c, 0, 1, B0, 1, 0, 0], albedo_in, albedo_type), albedo_in);
            otherwise
                error(['Use geometric, normal, bond or ssa albedo types for ', char(reflection_model), ' reflection model.'])
        end
        [pGeom, pNorm, pBond] = abram.brdf.hapkeAlbedo(pSSA, b, c, 0, 1, B0, 1, 0, 0);

    case 'hapke'

        nparams = length(reflection_model_params);
        if nparams < 6 | nparams > 8
            error('Model parameters for hapke model should be at least 6 and maximum 8, in this order: [b, c, B0_CBOE, h_CBOE, B0_SHOE, h_SHOE, roughness, filling_factor].');
        end
        b = reflection_model_params(1);
        c = reflection_model_params(2);
        B0_CBOE = reflection_model_params(3);
        h_CBOE = reflection_model_params(4);
        B0_SHOE = reflection_model_params(5);
        h_SHOE = reflection_model_params(6);
        if nparams > 6; effective_roughness = reflection_model_params(7); else; effective_roughness = 0; end
        if nparams > 7; filling_factor = reflection_model_params(8); else; filling_factor = 0; end

        switch albedo_type
            case {'singlescattering','ssa'}
                pSSA = albedo_in;
            case {'geometric', 'normal','bond'}
                % Implicit retrieval of pSSA
                [pSSA, res] = fzero(@(x) residual_hapke_albedo(x, [b, c, B0_CBOE, h_CBOE, B0_SHOE, h_SHOE, effective_roughness, filling_factor], albedo_in, albedo_type), albedo_in);
            otherwise
                error(['Use geometric, normal, bond or ssa albedo types for ', char(reflection_model), ' reflection model.'])
        end
        [pGeom, pNorm, pBond] = abram.brdf.hapkeAlbedo(pSSA, b, c, B0_CBOE, h_CBOE, B0_SHOE, h_SHOE, effective_roughness, filling_factor);

    otherwise
        error('Use lambert, lommel, area, oren, phon, hapke or hapke1981 reflection models.')
end

end


function res = residual_hapke_albedo(pSSA, hapkeParams, albedoIn, albedoType)

[pGeomTemp, pNormTemp, pBondTemp] = abram.brdf.hapkeAlbedo(pSSA, hapkeParams(1), hapkeParams(2), hapkeParams(3), hapkeParams(4), hapkeParams(5), hapkeParams(6), hapkeParams(7), hapkeParams(8));
switch albedoType
    case 'geometric'
        res = albedoIn - pGeomTemp;
    case 'normal'
        res = albedoIn - pNormTemp;
    case 'bond'
        res = albedoIn - pBondTemp;
end

end