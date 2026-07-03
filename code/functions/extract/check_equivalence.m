function res = check_equivalence(obj1, obj2)

if isempty(obj1) && isempty(obj2)
    res = true;
elseif (~isempty(obj1) && isempty(obj2)) || (isempty(obj1) && ~isempty(obj2)) 
    res = false;
else
    res = isequal(obj1, obj2);
end

end