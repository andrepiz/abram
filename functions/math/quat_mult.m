function q_out = quat_mult(q1_s,q2_s,conj)
%  Efficient quaternion multiplication extended to multi-quaternion vector,
% i.e. q1 is [4-by-N1] and q2 [4-by-N2] with N1=N2, or N1=1 & N2 whatever,.
%      or  N1 whatever & N2=1
%
%  qn = cp_quat_mult(q1,q2)
%    This function returns q = q1*q2
%
%   q1: First rotation quaternion
%   q2: Second rotation quaternion
%   conj: if present and one, the first quaternion is conjugated before
%   the multiplication is made
%
%   qn: Resultant rotation quaternion (normalized)
%       q = q0+i*q1+j*q2+k*q3
%
%_____________________________________________________________________
%*********************************************************************

if(~exist('conj','var'))
    conj = false;
end

if(conj)
	q1_s  = quat_conj(q1_s);
end

if ~(size(q1_s,1)==4 )
    error('q1_s is not 4-by-N')
end
if ~(size(q2_s,1)==4 )
    error('q2_s is not 4-by-N')
end
N1 = size(q1_s,2);
N2 = size(q2_s,2);
if N1~=N2 && N1~=1 && N2~=1
    error('Quaternion sizes are not compatible.')
end

if N1==1
    q1_s = q1_s*ones(1,N2);
end
if N2==1
    q2_s = q2_s*ones(1,N1);
end

% calc quat product
A = (q1_s(1,:)+q1_s(2,:)).*(q2_s(1,:)+q2_s(2,:));
B = (q1_s(4,:)-q1_s(3,:)).*(q2_s(3,:)-q2_s(4,:));
C = (q1_s(1,:)-q1_s(2,:)).*(q2_s(3,:)+q2_s(4,:));
D = (q1_s(3,:)+q1_s(4,:)).*(q2_s(1,:)-q2_s(2,:));
E = (q1_s(2,:)+q1_s(4,:)).*(q2_s(2,:)+q2_s(3,:));
F = (q1_s(2,:)-q1_s(4,:)).*(q2_s(2,:)-q2_s(3,:));
G = (q1_s(1,:)+q1_s(3,:)).*(q2_s(1,:)-q2_s(4,:));
H = (q1_s(1,:)-q1_s(3,:)).*(q2_s(1,:)+q2_s(4,:));

qr1 = B + (-E - F + G + H)/2;
qr2 = A - (E + F + G + H)/2;
qr3 = C + (E - F + G - H)/2;
qr4 = D + (E - F - G + H)/2;
q = [qr1;qr2;qr3;qr4];
% DO NOT ADD NORMALIZATION AS VECTOR ROTATION USES QUATERNION PRODUCT WITH
% OUT NORMALIZATION
q_out = q;

end
