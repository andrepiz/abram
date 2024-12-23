function update_flag = update_flag_trigger(obj, objInput, update_flag, fields)     
%UPDATE_FLAG_TRIGGER Trigger the update flag in case the object or fields of the
%object are modified

st = dbstack;

% Check the update only if the call does not come from
% rendering method
if ~any(strcmp({st.name}, 'render.rendering')) && ~isempty(obj) 
    if ~exist('fields','var')
        % Compare the whole object
        if check_equivalence(obj,  objInput)
            % Do not update if they are equivalent and update
            % flag is not true
            update_flag = false | update_flag;    
        else
            % Update if any change is detected
            update_flag = true;
        end
    else
        % Compare each field of the object
        for ix = 1:length(fields)
            field_temp = fields{ix};
            update_flag = update_flag_trigger(obj.(field_temp), objInput.(field_temp), update_flag);
        end
    end
end

end

