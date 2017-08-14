function a = add_spq(a,data)

a.con = [a.con; data];
a = setup_spq(a);
