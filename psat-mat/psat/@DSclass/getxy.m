function [x,y] = getxy(a,bus,x,y)

global Syn

if ~a.n, return, end

h = find(ismember(Syn.bus(a.syn),bus));

if ~isempty(h)
  x = [x; a.delta_HP(h); a.omega_HP(h); ...
       a.delta_IP(h); a.omega_IP(h); ...
       a.delta_LP(h); a.omega_LP(h); ...
       a.delta_EX(h); a.omega_EX(h)];
end
