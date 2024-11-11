function st = add_missing_field(st, fd)

if iscell(fd)
    for ix = 1:length(fd)
        st = add_missing_field(st, fd{ix});
    end
else
    if ~isfield(st, fd)
        st.(fd)= []; 
    end
end

end