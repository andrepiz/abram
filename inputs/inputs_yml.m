inputs = yaml.ReadYaml(filename_yml);

if isempty(fields(inputs))
    error('No inputs file recognized')
else
    parse_inputs_yml();
end

prepro();
