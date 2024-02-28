function quat_vector = dcm_to_quat(dcm)
% Transforms a rotation matrix to an equivalent quaternion.
% The output quaternion has the format: q = q0 + q1.i + q2.j + q3.k
 
q0 = 0.5 * sqrt( abs(1+squeeze(dcm(1,1,:)+dcm(2,2,:)+dcm(3,3,:))) )';
q1 = 0.5 * sqrt( abs(1+squeeze(dcm(1,1,:)-dcm(2,2,:)-dcm(3,3,:))) )';
q3 = 0.5 * sqrt( abs(1+squeeze(-dcm(1,1,:)-dcm(2,2,:)+dcm(3,3,:))) )';
q2 = 0.5 * sqrt( abs(1+squeeze(-dcm(1,1,:)+dcm(2,2,:)-dcm(3,3,:))) )';
%
%CHOOSE THE BIGGEST VALUE in order to avoid future numerical problems
%as this value will be the denominator of following computations!
maxQ = max([q1;q2;q3;q0;],[],1);


ixs0 = (q0 == maxQ);
ixs1 = (q1 == maxQ)&~ixs0;
ixs3 = (q3 == maxQ)&~(ixs1|ixs0);
ixs_def = ~(ixs0 | ixs1 | ixs3);

if any(ixs0)
    q1(ixs0)=0.25*squeeze(dcm(2,3,ixs0)-dcm(3,2,ixs0))'./q0(ixs0);
    q2(ixs0)=0.25*squeeze(dcm(3,1,ixs0)-dcm(1,3,ixs0))'./q0(ixs0);
    q3(ixs0)=0.25*squeeze(dcm(1,2,ixs0)-dcm(2,1,ixs0))'./q0(ixs0);
end
if any(ixs1)
    q2(ixs1)=0.25*squeeze(dcm(1,2,ixs1)+dcm(2,1,ixs1))'./q1(ixs1);
    q3(ixs1)=0.25*squeeze(dcm(3,1,ixs1)+dcm(1,3,ixs1))'./q1(ixs1);
    q0(ixs1)=0.25*squeeze(dcm(2,3,ixs1)-dcm(3,2,ixs1))'./q1(ixs1);
end
if any(ixs3)
    q1(ixs3)=0.25*squeeze(dcm(1,3,ixs3)+dcm(3,1,ixs3))'./q3(ixs3);
    q2(ixs3)=0.25*squeeze(dcm(2,3,ixs3)+dcm(3,2,ixs3))'./q3(ixs3);
    q0(ixs3)=0.25*squeeze(dcm(1,2,ixs3)-dcm(2,1,ixs3))'./q3(ixs3);
end
if any(ixs_def)
    q1(ixs_def)=0.25*squeeze(dcm(1,2,ixs_def)+dcm(2,1,ixs_def))'./q2(ixs_def);
    q3(ixs_def)=0.25*squeeze(dcm(2,3,ixs_def)+dcm(3,2,ixs_def))'./q2(ixs_def);
    q0(ixs_def)=0.25*squeeze(dcm(3,1,ixs_def)-dcm(1,3,ixs_def))'./q2(ixs_def);
end
quat_vector = [q0;q1;q2;q3];

end
