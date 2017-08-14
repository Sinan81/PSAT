function a = add_cswt(a,data)

a.con = [a.con; data];
a = setup_cswt(a);
