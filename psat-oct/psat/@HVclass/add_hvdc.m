function a = add_hvdc(a,data)

a.con = [a.con; data];
a = setup_hvdc(a)
