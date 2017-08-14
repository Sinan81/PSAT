function a = add_mass(a,data)

a.n = a.n + length(data(1,:));
a.con = [a.con; data];
a.syn = [a.syn; round(data(:,1))];
