function a = setup(a)

global Bus

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));
[a.bus,a.vbus] = getbus(Bus,a.con(:,1));

% fault occurrence and clearing times
idx = find(a.con(:,5) == 0);
if ~isempty(idx)
  a.con(idx,5) = 1e-6;
  a.con(idx,6) = a.con(idx,6)+1e-6;
end

% consistency of clearing times
idx = find((a.con(:,6) - a.con(:,5)) < 0);
if ~isempty(idx)
  fm_disp('Warning: The fault clearing time must be greater than the fault time',2);
  a.con(idx,6) = a.con(idx,6) + a.con(idx,5);
  fm_disp(fm_strjoin('         Fault #',int2str(idx), ...
                 ' at bus #',Bus.names(a.bus(idx)), ...
                 ': clearing time changed to <', ...
                 num2str(a.con(idx,6)), '> s.'))
end

% fault status:
%
% 0 before and after fault
% 1 during fault

a.u = zeros(a.n,1);

% dat:
%
% 1.  fault conductance
% 2.  fault susceptance

z = a.con(:,7) + i*a.con(:,8);
z(find(abs(z) == 0)) = i*1e-6;
y = conj(1./z);

a.dat= [real(y), imag(y)];

a.store = a.con;
