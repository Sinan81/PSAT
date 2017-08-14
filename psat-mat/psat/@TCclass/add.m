function a = add(a,data)

global Line Bus

a.n = a.n + length(data(1,:));
a.con = [a.con; data];
a.line = [a.line; data(:,1)];
a.bus1 = [a.bus1; Line.fr(data(:,1))];
a.bus2 = [a.bus2; Line.to(data(:,1))];
a.v1 = a.bus1 + Bus.n;
a.v2 = a.bus2 + Bus.n;
