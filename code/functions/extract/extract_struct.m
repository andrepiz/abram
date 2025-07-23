function val = extract_struct(st, field, def, flag_warning)
% Extract the value of an input from the field of a struct, if present. If
% not present, set the default value and raise a warning if flag is true.
% If default value input is missing, raise an error.

if ~exist('flag_warning','var')
    flag_warning = false;
end

if isfield(st, field)
    val = st.(field);
    if iscell(val)
        val = cell2mat(val);
    end
else
    if ~exist('def','var')
        error('abram:io',[field ,' missing!'])
    end
    val = def;
    if flag_warning
        warning('abram:io',[field ,' missing, using default value ', num2str(def)])
    end
end

end
