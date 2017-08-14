function a = add_spv(a,data)

a.con = [a.con; data];
a = setup_spv(a);
