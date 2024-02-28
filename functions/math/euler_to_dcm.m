function dcm = euler_to_dcm(euler,p)
% This function converts from euler angles [3 x n-set-of-angles] to a direct rotation matrix
% Input: Euler angles according to p.sequence convention [rad]
% Outputs: rotation matrix (3 x 3 x n-set-of-angles)
% The angles in input must be ordered according to the convention
% RPY: [roll,pitch,yaw] (Default)
% ZYX: [yaw,pitch,roll]
% REMARK: RPY and ZYX espress the same set of angles with the only difference
% of the assumed order of the angles in the input

exp_str.sequence   = 'RPY';

if(~exist('p','var')), p = []; end
p = check_input_pars(exp_str,p);

if size(euler,1)~=3
    error('Input must have 3 rows')
end

n_ang = size(euler,2);

switch p.sequence
    case {'RPY','rpy'}
        
        c_roll = reshape(cos(euler(1,:)),1,1,n_ang);
        s_roll = reshape(sin(euler(1,:)),1,1,n_ang);
        c_pitch = reshape(cos(euler(2,:)),1,1,n_ang);
        s_pitch = reshape(sin(euler(2,:)),1,1,n_ang);
        c_yaw = reshape(cos(euler(3,:)),1,1,n_ang);
        s_yaw = reshape(sin(euler(3,:)),1,1,n_ang);
        
        dcm = [ c_pitch .* c_yaw     ,   c_pitch .* s_yaw     ,   -s_pitch ; ...
            s_roll .* s_pitch .* c_yaw - c_roll .* s_yaw , s_roll .* s_pitch .* s_yaw + c_roll .* c_yaw , c_pitch .* s_roll ; ...
            c_roll .* s_pitch .* c_yaw + s_roll .* s_yaw , c_roll .* s_pitch .* s_yaw - s_roll .* c_yaw , c_pitch .* c_roll ];    
        
    case {'321','ZYX','zyx'}
        dcm = cp_euler_to_dcm(euler([3,2,1]',:,:));

    otherwise
        error(['Unknown sequence ' p.sequence]);
end

end

