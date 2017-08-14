function a = add_pmu(a,data)

global Line

a.n = a.n + length(data(1,:));
a.con = [a.con; data];
