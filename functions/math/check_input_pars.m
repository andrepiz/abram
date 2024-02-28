function params = check_input_pars(std_str,params)

    if(ischar(params))
        if(any(strcmp({'params','par','pars'},params)))
            std_str %#ok<NOPRT>
        end
    end

	if(isempty(params))
		params = std_str;
		return;
	end
	
    fields_in       = fieldnames(params);
    fields_std      = fieldnames(std_str);
    
    n_fields_in     = length(fields_in);
    n_fields_std    = length(fields_std);
    
    for i = 1:n_fields_std
        % input structure do not have the standard field
        if(~isfield(params,fields_std{i}))
            % no default value defined
            if(isnumeric(std_str.(fields_std{i})))&& (isempty(std_str.(fields_std{i})))
%               disp_necessary_fields(std_str);
                error(['Field "' fields_std{i} '" must be part of the input parameters']);
            else
                params.(fields_std{i})  = std_str.(fields_std{i});
            end
        end
    end
    
    for i = 1:n_fields_in
        if(~isfield(std_str,fields_in{i}))
            warning('ParameterFieldNotNeeded',['Field "' fields_in{i} '" is not actually needed by this function']);
        end
    end
        
end