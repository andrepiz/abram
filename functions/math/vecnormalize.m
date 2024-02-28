function x_out = vecnormalize(x_in,p)
% normalize a vector or a matrix (seen as a collection of vectors) along the specified dimension
% dim=1: each column in x_in is divided by its norm
% dim=2: each row in x_in is divided by its norm

exp_str.dim   = 1;

if(~exist('p','var'))
    p = [];
elseif isnumeric(p)
    p = struct('dim',p);
end
p = check_input_pars(exp_str,p);

switch p.dim
    case 1
        mn = [size(x_in,1) 1];
    case 2
        mn = [1 size(x_in,2)];
    otherwise
        error('dim can be 1 (normalize column vectors) or 2 (normalize row vectors)')
end

x_out = x_in./repmat(vecnorm(x_in,2,p.dim),mn);

end