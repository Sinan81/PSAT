function p = gcall(p)

global DAE Bus Settings

if ~p.n, return, end

K = p.u.*(1+DAE.kg*p.con(:,10));
DAE.g(p.bus) = DAE.g(p.bus) - K.*p.con(:,4);
if ~Settings.pv2pq
  DAE.g(p.vbus(find(p.u))) = 0;   
  return
end

% ================================================
% check reactive power limits
% ================================================

% find max mismatch error
if isempty(DAE.g) || Settings.iter < Settings.pv2pqniter
  prev_err = 1e6;
else
  prev_err = 2*Settings.error;
end
p.newpq = 0;

% Q min
% ================================================

% Limit check improved by Lars L. 2006-01.
[tmp,idx] = max(p.u.*(p.con(:,7) - DAE.g(p.vbus) - prev_err));  

if tmp > 0
  if ~p.pq(idx)
    fm_disp(['Switch PV bus <', Bus.names{p.bus(idx)}, '> to PQ bus: Min Qg reached'])
  end
  p.qg(idx) = p.con(idx,7);    
  p.pq(idx) = 1;
  p.newpq = ~Settings.multipvswitch;
end

% Q max
% ================================================

% Limit check improved by Lars L. 2006-01.
[tmp,idx] = min(p.u.*(p.con(:,6) - DAE.g(p.vbus) + prev_err));

if tmp < 0 && ~p.newpq
  if ~p.pq(idx)
    fm_disp(['Switch PV bus <', Bus.names{p.bus(idx)}, '> to PQ bus: Max Qg reached'])
  end
  p.qg(idx) = p.con(idx,6);    
  p.pq(idx) = 1;
  p.newpq = ~Settings.multipvswitch;
end

% Generator reactive powers
% ================================================

DAE.g(p.vbus) = DAE.g(p.vbus) - p.u.*p.qg;
DAE.g(p.vbus(find(~p.pq & p.u))) = 0;
