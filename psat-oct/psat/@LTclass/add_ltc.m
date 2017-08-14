function a = add_ltc(a,data)

a.con = [a.con; data];
a = setup_ltc(a);
