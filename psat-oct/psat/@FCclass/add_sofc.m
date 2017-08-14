function a = add_sofc(a,data)

a.n = a.n + length(data(1,:));
a = setup_sofc(a);
