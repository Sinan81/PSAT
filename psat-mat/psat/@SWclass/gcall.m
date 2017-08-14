function p = gcall(p)

global DAE Settings Bus PV

if ~p.n, return, end

idx = find(p.u);
DAE.g(p.bus(idx)) = 0;
if ~Settings.pv2pq 
  DAE.g(p.vbus(idx)) = 0;   
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

% Q min
% ================================================

% Limit check improved by Lars L. 2006-01.
[tmp,idx] = max(p.u.*(p.con(:,7) - DAE.g(p.vbus) - prev_err));  

if tmp > 0 && ~PV.newpq
  if ~p.dq(idx)
    fm_disp(['Switch SW bus <', ...
             Bus.names{p.bus(idx)}, ...
             '> to theta-Q bus: Min Qg reached'])
  end
  p.qg(idx) = p.con(idx,7);    
  p.dq(idx) = 1;
end

% Q max
% ================================================

% Limit check improved by Lars L. 2006-01.
[tmp,idx] = min(p.u.*(p.con(:,6) - DAE.g(p.vbus) + prev_err));

if tmp < 0 && ~PV.newpq 
  if ~p.dq(idx)
    fm_disp(['Switch SW bus <', ...
             Bus.names{p.bus(idx)}, ...
             '> to theta-Q bus: Max Qg reached'])
  end
  p.qg(idx) = p.con(idx,6);    
  p.dq(idx) = 1;
end

% Generator reactive powers
% ================================================

DAE.g(p.vbus) = DAE.g(p.vbus) - p.u.*p.qg;
DAE.g(p.vbus(find(~p.dq & p.u))) = 0;
