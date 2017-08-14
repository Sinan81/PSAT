function a = add_phs(a,data)

global Bus

a.n = a.n + length(data(1,:));
a.con = [a.con; data];
[a.bus1,a.v1] = getbus_bus(Bus,a.con(:,1));
[a.bus2,a.v2] = getbus_bus(Bus,a.con(:,2));

