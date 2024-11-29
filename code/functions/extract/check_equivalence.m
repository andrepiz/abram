function res = check_equivalence(obj1, obj2)

if isempty(obj1) || isempty(obj2)
    res = true;
else
    res = isequal(obj1, obj2);
end

end