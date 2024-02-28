function q_out = quat_conj(qin)
%  Simple quaternion inversion
%
%  q = cp_quat_conj(qin)
%
%  @inputs
%       qin:    Input quaternion
%
%  @outputs
%       xOut:   Output quaternion

q_out = [ +qin(1,:)
			-qin(2:4,:) ];

end
