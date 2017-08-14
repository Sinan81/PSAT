function [x,y] = getxy(a,bus,x,y)

global Sssc Statcom Svc Tcsc Upfc Dfig

if ~a.n, return, end

type = a.con(:,4);
a1 = find(type == 1);
a2 = find(type == 2);
a3 = find(type == 3);
a4 = find(type == 4);
a5 = find(type == 5);
a6 = find(type == 6);

h = zeros(a.n,1);

h(a1) = ismember(Svc.bus(a.con(a1,2)),bus);

h1 = ismember(Tcsc.bus1(a.con(a2,2)),bus); 
h2 = ismember(Tcsc.bus2(a.con(a2,2)),bus); 
h(a2) = h1+h2;

h(a3) = ismember(Statcom.bus(a.con(a3,2)),bus);

h1 = ismember(Sssc.bus1(a.con(a4,2)),bus); 
h2 = ismember(Sssc.bus2(a.con(a4,2)),bus); 
h(a4) = h1+h2;

h1 = ismember(Upfc.bus1(a.con(a5,2)),bus); 
h2 = ismember(Upfc.bus2(a.con(a5,2)),bus); 
h(a5) = h1+h2;

h(a6) = ismember(Dfig.bus(a.con(a6,2)),bus);

h = find(h);

if ~isempty(h)
  x = [x; a.v1(h); a.v2(h); a.v3(h)];
  y = [y; a.Vs(h)];
end
