function out = getvar(a,idx,type)

global DAE

out = [];

if ~a.n, return, end

if isempty(idx), return, end

switch type
 case 'pm'
  out = DAE.y(a.pm(idx));
 case 'vf'
  out = DAE.y(a.vf(idx));
 case 'xd'
  out = a.con(idx,8);
 case 'xd1'
  out = a.con(idx,9);
 case 'xq'
  out = a.con(idx,13);
 case 'M'
  out = a.u(idx).*a.con(idx,18);
 case 'COI'
  out = a.con(idx,27);
 case 'mva'
  out = a.con(idx,2);
 case 'e1q'
  out = a.u(idx).*DAE.x(a.e1q(idx));
 case 'delta'
  out = a.u(idx).*DAE.x(a.delta(idx));
 case 'omega'
  out = a.u(idx).*DAE.x(a.omega(idx));
end
