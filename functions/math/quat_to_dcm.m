function M = quat_to_dcm(q)
%  Efficient conversion from quaternion to rotation matrix
%  Heritage
%  M = ixvfes_quatToMat(q)
%    Converts quaternion to rotation matrix.
%
%    q: Quaternion
%       q = q0+i*q1+j*q2+k*q3
%
%    M: Rotation matrix

% Calculate coefficients
if size(q,1)~=4
    error('Input must have 4 rows')
end

n_elements = size(q,2);

x2 = q(2,:) + q(2,:);
y2 = q(3,:) + q(3,:);
z2 = q(4,:) + q(4,:);
xx = q(2,:) .* x2;
xy = q(2,:) .* y2;
xz = q(2,:) .* z2;
yy = q(3,:) .* y2;
yz = q(3,:) .* z2;
zz = q(4,:) .* z2;
wx = q(1,:) .* x2;
wy = q(1,:) .* y2;
wz = q(1,:) .* z2;

M = cast(zeros(3,3,n_elements),'like',q);

M(1,1,:) = 1.0 - (yy + zz);
M(2,1,:) = xy - wz;
M(3,1,:) = xz + wy;
M(1,2,:) = xy + wz;
M(2,2,:) = 1.0 - (xx + zz);
M(3,2,:) = yz - wx;
M(1,3,:) = xz - wy;
M(2,3,:) = yz + wx;
M(3,3,:) = 1.0 - (xx + yy);
    
end